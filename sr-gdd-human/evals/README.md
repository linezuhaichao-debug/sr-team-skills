# sr-gdd-human 评测套件（skill-up）

本目录用 [skill-up](https://alibaba.github.io/skill-up/) CLI 对 `sr-gdd-human` 做**可重复的行为评测**：
把 skill 装进真实 Agent Engine（本机 claude CLI），喂真实形态的上游材料，跑完出稿后按 SKILL.md 的硬约束做确定性判分。

## 快速开始

前置：本机 `claude` CLI 已登录（或配好网关鉴权）。无需 `ANTHROPIC_API_KEY`——skill-up 在缺 key 时会沿用 CLI 既有登录态。

```powershell
# 1) 先校验配置
skill-up validate  C:\Users\ZuHaiChao\.agents\skills\sr-gdd-human\evals\eval.yaml

# 2) 全量跑（7 条用例，并行 3；用时约 10~20 分钟）
skill-up run       C:\Users\ZuHaiChao\.agents\skills\sr-gdd-human\evals\eval.yaml --parallelism 3

# 3) 只跑某几条 / 出 HTML 报告
skill-up run  ...eval.yaml --include-case-name "gdd-no-config-numbers"
skill-up report <…>\sr-gdd-human-workspace\iteration-N\result.json --format html
```

产物目录：`C:\Users\ZuHaiChao\.agents\skills\sr-gdd-human-workspace\iteration-N\`
（`result.json`、每条用例的 `grading.json` 与 `outputs/`，其中 `outputs/workspace/` 是回收的成稿与决策记录）。

## 用例清单

| 用例 ID | 验证什么 | 判分方式 |
| --- | --- | --- |
| `bare-invocation-asks-back` | 裸调用（无主题/材料）必须先回问主题与上游材料，且**不得擅自落稿** | script |
| `gdd-result-only-no-process` | 成稿剥离证据编号（E00x）、拍板编号（T0x）、来源材料清单、假设/风险台账、配置契约、未支持声明、**模板教学性提示（HTML 注释/引用块）**；规则行**不得出现配置字段名**（snake_case、"配表名.字段名"）；保留 R 组级编号（无 R1.1 式小号）、UE 编号、ASCII 线框、数值待定项、验收标准 | script |
| `gdd-no-config-numbers` | **数值纪律**：材料给满配置初值，规则章不得出现具体数值（`\d+ 层/级/次/天/秒/张/钻石`、非 100% 的百分比、4 位以上 ID、材料原值 50/12/15/30/2.5）；且"数值待定项"**只列待定项名称，不回填参考值/初值**（该节仅编号列可有数字），文末有"参考值 X，待定"表述 | script |
| `gdd-current-scope-only` | **只保留当前口径**：正文不得出现 曾经/原先/旧稿/旧版/上版/变更前/本次已改/本次改动/原方案/旧方案/此前/过去/已废弃；废弃口径只允许在文末附录，且**必须是一句话、不得用表格**；成稿不得残留模板教学提示 | script |
| `gdd-ui-wireframes` | **界面章完整度**：≥3 个自有界面各有独立小节 + ASCII 线框图 + UE 编号表；有界面清单/界面流程/全局交互规范；通用组件与其它系统界面（货币详情弹窗、英雄详情页）只声明"不属于本功能"，**不得给它们单独开节** | script |
| `human-gate-options` | 定稿后给出四选项 Human Gate（approve / approve_with_conditions / revise / reject），且**不含** sr-gdd-ai 的 `request_missing_evidence` | rule_based |
| `decision-record-on-approve` | 多轮：出稿 → 用户 `approve` → 按 `decision-recording` 落 `decisions\decision_<主题>_<日期>.json`，字段满足 `decision.schema.json`（16 个 required、options≥2、status=accepted、decision_id 匹配 `^DEC-[A-Z0-9-]{3,}$`） | script |

判分策略：**没有使用 `agent_judge`**——全部为确定性断言，零额外 token，结果可复现。

## 目录结构

```
evals/
  eval.yaml                      # 评测入口（environment / skills / engine / cases / report）
  cases/*.yaml                   # 7 条用例；材料以 context.files 内联注入用例工作区
  fixtures/
    skills/sr-askme/             # 依赖 skill 的沙箱副本（见下）
    scripts/check_*.ps1          # 自包含判分脚本（UTF-8 BOM）
```

### fixtures/skills/sr-askme —— 沙箱副本，务必保持"相对路径"

`sr-gdd-human` 第 0 步要读 `../sr-askme/references/*` 与 `../config.local.json`，因此评测时把 sr-askme 作为**兄弟 skill** 一起安装（`eval.yaml` 的 `skills` 第二项）。
该副本的 `config.local.json` 被改写成相对路径：

```json
{ "sr_workspace": "sr-workspace", "sr_project": "sr-project", "config_root": "config-root" }
```

**安全要点**：真实 `config.local.json` 的 `sr_workspace` 指向 `D:\TimeMachine\GameDesignOS\workspace`。
若直接安装真实 sr-askme，评测会把草稿写进真实 workspace。副本的相对路径让产出落在用例临时工作区（`<tmp>\sr-workspace\proposals\…`），
判分脚本按 `<cwd>/**/proposals/*.md` 递归查找，**不依赖**成稿放在 `sr-workspace/` 还是工作区根目录。

## 判分脚本的三条硬约束（踩过的坑）

1. **必须自包含**：skill-up 会把 `script_path` 指向的脚本**单独复制**到临时目录（如 `%TEMP%\skill-up-judge-…\script.ps1`）再执行，
   因此 `$PSScriptRoot` 不指向本目录——脚本内不得 dot-source 公共库、也不得读取外部判定词表，判定词只能内嵌。
2. **Windows 只认 `.ps1` / `.cmd` / `.sh`**：`.py` 会报 `cannot determine interpreter`。本套件统一用 `.ps1`，
   并保存为 **UTF-8 with BOM**——否则 Windows PowerShell 5.1 读中文判定词会变乱码。
3. **工作目录 = 用例工作区**：脚本以 `<cwd>` 为工作区根，判分在产物回收（`collect_artifacts`）**之后**执行，
   所以判分脚本自己写出的文件不会被回收；判分结论通过 stdout 输出，失败时可在 `-v` 日志里直接看到完整逐条证据。

## 判定口径说明（避免误判）

- 规则章的数值检查按"把配置表数字任意改一遍，全文是否一字不用改"这一**skill 自身标准**实现，因此有两处豁免：
  - 字面量 `1`（如"至少 1 层推进""消耗 1 张勘探券"）是逻辑下限，不是可调配置值；
  - `100%`（如"成功与失败概率合计为 100%"）是恒等式，SKILL.md 本身就把它列为合规的机制表述。
  其余数值（材料里的 50 钻石 / 12 层 / 15 级 / 2.5% / 7 天 / 30 秒 / 10001 号段）出现即判失败。
- 扫描前会剥离 `R4 / UE4 / AC1 / P0 / UI-M1` 这类**文档标识符**，否则规则组标题 `### R4 层内倒计时` 会被误读成数值"4 层"。
- "数值待定项"一节只豁免**编号列**的数字：待定项名称、说明、参考值列里出现任何数字都判失败（2026-09-16 口径：该节不回填初值）。
- 历史口径扫描会**跳过引用块（`>` 开头的行）**，模板自带的教学性引用块（"不出现'曾经/原先/旧稿/变更前'式历史表述"）因此不会误伤；
  但**模板教学提示本身不得进成稿**，这是独立的一条 FAIL 级检查（同时覆盖 HTML 注释与引用块两种残留形态）。
- 规则组标题若用行内加粗而非标题，`rule-numbering:has-R-groups` 会退化为统计 `R\d+` 唯一 token 数，不会因为排版差异误判。
- WARN 级检查不影响退出码（`0` 通过 / `1` 失败），用于记录"值得改进但不该判失败"的观察项，例如：清单里列了但已声明归属其它系统、因而没有独立线框小节的界面 ID。

## 维护提示

- 改 skill 的约束时，同步改这里的判定词与用例材料，然后**先离线自测**：把脚本复制到临时目录、用
  `powershell -NoProfile -ExecutionPolicy Bypass -File` 在一个人造工作区上跑一遍，确认正/负样本判定正确，再跑真实评测。
- 用例材料刻意"脏"（带证据编号、拍板编号、变故记录、配置初值），不要为了好过而清理——
  这些正是被测 skill 必须消化的上游形态。
