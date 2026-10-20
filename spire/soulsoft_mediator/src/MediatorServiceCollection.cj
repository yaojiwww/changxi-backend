/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

import soulsoft_extensions_injection.*

/**
 * @brief 定义中介者服务集合扩展接口。
 */
public interface MediatorServiceCollection {
    /**
     * @brief 向服务集合注册中介者基础服务。
     * @return 用于后续注册处理器和管道的构建器实例。
     */
    func addMediator(): MediatorBuilder
}

extend ServiceCollection <: MediatorServiceCollection {
    /**
     * @brief 向服务集合注册中介者、发送器和发布器服务。
     * @return 用于后续注册处理器和管道的构建器实例。
     */
    public func addMediator(): MediatorBuilder {
        addScoped<IMediator, Mediator> {
            sp => Mediator(sp)
        }
        addScoped<ISender>{sp =>
            sp.getOrThrow<IMediator>()
        }
        addScoped<IPublisher>{sp =>
            sp.getOrThrow<IMediator>()
        }
        MediatorBuilder(this)
    }
}
