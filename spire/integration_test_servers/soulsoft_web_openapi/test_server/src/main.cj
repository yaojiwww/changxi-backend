package soulsoft_openapi_test_server

import soulsoft_web_mvc.*
import soulsoft_web_http.*
import soulsoft_web_routing.*
import soulsoft_web_hosting.*
import soulsoft_web_openapi.*
import soulsoft_web_openapi.models.*
import soulsoft_extensions_injection.*
import soulsoft_openapi_test_server.controllers.*

private const DefaultPortBase: Int64 = 15120

func applyDefaultPort(builder: WebHostBuilder, port: Int64): Unit {
    if (builder.configuration["urls"].isNone() && builder.configuration["HTTP_PORTS"].isNone()) {
        builder.configuration["HTTP_PORTS"] = port.toString()
    }
}

main(args: Array<String>): Int64 {
    let builder = WebHost.createBuilder(args)
    applyDefaultPort(builder, DefaultPortBase)

    builder.services.addControllers("soulsoft_openapi_test_server.controllers")

    builder.services.addOpenApi({
        opts =>
            opts.addDocumentTransformer({ document, _ =>
                if (let Some(paths) <- document.paths) {
                    let pathItem = OpenApiPathItem()
                    pathItem.unresolvedReference = true
                    pathItem.reference = Some(OpenApiReference(ReferenceType.Schema, "DataItem"))
                    paths["/openapi/path-ref-probe"] = pathItem
                }
            })
    })

    let app = builder.build()

    app.useRouting()
    app.useOpenApiUI()
    app.mapOpenApi()
    app.mapControllers()

    app.run()
    return 0
}
