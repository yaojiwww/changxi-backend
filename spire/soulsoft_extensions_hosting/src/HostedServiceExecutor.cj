package soulsoft_extensions_hosting

class HostedServiceExecutor {
    public HostedServiceExecutor(private let services: Collection<IHostedService>) {
        
    }

    /**
     * @brief 顺序启动当前执行器管理的全部托管服务。
     */
    public func start(): Unit {
        for (service in services) {
            service.start()
        }
    }

    /**
     * @brief 顺序停止当前执行器管理的全部托管服务。
     */
    public func stop(): Unit {
        for (service in services) {
            service.stop()
        }
    }
}
