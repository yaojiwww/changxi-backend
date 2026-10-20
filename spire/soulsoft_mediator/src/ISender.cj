/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 定义请求发送能力。
 */
public interface ISender {
    /**
     * @brief 发送一个请求并返回响应。
     * @param request 要发送的请求实例。
     * @return 对应请求处理器返回的响应结果。
     */
    func send<TRequest, TResponse>(request: TRequest): TResponse where TRequest <: IRequest<TResponse>
}
