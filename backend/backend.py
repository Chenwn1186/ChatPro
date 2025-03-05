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

# 配置日志记录
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 初始化 OpenAI 客户端
# API_KEY = "3MFOSXFhX8cuMahAJVKnnR9dh31NsKMqecGTX7zX6hnTfYX03bT0fJT9DqMNshBqu"
# client = OpenAI(api_key=API_KEY, base_url="https://api.stepfun.com/v1")
API_KEY = "sk-528.kT3wdhoKY531DD59egtWtRZKT8deOwLVo0i0IxorxyQVePoY"
client = OpenAI(api_key=API_KEY, base_url="https://wcode.net/api/gpt/v1")

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

        # 读取图片元数据
        metadata = image._getexif() if image._getexif() else {}

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
    "活动"（包含描述的活动，是字符串的列表）、"情绪"（带有推理的情绪，是字符串）。
    """
    
        # 调用OpenAI API获取大模型的回复
        response = get_openai_response(conversation_str, yolo_results, metadata, prompt)

        # 处理 Markdown 格式数据，提取 JSON 内容
        start_tag = "```json"
        end_tag = "```"
        response = response.replace(start_tag, "")
        response = response.replace(end_tag, "")
        # print(f'from ip: {ip}, response:{response}')
        print(f'from ip: {ip}, response:{response}')
        return jsonify({"result": response}), 200

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
                {"type": "image_url", "image_url": {"url": image_url}},
            ],
        },
    ]
    # print(f"构建的消息内容: {image_url[:30]}")

    try:
        # 调用 OpenAI 接口获取结果
        logging.info("开始调用 OpenAI API...")
        completion = client.chat.completions.create(
            model="Doubao-1.5-vision-pro-32k", messages=messages
        )
        logging.info("成功调用 OpenAI API，获取到结果。")
    except Exception as e:
        logging.error(f"调用 OpenAI API 时出错: {e}")
        get_money()
        return f"调用 OpenAI API 时出错: {e}"
        raise
    

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
    return result



def get_money():
    url = "https://wcode.net/api/account/billing/grants"

    payload = {}
    headers = {
    'Authorization': f'Bearer {API_KEY}'
    }

    response = requests.request("GET", url, headers=headers, data=payload)

    print(f'剩余余额：{response.text}')


if __name__ == "__main__":
    app.run(host="172.16.91.233", port=5408, threaded=True)
