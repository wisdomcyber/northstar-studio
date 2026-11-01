import json
import mimetypes
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote


PORT = int(os.environ.get("PORT", "8080"))
PUBLIC_DIR = Path(__file__).resolve().parent / "public"


def normalize_path(path):
    return unquote(path.split("?", 1)[0]).lstrip("/")


def json_response(handler, status, payload):
    body = json.dumps(payload).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(body)))
    handler.send_header("Cache-Control", "no-store")
    handler.end_headers()
    handler.wfile.write(body)


class Handler(BaseHTTPRequestHandler):
    server_version = "HostableSite/1.0"

    def do_GET(self):
        if normalize_path(self.path) == "health":
            json_response(self, 200, {"status": "ok"})
            return

        requested = normalize_path(self.path)
        if requested == "":
            requested = "index.html"

        file_path = (PUBLIC_DIR / requested).resolve()
        if file_path.is_dir():
            index_path = file_path / "index.html"
            if index_path.is_file():
                file_path = index_path
            else:
                json_response(self, 404, {"error": "Not found"})
                return

        if PUBLIC_DIR.resolve() not in file_path.parents and file_path != PUBLIC_DIR.resolve():
            json_response(self, 403, {"error": "Forbidden"})
            return
        if not file_path.is_file():
            json_response(self, 404, {"error": "Not found"})
            return

        content = file_path.read_bytes()
        content_type = mimetypes.guess_type(file_path.name)[0] or "application/octet-stream"
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.send_header("Cache-Control", "public, max-age=300")
        self.end_headers()
        self.wfile.write(content)

    def log_message(self, format, *args):
        print("%s - %s" % (self.address_string(), format % args))


if __name__ == "__main__":
    print(f"Listening on 0.0.0.0:{PORT}")
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
