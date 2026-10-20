/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_identity_server.services

/**
 * @brief 定义句柄生成器接口。
 */
public interface IHandleGenerator {
    /**
     * @brief 使用默认长度生成句柄。
     * @return 返回生成的句柄字符串。
     */
    func generate(): String {
        generate(16)
    }
    /**
     * @brief 生成指定长度的句柄。
     * @param length 句柄长度。
     * @return 返回生成的句柄字符串。
     */
    func generate(length: Int32): String
}
