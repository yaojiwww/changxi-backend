package changxi_backend

// 全局业务码表
//
// 整个后端共用一套编号：客户端只看 code 就能判断错误类型，不必结合请求的 URL。
// 这正是"全局统一"相对"每接口独立编号"的价值所在 —— 拦截器里一个 switch
// 就能处理"token 失效跳登录"之类的全站性分支。
//
// 分段规则（新增业务域时往后顺延段号，不要复用退休的码）：
//   0       成功
//   1xxx    客户端错误 / 认证域
//   2xxx    鉴权（任何需要登录的接口共用，不限认证域）
//   5xxx    服务端错误

// 成功。writeOk 内部也用它，保持单一来源
public const CODE_OK: Int64 = 0

// ---------- 1xxx 客户端错误 / 认证域 ----------

// 参数为空或格式错误：所有接口共用
public const CODE_PARAM_INVALID: Int64 = 1001

// 手机号未注册（登录时不存在；找回密码时也不存在）
public const CODE_NUMBER_NOT_REGISTERED: Int64 = 1002

// 密码错误
public const CODE_PASSWORD_WRONG: Int64 = 1003

// 短信验证码错误
public const CODE_VERIFY_CODE_WRONG: Int64 = 1004

// 短信验证码已过期
public const CODE_VERIFY_CODE_EXPIRED: Int64 = 1005

// 验证码请求过于频繁
public const CODE_VERIFY_CODE_TOO_FREQUENT: Int64 = 1006

// ---------- 2xxx 鉴权 ----------

// token 无效或已过期：客户端收到它就清本地 token 并跳登录页
public const CODE_TOKEN_INVALID: Int64 = 2001
