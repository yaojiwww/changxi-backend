#!/usr/bin/env python3
"""
docker-compose 启动入口。

执行顺序：
    1. 拉取或更新 /workspace/spire 仓库
    2. 启动 integration_test_servers 下的全部集成服务
    3. 在模块根目录运行 cjpm test
    4. 运行 integration_test_servers 下的 Python 集成测试
    5. 打印最终报告

说明：
    - 这是一次性脚本，给 docker-compose 直接调用
    - 不接收命令行参数，逻辑尽量写直白
    - 仓库地址和分支通过环境变量 REPO_URL / REPO_BRANCH 控制
    - 跑完后脚本退出，容器也会退出
"""

from __future__ import annotations

import os
import re
import shutil
import signal
import subprocess
import sys
import threading
import time
from collections import deque
from dataclasses import dataclass, field
from pathlib import Path
from urllib.error import URLError
from urllib.request import urlopen


REPO_URL = os.environ.get("REPO_URL", "https://gitcode.com/soulsoft/spire.git")
REPO_BRANCH = os.environ.get("REPO_BRANCH", "dev")
REPO_DIR = Path("/workspace/spire")
SPIRE_PATH = os.environ.get("SPIRE_PATH", "/workspace/spire/")
CJPM_BIN = os.environ.get("CJPM_BIN", "/opt/cangjie/tools/bin/cjpm")
SKIP_CANGJIE_TESTS = os.environ.get("SKIP_CANGJIE_TESTS", "").strip().lower() in {"1", "true", "yes", "on"}
DEFAULT_HOST = "127.0.0.1"
DEFAULT_TEST_SERVER_HOST = f"http://{DEFAULT_HOST}"
HEARTBEAT_INTERVAL_SECONDS = 15
EXCLUDE_DIRS = {
    ".git",
    ".cjpm",
    "build",
    "docker",
    "integration_test_servers",
    "samples",
    "skills",
    "target",
    "__pycache__",
}

ANSI_PATTERN = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
CJPM_SUMMARY_PATTERN = re.compile(
    r"Summary:\s+TOTAL:\s+(?P<total>\d+)\s*"
    r"PASSED:\s+(?P<passed>\d+),\s*SKIPPED:\s+(?P<skipped>\d+),\s*ERROR:\s+(?P<error>\d+)\s*"
    r"FAILED:\s+(?P<failed>\d+)",
    re.MULTILINE,
)
FAILED_CASE_PATTERN = re.compile(r"\[\s*FAILED\s*\]\s*CASE:\s*(?P<name>.+)")
PYTEST_COUNT_PATTERNS = {
    "passed": re.compile(r"(?P<count>\d+)\s+passed"),
    "failed": re.compile(r"(?P<count>\d+)\s+failed"),
    "error": re.compile(r"(?P<count>\d+)\s+error(?:s)?"),
    "skipped": re.compile(r"(?P<count>\d+)\s+skipped"),
}
COLOR_ENABLED = os.environ.get("NO_COLOR") is None
RESET = "\033[0m"
BOLD = "\033[1m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
GRAY = "\033[90m"


@dataclass(frozen=True)
class HealthCheck:
    """单个健康检查配置。"""

    url: str
    expect_status: int = 200
    expect_body: str | None = None


@dataclass(frozen=True)
class ServiceConfig:
    """单个集成服务配置。"""

    module: str
    service: str
    kind: str
    command: tuple[str, ...]
    port_base: int
    health_checks: tuple[HealthCheck, ...]
    health_timeout_seconds: float = 45.0

    @property
    def key(self) -> str:
        return f"{self.module}/{self.service}"


@dataclass
class SummaryCounts:
    """测试计数摘要。"""

    total: int = 0
    passed: int = 0
    failed: int = 0
    error: int = 0
    skipped: int = 0


@dataclass
class ServiceResult:
    """服务启动结果。"""

    key: str
    status: str
    duration_seconds: float
    detail: str = ""


@dataclass(frozen=True)
class GitHeadInfo:
    """仓库当前 HEAD 信息。"""

    commit_id: str
    short_commit_id: str
    committed_at: str
    subject: str


@dataclass
class StepResult:
    """单个测试步骤结果。"""

    label: str
    category: str
    owner: str
    status: str
    duration_seconds: float
    exit_code: int | None = None
    summary: SummaryCounts = field(default_factory=SummaryCounts)
    detail: str = ""
    failure_excerpt: str = ""


@dataclass
class ModuleReport:
    """单个模块最终结果。"""

    module: str
    cangjie: StepResult | None = None
    integration_py: list[StepResult] = field(default_factory=list)

    def overall_status(self) -> str:
        steps = [step for step in [self.cangjie, *self.integration_py] if step is not None]
        if any(step.status == "failed" for step in steps):
            return "failed"
        if any(step.status == "passed" for step in steps):
            return "passed"
        return "skipped"


@dataclass
class RunningService:
    """已启动的服务进程。"""

    config: ServiceConfig
    service_dir: Path
    process: subprocess.Popen[str]
    output_lines: list[str]
    tail_lines: deque[str]
    reader_thread: threading.Thread


SERVICE_CONFIGS: dict[tuple[str, str], ServiceConfig] = {
    ("soulsoft_net_http", "test_server"): ServiceConfig(
        module="soulsoft_net_http",
        service="test_server",
        kind="python",
        command=("server.py", "--host", DEFAULT_HOST, "--port", "15050"),
        port_base=15050,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15050/ping", expect_body="pong"),),
        health_timeout_seconds=10.0,
    ),
    ("soulsoft_web_authentication_jwtbearer", "test_server"): ServiceConfig(
        module="soulsoft_web_authentication_jwtbearer",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--portBase", "15060"),
        port_base=15060,
        health_checks=(
            HealthCheck(url=f"http://{DEFAULT_HOST}:15060/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15061/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15062/health"),
        ),
    ),
    ("soulsoft_web_authorization", "test_server"): ServiceConfig(
        module="soulsoft_web_authorization",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--portBase", "15070"),
        port_base=15070,
        health_checks=(
            HealthCheck(url=f"http://{DEFAULT_HOST}:15070/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15071/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15072/health"),
        ),
    ),
    ("soulsoft_web_cors", "test_server"): ServiceConfig(
        module="soulsoft_web_cors",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--HTTP_PORTS", "15080"),
        port_base=15080,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15080/health"),),
    ),
    ("soulsoft_web_healthchecks", "test_server"): ServiceConfig(
        module="soulsoft_web_healthchecks",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--HTTP_PORTS", "15090"),
        port_base=15090,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15090/healthz/only-healthy"),),
    ),
    ("soulsoft_web_hosting", "test_server"): ServiceConfig(
        module="soulsoft_web_hosting",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--HTTP_PORTS", "15100"),
        port_base=15100,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15100/health"),),
    ),
    ("soulsoft_web_mvc", "test_server"): ServiceConfig(
        module="soulsoft_web_mvc",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--HTTP_PORTS", "15110"),
        port_base=15110,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15110/health"),),
    ),
    ("soulsoft_web_openapi", "test_server"): ServiceConfig(
        module="soulsoft_web_openapi",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--HTTP_PORTS", "15120"),
        port_base=15120,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15120/health"),),
    ),
    ("soulsoft_web_routing", "test_server"): ServiceConfig(
        module="soulsoft_web_routing",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--HTTP_PORTS", "15130"),
        port_base=15130,
        health_checks=(HealthCheck(url=f"http://{DEFAULT_HOST}:15130/health"),),
    ),
    ("soulsoft_web_staticfiles", "test_server"): ServiceConfig(
        module="soulsoft_web_staticfiles",
        service="test_server",
        kind="cjpm",
        command=("run", "--", "--portBase", "15140"),
        port_base=15140,
        health_checks=(
            HealthCheck(url=f"http://{DEFAULT_HOST}:15140/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15141/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15142/health"),
            HealthCheck(url=f"http://{DEFAULT_HOST}:15143/health"),
        ),
    ),
}


def colorize(text: str, color: str, bold: bool = False) -> str:
    """为文本添加 ANSI 颜色。"""

    if not COLOR_ENABLED:
        return text
    prefix = color
    if bold:
        prefix += BOLD
    return f"{prefix}{text}{RESET}"


def highlight_status(status: str) -> str:
    """高亮状态文本。"""

    lowered = status.lower()
    if lowered == "passed" or lowered == "started":
        return colorize(status, GREEN, bold=True)
    if lowered == "failed":
        return colorize(status, RED, bold=True)
    if lowered == "skipped":
        return colorize(status, YELLOW, bold=True)
    return colorize(status, CYAN, bold=True)


def print_step(title: str) -> None:
    """打印高亮阶段标题。"""

    print(colorize(title, CYAN, bold=True), flush=True)


def print_line(text: str = "") -> None:
    """统一输出单行文本。"""

    print(text, flush=True)


def format_progress_prefix(category: str, index: int, total: int) -> str:
    """按位对齐阶段进度前缀。"""

    width = len(str(total))
    return f"[{category} {index:>{width}}/{total}]"


def clean_output(text: str) -> str:
    """去掉 ANSI 控制字符。"""

    return ANSI_PATTERN.sub("", text)


def ensure_cjpm_bin() -> str:
    """确认 cjpm 可执行文件存在。"""

    if Path(CJPM_BIN).is_file():
        return CJPM_BIN
    fallback = shutil.which("cjpm")
    if fallback:
        return fallback
    raise FileNotFoundError(f"未找到 cjpm：{CJPM_BIN}")


def run_command(args: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    """执行普通命令并捕获输出。"""

    print_line(colorize(f"$ {' '.join(args)}", GRAY))
    return subprocess.run(
        args,
        cwd=cwd,
        check=False,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )


def get_repo_head_info() -> GitHeadInfo:
    """读取当前仓库 HEAD 的提交信息。"""

    result = subprocess.run(
        [
            "git",
            "log",
            "-1",
            "--date=iso-strict",
            "--format=%H%n%h%n%cd%n%s",
        ],
        cwd=REPO_DIR,
        check=False,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if result.returncode != 0:
        raise RuntimeError(f"读取仓库提交信息失败：{clean_output(result.stdout).strip()}")

    lines = [line.strip() for line in result.stdout.splitlines()]
    if len(lines) < 4:
        raise RuntimeError("读取仓库提交信息失败：git log 输出不完整")

    return GitHeadInfo(
        commit_id=lines[0],
        short_commit_id=lines[1],
        committed_at=lines[2],
        subject=lines[3],
    )


def sync_repo() -> None:
    """拉取或更新仓库。"""

    if REPO_DIR.exists():
        if not (REPO_DIR / ".git").is_dir():
            raise RuntimeError(f"{REPO_DIR} exists but is not a git repository")

        for command in [
            ["git", "fetch", "origin"],
            ["git", "checkout", REPO_BRANCH],
            ["git", "pull", "--ff-only", "origin", REPO_BRANCH],
        ]:
            result = run_command(command, cwd=REPO_DIR)
            sys.stdout.write(result.stdout)
            if result.returncode != 0:
                raise RuntimeError(f"Command failed: {' '.join(command)}")
        return

    REPO_DIR.parent.mkdir(parents=True, exist_ok=True)
    result = run_command(
        ["git", "clone", "--branch", REPO_BRANCH, "--single-branch", REPO_URL, str(REPO_DIR)]
    )
    sys.stdout.write(result.stdout)
    if result.returncode != 0:
        raise RuntimeError("git clone failed")


def scan_modules() -> list[Path]:
    """扫描一级仓颉模块。"""

    modules: list[Path] = []
    for child in sorted(REPO_DIR.iterdir()):
        if not child.is_dir():
            continue
        if child.name in EXCLUDE_DIRS:
            continue
        if (child / "cjpm.toml").is_file():
            modules.append(child)
    return modules


def discover_service_dirs() -> tuple[list[tuple[ServiceConfig, Path]], list[str]]:
    """扫描全部集成服务目录。"""

    service_root = REPO_DIR / "integration_test_servers"
    if not service_root.is_dir():
        return [], []

    discovered: list[tuple[ServiceConfig, Path]] = []
    unconfigured: list[str] = []

    for module_dir in sorted(path for path in service_root.iterdir() if path.is_dir()):
        for service_dir in sorted(path for path in module_dir.iterdir() if path.is_dir()):
            config = SERVICE_CONFIGS.get((module_dir.name, service_dir.name))
            if config is None:
                unconfigured.append(f"{module_dir.name}/{service_dir.name}")
                continue
            discovered.append((config, service_dir))

    return discovered, unconfigured


def read_stream(stdout, output_lines: list[str], tail_lines: deque[str]) -> None:
    """持续读取子进程输出。"""

    for line in stdout:
        output_lines.append(line)
        tail_lines.append(line.rstrip("\n"))


def tail_text(lines: deque[str] | list[str], max_lines: int = 20) -> str:
    """截取尾部日志。"""

    if not lines:
        return ""
    return clean_output("\n".join(list(lines)[-max_lines:])).strip()


def wait_for_health(running: RunningService, timeout_seconds: float | None = None) -> None:
    """等待服务通过全部健康检查。"""

    timeout = timeout_seconds or running.config.health_timeout_seconds
    deadline = time.time() + timeout
    pending = list(running.config.health_checks)
    last_error: str | None = None

    while time.time() < deadline:
        if running.process.poll() is not None:
            tail = tail_text(running.tail_lines)
            message = "进程在健康检查通过前退出"
            if tail:
                message += f"\n{tail}"
            raise RuntimeError(message)

        remaining: list[HealthCheck] = []
        for check in pending:
            try:
                with urlopen(check.url, timeout=1) as response:
                    body = response.read().decode("utf-8", errors="replace")
                    if response.status != check.expect_status:
                        last_error = f"{check.url} 返回状态码 {response.status}"
                        remaining.append(check)
                        continue
                    if check.expect_body is not None and body != check.expect_body:
                        last_error = f"{check.url} 返回内容不符合预期：{body!r}"
                        remaining.append(check)
                        continue
            except (URLError, OSError, TimeoutError) as exc:
                last_error = f"{check.url} 探活失败：{exc}"
                remaining.append(check)

        if not remaining:
            return

        pending = remaining
        time.sleep(0.3)

    tail = tail_text(running.tail_lines)
    message = last_error or "探活超时"
    if tail:
        message += f"\n{tail}"
    raise RuntimeError(f"{running.config.key} 探活失败（超时 {timeout:.1f}s）：{message}")


def stop_service(running: RunningService) -> None:
    """停止单个服务。"""

    if running.process.poll() is None:
        try:
            os.killpg(running.process.pid, signal.SIGTERM)
            running.process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            os.killpg(running.process.pid, signal.SIGKILL)
            running.process.wait(timeout=10)
        except ProcessLookupError:
            pass

    if running.process.stdout is not None:
        try:
            running.process.stdout.close()
        except OSError:
            pass

    running.reader_thread.join(timeout=1)


class ServiceManager:
    """统一管理集成服务的启动与关闭。"""

    def __init__(self, cjpm_bin: str) -> None:
        self.cjpm_bin = cjpm_bin
        self.running_services: list[RunningService] = []
        self.service_results: list[ServiceResult] = []

    def start_all(self, service_dirs: list[tuple[ServiceConfig, Path]]) -> None:
        """顺序启动全部服务。"""

        total = len(service_dirs)
        for index, (config, service_dir) in enumerate(service_dirs, start=1):
            prefix = format_progress_prefix("service", index, total)
            started_at = time.perf_counter()
            try:
                running = self._start_one(config, service_dir)
                self.running_services.append(running)
                duration = time.perf_counter() - started_at
                self.service_results.append(ServiceResult(config.key, "started", duration))
                print_line(f"{prefix} {config.key} | {highlight_status('started')} | {duration:.2f}s")
            except Exception as exc:
                duration = time.perf_counter() - started_at
                self.service_results.append(ServiceResult(config.key, "failed", duration, str(exc)))
                print_line(f"{prefix} {config.key} | {highlight_status('failed')} | {duration:.2f}s")
                detail = clean_output(str(exc)).strip()
                if detail:
                    print_line(detail)
                raise

    def _start_one(self, config: ServiceConfig, service_dir: Path) -> RunningService:
        """启动单个服务。"""

        env = {**os.environ, "SPIRE_PATH": SPIRE_PATH, "PYTHONUNBUFFERED": "1"}
        if config.kind == "python":
            command = [sys.executable, *config.command]
        else:
            command = [self.cjpm_bin, *config.command]

        process = subprocess.Popen(
            command,
            cwd=service_dir,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            stdin=subprocess.DEVNULL,
            text=True,
            encoding="utf-8",
            errors="replace",
            bufsize=1,
            start_new_session=True,
        )

        assert process.stdout is not None
        output_lines: list[str] = []
        tail_lines: deque[str] = deque(maxlen=200)
        reader_thread = threading.Thread(
            target=read_stream,
            args=(process.stdout, output_lines, tail_lines),
            daemon=True,
        )
        reader_thread.start()

        running = RunningService(config, service_dir, process, output_lines, tail_lines, reader_thread)
        try:
            wait_for_health(running)
        except Exception:
            stop_service(running)
            raise
        return running

    def stop_all(self) -> None:
        """逆序关闭全部服务。"""

        for running in reversed(self.running_services):
            stop_service(running)
        self.running_services.clear()


class CommandRunner:
    """执行测试命令并返回完整输出。"""

    def __init__(self) -> None:
        self.interactive_output = sys.stdout.isatty()

    def run(self, command: list[str], cwd: Path, env: dict[str, str]) -> tuple[int, str]:
        """执行命令并返回退出码和完整输出。"""

        process = subprocess.Popen(
            command,
            cwd=cwd,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            stdin=subprocess.DEVNULL,
            text=True,
            encoding="utf-8",
            errors="replace",
            bufsize=1,
        )

        assert process.stdout is not None
        captured_lines: list[str] = []
        tail_lines: deque[str] = deque(maxlen=200)
        reader = threading.Thread(
            target=read_stream,
            args=(process.stdout, captured_lines, tail_lines),
            daemon=True,
        )
        reader.start()

        exit_code = process.wait()
        reader.join()
        return exit_code, "".join(captured_lines)


class TestOrchestrator:
    """按阶段运行全部测试。"""

    def __init__(self, modules: list[Path], service_dirs: list[tuple[ServiceConfig, Path]], cjpm_bin: str) -> None:
        self.modules = modules
        self.service_dirs = service_dirs
        self.cjpm_bin = cjpm_bin
        self.command_runner = CommandRunner()
        self.module_reports = {module_dir.name: ModuleReport(module=module_dir.name) for module_dir in modules}
        self.step_results: list[StepResult] = []

    def run_all(self) -> None:
        """按顺序运行所有测试阶段。"""

        if SKIP_CANGJIE_TESTS:
            print_line()
            print_step("=== Step 3/5: Skip Cangjie Tests ===")
            for module_dir in self.modules:
                result = StepResult(
                    label=module_dir.name,
                    category="cangjie",
                    owner=module_dir.name,
                    status="skipped",
                    duration_seconds=0.0,
                    detail="SKIP_CANGJIE_TESTS is enabled",
                )
                self.module_reports[module_dir.name].cangjie = result
                self.step_results.append(result)
                print_line(f"[cangjie] {module_dir.name} | {highlight_status('skipped')} | {result.detail}")
        else:
            self._run_cangjie_tests()
        self._run_python_integration_tests()

    def _run_cangjie_tests(self) -> None:
        """在每个模块根目录运行 cjpm test。"""

        print_line()
        print_step("=== Step 3/5: Run Cangjie Tests ===")
        total = len(self.modules)
        for index, module_dir in enumerate(self.modules, start=1):
            result = self._run_cjpm_step(module_dir, format_progress_prefix("cangjie", index, total))
            self.module_reports[module_dir.name].cangjie = result
            self.step_results.append(result)

    def _run_cjpm_step(self, module_dir: Path, prefix: str) -> StepResult:
        """在模块根目录运行 cjpm test。"""

        module_name = module_dir.name
        started_at = time.perf_counter()
        exit_code, output = self.command_runner.run(
            command=[self.cjpm_bin, "test"],
            cwd=module_dir,
            env={**os.environ, "SPIRE_PATH": SPIRE_PATH},
        )
        duration = time.perf_counter() - started_at
        summary = parse_cjpm_summary(output)
        status = "passed" if exit_code == 0 else "failed"
        failure_excerpt = build_failure_excerpt(output) if status == "failed" else ""
        print_line(
            f"{prefix} {module_name} | {highlight_status(status)} | {duration:.2f}s | "
            f"passed={summary.passed} failed={summary.failed} error={summary.error} skipped={summary.skipped}"
        )
        return StepResult(
            label=module_name,
            category="cangjie",
            owner=module_name,
            status=status,
            duration_seconds=duration,
            exit_code=exit_code,
            summary=summary,
            failure_excerpt=failure_excerpt,
        )

    def _run_python_integration_tests(self) -> None:
        """运行全部 Python 集成测试。"""

        runnable_services = [
            (config, service_dir)
            for config, service_dir in self.service_dirs
            if self._has_python_tests(service_dir)
        ]

        print_line()
        print_step("=== Step 4/5: Run Python Integration Tests ===")
        total = len(runnable_services)
        for index, (config, service_dir) in enumerate(runnable_services, start=1):
            result = self._run_pytest_step(config, service_dir, format_progress_prefix("integration-py", index, total))
            self.module_reports.setdefault(config.module, ModuleReport(module=config.module)).integration_py.append(result)
            self.step_results.append(result)

    def _has_python_tests(self, service_dir: Path) -> bool:
        """判断服务目录下是否存在 Python 集成测试。"""

        tests_dir = service_dir / "tests"
        return tests_dir.is_dir() and any(tests_dir.rglob("test_*.py"))

    def _run_pytest_step(self, config: ServiceConfig, service_dir: Path, prefix: str) -> StepResult:
        """运行 integration_test_servers 下单个服务目录的 Python 集成测试。"""

        tests_dir = service_dir / "tests"
        label = f"{config.module}/{config.service}"

        started_at = time.perf_counter()
        exit_code, output = self.command_runner.run(
            command=[sys.executable, "-m", "pytest", "-v", "tests"],
            cwd=service_dir,
            env={
                **os.environ,
                "SPIRE_PATH": SPIRE_PATH,
                "TEST_SERVER_HOST": DEFAULT_TEST_SERVER_HOST,
                "TEST_SERVER_PORT_BASE": str(config.port_base),
                "PYTHONUNBUFFERED": "1",
            },
        )
        duration = time.perf_counter() - started_at
        summary = parse_pytest_summary(output)
        status = "passed" if exit_code == 0 else "failed"
        failure_excerpt = build_failure_excerpt(output) if status == "failed" else ""
        print_line(
            f"{prefix} {label} | {highlight_status(status)} | {duration:.2f}s | "
            f"passed={summary.passed} failed={summary.failed} error={summary.error} skipped={summary.skipped}"
        )
        return StepResult(
            label=label,
            category="integration-py",
            owner=config.module,
            status=status,
            duration_seconds=duration,
            exit_code=exit_code,
            summary=summary,
            failure_excerpt=failure_excerpt,
        )


def parse_cjpm_summary(output: str) -> SummaryCounts:
    """从 cjpm 输出中提取摘要。"""

    cleaned = clean_output(output)
    matches = list(CJPM_SUMMARY_PATTERN.finditer(cleaned))
    if not matches:
        return SummaryCounts()

    match = matches[-1]
    return SummaryCounts(
        total=int(match.group("total")),
        passed=int(match.group("passed")),
        failed=int(match.group("failed")),
        error=int(match.group("error")),
        skipped=int(match.group("skipped")),
    )


def parse_pytest_summary(output: str) -> SummaryCounts:
    """从 pytest 输出中提取摘要。"""

    cleaned = clean_output(output)
    counts = SummaryCounts()
    for name, pattern in PYTEST_COUNT_PATTERNS.items():
        values = [int(match.group("count")) for match in pattern.finditer(cleaned)]
        if values:
            setattr(counts, name, values[-1])
    counts.total = counts.passed + counts.failed + counts.error + counts.skipped
    return counts


def build_failure_excerpt(output: str, max_lines: int = 20) -> str:
    """从失败输出中提取高价值片段。"""

    cleaned = clean_output(output)
    lines = [line.rstrip() for line in cleaned.splitlines() if line.strip()]
    if not lines:
        return ""

    failed_case_indexes = [index for index, line in enumerate(lines) if FAILED_CASE_PATTERN.search(line)]
    if failed_case_indexes:
        excerpts: list[str] = []
        for failed_index in failed_case_indexes:
            start = max(0, failed_index - 3)
            end = min(len(lines), failed_index + 6)
            excerpts.extend(lines[start:end])
            excerpts.append("")
        return "\n".join(excerpts).strip()

    important_lines = [
        line for line in lines
        if "[ FAILED ]" in line
        or "FAILED" in line
        or "Error:" in line
        or "Exception" in line
        or "Traceback" in line
        or line.startswith("E   ")
        or "AssertionError" in line
    ]
    if important_lines:
        return "\n".join(important_lines[-max_lines:])
    return "\n".join(lines[-max_lines:])


def merge_python_status(results: list[StepResult]) -> str:
    """聚合一个模块下的 Python 测试状态。"""

    if not results:
        return "skipped"
    if any(item.status == "failed" for item in results):
        return "failed"
    if any(item.status == "passed" for item in results):
        return "passed"
    return "skipped"


def print_final_report(
    modules: list[Path],
    service_results: list[ServiceResult],
    step_results: list[StepResult],
    module_reports: dict[str, ModuleReport],
    head_info: GitHeadInfo,
) -> None:
    """打印最终报告。"""

    started_services = [item for item in service_results if item.status == "started"]
    failed_services = [item for item in service_results if item.status == "failed"]
    module_items = [module_reports[name] for name in sorted(module_reports)]
    passed_modules = [item for item in module_items if item.overall_status() == "passed"]
    failed_modules = [item for item in module_items if item.overall_status() == "failed"]
    skipped_modules = [item for item in module_items if item.overall_status() == "skipped"]
    cj_results = [item for item in step_results if item.category == "cangjie"]
    py_results = [item for item in step_results if item.category == "integration-py"]

    def status_counts(items: list[StepResult]) -> dict[str, int]:
        counts = {"passed": 0, "failed": 0, "skipped": 0}
        for item in items:
            counts[item.status] = counts.get(item.status, 0) + 1
        return counts

    cj_counts = status_counts(cj_results)
    py_counts = status_counts(py_results)

    print_line()
    print_step("=== Final Report ===")
    print_line(f"Root: {colorize(str(REPO_DIR), CYAN, bold=True)}")
    print_line(f"Repo branch: {colorize(REPO_BRANCH, YELLOW, bold=True)}")
    print_line(f"Repo commit: {colorize(head_info.short_commit_id, GREEN, bold=True)} ({head_info.commit_id})")
    print_line(f"Commit time: {colorize(head_info.committed_at, CYAN, bold=True)}")
    print_line(f"Commit subject: {head_info.subject}")
    print_line(f"Modules tracked: {colorize(str(len(modules)), CYAN, bold=True)}")
    print_line(f"Services started: {colorize(str(len(started_services)), GREEN, bold=True)}")
    print_line(f"Service startup failures: {colorize(str(len(failed_services)), RED if failed_services else GREEN, bold=True)}")
    print_line(f"Passed modules: {colorize(str(len(passed_modules)), GREEN, bold=True)}")
    print_line(f"Failed modules: {colorize(str(len(failed_modules)), RED if failed_modules else GREEN, bold=True)}")
    print_line(f"Skipped modules: {colorize(str(len(skipped_modules)), YELLOW, bold=True)}")
    print_line()
    print_line("Phase Summary:")
    print_line(f"  - cangjie: passed={cj_counts.get('passed', 0)} failed={cj_counts.get('failed', 0)} skipped={cj_counts.get('skipped', 0)}")
    print_line(f"  - integration-py: passed={py_counts.get('passed', 0)} failed={py_counts.get('failed', 0)} skipped={py_counts.get('skipped', 0)}")
    print_line()
    print_line("Module Results:")
    for report in module_items:
        cj_status = report.cangjie.status if report.cangjie else "skipped"
        py_status = merge_python_status(report.integration_py)
        print_line(
            f"  - {report.module}: overall={highlight_status(report.overall_status())} | "
            f"cangjie={highlight_status(cj_status)} | integration-py={highlight_status(py_status)}"
        )

    if failed_services:
        print_line()
        print_line("Service Failure Details:")
        for item in failed_services:
            print_line(f"  - {item.key} | {item.detail}")

    failed_steps = [item for item in step_results if item.status == "failed"]
    if failed_steps:
        print_line()
        print_line("Test Failure Details:")
        for item in failed_steps:
            print_line(f"  - {item.label} [{item.category}]")
            if item.failure_excerpt:
                for line in item.failure_excerpt.splitlines():
                    print_line(f"    {line}")
            elif item.detail:
                print_line(f"    {item.detail}")


def main() -> int:
    """脚本入口。"""

    print_step("=== Step 1/5: Sync Repository ===")
    print_line(f"REPO_URL: {colorize(REPO_URL, GREEN, bold=True)}")
    print_line(f"REPO_BRANCH: {colorize(REPO_BRANCH, YELLOW, bold=True)}")
    print_line(f"SPIRE_PATH: {colorize(SPIRE_PATH, CYAN, bold=True)}")
    print_line(f"SKIP_CANGJIE_TESTS: {colorize(str(SKIP_CANGJIE_TESTS).lower(), YELLOW if SKIP_CANGJIE_TESTS else GREEN, bold=True)}")

    cjpm_bin = ensure_cjpm_bin()

    try:
        sync_repo()
        head_info = get_repo_head_info()
        print_line(f"REPO_HEAD: {colorize(head_info.short_commit_id, GREEN, bold=True)}")
        print_line(f"REPO_HEAD_TIME: {colorize(head_info.committed_at, CYAN, bold=True)}")
        print_line(f"REPO_HEAD_SUBJECT: {head_info.subject}")
        modules = scan_modules()
        if not modules:
            print(f"未扫描到仓颉模块：{REPO_DIR}", file=sys.stderr)
            return 1

        service_dirs, unconfigured = discover_service_dirs()
        if unconfigured:
            print("发现未配置的集成服务，无法继续执行：", file=sys.stderr)
            for item in unconfigured:
                print(f"  - {item}", file=sys.stderr)
            return 1

        print_line()
        print_step("=== Step 2/5: Start Integration Services ===")
        service_manager = ServiceManager(cjpm_bin)
        orchestrator = TestOrchestrator(modules, service_dirs, cjpm_bin)

        exit_code = 0
        try:
            service_manager.start_all(service_dirs)
            orchestrator.run_all()

            print_line()
            print_step("=== Step 5/5: Final Report ===")
            print_final_report(
                modules,
                service_manager.service_results,
                orchestrator.step_results,
                orchestrator.module_reports,
                head_info,
            )
            if any(item.status == "failed" for item in orchestrator.step_results):
                exit_code = 1
            return exit_code
        finally:
            service_manager.stop_all()
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
