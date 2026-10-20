// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_hosting

/**
 * @brief 定义主机应用生命周期通知接口。
 */
public interface IHostApplicationLifetime {
    /**
     * @brief 注册应用启动完成时执行的回调。
     * @param callback 应用启动完成时执行的回调。
     */
    func onStarted(callback: () -> Unit): Unit

    /**
     * @brief 注册应用停止完成时执行的回调。
     * @param callback 应用停止完成时执行的回调。
     */
    func onStopped(callback: () -> Unit): Unit

    /**
     * @brief 注册应用开始停止时执行的回调。
     * @param callback 应用开始停止时执行的回调。
     */
    func onStopping(callback: () -> Unit): Unit

    /**
     * @brief 通知应用开始停止。
     */
    func stopApplication(): Unit
}
