// auth.js
import {
  UserManager,
  WebStorageStateStore,
} from "https://esm.sh/oidc-client-ts@3.0.1";

// 自动检测当前运行的根路径 (例如 http://localhost:3000)
const origin = window.location.origin;

export const oidcConfig = {
  // Duende IdentityServer Demo 地址
  authority: "http://localhost:5000",
  client_id: "interactive.public",

  // ⚠️ 关键点：回调地址指向 callback.html
  // 确保你的本地服务运行在端口 3000，否则 Duende 会报错 Invalid redirect_uri
  redirect_uri: `${origin}/callback.html`,

  // 登出后跳回 index.html
  post_logout_redirect_uri: `${origin}/index.html`,

  response_type: "code",
  scope: "openid profile offline_access",

  // 使用 LocalStorage 存储 Token，这样刷新页面 Token 还在
  userStore: new WebStorageStateStore({ store: window.localStorage }),

  // 登录成功后，拿着 Access Token 去换取完整的用户信息
  loadUserInfo: true,
};

export const userManager = new UserManager(oidcConfig);
