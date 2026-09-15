# -*- coding: utf-8 -*-
"""
英雄技能配置工具 - 副玩法技能表 xlsx 读写与设计文档提取

用法:
  python config_tool.py design "<设计文档.xlsm>" --hero 雅典娜
      提取某英雄完整技能设计(跨阶合并, 富文本清洗)
  python config_tool.py design "<设计文档.xlsm>" --all
      列出全部英雄名
  python config_tool.py inspect "<技能表.xlsx>" [--hero 雅典娜]
      查看配置表现状: 各表数据行数 / 某英雄已有配置链
  python config_tool.py check "<技能表.xlsx>"
      检查 ID 冲突与引用完整性
  python config_tool.py apply "<技能表.xlsx>" plan.json -o "<输出.xlsx>"
      按配置计划写入(自动追加到各表末尾, 不覆盖已有行)
  python config_tool.py report "<技能表.xlsx>" plan.json -o "报告.md"
      生成审查报告草稿
  python config_tool.py diff "<原表.xlsx>" "<改后表.xlsx>"
      逐表/行/字段输出改动清单(新增整行, 更新给 旧值->新值); 改完后用它核对哪些改过

plan.json schema:
{
  "hero": "英雄名",
  "rows": {
    "主动技能表":  [ {cell: value, ...}, ... ],   # cell 用英文表头名(id/cd/type/...)
    "子技能表":    [...],
    "技能计算表":  [...],
    "技能效果表":  [...],
    "被动技能表":  [...],
    "技能表现表":  [...],
    "扫描特效表现表": [...]
  },
  "notes": [ "存疑项说明", ... ]
}
写表时以各表第2行英文字段为列名基准; 未提供的字段留空; table 类型直接写字符串(逗号分隔)。
"""
import sys, json, re, argparse, datetime
from pathlib import Path

import openpyxl
from openpyxl.styles import PatternFill

CONFIG_SHEETS = ["技能表现表", "扫描特效表现表", "主动技能表", "子技能表",
                 "技能计算表", "技能效果表", "被动技能表"]
ID_COL = {"技能表现表": "id", "扫描特效表现表": "id", "主动技能表": "id",
          "子技能表": "id", "技能计算表": "id", "技能效果表": "id", "被动技能表": "id"}
# 各表英文字段 -> 列号
def header_map(ws):
    m = {}
    for col in range(1, min(ws.max_column, 30) + 1):
        en = ws.cell(row=2, column=col).value
        zh = ws.cell(row=1, column=col).value
        if en and isinstance(en, str):
            m[en] = col
        elif zh and isinstance(zh, str) and col > 1:
            # 特例列(如子技能表 L/U/V 列无英文名), 用中文表头
            m[f"__zh__{zh}"] = col
            if "备注" in str(zh):
                m["remark"] = col  # 备注列多数表无英文名, 统一别名
    return m

def sheet_rows(ws, hmap, max_col=30):
    out = []
    for r in range(6, ws.max_row + 1):
        row = {}
        for en, col in hmap.items():
            if en.startswith("__zh__"):
                continue
            v = ws.cell(row=r, column=col).value
            if v is not None:
                row[en] = v
        row["__row__"] = r
        if any(v is not None for k, v in row.items() if k != "__row__"):
            out.append(row)
    return out

COLOR_RE = re.compile(r"<[^>]+>")

def clean_rich(s):
    if s is None:
        return ""
    return COLOR_RE.sub("", str(s)).replace("\\n", "\n").strip()

# ---------------- design ----------------
def cmd_design(args):
    wb = openpyxl.load_workbook(args.design, data_only=True, keep_vba=True)
    main = wb["英雄技能三阶设计"]

    heroes = {}
    for r in range(3, main.max_row + 1):
        hero = main.cell(row=r, column=1).value
        sid = main.cell(row=r, column=5).value
        if hero is None or sid is None:
            continue
        rec = {
            "row": r,
            "hero": str(hero).strip(),
            "quality": main.cell(row=r, column=2).value,
            "weapon": main.cell(row=r, column=3).value,
            "positioning": main.cell(row=r, column=4).value,
            "skill_id": sid,
            "remark": main.cell(row=r, column=6).value,
            "type": main.cell(row=r, column=7).value,      # 战技/大招/被动
            "stage": main.cell(row=r, column=8).value,     # 1/2/3
            "name": main.cell(row=r, column=9).value,
            "desc_raw": main.cell(row=r, column=10).value,
            "cd_s": main.cell(row=r, column=11).value,
            "desc_split": main.cell(row=r, column=12).value,
            "cd_s2": main.cell(row=r, column=13).value,
            "target_num": main.cell(row=r, column=14).value,
            "note": main.cell(row=r, column=15).value,
        }
        rec["desc_clean"] = clean_rich(rec["desc_raw"])
        heroes.setdefault(rec["hero"], []).append(rec)

    if args.all:
        for h, rows in heroes.items():
            print(f"{h}: {len(rows)}条 (ID {rows[0]['skill_id']}~{rows[-1]['skill_id']})")
        return 0

    target = args.hero
    if not target:
        print("英雄列表:", ", ".join(heroes))
        return 0
    if target not in heroes:
        print(f"未找到英雄[{target}]。可用: " + ", ".join(heroes))
        return 1
    print(json.dumps({"hero": target, "skills": heroes[target]}, ensure_ascii=False, indent=2, default=str))
    return 0

# ---------------- inspect ----------------
def cmd_inspect(args):
    wb = openpyxl.load_workbook(args.config, data_only=True)
    print("== 各表数据行数 ==")
    for name in CONFIG_SHEETS:
        ws = wb[name]
        n = sum(1 for r in range(6, ws.max_row + 1) if ws.cell(row=r, column=2).value is not None)
        print(f"  {name}: {n}")
    if not args.hero:
        return 0
    h = args.hero
    print(f"\n== [{h}] 已有配置链 ==")
    for name, keyword_col in [("主动技能表", 3), ("被动技能表", 3), ("技能表现表", 3)]:
        ws = wb[name]
        for r in range(6, ws.max_row + 1):
            remark = str(ws.cell(row=r, column=keyword_col).value or "")
            if h in remark:
                print(f"  [{name}] r{r}: " + " | ".join(
                    f"{ws.cell(row=2,column=c).value or ws.cell(row=1,column=c).value}={ws.cell(row=r,column=c).value}"
                    for c in range(2, min(ws.max_column, 12) + 1) if ws.cell(row=r, column=c).value is not None))
    # 子技能/计算/buff 按 ID 段搜(备注含英雄名 或 ID 属于该英雄段)
    ws = wb["子技能表"]
    for r in range(6, ws.max_row + 1):
        remark = str(ws.cell(row=r, column=3).value or "")
        if h in remark:
            print(f"  [子技能表] r{r}: " + " | ".join(
                f"{ws.cell(row=2,column=c).value or ''}={ws.cell(row=r,column=c).value}"
                for c in range(2, 16) if ws.cell(row=r, column=c).value is not None))
    for name in ("技能计算表", "技能效果表"):
        ws = wb[name]
        for r in range(6, ws.max_row + 1):
            remark = str(ws.cell(row=r, column=3).value or "")
            if h in remark:
                print(f"  [{name}] r{r}: " + " | ".join(
                    f"{ws.cell(row=2,column=c).value or ''}={ws.cell(row=r,column=c).value}"
                    for c in range(2, 15) if ws.cell(row=r, column=c).value is not None))
    return 0

# ---------------- check ----------------
REF_FIELDS = {  # sheet -> [(引用字段, 目标sheet)]
    "主动技能表": [("subSkillList", "子技能表")],
    "子技能表": [("scanEffectId", "扫描特效表现表"), ("hurtRatio", "技能计算表"),
               ("healRatio", "技能计算表"), ("impactList", "技能效果表")],
    "被动技能表": [("subSkillList", "子技能表")],
}
def collect_ids(wb):
    ids = {}
    for name in CONFIG_SHEETS:
        ws = wb[name]
        hmap = header_map(ws)
        idc = hmap.get(ID_COL[name], 2)
        s = set()
        for r in range(6, ws.max_row + 1):
            v = ws.cell(row=r, column=idc).value
            if v is not None:
                s.add(int(v))
        ids[name] = s
    return ids

def cmd_check(args):
    wb = openpyxl.load_workbook(args.config, data_only=True)
    ids = collect_ids(wb)
    problems, warnings = [], []
    for name in CONFIG_SHEETS:
        ws = wb[name]
        hmap = header_map(ws)
        idc = hmap.get(ID_COL[name], 2)
        seen = {}
        for r in range(6, ws.max_row + 1):
            v = ws.cell(row=r, column=idc).value
            if v is None:
                continue
            v = int(v)
            if v in seen:
                problems.append(f"[{name}] ID 重复: {v} (行{seen[v]} 与 行{r})")
            seen[v] = r
    for sheet, refs in REF_FIELDS.items():
        ws = wb[sheet]
        hmap = header_map(ws)
        for field, target in refs:
            if field not in hmap:
                continue
            col = hmap[field]
            for r in range(6, ws.max_row + 1):
                v = ws.cell(row=r, column=col).value
                if v is None:
                    continue
                for part in str(v).split(","):
                    part = part.strip()
                    if not part:
                        continue
                    try:
                        n = int(float(part))
                    except ValueError:
                        continue
                    if n not in ids[target]:
                        # 既有表存在历史悬空引用(如通用子弹特效 79449901), 降级为警告
                        msg = f"[{sheet}] 行{r} {field}引用 {n} 不存在于[{target}]"
                        (warnings if field == "scanEffectId" else problems).append(msg)
    # 主动技能ID应有表现表行(被动技能按惯例不配表现表, 不检查)
    anim_ids = ids["技能表现表"]
    for n in ids["主动技能表"]:
        if n >= 10000000 and n not in anim_ids:
            problems.append(f"[主动技能表] 技能 {n} 无技能表现表行")
    if problems:
        print(f"发现 {len(problems)} 个问题:")
        for p in problems:
            print("  " + p)
    if warnings:
        print(f"\n警告 {len(warnings)} 个(多为既有数据的历史遗留, 新增配置不应产生新的):")
        for w in warnings:
            print("  " + w)
    if not problems and not warnings:
        print("check 通过: 无 ID 冲突, 无悬空引用")
        return 0
    return 1 if problems else 0

# ---------------- apply ----------------
def cmd_apply(args):
    with open(args.plan, encoding="utf-8") as f:
        plan = json.load(f)
    out_path = args.out or args.config
    wb = openpyxl.load_workbook(args.config)  # 保留格式
    ids_before = collect_ids(wb)
    added, skipped = [], []
    for sheet, rows in plan.get("rows", {}).items():
        if sheet not in CONFIG_SHEETS:
            raise SystemExit(f"未知表名: {sheet}")
        ws = wb[sheet]
        hmap = header_map(ws)
        idc = hmap.get(ID_COL[sheet], 2)
        # 找写入起点: 该表最后有 ID 的行
        last = 5
        for r in range(6, ws.max_row + 1):
            if ws.cell(row=r, column=idc).value is not None:
                last = r
        for row in rows:
            rid = row.get(ID_COL[sheet])
            if rid is None:
                raise SystemExit(f"[{sheet}] 计划行缺少 id: {row}")
            # 已存在? 找现有行
            exist_r = None
            for r in range(6, last + 1):
                if ws.cell(row=r, column=idc).value is not None and int(ws.cell(row=r, column=idc).value) == int(rid):
                    exist_r = r
                    break
            if exist_r and not args.force:
                skipped.append(f"[{sheet}] id={rid} 已存在(行{exist_r}), 跳过")
                continue
            target_r = exist_r or (last + 1)
            if not exist_r:
                last = target_r
            for en, val in row.items():
                if en in hmap:
                    ws.cell(row=target_r, column=hmap[en]).value = val
                else:
                    zh_key = f"__zh__{en}"
                    if zh_key in hmap:
                        ws.cell(row=target_r, column=hmap[zh_key]).value = val
                    else:
                        skipped.append(f"[{sheet}] id={rid} 字段 {en} 找不到列, 忽略")
            added.append(f"[{sheet}] {'更新' if exist_r else '新增'} 行{target_r} id={rid} 备注={row.get('remark','')}")
    wb.save(out_path)
    print(f"已写入: {out_path}")
    print(f"新增/更新 {len(added)} 行, 跳过/忽略 {len(skipped)} 项")
    for a in added:
        print("  + " + a)
    for s in skipped:
        print("  ~ " + s)
    # 写后自检
    wb2 = openpyxl.load_workbook(out_path, data_only=True)
    ids_after = collect_ids(wb2)
    dangling = []
    for sheet, refs in REF_FIELDS.items():
        ws = wb2[sheet]
        hmap = header_map(ws)
        for field, target in refs:
            if field not in hmap:
                continue
            col = hmap[field]
            for r in range(6, ws.max_row + 1):
                v = ws.cell(row=r, column=col).value
                if v is None:
                    continue
                for part in str(v).split(","):
                    part = part.strip()
                    if not part:
                        continue
                    try:
                        n = int(float(part))
                    except ValueError:
                        continue
                    if n not in ids_after[target]:
                        dangling.append(f"[{sheet}] 行{r} {field}引用 {n} 不存在于[{target}]")
    if dangling:
        print("\n!! 引用完整性警告:")
        for d in dangling:
            print("  " + d)
    else:
        print("\n写后引用完整性: 通过")
    if getattr(args, "view", None):
        if not args.out:
            print("!! --view 需要配合 -o 使用(生成副本才能对比前后), 已跳过变动行视图")
        else:
            try:
                cmd_diffview(argparse.Namespace(config=args.config, new=out_path, out=args.view))
            except Exception as e:
                print(f"!! 变动行视图生成失败: {e}")
    return 0

# ---------------- report ----------------
def cmd_report(args):
    with open(args.plan, encoding="utf-8") as f:
        plan = json.load(f)
    lines = [f"# 技能配置审查报告 - {plan.get('hero', '')}",
             f"生成时间: {datetime.date.today()}  ",
             f"配置文件: {args.config}", ""]
    lines.append("## 新增/变更行")
    for sheet, rows in plan.get("rows", {}).items():
        if not rows:
            continue
        lines.append(f"\n### {sheet}")
        lines.append("| id | 备注 | 其他关键字段 |")
        lines.append("|---|---|---|")
        for row in rows:
            rid = row.get(ID_COL.get(sheet, "id"), "")
            remark = row.get("remark", "")
            rest = {k: v for k, v in row.items() if k not in ("id", "remark")}
            rest_s = "; ".join(f"{k}={v}" for k, v in list(rest.items())[:8])
            lines.append(f"| {rid} | {remark} | {rest_s} |")
    lines.append("\n## 存疑项(请逐条核对)")
    notes = plan.get("notes", [])
    if notes:
        for i, n in enumerate(notes, 1):
            lines.append(f"{i}. {n}")
    else:
        lines.append("(无)")
    out = args.out or (str(Path(args.config).parent / f"配置审查报告-{plan.get('hero','')}-{datetime.date.today()}.md"))
    Path(out).write_text("\n".join(lines), encoding="utf-8")
    print(f"报告已生成: {out}")
    return 0

# ---------------- diff ----------------
def cmd_diff(args):
    """对比修改前后的两份副玩法技能表, 逐表/行/字段输出改动清单. config=原表, new=改后表."""
    wb_b = openpyxl.load_workbook(args.config, data_only=True)
    wb_a = openpyxl.load_workbook(args.new, data_only=True)
    n_add = n_del = n_mod = 0

    def col_label(ws, col):
        en = ws.cell(row=2, column=col).value
        if en and isinstance(en, str):
            return str(en)
        zh = ws.cell(row=1, column=col).value
        return str(zh) if zh else f"col{col}"

    def collect(ws, idc):
        d = {}
        for r in range(6, ws.max_row + 1):
            v = ws.cell(row=r, column=idc).value
            if v is not None:
                d[int(v)] = r
        return d

    def norm(v):
        # 空字符串与 None 视为等价(openpyxl 保存可能把空串归一为空值, 非实际改动)
        return "" if v is None or v == "" else v

    def fmt_row(ws, r, idc):
        parts = []
        for c in range(idc, 31):
            v = ws.cell(row=r, column=c).value
            if v is not None:
                parts.append(f"{col_label(ws, c)}={v}")
        return "; ".join(parts)

    for name in CONFIG_SHEETS:
        ws_b, ws_a = wb_b[name], wb_a[name]
        idc = header_map(ws_b).get(ID_COL[name], 2)
        rows_b, rows_a = collect(ws_b, idc), collect(ws_a, idc)
        added = sorted(set(rows_a) - set(rows_b))
        removed = sorted(set(rows_b) - set(rows_a))
        common = sorted(set(rows_a) & set(rows_b))

        if added:
            print(f"[{name}] 新增 {len(added)} 行:")
            for idv in added:
                print(f"    + {idv}: {fmt_row(ws_a, rows_a[idv], idc)}")
                n_add += 1
        if removed:
            print(f"[{name}] 删除 {len(removed)} 行:")
            for idv in removed:
                print(f"    - {idv}: {fmt_row(ws_b, rows_b[idv], idc)}")
                n_del += 1
        first_mod = True
        for idv in common:
            rb, ra = rows_b[idv], rows_a[idv]
            diffs = []
            for c in range(idc, 31):
                vb, va = ws_b.cell(row=rb, column=c).value, ws_a.cell(row=ra, column=c).value
                if norm(vb) != norm(va):
                    diffs.append(f"{col_label(ws_b, c)}: {vb!r} -> {va!r}")
            if diffs:
                if first_mod:
                    print(f"[{name}] 更新 {len(common)} 行中的改动:")
                    first_mod = False
                print(f"    ~ {idv}: " + "; ".join(diffs))
                n_mod += 1

    print(f"\n汇总: 新增 {n_add}, 删除 {n_del}, 更新 {n_mod}, 共 {n_add + n_del + n_mod} 处改动")
    return 0

# ---------------- diffview ----------------
def cmd_diffview(args):
    """生成'只含变动行'的视图表: 每个有增改的 sheet 一张'变动行-<表>'页, 带列头, 改动单元格黄色, 新增行绿色."""
    wb_b = openpyxl.load_workbook(args.config, data_only=True)
    wb_a = openpyxl.load_workbook(args.new, data_only=True)
    out = openpyxl.Workbook()
    out.remove(out.active)
    GREEN = "FFA5D6A7"
    YELLOW = "FFFFE082"
    n_add = n_mod = 0
    for name in CONFIG_SHEETS:
        ws_b, ws_a = wb_b[name], wb_a[name]
        idc = header_map(ws_b).get(ID_COL[name], 2)
        rb, ra = {}, {}
        for r in range(6, max(ws_b.max_row, ws_a.max_row) + 1):
            v = ws_b.cell(row=r, column=idc).value
            if v is not None:
                rb[int(v)] = r
            v2 = ws_a.cell(row=r, column=idc).value
            if v2 is not None:
                ra[int(v2)] = r
        added = sorted(set(ra) - set(rb))
        mod_rows = []
        for idv in sorted(set(ra) & set(rb)):
            rr_b, rr_a = rb[idv], ra[idv]
            changed = []
            for c in range(idc, min(max(ws_b.max_column, ws_a.max_column), 64) + 1):
                vb, va = ws_b.cell(row=rr_b, column=c).value, ws_a.cell(row=rr_a, column=c).value
                if (vb is None or vb == "") and (va is None or va == ""):
                    continue
                if vb != va:
                    changed.append(c)
            if changed:
                mod_rows.append((rr_a, changed))
        if not added and not mod_rows:
            continue
        ws_out = out.create_sheet(f"变动行-{name}")
        maxcol = min(max(ws_b.max_column, ws_a.max_column), 64)
        for r in range(1, 6):  # 列头 1..5 行
            for c in range(1, maxcol + 1):
                ws_out.cell(row=r, column=c).value = ws_a.cell(row=r, column=c).value
        out_row = 6
        def write_row(src_r):
            for c in range(1, maxcol + 1):
                v = ws_a.cell(row=src_r, column=c).value
                cell = ws_out.cell(row=out_row, column=c)
                cell.value = v
                if (isinstance(v, int) and not isinstance(v, bool)) or (isinstance(v, float) and v.is_integer()):
                    cell.number_format = "0"
        for idv in added:
            write_row(ra[idv])
            for c in range(idc, maxcol + 1):
                ws_out.cell(row=out_row, column=c).fill = PatternFill("solid", fgColor=GREEN)
            out_row += 1
            n_add += 1
        for rr_a, changed in mod_rows:
            write_row(rr_a)
            for c in changed:
                ws_out.cell(row=out_row, column=c).fill = PatternFill("solid", fgColor=YELLOW)
            out_row += 1
            n_mod += 1
    if not out.sheetnames:
        ws_out = out.create_sheet("变动行")
        ws_out.cell(row=1, column=1).value = "无增删改"
    out.save(args.out)
    print(f"变动行视图已生成: {args.out} (新增 {n_add} 行, 修改 {n_mod} 行)")
    return 0

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("design")
    p.add_argument("design")
    p.add_argument("--hero")
    p.add_argument("--all", action="store_true")
    p.set_defaults(func=cmd_design)

    p = sub.add_parser("inspect")
    p.add_argument("config")
    p.add_argument("--hero")
    p.set_defaults(func=cmd_inspect)

    p = sub.add_parser("check")
    p.add_argument("config")
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("apply")
    p.add_argument("config")
    p.add_argument("plan")
    p.add_argument("-o", "--out")
    p.add_argument("--force", action="store_true", help="允许更新已存在的行(默认跳过)")
    p.add_argument("--view", help="写完后自动生成'变动行视图'xlsx 路径(需配合 -o 才有前后可比)")
    p.set_defaults(func=cmd_apply)

    p = sub.add_parser("report")
    p.add_argument("config")
    p.add_argument("plan")
    p.add_argument("-o", "--out")
    p.set_defaults(func=cmd_report)

    p = sub.add_parser("diff", help="对比修改前后的表, 输出改动清单")
    p.add_argument("config", help="改动前的原表")
    p.add_argument("new", help="改动后的表")
    p.set_defaults(func=cmd_diff)

    p = sub.add_parser("diffview", help="生成只含变动行的视图表(列头+仅增改行, 黄=改/绿=增)")
    p.add_argument("config", help="改动前的原表")
    p.add_argument("new", help="改动后的表")
    p.add_argument("-o", "--out", required=True, help="输出视图 xlsx 路径")
    p.set_defaults(func=cmd_diffview)

    args = ap.parse_args()
    sys.exit(args.func(args))

if __name__ == "__main__":
    main()
