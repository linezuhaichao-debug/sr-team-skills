---
name: sr-analysis
description: 体验诊断 + 设计拆解复刻工作流——游戏素材（截图/录屏/PV/商店页/视频链接）→ 证据链分析报告 → 用户判定 → 复刻规格 → 交接 sr-gdd-human 出成稿。当用户分析游戏素材、体验复盘、拆解竞品/玩法，或想复刻某个功能时使用。
---

# 体验诊断与设计拆解工作流（SR-Analysis）

## 功能说明

两段式流水线，中间由人判断：

1. **第一阶段 · 证据链分析报告**（样本边界 + 证据索引 + 体验报告 + 问题卡 + 验证建议）。这是默认产出，做完即停，交给用户看。
2. **第二阶段 · 设计拆解与复刻规格**（仅用户在报告门选择"可参考、进入拆解"后执行）。把素材中的功能设计拆成可复刻的规格，与用户迭代优化后交接 sr-gdd-human 生成功能 GDD（主线先 human 后 ai，见 sr-askme 教学主线）。

方法论引用内嵌快照 `game-experience-analyzer`（入口：`references/game-experience-analyzer/METHOD.md`），本 skill 只固化 SR 团队的项目语境、VOI 门、产出路径与 Human Gate。

注意：上游拆解方法声明"不要把拆解当成竞品复刻清单"。本 skill 的第二阶段**显式放宽**该约束——复刻规格是本团队的正当产出，但迁移边界仍必须保留：题材、美术、IP、具体数值、运营节奏不得原样照搬成建议。

不编造未观察到的内容——素材里看不到的，标注 `unknown` / `unsupported_by_sample`，由人决定补不补素材。

## 使用方法

```
/sr-analysis <素材路径或链接>
```

或直接说人话，例如"分析一下这段新手期录屏"、"拆一下这个竞品的 PV"、"看看这个功能能不能复刻"。

## 无输入时的行为

调用时未带任何素材（裸 `/sr-analysis`），**不得直接进入执行流程、不得自行扫描目录找素材**。先用一段话向用户说明需要什么，并停下等输入：

1. **素材**：截图、录屏文件、PV/宣传片、商店页或视频链接（给路径或 URL）。
2. **分析目标**（有就说，没有就在第 1 步 VOI 门现场确认）：这次诊断要改变什么决策。

提示中给出示例：`/sr-analysis 分析 D:\recordings\新手期首战.mp4 的前期体验`。用户补齐后再从第 0 步开始。

## 路径约定

文中的 `<SR_WORKSPACE>`（产出落盘根目录）与 `<SR_PROJECT>`（Unity 工程根目录）在运行时从 `../sr-askme/config.local.json` 解析：文件不存在或字段为空时，先按 `../sr-askme/SKILL.md` 的首次配置引导收集并写入，再继续本流程；文件存在则直接采用，不再询问。本 skill 与 sr-askme 及其它 sr-* skill 为兄弟目录，须成组安装在同一 skill 根。

## 执行流程

### 第 0 步 · 载入项目语境

读 `../sr-askme/references/sr_project_context.md`，后续全程遵守其中的写作约束。
完成判据：已读完该文件。

### 第 1 步 · 声明决策（VOI 门）

不因为素材在手就分析。先向用户确认这次诊断要改变什么决策——问题优先级、修改方案、玩家承诺修订、下一个验证测试，还是"是否值得复刻该功能"。写明：

- 不做这次分析时的默认动作
- 样本能消除的不确定性
- 什么观察信号会改变动作
- 样本**不能**证明什么

额外的截图、时间戳、对比样本不会改变优先级或下一步动作时，停止取证。

注意：即使最终目标是复刻，第一阶段的决策声明也只到"是否值得复刻"为止；**复刻哪些部分、如何改造、放弃什么**属于第二阶段的取舍，不在此承诺。
完成判据：决策声明成文，用户认可分析目标。

### 第 2 步 · 样本边界门

读本目录 `references/game-experience-analyzer/METHOD.md` 与 `references/game-experience-analyzer/references/sample-scope-gate.zh-CN.md`，输出四要素：`sample_boundary`、`supported_judgment_scope`、`unsupported_judgment_scope`、`key_unknowns`。用户要求越界判断时保留问题但标 `unsupported_by_sample`。
完成判据：四要素齐全，写在报告最前面。

### 第 3 步 · 证据与诊断

按 `references/game-experience-analyzer/METHOD.md` 的默认流程执行（证据索引 → 诊断包路由 → 品类路由 → 判断与验证计划；METHOD 内引用的 references/templates 均在 `references/game-experience-analyzer/` 下），证据规则照上游（第 2 步已读入）：P0/P1 判断必须引用 `evidence_id`、严格区分观察与解释、低置信度判断标 `uncertain`。
完成判据：所有 P0/P1 问题卡与核心建议都有 `evidence_id`；无证据支撑的判断已标注。

### 第 4 步 · 治理检查

按本目录 `references/governance-check.md` 做检查，在报告末尾附五条引用：

- `decision_ref`：本次素材证据要改变的产品/设计决策
- `voi_gate_ref`：哪些额外取证才会真正改变优先级
- `paranoia_review_ref`：要拦截的无支撑声明、弱证据、过度自信解读
- `human_gate_refs`：需要 owner 审批的承诺、对外口径、范围变更、生产投入
- `candidate_learning_refs`：可复用的诊断规则（在跨样本重复出现前保持 candidate 状态）

完成判据：五条引用全部填写，无占位符残留。

### 第 5 步 · Human Gate（报告门）

向用户呈现选项并等待选择，不替用户做批准类决定：

```
accept_diagnosis / enter_dissection / request_more_evidence / route_to_ed_experiment / revise_player_promise / stop
```

- `accept_diagnosis`：用户认可诊断结论，第一阶段收尾，流程结束（不进入拆解）。
- `enter_dissection` = 用户看完报告，判定该功能**可参考、值得拆解复刻**，进入第 6 步。这是两阶段之间唯一的入口，不得默认进入。
- `request_more_evidence`：列出最小补充素材清单，用户补齐后回到第 2 步。
- `route_to_ed_experiment`：输出 ED handoff（见本节末段），流程结束。
- `revise_player_promise`：把报告中的玩家承诺修订项带回给承诺产出方（sr-concept 案例或人工），本流程结束。
- 选择后按 `../sr-askme/references/decision-recording.md` 写决策记录（schema 见本目录 `references/decision.schema.json`）。`status` 映射：`accept_diagnosis / route_to_ed_experiment→accepted`、`stop→rejected`、`request_more_evidence / revise_player_promise / enter_dissection→proposed`。

选择 `route_to_ed_experiment` 时，另按 `references/game-experience-density-optimizer/ed-handoff-contract.md` 输出 ED handoff（保留每张问题卡的 `evidence_id`、不可判断项和置信度）。

### 第 6 步 · 设计拆解与复刻规格（仅 enter_dissection 后）

路由到上游游戏拆解方法：读 `references/game-experience-analyzer/references/game-dissection-diagnosis.zh-CN.md`，以 `transfer_mechanic` 为拆解目标执行（玩家动词、动作-目标对齐、不确定性来源、系统动态、内容流、迁移边界），不使用 `early_experience` 默认模式。

产出**复刻规格**（产出路径见文末产出规范表），必备章节：

- **功能规则候选**：每条绑定 `evidence_id`，并按项目语境显式标注 已验证事实 / 推断 / unknown
- **UI 结构与交互流程**：界面层级、操作序列、反馈节奏
- **数值表现**：素材中观察到的数值；观察不到的一律标 `unknown` 或"待配表"，遵守数值铁律，禁止猜数
- **推断配置项**：复刻需要的配置字段清单，标"待配表"
- **迁移边界**：可迁移的结构 vs 依赖题材/美术/IP/具体数值/运营节奏、不可照搬的部分
- **待裁决取舍清单**：复刻/改造/放弃三分类中需要用户拍板的条目（每条给候选方案 + 推荐 + 理由）

规格初稿出来后与用户迭代优化取舍，直到用户认可。
完成判据：复刻规格六章节齐全；每条规则有 `evidence_id` 或显式标注；待裁决取舍已获用户逐条拍板。

### 第 7 步 · Human Gate（交接门）

向用户呈现选项并等待选择：

```
route_to_gdd / revise_spec / stop
```

- `route_to_gdd`：输出 GDD 交接 JSON（产出路径见产出规范表），交接目标为 `sr-gdd-human`，内容为材料清单：复刻规格路径、证据索引路径、样本边界、迁移边界、已拍板取舍、遗留 unknown 与置信度。sr-gdd-human 第 1 步资产盘点可直接从 `workspace\` 拾取这些材料。
- 决策记录按 `../sr-askme/references/decision-recording.md` 写入，`status` 映射：`route_to_gdd→accepted`、`stop→rejected`、`revise_spec→proposed`。

## 产出规范

| 产出 | 路径（`<SR_WORKSPACE>\` 下） |
|------|------|
| 证据包（source-boundary、evidence-index、时间戳账本） | `evidence\<主题>\` |
| 体验报告 | `analysis\experience-report_<主题>_<日期>.md` |
| 问题卡 | `analysis\issue-cards_<主题>_<日期>.json` |
| ED 交接（仅 route_to_ed_experiment 时） | `analysis\ed-handoff_<主题>_<日期>.json` |
| 复刻规格（仅 enter_dissection 后） | `analysis\replication-spec_<主题>_<日期>.md` |
| GDD 交接（仅 route_to_gdd 时，交接目标 sr-gdd-human） | `analysis\sr-gdd-handoff_<主题>_<日期>.json` |
| 决策记录（decision.schema.json） | `decisions\decision_<主题>_<日期>.json` |

目录不存在时直接创建。日期格式 `YYYYMMDD`。

## 上游依赖（快照内嵌，勿改）

- `references/game-experience-analyzer/`（game-experience-analyzer 运行时子集原样快照：METHOD.md + references/ + templates/；SKILL.md 原文改名 METHOD.md 存档）
- `references/game-experience-density-optimizer/ed-handoff-contract.md`（ED 交接契约原样快照）
- `references/governance-check.md`（蒸馏自 paranoia-ai-system-evolver 的治理检查）
- `references/decision.schema.json`（contracts/decision.schema.json 原样副本）

快照文件清单与完整性校验见仓库根 CHECKSUMS.txt（仓库级文件，不随 skill 目录安装）。
