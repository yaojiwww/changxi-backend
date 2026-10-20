package soulsoft_web_authentication

/**
 * @brief 定义支持登出操作的身份验证处理器。
 */
public interface IAuthenticationSignOutHandler <: IAuthenticationHandler{
    /**
     * @brief 执行登出处理。
     * @param properties 登出时附带的属性。
     */
    func signOut(properties: ?AuthenticationProperties): Unit
}
