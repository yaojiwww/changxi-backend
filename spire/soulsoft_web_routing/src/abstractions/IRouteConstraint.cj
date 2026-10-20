package soulsoft_web_routing.abstractions

import soulsoft_web_http.*

/**
 * @brief 定义路由约束接口。
 */
public interface IRouteConstraint <: IParameterPolicy {
    /**
     * @brief 检查路由值是否满足当前约束。
     * @param context 当前 HTTP 上下文。
     * @param routeKey 路由值键名。
     * @param values 路由值字典。
     * @return 满足约束时返回 true。
     */
    func isMatch(context: ?HttpContext, routeKey: String, values: RouteValueDictionary): Bool
}
