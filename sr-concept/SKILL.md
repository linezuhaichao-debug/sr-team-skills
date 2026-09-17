---
name: sr-concept
description: 创新功能设计工作流——一句话创意 → 设计核三角报告 → 用户拍板 → 完整功能设计 → 交接 sr-gdd-human 出成稿。当用户想新玩法/新功能/有新创意，或问"这个点子能不能做"（可行性评估）时使用。
---

# 创新功能设计工作流（SR-Concept）

## 功能说明

两段式流水线，中间由人判断：

1. **第一阶段 · 设计核三角报告**（concept seed + 玩家动词清单 + design nucleus options + 假设台账 + 外部证据状态）。这是默认产出，做完即停，交给用户看。
2. **第二阶段 · 完整功能设计**（仅用户在设计核门选定设计核后执行）。把选定设计核展开为可验证的功能设计（玩家承诺、核心循环、关键系统、scope gate、验证计划），与用户迭代优化后交接 sr-gdd-human 生成功能 GDD（主线先 human 后 ai，见 sr-askme 教学主线）。

方法论引用内嵌快照 `game-concept-architect`（入口：`references/concept-method.md`），本 skill 只固化 SR 团队的项目语境、VOI 门、产出路径与 Human Gate。

适用范围：默认为**本项目（文明之跃）内的新玩法/功能**——数值铁律、RPGBattleModule 双模式等项目约束直接生效。用户明确说是新游戏概念时按通用模式执行，项目约束全部标 `unknown`，交接 sr-gdd 时才注入项目语境。

不编造用户未提供的信息——缺失信息一律标 `assumption` / `unknown`（含置信度、影响等级、验证方式），由人决定补不补。不替用户选设计核。

**证据优先级**：`配置表 > 客户端代码 > 参考策划文档 > 推断`。用户提供的参考材料（旧案、竞品拆解、配置表、代码结论）相互冲突时，以高优先级来源为准，差异写入 Assumption Ledger 并标 `待确认：`。

## 使用方法

```
/sr-concept <一句话创意>
```

或直接说人话，例如"我想做一个时空回溯改战局的玩法"、"设计一个文明奇观争夺功能"、"这个点子能不能做：玩家互相派遣间谍偷科技"。

## 无输入时的行为

调用时未带任何创意（裸 `/sr-concept`），**不得直接进入执行流程、不得自行扫描 workspace 找题目**。先用一段话向用户说明需要什么，并停下等输入：

1. **创意**：一句话描述想做的玩法或功能。
2. **定位**：本项目（文明之跃）新功能/新玩法，还是通用概念（默认项目内）。
3. **已有材料**（有就给路径，没有就明说没有）：脑图、参考游戏笔记、旧草案、相关决议记录。

用户补齐后再从第 0 步开始。

## 路径约定

文中的 `<SR_WORKSPACE>`（产出落盘根目录）与 `<SR_PROJECT>`（Unity 工程根目录）在运行时从 `../sr-askme/config.local.json` 解析：文件不存在或字段为空时，先按 `../sr-askme/SKILL.md` 的首次配置引导收集并写入，再继续本流程；文件存在则直接采用，不再询问。本 skill 与 sr-askme 及其它 sr-* skill 为兄弟目录，须成组安装在同一 skill 根。

## 执行流程

### 第 0 步 · 载入项目语境

读 `../sr-askme/references/sr_project_context.md`，后续全程遵守其中的数值铁律与写作约束。项目内功能设计全部生效；通用概念模式仅写作约束生效，项目约束标 `unknown`。
完成判据：已读完该文件。

### 第 1 步 · 创意复述与定位

- 用一句话复述用户原始创意，确认理解一致。
- 确认定位：项目内新玩法/功能（默认）| 通用概念（无输入阶段已收集的，此处仅复述确认）。
- 记录 case visibility（照上游）：`case_visibility` 默认 `private_user_work`，`output_destination` 默认 `private_notes`。
- 缺失信息会实质改变设计方向时才提澄清问题（如目标平台、参考游戏是灵感还是硬约束），**最多问三个**；用户要求继续就带着明确 assumptions 推进。

完成判据：复述获用户认可；定位与 case visibility 成文。

### 第 2 步 · 设计核三角报告（第一阶段）

读本目录 `references/concept-method.md`（上游方法论入口：五件套工作流、reference 加载顺序、硬规则）；撰写 Concept Seed Extraction 章节前加载 `references/game-concept-architect/references/concept-seed-extraction.zh-CN.md`，撰写 Design Nucleus Options 章节前加载 `references/game-concept-architect/references/design-nucleus-options.zh-CN.md`；输入涉及参考游戏或机制迁移时加读 `references/game-concept-architect/references/game-dissection-lens.zh-CN.md`。报告表格骨架用 `references/game-concept-architect/templates/idea-triage.md`。

按 `references/concept-method.md` §idea_triage 最低合格输出撰写设计核三角报告（产出路径见文末产出规范表）：

- **Case Visibility**
- **Original Idea**：一句话复述
- **Concept Seed Extraction**：题材母体、玩法母体、情绪承诺、差异化种子、平台假设、商业化假设、受众假设、关键 unknown
- **Player Verb Inventory**：玩家直接动作、系统响应、脑内判断、80% 时间里玩家真正反复做什么
- **Design Nucleus Options**：2 到 4 个候选，每个写清玩家反复做什么取舍、改变什么行为/节奏/成长、依赖哪些 assumptions、最大风险和最小验证方式。**不得过早锁死单一设计核**
- **Action-Goal Alignment**：核心动词是否推进瞬时目标、局内目标和长期目标；是否存在脱离核心循环的目标或功能
- **Assumption Ledger**：每条标置信度、影响等级、验证方式；不得把 assumption 藏在确定语气里
- **External Evidence Status**：VOI 门判定（`not-run` / `evidence-needed` / `partial` / `verified` / `contradicted`）。不强制联网、不做泛搜；没有证据的市场判断不得写成事实
- **Recommended Next Step**

项目语境硬约束（项目内定位时）：

- 报告出现的数值一律标"待配表"，禁止猜数。
- 涉及战斗的设计注明 RPGBattleModule 确定性引擎两种模式（开放世界 / 独立战斗场景）的归属。

上游 `game-concept-architect` §硬规则 全部生效（本步开头已读入，见 `references/concept-method.md`）。

完成判据：报告章节齐全；每个 nucleus option 有风险与最小验证方式；所有 assumption 已入台账。

### 第 3 步 · 治理检查

按本目录 `references/governance-check.md` 做检查，在报告末尾附五条引用：

- `decision_ref`：本次创意探索要改变的产品/设计决策
- `voi_gate_ref`：哪些外部取证才会真正改变设计核选择或范围
- `paranoia_review_ref`：要拦截的无支撑声明、过度自信解读、被藏起来的 assumption
- `human_gate_refs`：需要 owner 审批的玩家承诺、对外口径、范围与生产投入
- `candidate_learning_refs`：可复用的设计规则（在跨案例重复出现前保持 candidate 状态）

完成判据：五条引用全部填写，无占位符残留。

### 第 4 步 · Human Gate（设计核门）

向用户呈现选项并等待选择，不替用户做批准类决定：

```
pick_nucleus_<编号> / merge_nuclei / regenerate_options / request_external_evidence / stop
```

- `pick_nucleus_<编号>` = 用户选定设计核，进入第 5 步。这是两阶段之间唯一的入口，不得默认进入。
- `merge_nuclei` / `regenerate_options`：按用户指示回到第 2 步调整候选。
- `request_external_evidence`：列出最小验证动作，补证据后回到第 2 步。
- 选择后按 `../sr-askme/references/decision-recording.md` 写决策记录（schema 见本目录 `references/decision.schema.json`）。`status` 映射：`pick_nucleus_*→accepted`、`stop→rejected`、`merge_nuclei / regenerate_options / request_external_evidence→proposed`。

### 第 5 步 · 完整功能设计（第二阶段，仅选定设计核后）

读上游 references：`player-promise-framework.zh-CN.md`、`core-loop-expansion.zh-CN.md`、`scope-gate.zh-CN.md`、`prototype-validation-gate.zh-CN.md`、`production-feasibility.zh-CN.md`；涉及品类或参考游戏时加读 `genre-fit-matrix.zh-CN.md`、`reference-game-boundary.zh-CN.md`。

产出功能设计稿（产出路径见产出规范表），必备章节：

- **Player Promise**：一句话承诺、首次接触承诺、重复游玩承诺
- **Core Loop**：行动、选择、风险、反馈、奖励、成长或新约束
- **Key Systems**：每个系统必须答出四问——服务哪个核心循环、改变什么玩家行为、创造什么反馈、如何被验证；答不出的系统不得加入
- **Uncertainty Calibration**：不确定性来源（人/隐藏信息/身体技能/脑力技能/随机性）、玩家能否解释失败原因、随机性是否覆盖玩家努力
- **Scope Gate**：MVP 必须有、后续版本应该有、建议砍掉的危险设计
- **Production Feasibility**：项目内定位时落到引擎与工具链约束（C# 确定性 sim / Lua 热更边界、`LuaConfigs` 与 `RPG_Configs` 配表管线、移动端性能预算）；内容产能能否持续
- **Validation Plan**：最小可玩原型、第一轮测试目标、最危险假设、通过标准、失败标准、下一步投入条件。**没有通过/失败标准不得建议继续投入**
- **Assumption Ledger**：更新版，标注第一阶段哪些 assumption 已被设计决策消化
- **配置项预测**：本设计涉及的新配置表与字段清单，全部标"待配表"——为 sr-config 建表与 sr-gdd-ai 配置契约章节备料

设计稿初稿出来后与用户迭代优化，直到用户认可。
完成判据：章节齐全；每个 key system 答出四问；validation plan 有通过/失败标准；数值全部"待配表"或标注 `配表名.字段名`。

### 第 6 步 · Human Gate（交接门）

向用户呈现选项并等待选择：

```
route_to_sr-gdd / revise_concept / stop
```

- `route_to_sr-gdd`：输出 GDD 交接 JSON（产出路径见产出规范表），交接目标为 `sr-gdd-human`（主线成稿步），内容为材料清单：功能设计稿路径、设计核三角报告路径、已拍板设计核与关键取舍、假设台账、配置项预测、遗留 unknown 与置信度。sr-gdd-human 第 1 步资产盘点可直接从 `workspace\` 拾取这些材料。
- 决策记录按 `../sr-askme/references/decision-recording.md` 写入，`status` 映射：`route_to_sr-gdd→accepted`、`stop→rejected`、`revise_concept→proposed`。

## 产出规范

| 产出 | 路径（`<SR_WORKSPACE>\` 下） |
|------|------|
| 设计核三角报告 | `analysis\concept-triage_<主题>_<日期>.md` |
| 功能设计稿（仅选定设计核后） | `analysis\feature-concept_<主题>_<日期>.md` |
| GDD 交接（仅 route_to_sr-gdd 时） | `analysis\sr-gdd-handoff_<主题>_<日期>.json` |
| 决策记录（decision.schema.json） | `decisions\decision_<主题>_<日期>.json` |

目录不存在时直接创建。日期格式 `YYYYMMDD`。

## 上游依赖（快照内嵌，勿改）

- `references/concept-method.md`（蒸馏自 game-concept-architect SKILL.md：五件套工作流 + reference 加载顺序 + 硬规则 + idea_triage 最低合格输出）
- `references/game-concept-architect/references/`（上游 10 个方法论 reference 原样快照）
- `references/game-concept-architect/templates/idea-triage.md`（报告表格骨架原样快照）
- `references/governance-check.md`（蒸馏自 paranoia-ai-system-evolver 的治理检查）
- `references/decision.schema.json`（contracts/decision.schema.json 原样副本）

快照文件清单与完整性校验见仓库根 CHECKSUMS.txt（仓库级文件，不随 skill 目录安装）。上游 SKILL.md 原文以 `references/game-concept-architect/METHOD.md` 存档（改名避免被 loader 误认成独立 skill）。
