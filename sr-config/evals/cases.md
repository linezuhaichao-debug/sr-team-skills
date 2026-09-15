# sr-config 回归案例

本文件用于维护 Skill，不在普通配置任务中加载。每个案例都检查任务分支、证据状态、写入集合、最终状态和必须产出的审计字段。

## E01 新建运行时表

给定有效 `config_root`，新建一张包含枚举、codec 和真实外键的运行时表。

预期：选择 `create_workbook`；生成五行表头、`INDEX`、说明、批注和至少一条第 6 行起的测试记录；测试记录进入正常导出链路，标记 `fixture: true`，引用真实存在；全部读回后为 `PASS`。

## E02 既有表字段变更

给定已有工作簿，只要求新增一个已确认字段和批注。

预期：只选择 `schema_change`；不自动新增测试记录；field diff 包含 before/after、证据、风险、change hash 和审批；所有变更列全量读回。

## E03 混合分支

给定同一请求同时移动字段并修改一条已确认主键记录。

预期：同时选择 `schema_change` 和 `record_change`；move 包含 from/to；两个 change 分别记录风险、审批和验证；任一 change 失败都不替换目标文件。

## E04 deferred 不阻断独立变更

给定一个已确认的批注修复，以及一个与其无依赖、尚未确认的候选字段。

预期：批注进入写入集合；候选字段进入 `deferred_items` 并明确排除；只要不存在依赖，批注修改可以达到 `PASS`。

## E05 缺少本机配置目录

给定 `timemachine.local.yaml` 缺失、路径失效，且任务需要既有表证据。

预期：询问用户提供目录；确认前保持 `DRAFT`；不扫描其他目录，不创建备份、临时文件或写入项。用户无法提供必要目录时为 `BLOCKED`。

## E06 profile 哈希冲突

给定模式来源文件存在，但 SHA-256 与 profile 记录不一致。

预期：产生 `profile_conflict`；模式由 `verified` 降级为 `candidate`；不自动更新哈希；依赖该模式的写入进入确认门。

## E07 测试数据缺少真实引用

给定新表测试数据需要道具 ID，但 `config_root` 中找不到满足引用契约的真实主键。

预期：不生成随机 ID 或按号段猜测；产生 blocker；不写入目标文件；结果为 `BLOCKED`，报告准确列出缺失的工作簿、工作表、字段和空值策略。

## E08 临时文件读回失败

给定临时文件写入成功，但读回时发现字段错位、批注缺失、引用无效或计划外配置数据变化。

预期：不替换目标文件；失败产物改名为 `.failed.`；保留备份和报告；状态为 `BLOCKED`。

## E09 三种任务状态

分别给定仍待确认的草案、全部验证通过的写入、存在未解决 blocker 的写入。

预期：唯一状态依次为 `DRAFT`、`PASS`、`BLOCKED`；只有 `PASS` 可以宣称任务完成。

## E10 权重模式不可混用

给定整数 `baseweight` 字段和另一个 `entry_gid,weight` 需求。

预期：前者匹配已验证的 `weight_scalar`；后者只匹配候选 `weighted_pair`；二者不因都包含“权重”而合并，也不解释为百分比。

## E11 change 修改使审批失效

给定已确认的 change，随后修改其 before/after、codec、引用或风险。

预期：重新计算 `change_hash`；原 approval 标记 `stale`；重新确认前保持 `DRAFT`，不得写入。

## E12 新表测试数据无需逐行确认

给定新表 schema 已确认，测试记录完全符合该 schema，主键唯一且引用真实存在。

预期：fixture change 使用 `basis: confirmed_schema` 自动确认；仍完整记录测试值、主键、覆盖范围和验证结果；若测试记录要求改变 schema，则返回确认门。
