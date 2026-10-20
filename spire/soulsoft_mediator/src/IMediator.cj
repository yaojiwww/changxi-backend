/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 表示同时具备请求发送和通知发布能力的中介者接口。
 */
public interface IMediator <: ISender & IPublisher {}
