// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_http.headers

/**
 * @brief 表示 HTTP If-Range 标头值（RFC 7233 §3.2）
 *
 * If-Range 可以是：
 * - ETag 值（强或弱），如 `"abc123"` 或 `W/"abc123"`
 * - HTTP-date（Unix epoch 秒，UTC），如 `Thu, 01 Jan 2015 00:00:00 GMT`
 */
public class RangeConditionHeaderValue <: Equatable<RangeConditionHeaderValue> {
    private static let parser: GenericHeaderParser<RangeConditionHeaderValue> = GenericHeaderParser<RangeConditionHeaderValue>(
        false, getRangeConditionLength)

    // 二选一：_entityTag 非 None 时使用 ETag，否则使用日期
    private var _entityTag: ?EntityTagHeaderValue = None
    private var _lastModified: ?Int64 = None // Unix epoch 秒（UTC）

    // 供解析器内部使用
    private init() {}

    /**
     * @brief 以 HTTP-date 构造（lastModified 为 Unix epoch 秒，UTC）
     * @param lastModified 资源最后修改时间的 Unix 时间戳。
     */
    public init(lastModified: Int64) {
        _lastModified = lastModified
    }

    /**
     * @brief 以 EntityTagHeaderValue 构造
     * @param entityTag ETag 标头值。
     */
    public init(entityTag: EntityTagHeaderValue) {
        _entityTag = entityTag
    }

    /**
     * @brief 以 ETag 字符串构造（如 `"\"abc\""`）
     * @param entityTag ETag 字符串。
     */
    public init(entityTag: String) {
        _entityTag = EntityTagHeaderValue(entityTag)
    }

    /**
     * @brief ETag 值（None 表示本实例是日期类型）
     * @return 当前 If-Range 的 ETag 值；日期模式下返回 `None`。
     */
    public prop entityTag: ?EntityTagHeaderValue {
        get() {
            _entityTag
        }
    }

    /**
     * @brief HTTP-date（Unix epoch 秒，UTC）；None 表示本实例是 ETag 类型
     * @return 当前 If-Range 的最后修改时间；ETag 模式下返回 `None`。
     */
    public prop lastModified: ?Int64 {
        get() {
            _lastModified
        }
    }

    /**
     * @brief 序列化为字符串：ETag 原样输出，日期格式化为 RFC 7231 格式
     * @return 当前 If-Range 标头的字符串表示。
     */
    public func toString(): String {
        match (_entityTag) {
            case Some(et) => return et.toString()
            case None => match (_lastModified) {
                case Some(ts) => return HeaderUtilities.formatDate(ts)
                case None => return ""
            }
        }
    }

    /**
     * @brief 比较两个 If-Range 标头值是否相等。
     * @param other 要比较的 If-Range 标头值。
     * @return 如果两个 If-Range 标头值相等则返回 true，否则返回 false。
     */
    public operator func ==(other: RangeConditionHeaderValue): Bool {
        match ((_entityTag, other._entityTag)) {
            case (Some(a), Some(b)) => return a == b
            case (None, None) => return _lastModified == other._lastModified
            case _ => return false
        }
    }

    /**
     * @brief 返回当前 If-Range 标头值的哈希值。
     * @return 当前 If-Range 标头值的哈希值。
     */
    public func hashCode(): Int64 {
        match (_entityTag) {
            case Some(et) => return et.hashCode()
            case None => match (_lastModified) {
                case Some(ts) => return ts
                case None => return 0
            }
        }
    }

    /**
     * @brief 解析 If-Range 字符串，格式非法时抛出异常
     * @param input 待解析的 If-Range 字符串。
     * @return 解析得到的 If-Range 标头值。
     */
    public static func parse(input: String): RangeConditionHeaderValue {
        let (ok, result, _) = parser.tryParseValue(input, 0)
        if (!ok) {
            throw Exception("Invalid If-Range header value: '${input}'")
        }
        match (result) {
            case Some(v) => return v
            case None => throw Exception("Invalid If-Range header value: '${input}'")
        }
    }

    /**
     * @brief 尝试解析 If-Range 字符串，返回 None 表示格式无效
     * @param input 待解析的 If-Range 字符串。
     * @return 解析成功时返回 If-Range 标头值；失败时返回 `None`。
     */
    public static func tryParse(input: String): ?RangeConditionHeaderValue {
        let (ok, result, _) = parser.tryParseValue(input, 0)
        if (!ok) {
            return None
        }
        return result
    }

    // 解析单个 If-Range 值（ETag 或 HTTP-date）
    private static func getRangeConditionLength(input: String, startIndex: Int64): (Int64, ?RangeConditionHeaderValue) {
        // 至少需要 2 个字符
        if (input.isEmpty() || startIndex + 1 >= input.size) {
            return (0, None)
        }

        let firstChar = input[startIndex]
        let secondChar = input[startIndex + 1]

        // ETag 判断：以 '"' 开头，或以 'W/' 或 'w/' 开头
        if (firstChar == b'"' || ((firstChar == b'W' || firstChar == b'w') && secondChar == b'/')) {
            let (etagLength, etag) = EntityTagHeaderValue.getEntityTagLength(input, startIndex)
            if (etagLength == 0) {
                return (0, None)
            }
            let result = RangeConditionHeaderValue()
            result._entityTag = etag
            return (etagLength, result)
        }

        // 尝试解析 HTTP-date
        match (HeaderUtilities.tryStringToDate(input, startIndex)) {
            case Some((consumed, epochSeconds)) =>
                let result = RangeConditionHeaderValue()
                result._lastModified = epochSeconds
                return (consumed, result)
            case None => return (0, None)
        }
    }
}
