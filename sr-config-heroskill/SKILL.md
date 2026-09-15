---
name: sr-config-heroskill
description: 把英雄技能详细设计（【小世界】英雄技能详细设计.xlsm）配置进副玩法技能表（B008-副玩法技能表.xlsx）：为新英雄全量配置、为已有占位行的英雄补全真实配置、或按设计变更调整现有技能。用户提到配技能表、技能配置、把技能设计落到配置表时触发。
---

# 英雄技能自动配置

把技能详细设计文档中的英雄技能转化为符合规范的副玩法技能表配置。产出允许与"完美配置"有偏差（数值单位、扫描参数细节等），用户会人工检查修正，但结构、ID 引用链、表内格式必须正确。

## 总体流程

1. **读设计文档**（必读：`references/design-doc.md` 了解设计文档结构）
2. **读配置规范**（必读：`references/conventions.md` 了解 7 张表的字段语义、枚举字典、ID 规则、雅典娜完整样例）
3. **用 scripts/config_tool.py 提取设计数据**，逐英雄产出配置计划
4. **写表**（见下"占位行改造"，这是多数英雄的必经路径）
5. **自检 + 生成审查报告**，明确列出所有存疑项供用户核对

## 关键规则

- **先查重再新增**：写入前必须检查目标 ID 是否已存在（`inspect --hero`）。存在三种状态，处置不同：
  - **占位行**（如 `subSkillList=999901` 通用普攻）：最常见。保留行内其他字段，用 `apply --force` 只在 plan 中写要改的字段（如 `subSkillList`），plan 不含的字段不会被触碰。
  - **完整配置**：跳过，报告中说明"已存在，未改动"。
  - **设计文档有、配置表没有**：正常新增。
- **ID 体系**（详见 conventions.md）：
  - 主动/被动技能ID = `100794523` 这种 9 位格式，直接沿用设计文档的技能Id 列
  - 子技能ID / 技能计算ID / 技能效果(buff)ID / 扫描特效ID = 技能ID 去掉前两位 `10` + 两位序号，如 `100794523` → `79452301`、`79452302`…（序号按"技能组内第几个子技能/buff"递增，跨阶复用的沿用已有 ID）
- **三阶递进是增量的**：二/三阶描述往往只写变化（"目标数增加至6名""持续时间提升至10秒"），必须与一阶合并理解出完整效果链。复用可复用的行（同 buff 换持续时间才新增 buff 行）。
- **数值单位**：百分比 → 万分比（550% → 计算表 baseValue `55000`），秒 → 毫秒（6秒 → `6000`），"15%最大生命值的护盾" → 护盾 buff paramValue 引用计算表ID。
- **伤害/治疗系数一律走技能计算表**：子技能表 M/N 列填计算表 ID（如 `79452301`），不直接填系数数字。
- **不确定就留默认+标注**：拿不准的枚举值（scanForm 细分、表现资源路径等）宁可沿用同类英雄的通用值并在报告中标注，不要瞎编资源路径。表现资源（特效名/挂点）没有信息来源时直接留空并标注"待表现配置"。
- **每次写入后生成审查报告**（Markdown，逐英雄列出：新增行清单、引用链、存疑项清单），命名 `<表名>-配置审查报告-<日期>.md`，与输出文件同目录。

## 使用脚本

scripts/config_tool.py 是唯一的读写入口，直接操作 xlsx（openpyxl），保留原文件格式：

```bash
# 查看设计文档某英雄的完整技能设计（含跨阶合并）
python scripts/config_tool.py design "<设计文档路径>" --hero 雅典娜

# 查看配置表现状（各表行数、ID 段占用、某英雄已有配置）
python scripts/config_tool.py inspect "<技能表路径>" [--hero 雅典娜]

# 检查 ID 冲突与引用完整性（写之前、写之后各跑一次）
python scripts/config_tool.py check "<技能表路径>"

# 应用配置计划（JSON 格式，schema 见脚本 docstring；--force 更新已有行，--view 写后自动生成变动行视图）
python scripts/config_tool.py apply "<技能表路径>" plan.json -o "<输出>.xlsx" --force --view "<变动行视图>.xlsx"

# 生成审查报告草稿
python scripts/config_tool.py report "<技能表路径>" plan.json -o 报告.md

# 改动前后对比：逐表/行/字段列出改了什么（新增整行、更新给 旧值->新值）
python scripts/config_tool.py diff "<原表路径>" "<改后表路径>"

# 生成"只含变动行"的视图表（列头+仅增改行，黄=改、绿=增），供 univer/GUI 直接看改动
python scripts/config_tool.py diffview "<原表路径>" "<改后表路径>" -o "<变动行视图>.xlsx"
```

配置计划 JSON：先跑 `design` 拿到结构化设计数据，自己推理出配置计划（哪些子技能、buff、计算行、引用关系）写成 plan.json，再 `apply`。不要手写 Excel 单元格。plan 文件写在 Windows 临时目录（如 `C:\Users\<user>\AppData\Local\Temp\`）——Git Bash 的 `/tmp` 与 Python 进程的路径不互通，写 `/tmp/xxx.json` 会让后续命令找不到文件。

存疑项（plan 的 `notes`）在 `apply` 之后、`report` 之前定稿——写表过程中发现的偏差（占位行处置、临时改的枚举值）都要回写进 notes。报告是用户检查修改的唯一依据。

## 输出前必须完成

1. `check` 通过：无 ID 冲突、无悬空引用（subSkillList/impactList/scanEffectId/hurtRatio 指向的行都存在）
2. 审查报告已生成，存疑项逐条可读（用户据此修表）
3. **变动行视图已生成并交付 univer 展示**：`diffview <原表> <改后表> -o 变动行.xlsx` 输出"只含增删改行+列头"的视图表（黄=改动单元格、绿=新增行）；随后**必须把它 `univer_import` 进一个新的 `.univer` worktree**（`univer_new`→worktree 创建→`univer_import`，会拉起 DSH 实时差异浮窗，用户才能在界面看到高亮改动）。`diff` 则给出逐字段 旧值->新值 文本清单。
   - 注意：`diffview` 对比的是"原表 vs 改后副本"。若改动**同时**加到原表和副本（如清理既有错误），原表-副本对比显示不出来——这种场景需先对原表留"改动前"快照，再用 `diffview <快照> <当前>` 出差异。
4. 输出文件是副本（在原文件名上加 `-新增<日期>` 后缀），不覆盖用户原表——除非用户明确说直接改原文件
