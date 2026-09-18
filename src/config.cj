package changxi_backend

import std.env.*

// 所有密钥只从环境变量来；读不到就立刻失败，绝不给默认值
public func mustGetEnv(key: String): String {
    let value = match (getVariable(key)) {
        case Some(s) => s
        case None => ""
    }
    if (value.isEmpty()) {
        throw Exception("缺少环境变量 ${key}，请设置后重开终端")
    }
    return value
}

// 数据库连接、JWT 密钥等，等接口文档确认后在这里补：
// createDataSource() / jwtValidationParameters() / issueToken()
