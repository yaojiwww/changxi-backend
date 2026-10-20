// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_extensions_healthchecks

import std.time.*
import std.collection.*
import soulsoft_extensions_options.*
import soulsoft_extensions_logging.*
import soulsoft_extensions_injection.*

class HealthCheckService <: IHealthCheckService {
    private let _logger: ILogger
    private let _services: IServiceProvider
    private let _options: IOptions<HealthCheckServiceOptions>

    HealthCheckService(services: IServiceProvider) {
        _services = services
        _logger = services.getOrThrow<ILoggerFactory>().createLogger<HealthCheckService>()
        _options = services.getOrThrow<IOptions<HealthCheckServiceOptions>>()
    }

    /**
     * @brief 执行满足条件的健康检查并返回聚合报告。
     * @param predicate 用于筛选要执行健康检查的条件。
     * @return 返回本次执行生成的健康检查报告。
     */
    public func checkHealth(predicate: (HealthCheckRegistration) -> Bool): HealthReport {
        let registrations = _options.value.registrations |> filter {f => predicate(f)} |> collectArray

        var tasks = ArrayList<Future<HealthReportEntry>>()
        for (i in 0..registrations.size) {
            let task = runCheck(registrations[i])
            tasks.add(task)
        }

        let entries = HashMap<String, HealthReportEntry>(registrations.size)

        for (i in 0..registrations.size) {
            let entry = registrations[i]
            entries[entry.name] = tasks[i].get()
        }
        return HealthReport(entries)
    }

    private func runCheck(registration: HealthCheckRegistration): Future<HealthReportEntry> {
        spawn {
            let start = DateTime.nowUTC()
            let scope = _services.createScope()
            var task: ?Future<HealthCheckResult> = None
            try {
                let instance = registration.factory(scope.services)
                let checkTask = spawn {
                    instance.check(HealthCheckContext(registration))
                }
                task = checkTask
                let result = checkTask.get(registration.timeout)
                let duration = DateTime.nowUTC() - start
                return HealthReportEntry(result.status, duration, result.description, result.exception,
                    registration.tags, result.data)
            } catch (ex: TimeoutException) {
                task?.cancel()
                let duration = DateTime.nowUTC() - start
                _logger.error(ex,
                    "Health check ${registration.name} threw an unhandled exception after ${duration.toMilliseconds()}ms")
                return HealthReportEntry(HealthStatus.Unhealthy, duration, "A timeout occurred while running check.", ex,
                    registration.tags)
            } catch (ex: Exception) {
                let duration = DateTime.nowUTC() - start
                return HealthReportEntry(HealthStatus.Unhealthy, duration, ex.message, ex, registration.tags)
            } finally {
                scope.close()
            }
        }
    }
}
