/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import stdx.encoding.json.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*
import stdx.serialization.serialization.*

/**
 * @brief 定义用户同意服务接口。
 */
public interface IConsentService {
    /**
     * @brief 获取指定返回地址的同意上下文。
     * @param returnUrl 返回地址。
     * @return 返回同意上下文结果。
     */
    func getConsentContext(returnUrl: String): ConsentContextResult
    /**
     * @brief 为当前主体创建同意记录。
     * @param subject 当前用户主体。
     * @param client 当前客户端。
     * @param scopes 已同意的作用域数组。
     */
    func createConsent(subject: ClaimsPrincipal, client: Client, scopes: Array<String>): Unit
}

/**
 * @brief 表示同意页面上下文结果。
 */
public class ConsentContextResult {
    /**
     * @brief 创建同意上下文结果。
     * @param client 当前客户端。
     * @param resources 当前资源集合。
     */
    public ConsentContextResult(public let client: Client, public let resources: ResourceCollection) {}

    /**
     * @brief 将同意上下文转换为 JSON 值。
     * @return 返回同意上下文 JSON 对象。
     */
    public func toJson(): JsonValue {
        let result = DataModelStruct()
        let scopes = DataModelSeq()
        for (pattern in resources.getApiScopes()) {
            let scope = DataModelStruct()
            scope.add(field("name", pattern.name))
            scope.add(field("required", pattern.required))
            scope.add(field("description", pattern.description))
            scopes.add(scope)
        }
        for (pattern in resources.getIdentityResources()) {
            let scope = DataModelStruct()
            scope.add(field("name", pattern.name))
            scope.add(field("required", pattern.required))
            scope.add(field("description", pattern.description))
            scopes.add(scope)
        }
        result.add(field("clientId", client.clientId))
        result.add(field("clientName", client.clientName))
        result.add(field("description", client.description))
        result.add(Field("scopes", scopes))
        return result.toJson()
    }
}
