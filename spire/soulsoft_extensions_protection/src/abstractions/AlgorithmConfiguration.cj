// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义算法配置的抽象基类。
 */
public abstract class AlgorithmConfiguration {
    /**
     * @brief 创建新的认证加密器描述符。
     * @return 返回新建的认证加密器描述符。
     */
    public func createNewDescriptor(): IAuthenticatedEncryptorDescriptor
}
