// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_options

/**
 * @brief 表示选项验证结果。
 */
public class ValidateOptionsResult {
    /**
     * @brief 表示跳过验证的结果。
     */
    public static let skip: ValidateOptionsResult

    /**
     * @brief 表示验证成功的结果。
     */
    public static let success: ValidateOptionsResult

    static init() {
        skip = ValidateOptionsResult(skipped: true)
        success = ValidateOptionsResult(succeeded: true)
    }

    private ValidateOptionsResult(public let succeeded!: Bool = false, public let skipped!: Bool = false,
        public let failed!: Bool = false, public let failureMessage!: ?String = None,
        public let failures!: ?Collection<String> = None) {
    }

    /**
     * @brief 创建一个包含单条失败消息的失败结果。
     * @param failureMessage 验证失败消息。
     * @return 返回失败结果。
     */
    public static func fail(failureMessage: String): ValidateOptionsResult {
        return ValidateOptionsResult(failed: true, failureMessage: failureMessage, failures: [failureMessage])
    }

    /**
     * @brief 创建一个包含多条失败消息的失败结果。
     * @param failures 验证失败消息集合。
     * @return 返回失败结果。
     */
    public static func fail(failures: Collection<String>): ValidateOptionsResult {
        return ValidateOptionsResult(failed: true, failures: failures)
    }
}
