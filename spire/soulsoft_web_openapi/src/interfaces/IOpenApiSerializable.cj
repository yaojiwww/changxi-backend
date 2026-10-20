// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.interfaces

/**
 * @brief 定义 OpenAPI 对象序列化接口。
 */
public interface IOpenApiSerializable {
    /**
     * @brief 按 OpenAPI V3 格式写出当前对象。
     * @param writer OpenAPI 写入器。
     */
    func serializeAsV3(writer: IOpenApiWriter): Unit
}
