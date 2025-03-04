import os
import json
import base64
from openai import OpenAI
from PIL import Image
from PIL.ExifTags import TAGS
from PIL.TiffImagePlugin import IFDRational
import cv2
import torch
import numpy as np
from torchvision import models, transforms


# 检查是否有可用的 CUDA 设备，如果有则使用 GPU，否则使用 CPU
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# 从 ultralytics/yolov5 仓库加载预训练的 YOLOv5s 模型，并将其移动到指定设备上
object_detector = torch.load("D:/FlutterProjects/yolo/yolo11m.pt").to(
    device
)

# Load ResNet50 model for scene classification
# 加载预训练的 ResNet50 模型，并将其设置为评估模式，然后移动到指定设备上
scene_model = models.resnet50(pretrained=True).eval().to(device)


# Clean non-JSON-serializable data types
def clean_exif_value(value):
    """
    Convert special data types to serializable formats.
    将特殊数据类型转换为可序列化的格式。
    """
    # 如果值是 IFDRational 类型，将其转换为浮点数或字符串
    if isinstance(value, IFDRational):
        return float(value) if value.denominator != 0 else str(value)
    # 如果值是字节类型，将其解码为字符串
    elif isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    # 其他类型的值直接返回
    return value


# Extract EXIF data using PIL
def get_exif_data_pil(image_path):
    """
    Extract EXIF data from the image.
    从图像中提取 EXIF 数据。
    """
    try:
        # 打开图像文件
        with Image.open(image_path) as img:
            # 获取图像的 EXIF 数据
            exif_data = img.getexif()
            # 如果存在 EXIF 数据，将标签和值进行处理并存储在字典中，否则返回空字典
            return (
                {
                    TAGS.get(tag, tag): clean_exif_value(value)
                    for tag, value in exif_data.items()
                }
                if exif_data
                else {}
            )
    except Exception as e:
        # 打印提取 EXIF 数据时的错误信息
        print(f"Error extracting EXIF data: {str(e)}")
        # 返回空字典
        return {}


# Extract metadata from the image (移除 OCR 预处理)
def extract_metadata(image_path):
    try:
        # 打印开始提取元数据的信息
        print("Starting metadata extraction...")
        # 初始化元数据字典，包含 EXIF 数据和内容分析信息
        metadata = {
            "exif_data": {},
            "content_analysis": {"scene_classification": [], "object_detection": []},
        }

        # Extract EXIF data
        # 打印开始提取 EXIF 数据的信息
        print("Extracting EXIF data...")
        # 调用 get_exif_data_pil 函数提取 EXIF 数据，并存储在元数据字典中
        metadata["exif_data"] = get_exif_data_pil(image_path)
        # 打印提取的 EXIF 数据
        print("EXIF data extracted:", metadata["exif_data"])

        # Read image
        # 打印开始读取图像的信息
        print("Reading image...")
        # 打开图像文件并转换为 RGB 模式
        pil_img = Image.open(image_path).convert("RGB")
        # 打印图像读取成功的信息
        print("Image read successfully.")

        # Scene classification
        # 打印开始场景分类的信息
        print("Starting scene classification...")
        # 定义图像预处理步骤，包括调整大小、中心裁剪、转换为张量和归一化
        preprocess = transforms.Compose(
            [
                transforms.Resize(256),
                transforms.CenterCrop(224),
                transforms.ToTensor(),
                transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
            ]
        )
        # 对图像进行预处理，并添加一个批次维度，然后移动到指定设备上
        input_tensor = preprocess(pil_img).unsqueeze(0).to(device)
        # 在不进行梯度计算的情况下，对图像进行场景分类
        with torch.no_grad():
            scene_output = torch.nn.functional.softmax(
                scene_model(input_tensor)[0], dim=0
            )
        # 打印场景分类的前 5 个输出结果
        print(
            "Scene classification output:", scene_output[:5]
        )  # Log first 5 for brevity

        # Load ImageNet labels
        # 打印开始加载标签的信息
        print("Loading labels...")
        try:
            # 打开 ImageNet 标签文件
            with open("imagenet_class_index.json", "r", encoding="utf-8") as f:
                # 加载标签数据
                labels = json.load(f)
            # 对场景分类结果进行排序，取前 3 个结果
            scene_pred = sorted(
                [
                    (labels[str(i)][1], float(scene_output[i]))
                    for i in range(len(scene_output))
                ],
                key=lambda x: -x[1],
            )[:3]
            # 将场景分类结果存储在元数据字典中
            metadata["content_analysis"]["scene_classification"] = scene_pred
            # 打印场景分类结果
            print("Scene classification result:", scene_pred)
        except Exception as e:
            # 打印加载标签时的错误信息
            print(f"Error loading labels: {str(e)}")
            # 将场景分类结果设置为空列表
            metadata["content_analysis"]["scene_classification"] = []

        # Object detection
        # 打印开始目标检测的信息
        print("Starting object detection...")
        # 将 PIL 图像转换为 OpenCV 图像格式
        cv_img = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)
        # 在自动混合精度模式下进行目标检测
        with torch.amp.autocast("cuda" if torch.cuda.is_available() else "cpu"):
            detections = object_detector(cv_img)
        # 处理目标检测结果，提取类别、置信度和边界框信息
        detected_objects = [
            {
                "class": object_detector.names[int(pred[5])],
                "confidence": float(pred[4]),
                "bbox": [int(x) for x in pred[:4].tolist()],
            }
            for pred in detections.xyxy[0].cpu().numpy()
        ]
        # 将目标检测结果存储在元数据字典中
        metadata["content_analysis"]["object_detection"] = detected_objects
        # 打印目标检测完成的信息和检测结果
        print("Object detection completed:", detected_objects)

        # 返回元数据字典
        return metadata
    except Exception as e:
        # 打印提取元数据时的错误信息
        print(f"Error in extract_metadata: {str(e)}")
        # 抛出异常
        raise


# Convert image to Base64 encoding
def encode_image(image_path):
    """
    Convert image to Base64 encoding for LLM.
    将图像转换为 Base64 编码，以便用于大语言模型。
    """
    try:
        # 以二进制模式打开图像文件
        with open(image_path, "rb") as image_file:
            # 对图像数据进行 Base64 编码，并解码为字符串
            return base64.b64encode(image_file.read()).decode("utf-8")
    except Exception as e:
        # 打印编码图像时的错误信息
        print(f"Error encoding image: {str(e)}")
        raise


# Define system instruction for LLM
def get_system_instruction():
    """基于元数据为大语言模型生成描述的系统提示。"""
    return """
    根据提供的元数据 JSON 和图像，描述图像中的内容，包括人物、物体和事件。
    以 JSON 格式返回响应，包含以下字段："时间"（精确时间、星期几、上午/下午/晚上）、
    "地点"（位置）、"场景"（场景类型）、"人物"（包含描述的人物列表）、
    "物体"（包含描述的物体列表）、"环境"（天气等）、
    "活动"（包含描述的活动列表）、"情绪"（带有推理的情绪）
    """


def generate_llm_dialog(image_path, metadata):
    """
    该函数用于将图像和元数据发送给大语言模型（LLM），并处理模型的响应。

    :param image_path: 图像文件的路径
    :param metadata: 从图像中提取的元数据
    :return: 大语言模型生成的 JSON 格式响应
    """
    try:
        # 创建 OpenAI 客户端实例，使用自定义的 base_url 和 API 密钥
        client = OpenAI(base_url="https://api.stepfun.com/v1", api_key='3MFOSXFhX8cuMahAJVKnnR9dh31NsKMqecGTX7zX6hnTfYX03bT0fJT9DqMNshBqu')
        # 调用 encode_image 函数将图像文件编码为 Base64 字符串
        image_base64 = encode_image(image_path)
        # 将元数据字典转换为 JSON 字符串，确保非 ASCII 字符能正确显示
        metadata_json = json.dumps(metadata, ensure_ascii=False)
        # 调用 OpenAI 的聊天完成接口，向大语言模型发送请求
        response = client.chat.completions.create(
            model="step-1o-vision-32k",
            messages=[
                {"role": "system", "content": get_system_instruction()},
                {
                    "role": "user",
                    "content": [
                        # 发送 Base64 编码的图像数据
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_base64}"
                            },
                        },
                        # 发送元数据的 JSON 字符串
                        {"type": "text", "text": f"Metadata: {metadata_json}"},
                    ],
                },
            ],
            # 设置最大生成的令牌数为 400
            max_tokens=400,
        )
        # 提取模型响应的内容，并去除首尾的空白字符
        raw_response = response.choices[0].message.content.strip()
        # 打印模型的原始响应
        print("LLM raw response:", raw_response)

        # 初始化处理后的 JSON 内容
        json_content = raw_response
        # 检查响应是否以 ```json 开头且以 ``` 结尾
        if json_content.startswith("```json") and json_content.endswith("```"):
            # 去除 Markdown 代码块标记，提取 JSON 内容
            json_content = json_content[7:-3].strip()
        # 检查响应是否以 ``` 开头且以 ``` 结尾
        elif json_content.startswith("```") and json_content.endswith("```"):
            # 去除 Markdown 代码块标记，提取 JSON 内容
            json_content = json_content[3:-3].strip()

        # 将处理后的 JSON 内容解析为 Python 字典并返回
        return json.loads(json_content)
    except json.JSONDecodeError as e:
        # 若解析 JSON 响应时出错，打印错误信息
        print(f"Failed to parse LLM response as JSON: {str(e)}")
        # 返回包含错误信息和原始响应的字典
        return {"error": "Invalid JSON response", "raw_response": raw_response}
    except Exception as e:
        # 若发生其他异常，打印错误信息
        print(f"Error in generate_llm_dialog: {str(e)}")
        # 重新抛出异常
        raise


def analyze_image(image_path):
    try:
        metadata = extract_metadata(image_path)
        print("Metadata extraction completed:", metadata)
        dialog_json = generate_llm_dialog(image_path, metadata)
        print("LLM dialog generated:", dialog_json)
        return dialog_json
    except Exception as e:
        print(f"Detailed error: {str(e)}")
        return {"error": f"Error analyzing image: {str(e)}"}

