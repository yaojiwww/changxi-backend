/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.models

/**
 * @brief 表示刷新令牌过期策略。
 */
public enum RefreshTokenExpiration <: Equatable<RefreshTokenExpiration> {
    /**
     * @brief 表示滑动过期策略。
     */
    | Sliding
    /**
     * @brief 表示绝对过期策略。
     */
    | Absolute

    /**
     * @brief 判断两个刷新令牌过期策略是否相等。
     * @param that 需要比较的另一个过期策略。
     * @return 如果两个策略相等则返回 `true`。
     */
    public operator func ==(that: RefreshTokenExpiration): Bool {
        match ((this, that)) {
            case (Sliding, Sliding) => true
            case (Absolute, Absolute) => true
            case _ => false
        }
    }
}
