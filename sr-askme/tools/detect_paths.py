#!/usr/bin/env python3
"""探测 SR 系列 skill 首次配置所需的本机路径（sr-askme 引导流程的辅助工具）。

探测规则继承自原 team-skills/install.py 的实战逻辑：
  * sr_workspace：本 skill 根的邻近布局候选中第一个存在的 workspace 目录；
  * sr_project：邻近目录中含 Assets/HotRes 结构、且 .git remote URL 含特征子串的
    Unity 工程根（多工程并存时目录结构相同，remote 特征是唯一可靠区分）；
  * config_root：Unity 工程邻近的 planner/策划配置。

输出：逐项打印 探测值/未探测到；--json 输出机器可读结果。只读探测，不写任何文件。
"""

import json
import re
import sys
from pathlib import Path

PROJECT_GIT_URL_HINT = "projectreclaimnew"


def git_remote_urls(path: Path) -> list:
    config = path / ".git" / "config"
    if not config.is_file():
        return []
    return re.findall(r"^\s*url\s*=\s*(\S+)\s*$",
                      config.read_text(encoding="utf-8", errors="ignore"), re.M)


def detect_workspace(skill_root: Path):
    for base in (skill_root.parent.parent, skill_root.parent.parent.parent, skill_root.parent):
        candidate = base / "GameDesignOS" / "workspace"
        if not candidate.is_dir():
            candidate = base / "workspace"
        if candidate.is_dir():
            return candidate
    return None


def detect_project(skill_root: Path):
    candidates = []
    for base in (skill_root.parent.parent, skill_root.parent.parent.parent, skill_root.parent):
        if not base.is_dir():
            continue
        for child in sorted(base.iterdir()):
            if child.is_dir() and (child / "Assets" / "HotRes").is_dir():
                candidates.append(child)
    for c in candidates:
        if any(PROJECT_GIT_URL_HINT in url.lower() for url in git_remote_urls(c)):
            return c, True  # True = remote 特征确认
    return (candidates[0], False) if candidates else (None, False)


def detect_config_root(project):
    if project is None:
        return None
    for candidate in (project.parent / "planner" / "策划配置", project / "planner" / "策划配置"):
        if candidate.is_dir():
            return candidate
    return None


def main() -> None:
    skill_root = Path(__file__).resolve().parent.parent  # sr-askme/
    workspace = detect_workspace(skill_root)
    project, confirmed = detect_project(skill_root)
    config_root = detect_config_root(project)

    result = {
        "sr_workspace": str(workspace) if workspace else None,
        "sr_project": str(project) if project else None,
        "config_root": str(config_root) if config_root else None,
        "project_remote_confirmed": confirmed if project else False,
    }
    if "--json" in sys.argv:
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return
    label = {"sr_workspace": "workspace（产出落盘根目录）",
             "sr_project": "Unity 工程根目录",
             "config_root": "策划配置根目录（仅 sr-config 使用）"}
    for key in ("sr_workspace", "sr_project", "config_root"):
        v = result[key]
        note = ""
        if key == "sr_project" and v and not confirmed:
            note = "（仅按 Assets/HotRes 结构推测，.git remote 未匹配特征，请人工确认）"
        print(f"{label[key]}: {v or '未探测到'}{note}")
    print("\n探测值供参考：请逐项确认或修正后，由引导流程写入 sr-askme/config.local.json")


if __name__ == "__main__":
    main()
