package soulsoft_web_authentication

import soulsoft_web_http.*
import soulsoft_identity_claims.*

/**
 * @brief 提供包含用户主体的身份验证上下文基类。
 * @param TOptions 当前上下文使用的方案选项类型。
 */
public abstract class PrincipalContext<TOptions> <: PropertiesContext<TOptions> where TOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 保存当前上下文的用户主体。
     */
    public var principal: ?ClaimsPrincipal = None

    /**
     * @brief 创建一个带用户主体的上下文基类实例。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前方案选项。
     * @param properties 身份验证属性。
     */
    protected init(context: HttpContext, scheme: AuthenticationScheme, options: TOptions,
        properties: ?AuthenticationProperties) {
        super(context, scheme, options, properties)
    }
}
