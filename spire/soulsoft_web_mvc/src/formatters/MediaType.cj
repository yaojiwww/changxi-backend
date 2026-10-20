// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_mvc.formatters

import std.convert.*
import std.unicode.*
import std.collection.*

private let EmptyParameters = HashMap<String, String>()

/**
 * @brief 表示一个已解析的媒体类型。
 */
public struct MediaType {
    private var _value: String
    private var _type: String
    private var _subType: String
    private var _subTypeWithoutSuffix: String
    private var _subTypeSuffix: String
    private var _parameters = HashMap<String, String>()

    /**
     * @brief 创建空的媒体类型实例。
     */
    public init() {
        this(String.empty, EmptyParameters)
    }

    init(value: String, `type`!: String = String.empty, subType!: String = String.empty,
        subTypeWithoutSuffix!: String = String.empty, subTypeSuffix!: String = String.empty) {
        _value = value
        _type = `type`
        _subType = subType
        _subTypeWithoutSuffix = subTypeWithoutSuffix
        _subTypeSuffix = subTypeSuffix
        _parameters = HashMap<String, String>()
    }

    init(value: String, parameters: HashMap<String, String>, `type`!: String = String.empty,
        subtype!: String = String.empty, subTypeWithoutSuffix!: String = String.empty,
        subTypeSuffix!: String = String.empty) {
        _value = value
        _type = `type`
        _subType = subtype
        _subTypeWithoutSuffix = subTypeWithoutSuffix
        _subTypeSuffix = subTypeSuffix
        _parameters = parameters
    }

    /**
     * @brief 返回原始媒体类型字符串。
     * @return 媒体类型的原始文本。
     */
    public prop value: String {
        get() {
            _value
        }
    }

    /**
     * @brief 返回主类型名称。
     * @return 媒体类型的主类型部分。
     */
    public prop `type`: String {
        get() {
            return _type
        }
    }

    /**
     * @brief 检查主类型是否为通配符。
     * @return 如果主类型为 `*` 则返回 `true`。
     */
    public prop matchesAllTypes: Bool {
        get() {
            `type`.equalsIgnoreAsciiCase('*')
        }
    }

    /**
     * @brief 返回子类型名称。
     * @return 媒体类型的子类型部分。
     */
    public prop subType: String {
        get() {
            return _subType
        }
    }

    /**
     * @brief 检查子类型是否为通配符。
     * @return 如果子类型为 `*` 则返回 `true`。
     */
    public prop matchesAllSubTypes: Bool {
        get() {
            subType.equalsIgnoreAsciiCase('*')
        }
    }

    /**
     * @brief 检查去除后缀后的子类型是否为通配符。
     * @return 如果去除后缀后的子类型为 `*` 则返回 `true`。
     */
    public prop matchesAllSubTypesWithoutSuffix: Bool {
        get() {
            subTypeWithoutSuffix.equalsIgnoreAsciiCase('*')
        }
    }

    /**
     * @brief 检查当前媒体类型是否包含通配符。
     * @return 如果主类型、子类型或参数中包含通配符则返回 `true`。
     */
    public prop hasWildcard: Bool {
        get() {
            matchesAllSubTypes || matchesAllSubTypesWithoutSuffix ||
                getParameter('*').flatMap {f => f.equalsIgnoreAsciiCase('*')} == true
        }
    }

    /**
     * @brief 返回子类型后缀。
     * @return 子类型中的后缀部分。
     */
    public prop subTypeSuffix: String {
        get() {
            return _subTypeSuffix
        }
    }

    /**
     * @brief 返回去除后缀后的子类型。
     * @return 子类型去除后缀后的部分。
     */
    public prop subTypeWithoutSuffix: String {
        get() {
            return _subTypeWithoutSuffix
        }
    }

    /**
     * @brief 返回 charset 参数值。
     * @return 如果存在 charset 参数则返回其值，否则返回空字符串。
     */
    public prop charset: String {
        get() {
            if (let Some(value) <- getParameter("charset")) {
                return value
            }
            return String.empty
        }
    }

    /**
     * @brief 返回 q 质量因子。
     * @return 如果存在 q 参数则返回其值，否则返回 `1.0`。
     */
    public prop quality: Float64 {
        get() {
            if (let Some(value) <- getParameter("q").flatMap {f => Float64.tryParse(f)}) {
                return value
            }
            return 1.0
        }
    }

    /**
     * @brief 返回 boundary 参数值。
     * @return 如果存在 boundary 参数则返回其值，否则返回空字符串。
     */
    public prop boundary: String {
        get() {
            if (let Some(value) <- getParameter("boundary")) {
                return value
            }
            return String.empty
        }
    }

    /**
     * @brief 按名称获取参数值。
     * @param name 要查找的参数名称。
     * @return 对应的参数值；如果不存在则返回 `None`。
     */
    public func getParameter(name: String): ?String {
        _parameters.get(name)
    }

    /**
     * @brief 检查当前媒体类型是否是指定媒体类型的子集。
     * @param superType 用于比较的媒体类型。
     * @return 如果当前媒体类型满足指定媒体类型约束则返回 `true`。
     */
    public func isSubsetOf(superType: MediaType): Bool {
        return matchesType(superType) && matchesSubtype(superType) && containsAllParameters(superType)
    }

    /**
     * @brief 解析媒体类型字符串。
     * @param input 要解析的媒体类型文本。
     * @return 解析得到的媒体类型实例。
     */
    public static func parse(input: String): MediaType {
        if (input.isEmpty()) {
            return MediaType(input)
        }
        let `type` = if (let Some(index) <- input.indexOf('/')) {
            input[0..index]
        } else {
            input
        }
        let subType = parseSubtype(input, `type`.size + 1)
        let (subTypeWithoutSuffix, subTypeSuffix) = if (subType.size > 0 && let Some(index) <- subType.indexOf('+')) {
            let subTypeWithoutSuffix = subType.slice(0, index)
            let subTypeSuffix = subType[index + 1..]
            (subTypeWithoutSuffix, subTypeSuffix)
        } else {
            (String.empty, String.empty)
        }
        let parametersPartIndex = `type`.size + subType.size + 1
        let parameters = if (input.size > parametersPartIndex) {
            let parametersPart = input[parametersPartIndex..]
            if (parametersPart.indexOf('=').isSome()) {
                MediaTypeParameterParser.parse(parametersPart)
            } else {
                EmptyParameters
            }
        } else {
            EmptyParameters
        }
        return MediaType(input, parameters, `type`: `type`, subtype: subType, subTypeWithoutSuffix: subTypeWithoutSuffix,
            subTypeSuffix: subTypeSuffix)
    }

    private static func parseSubtype(input: String, offset: Int64) {
        if (let Some(index) <- input.indexOf(';', offset)) {
            let length = index - offset
            return input.slice(offset, length)
        }
        if (input.size > offset) {
            return input[offset..]
        }
        return String.empty
    }

    private func matchesType(superType: MediaType) {
        return superType.matchesAllTypes || superType.`type`.equalsIgnoreAsciiCase(this.`type`)
    }

    private func matchesSubtype(superType: MediaType) {
        if (superType.matchesAllSubTypes) {
            return true
        }

        if (!superType.subTypeSuffix.isEmpty()) {
            if (!this.subTypeSuffix.isEmpty()) {
                return matchesSubtypeWithoutSuffix(superType) || matchesSubtypeSuffix(superType)
            } else {
                return false
            }
        } else {
            return matchesEitherSubtypeOrSuffix(superType)
        }
    }

    private func containsAllParameters(superType: MediaType) {
        if (superType._parameters.contains('q')) {
            return true
        }

        for ((key, value) in superType._parameters) {
            if (key.equalsIgnoreAsciiCase('*')) {
                continue
            }

            if (!this._parameters.contains(key)) {
                return false
            }
        }

        return true
    }

    private func matchesSubtypeWithoutSuffix(superType: MediaType) {
        return superType.matchesAllSubTypesWithoutSuffix || superType
            .subTypeWithoutSuffix
            .equalsIgnoreAsciiCase(this.subTypeWithoutSuffix)
    }

    private func matchesSubtypeSuffix(superType: MediaType) {
        return superType.subTypeSuffix.equalsIgnoreAsciiCase(this.subTypeSuffix)
    }

    private func matchesEitherSubtypeOrSuffix(superType: MediaType) {
        return superType.subType.equalsIgnoreAsciiCase(this.subType) || superType
            .subType
            .equalsIgnoreAsciiCase(this.subTypeSuffix)
    }
}

/**
 * @brief 提供媒体类型参数字符串解析能力。
 */
public struct MediaTypeParameterParser {
    /**
     * @brief 将参数片段解析为键值映射。
     * @param input 要解析的参数片段。
     * @return 解析得到的参数键值映射。
     */
    public static func parse(input: String): HashMap<String, String> {
        let parameters = HashMap<String, String>()
        var index = 0
        while (index < input.size) {
            if (input[index] == b' ' || input[index] == b';') {
                index++
                continue
            }
            if (let Some(offset) <- input.indexOf('=', index)) {
                let parameterNameLength = offset - index
                let parameterLength = (input.indexOf(';', index + parameterNameLength) ?? input.size) - index
                let name = input.slice(index, parameterNameLength).trim()
                let parameterValueLength = parameterLength - parameterNameLength - 1
                let value = input.slice(index + parameterNameLength + 1, parameterValueLength).trim()
                parameters.add(name, value)
                index += parameterLength + 1
            } else {
                break
            }
        }
        return parameters
    }
}

extend String {
    internal func slice(start: Int64, length: Int64) {
        return this[start..start + length]
    }
}
