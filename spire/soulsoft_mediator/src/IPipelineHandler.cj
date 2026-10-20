/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 定义请求处理管道行为接口。
 */
public interface IPipelineHandler {
    /**
     * @brief 在请求处理管道中处理当前请求。
     * @param request 当前要处理的请求对象。
     * @param next 管道中的下一步委托。
     * @return 当前管道节点或后续节点返回的结果。
     */
    func handle(request: Any, next: RequestDelegate): Any
}
