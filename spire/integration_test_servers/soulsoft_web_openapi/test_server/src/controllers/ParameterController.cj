/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_openapi_test_server.controllers

import soulsoft_serialization.*
import soulsoft_serialization.macros.*
import soulsoft_web_mvc.*

// ═══════════════════════════════════════════════════════════════════════════════
// DTO 定义 - 用于 OpenAPI responses schema 生成
// ═══════════════════════════════════════════════════════════════════════════════

// Path 参数响应
@Serialization
public class PathParamResponse {
    private var _id: Int64 = 0
}

// 字符串 Path 参数响应
@Serialization
public class StringPathParamResponse {
    private var _name: String = ""
}

// 多 Path 参数响应
@Serialization
public class MultiPathParamResponse {
    private var _userId: Int64 = 0
    private var _orderId: Int64 = 0
}

// Query 参数响应
@Serialization
public class QueryParamResponse {
    private var _id: Int64 = 0
}

// 可选 Query 参数响应
@Serialization
public class OptionalQueryParamResponse {
    private var _id: ?Int64 = None
}

// 多 Query 参数响应
@Serialization
public class MultiQueryParamResponse {
    private var _name: String = ""
    private var _age: Int64 = 0
}

// Header 参数响应
@Serialization
public class HeaderParamResponse {
    private var _requestId: String = ""
}

// 多 Header 参数响应
@Serialization
public class MultiHeaderParamResponse {
    private var _clientId: String = ""
    private var _apiKey: String = ""
}

// 混合参数响应
@Serialization
public class MixedParamResponse {
    private var _userId: Int64 = 0
    private var _name: String = ""
    private var _token: String = ""
}

// ═══════════════════════════════════════════════════════════════════════════════
// 参数测试控制器
// 验证 OpenAPI parameters 定义：
// - path parameters (in: path, required: true)
// - query parameters (in: query)
// - header parameters (in: header)
// - multiple parameters combination
// 所有方法返回具体 DTO 类型，使 OpenAPI 能正确推断 responses schema
// ═══════════════════════════════════════════════════════════════════════════════

@Route["api/params"]
public class ParameterController <: Controller {

    // ═══════════════════════════════════════════════════════════════════════════
    // Path 参数测试
    // OpenAPI: parameters with in: path, required: true
    // ═══════════════════════════════════════════════════════════════════════════

    // GET /api/params/path/123
    // OpenAPI: { name: "id", in: "path", required: true, schema: { type: "integer", format: "int64" } }
    // Response: PathParamResponse
    @HttpGet["path/{id}"]
    public func pathParam(@FromRoute id: Int64): PathParamResponse {
        let resp = PathParamResponse()
        resp.id = id
        return resp
    }

    // GET /api/params/path-named/123
    // OpenAPI: { name: "type", in: "path", required: true, schema: { type: "integer", format: "int64" } }
    @HttpGet["path-named/{type}"]
    public func pathNamedParam(@FromRoute[name: "type"] value: Int64): PathParamResponse {
        let resp = PathParamResponse()
        resp.id = value
        return resp
    }

    // GET /api/params/path-string/hello
    // OpenAPI: { name: "name", in: "path", required: true, schema: { type: "string" } }
    // Response: StringPathParamResponse
    @HttpGet["path-string/{name}"]
    public func pathStringParam(@FromRoute name: String): StringPathParamResponse {
        let resp = StringPathParamResponse()
        resp.name = name
        return resp
    }

    // GET /api/params/multi-path/123/456
    // OpenAPI: multiple path parameters
    // Response: MultiPathParamResponse
    @HttpGet["multi-path/{userId}/{orderId}"]
    public func multiPathParam(@FromRoute userId: Int64, @FromRoute orderId: Int64): MultiPathParamResponse {
        let resp = MultiPathParamResponse()
        resp.userId = userId
        resp.orderId = orderId
        return resp
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Query 参数测试
    // OpenAPI: parameters with in: query
    // ═══════════════════════════════════════════════════════════════════════════

    // GET /api/params/query?id=123
    // OpenAPI: { name: "id", in: "query", schema: { type: "integer", format: "int64" } }
    // Response: QueryParamResponse
    @HttpGet["query"]
    public func queryParam(@FromQuery id: Int64): QueryParamResponse {
        let resp = QueryParamResponse()
        resp.id = id
        return resp
    }

    // GET /api/params/query-named?type=123
    // OpenAPI: { name: "type", in: "query", schema: { type: "integer", format: "int64" } }
    @HttpGet["query-named"]
    public func queryNamedParam(@FromQuery[name: "type"] value: Int64): QueryParamResponse {
        let resp = QueryParamResponse()
        resp.id = value
        return resp
    }

    // GET /api/params/multi-query?name=alice&age=30
    // OpenAPI: multiple query parameters
    // Response: MultiQueryParamResponse
    @HttpGet["multi-query"]
    public func multiQueryParam(@FromQuery name: String, @FromQuery age: Int64): MultiQueryParamResponse {
        let resp = MultiQueryParamResponse()
        resp.name = name
        resp.age = age
        return resp
    }

    // POST /api/params/form-named
    // OpenAPI: requestBody multipart/form-data schema property "type"
    @HttpPost["form-named"]
    public func formNamedParam(@FromForm[name: "type"] value: Int64): QueryParamResponse {
        let resp = QueryParamResponse()
        resp.id = value
        return resp
    }

    // GET /api/params/optional-query?id=123 或 GET /api/params/optional-query（id 缺省时为 None）
    // OpenAPI: query parameter with ?Int64 → required: false, nullable: true
    // Response: OptionalQueryParamResponse
    @HttpGet["optional-query"]
    public func optionalQueryParam(@FromQuery id: ?Int64): OptionalQueryParamResponse {
        let resp = OptionalQueryParamResponse()
        resp.id = id
        return resp
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Header 参数测试
    // OpenAPI: parameters with in: header
    // ═══════════════════════════════════════════════════════════════════════════

    // GET /api/params/header
    // Header: X-Request-ID: abc-123
    // OpenAPI: { name: "X-Request-ID", in: "header", schema: { type: "string" } }
    // 通过显式 @FromHeader[name: ...] 对齐 ASP.NET Core 的朴素行为。
    // Response: HeaderParamResponse
    @HttpGet["header"]
    public func headerParam(@FromHeader[name: "X-Request-ID"] headerXRequestId: String): HeaderParamResponse {
        let resp = HeaderParamResponse()
        resp.requestId = headerXRequestId
        return resp
    }

    // GET /api/params/multi-header
    // Headers: X-Client-ID: client-123, X-API-Key: key-456
    // OpenAPI: multiple header parameters
    // Response: MultiHeaderParamResponse
    @HttpGet["multi-header"]
    public func multiHeaderParam(
        @FromHeader[name: "X-Client-ID"] headerXClientId: String,
        @FromHeader[name: "X-API-Key"] headerXApiKey: String
    ): MultiHeaderParamResponse {
        let resp = MultiHeaderParamResponse()
        resp.clientId = headerXClientId
        resp.apiKey = headerXApiKey
        return resp
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 混合参数测试
    // OpenAPI: combination of path, query, and header parameters
    // ═══════════════════════════════════════════════════════════════════════════

    // GET /api/params/mixed/123?name=alice
    // Header: X-Token: token-xyz
    // OpenAPI: path + query + header parameters
    // Response: MixedParamResponse
    @HttpGet["mixed/{userId}"]
    public func mixedParams(
        @FromRoute userId: Int64,
        @FromQuery name: String,
        @FromHeader[name: "X-Token"] headerXToken: String
    ): MixedParamResponse {
        let resp = MixedParamResponse()
        resp.userId = userId
        resp.name = name
        resp.token = headerXToken
        return resp
    }
}
