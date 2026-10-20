package soulsoft_web_routing.abstractions

import std.reflect.*

/**
 * @brief 定义路由参数策略的基础接口。
 */
public interface IParameterPolicy <: ToString {
    /**
     * @brief 返回当前参数策略的字符串表示。
     * @return 当前参数策略的类型字符串。
     */
    func toString() {
        TypeInfo.of(this).toString()
    }
}
