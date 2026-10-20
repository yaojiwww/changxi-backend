// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package soulsoft_web_http

/**
 * @brief 定义提供 Session 对象的功能接口。
 */
public interface ISessionFeature {
    /**
     * @brief 返回当前请求关联的 Session 对象。
     * @return 当前请求关联的 Session 对象。
     */
    prop session: Session
}
