/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

/**
 * @brief 允许对象接收配置绑定结果的接口。
 */
public interface IConfigurationBinding {
    /**
     * @brief 按成员名写入已完成类型转换的绑定值。
     * @param name 目标成员名。
     * @param value 已完成类型转换的绑定值。
     */
    func bind(name: String, value: Any): Unit
}
