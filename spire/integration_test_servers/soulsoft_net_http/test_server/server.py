#!/usr/bin/env python3
import argparse
import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse


def json_bytes(value):
    return json.dumps(value, ensure_ascii=False).encode("utf-8")


def parse_header_params(header_value):
    params = {}
    for segment in header_value.split(";")[1:]:
        part = segment.strip()
        if "=" not in part:
            continue
        key, value = part.split("=", 1)
        params[key.strip().lower()] = value.strip().strip('"')
    return params


def collect_headers(message):
    result = {}
    seen = set()
    for key in message.keys():
        lower_key = key.lower()
        if lower_key in seen:
            continue
        seen.add(lower_key)
        values = message.get_all(key) or []
        normalized_key = "-".join(segment[:1].upper() + segment[1:].lower() for segment in lower_key.split("-"))
        result[normalized_key] = ", ".join(values)
    return result


def parse_multipart_form_data(body, content_type):
    boundary = parse_header_params(content_type).get("boundary")
    if not boundary:
        return [], {}

    delimiter = f"--{boundary}".encode("utf-8")
    files = []
    fields = {}

    for raw_part in body.split(delimiter):
        part = raw_part.strip()
        if not part or part == b"--":
            continue
        if part.endswith(b"--"):
            part = part[:-2].rstrip()
        if not part:
            continue

        header_block, separator, content = part.partition(b"\r\n\r\n")
        if not separator:
            continue

        headers = {}
        for header_line in header_block.decode("utf-8", errors="replace").split("\r\n"):
            if ":" not in header_line:
                continue
            key, value = header_line.split(":", 1)
            headers[key.strip().lower()] = value.strip()

        disposition = headers.get("content-disposition", "")
        disposition_params = parse_header_params(disposition)
        field_name = disposition_params.get("name", "")
        file_name = disposition_params.get("filename")
        payload = content.rstrip(b"\r\n")

        if file_name is not None:
            files.append(
                {
                    "name": field_name,
                    "fileName": file_name,
                    "size": len(payload),
                    "contentType": headers.get("content-type", "application/octet-stream"),
                }
            )
        elif field_name:
            fields[field_name] = payload.decode("utf-8", errors="replace")

    return files, fields


class TestRequestHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.0"

    def log_message(self, fmt, *args):
        return

    def _send_bytes(self, status, body=b"", content_type="text/plain; charset=utf-8", extra_headers=None):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        if extra_headers:
            for key, value in extra_headers.items():
                self.send_header(key, value)
        self.end_headers()
        if body:
            self.wfile.write(body)
            self.wfile.flush()
        self.close_connection = True

    def _send_text(self, status, text="", content_type="text/plain; charset=utf-8", extra_headers=None):
        self._send_bytes(status, text.encode("utf-8"), content_type, extra_headers)

    def _send_json(self, status, value, extra_headers=None):
        self._send_bytes(status, json_bytes(value), "application/json; charset=utf-8", extra_headers)

    def _read_body(self):
        content_length = int(self.headers.get("Content-Length", "0"))
        if content_length <= 0:
            return b""
        return self.rfile.read(content_length)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/ping":
            self._send_text(200, "pong")
            return

        if path.startswith("/status/"):
            code_text = path.removeprefix("/status/")
            try:
                code = int(code_text)
            except ValueError:
                self._send_text(400, "invalid status code")
                return
            self._send_bytes(code, b"", "text/plain; charset=utf-8")
            return

        if path == "/echo-headers":
            self._send_json(200, collect_headers(self.headers))
            return

        if path == "/sse/events":
            query = parse_qs(parsed.query)
            count = int(query.get("count", ["3"])[0])
            interval = int(query.get("interval", ["100"])[0])

            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream; charset=utf-8")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.flush()

            for i in range(1, count + 1):
                event = f"id: {i}\ndata: event-{i}\n\n".encode("utf-8")
                self.wfile.write(event)
                self.wfile.flush()
                if i < count:
                    time.sleep(interval / 1000.0)
            self.close_connection = True
            return

        if path == "/content/json":
            self._send_json(200, {"type": "json", "value": 42})
            return

        if path == "/content/xml":
            self._send_text(
                200,
                "<?xml version=\"1.0\"?><root><type>xml</type><value>42</value></root>",
                "text/xml; charset=utf-8",
            )
            return

        if path == "/content/html":
            self._send_text(
                200,
                "<html><body><p>html content</p></body></html>",
                "text/html; charset=utf-8",
            )
            return

        if path == "/content/binary":
            self._send_bytes(200, bytes([0x01, 0x02, 0x03, 0xFF]), "application/octet-stream")
            return

        if path == "/content/csv":
            self._send_text(200, "id,name,value\n1,test,42\n", "text/csv; charset=utf-8")
            return

        self._send_text(404, "not found")

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/echo-body":
            body = self._read_body()
            content_type = self.headers.get("Content-Type", "text/plain")
            self._send_bytes(200, body, content_type)
            return

        if path == "/echo-content-type":
            self._send_text(200, self.headers.get("Content-Type", ""))
            return

        if path == "/upload":
            if not self.headers.get("Content-Type", "").startswith("multipart/form-data"):
                self._send_json(400, {"error": "Expected multipart/form-data"})
                return

            body = self._read_body()
            files, fields = parse_multipart_form_data(body, self.headers.get("Content-Type", ""))
            self._send_json(200, {"files": files, "fields": fields})
            return

        self._send_text(404, "not found")

    def do_PUT(self):
        parsed = urlparse(self.path)
        if parsed.path == "/echo-body":
            body = self._read_body()
            self._send_bytes(200, body, "text/plain; charset=utf-8")
            return
        self._send_text(404, "not found")

    def do_DELETE(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith("/resource/"):
            self._send_bytes(204, b"", "text/plain; charset=utf-8")
            return
        self._send_text(404, "not found")


class ReusableThreadingHTTPServer(ThreadingHTTPServer):
    allow_reuse_address = True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=15050)
    args = parser.parse_args()

    server = ReusableThreadingHTTPServer((args.host, args.port), TestRequestHandler)
    print(f"Starting TestServer on http://{args.host}:{args.port} ...")
    print("Press Ctrl+C to stop.")
    print()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
