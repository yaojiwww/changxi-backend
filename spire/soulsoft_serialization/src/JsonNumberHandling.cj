/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization

/**
 * @brief 表示 JSON 数值读写行为的组合选项。
 */
public struct JsonNumberHandling {
    private let value: UInt8

    private init(value: UInt8) {
        this.value = value
    }

    /**
     * @brief 表示严格数值读写模式。
     */
    public static let Strict: JsonNumberHandling
    /**
     * @brief 表示将数值写出为字符串。
     */
    public static let WriteAsString: JsonNumberHandling
    /**
     * @brief 表示允许从字符串读取数值。
     */
    public static let AllowReadingFromString: JsonNumberHandling

    static init() {
        Strict = JsonNumberHandling(0)
        WriteAsString = JsonNumberHandling(1)
        AllowReadingFromString = JsonNumberHandling(2)
    }

    /**
     * @brief 组合两个数值处理选项。
     * @param that 要组合的另一个选项。
     * @return 组合后的数值处理选项。
     */
    public operator func |(that: JsonNumberHandling): JsonNumberHandling {
        JsonNumberHandling(this.value | that.value)
    }

    /**
     * @brief 检查当前选项是否包含指定标记。
     * @param flag 要检查的标记。
     * @return 如果包含指定标记则返回 true。
     */
    public func hasFlag(flag: JsonNumberHandling): Bool {
        (this.value & flag.value) != 0
    }
}
