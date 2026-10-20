// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

import std.collection.*

/**
 * @brief 表示单个健康检查的报告条目。
 */
public struct HealthReportEntry {
    private let _status: HealthStatus
    private let _duration: Duration
    private let _exception: ?Exception
    private let _description: ?String
    private let _tags: Array<String>
    private let _data: ReadOnlyMap<String, Object>

    /**
     * @brief 创建健康检查报告条目。
     * @param status 健康检查状态。
     * @param duration 健康检查执行耗时。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @param tags 健康检查关联的标签集合。
     */
    public init(status: HealthStatus, duration: Duration, description: ?String, exception: ?Exception, tags: Array<String>) {
        _status = status
        _duration = duration
        _description = description
        _exception = exception
        _tags = tags
        _data = HashMap<String, Object>()
    }

    /**
     * @brief 创建包含扩展数据的健康检查报告条目。
     * @param status 健康检查状态。
     * @param duration 健康检查执行耗时。
     * @param description 健康检查结果描述。
     * @param exception 健康检查过程中捕获的异常。
     * @param tags 健康检查关联的标签集合。
     * @param data 健康检查附带的数据集合。
     */
    public init(status: HealthStatus, duration: Duration, description: ?String, exception: ?Exception, tags: Array<String>,
        data: ReadOnlyMap<String, Object>) {
        _status = status
        _duration = duration
        _description = description
        _exception = exception
        _tags = tags
        _data = data
    }

    /**
     * @brief 返回当前报告条目的健康状态。
     * @return 返回当前报告条目的健康状态。
     */
    public prop status: HealthStatus {
        get() {
            _status
        }
    }

    /**
     * @brief 返回当前报告条目的执行耗时。
     * @return 返回当前报告条目的执行耗时。
     */
    public prop duration: Duration {
        get() {
            _duration
        }
    }

    /**
     * @brief 返回当前报告条目关联的标签集合。
     * @return 返回当前报告条目关联的标签集合。
     */
    public prop tags: Array<String> {
        get() {
            _tags
        }
    }

    /**
     * @brief 返回当前报告条目附带的数据集合。
     * @return 返回当前报告条目附带的数据集合。
     */
    public prop data: ReadOnlyMap<String, Object> {
        get() {
            _data
        }
    }

    /**
     * @brief 返回当前报告条目记录的异常。
     * @return 返回当前报告条目记录的异常；如果没有异常则返回 None。
     */
    public prop exception: ?Exception {
        get() {
            _exception
        }
    }

    /**
     * @brief 返回当前报告条目的描述信息。
     * @return 返回当前报告条目的描述信息；如果没有描述则返回 None。
     */
    public prop description: ?String {
        get() {
            _description
        }
    }
}
