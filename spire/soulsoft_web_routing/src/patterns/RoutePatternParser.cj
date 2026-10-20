// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import std.collection.*

class RoutePatternParser {
    static let Separator = b'/'
    static let OpenBrace = b'{'
    static let CloseBrace = b'}'
    static let QuestionMark = '?'
    static let PeriodString = "."
    static let InvalidParameterNameChars = ['/', '{', '}', '?', '*']

    public static func parse(pattern: String) {
        if (pattern.isEmpty()) {
            // 用于 mapGroup("/prefix").mapGet("", handler) 匹配分组根路径。
            return RoutePatternFactory.pattern(String.empty, ArrayList<RoutePatternPathSegment>(0))
        }
        var trimmedPattern = trimPrefix(pattern)

        var context = Context(trimmedPattern)
        var segments = ArrayList<RoutePatternPathSegment>()

        while (context.moveNext()) {
            var i = context.index

            if (context.current == Separator) {
                // If we get here is means that there's a consecutive '/' character.
                // Templates don't start with a '/' and parsing a segment consumes the separator.
                throw RoutePatternException(pattern,
                    "The route template separator character '/' cannot appear consecutively. It must be separated by either a parameter or a literal value.")
            }

            if (!parseSegment(context, segments)) {
                throw RoutePatternException(pattern, context.error)
            }

            if (context.index <= i) {
                // This shouldn't happen, but we want to crash if it does.
                var message = "Infinite loop detected in the parser. Please open an issue."
                throw UnsupportedException(message)
            }
        }

        if (isAllValid(context, segments)) {
            return RoutePatternFactory.pattern(pattern, segments)
        } else {
            throw RoutePatternException(pattern, context.error)
        }
    }

    /**解析'/'分割的段**/
    private static func parseSegment(context: Context, segments: ArrayList<RoutePatternPathSegment>): Bool {
        let parts = ArrayList<RoutePatternPart>()

        while (true) {
            let i = context.index

            if (context.current == OpenBrace) {
                if (!context.moveNext()) {
                    // 这是一个悬空的'{'，这是不允许的
                    context.error = "There is an incomplete parameter in the route template. Check that each '{' character has a matching '}' character."
                    return false
                }

                if (context.current == OpenBrace) {
                    // 这是一个字面量中的“转义”大括号，比如“{{foo”
                    context.back()
                    if (!parseLiteral(context, parts)) {
                        return false
                    }
                } else {
                    context.back()
                    //这是一个参数
                    if (!parseParameter(context, parts)) {
                        return false
                    }
                }
            } else {
                //字面量
                if (!parseLiteral(context, parts)) {
                    return false
                }
            }

            if (context.current == Separator || context.atEnd()) {
                // We've reached the end of the segment
                break
            }

            if (context.index <= i) {
                throw UnsupportedException("Infinite loop detected in the parser. Please open an issue.")
            }
        }

        if (isSegmentValid(context, parts)) {
            segments.add(RoutePatternPathSegment(parts))
            return true
        } else {
            return false
        }
    }

    /*解析路由参数*/
    private static func parseParameter(context: Context, parts: ArrayList<RoutePatternPart>) {
        context.mark()

        context.moveNext()

        while (true) {
            //处理'{{'转义
            if (context.current == OpenBrace) {
                if (context.moveNext()) {
                    //'{'出现了三次
                    if (context.current != OpenBrace) {
                        context.error = "In a route parameter, '{' and '}' must be escaped with '{{' and '}}'."
                        return false
                    }
                } else {
                    context.error = "There is an incomplete parameter in the route template. Check that each '{' character has a matching '}' character."
                    return false
                }
            } else if (context.current == CloseBrace) {
                if (!context.moveNext()) {
                    break
                }

                if (context.current == CloseBrace) {
                // 转义结束标志：'}}'
                } else {
                    // This is the end of the parameter
                    break
                }
            }

            if (!context.moveNext()) {
                context.error = "There is an incomplete parameter in the route template. Check that each '{' character has a matching '}' character."
                return false
            }
        }

        var text = context.capture()
        if (text == "{}") {
            context.error = "The route parameter name '' is invalid. Route parameter names must be non-empty and cannot contain these characters: '{{', '}}', '/'. The '?' character marks a parameter as optional, and can occur only at the end of the parameter. The '*' character marks a parameter as catch-all, and can occur only at the start of the parameter."
            return false
        }

        var inside = text[1..text.size - 1]
        var decoded = inside.replace("}}", "}").replace("{{", "{")

        var templatePart = RouteParameterParser.parseRouteParameter(decoded)

        // See #475 - this is here because InlineRouteParameterParser can't return errors
        if (decoded.startsWith('*') && decoded.endsWith('?')) {
            context.error = "A catch-all parameter cannot be marked optional."
            return false
        }

        if (templatePart.isOptional && templatePart.default.isSome()) {
            context.error = "An optional parameter cannot have default value."
            return false
        }

        var parameterName = templatePart.name
        if (isValidParameterName(context, parameterName)) {
            parts.add(templatePart)
            return true
        } else {
            return false
        }
    }

    private static func parseLiteral(context: Context, parts: ArrayList<RoutePatternPart>): Bool {
        context.mark()

        while (true) {
            if (context.current == Separator) {
                break
            } else if (context.current == OpenBrace) {
                if (!context.moveNext()) {
                    context.error = "There is an incomplete parameter in the route template. Check that each '{' character has a matching '}' character."
                    return false
                }

                if (context.current == OpenBrace) {
                } else {
                    context.back()
                    break
                }
            } else if (context.current == CloseBrace) {
                if (!context.moveNext()) {
                    context.error = "There is an incomplete parameter in the route template. Check that each '{' character has a matching '}' character."
                    return false
                }

                if (context.current == CloseBrace) {
                //This is an 'escaped' brace in a literal, like "{{foo" - keep going.
                } else {
                    context.error = "There is an incomplete parameter in the route template. Check that each '{' character has a matching '}' character."
                    return false
                }
            }

            if (!context.moveNext()) {
                break
            }
        }

        let encoded = context.capture()
        let decoded = encoded.replace("}}", "}").replace("{{", "{")

        if (isValidLiteral(context, decoded)) {
            parts.add(RoutePatternFactory.literalPart(decoded))
            return true
        }
        return false
    }

    private static func isAllValid(context: Context, segments: ArrayList<RoutePatternPathSegment>) {
        // A catch-all parameter must be the last part of the last segment
        for (i in 0..segments.size) {
            let segment = segments[i]
            for (j in 0..segment.parts.size) {
                let part = segment.parts[j]
                if (let parameter: RoutePatternParameterPart <- part && parameter.isCatchAll && (i != segments.size - 1 ||
                    j != segment.parts.size - 1)) {
                    context.error = "A catch-all parameter can only appear as the last segment of the route template."
                    return false
                }
            }
        }
        return true
    }

    /*
        检查是否为有效段
     */
    private static func isSegmentValid(context: Context, parts: ArrayList<RoutePatternPart>): Bool {
        // ==============================================
        // 规则1：如果段有多个部分，则不能包含catch-all参数
        // ==============================================
        for (index in 0..parts.size) {
            let part = parts[index]
            if ((let parameter: RoutePatternParameterPart <- part) && parameter.isCatchAll && parts.size > 1) {
                context.error = "A path segment that contains more than one section, such as a literal section or a parameter, cannot contain a catch-all parameter."
                return false
            }
        }

        // ==============================================
        // 规则2：可选参数必须位于段末尾，且前导字符有限制
        // ==============================================
        for (i in 0..parts.size) {
            let part = parts[i]
            /// 只检查可选参数的情况
            if ((let parameter: RoutePatternParameterPart <- part) && parameter.isOptional && parts.size > 1) {
                // 情况2.1：当前是段的最后一个部分
                if (i == parts.size - 1) {
                    var previousPart = parts[i - 1] //前一个部分

                    // 2.1.1 前导部分必须满足以下条件之一：
                    // - 是分隔符（如/）
                    // - 是字面量的点号（.）
                    if (!previousPart.isLiteral && !previousPart.isSeparator) {
                        // 错误示例：{a}{b?} 前导是参数
                        context.error = "In the segment '${RoutePatternPathSegment.debugger(parts)}', the optional parameter '${parameter.name}' is preceded by an invalid segment '${parts[i - 1].debuggerToString()}'. Only a period (.) can precede an optional parameter."
                        return false
                    } else if ((let literal: RoutePatternLiteralPart <- previousPart) && literal.content != PeriodString) {
                        // 错误示例：a{b?} 前导是普通字面量
                        context.error = "In the segment '${RoutePatternPathSegment.debugger(parts)}', the optional parameter '${parameter.name}' is preceded by an invalid segment '${parts[i - 1].debuggerToString()}'. Only a period (.) can precede an optional parameter."

                        return false
                    }
                    // 合法情况（如 {controller}.{id?}），将前导字面量强制转换为分隔符
                    if (let previousPart: RoutePatternLiteralPart <- previousPart) {
                        parts[i - 1] = RoutePatternFactory.separatorPart(previousPart.content)
                    }
                } else {
                    context.error = "An optional parameter must be at the end of the segment. In the segment '${RoutePatternPathSegment.debugger(parts)}', optional parameter '${parameter.name}' is followed by '${parts[i + 1].debuggerToString()}'."
                    return false
                }
            }
        }

        // ==============================================
        // 规则3：禁止连续参数（必须用字面量或分隔符隔开）
        // ==============================================
        var isLastSegmentParameter = false
        for (index in 0..parts.size) {
            let part = parts[index]
            if (part.isParameter && isLastSegmentParameter) {
                context.error = "A path segment cannot contain two consecutive parameters. They must be separated by a '/' or by a literal string."
                return false
            }

            isLastSegmentParameter = part.isParameter
        }

        return true
    }

    private static func isValidParameterName(context: Context, parameterName: String): Bool {
        if (parameterName.size == 0 || (InvalidParameterNameChars |> any {f => parameterName.contains(f)})) {
            context.error = "The route parameter name '${parameterName}' is invalid. Route parameter names must be non-empty and cannot contain these characters: '{{', '}}', '/'. The '?' character marks a parameter as optional, and can occur only at the end of the parameter. The '*' character marks a parameter as catch-all, and can occur only at the start of the parameter."
            return false
        }

        if (!context.parameterNames.add(parameterName)) {
            context.error = "The route parameter name '${parameterName}' appears more than one time in the route template."
            return false
        }

        return true
    }

    private static func isValidLiteral(context: Context, literal: String): Bool {
        if (literal.contains(QuestionMark)) {
            context.error = "The literal section '${literal}' is invalid. Literal sections cannot contain the '?' character."
            return false
        }

        return true
    }

    private static func trimPrefix(routePattern: String) {
        if (routePattern.startsWith("~/")) {
            return routePattern[2..]
        } else if (routePattern.startsWith('/')) {
            return routePattern[1..]
        } else if (routePattern.startsWith('~')) {
            throw RoutePatternException(routePattern,
                "The route template cannot start with a '~' character unless followed by a '/'.")
        }

        return routePattern
    }
}

private class Context {
    private var _index: Int64
    private let _buffer: String
    private var _mark: ?Int64 = None
    private var _error: String = String.empty
    private let _parameterNames = HashSet<String>()

    init(buffer: String) {
        _index = -1
        _buffer = buffer
    }

    public prop index: Int64 {
        get() {
            _index
        }
    }

    public prop parameterNames: HashSet<String> {
        get() {
            _parameterNames
        }
    }

    public mut prop error: String {
        get() {
            _error
        }
        set(value) {
            _error = value
        }
    }

    public prop current: UInt8 {
        get() {
            if (_index < _buffer.size && _index >= 0) {
                return _buffer[_index]
            } else {
                return 0
            }
        }
    }

    public func back() {
        _index--
        return _index >= 0
    }

    public func atEnd() {
        return _index >= _buffer.size
    }

    public func moveNext() {
        _index++
        return _index < _buffer.size
    }

    public func mark() {
        _mark = _index
    }

    public func capture(): String {
        if (let Some(mark) <- _mark) {
            _mark = None
            return _buffer[mark.._index]
        }

        return String.empty
    }
}
