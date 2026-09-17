# sr-gtgenerator 使用卡：GTGenerator 配置维护（独立技能）

**什么时候用**："新增/修改/废弃 GID"、"加一条多语言文案 / Localizatio(n) 文案"、"生成 string_zh_CN.txt / APQualityMap.txt / Android 文本资源"、"翻译合并"。

```
/sr-gtgenerator 新增 GID <类型> <说明>
```

维护《文明之跃》GTGenerator 配置：GID 类型表（gtypes.xml）与多语言文本表（normaltxt.xml），并通过自带 CLI 导出 lua/Android 资源。内置类型映射表、key 自动生成（可带用户给的 key，先查重）、修改前后对比汇报。

**前置路径**：GTGenerator 工作目录（含 `gtypes.xml`/`normaltxt.xml`）取自 `sr-askme/config.local.json` 的 `gtgenerator_workdir`；缺失时本 skill 会问一次并写回固化，不要求先跑 `/sr-askme`。

**命令调用**（二选一）：首选 `gtgenerator ...`（pip 安装过的命令入口）；零安装回退 `python <skill目录>/scripts/gtgenerator.py ...`（Python ≥ 3.10，第三方依赖仅 click）。

**安全机制**：所有写操作自动备份到 `<工作目录>/.gtgen-backup/<时间戳>/`；`--dry-run` 可预演；未知 GID 类型绝不写入。

详细命令与流程见 skill 目录 `SKILL.md` 与 `scripts/` 内 CLI help。
