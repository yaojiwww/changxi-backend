/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_mediator

/**
 * @brief 表示请求处理管道中的下一步委托。
 * @return 管道继续执行后的返回结果。
 */
public type RequestDelegate = () -> Any
