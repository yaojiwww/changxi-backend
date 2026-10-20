package soulsoft_extensions_hosting

/**
 * @brief 定义主机底层生命周期控制接口。
 */
public interface IHostLifetime {
    /**
     * @brief 等待主机完成启动准备。
     */
    func waitForStart(): Unit

    /**
     * @brief 停止底层主机生命周期控制。
     */
    func stop(): Unit
}
