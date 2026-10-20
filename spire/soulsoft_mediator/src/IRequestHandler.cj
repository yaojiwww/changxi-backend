/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 定义请求处理器接口。
 */
public interface IRequestHandler<TRequest, TResponse> where TRequest <: IRequest<TResponse> {
    /**
     * @brief 处理指定请求。
     * @param request 要处理的请求实例。
     * @return 请求处理后的响应结果。
     */
    func handle(request: TRequest): TResponse
}
