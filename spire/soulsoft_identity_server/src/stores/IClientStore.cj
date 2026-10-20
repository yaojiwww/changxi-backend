/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.stores

import soulsoft_identity_server.models.*

/**
 * @brief 定义客户端存储接口。
 */
public interface IClientStore {
    /**
     * @brief 根据客户端标识查找客户端。
     * @param id 客户端标识。
     * @return 返回客户端对象；不存在时返回空。
     */
    func find(id: String): ?Client
}
