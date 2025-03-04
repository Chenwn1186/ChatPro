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

# 初始化 OpenAI 客户端
API_KEY = "3MFOSXFhX8cuMahAJVKnnR9dh31NsKMqecGTX7zX6hnTfYX03bT0fJT9DqMNshBqu"
client = OpenAI(api_key=API_KEY, base_url="https://api.stepfun.com/v1")


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
        conversation_str = f"data:image/{image_format};base64,{img_base64}"

        prompt = """根据提供的元数据 JSON 和图像，描述图像中的内容，包括人物、物体和事件。
    以 JSON 格式返回响应，包含以下字段："时间"（精确时间、星期几、上午/下午/晚上）、
    "地点"（位置）、"场景"（场景类型）、"人物"（包含描述的人物列表）、
    "物体"（包含描述的物体列表）、"环境"（天气等）、
    "活动"（包含描述的活动列表）、"情绪"（带有推理的情绪）"""
    
        # 调用OpenAI API获取大模型的回复
        response = get_openai_response(conversation_str, yolo_results, metadata, prompt)

        # 处理 Markdown 格式数据，提取 JSON 内容
        json_pattern = r'```json(.*?)```'
        match = re.search(json_pattern, response, re.DOTALL)
        if match:
            json_content = match.group(1).strip()
            print(f'from ip: {ip}, response:{response}')
            return jsonify({"result": json_content})
        else:
            return jsonify({"error": "未找到有效的 JSON 内容"}), 400

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

    # 调用 OpenAI 接口获取结果
    completion = client.chat.completions.create(
        model="step-1o-vision-32k", messages=messages
    )

    # 记录函数结束时间
    end_time = time.time()
    # 计算函数执行时间
    elapsed_time = end_time - start_time
    print(f"获取大模型回复所消耗的时间: {elapsed_time} 秒")

    return completion.choices[0].message.content


if __name__ == "__main__":
    app.run(host="172.16.91.233", port=5408)
