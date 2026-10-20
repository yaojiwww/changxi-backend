// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.sort.*
import std.collection.*
import soulsoft_web_http.*
import soulsoft_web_routing.http.*

let ANY_HTTP_METHOD = "*"

protected class HttpMethodMatcherPolicy <: INodeBuilderPolicy & IEndpointComparerPolicy {
    /*
    评估该策略是否适用于给定的端点列表
     */
    public func appliesToEndpoints(endpoints: ReadOnlyList<Endpoint>): Bool {
        for (index in 0..endpoints.size) {
            let endpoint = endpoints[index]
            if (endpoint.metadata.getMetadata<IHttpMethodMetadata>().flatMap {f => f.httpMethods.size > 0} == true) {
                return true
            }
        }
        return false
    }

    /*
    生成分支。
    两遍扫描：第一遍枚举所有边，第二遍将端点分配到对应边。
    对 acceptCorsPreflight=true 的端点，每个方法生成两条边：
      EdgeState(method, isCors=true)  — CORS 预检请求路径
      EdgeState(method, isCors=false) — 普通请求路径
     */
    public func getEdges(endpoints: ReadOnlyList<Endpoint>): ReadOnlyList<PolicyNodeEdge> {
        let allHttpMethods = ArrayList<String>()
        let edges = HashMap<EdgeState, ArrayList<Endpoint>>()

        // 第一遍：枚举所有可能的 (方法 × CORS) 边组合
        for (index in 0..endpoints.size) {
            let endpoint = endpoints[index]
            let (httpMethods, acceptCorsPreflight) = getHttpMethods(endpoint)

            // 若端点未指定方法，用哨兵值 * 表示"接受所有方法"
            let effectiveMethods = if (httpMethods.size == 0) {
                [ANY_HTTP_METHOD]
            } else {
                httpMethods
            }

            for (i in 0..effectiveMethods.size) {
                let httpMethod = effectiveMethods[i]
                let key = EdgeState(httpMethod, acceptCorsPreflight)
                if (!edges.contains(key)) {
                    edges.add(key, ArrayList<Endpoint>())
                }
                // acceptCorsPreflight=true 的端点同时参与普通请求分支
                if (acceptCorsPreflight) {
                    let nonCorsKey = EdgeState(httpMethod, false)
                    if (!edges.contains(nonCorsKey)) {
                        edges.add(nonCorsKey, ArrayList<Endpoint>())
                    }
                }
                if (!httpMethod.equalsIgnoreAsciiCase(ANY_HTTP_METHOD) && !containsHttpMethod(allHttpMethods, httpMethod)) {
                    allHttpMethods.add(httpMethod)
                }
            }
        }

        sort(allHttpMethods)

        // 第二遍：将端点分配到对应的边
        for (index in 0..endpoints.size) {
            let endpoint = endpoints[index]
            let (httpMethods, acceptCorsPreflight) = getHttpMethods(endpoint)

            if (httpMethods.size == 0) {
                // 未指定方法：匹配所有边（若不接受 CORS 则排除 CORS 边）
                for ((key, list) in edges) {
                    if (acceptCorsPreflight || !key.isCorsPreflightRequest) {
                        list.add(endpoint)
                    }
                }
            } else {
                for (i in 0..httpMethods.size) {
                    let httpMethod = httpMethods[i]
                    edges[EdgeState(httpMethod, acceptCorsPreflight)].add(endpoint)
                    // acceptCorsPreflight=true 的端点同时加入普通请求分支
                    if (acceptCorsPreflight) {
                        edges[EdgeState(httpMethod, false)].add(endpoint)
                    }
                }
            }
        }

        // 添加 405 默认拒绝分支（仅针对普通请求，不针对 CORS 预检）
        let anyEdgeState = EdgeState(ANY_HTTP_METHOD, false)
        if (!edges.contains(anyEdgeState)) {
            let endpoint = createRejectionEndpoint(allHttpMethods)
            edges[anyEdgeState] = ArrayList<Endpoint>([endpoint])
        }

        let policyNodeEdges = ArrayList<PolicyNodeEdge>(edges.size)
        for ((key, value) in edges) {
            policyNodeEdges.add(PolicyNodeEdge(key, value))
        }
        return policyNodeEdges
    }

    /*
    构建跳转表。
    将边按 CORS 维度拆分为两张查找表，分别处理普通请求和 CORS 预检请求。
     */
    public func buildJumpTable(exitDestination: Int64, policyEntries: ReadOnlyList<PolicyJumpTableEdge>): PolicyJumpTable {
        var destinations: ?HashMap<String, Int64> = None
        var corsPreflightDestinations: ?HashMap<String, Int64> = None
        var corsPreflightExitDestination = exitDestination
        var normalExitDestination = exitDestination

        for (entry in policyEntries) {
            let state = (entry.state as EdgeState).getOrThrow()
            let destination = entry.destination
            // key 统一存小写，与 getDestination 查询保持一致
            let httpMethodKey = state.httpMethod.toAsciiLower()

            if (state.isCorsPreflightRequest) {
                if (httpMethodKey.equalsIgnoreAsciiCase(ANY_HTTP_METHOD)) {
                    corsPreflightExitDestination = destination
                } else {
                    let corsMap = corsPreflightDestinations ?? HashMap<String, Int64>()
                    corsMap[httpMethodKey] = destination
                    corsPreflightDestinations = corsMap
                }
            } else {
                if (httpMethodKey.equalsIgnoreAsciiCase(ANY_HTTP_METHOD)) {
                    normalExitDestination = destination
                } else {
                    let destMap = destinations ?? HashMap<String, Int64>()
                    destMap[httpMethodKey] = destination
                    destinations = destMap
                }
            }
        }

        // 只有 1 个 HTTP 方法时使用优化的单条目跳转表，避免 HttpMethodDestinationsLookup 查找开销
        if (let Some(destMap) <- destinations) {
            if (destMap.size == 1) {
                var singleMethod = ""
                var singleDest: Int64 = 0
                for ((m, d) in destMap) {
                    singleMethod = m
                    singleDest = d
                }

                var supportsCorsPreflight = false
                var corsPreflightDest: Int64 = 0
                if (let Some(corsMap) <- corsPreflightDestinations) {
                    if (corsMap.size > 0) {
                        supportsCorsPreflight = true
                        for ((_, d) in corsMap) {
                            corsPreflightDest = d
                            break
                        }
                    }
                }

                return HttpMethodSingleEntryPolicyJumpTable(
                    normalExitDestination,
                    singleMethod,
                    singleDest,
                    supportsCorsPreflight,
                    corsPreflightExitDestination,
                    corsPreflightDest
                )
            }
        }

        let corsTable: ?HttpMethodDestinationsLookup = if (let Some(corsMap) <- corsPreflightDestinations) {
            HttpMethodDestinationsLookup(corsMap, corsPreflightExitDestination)
        } else {
            None
        }

        return HttpMethodDictionaryPolicyJumpTable(
            HttpMethodDestinationsLookup(destinations ?? HashMap<String, Int64>(), normalExitDestination),
            corsTable
        )
    }

    /*
    返回端点的 HTTP 方法列表和 acceptCorsPreflight 标志。
    无 IHttpMethodMetadata 时返回空列表，由调用方决定如何处理。
     */
    private static func getHttpMethods(endpoint: Endpoint): (Array<String>, Bool) {
        if (let Some(m) <- endpoint.metadata.getMetadata<IHttpMethodMetadata>()) {
            return (m.httpMethods.toArray(), m.acceptCorsPreflight)
        }
        return ([], false)
    }

    /*
    大小写不敏感地检查列表中是否已包含指定方法。
     */
    private static func containsHttpMethod(httpMethods: ArrayList<String>, httpMethod: String): Bool {
        for (i in 0..httpMethods.size) {
            if (HttpMethods.equals(httpMethods[i], httpMethod)) {
                return true
            }
        }
        return false
    }

    private static func createRejectionEndpoint(allHttpMethods: Collection<String>): RejectionEndpoint {
        let allow = String.join(allHttpMethods |> collectArray, delimiter: ", ")
        return RejectionEndpoint {
            context =>
                context.response.headers.add(HeaderNames.Allow, allow)
                context.response.statusCode = StatusCodes.MethodNotAllowed
        }
    }

    /*
    IEndpointComparerPolicy：返回 HTTP 方法元数据比较器单例。
     */
    public prop comparer: IEndpointComparer {
        get() {
            HttpMethodMetadataEndpointComparer.instance
        }
    }

    /*
    判断请求是否为 CORS 预检请求，若是则返回 Access-Control-Request-Method 的值。
    条件：OPTIONS 方法 + Origin 头 + 非空 Access-Control-Request-Method 头。
     */
    internal static func isCorsPreflightRequest(context: HttpContext, httpMethod: String): ?String {
        if (!HttpMethods.isOptions(httpMethod)) {
            return None
        }
        let headers = context.request.headers
        if (!headers.contains(HeaderNames.Origin) || !headers.contains(HeaderNames.AccessControlRequestMethod)) {
            return None
        }
        let values = headers[HeaderNames.AccessControlRequestMethod]
        if (values.size == 0) {
            return None
        }
        let method = values[0].trimAscii()
        return if (method.isEmpty()) {
            None
        } else {
            method
        }
    }
}

private class RejectionEndpoint <: Endpoint {
    init(delegate: RequestDelegate) {
        super(delegate, EndpointMetadataCollection.empty, "405 HTTP Method Not Supported")
    }
}

/*
EdgeState 对应 C# 中的 EdgeKey，包含 HTTP 方法和 CORS 预检两个维度。
 */
private struct EdgeState <: IEdgeState & Equatable<EdgeState> {
    EdgeState(let httpMethod: String, let isCorsPreflightRequest: Bool) {
    }

    public operator func ==(that: EdgeState) {
        return this.isCorsPreflightRequest == that.isCorsPreflightRequest && HttpMethods.equals(this.httpMethod,
            that.httpMethod)
    }

    public operator func ==(that: IEdgeState) {
        if (let that: EdgeState <- that) {
            return this == that
        } else {
            return false
        }
    }

    public func hashCode() {
        var hasher = DefaultHasher()
        if (isCorsPreflightRequest) {
            hasher.write(1)
        } else {
            hasher.write(0)
        }
        hasher.write(httpMethod)
        return hasher.finish()
    }

    public func toString() {
        return if (isCorsPreflightRequest) {
            "CORS: ${httpMethod}"
        } else {
            "HTTP: ${httpMethod}"
        }
    }
}
