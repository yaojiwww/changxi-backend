/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package test_server

import test_server.controllers.*
import soulsoft_web_mvc.*
import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_serialization.*
import soulsoft_extensions_options.*
import soulsoft_extensions_injection.*

// 模型绑定集成测试服务器，默认端口 15110
// 用法：
//   1. 启动服务器：cjpm run
//   2. 运行测试：  cd tests && pytest -v

private const DefaultPortBase: Int64 = 15110

func applyDefaultPort(builder: WebHostBuilder, port: Int64): Unit {
    if (builder.configuration["urls"].isNone() && builder.configuration["HTTP_PORTS"].isNone()) {
        builder.configuration["HTTP_PORTS"] = port.toString()
    }
}

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    applyDefaultPort(builder, DefaultPortBase)
    builder.services.addControllers("test_server.controllers")

    let host = builder.build()
    host.useRouting()
    host.mapControllers()
    host.run()
    return 0
}
