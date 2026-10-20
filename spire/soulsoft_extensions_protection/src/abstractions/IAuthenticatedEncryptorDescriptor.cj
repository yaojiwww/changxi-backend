// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_protection.abstractions

/**
 * @brief 定义认证加密器描述符接口。
 */
public interface IAuthenticatedEncryptorDescriptor {
    /**
     * @brief 导出当前描述符的 JSON 表示。
     * @return 返回序列化后的描述符信息。
     */
    func exportToJson(): JsonSerializedDescriptorInfo
}
