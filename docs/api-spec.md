# 畅溪鸿蒙APP 接口文档

> 待粘贴：把完整接口文档替换到本文件下方。
> 建议按域组织：认证域、各业务域，每个接口包含路径、方法、请求体、响应示例、错误码。

<!-- 接口文档内容从这里开始 -->
1. 注册接口 POST /api/v1/auth/register
* 手机号验证请求体
```
{
  "number": "string",
  "code": "string",
  "password": "string"
}
```
* 响应体
```
{
  "code":number,
  "message":string,
  "data":string // 成功返回 token，失败统一返回 null
}
```
2. 获取验证码接口 POST /api/v1/auth/send-code
* 请求体
```
{
  "number": "string",
  "purpose": "string" // "register" 注册 / "reset_password" 找回密码
}
```
   * 响应体

   {
  "code":number,
  "message":string,
  "data":null // 验证码不通过接口返回，仅通过短信发送
}
3. 登录接口 POST /api/v1/auth/login
   * 请求体

   {
   "number":string,
   "password":string
}
   * 响应体

   {
  "code":number,
  "message":string,
  "data":string // 成功返回token，失败统一返回 null
}
4. 登出接口 POST /api/v1/auth/logout
   * 请求体

   {
  "number":string
}
   * 响应体

   {
  "code":number,
  "message":string,
  "data":string // 失败统一返回 null
}
5. 聊天接口 POST /api/v1/chat
   * 请求体

   // Authorization: Bearer <登录拿到的 token>
{
  "message":string,
  "conversationId": string, // 首轮传 ""，续聊传上一轮返回的 conversationId
  "stream":boolean, // 流式输出
  "mode":string // agent工作流模式选择
}
   * 响应体

   {
  "type":string,
  "conversationId":string,
  "content":string
}

/*
举例
data: {"type": "message", "content": "急救"} // message 正在推送中间内容
data: {"type": "message", "content": "的第一步是"}
data: {"type": "end", "conversationId":"11111", "content": ""} // end 推送结束
data: {"type": "error", "content": "出错了"} // error 中途出错了
*/
6. 大模型接口 POST /v1/chat-messages
   * 请求体

   Authorization: Bearer <你的Dify API Key>
{
  "inputs": {},
  "query": "用户发的消息内容",
  "response_mode": "streaming",
  "conversation_id": "",
  "user": "user123"
}
   * 响应体

原始 dify 输出格式转成聊天接口的响应体即可输出
