# sr-config 使用卡：策划规则落配置数据

**什么时候用**："把这条规则落成配置表"、"给这张表加个字段"、"建一张新配置表"。

```
/sr-config 给英雄基础表加一个"碎片合成所需数量"字段
/sr-config 新建一张神话宝库里程碑表
```

只验收最终配置数据（运行时表与五行表头、字段与记录、主键与索引、枚举、codec、引用、INDEX、配置说明、字段批注、新表测试数据）。

**流程**：确定任务范围（新建表/字段变更/记录变更三选一或多选）→ 建立证据与契约（**必须读取单元格批注**，附 `tools/probe_workbook.py` 标准探查工具）→ 生成 change set 过确认门 → 新表自动生成测试数据 → 备份-写入-读回 100% 验收（附 `tools/readback_report_template.md` 模板）。

**状态机**：`DRAFT → PASS / BLOCKED`，`blocking_items` 清空才能写入，只有 `PASS` 算完成。

**配置根目录**：写在 `sr-config/profiles/timemachine.local.yaml`（首次配置由 sr-askme 生成；含私有路径不入仓库，参照同目录 `timemachine.local.example.yaml` 手工创建亦可）。
