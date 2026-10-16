package changxi_backend

import std.database.sql.*
import mariadb.cdbc.*

// =============================================================================
// 数据库入口
//
// 这里用的是仓颉官方的 std.database.sql 接口（JDBC 风格）+ mariadb 原生驱动，
// 不是 ORM。所以「SQL 得自己写，结果得自己映射」——全部集中在 repositories.cj 里。
//
// 连接池由驱动内部管理（driver.open 拿到的是池化数据源），所以每次请求
// connect() 一下、用完 close() 就行：close 是把连接还回池子，不是真的断开。
// =============================================================================

public class Database {
    private let dataSource: Datasource

    public init(config: DatabaseConfig) {
        // "mariadb" 是驱动注册的名字；驱动没注册会返回 None，getOrThrow 立刻炸，
        // 比留到第一次查询才报错好定位。
        let driver = DriverManager.getDriver("mariadb").getOrThrow()
        // 连接串里只放地址，账号密码库名作为独立参数传（这样也不会出现在日志里）
        this.dataSource = driver.open(
            config.serverUrl(),
            [
                ("username", config.user),
                ("password", config.password),
                ("database", config.name),
                ("connection_timeout", config.connectionTimeoutMs.toString()),
                ("pool.max.size", config.poolMaxSize.toString())
            ]
        )
    }

    // 借一条连接。调用方负责在 finally 里 close()
    public func connection(): Connection {
        return dataSource.connect()
    }

    // 启动时探活：数据库不通的话，让问题在启动日志里就暴露出来，
    // 而不是等前端点登录时收到一个 500 再回头查。
    public func ping(): Unit {
        let connection = dataSource.connect()
        try {
            let statement = connection.prepareStatement("select 1")
            let result = statement.query()
            result.next()
            result.close()
            statement.close()
        } finally {
            connection.close()
        }
    }

    // 查一个数（select count(*) 之类），失败返回 -1
    public func scalarInt64(sql: String): Int64 {
        let connection = dataSource.connect()
        try {
            let statement = connection.prepareStatement(sql)
            let result = statement.query()
            let value = if (result.next()) { result.get<Int64>(1) } else { -1 }
            result.close()
            statement.close()
            return value
        } finally {
            connection.close()
        }
    }
}
