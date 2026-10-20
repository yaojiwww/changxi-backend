/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import std.collection.*
import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义声明服务接口。
 */
public interface IClaimService {
    /**
     * @brief 获取访问令牌需要包含的声明集合。
     * @param request 声明请求上下文。
     * @return 返回访问令牌声明集合。
     */
    func getAccessTokenClaims(request: ClaimsRequest): Collection<Claim>
    /**
     * @brief 获取身份令牌需要包含的声明集合。
     * @param request 声明请求上下文。
     * @return 返回身份令牌声明集合。
     */
    func getIdentityTokenClaims(request: ClaimsRequest): Collection<Claim>
}

/**
 * @brief 表示声明生成请求上下文。
 */
public class ClaimsRequest {
    /**
     * @brief 创建声明生成请求上下文。
     * @param client 当前客户端。
     * @param subject 当前用户主体。
     * @param resources 当前请求资源集合。
     */
    public ClaimsRequest(
        public let client: Client,
        public let subject: ClaimsPrincipal,
        public let resources: ResourceCollection
    ) {
    }

    /**
     * @brief 获取访问令牌涉及的声明类型集合。
     * @return 返回访问令牌声明类型数组。
     */
    public func getAccessTokenClaimTypes(): Array<String> {
        let claimTypes = ArrayList<String>()

        for (resource in resources.getApiScopes()) {
            claimTypes.add(all: resource.claimTypes)
        }

        for (resource in resources.getApiResources()) {
            claimTypes.add(all: resource.claimTypes)
        }

        return claimTypes.toArray()
    }

    /**
     * @brief 获取身份令牌涉及的声明类型集合。
     * @return 返回身份令牌声明类型数组。
     */
    public func getIdentityTokenClaimTypes(): Array<String> {
        let claimTypes = ArrayList<String>()

        for (resource in resources.getIdentityResources()) {
            claimTypes.add(all: resource.claimTypes)
        }

        return claimTypes.toArray()
    }
}
