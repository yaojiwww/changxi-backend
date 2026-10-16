package changxi_backend

import std.time.*

// =============================================================================
// 服务端终端日志
//
// 为什么不用 println？—— 踩过坑：
// 容器里 stdout 是**块缓冲**的（攒够 4KB 才真正吐出去），println 写完就留在缓冲区里。
// 后果是启动横幅能看到（后面陆续攒够了），但请求期间打的日志（异常堆栈、验证码）
// 会**看起来完全没输出**，得再刷几十个请求把缓冲撑满才一起冒出来。
// 开发阶段最需要实时看日志（比如"验证码是什么"），所以这里必须带 flush。
// =============================================================================

public func serverLog(message: String): Unit {
    // print(..., flush: true) 是 std.console 提供的立即刷新重载；println 没有这个参数
    print("[${DateTime.nowUTC().toString()}] ${message}\n", flush: true)
}
