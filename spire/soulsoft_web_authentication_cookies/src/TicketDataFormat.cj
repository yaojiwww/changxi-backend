// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_authentication_cookies

import stdx.encoding.json.*
import soulsoft_web_authentication.*
import soulsoft_extensions_protection.*
import stdx.serialization.serialization.*

/**
 * @brief 定义认证数据的保护与还原格式。
 * @param TData 受保护的数据类型。
 */
public interface ISecureDataFormat<TData> {
    /**
     * @brief 保护指定数据并输出字符串表示。
     * @param data 待保护的数据。
     * @return 保护后的字符串。
     */
    func protect(data: TData): String
    /**
     * @brief 将受保护字符串还原为目标数据。
     * @param text 待还原的受保护字符串。
     * @return 还原后的数据；失败时返回 None。
     */
    func unprotect(text: String): ?TData
}

class TicketDataFormat <: ISecureDataFormat<AuthenticationTicket> {
    private let _dataProtector: IDataProtector

    init(dataProtector: IDataProtector) {
        _dataProtector = dataProtector
    }

    public func protect(data: AuthenticationTicket): String {
        let json = data.serialize().toJson().toJsonString()
        let bytes = _dataProtector.protect(json.toArray())
        return Base64UrlEncoder.encode(bytes)
    }

    public func unprotect(text: String): ?AuthenticationTicket {
        if (let Some(bytes) <- Base64UrlEncoder.decodeBytes(text)) {
            let plainBytes = _dataProtector.unprotect(bytes)
            unsafe {
                let json = String.withRawData(plainBytes)
                let dm = DataModel.fromJson(JsonValue.fromStr(json))
                return AuthenticationTicket.deserialize(dm)
            }
        }
        return None
    }
}
