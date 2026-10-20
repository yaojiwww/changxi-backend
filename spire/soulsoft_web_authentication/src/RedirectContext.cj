package soulsoft_web_authentication

import soulsoft_web_http.*

/**
 * @brief 表示带重定向地址的身份验证上下文。
 * @param TOptions 当前上下文使用的方案选项类型。
 */
public class RedirectContext<TOptions> <: PropertiesContext<TOptions> where TOptions <: AuthenticationSchemeOptions {
    /**
     * @brief 目标重定向地址。
     */
    public let redirectUri: String

    /**
     * @brief 创建一个重定向上下文。
     * @param context 当前 HTTP 上下文。
     * @param scheme 当前身份验证方案。
     * @param options 当前方案选项。
     * @param properties 身份验证属性。
     * @param redirectUri 目标重定向地址。
     */
    public init(context: HttpContext, scheme: AuthenticationScheme, options: TOptions,
        properties: AuthenticationProperties, redirectUri: String) {
        super(context, scheme, options, properties)
        this.redirectUri = redirectUri
    }
}
