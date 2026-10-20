package soulsoft_web_staticfiles.fileProviders

/**
 * @brief 表示一个不存在的目录内容集合。
 */
public class NotFoundDirectoryContents <: IDirectoryContents {

    /**
     * @brief 返回不存在目录内容的共享实例。
     */
    public static let instance = NotFoundDirectoryContents()
    
    private static let _iterator = NotFoundDirectoryContentsIterator()
    /**
     * @brief 返回目录内容是否存在。
     * @return 固定返回 false。
     */
    public prop exists: Bool {
        get() {
            false
        }
    }

    /**
     * @brief 返回用于遍历目录内容的迭代器。
     * @return 始终不产生任何项的迭代器。
     */
    public func iterator(): Iterator<IFileInfo> {
        return _iterator
    }
}

private class NotFoundDirectoryContentsIterator <: Iterator<IFileInfo> {
    public func next(): ?IFileInfo {
        None
    }
}
