/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

import soulsoft_identity_claims.*
import soulsoft_identity_server.models.*

/**
 * @brief 定义用户资料服务接口。
 */
public interface IProfileService {
    /**
     * @brief 获取指定调用场景下的资料声明。
     * @param request 用户资料请求。
     * @return 返回资料声明集合。
     */
    func getProfileData(request: ProfileDataRequest): Collection<Claim>
}

/**
 * @brief 表示用户资料请求。
 */
public class ProfileDataRequest {
    /**
     * @brief 创建用户资料请求。
     * @param caller 资料调用方类型。
     * @param client 当前客户端。
     * @param subject 当前用户主体。
     * @param resources 当前资源集合。
     */
    public ProfileDataRequest(public let caller: ProfileDataCaller, public let client: Client,
        public let subject: ClaimsPrincipal, public let resources: ResourceCollection) {
    }
}

/**
 * @brief 表示用户资料调用方类型。
 */
public enum ProfileDataCaller {
    /**
     * @brief 表示由 UserInfo 端点请求资料。
     */
    UserInfo
    /**
     * @brief 表示由访问令牌生成流程请求资料。
     */
    | AccessToken
    /**
     * @brief 表示由身份令牌生成流程请求资料。
     */
    | IdentityToken
}
