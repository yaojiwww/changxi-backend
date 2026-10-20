/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 定义通知发布能力。
 */
public interface IPublisher {
    /**
     * @brief 发布一个通知对象。
     * @param notification 要发布的通知实例。
     * @return 无返回值。
     */
    func publish<TNotification>(notification: TNotification): Unit where TNotification <: INotification
}
