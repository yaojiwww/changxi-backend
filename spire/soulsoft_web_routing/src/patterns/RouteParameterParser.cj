// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.patterns

import std.collection.*

/**
 * @brief 提供路由参数片段的解析工具。
 */
public class RouteParameterParser {
    /**
     * @brief 解析单个路由参数表达式。
     * @param parameter 去除花括号后的参数文本。
     * @return 解析后的路由参数片段。
     */
    public static func parseRouteParameter(parameter: String): RoutePatternParameterPart {
        /**
         *   ParameterSegment = "{" ParameterName [":" Constraint]{0,n} ["=" DefaultValue] ["?"] "}"
         */
        if (parameter.size == 0) {
            return RoutePatternParameterPart(String.empty, None, RoutePatternParameterKind.Standard)
        }

        var startIndex = 0
        var endIndex = parameter.size - 1
        var encodeSlashes = true

        var parameterKind = RoutePatternParameterKind.Standard
        //计算参数的起始和结束索引
        if (parameter.size >= 2 && parameter[0..2] == '**') {
            encodeSlashes = false
            parameterKind = RoutePatternParameterKind.CatchAll
            startIndex += 2
        } else if (parameter[0] == b'*') {
            parameterKind = RoutePatternParameterKind.CatchAll
            startIndex++
        }

        if (parameter[endIndex] == b'?') {
            parameterKind = RoutePatternParameterKind.Optional
            endIndex--
        }

        var currentIndex = startIndex

        // Parse parameter name
        var parameterName = String.empty

        //计算出参数名
        while (currentIndex <= endIndex) {
            var current = parameter[currentIndex]

            //参数结束标志
            if ((current == b':' || current == b'=') && startIndex != currentIndex) {
                // Parameter names are allowed to start with delimiters used to denote constraints or default values.
                // i.e. "=foo" or ":bar" would be treated as parameter names rather than default value or constraint
                // specifications.
                parameterName = parameter[startIndex..currentIndex]

                // Roll the index back and move to the constraint parsing stage.
                currentIndex--
                break
            } else if (currentIndex == endIndex) {
                parameterName = parameter[startIndex..currentIndex + 1]
            }

            currentIndex++
        }

        //解析参数约束：{name:int:min(1)}
        var parseResults = parseConstraints(parameter, currentIndex, endIndex)
        currentIndex = parseResults.currentIndex

        var defaultValue: ?String = None
        if (currentIndex <= endIndex && parameter[currentIndex] == b'=') {
            defaultValue = parameter[currentIndex + 1..endIndex + 1]
        }
        return RoutePatternParameterPart(parameterName, defaultValue, parameterKind, parseResults.parameterPolicies,
            encodeSlashes)
    }

    /*
     *   解析参数约束
     */
    private static func parseConstraints(text: String, index: Int64, endIndex: Int64) {
        /*
         *   Constraint = SimpleConstraint | CompositeConstraint
         *    SimpleConstraint（基本约束） = "int" | "bool" | "datetime" | "decimal" | "guid" | "long" | "float" | "double" | "alpha" | RegexConstraint | LengthConstraint | RangeConstraint
         *    CompositeConstraint（复合约束） = SimpleConstraint (":" SimpleConstraint){0,n}
         *    RegexConstraint（正则约束） = "regex(" RegularExpression ")"
         *    LengthConstraint（长度约束） = ("length" | "minlength" | "maxlength") "(" Number ")"
         *    RangeConstraint（区间约束） = "range(" Number "," Number ")"
         */
        let constraints = ArrayList<RoutePatternParameterPolicyReference>(0)
        var state = ParseState.Start
        var startIndex = index
        var currentIndex = index

        do {
            let currentChar: ?Byte = if (currentIndex > endIndex) {
                None
            } else {
                text[currentIndex]
            }

            match (state) {
                case ParseState.Start =>
                    //处理开始状态
                    match (currentChar) {
                    case None => state = ParseState.End
                    case Some(current) =>
                        if (current == b':') {
                            state = ParseState.ParsingName
                            startIndex = currentIndex + 1
                        } else if (current == b'(') {
                            state = ParseState.InsideParenthesis
                        } else if (current == b'=') {
                            //默认值部分
                            state = ParseState.End
                            currentIndex--
                        }
                }
                //处理括号部分找到当前约束的闭合括号
                case ParseState.InsideParenthesis =>
                    //处理括号部分的参数
                    match (currentChar) {
                    case None =>
                        state = ParseState.End
                        var constraintText = text[startIndex..currentIndex]
                        //解析策略
                        constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                    case Some(current) =>
                        //结束括号匹配
                        if (current == b')') {
                            // 仅在以下情况下消耗 ')' 令牌：
                            // (a) 他是最后一个令牌，如：{name:length(7)}
                            // (b) 下一个字符是新约束的起始符号':'，如：{name:length(7):int}
                            // (c) 下一个字符是默认值的起始符号，如：{name:length(7)=cangjie}
                            let nextChar: ?Byte = if (currentIndex + 1 > endIndex) {
                                None
                            } else {
                                text[currentIndex + 1]
                            }

                            match (nextChar) {
                                case None =>
                                    //(a)已结束
                                    state = ParseState.End
                                    let constraintText = text[startIndex..currentIndex + 1]
                                    constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                                //闭合后遇到：'r'，'=    
                                case Some(nextChar) =>
                                    if (nextChar == b':') {
                                        //(b)解析下一个约束
                                        state = ParseState.Start
                                        let constraintText = text[startIndex..currentIndex + 1]
                                        constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                                        startIndex = currentIndex + 1
                                    } else if (nextChar == b'=') {
                                        //(c)默认开始，结束本次约束
                                        state = ParseState.End
                                        let constraintText = text[startIndex..currentIndex + 1]
                                        constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                                    }
                            }
                        } else if (current == b':' || current == b'=') { //未闭合时遇到：'r'，'=       
                            if (let Some(indexOfClosingParantheses) <- text.indexOf(')', currentIndex + 1)) {
                                //跳过当前符号，继续解析约束内容
                                currentIndex = indexOfClosingParantheses
                            } else {
                                //找不到闭合括号
                                let constraintText = text[startIndex..currentIndex] // 视为分隔符（非常规情况，可能是格式错误）
                                constraints.add(RoutePatternFactory.parameterPolicy(constraintText))

                                if (current == b':') {
                                    state = ParseState.ParsingName
                                    startIndex = currentIndex + 1
                                } else {
                                    state = ParseState.End
                                    currentIndex--
                                }
                            }
                        }
                }
                //解析约束名
                case ParseState.ParsingName => match (currentChar) {
                    case None =>
                        state = ParseState.End
                        var constraintText = text[startIndex..currentIndex]
                        if (constraintText.size > 0) {
                            constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                        }
                    case Some(current) =>
                        if (current == b':') {
                            let constraintText = text[startIndex..currentIndex]
                            if (constraintText.size > 0) {
                                constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                            }
                            startIndex = currentIndex + 1
                        } else if (current == b'(') {
                            state = ParseState.InsideParenthesis
                        } else if (current == b'=') {
                            state = ParseState.End
                            let constraintText = text[startIndex..currentIndex]
                            if (constraintText.size > 0) {
                                constraints.add(RoutePatternFactory.parameterPolicy(constraintText))
                            }
                            currentIndex--
                        }
                }
                case _ => break
            }

            currentIndex++
        } while (!state.isEnd())
        return ParameterPolicyParseResults(currentIndex, constraints.toArray())
    }
}

private enum ParseState {
    Start
    | ParsingName
    | InsideParenthesis
    | End

    public func isEnd() {
        match (this) {
            case End => true
            case _ => false
        }
    }
}

private struct ParameterPolicyParseResults {
    public ParameterPolicyParseResults(let currentIndex: Int64,
        let parameterPolicies: Array<RoutePatternParameterPolicyReference>) {
    }
}
