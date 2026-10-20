/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

import soulsoft_extensions_injection.*

/**
 * @brief 提供请求分发与通知发布的默认中介者实现。
 */
public class Mediator <: IMediator {
    private let _services: IServiceProvider

    /**
     * @brief 使用服务提供器创建中介者实例。
     * @param services 用于解析处理器和管道行为的服务提供器。
     */
    public init(services: IServiceProvider) {
        _services = services
    }

    /**
     * @brief 发送请求并返回响应。
     * @param request 要发送的请求实例。
     * @return 请求处理器返回的响应结果。
     * @throws NoneValueException 当请求处理器未注册或返回结果无法转换为目标类型时抛出。
     */
    public func send<TRequest, TResponse>(request: TRequest): TResponse where TRequest <: IRequest<TResponse> {
        let next: RequestDelegate = {
            => _services.getOrThrow<IRequestHandler<TRequest, TResponse>>().handle(request)
        }
        let app = createPipelineDelegate(request, next)
        return (app() as TResponse).getOrThrow()
    }

    /**
     * @brief 发布通知给所有已注册处理器。
     * @param notification 要发布的通知实例。
     * @return 无返回值。
     */
    public func publish<TNotification>(notification: TNotification): Unit where TNotification <: INotification {
        let handlers = _services.getAll<INotificationHandler<TNotification>>().toArray()
        var index: Int64 = 0
        while (index < handlers.size) {
            handlers[index].handle(notification)
            index++
        }
    }

    private func createPipelineDelegate<TRequest>(request: TRequest, next: RequestDelegate) {
        let handlers = _services.getAll<IPipelineHandler>().toArray()
        var pipeline = next
        var index = handlers.size - 1
        while (index >= 0) {
            let handler = handlers[index]
            let innerNext = pipeline
            pipeline = {=> handler.handle(request, innerNext)}
            index--
        }
        return pipeline
    }
}
