# chat_pro

1.chat_controller中的receiveMessage方法待实现：

设置socket监听

如果接受到api返回的信息，那就调用sendMessage方法

需要注意的是返回的信息需要包含当前对话的标题！

2.chat page中的最后面发送信息的功能不完整：

缺少发送信息到服务器的功能

3.待实现：

连续对话功能

# 基本功能

1.首页显示所有的对话，并且能新建对话

2.进入某个对话，显示所有的消息

3.发送消息

# 页面层级：

main
-chat_list
--chat_page
---chat_page_msg

# 状态管理

## chat_controller

读取和存储聊天记录、发送和接收信息，以及后续的所有数据流动、处理、通知、变更功能。