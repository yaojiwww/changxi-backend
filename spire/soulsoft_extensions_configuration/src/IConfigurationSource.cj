// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_configuration

/**
 * @brief 定义可构建配置提供程序的配置源接口。
 */
public interface IConfigurationSource {
    /**
     * @brief 基于指定配置构建器创建配置提供程序。
     * @param builder 当前配置构建器。
     * @return 返回创建得到的配置提供程序。
     */
    func build(builder: IConfigurationBuilder): IConfigurationProvider
}
