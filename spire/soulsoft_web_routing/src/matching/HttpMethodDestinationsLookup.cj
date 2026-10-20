// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

import std.collection.*
import soulsoft_web_http.*

/*
HTTP 方法 → 目标节点索引的快速查找表
优化思路：将标准 HTTP 方法直接存为 Int64 字段，查找时用首字节位运算定位候选，
再经 HttpMethods 做一次大小写不敏感确认，完全跳过哈希计算与桶查找。
非标准方法（自定义方法，极少见）惰性存入 _extraDestinations。
 */
protected class HttpMethodDestinationsLookup {
    private let _exitDestination: Int64
    private let _connectDestination: Int64
    private let _deleteDestination: Int64
    private let _getDestination: Int64
    private let _headDestination: Int64
    private let _optionsDestination: Int64
    private let _patchDestination: Int64
    private let _postDestination: Int64
    private let _putDestination: Int64
    private let _queryDestination: Int64
    private let _traceDestination: Int64
    // 非标准方法，绝大多数情况为 None
    private let _extraDestinations: ?HashMap<String, Int64>

    public init(entries: HashMap<String, Int64>, exitDestination: Int64) {
        _exitDestination = exitDestination

        var connectDest: ?Int64 = None
        var deleteDest: ?Int64 = None
        var getDest: ?Int64 = None
        var headDest: ?Int64 = None
        var optionsDest: ?Int64 = None
        var patchDest: ?Int64 = None
        var postDest: ?Int64 = None
        var putDest: ?Int64 = None
        var queryDest: ?Int64 = None
        var traceDest: ?Int64 = None
        var extraDests: ?HashMap<String, Int64> = None

        // entries 中的 key 已在 buildJumpTable 中转为小写
        for ((method, destination) in entries) {
            var handled = false
            if (method.size >= 3) {
                let fb = method[0]
                if (fb == b'c' && HttpMethods.isConnect(method)) {
                    connectDest = destination
                    handled = true
                } else if (fb == b'd' && HttpMethods.isDelete(method)) {
                    deleteDest = destination
                    handled = true
                } else if (fb == b'g' && HttpMethods.isGet(method)) {
                    getDest = destination
                    handled = true
                } else if (fb == b'h' && HttpMethods.isHead(method)) {
                    headDest = destination
                    handled = true
                } else if (fb == b'o' && HttpMethods.isOptions(method)) {
                    optionsDest = destination
                    handled = true
                } else if (fb == b'p') {
                    if (HttpMethods.isPut(method)) {
                        putDest = destination
                        handled = true
                    } else if (HttpMethods.isPost(method)) {
                        postDest = destination
                        handled = true
                    } else if (HttpMethods.isPatch(method)) {
                        patchDest = destination
                        handled = true
                    }
                } else if (fb == b'q' && HttpMethods.isQuery(method)) {
                    queryDest = destination
                    handled = true
                } else if (fb == b't' && HttpMethods.isTrace(method)) {
                    traceDest = destination
                    handled = true
                }
            }
            if (!handled) {
                let extra = extraDests ?? HashMap<String, Int64>()
                extra[method] = destination
                extraDests = extra
            }
        }

        _connectDestination = connectDest ?? exitDestination
        _deleteDestination = deleteDest ?? exitDestination
        _getDestination = getDest ?? exitDestination
        _headDestination = headDest ?? exitDestination
        _optionsDestination = optionsDest ?? exitDestination
        _patchDestination = patchDest ?? exitDestination
        _postDestination = postDest ?? exitDestination
        _putDestination = putDest ?? exitDestination
        _queryDestination = queryDest ?? exitDestination
        _traceDestination = traceDest ?? exitDestination
        _extraDestinations = extraDests
    }

    public func getDestination(httpMethod: String): Int64 {
        if (httpMethod.size >= 3) {
            // 首字节 | b' '（0x20）：将 ASCII 大写转小写，一次位运算，无内存分配
            let fb = httpMethod[0] | b' '
            if (fb == b'g') {
                if (HttpMethods.isGet(httpMethod)) {
                    return _getDestination
                }
            } else if (fb == b'p') { // PUT(3)/POST(4)/PATCH(5)，长度消歧
                if (httpMethod.size == 3 && HttpMethods.isPut(httpMethod)) {
                    return _putDestination
                } else if (httpMethod.size == 4 && HttpMethods.isPost(httpMethod)) {
                    return _postDestination
                } else if (HttpMethods.isPatch(httpMethod)) {
                    return _patchDestination
                }
            } else if (fb == b'd') {
                if (HttpMethods.isDelete(httpMethod)) {
                    return _deleteDestination
                }
            } else if (fb == b'h') {
                if (HttpMethods.isHead(httpMethod)) {
                    return _headDestination
                }
            } else if (fb == b'o') {
                if (HttpMethods.isOptions(httpMethod)) {
                    return _optionsDestination
                }
            } else if (fb == b'q') {
                if (HttpMethods.isQuery(httpMethod)) {
                    return _queryDestination
                }
            } else if (fb == b't') {
                if (HttpMethods.isTrace(httpMethod)) {
                    return _traceDestination
                }
            } else if (fb == b'c') {
                if (HttpMethods.isConnect(httpMethod)) {
                    return _connectDestination
                }
            }
        }

        // 非标准方法走字典（极少触发）
        if (let Some(extra) <- _extraDestinations) {
            if (let Some(destination) <- extra.get(httpMethod.toAsciiLower())) {
                return destination
            }
        }

        return _exitDestination
    }
}
