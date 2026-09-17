# 决策记录写入规范（decision-recording）

各 SR 技能的 Human Gate 产生决策后，按本规范把决策写为 JSON。schema 权威来源：本目录 `decision.schema.json`（**全系列唯一一份**，不再随各 skill 分发副本）。`<SR_WORKSPACE>` 从 `../config.local.json` 解析（首次配置见 `../SKILL.md`）。

## 写入步骤

1. 写之前先读 schema，以 schema 为准。
2. 全部 required 字段必须有值；refs 类字段无内容时给空数组 `[]`，不要省略。
3. `decision_id` 必须匹配 `^DEC-[A-Z0-9-]{3,}$`（如 `DEC-20260723-AFK`）。
4. `status` 由各技能按自身 Human Gate 选项映射，映射表见各技能 SKILL.md 对应 Human Gate 步骤。**`stop`（sr-concept / sr-analysis）与 `reject`（GDD 链）同义**，都映射为 `rejected`。
5. 落盘：`<SR_WORKSPACE>\decisions\decision_<主题>_<日期>.json`，日期格式 `YYYYMMDD`，目录不存在时直接创建。
