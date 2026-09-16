---
name: sr-askme
description: SR 系列 skill 的配置引导与使用教学中枢。首次使用 sr 系列 skill 时（config.local.json 不存在）询问并固化 workspace、Unity 工程、策划配置目录等本机路径；也用于回答"sr 系列有哪些 skill、怎么用、流程是什么"等教学问题。其它 sr-* skill 第 0 步会来读本 skill 的共享语境文件。
---

# SR-AskMe：SR 系列配置引导与教学中枢

本 skill 是 SR 团队工作流 skill（sr-concept / sr-analysis / sr-gdd-ai / sr-gdd-human / sr-gdd-html / sr-config / sr-config-heroskill）的**共享基础设施**，承担三件事：

1. **首次配置引导**：收集并固化本机路径，写 `config.local.json`；
2. **使用教学**：按 `references/teaching/` 下的使用卡讲解各 skill 的用法；
3. **共享语境宿主**：其余 sr-* skill 的"载入项目语境"步骤读取本 skill `references/` 下的共享文件。**因此 sr-askme 必须与其它 sr-* skill 安装在同一 skill 根目录下（兄弟目录）**，单独拷走任何一个 skill 而不带 sr-askme，其第 0 步会明确报错提示。

## 一、首次配置引导（核心流程）

**触发条件**：任何 sr-* skill 执行时，第 0 步先检查本目录 `config.local.json` 是否存在；不存在，或存在但关键字段为空，则引导用户完成配置后再继续该 skill 的流程。用户直接说"/sr-askme"或"配置 sr 系列"时也进入本流程。

**配置文件**：本目录下 `config.local.json`（含本机私有路径，不入仓库，参照同目录 `config.local.example.json` 创建；安装/镜像更新不应覆盖它）。

### 引导步骤

1. **读 schema**：先读 `config.local.example.json` 了解字段与含义。
2. **能自动探测的先探测**：运行 `python tools/detect_paths.py`（Python 3，无第三方依赖）。它按以下规则给出建议值，探测成功时只需用户回车确认：
   - `sr_workspace`：本 skill 根的邻近布局（`<skill根>/../../workspace`、`<skill根>/../../../workspace` 等候选）中第一个存在的目录；
   - `sr_project`：邻近目录中含 `Assets/HotRes` 结构、且 `.git` remote URL 含 `projectreclaimnew` 特征的 Unity 工程根（多工程并存时 remote 特征是唯一可靠区分，结构相同不构成证据）；
   - `config_root`：`sr_project` 的邻近 `planner/策划配置` 目录。
3. **探测不到的字段逐项询问**，一次问完，说明每项的用途：
   - `sr_workspace`：策划案、证据、决议等产出的落盘位置（产出子目录 proposals/decisions/analysis/evidence 会自动创建）；
   - `sr_project`：Unity 工程根目录（配表与文本表所在，含 `Assets/`）；
   - `config_root`：策划配置 `.xlsx/.xlsm` 的根目录（仅 sr-config 使用）。
4. **写入并固化**：把确认的路径写成本目录 `config.local.json`（JSON，路径用原生分隔符），并同步生成 `sr-config/profiles/timemachine.local.yaml`（格式参照其同目录 `timemachine.local.example.yaml`，只填 `config_root` 一行）。两处都写，然后明确告知用户："已固化，下次不再询问。改路径直接编辑这两个文件，或删掉后重新运行 /sr-askme。"
5. **不重复打扰**：`config.local.json` 存在且关键字段齐全时，任何 skill 都不得再次询问路径。

### 字段说明

| 字段 | 含义 | 消费方 |
| --- | --- | --- |
| `sr_workspace` | 产出落盘根目录（下挂 proposals\ decisions\ analysis\ evidence\） | 全部 sr-* skill |
| `sr_project` | Unity 工程根（`<SR_PROJECT>`，配表与文本表所在） | 全部 sr-* skill 的数值铁律、sr-config 的配置说明 |
| `config_root` | 策划配置 `.xlsx/.xlsm` 根目录 | sr-config |
| `configured_at` | 首次配置日期 | 提示信息 |

## 二、使用教学

用户问"sr 系列怎么用"、"有哪些 skill"、"/sr-concept 是什么"时，先给出下方「一条主线 + 场景入口」的讲解（禁止直接甩 ASCII 大图），再按需展开 `references/teaching/` 下对应用卡。7 张卡与各 skill 目录一一对应。

### 推荐用法（教学时的固定口径）

**主线**：五个步骤，从想法/素材走到评审宣讲：

1. **入口（二选一，看手里的材料）**
   - 手里是**一句话创意 / 新玩法想法** → `/sr-concept`：先出"设计核三角报告"（2~4 个候选方向，各带风险与验证方式），你拍板选定后展开完整功能设计稿；
   - 手里是**竞品录屏/截图/PV/商店页** → `/sr-analysis`：先出"证据链分析报告"（这个玩法值不值得抄、抄哪些），你判定可参考后拆出复刻规格。
2. **成稿**：`/sr-gdd-human` 基于入口产出的设计稿/复刻规格，生成**只有规则和界面**的 GDD（无证据编号、无配置契约，规则+界面线框详细可读）。
3. **落配置**：`/sr-config` 根据 GDD 把规则写成配置表（新表/加字段/改记录，带读回验收）。
4. **整合定稿**：`/sr-gdd-ai` 把设计稿 + 配置表变更**整合成最终版本 GDD**（功能规则、配置契约、验收标准，带证据溯源，适合正式留档）。
5. **宣讲**：`/sr-gdd-html` 把定稿 GDD 出成评审会用的单文件 HTML（投屏可直接讲）。

以上是推荐顺序，**全部 skill 也都可以单独调用**——比如直接 `/sr-gdd-ai 基于 旧策划案.xlsx 出功能 GDD`，不经过前序步骤。

**独立技能**：`/sr-config-heroskill` 不在推荐主线里，专精英雄技能配置（技能详细设计 xlsm → 副玩法技能表 B008），需要配英雄技能时单独使用。

### 速查表

| 你想做什么 | 用哪个 |
| --- | --- |
| "我有个创意 / 想个新玩法 / 这个点子能不能做" | `/sr-concept` |
| "分析这段录屏 / 拆一下这个竞品 / 能不能复刻" | `/sr-analysis` |
| "写策划案 / 出 GDD / 整理成功能文档" | `/sr-gdd-ai` |
| "出给开发团队看的可读版 / 只留规则不要过程" | `/sr-gdd-human` |
| "出评审会用的 HTML / 把策划案做成宣讲页" | `/sr-gdd-html` |
| "把这条规则落成配置表 / 加字段 / 建新表" | `/sr-config` |
| "配英雄技能 / 把技能设计落到配置表" | `/sr-config-heroskill` |

### 产出落盘位置（`sr_workspace` 下）

| 产出 | 子目录 |
| --- | --- |
| 功能 GDD、评审宣讲 HTML（+ content.json） | `proposals\` |
| 设计核三角报告 / 功能设计稿 / 体验报告 / 问题卡 / 复刻规格 / 各类交接 JSON | `analysis\` |
| 证据包（证据索引、时间戳账本） | `evidence\` |
| 决策记录（decision.schema.json） | `decisions\` |

### 数值铁律（各 skill 产出共同遵守）

- 玩法数值一律 data-driven，标注 `配表名.字段名`；还没建表的标"待配表"，禁止硬编码和猜数；
- 全文区分并显式标注四类陈述：已验证事实 / 项目假设 / 估算 / 未决问题。

完整约束见 `references/sr_project_context.md`（各 skill 第 0 步载入的同一份文件）。

## 三、共享语境文件（供其它 sr-* skill 引用）

| 文件 | 内容 | 引用方 |
| --- | --- | --- |
| `references/sr_project_context.md` | 项目语境：数值铁律、写作约束、受众默认 | 全部 sr-* 第 0 步 |
| `references/decision-recording.md` | 决策记录写入规范（status 映射、落盘路径） | 各 skill Human Gate 之后 |
| `references/decision.schema.json` | 决策记录 JSON schema（权威定义） | decision-recording 引用 |

注意：`decision.schema.json` 的权威定义随本 skill 携带一份副本；sr-gdd-ai / sr-concept / sr-analysis 目录内各有一份同样副本，供其单目录引用，四处必须同步更新。

## 四、维护提示

- 本 skill 与 7 个 sr-* skill 需**成组安装**在同一 skill 根（安装方式与镜像同步由使用者自管，无安装脚本）；
- `config.local.json` 与 `sr-config/profiles/timemachine.local.yaml` 是运行时生成的本地文件，更新 skill 时不应被覆盖（若同步机制会清空目录，需先备份这两个文件）；
- 内嵌方法论快照的文件清单与完整性校验见仓库根 CHECKSUMS.txt（仓库级文件，不随 skill 目录安装）。
