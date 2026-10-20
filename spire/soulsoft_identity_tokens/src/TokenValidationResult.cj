// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_tokens

import soulsoft_identity_claims.*

/**
 * @brief 表示令牌验证结果。
 */
public enum TokenValidationResult {
    /**
     * @brief 表示令牌验证成功。
     */
    Success(ClaimsIdentity, SecurityToken)
    /**
     * @brief 表示令牌验证失败。
     */
    | Failed(Exception)

    /**
     * @brief 检查验证结果是否成功。
     * @return 当前结果为 `Success` 时返回 `true`。
     */
    public func isValid(): Bool {
        match (this) {
            case Success(_, _) => true
            case _ => false
        }
    }
}
