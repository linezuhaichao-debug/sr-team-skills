---
name: sr-config
description: 将游戏策划规则转换为可追溯的配置数据契约。用于新建运行时配置表、增删改字段或记录、同步 INDEX、配置说明和字段批注、为新表生成配置测试数据，以及对最终配置数据进行读回验收。
---

# 策划配置数据契约（sr-config）

将用户确认的策划规则落实为可追溯、可确认、可读回验收的配置数据变更。

本 Skill 只验收最终配置数据：运行时表与五行表头、字段与记录、主键与索引、枚举、单位、codec、引用、`INDEX`、配置说明、字段批注和新表测试数据。公式、VBA、外部链接、样式及其他工作簿文件特性由当前表格工具负责，本 Skill 不对其作保真承诺。

## 按需读取

- 建立规则、字段 schema、codec 或 `INDEX` 映射时，完整读取 [规则与 schema](references/rules_and_schema.md)。
- 生成 change set、风险或确认门时，完整读取 [change set 与确认](references/change_set.md)。
- 新建任何运行时表时，完整读取 [新表与配置测试数据](references/new_table.md)。
- 实际写入工作簿时，完整读取 [最小事务写入与验收](references/mutation_protocol.md)。
- TimeMachine 项目任务读取 [TimeMachine profile](profiles/timemachine.md)；`config_root` 取自 `../sr-askme/config.local.json` 的 `config_root` 字段（首次使用由 sr-askme 引导生成，并同步写成本目录 `profiles/timemachine.local.yaml`，含私有路径不入仓库；手工配置参照 `timemachine.local.example.yaml`）。
- `evals/cases.md` 只用于维护和回归测试本 Skill，不进入普通任务上下文。

## 附带工具

- [tools/probe_workbook.py](tools/probe_workbook.py)：工作簿标准探查。凡需要读取既有工作簿结构（表头、样本、`INDEX`、批注、结构特性），一律运行该脚本而不是临时手写 openpyxl 代码——脚本默认输出**全部单元格批注**，批注是项目字段契约（枚举含义、codec 规则、取值边界）的权威载体，只读 `cell.value` 会漏读契约；对零批注的运行时表它会显式告警。
- [tools/check_pattern_fields.py](tools/check_pattern_fields.py)：项目 profile「已验证模式」的字段级校验。建表/写字段前先跑它——全部通过则模式直接采用，有字段缺失则降级 `candidate` 并登记 `profile_conflict`。它取代对来源工作簿的哈希校验（配置表是活文档，以字段存在性为验证依据）。
- [tools/readback_report_template.md](tools/readback_report_template.md)：读回验收报告模板。验收报告必须逐条对照模板必达项填写 `pass|fail|not_applicable`，**禁止自拟另一套"全部通过"式清单替代模板**——`pass` 总数不能掩盖任何必达项缺失。

## 状态

- `DRAFT`：仍在收集事实、设计、等待确认或尚未写入。
- `PASS`：冻结的 change set 已写入，最终目标中的配置数据全部验收通过。
- `BLOCKED`：存在阻断项、写入失败或验收失败，目标文件保持写入前状态或已恢复。

`blocking_items` 必须清空后才能写入。`deferred_items` 可以保留，但必须排除在本次写入集合之外，且与写入项不存在依赖。只有 `PASS` 可以宣称任务完成。

## 1. 确定任务范围

选择一个或多个 `task_branches`：

- `create_workbook`：新建工作簿或在既有工作簿中新建运行时表；
- `schema_change`：增加、修改、移动或删除字段及其契约；
- `record_change`：按已确认主键增加、修改或删除记录。

记录目标文件、目标工作表、客户端/服务端范围、输入来源、预期交付物和明确排除项。用户只要求字段变更时，不扩展到记录变更。

当任务需要既有表证据时，按以下顺序确定 `config_root`：

1. 使用用户本次明确指定的目录；
2. 否则读取项目 profile 对应的本机配置文件；
3. 路径缺失、失效或不含 `.xlsx/.xlsm` 时询问用户，确认后更新本机配置。

新建运行时表必须有有效 `config_root`，用于取得真实引用 ID。仅整理规则或输出候选契约时可以没有目录，证据不足的内容保持候选或进入阻断项。

完成条件：每项用户意图均已归入分支，目标、非目标和必要的 `config_root` 均明确。

## 2. 建立证据与配置契约

证据范围是用户输入、用户提供的文档、目标工作簿、已确认 `config_root` 和用户明确要求读取的其他路径。代码消费方只有在用户明确提供或要求检查时才进入证据范围。

执行正向证据门：

1. 用户明确确认定义目标契约；
2. 当前目标工作簿定义变更前事实；
3. 用户提供的策划文档定义目标需求；
4. 项目 profile 只提供候选格式；按 profile 的字段级校验（`tools/check_pattern_fields.py`）通过时可作为已验证参考，字段缺失/改名时降级为 `candidate` 并登记 `profile_conflict`；
5. 无法解释且影响本次写入的冲突进入 `blocking_items`。

按照 [规则与 schema](references/rules_and_schema.md) 建立规则台账、字段 schema、结构化 codec、引用、约束和 `INDEX` 映射。每条规则至少关联一个契约目标，允许一条规则影响多个目标。

探查既有工作簿时必须读取单元格批注（`cell.comment`），优先运行附带工具 `tools/probe_workbook.py`；批注中的枚举含义、格式与边界规则按来源类型 `existing_comment` 登记进规则台账，不得只读单元格值就下契约结论。

完成条件：所有输入规则均有来源、证据状态、处理状态和目标；所有纳入写入的配置项均能追溯到规则。

## 3. 生成草案并通过确认门

按照 [change set 与确认](references/change_set.md) 生成候选配置契约、配置说明、字段批注、change set、风险、`blocking_items` 和 `deferred_items`。每项写入使用稳定 `change_id`，审批绑定具体 change 及其哈希；change 内容变化时，对应旧审批失效。

需要明确确认的内容包括中高风险变更、新建运行时表契约，以及主键、索引、codec、引用和输出映射。低风险的非语义说明、批注或格式变更可以自动确认。

完成条件：写入集合已经冻结，`blocking_items` 为空，所有必要审批覆盖当前 change 哈希；其余事项明确排除为 `deferred_items`。

## 4. 为新运行时表生成测试数据

只要任务新建运行时表，就必须按 [新表与配置测试数据](references/new_table.md) 生成测试记录；既有表的字段或记录变更不自动补测试数据。

测试数据写入新表第 6 行起的运行时数据区并进入正常导出链路，用于程序自测和联调，不代表最终正式数值。它必须写入 change set 并标记 `fixture: true`。符合已确认 schema 的测试数据无需逐行再次确认；若测试数据要求改变 schema，则返回确认门。

完成条件：每张新增运行时表至少有一条合法测试记录，真实引用、唯一键和声明的 `fixture_coverage` 全部可验证。

## 5. 写入与读回

实际写入遵循 [最小事务写入与验收](references/mutation_protocol.md)：已有文件先在目标目录生成备份，再写同目录临时文件；新文件直接从临时文件开始。临时文件的配置数据验收通过后才替换目标文件。

配置目录扫描排除名称包含 `.backup.`、`.tmp.`、`.failed.` 的工作簿；这些文件不能成为配置模式、引用或 `INDEX` 的证据来源。

验收报告必须按 [tools/readback_report_template.md](tools/readback_report_template.md) 逐条对照必达项（含「配置说明、字段批注写入项 100% 匹配」），每项标注 `pass|fail|not_applicable`；不得以自拟检查项的通过总数替代模板必达项。

完成条件：最终目标中的所有 change 和测试数据均已 100% 读回验证，不存在计划外配置数据差异；否则状态为 `BLOCKED`，不宣称完成。

## 最终交付

交付最终状态、目标文件或失败产物、规则台账、change set 与哈希、确认记录、配置 diff、测试数据清单、验收报告、阻断项、延期项和备份位置。
