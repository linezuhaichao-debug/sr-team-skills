# 概念设计方法卡（蒸馏自 game-concept-architect v1.3.0 @ 0855025 SKILL.md）

本卡是 `sr-concept` 加载上游方法论时的入口。细节方法论按章节加载本目录 `game-concept-architect/references/` 下的对应文件（原样保留），报告表格骨架用 `game-concept-architect/templates/idea-triage.md`。

## 五件套工作流（上游核心方法）

1. **Concept Seed Extraction**（一句话创意 → 题材/玩法/情绪/差异化/平台/商业化/受众假设 + 关键 unknown）
2. **Player Verb Inventory**（玩家直接动作、系统响应、脑内判断、80% 时间里反复做什么）
3. **Design Nucleus Options**（2~4 个候选，各带行为改变、风险、最小验证；不得过早锁死单一设计核）
4. **Action-Goal Alignment**（核心动词是否推进瞬时/局内/长期目标）
5. **Assumption Ledger + External Evidence Status**（假设台账 + VOI 门状态：not-run / evidence-needed / partial / verified / contradicted）

## Reference 加载顺序（本目录 `game-concept-architect/references/`）

| 时机 | 加载 |
| --- | --- |
| 撰写 Concept Seed Extraction 前 | `concept-seed-extraction.zh-CN.md` |
| 撰写 Design Nucleus Options 前 | `design-nucleus-options.zh-CN.md` |
| 输入涉及参考游戏/机制迁移 | `game-dissection-lens.zh-CN.md` |
| 判断是否需要外部调研 | `voi-feasibility-gate.zh-CN.md` |
| 书写玩家承诺前 | `player-promise-framework.zh-CN.md` |
| 把承诺转成循环和系统 | `core-loop-expansion.zh-CN.md` |
| 涉及品类/融合品类/参考游戏 | `genre-fit-matrix.zh-CN.md` + `reference-game-boundary.zh-CN.md` |
| 承诺功能范围前 | `scope-gate.zh-CN.md` |
| 判断是否值得继续投入 | `prototype-validation-gate.zh-CN.md` |
| 平台/商业化约束影响设计 | `platform-business-fit.zh-CN.md` |
| 评估团队能力/产能/成本 | `production-feasibility.zh-CN.md`（+ `production-profile-gate.zh-CN.md`） |

## 硬规则（原文照搬，全部生效）

- 不要把题材当差异化。题材组合只有在改变玩家行为时，才可能成为设计核。
- 不要把世界观当玩法。设定必须创造行动、约束或选择，才有设计价值。
- 不要只列功能名；必须能说清玩家反复执行的动词，以及这些动词如何接到目标。
- 不要把随机性当万能调味料；必须说明它来自哪里、放在哪里、玩家如何理解失败。
- 不要用"内容很多"弥补核心循环薄弱；内容必须是核心循环的变奏和延展。
- 不要把受众写成人口标签；必须写出玩家想做什么、为什么兴奋、为什么反感。
- 不要把主题停留在剧情或美术；主题必须被操作、选择和后果承载。
- 不要因为某个系统是品类标配就加入它。
- 不要在一句话创意有多个合理方向时，过早锁死单一设计核。
- 不要把 assumption 藏在确定语气里。
- 不要输出无法测试的完整幻想文档。
- 当目标平台被说出或明显暗示时，不要跳过平台和商业适配。
- 不要把没有外部证据的市场判断写成事实。
- 不要为了显得完整而泛搜；先说明 VOI。
- 不要复制参考游戏的结构、术语、设定、阵营或内容表达；只抽取行为结构。
- 不要把团队未知或不可控的能力设计成核心卖点。
- 不要承诺需要长期大量内容产出的高光体验，除非写清内容产能验证方式。
- 没有通过标准和失败标准时，不要建议继续生产投入。
- 不要用"后续调优"代替验证计划。
- 不要把 `repo_example` 贡献规则误用为用户私有工作限制。

## idea_triage 最低合格输出

至少包含：Case Visibility、Original Idea、Concept Seed Extraction、Player Verb Inventory、Design Nucleus Options（≥2 个候选）、Action-Goal Alignment、Assumption Ledger、External Evidence Status、Triage Decision。未提供的信息必须进入 assumption ledger；没有证据时写 `not-run` 或 `evidence-needed`；不得在一句话输入下直接展开完整设计。

上游模板中仅 `idea-triage.md` 被本工作流使用；其余 23 个模板（full-design-brief、one-page-pitch 等）与外部可行性扫描面向通用/对外场景，不随包携带。
