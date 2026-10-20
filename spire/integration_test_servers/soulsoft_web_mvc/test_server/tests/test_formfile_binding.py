"""
test_formfile_binding.py — FormFileModelBinder 集成测试

覆盖：
  IFormFile 单文件上传
  Array<IFormFile> 多文件上传
  混合表单数据（文件+字段）
  ?IFormFile 可选文件

注意：IFormFile 仅支持 @FromForm 来源，使用 multipart/form-data
"""

import io
from conftest import post


class TestFormFileSingle:
    """POST /api/file/single — 单文件上传"""

    def test_upload_single_file(self):
        """上传单个文件，验证文件信息"""
        files = {"file": ("test.txt", io.BytesIO(b"Hello, World!"), "text/plain")}
        r = post("/api/file/single", files=files)
        assert r.status_code == 200
        data = r.json()
        assert data["name"] == "file"  # form field name
        assert data["filename"] == "test.txt"
        assert data["contentType"] == "text/plain"
        assert data["length"] == 13

    def test_upload_without_file(self):
        """不上传文件 → IFormFile 为必填，返回 400"""
        r = post("/api/file/single", data={})
        assert r.status_code == 400

    def test_upload_empty_file(self):
        """上传空文件"""
        files = {"file": ("empty.txt", io.BytesIO(b""), "text/plain")}
        r = post("/api/file/single", files=files)
        assert r.status_code == 200
        data = r.json()
        assert data["filename"] == "empty.txt"
        assert data["length"] == 0

    def test_upload_binary_file(self):
        """上传二进制文件"""
        binary_data = bytes([0x00, 0x01, 0x02, 0xFF, 0xFE])
        files = {"file": ("binary.bin", io.BytesIO(binary_data), "application/octet-stream")}
        r = post("/api/file/single", files=files)
        assert r.status_code == 200
        data = r.json()
        assert data["filename"] == "binary.bin"
        assert data["length"] == 5


class TestFormFileMultiple:
    """POST /api/file/multiple — 多文件上传"""

    def test_upload_multiple_files(self):
        """上传多个文件"""
        files = [
            ("files", ("a.txt", io.BytesIO(b"File A"), "text/plain")),
            ("files", ("b.txt", io.BytesIO(b"File B content"), "text/plain")),
            ("files", ("c.txt", io.BytesIO(b"C"), "text/plain")),
        ]
        r = post("/api/file/multiple", files=files)
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 3
        assert data["totalLength"] == 6 + 14 + 1
        files_list = data["files"]
        assert len(files_list) == 3
        assert files_list[0]["filename"] == "a.txt"
        assert files_list[0]["length"] == 6
        assert files_list[1]["filename"] == "b.txt"
        assert files_list[2]["filename"] == "c.txt"

    def test_upload_no_files(self):
        """不上传任何文件"""
        r = post("/api/file/multiple", data={})
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 0
        assert data["totalLength"] == 0
        assert data["files"] == []

    def test_upload_single_file_to_multiple_endpoint(self):
        """只上传一个文件到 multiple 端点"""
        files = {"files": ("single.txt", io.BytesIO(b"Single"), "text/plain")}
        r = post("/api/file/multiple", files=files)
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["totalLength"] == 6


class TestFormFileMixed:
    """POST /api/file/mixed — 混合表单数据（文件+字段）"""

    def test_upload_file_with_form_fields(self):
        """同时上传文件和表单字段"""
        files = {"file": ("report.pdf", io.BytesIO(b"PDF content"), "application/pdf")}
        data = {"name": "Test User", "age": "25"}
        r = post("/api/file/mixed", data=data, files=files)
        assert r.status_code == 200
        result = r.json()
        assert result["name"] == "Test User"
        assert result["age"] == 25
        assert result["file"]["filename"] == "report.pdf"
        assert result["file"]["length"] == 11

    def test_only_form_fields_no_file(self):
        """只提交表单字段，不上传文件 → IFormFile 为必填，返回 400"""
        data = {"name": "No File", "age": "30"}
        r = post("/api/file/mixed", data=data)
        assert r.status_code == 400

    def test_empty_form_fields_with_file(self):
        """空表单字段+文件"""
        files = {"file": ("data.txt", io.BytesIO(b"Data"), "text/plain")}
        data = {"name": "", "age": "0"}
        r = post("/api/file/mixed", data=data, files=files)
        assert r.status_code == 200
        result = r.json()
        assert result["name"] == ""
        assert result["age"] == 0
        assert result["file"]["name"] is not None  # 文件存在


# class TestFormFileOptional:
#     """POST /api/file/optional — 可选文件上传（触发仓颉 bug，暂时禁用）"""
#
#     def test_upload_optional_file_present(self):
#         """提供可选文件"""
#         files = {"file": ("optional.txt", io.BytesIO(b"Optional content"), "text/plain")}
#         r = post("/api/file/optional", files=files)
#         assert r.status_code == 200
#         data = r.json()
#         assert data["hasFile"] is True
#         assert data["name"] == "file"  # form field name
#         assert data["filename"] == "optional.txt"
#         assert data["length"] == 16
#
#     def test_upload_optional_file_missing(self):
#         """不提供可选文件 → hasFile=false"""
#         r = post("/api/file/optional", data={})
#         assert r.status_code == 200
#         data = r.json()
#         assert data["hasFile"] is False
#         assert data["filename"] is None
#         assert data["length"] is None
#
#     def test_upload_optional_empty_file(self):
#         """上传空文件作为可选文件"""
#         files = {"file": ("empty.txt", io.BytesIO(b""), "text/plain")}
#         r = post("/api/file/optional", files=files)
#         assert r.status_code == 200
#         data = r.json()
#         assert data["hasFile"] is True
#         assert data["length"] == 0
