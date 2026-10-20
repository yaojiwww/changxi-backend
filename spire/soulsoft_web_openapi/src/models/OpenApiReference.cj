// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_openapi.models

/**
 * @brief 表示 OpenAPI 引用对象。
 */
public class OpenApiReference <: IOpenApiSerializable {
    /**
     * @brief 表示引用标识。
     */
    public var id: String
    /**
     * @brief 表示引用类型。
     */
    public var referenceType: ReferenceType

    /**
     * @brief 创建 OpenAPI 引用对象。
     * @param referenceType 引用类型。
     * @param id 引用标识。
     */
    public init(referenceType: ReferenceType, id: String) {
        this.id = id
        this.referenceType = referenceType
    }

    /**
     * @brief 返回当前引用在 OpenAPI 文档中的字符串值。
     * @return 引用字符串。
     */
    public func toReferenceString(): String {
        if (ReferenceType.Tag == referenceType) {
            return id
        }
        return "#/components/${referenceType.toString()}/${id}"
    }

    /**
     * @brief 按 OpenAPI V3 格式写出当前引用对象。
     * @param writer OpenAPI 写入器。
     */
    public func serializeAsV3(writer: IOpenApiWriter): Unit {
        if (ReferenceType.Tag == referenceType) {
            writer.writeValue(id)
            return
        }
        writer.startObject()
        writer.writeName("$ref")
        writer.writeValue(toReferenceString())
        writer.endObject()
    }
}
