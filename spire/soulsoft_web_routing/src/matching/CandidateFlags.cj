// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_routing.matching

/**
 * @brief 表示候选端点附带的匹配特征标志。
 */
public struct CandidateFlags <: Equatable<CandidateFlags> {
    private let _value: Byte
    /**
     * @brief 表示不包含任何附加特征的候选标志。
     */
    public static let None = CandidateFlags(0)
    /**
     * @brief 表示候选端点包含默认路由值。
     */
    public static let HasDefaults = CandidateFlags(1)
    /**
     * @brief 表示候选端点包含参数捕获信息。
     */
    public static let HasCaptures = CandidateFlags(2)
    /**
     * @brief 表示候选端点包含捕获所有参数。
     */
    public static let HasCatchAll = CandidateFlags(4)
    /**
     * @brief 表示候选端点包含复合路径段。
     */
    public static let HasComplexSegments = CandidateFlags(8)
    /**
     * @brief 表示候选端点包含路由约束。
     */
    public static let HasConstraints = CandidateFlags(16)
    /**
     * @brief 表示候选端点包含需要预填充槽位的特征。
     */
    public static let HasSlots = HasDefaults | HasCaptures | HasCatchAll

    init(value: Byte) {
        _value = value
    }

    public operator func |(that: CandidateFlags) {
        let value = this._value | that._value
        return CandidateFlags(value)
    }

    /**
     * @brief 检查当前标志是否包含指定标志位。
     * @param flags 要检查的标志位。
     * @return 包含指定标志位时返回 true。
     */
    public func has(flags: CandidateFlags): Bool {
        (this._value & flags._value) != 0
    }

    public operator func ==(that: CandidateFlags) {
        return this._value == that._value
    }
}
