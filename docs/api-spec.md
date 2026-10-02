# 畅溪鸿蒙APP 接口文档

> 待粘贴：把完整接口文档替换到本文件下方。
> 建议按域组织：认证域、各业务域，每个接口包含路径、方法、请求体、响应示例、错误码。

<!-- 接口文档内容从这里开始 -->

## 业务码表

响应体里的 `code` 是**业务码**，全后端共用一套编号，与请求的 URL 无关。
APP 端只需看 `code` 即可判断错误类型（例如收到 `2001` 就清本地 token 并跳登录页）。

| code | 含义 | 备注 |
|---|---|---|
| 0    | 成功 | `message` 固定为 `ok` |
| 1001 | 参数为空或格式错误 | 所有接口共用 |
| 1002 | 手机号未注册 | |
| 1003 | 密码错误 | |
| 1004 | 短信验证码错误 | |
| 1005 | 短信验证码已过期 | |
| 1006 | 验证码请求过于频繁 | |
| 2001 | token 无效或已过期 | 任何需登录的接口都可能返回 |

> ⚠️ 注意区分两个 `code`：**请求体**里的 `code` 是短信验证码（字符串），
> **响应体**里的 `code` 是上表的业务码（数字），同名不同义。
>
> 约定：失败时 HTTP 状态码仍为 4xx，同时 `data` 固定为 `null`。

---

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
   * 错误码
     - 1001 手机号或 purpose 为空
     - 1002 手机号未注册（purpose 为 reset_password 时）

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
   * 错误码
     - 1001 手机号或密码为空
     - 1002 手机号未注册
     - 1003 密码错误

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
