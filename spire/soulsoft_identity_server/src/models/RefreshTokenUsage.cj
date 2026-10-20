/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

/**
 * @brief 表示刷新令牌使用策略。
 */
public enum RefreshTokenUsage <: Equatable<RefreshTokenUsage> {
    /**
     * @brief 表示刷新令牌只能使用一次。
     */
    | Once
    /**
     * @brief 表示刷新令牌可以重复使用。
     */
    | ReUse

    /**
     * @brief 判断两个刷新令牌使用策略是否相等。
     * @param that 需要比较的另一个使用策略。
     * @return 如果两个策略相等则返回 `true`。
     */
    public operator func ==(that: RefreshTokenUsage): Bool {
        match ((this, that)) {
            case (Once, Once) => true
            case (ReUse, ReUse) => true
            case _ => false
        }
    }
}
