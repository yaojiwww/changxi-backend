package soulsoft_web_authentication

import soulsoft_identity_claims.*

/**
 * @brief 定义支持登录操作的身份验证处理器。
 */
public interface IAuthenticationSignInHandler {
    /**
     * @brief 执行登录处理。
     * @param user 待登录的用户主体。
     * @param properties 登录时附带的属性。
     */
    func signIn(user: ClaimsPrincipal, properties: ?AuthenticationProperties): Unit
}
