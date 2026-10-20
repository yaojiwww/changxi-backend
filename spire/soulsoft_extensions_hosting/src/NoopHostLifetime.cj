package soulsoft_extensions_hosting

/**
 * @brief 提供空操作的主机生命周期实现。
 */
public class NoopHostLifetime <: IHostLifetime {
    /**
     * @brief 直接完成主机启动等待。
     */
    public func waitForStart(): Unit {}

    /**
     * @brief 直接完成主机停止操作。
     */
    public func stop(): Unit {}
}
