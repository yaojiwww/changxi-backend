/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 定义通知处理器接口。
 */
public interface INotificationHandler<TNotification> where TNotification <: INotification {
    /**
     * @brief 处理一个通知消息。
     * @param notification 要处理的通知实例。
     * @return 无返回值。
     */
    func handle(notification: TNotification): Unit
}
