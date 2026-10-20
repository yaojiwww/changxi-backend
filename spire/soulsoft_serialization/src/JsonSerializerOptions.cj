/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

import std.collection.*

/**
 * @brief 表示 JSON 序列化与反序列化配置。
 */
public class JsonSerializerOptions {
    public static let default: JsonSerializerOptions

    static init() {
        default = JsonSerializerOptions()
    }

    /**
     * @brief 创建一组空的序列化选项。
     */
    public init() {}

    /**
     * @brief 通过复制现有选项创建新的序列化选项。
     * @param options 要复制的选项对象。
     */
    public init(options: JsonSerializerOptions) {
        writeIndented = options.writeIndented
        for (converter in options.converters) {
            converters.add(converter)
        }
        dateFormatString = options.dateFormatString
        defaultIgnoreCondition = options.defaultIgnoreCondition
        numberHandling = options.numberHandling
    }

    /**
     * @brief 指定是否以缩进格式输出 JSON。
     */
    public var writeIndented = false
    /**
     * @brief 保存用户注册的自定义转换器集合。
     */
    public let converters = ArrayList<IJsonConverter>()
    /**
     * @brief 指定日期时间的格式化字符串。
     */
    public var dateFormatString: ?String = None
    /**
     * @brief 指定字段默认忽略条件。
     */
    public var defaultIgnoreCondition = JsonIgnoreCondition.Never
    /**
     * @brief 指定数值类型的读写策略。
     */
    public var numberHandling: JsonNumberHandling = JsonNumberHandling.Strict

    public func getConverter<T>(): ?JsonConverter<T> {
        // 用户自定义转换器（后注册优先，可覆盖内置行为）
        if (let Some(converter) <- findLastConverter<T>(converters)) {
            return converter
        }
        // 回退到内置默认转换器
        return DefaultJsonConverters.getConverter<T>()
    }
}
