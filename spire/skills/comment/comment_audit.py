#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


SKIP_DIR_NAMES = {
    ".git",
    ".idea",
    ".vscode",
    ".pytest_cache",
    "build",
    "dist",
    "out",
    "target",
    "node_modules",
    "__pycache__",
    "tests",
    "test",
    "unittests",
    "testdata",
    "fixtures",
    "fixture",
    "mock",
    "mocks",
    "samples",
    "sample",
    "benchmark",
    "benchmarks",
    "fuzz",
    "generated",
    "gen",
}

SKIP_PATH_PARTS = {
    "test_server",
    "tests",
    "test",
    "unittests",
    "samples",
    "sample",
    "mock",
    "mocks",
    "benchmark",
    "benchmarks",
    "fuzz",
    "fixture",
    "fixtures",
    "testdata",
    "generated",
    "gen",
    "build",
}

SKIP_FILE_PATTERNS = (
    re.compile(r"(^|[_-])test([_-]|$)", re.IGNORECASE),
    re.compile(r"(^|[_-])mock([_-]|$)", re.IGNORECASE),
    re.compile(r"(^|[_-])benchmark([_-]|$)", re.IGNORECASE),
    re.compile(r"(^|[_-])fuzz([_-]|$)", re.IGNORECASE),
    re.compile(r"(^|[_-])fixture([_-]|$)", re.IGNORECASE),
    re.compile(r"(^|[_-])helper([_-]|$)", re.IGNORECASE),
    re.compile(r"generated", re.IGNORECASE),
)

ANNOTATION_RE = re.compile(r"^\s*@[\w`]")
TAG_RE = re.compile(r"@(\w+)\b")
PARAM_TAG_RE = re.compile(r"@param\s+([A-Za-z_`][\w`]*)")

TYPE_DECL_RE = re.compile(
    r"^(?:(public|private|protected|internal)\s+)?((?:open|abstract)\s+)?(class|struct|enum|interface|type)\s+([^\s<:{(]+)"
)
EXTEND_DECL_RE = re.compile(r"^extend\s+([^\s<:{(]+)")
FUNC_DECL_RE = re.compile(
    r"^(?:(public|protected)\s+)?(?:(open)\s+)?(?:(static)\s+)?func\s+([^\s<(]+)\s*\("
)
INIT_DECL_RE = re.compile(r"^(?:(public|protected)\s+)?(?:(const)\s+)?init\s*\(")
PROP_DECL_RE = re.compile(r"^(?:(public|protected)\s+)?(?:(open)\s+)?prop\s+([^\s:={]+)\s*:")
LET_VAR_DECL_RE = re.compile(r"^(?:(public)\s+)?(let|var)\s+([^\s:=,]+)")
INTERFACE_MEMBER_RE = re.compile(r"^(?:(const)\s+)?init\s*\(|^(?:(static)\s+)?func\s+([^\s<(]+)\s*\(|^prop\s+([^\s:={]+)\s*:|^(let|var)\s+([^\s:=,]+)")
NAMED_INIT_RE = re.compile(r"^(?:(public|private|protected|internal)\s+)?([^\s(]+)\s*\(")
ENUM_MEMBER_RE = re.compile(r"^\|?\s*([^\s(=,{|]+)")
IDENTIFIER_RE = re.compile(r"^[A-Za-z_`][\w`]*[!?]?$")
ENUM_MEMBER_KEYWORDS = {
    "public",
    "private",
    "protected",
    "internal",
    "open",
    "abstract",
    "static",
    "func",
    "prop",
    "let",
    "var",
    "init",
    "operator",
    "override",
    "redef",
    "const",
    "mut",
    "class",
    "struct",
    "enum",
    "interface",
    "type",
    "extend",
}


@dataclass
class DocBlock:
    start: int
    end: int
    text: str

    @property
    def tags(self) -> set[str]:
        return {match.group(1) for match in TAG_RE.finditer(self.text)}

    @property
    def param_names(self) -> set[str]:
        return {normalize_identifier(match.group(1)) for match in PARAM_TAG_RE.finditer(self.text)}


@dataclass
class PlainBlockComment:
    start: int
    end: int
    text: str


@dataclass
class Scope:
    kind: str
    name: str
    parent: "Scope | None"
    declaration: "Declaration | None"
    is_public_type: bool = False
    is_interface: bool = False
    is_open_or_abstract_class: bool = False
    opened: bool = False
    closed: bool = False


@dataclass
class Declaration:
    path: Path
    line: int
    end_line: int
    open_brace_line: int | None
    kind: str
    name: str
    signature: str
    raw_signature: str
    visibility: str | None
    is_open: bool = False
    is_static: bool = False
    is_const: bool = False
    parent_scope: Scope | None = None
    scope: Scope | None = None
    params: list[str] = field(default_factory=list)
    return_type: str | None = None
    comment: DocBlock | None = None
    has_annotation: bool = False
    misplaced_comment_under_annotation: bool = False
    redundant_non_doc_comment_before_doc: bool = False

    @property
    def is_function_like(self) -> bool:
        return self.kind in {"func", "init", "interface-func", "interface-init"}

    @property
    def requires_return_tag(self) -> bool:
        if self.kind in {"prop", "interface-prop"}:
            return True
        if self.kind in {"func", "interface-func"}:
            return self.return_type is not None and normalize_type_name(self.return_type) != "Unit"
        return False

    @property
    def needs_explicit_return_type(self) -> bool:
        return self.kind in {"func", "interface-func"} and self.return_type is None

    @property
    def display_kind(self) -> str:
        mapping = {
            "class": "class",
            "struct": "struct",
            "enum": "enum",
            "enum-member": "enum-member",
            "interface": "interface",
            "type": "type",
            "func": "func",
            "init": "init",
            "prop": "prop",
            "let": "let",
            "var": "var",
            "interface-func": "func",
            "interface-init": "init",
            "interface-prop": "prop",
            "interface-let": "let",
            "interface-var": "var",
        }
        return mapping.get(self.kind, self.kind)


@dataclass
class Issue:
    path: Path
    line: int
    code: str
    message: str
    declaration: Declaration

    def to_dict(self, root: Path) -> dict[str, object]:
        return {
            "path": str(self.path.relative_to(root)),
            "line": self.line,
            "code": self.code,
            "message": self.message,
            "kind": self.declaration.display_kind,
            "name": self.declaration.name,
            "signature": self.declaration.raw_signature,
        }


def normalize_identifier(name: str) -> str:
    normalized = name.strip().rstrip("!").rstrip("?")
    return normalized.strip("`")


def normalize_type_name(name: str) -> str:
    return re.sub(r"\s+", "", name.strip())


def should_skip_path(path: Path, root: Path) -> bool:
    rel_parts = [part.lower() for part in path.relative_to(root).parts]
    if any(part in SKIP_PATH_PARTS for part in rel_parts[:-1]):
        return True
    stem = path.stem.lower()
    if any(pattern.search(stem) for pattern in SKIP_FILE_PATTERNS):
        return True
    return False


def collapse_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def strip_comments_and_strings(lines: list[str]) -> list[str]:
    result: list[str] = []
    in_block_comment = False
    for line in lines:
        i = 0
        out: list[str] = []
        in_string = False
        string_quote = ""
        while i < len(line):
            ch = line[i]
            nxt = line[i : i + 2]
            if in_block_comment:
                if nxt == "*/":
                    in_block_comment = False
                    i += 2
                else:
                    i += 1
                continue
            if in_string:
                if ch == "\\":
                    i += 2
                    continue
                if ch == string_quote:
                    in_string = False
                i += 1
                continue
            if nxt == "//":
                break
            if nxt == "/*":
                in_block_comment = True
                i += 2
                continue
            if ch in {'"', "'"}:
                in_string = True
                string_quote = ch
                i += 1
                continue
            out.append(ch)
            i += 1
        result.append("".join(out))
    return result


def find_doc_blocks(lines: list[str]) -> tuple[list[DocBlock], dict[int, DocBlock]]:
    blocks: list[DocBlock] = []
    end_map: dict[int, DocBlock] = {}
    i = 0
    while i < len(lines):
        if "/**" not in lines[i]:
            i += 1
            continue
        start = i
        text_parts = [lines[i]]
        while i < len(lines):
            if "*/" in lines[i]:
                break
            i += 1
            if i < len(lines):
                text_parts.append(lines[i])
        if i >= len(lines):
            break
        block = DocBlock(start=start, end=i, text="\n".join(text_parts))
        blocks.append(block)
        end_map[i] = block
        i += 1
    return blocks, end_map


def find_plain_block_comments(lines: list[str]) -> tuple[list[PlainBlockComment], dict[int, PlainBlockComment]]:
    blocks: list[PlainBlockComment] = []
    end_map: dict[int, PlainBlockComment] = {}
    i = 0
    while i < len(lines):
        line = lines[i]
        start_at = line.find("/*")
        if start_at < 0 or line[start_at : start_at + 3] == "/**":
            i += 1
            continue
        start = i
        text_parts = [line]
        while i < len(lines):
            if "*/" in lines[i]:
                break
            i += 1
            if i < len(lines):
                text_parts.append(lines[i])
        if i >= len(lines):
            break
        block = PlainBlockComment(start=start, end=i, text="\n".join(text_parts))
        blocks.append(block)
        end_map[i] = block
        i += 1
    return blocks, end_map


def is_annotation_line(line: str) -> bool:
    return bool(ANNOTATION_RE.match(line))


def is_blank(line: str) -> bool:
    return not line.strip()


def split_top_level(text: str, separator: str = ",") -> list[str]:
    parts: list[str] = []
    current: list[str] = []
    paren = bracket = brace = angle = 0
    for ch in text:
        if ch == "(":
            paren += 1
        elif ch == ")":
            paren = max(paren - 1, 0)
        elif ch == "[":
            bracket += 1
        elif ch == "]":
            bracket = max(bracket - 1, 0)
        elif ch == "{":
            brace += 1
        elif ch == "}":
            brace = max(brace - 1, 0)
        elif ch == "<":
            angle += 1
        elif ch == ">":
            angle = max(angle - 1, 0)
        if ch == separator and paren == bracket == brace == angle == 0:
            item = "".join(current).strip()
            if item:
                parts.append(item)
            current = []
            continue
        current.append(ch)
    tail = "".join(current).strip()
    if tail:
        parts.append(tail)
    return parts


def extract_parenthesized_text(signature: str) -> tuple[str, int] | None:
    start = signature.find("(")
    if start < 0:
        return None
    depth = 0
    for index in range(start, len(signature)):
        ch = signature[index]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return signature[start + 1 : index], index
    return None


def parse_param_names(signature: str) -> list[str]:
    extracted = extract_parenthesized_text(signature)
    if extracted is None:
        return []
    params_text, _ = extracted
    params: list[str] = []
    for item in split_top_level(params_text):
        head = item.split(":", 1)[0].strip()
        if not head:
            continue
        head = re.sub(r"\b(public|private|protected|let|var|const|mut|inout)\b", " ", head)
        name = normalize_identifier(head.split()[-1])
        if name:
            params.append(name)
    return params


def parse_enum_member_param_names(signature: str) -> list[str]:
    extracted = extract_parenthesized_text(signature)
    if extracted is None:
        return []
    params_text, _ = extracted
    params: list[str] = []
    for item in split_top_level(params_text):
        if ":" not in item:
            continue
        head = item.split(":", 1)[0].strip()
        if not head:
            continue
        head = re.sub(r"\b(public|private|protected|let|var|const|mut|inout)\b", " ", head)
        name = normalize_identifier(head.split()[-1])
        if name:
            params.append(name)
    return params


def is_enum_member_signature(line: str) -> bool:
    stripped = line.strip()
    match = ENUM_MEMBER_RE.match(stripped)
    if not match:
        return False
    name = normalize_identifier(match.group(1))
    if not name or name in ENUM_MEMBER_KEYWORDS or not IDENTIFIER_RE.match(name):
        return False
    return True


def parse_return_type(signature: str) -> str | None:
    extracted = extract_parenthesized_text(signature)
    if extracted is None:
        return None
    _, end_index = extracted
    tail = signature[end_index + 1 :].strip()
    if not tail.startswith(":"):
        return None
    tail = tail[1:].strip()
    tail = re.split(r"\s+\bwhere\b", tail, maxsplit=1)[0]
    tail = tail.split("{", 1)[0].split("=", 1)[0].strip()
    return tail or None


def collect_signature(start: int, sanitized_lines: list[str], raw_lines: list[str], kind: str) -> tuple[int, str, str, int | None]:
    pieces: list[str] = []
    raw_pieces: list[str] = []
    paren_depth = 0
    open_brace_line: int | None = None
    end = start
    for index in range(start, len(sanitized_lines)):
        part = sanitized_lines[index].strip()
        raw_part = raw_lines[index].strip()
        if not part and not pieces:
            continue
        pieces.append(part)
        raw_pieces.append(raw_part)
        paren_depth += part.count("(") - part.count(")")
        if open_brace_line is None and "{" in part:
            open_brace_line = index
        signature = collapse_whitespace(" ".join(pieces))
        tail = part.rstrip()
        if kind in {"class", "struct", "enum", "interface", "type", "extend"}:
            if "{" in signature and paren_depth <= 0:
                end = index
                break
        elif kind in {"func", "interface-func", "init", "interface-init", "named-init"}:
            if paren_depth > 0:
                continue
            if tail.endswith(",") or re.search(r"\bwhere\s*$", tail):
                continue
            if "{" in signature or tail.endswith(")") or ":" in signature[signature.rfind(")") :]:
                end = index
                break
        elif kind in {"prop", "interface-prop"}:
            if "{" in signature or re.search(r"\bprop\b.+:\s*.+$", signature):
                end = index
                break
        elif kind in {"let", "var", "interface-let", "interface-var"}:
            if tail.endswith(",") or tail.endswith("="):
                continue
            end = index
            break
        elif kind == "enum-member":
            if paren_depth > 0:
                continue
            end = index
            break
    return end, collapse_whitespace(" ".join(pieces)), collapse_whitespace(" ".join(raw_pieces)), open_brace_line


def match_declaration_kind(line: str, current_scope: Scope | None) -> str | None:
    return match_declaration_kind_at_depth(line, current_scope, None)


def match_declaration_kind_at_depth(line: str, current_scope: Scope | None, current_brace_depth: int | None) -> str | None:
    stripped = line.strip()
    if not stripped:
        return None
    immediate_scope = (
        current_scope is not None
        and current_brace_depth is not None
        and current_brace_depth == getattr(current_scope, "brace_depth", current_brace_depth)
    )
    if TYPE_DECL_RE.match(stripped):
        return TYPE_DECL_RE.match(stripped).group(3)
    if EXTEND_DECL_RE.match(stripped):
        return "extend"
    if current_scope and current_scope.kind in {"class", "struct", "enum", "interface", "type"} and not current_scope.is_public_type:
        return None
    if current_scope and current_scope.kind in {"class", "struct"} and immediate_scope:
        match = NAMED_INIT_RE.match(stripped)
        if match and normalize_identifier(match.group(2)) == normalize_identifier(current_scope.name):
            visibility = match.group(1)
            if visibility in {"public", "private", "protected", "internal", None}:
                return "named-init"
    if current_scope and current_scope.kind == "enum" and current_scope.is_public_type and immediate_scope:
        if is_enum_member_signature(stripped):
            return "enum-member"
    func_match = FUNC_DECL_RE.match(stripped)
    if func_match:
        visibility = func_match.group(1)
        is_open = bool(func_match.group(2))
        if current_scope and not immediate_scope:
            return None
        if visibility == "public":
            return "func"
        if visibility == "protected" and current_scope and current_scope.is_public_type and is_open:
            return "func"
        return None
    init_match = INIT_DECL_RE.match(stripped)
    if init_match:
        visibility = init_match.group(1)
        if current_scope and not immediate_scope:
            return None
        if visibility == "public":
            return "init"
        if visibility == "protected" and current_scope and current_scope.is_public_type:
            return "init"
        return None
    prop_match = PROP_DECL_RE.match(stripped)
    if prop_match:
        visibility = prop_match.group(1)
        if current_scope and not immediate_scope:
            return None
        if visibility == "public":
            return "prop"
        if visibility == "protected" and current_scope and current_scope.is_open_or_abstract_class:
            return "prop"
        return None
    let_var_match = LET_VAR_DECL_RE.match(stripped)
    if let_var_match and let_var_match.group(1) == "public" and (current_scope is None or immediate_scope):
        return let_var_match.group(2)
    if current_scope and current_scope.is_interface and immediate_scope:
        member_match = INTERFACE_MEMBER_RE.match(stripped)
        if member_match:
            if stripped.startswith("func ") or stripped.startswith("static func "):
                return "interface-func"
            if stripped.startswith("prop "):
                return "interface-prop"
            if stripped.startswith("let "):
                return "interface-let"
            if stripped.startswith("var "):
                return "interface-var"
            if stripped.startswith("init(") or stripped.startswith("const init("):
                return "interface-init"
    return None


def parse_declaration(
    path: Path,
    start: int,
    kind: str,
    signature: str,
    raw_signature: str,
    open_brace_line: int | None,
    end_line: int,
    current_scope: Scope | None,
) -> Declaration | None:
    if kind in {"class", "struct", "enum", "interface", "type"}:
        match = TYPE_DECL_RE.match(signature)
        if not match:
            return None
        visibility = match.group(1)
        modifier = (match.group(2) or "").strip()
        decl = Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None if open_brace_line is None else open_brace_line + 1,
            kind=kind,
            name=normalize_identifier(match.group(4)),
            signature=signature,
            raw_signature=raw_signature,
            visibility=visibility,
            is_open=modifier in {"open", "abstract"},
            parent_scope=current_scope,
        )
        return decl
    if kind == "extend":
        match = EXTEND_DECL_RE.match(signature)
        if not match:
            return None
        return Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None if open_brace_line is None else open_brace_line + 1,
            kind="extend",
            name=normalize_identifier(match.group(1)),
            signature=signature,
            raw_signature=raw_signature,
            visibility=None,
            parent_scope=current_scope,
        )
    if kind in {"func", "interface-func"}:
        match = FUNC_DECL_RE.match(signature if kind == "func" else signature.replace("static func", "func", 1) if signature.startswith("static func") else signature)
        if kind == "func" and not match:
            return None
        if kind == "interface-func":
            name_match = re.match(r"^(?:(static)\s+)?func\s+([^\s<(]+)\s*\(", signature)
            if not name_match:
                return None
            name = name_match.group(2)
            is_static = bool(name_match.group(1))
            visibility = "public"
            is_open = False
        else:
            name = match.group(4)
            is_static = bool(match.group(3))
            visibility = match.group(1)
            is_open = bool(match.group(2))
        return Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None if open_brace_line is None else open_brace_line + 1,
            kind=kind,
            name=normalize_identifier(name),
            signature=signature,
            raw_signature=raw_signature,
            visibility=visibility,
            is_open=is_open,
            is_static=is_static,
            parent_scope=current_scope,
            params=parse_param_names(signature),
            return_type=parse_return_type(signature),
        )
    if kind in {"init", "interface-init", "named-init"}:
        match = INIT_DECL_RE.match(signature)
        named_init_match = NAMED_INIT_RE.match(signature)
        if kind == "init" and not match:
            return None
        if kind == "named-init" and not named_init_match:
            return None
        if kind == "interface-init":
            visibility = "public"
        elif kind == "named-init":
            visibility = named_init_match.group(1)
        else:
            visibility = match.group(1)
        is_const = bool(match.group(2)) if match else signature.startswith("const init")
        return Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None if open_brace_line is None else open_brace_line + 1,
            kind="init" if kind == "named-init" else kind,
            name="init",
            signature=signature,
            raw_signature=raw_signature,
            visibility=visibility,
            is_const=is_const,
            parent_scope=current_scope,
            params=parse_param_names(signature),
        )
    if kind in {"prop", "interface-prop"}:
        if kind == "interface-prop":
            match = re.match(r"^prop\s+([^\s:={]+)\s*:", signature)
            visibility = "public"
            is_open = False
        else:
            match = PROP_DECL_RE.match(signature)
            visibility = match.group(1) if match else None
            is_open = bool(match.group(2)) if match else False
        if not match:
            return None
        prop_name = match.group(1) if kind == "interface-prop" else match.group(3)
        prop_type = signature.split(":", 1)[1].split("{", 1)[0].strip()
        return Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None if open_brace_line is None else open_brace_line + 1,
            kind=kind,
            name=normalize_identifier(prop_name),
            signature=signature,
            raw_signature=raw_signature,
            visibility=visibility,
            is_open=is_open,
            parent_scope=current_scope,
            return_type=prop_type,
        )
    if kind in {"let", "var", "interface-let", "interface-var"}:
        if kind.startswith("interface-"):
            match = re.match(r"^(let|var)\s+([^\s:=,]+)", signature)
            visibility = "public"
            actual_kind = kind
            if not match:
                return None
            name = match.group(2)
        else:
            match = LET_VAR_DECL_RE.match(signature)
            visibility = "public"
            actual_kind = kind
            if not match:
                return None
            name = match.group(3)
        return Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None if open_brace_line is None else open_brace_line + 1,
            kind=actual_kind,
            name=normalize_identifier(name),
            signature=signature,
            raw_signature=raw_signature,
            visibility=visibility,
            parent_scope=current_scope,
        )
    if kind == "enum-member":
        match = ENUM_MEMBER_RE.match(signature)
        if not match:
            return None
        return Declaration(
            path=path,
            line=start + 1,
            end_line=end_line + 1,
            open_brace_line=None,
            kind="enum-member",
            name=normalize_identifier(match.group(1)),
            signature=signature,
            raw_signature=raw_signature,
            visibility="public",
            parent_scope=current_scope,
            params=parse_enum_member_param_names(signature),
        )
    return None


def attach_doc_comment(
    declaration: Declaration,
    lines: list[str],
    doc_end_map: dict[int, DocBlock],
    doc_blocks: list[DocBlock],
    plain_block_end_map: dict[int, PlainBlockComment],
) -> None:
    start_idx = declaration.line - 1
    annotation_start = start_idx
    index = start_idx - 1
    while index >= 0 and is_annotation_line(lines[index].strip()):
        declaration.has_annotation = True
        annotation_start = index
        index -= 1
    target = annotation_start
    attached = doc_end_map.get(target - 1)
    if attached:
        declaration.comment = attached
        probe = attached.start - 1
        while probe >= 0 and is_blank(lines[probe]):
            probe -= 1
        if probe >= 0:
            stripped = lines[probe].strip()
            if probe in plain_block_end_map or stripped.startswith("//"):
                declaration.redundant_non_doc_comment_before_doc = True
    elif declaration.has_annotation:
        for block in doc_blocks:
            if annotation_start <= block.end < start_idx:
                declaration.misplaced_comment_under_annotation = True
                break


def build_scope_from_declaration(declaration: Declaration) -> Scope | None:
    if declaration.kind not in {"class", "struct", "enum", "interface", "type", "extend"}:
        return None
    if declaration.kind == "extend":
        return Scope(
            kind="extend",
            name=declaration.name,
            parent=declaration.parent_scope,
            declaration=declaration,
        )
    return Scope(
        kind=declaration.kind,
        name=declaration.name,
        parent=declaration.parent_scope,
        declaration=declaration,
        is_public_type=declaration.visibility == "public",
        is_interface=declaration.kind == "interface" and declaration.visibility == "public",
        is_open_or_abstract_class=declaration.kind == "class" and declaration.visibility == "public" and declaration.is_open,
    )


def analyze_file(path: Path, root: Path) -> list[Issue]:
    raw_text = path.read_text(encoding="utf-8")
    raw_lines = raw_text.splitlines()
    sanitized_lines = strip_comments_and_strings(raw_lines)
    doc_blocks, doc_end_map = find_doc_blocks(raw_lines)
    _, plain_block_end_map = find_plain_block_comments(raw_lines)

    declarations: list[Declaration] = []
    line_to_scope_openers: dict[int, list[Scope]] = {}
    occupied_lines: set[int] = set()
    scope_stack: list[Scope] = []
    brace_depth = 0

    for index, line in enumerate(sanitized_lines):
        while scope_stack and scope_stack[-1].closed:
            scope_stack.pop()
        if index in occupied_lines:
            brace_depth += line.count("{") - line.count("}")
            while scope_stack and scope_stack[-1].opened and brace_depth < getattr(scope_stack[-1], "brace_depth", 0):
                scope_stack.pop()
            continue

        current_scope = next((scope for scope in reversed(scope_stack) if scope.opened and not scope.closed), None)
        kind = match_declaration_kind_at_depth(line, current_scope, brace_depth)
        if kind:
            end_line, signature, raw_signature, open_brace_line = collect_signature(index, sanitized_lines, raw_lines, kind)
            for occupied in range(index + 1, end_line + 1):
                occupied_lines.add(occupied)
            declaration = parse_declaration(
                path=path,
                start=index,
                kind=kind,
                signature=signature,
                raw_signature=raw_signature,
                open_brace_line=open_brace_line,
                end_line=end_line,
                current_scope=current_scope,
            )
            if declaration is not None:
                attach_doc_comment(declaration, raw_lines, doc_end_map, doc_blocks, plain_block_end_map)
                declarations.append(declaration)
                scope = build_scope_from_declaration(declaration)
                if scope and open_brace_line is not None:
                    line_to_scope_openers.setdefault(open_brace_line, []).append(scope)
                    declaration.scope = scope

        brace_depth += line.count("{") - line.count("}")
        for scope in line_to_scope_openers.get(index, []):
            scope.opened = True
            scope.brace_depth = brace_depth
            scope_stack.append(scope)
        while scope_stack and scope_stack[-1].opened and brace_depth < getattr(scope_stack[-1], "brace_depth", 0):
            scope_stack.pop()

    issues: list[Issue] = []
    for declaration in declarations:
        if declaration.kind == "extend":
            continue
        if declaration.kind in {"class", "struct", "enum", "interface", "type"} and declaration.visibility != "public":
            continue
        if declaration.kind == "init" and declaration.visibility not in {"public", "protected"}:
            continue
        if declaration.comment is None:
            code = "misplaced_doc_comment" if declaration.misplaced_comment_under_annotation else "missing_doc_comment"
            message = (
                "文档注释必须位于语言注解上方。"
                if declaration.misplaced_comment_under_annotation
                else "缺少文档注释块。"
            )
            issues.append(Issue(path, declaration.line, code, message, declaration))
            continue

        if declaration.redundant_non_doc_comment_before_doc:
            issues.append(
                Issue(
                    path,
                    declaration.line,
                    "redundant_non_doc_comment_before_doc",
                    "文档注释块前存在冗余普通注释，请删除上方普通注释，仅保留 `/** ... */`。",
                    declaration,
                )
            )

        tags = declaration.comment.tags
        if "brief" not in tags:
            issues.append(Issue(path, declaration.line, "missing_brief", "缺少 `@brief` 标签。", declaration))

        if declaration.params:
            documented_params = declaration.comment.param_names
            for param in declaration.params:
                if param not in documented_params:
                    issues.append(
                        Issue(path, declaration.line, "missing_param", f"缺少参数 `{param}` 的 `@param` 标签。", declaration)
                    )

        if declaration.requires_return_tag and "return" not in tags:
            issues.append(Issue(path, declaration.line, "missing_return", "缺少 `@return` 标签。", declaration))

        if declaration.needs_explicit_return_type:
            issues.append(Issue(path, declaration.line, "missing_return_type", "公共函数缺少显式返回类型。", declaration))

    return issues


def walk_cangjie_files(root: Path, user_paths: list[Path]) -> list[Path]:
    if user_paths:
        files: list[Path] = []
        for item in user_paths:
            resolved = item if item.is_absolute() else root / item
            if resolved.is_file() and resolved.suffix == ".cj":
                files.append(resolved)
                continue
            if resolved.is_dir():
                for path in resolved.rglob("*.cj"):
                    if should_skip_path(path, root):
                        continue
                    files.append(path)
        return sorted(set(files))

    files = []
    for path in root.rglob("*.cj"):
        if any(part.lower() in SKIP_DIR_NAMES for part in path.parts):
            continue
        if should_skip_path(path, root):
            continue
        files.append(path)
    return sorted(files)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="检查 Cangjie 公共 API 文档注释缺漏。")
    parser.add_argument("paths", nargs="*", help="可选的文件或目录路径。默认扫描整个仓库。")
    parser.add_argument("--root", default=".", help="仓库根目录，默认当前目录。")
    parser.add_argument("--format", choices=("text", "json"), default="text", help="输出格式。")
    parser.add_argument("--max-issues", type=int, default=0, help="限制输出问题数，0 表示不限制。")
    return parser.parse_args()


def render_text(issues: list[Issue], root: Path, scanned_files: int, total_issues: int) -> str:
    lines = [f"Scanned {scanned_files} files, found {total_issues} issues."]
    for issue in issues:
        rel = issue.path.relative_to(root)
        lines.append(f"{rel}:{issue.line}: [{issue.code}] {issue.message} -> {issue.declaration.raw_signature}")
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    user_paths = [Path(item) for item in args.paths]
    files = walk_cangjie_files(root, user_paths)
    issues: list[Issue] = []
    for path in files:
        issues.extend(analyze_file(path, root))

    total_issues = len(issues)
    if args.max_issues > 0:
        issues = issues[: args.max_issues]

    if args.format == "json":
        payload = {
            "root": str(root),
            "scanned_files": len(files),
            "issue_count": total_issues,
            "shown_issue_count": len(issues),
            "issues": [issue.to_dict(root) for issue in issues],
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(render_text(issues, root, len(files), total_issues))

    return 1 if total_issues else 0


if __name__ == "__main__":
    sys.exit(main())
