/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_web_hosting

/**
 * @brief 定义启动和停止 HTTP 服务器的能力。
 */
public interface IServer {
    /**
     * @brief 使用指定请求管道启动服务器。
     * @param pipeline 用于处理请求的委托管道。
     */
    func start(pipeline: RequestDelegate): Unit
    /**
     * @brief 停止当前服务器。
     */
    func stop(): Unit
}
