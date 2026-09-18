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

## 安装

把 11 个目录**成组**装入任意 agent 会扫描的 skill 根（用户级或项目级均可），保持兄弟目录关系——各 skill 第 0 步会读 `../sr-askme/references/` 下的共享语境，单独拷走某个 skill 不可用。

`sr-gtgenerator` 额外带一个 Python CLI（Python ≥ 3.10，第三方依赖仅 click）。**零安装可用**：agent 会自动回退到 `python sr-gtgenerator/scripts/gtgenerator.py ...` 调用；想用全局短命令 `gtgenerator` 可选执行 `pip install -e sr-gtgenerator/scripts`。

同步/更新时直接镜像仓库目录即可；skill 文件内不含任何本机路径，覆盖安全。`sr-askme/config.local.json` 与 `sr-config/profiles/timemachine.local.yaml` 是运行时生成的本地文件，若同步方式会清空目标目录，先备份这两个文件。

## 首次使用

运行一次 `/sr-askme`：它会一次问清并固化本机路径（workspace / Unity 工程 / 策划配置目录 / GTGenerator 工作目录，最后一项仅 sr-gtgenerator 使用），写入后不再询问。之后任何一个 sr skill 启动时都会自查这些路径，缺失、为空或失效时自动引导补齐。

想了解某个 skill 怎么用，直接问 agent "sr 系列怎么用 / /sr-concept 是什么"，它会展开 `sr-askme/references/teaching/` 下对应的使用卡。

## 完整性与校验

- **内嵌的方法论文件以本机安装目录为准、改动即生效**，不另存哈希清单——哈希清单是需要人维护的缓存，会随每次改动腐化，而本仓库的 git 历史本身就在记录哪个文件被改过；
- `sr-gdd-html/resources/toolkit/` 是唯一的**原样内置、不得就地修改**的第三方件，其逐文件 SHA256 与再同步流程见 [sr-gdd-html/resources/PROVENANCE.md](sr-gdd-html/resources/PROVENANCE.md)。

## License

MIT（见 [LICENSE](LICENSE)）。内嵌方法论文件的许可随其原始授权（MIT），版权头保留。
