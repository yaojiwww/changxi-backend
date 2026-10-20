/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_logging_configuration

import soulsoft_extensions_configuration.*

/**
 * @brief 定义面向指定日志提供者的配置访问接口。
 */
public interface ILoggerProviderConfiguration<TProvider> {
    /**
     * @brief 返回该日志提供者对应的配置视图。
     */
    prop configuration: IConfiguration
}
