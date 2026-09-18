# SR Team Skills

SR（Strategy Runtime）团队的功能设计工作流 skill 集：从一句话创意或竞品素材出发，一路走到交给程序的配置化定稿。11 个目录（10 个 `sr-*` 工作流 skill + `sr-askme` 配置中枢），每个 skill 的方法论与资源全部内嵌在自身目录内，对其它仓库无依赖。

设计上贯穿三条纪律：

- **人管决策，agent 管执行**——每个 skill 在关键节点设 Human Gate，不替人做批准类决定；
- **设计语言与配置语言分离**——规则先写成人类可读的成稿，配置字段由 `sr-config` 从规则派生，两者再整合为交给程序的定稿；
- **一套共享语境**——数值铁律、三份产出的契约、撰写纪律等只维护一份，放在 `sr-askme`，其余 skill 按指针引用。

## skill 一览

| skill | 干什么 | 关键产出 |
| --- | --- | --- |
| `sr-askme` | 首次配置引导（固化本机路径）+ 使用教学；共享语境宿主 | `config.local.json` |
| `sr-concept` | 一句话创意 → 设计核候选报告 → 你拍板 → 完整功能设计 | 设计稿（`analysis\`） |
| `sr-analysis` | 录屏/截图/PV 素材 → 证据链分析报告 → 你判定 → 复刻规格 | 分析报告 / 复刻规格（`analysis\`） |
| `sr-gdd-human` | 把入口产出落成**成稿**：只有纯规则与设计，决策留痕在附录 A，供你审核 | `proposals\<主题>_<日期>.md` |
| `sr-config` | 从成稿规则**派生**配置字段与记录，最小事务写入，读回验收 | 配置工作簿（副本，不覆盖原表） |
| `sr-gdd-ai` | 把成稿 + 配置表**整合成定稿**：程序可实现的粒度，含配置契约与多语言文本条目 | `proposals\<主题>_<日期>_定稿.md` |
| `sr-gdd-review` | 对定稿做**只读审查**，出报告供你决定是否交程序；`sr-gdd-ai` 主线内置必经一步 | `proposals\<主题>_<日期>_审查.md` |
| `sr-gdd-fix` | 定稿通过后的**唯一改动入口**：影响面扫描 + 最小编辑 + 决策记录 | 定稿原地更新 |
| `sr-gdd-html` | 把定稿重排成评审会用的**单文件宣讲 HTML**（用户手动触发） | `proposals\<主题>_宣讲_<日期>.html` |
| `sr-config-heroskill` | 把【小世界】英雄技能详细设计配置进副玩法技能表（用户手动触发） | 配置副本 + 审查报告 + 变动行视图 |
| `sr-gtgenerator` | GID 类型与多语言文本的增删改、翻译合并、导出 string_zh_CN 等 | `gtypes.xml` / `normaltxt.xml` |

## 主线（推荐顺序）

```
                sr-askme
     配置引导 / 教学 / 共享契约宿主
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
    sr-concept              sr-analysis
  （一句话创意入口）      （竞品素材入口）
         │                       │
         └────► sr-gdd-human ◄───┘
              成稿：纯规则与设计
              [成稿门：你审核]
                     │
                     ▼
                 sr-config
        从规则派生配置字段与记录
                     │
                     ▼
                 sr-gdd-ai
          整合成定稿（status: pending）
                     │
                     ▼
               sr-gdd-review
        只读审查，报告随定稿一并呈门
                     │
                     ▼
          [定稿门：你批准 → active]
              │            │
              ▼            ▼
        sr-gdd-fix    sr-gdd-html
         定稿维护      评审宣讲
```

主线之外：

- **改定稿**一律走 `/sr-gdd-fix`（涉及配置表它会调 `/sr-config`）；改完想独立复核再跑 `/sr-gdd-review`。
- **`sr-gdd-html` 与 `sr-config-heroskill` 是用户调用型**——只能由人输入命令触发，agent 不会自动接手。
- **`sr-config-heroskill` 与 `sr-gtgenerator` 不依赖成稿**，可单独用于配置维护。

## 安装（本节写给 AI agent：照做即可完成）

**你的任务**：把本仓库的 11 个 `sr-*` 目录**成组**装进本机 agent 会扫描的**一个** skill 根。用户把本仓库交给你（给 URL 或给本地路径）时，读到这里就自己动手，不要把目录清单丢回给用户手抄。

**硬约束**（违反会让 skill 半残）：

- 11 个目录必须**成组、互为兄弟**装在同一父目录下——各 skill 第 0 步按相对路径读 `../sr-askme/references/`，少一个就读不到共享语境；
- **目录名不改、内部结构不动**（内嵌方法卡与脚本都按相对路径互相引用）；
- **只装一处**：同一批 skill 出现在两个 skill 根会造成版本漂移，日后不知道更新哪个；
- 装 skill **不需要** pip / npm / 任何依赖（唯一的例外是第 5 步的可选命令）。

**完成判据**：第 4 步校验输出 `OK`，且目标父目录确实是本机 agent 扫描的 skill 根。

### 1. 取到仓库文件

```bash
git clone https://github.com/linezuhaichao-debug/sr-team-skills.git "<仓库根>"
```

没有 git 或不能联网克隆时，取 zip 解压同样可用（解压出的 `sr-team-skills-main/` 就是仓库根）：

```
https://github.com/linezuhaichao-debug/sr-team-skills/archive/refs/heads/main.zip
```

用户已经给了本地仓库路径就直接用，别重复 clone。要装的 11 个目录：

```
sr-askme  sr-concept  sr-analysis  sr-gdd-human  sr-config  sr-gdd-ai
sr-gdd-review  sr-gdd-fix  sr-gdd-html  sr-config-heroskill  sr-gtgenerator
```

仓库根下的 `README.md`、`LICENSE`、`.gitignore`、`.gitattributes` 属于仓库自身，**不要**装进 skill 根。

### 2. 选一个 skill 根

不同宿主的扫描位置不同，下表只作候选，**选一个**：

| 级别 | 候选路径 |
| --- | --- |
| 用户级（默认，对所有项目生效） | `~/.agents/skills/`、`~/.claude/skills/`、`~/.dsh/skills/` |
| 项目级（只对该项目生效） | `<项目根>/.agents/skills/`、`<项目根>/.claude/skills/`、`<项目根>/.dsh/skills/` |

怎么定下"本机真正生效的那个根"，按顺序判断：

1. **反查你自己**：你这次会话已经加载了别的 skill（如 `memory-*`、`pdf`、`xlsx`）——找到它们的父目录，那就是有效根，优先装这里；
2. 候选目录**已存在且下面已有别的 skill**（含 `SKILL.md` 的子目录）→ 就是它；
3. 多个候选都命中 → **优先用户级**；只有用户明确说"只装到这个项目"才用项目级；
4. 一个都没有 → 建 `~/.agents/skills/`（跨 agent 通用约定），或问用户一句；
5. 宿主用别的路径（写在它自己的配置里）→ 以宿主为准。

### 3. 成组安装

把 `<仓库根>`、`<skill根>` 换成第 1、2 步定下的实际路径。

Windows（PowerShell）：

```powershell
$src = "<仓库根>"; $dst = "<skill根>"
$names = 'sr-askme','sr-concept','sr-analysis','sr-gdd-human','sr-config','sr-gdd-ai','sr-gdd-review','sr-gdd-fix','sr-gdd-html','sr-config-heroskill','sr-gtgenerator'
New-Item -ItemType Directory -Force $dst | Out-Null
foreach ($n in $names) {
  robocopy "$src\$n" "$dst\$n" /E /XD __pycache__ .pytest_cache /XF config.local.json timemachine.local.yaml /NFL /NDL /NJH /NJS
  if ($LASTEXITCODE -ge 8) { throw "robocopy 失败：$n（exit $LASTEXITCODE）" }
}
# 注意：robocopy 退出码 0–7 都算成功（1 = 有文件被复制），只有 ≥8 才是真失败
```

macOS / Linux：

```bash
SRC="<仓库根>"; DST="<skill根>"
for n in sr-askme sr-concept sr-analysis sr-gdd-human sr-config sr-gdd-ai \
         sr-gdd-review sr-gdd-fix sr-gdd-html sr-config-heroskill sr-gtgenerator; do
  mkdir -p "$DST/$n"
  rsync -a --exclude='__pycache__' --exclude='.pytest_cache' "$SRC/$n/" "$DST/$n/"
done
```

要点：

- **不要清空目标目录，也不要加 `--delete`**：`sr-askme/config.local.json` 与 `sr-config/profiles/timemachine.local.yaml` 是运行时生成的本机私有配置（在 `.gitignore` 里，**不在仓库中**），清目录会把它删掉；
- clone 出来的源里本来就没有这两个文件，所以覆盖式拷贝天然不会动它们；上面命令额外用 `/XF`、`--exclude` 兜底，防止源是**别人的本地目录**（可能含这两个文件）时被覆盖；
- skill 文件内不含任何本机路径，**覆盖安装安全**——更新就是重跑第 1、3 步；
- 别只装 `sr-askme` 或只装某一个：共享语境靠兄弟目录关系解析，缺一个就整体不可用。

### 4. 校验

Windows（PowerShell）：

```powershell
$dst = "<skill根>"
$names = 'sr-askme','sr-concept','sr-analysis','sr-gdd-human','sr-config','sr-gdd-ai','sr-gdd-review','sr-gdd-fix','sr-gdd-html','sr-config-heroskill','sr-gtgenerator'
$shared = 'sr_project_context.md','gdd-pipeline.md','gdd-writing-discipline.md','evidence-boundary.md','governance-check.md','decision-recording.md','bare-invocation.md','decision.schema.json'
$bad = @()
$bad += @($names | Where-Object { -not (Test-Path "$dst\$_\SKILL.md") })
$bad += @($shared | Where-Object { -not (Test-Path "$dst\sr-askme\references\$_") })
if ($bad.Count) { "缺失：$($bad -join ', ')" } else { "OK：11 个 skill + sr-askme 共享语境齐全（$dst）" }
```

macOS / Linux：

```bash
DST="<skill根>"; bad=""
for n in sr-askme sr-concept sr-analysis sr-gdd-human sr-config sr-gdd-ai \
         sr-gdd-review sr-gdd-fix sr-gdd-html sr-config-heroskill sr-gtgenerator; do
  [ -f "$DST/$n/SKILL.md" ] || bad="$bad $n"
done
for f in sr_project_context.md gdd-pipeline.md gdd-writing-discipline.md evidence-boundary.md \
         governance-check.md decision-recording.md bare-invocation.md decision.schema.json; do
  [ -f "$DST/sr-askme/references/$f" ] || bad="$bad sr-askme/references/$f"
done
[ -z "$bad" ] && echo "OK：11 个 skill + sr-askme 共享语境齐全（$DST）" || echo "缺失：$bad"
```

输出 `OK` 才算装好。报出缺失项就回第 3 步补齐；**不要**把缺的共享文件复制到别处充数——各 skill 认的路径是 `../sr-askme/references/`。

### 5. GTGenerator 的 Python CLI（可选，安装 skill 时不用做）

`sr-gtgenerator` 额外带一个 CLI（Python ≥ 3.10，第三方依赖仅 `click`），**零安装可用**：需要时直接跑

```bash
python "<skill根>/sr-gtgenerator/scripts/gtgenerator.py" --help
```

只有想让它在任何目录下以短命令 `gtgenerator` 调用时，才可选执行：

```bash
pip install -e "<skill根>/sr-gtgenerator/scripts"
```

### 6. 装完回报用户

按这个格式回，别写成一段散文：

```
已安装 sr 系列（11 个 skill）→ <skill根>
校验：OK（11 个 SKILL.md + sr-askme 共享语境齐全）
本机配置：{已存在，沿用 / 本次未生成}
下一步：先跑 /sr-askme 固化本机路径，再按主线用 /sr-concept 或 /sr-analysis 入口。
```

另外提醒用户两件事：

1. **宿主可能要重载 skill 列表**：多数宿主只在会话启动时扫描 skill 根（DSH 会自动感知文件变化），必要时让用户开个新会话，`/sr-*` 才会出现在命令列表里；
2. **首次使用先跑 `/sr-askme`**（见下节）——它才会去固化本机路径。

### 7. 卸载 / 重装

卸载 = 删掉 `<skill根>` 下这 11 个目录；重装 = 重跑第 1、3 步。删目录前先备份 `sr-askme/config.local.json` 与 `sr-config/profiles/timemachine.local.yaml`，否则本机路径配置要重问一遍。

## 首次使用

运行一次 `/sr-askme`：它会一次问清并固化本机路径（workspace / Unity 工程 / 策划配置目录 / GTGenerator 工作目录，最后一项仅 sr-gtgenerator 使用），写入后不再询问。之后任何一个 sr skill 启动时都会自查这些路径，缺失、为空或失效时自动引导补齐。

想了解某个 skill 怎么用，直接问 agent "sr 系列怎么用 / /sr-concept 是什么"，它会展开 `sr-askme/references/teaching/` 下对应的使用卡。

## 完整性与校验

- **内嵌的方法论文件以本机安装目录为准、改动即生效**，不另存哈希清单——哈希清单是需要人维护的缓存，会随每次改动腐化，而本仓库的 git 历史本身就在记录哪个文件被改过；
- `sr-gdd-html/resources/toolkit/` 是唯一的**原样内置、不得就地修改**的第三方件，其逐文件 SHA256 与再同步流程见 [sr-gdd-html/resources/PROVENANCE.md](sr-gdd-html/resources/PROVENANCE.md)。

## License

MIT（见 [LICENSE](LICENSE)）。内嵌方法论文件的许可随其原始授权（MIT），版权头保留。
