# import os
# import json

# def generate_files_json(input_dir, output_json_path):
#     """
#     根据输入目录生成包含所有文件名的JSON文件
#     :param input_dir: 输入目录路径（如 'assets/prompt_en'）
#     :param output_json_path: 输出JSON文件路径（如 'assets/files.json'）
#     """
#     # 获取目录下所有文件（含子目录）
#     file_names = []
#     for root, _, files in os.walk(input_dir):
#         for file in files:
#             file_names.append(file)
    
#     # 生成JSON内容
#     json_content = json.dumps(file_names, ensure_ascii=False, indent=4)
    
#     # 确保输出目录存在
#     output_dir = os.path.dirname(output_json_path)
#     if not os.path.exists(output_dir):
#         os.makedirs(output_dir)
    
#     # 写入JSON文件
#     with open(output_json_path, 'w', encoding='utf-8') as f:
#         f.write(json_content)
    
#     print(f"已生成文件列表：{output_json_path}")
#     print(f"内容示例：\n{json_content}")

# # 示例调用（直接指定路径）
# input_directory = r"D:\FlutterProjects\pros\ChatPro\assets\prompt_en"  # 如 'assets/prompt_en'
# output_json_file = r"D:\FlutterProjects\pros\ChatPro\assets\prompt_en\files.json"    # 如 'assets/files.json'
# generate_files_json(input_directory, output_json_file)


import requests
import base64

# 读取图片并转换为 base64
with open("./chats/我是奶龙/1.怀士堂.png", "rb") as image_file:
    image_base64 = base64.b64encode(image_file.read()).decode('utf-8')

# 将 base64 编码写入 txt 文件
with open("image_base64.txt", "w") as txt_file:
    txt_file.write(image_base64)

# 构造请求数据
data = {
    "image_base64": image_base64
}

# 发送请求
response = requests.post(
    "http://172.16.90.86:5000/analyze", 
    json=data,
    headers={"Content-Type": "application/json"}
)

# 打印结果
print(response.json())