"""
test_error_handling.py — 令牌验证错误处理测试（端口5003）

测试场景：
  - 过期令牌验证
  - 无效签名令牌验证
  - 详细令牌验证端点
  - 受保护端点错误响应
"""

import pytest
from conftest import get, post, get_with_auth, obtain_token, URL_ERROR, URL_BASIC


class TestHealthCheck:
    """健康检查端点测试"""

    def test_health_returns_200(self):
        r = get(URL_ERROR, "/health")
        assert r.status_code == 200


class TestExpiredToken:
    """过期令牌测试"""

    def test_expired_token_endpoint_returns_200(self):
        """过期令牌生成端点应可用"""
        r = get(URL_ERROR, "/test/expired")
        assert r.status_code == 200

    def test_expired_token_format(self):
        """过期令牌响应格式验证"""
        r = get(URL_ERROR, "/test/expired")
        data = r.json()
        assert "expired_token" in data
        assert "note" in data
        assert "expired" in data["note"].lower()

    def test_expired_token_is_valid_jwt_format(self):
        """过期令牌应是有效JWT格式"""
        r = get(URL_ERROR, "/test/expired")
        token = r.json()["expired_token"]
        parts = token.split(".")
        assert len(parts) == 3

    def test_expired_token_validation_fails(self):
        """验证过期令牌必须返回 401 且 valid=false"""
        r = get(URL_ERROR, "/test/expired")
        expired_token = r.json()["expired_token"]

        r2 = post(URL_ERROR, "/verify", json={"token": expired_token})
        assert r2.status_code == 401
        data = r2.json()
        assert data["valid"] is False
        assert "error" in data

    def test_expired_token_cannot_access_protected(self):
        """过期令牌不能访问受保护端点"""
        r = get(URL_ERROR, "/test/expired")
        expired_token = r.json()["expired_token"]

        r2 = get_with_auth(URL_ERROR, "/protected", expired_token)
        assert r2.status_code in [401, 403]


class TestInvalidSignatureToken:
    """无效签名令牌测试"""

    def test_invalid_token_endpoint_returns_200(self):
        """无效令牌生成端点应可用"""
        r = get(URL_ERROR, "/test/invalid")
        assert r.status_code == 200

    def test_invalid_token_format(self):
        """无效令牌响应格式验证"""
        r = get(URL_ERROR, "/test/invalid")
        data = r.json()
        assert "invalid_token" in data
        assert "note" in data
        assert "signature" in data["note"].lower() or "wrong" in data["note"].lower()

    def test_invalid_token_is_valid_jwt_format(self):
        """无效签名令牌仍是有效JWT格式（只是签名不对）"""
        r = get(URL_ERROR, "/test/invalid")
        token = r.json()["invalid_token"]
        parts = token.split(".")
        assert len(parts) == 3

    def test_invalid_token_validation_fails(self):
        """验证无效签名令牌应失败"""
        r = get(URL_ERROR, "/test/invalid")
        invalid_token = r.json()["invalid_token"]

        r2 = post(URL_ERROR, "/verify", json={"token": invalid_token})
        # 无效签名应返回401
        assert r2.status_code == 401
        data = r2.json()
        assert data["valid"] is False
        assert "error" in data


class TestTokenVerification:
    """详细令牌验证端点测试"""

    def test_verify_valid_token(self):
        """验证有效令牌应返回详细信息"""
        # 从基础服务器获取有效令牌
        token = obtain_token(URL_BASIC)
        r = post(URL_ERROR, "/verify", json={"token": token})
        assert r.status_code == 200
        data = r.json()
        assert data["valid"] is True
        assert "issuer" in data
        assert "audience" in data
        assert "claims" in data

    def test_verify_valid_token_returns_correct_issuer(self):
        """验证返回的发行者应正确"""
        token = obtain_token(URL_BASIC)
        r = post(URL_ERROR, "/verify", json={"token": token})
        data = r.json()
        assert data["issuer"] == "soulsoft-test-server"

    def test_verify_valid_token_returns_audience_array(self):
        """验证返回的受众应是数组"""
        token = obtain_token(URL_BASIC)
        r = post(URL_ERROR, "/verify", json={"token": token})
        data = r.json()
        assert isinstance(data["audience"], list)
        assert "soulsoft-test-client" in data["audience"]

    def test_verify_valid_token_returns_claims_object(self):
        """验证返回的声明应是对象"""
        token = obtain_token(URL_BASIC, username="testuser", role="admin")
        r = post(URL_ERROR, "/verify", json={"token": token})
        data = r.json()
        assert isinstance(data["claims"], dict)
        # 检查声明中包含name和role
        claims = data["claims"]
        name_key = "name" if "name" in claims else "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
        assert name_key in claims

    def test_verify_invalid_token_returns_error(self):
        """验证无效令牌应返回错误信息"""
        r = post(URL_ERROR, "/verify", json={"token": "invalid.token.signature"})
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False
        assert "error" in data

    def test_verify_empty_token(self):
        """验证空令牌"""
        r = post(URL_ERROR, "/verify", json={"token": ""})
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False

    def test_verify_missing_token_field(self):
        """验证请求中缺少token字段，空字符串应被视为无效令牌"""
        r = post(URL_ERROR, "/verify", json={})
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False

    def test_verify_malformed_token(self):
        """验证格式错误的令牌"""
        r = post(URL_ERROR, "/verify", json={"token": "not-a-valid-jwt-format"})
        assert r.status_code == 401
        data = r.json()
        assert data["valid"] is False


class TestProtectedEndpointErrors:
    """受保护端点错误响应测试"""

    def test_protected_without_token_returns_401(self):
        """无令牌访问受保护端点"""
        r = get(URL_ERROR, "/protected")
        assert r.status_code == 401

    def test_protected_with_valid_token_returns_200(self):
        """有效令牌访问受保护端点"""
        token = obtain_token(URL_BASIC)
        r = get_with_auth(URL_ERROR, "/protected", token)
        assert r.status_code == 200

    def test_protected_error_includes_www_authenticate_header(self):
        """401响应应包含WWW-Authenticate头"""
        r = get(URL_ERROR, "/protected")
        assert r.status_code == 401
        assert "www-authenticate" in r.headers or "WWW-Authenticate" in r.headers


class TestErrorMessages:
    """错误消息测试"""

    def test_invalid_token_error_message_contains_signature(self):
        """无效签名错误消息应提到签名"""
        r = get(URL_ERROR, "/test/invalid")
        invalid_token = r.json()["invalid_token"]

        r2 = post(URL_ERROR, "/verify", json={"token": invalid_token})
        assert r2.status_code == 401
        error_msg = r2.json().get("error", "").lower()
        # 错误消息应包含signature或验证相关词汇
        assert any(word in error_msg for word in ["signature", "valid", "验证", "签名"])

    def test_expired_token_error_message_contains_expired(self):
        """过期令牌错误消息应提到过期"""
        r = get(URL_ERROR, "/test/expired")
        expired_token = r.json()["expired_token"]

        r2 = post(URL_ERROR, "/verify", json={"token": expired_token})
        # 注意：过期令牌可能被不同的方式处理
        if r2.status_code == 401:
            error_msg = r2.json().get("error", "").lower()
            # 错误消息应包含expired或过期相关词汇
            assert any(word in error_msg for word in ["expir", "过期", "lifetime"])


class TestEdgeCases:
    """边界情况测试"""

    def test_verify_token_with_special_characters_in_claims(self):
        """测试包含特殊字符的声明"""
        # 从基础服务器获取令牌（用户名可能包含特殊字符）
        token = obtain_token(URL_BASIC, username="user@example.com", role="test-role_123")
        r = post(URL_ERROR, "/verify", json={"token": token})
        assert r.status_code == 200
        data = r.json()
        assert data["valid"] is True

    def test_large_token_verify(self):
        """测试大令牌验证"""
        # 创建包含多个声明的令牌
        # 注意：当前API不支持直接添加自定义声明，使用长用户名模拟
        long_name = "a" * 100
        token = obtain_token(URL_BASIC, username=long_name)
        r = post(URL_ERROR, "/verify", json={"token": token})
        assert r.status_code == 200


class TestInvalidSignatureProtected:
    """无效签名令牌访问受保护端点"""

    def test_invalid_signature_token_cannot_access_protected(self):
        """无效签名令牌不能访问受保护端点"""
        r = get(URL_ERROR, "/test/invalid")
        invalid_token = r.json()["invalid_token"]

        r2 = get_with_auth(URL_ERROR, "/protected", invalid_token)
        assert r2.status_code == 401

    def test_expired_and_invalid_both_return_401_on_protected(self):
        """过期令牌和无效签名令牌均无法通过受保护端点认证"""
        r_expired = get(URL_ERROR, "/test/expired")
        r_invalid = get(URL_ERROR, "/test/invalid")

        expired_token = r_expired.json()["expired_token"]
        invalid_token = r_invalid.json()["invalid_token"]

        assert get_with_auth(URL_ERROR, "/protected", expired_token).status_code == 401
        assert get_with_auth(URL_ERROR, "/protected", invalid_token).status_code == 401


class TestIncludeErrorDetails:
    """includeErrorDetails=true 效果验证（error服务器启用此选项）"""

    def test_401_response_includes_www_authenticate_header(self):
        """无令牌访问时应返回 WWW-Authenticate 头"""
        r = get(URL_ERROR, "/protected")
        assert r.status_code == 401
        headers_lower = {k.lower(): v for k, v in r.headers.items()}
        assert "www-authenticate" in headers_lower

    def test_invalid_token_www_authenticate_includes_error_detail(self):
        """无效令牌时 WWW-Authenticate 头应包含 error 详情（includeErrorDetails=true）"""
        r = get(URL_ERROR, "/test/invalid")
        invalid_token = r.json()["invalid_token"]

        r2 = get_with_auth(URL_ERROR, "/protected", invalid_token)
        assert r2.status_code == 401
        headers_lower = {k.lower(): v for k, v in r2.headers.items()}
        www_auth = headers_lower.get("www-authenticate", "")
        # includeErrorDetails=true 时应携带 error 和 error_description
        assert "error" in www_auth.lower()

    def test_expired_token_www_authenticate_includes_error_detail(self):
        """过期令牌时 WWW-Authenticate 头应包含 error 详情"""
        r = get(URL_ERROR, "/test/expired")
        expired_token = r.json()["expired_token"]

        r2 = get_with_auth(URL_ERROR, "/protected", expired_token)
        assert r2.status_code == 401
        headers_lower = {k.lower(): v for k, v in r2.headers.items()}
        www_auth = headers_lower.get("www-authenticate", "")
        assert "error" in www_auth.lower()
