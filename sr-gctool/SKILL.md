---
name: sr-gctool
description: 导出《文明之跃》策划配置表为游戏运行时配置（Server XML / Client Lua / list.txt）。当用户改完 planner/策划配置 下的 .xlsx/.xlsm 表后说"导出""出配置""生成配置""跑一下 GCTools""确认可以导出"，或点名导出某个表（如"导出科技表""把 A003 出出去"），或要求"全量导出""重新导出""更新配置"时使用——即使用户没提"GCTools"这个词，只要意图是把策划表变成游戏配置就触发。是 sr 工作流中 /sr-config 写完配置表之后的出包步骤。
---

# 策划配置导出（sr-gctool）

用 `cli-anything-gctools` 把 `D:\TimeMachine\planner\策划配置\` 的 Excel 配置表导出为游戏运行时配置（`Server/*.xml`、`Client/*.txt`、`Client/View/*.txt`、`Client/list.txt`）。该工具是 GCTools.exe 的无头等价物，输出与真实工具逐字节一致。

## 第一步：确定导出范围（从上下文推断，不要反问）

- **用户点名了具体表**（"导出科技表""A003 出一下"）→ 单表导出。中文表名先解析成文件名：`cli-anything-gctools workbooks list` 或在配置目录 `ls` 找到形如 `A003-科技表.xlsm` 的文件。如果本次会话就是你改的表，直接用你改过的那个文件名。
- **本次会话只改了已有表的单元格内容，用户确认可以导出** → 只导改过的那几张表（单表约 1~2 秒/张，全量约 20 秒）。
- **用户说"全量/全部导出"，或本次会话增删过 INDEX 条目（新增/删除了配置表）** → 全量导出。
- **拿不准是否动过 INDEX 结构** → 全量导出，宁可慢不可漏。

范围判据的原因：`export file` 不清空输出目录、**不重新生成 `Client/list.txt`**；只有 `export run` 会。增删过表时若只做单表导出，客户端索引会过期。

## 导出流程

工作目录固定用 `D:\TimeMachine\planner\策划配置`（`config` 文件在那里，工具靠它知道输入/输出目录）：

```bash
cd "D:\TimeMachine\planner\策划配置"

# 1. 先体检（不写盘，有 error 就停在这里）
cli-anything-gctools validate all --json

# 2a. 全量导出
cli-anything-gctools export run --json

# 2b. 单表导出（每张表执行一次）
cli-anything-gctools export file "A003-科技表.xlsm" --json
```

## 结果判读与汇报

解析 `--json` 输出，向用户汇报：

- `ok: true` → 报告导出文件数（`written_count`）和输出位置（`out_path`）。若做的是单表导出且本次没增删表，不需要提 list.txt；只有用户问起或增删过表时才提醒。
- `ok: false` → 逐条列出 `errors`（含工作簿、条目、原因，如"文件名重复"），**不要**自行修改用户的表，把错误原文交给用户，等用户决定怎么改。validate 阶段失败（如"简写字段名重复"）同样停下汇报，不进入导出。

## 导出错了要回退

```bash
cli-anything-gctools session undo --json
```

恢复被覆盖/删除的文件，删除新生成的文件。用户说"导出错了""撤回""恢复"时用它。默认导出（没加 `--no-session`）都有 undo 记录，单表和全量都是。

## 注意

- 全量导出会**先清空** `OutPut/` 下的旧 xml/txt 再重建——这是与真实 GCTools.exe 一致的行为，不是事故；出了问题用 session undo。
- 其他配置目录变体（`策划配置1.0`、`策划配置zc`、`策划配置zhc`）同样适用：先 cd 过去或用 `cli-anything-gctools -w <目录> ...`。
- 工具完整参考（全部命令、字段语义、已知踩坑）见 `tools/gctools/agent-harness/skills/cli-anything-gctools/SKILL.md`。
