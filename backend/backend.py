import re
import cv2
from PIL import Image
import base64
import io
import torch
from ultralytics import YOLO
from flask import Flask, request, jsonify
from openai import OpenAI
import os
import time
import datetime
import logging
import requests
import json
# 配置日志记录
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 获取 backend.py 所在的目录
script_dir = os.path.dirname(os.path.abspath(__file__))

# 构建 config.json 的路径（假设 config.json 在 ChatPro 目录）
config_path = os.path.join(script_dir, '..', 'config.json')

# 读取配置文件
try:
    with open(config_path, 'r', encoding='utf-8') as f:
        config = json.load(f)
except FileNotFoundError:
    logging.error("Config file not found at: %s", config_path)
    raise

# # 读取配置文件
# with open('../config.json', 'r', encoding='utf-8') as f:
#     config = json.load(f)

# 使用从配置文件读取的 API 密钥和基础 URL
API_KEY = config["backend_apiKey"]
BASE_URL = config["backend_base_url"]
client = OpenAI(api_key=API_KEY, base_url=BASE_URL)


app = Flask(__name__)

dev = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# 加载模型
model = YOLO("D:/FlutterProjects/yolo/yolo11m.pt")


@app.route("/analyseImg", methods=["POST"])
def analyse_img():
    try:
        ip = request.remote_addr
        # 获取上传的文件
        file = request.files.get("image")
        if not file:
            return jsonify({"error": "未上传图片"}), 400

        # 打开图片
        image = Image.open(file.stream)

        # 获取图片格式信息
        image_format = image.format

        # 计算压缩前图片体积
        before_buffered = io.BytesIO()
        image.save(before_buffered, format=image_format)
        before_size = len(before_buffered.getvalue()) / (1024 * 1024)
        print(f"压缩前图片体积: {before_size:.2f} MB")

        # 进行图片质量压缩
        # 压缩质量，范围从 0 到 100，数值越小压缩率越高，图片质量越低
        quality = 70 
        buffered = io.BytesIO()
        image.save(buffered, format=image_format, quality=quality)
        # 重置文件指针到文件开头
        buffered.seek(0) 
        # 使用压缩后的图片数据重新打开图片
        image = Image.open(buffered) 

        # 读取图片元数据（在转换为 PNG 之前）
        metadata = image._getexif() if image._getexif() else {}

        # 将图像转换为 PNG 格式
        image = image.convert('RGB')
        buffered = io.BytesIO()
        image.save(buffered, format='JPEG')
        buffered.seek(0)
        image = Image.open(buffered)
        image_format = 'JPEG'

        # 计算压缩后图片体积
        after_size = len(buffered.getvalue()) / (1024 * 1024)
        print(f"压缩后图片体积: {after_size:.2f} MB")

        # 将图片转换为 base64 编码
        buffered = io.BytesIO()
        image.save(buffered, format=image_format)
        img_base64 = base64.b64encode(buffered.getvalue()).decode()

        yolo_results = model.predict(image, save=False, device=dev.index)[0].to_json()

        # 生成与大模型对话的字符串
        conversation_str = f"data:image/{image_format.lower()};base64,{img_base64}"

        prompt = """根据提供的元数据 JSON 和图像，你要尽可能详细地描述图像中的内容，包括人物、物体和事件。你要特别注意，如果以下某些字段不存在，直接返回""或者[]。
    以 JSON 格式返回响应，包含以下字段："时间"（精确时间、星期几、上午/下午/晚上，是字符串）、
    "地点"（位置，是字符串）、"场景"（场景类型，是字符串）、"人物"（包含描述的人物，是字符串的列表）、
    "物体"（包含描述的物体，是字符串的列表）、"环境"（天气等，是字符串）、
    "活动"（包含描述的活动，是字符串的列表）、"情绪"（带有推理的情绪，是字符串）、"标签"(该图片可能具有的标签，是字符串的列表)。
    """
    
        # 调用OpenAI API获取大模型的回复
        response, code = get_openai_response(conversation_str, yolo_results, metadata, prompt)

        # 处理 Markdown 格式数据，提取 JSON 内容
        start_tag = "```json"
        end_tag = "```"
        response = response.replace(start_tag, "")
        response = response.replace(end_tag, "")
        # print(f'from ip: {ip}, response:{response}')
        print(f'from ip: {ip}, response:{response}')
        return jsonify({"result": response}), code

    except Exception as e:
        return jsonify({"error": str(e)}), 500


def get_openai_response(image_url, yolo_results, metadata, prompt):
    """
    根据传入的图片URL和文本信息，调用OpenAI的API获取大模型的回复。

    :param image_url: 图片的URL地址
    :param text: 用户输入的文本描述
    :return: OpenAI大模型的回复结果
    """
    # 记录函数开始时间
    start_time = time.time()
    logging.info(f"函数开始执行，起始时间戳: {start_time}")

    # 构建请求大模型的消息
    messages = [
        {"role": "system", "content": prompt},
        {
            "role": "user",
            "content": [
                {"type": "text", "text": f'yolo results:{yolo_results}'},
                {"type": "text", "text": f'metadata:{metadata}'},
                {"type": "image_url", "image_url": {"url": image_url, "detail": "high"}},
            ],
        },
    ]
    # print(f"构建的消息内容: {image_url[:30]}")

    try:
        # 调用 OpenAI 接口获取结果
        logging.info("开始调用 OpenAI API...")
        completion = client.chat.completions.create(
            model="Doubao-1.5-vision-pro-32k", messages=messages
            # model="gpt-4-vision-preview",
            # model="yi-vision",
            # messages=messages
        )
        logging.info("成功调用 OpenAI API，获取到结果。")
    except Exception as e:
        logging.error(f"调用 OpenAI API 时出错: {e}")
        get_money()
        return f"调用 OpenAI API 时出错: {e}", 400
    

    # 记录函数结束时间
    end_time = time.time()
    # 计算函数执行时间
    elapsed_time = end_time - start_time
    
    # 将 start_time 转换为真实时间
    start_datetime = datetime.datetime.fromtimestamp(start_time)
    start_time_str = start_datetime.strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"起始时间: {start_time_str}, 获取大模型回复所消耗的时间: {elapsed_time} 秒")

    result = completion.choices[0].message.content
    # logging.info(f"大模型回复结果: {result}")
    get_money()
    return result, 200



def get_money():
    url = "https://wcode.net/api/account/billing/grants"

    payload = {}
    headers = {
        'Authorization': f'Bearer {API_KEY}'
    }

    response = requests.request("GET", url, headers=headers, data=payload)
    if response.status_code == 200:
        try:
            data = response.json()
            if data.get("status") == "success":
                total_available = data["data"]["total_available"]
                total_available_currency_symbol = data["data"]["total_available_currency_symbol"]
                print(f'剩余余额：{total_available_currency_symbol}{total_available}')
            else:
                print(f"请求失败，错误信息：{data.get('error_message', '未知错误')}")
        except (KeyError, ValueError):
            print("解析响应数据时出错，请检查响应格式。")
    else:
        print(f"请求失败，状态码：{response.status_code}")


if __name__ == "__main__":
    # app.run(host="172.16.91.233", port=5408, threaded=True)
    app.run(host="0.0.0.0", port=5408, threaded=True)
