# SR Team Skills

SR 团队工作流 skill 仓：11 个目录（10 个 `sr-*` 工作流 skill + `sr-askme` 配置中枢），每个 skill 的方法论与资源**全部内嵌在自身目录内**，对其它仓库无依赖。

| skill | 用途 |
| --- | --- |
| `sr-askme` | 首次配置引导（固化本机路径）+ 共享语境宿主（三产出契约、撰写纪律、证据边界、治理检查均在此单份维护） |
| `sr-concept` | 创新功能设计：一句话创意 → 设计核候选报告 → 拍板 → 功能设计稿 |
| `sr-analysis` | 体验诊断 + 竞品拆解：录屏/截图/PV → 证据链报告 → 复刻规格 |
| `sr-gdd-human` | 功能 GDD 成稿（中间产物）：纯规则与设计（零配置内容），决策留痕在附录 A，供审核确认；定稿通过后归档 |
| `sr-config` | 策划配置落地：从成稿规则派生配置字段与记录，带读回验收 |
| `sr-gdd-ai` | 功能 GDD 定稿（最终交付物）：综合成稿与配置表的干净整合稿，交给程序；定稿后唯一的活文档 |
| `sr-gdd-fix` | 定稿修订（独立技能）：定稿之后的唯一改动入口，最小编辑 + 影响面扫描 |
| `sr-gdd-review` | 定稿审查（独立技能）：只读审查出报告（ai 主线内置必经一步），修复转 sr-gdd-fix |
| `sr-gdd-html` | 评审宣讲 HTML：定稿 GDD → 单文件自包含宣讲页 |
| `sr-config-heroskill` | 英雄冒险技能配置 |
| `sr-gtgenerator` | GID / 多语言增删改 |

## 推荐使用顺序

```
             sr-askme
    配置引导 / 教学 / 共享契约宿主
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
   sr-concept              sr-analysis
    创意入口                 素材入口
        │                       │
        └────► sr-gdd-human ◄───┘
               纯规则成稿
                   │
                   ▼
               sr-config
          配置字段 / 记录 / 验收
                   │
                   ▼
               sr-gdd-ai
                首次定稿
               │        │
               ▼        ▼
         sr-gdd-fix   sr-gdd-html
         定稿维护      评审宣讲


独立技能：
   sr-config-heroskill — 英雄冒险技能配置
   sr-gtgenerator       — GID / 多语言增删改
```

## 安装

把 11 个目录**成组**装入任意 agent 会扫描的 skill 根（用户级或项目级均可），保持兄弟目录关系——各 skill 第 0 步会读 `../sr-askme/references/` 下的共享语境与共享卡，单独拷走某个 skill 不可用。

`sr-gtgenerator` 额外带一个 Python CLI（Python ≥ 3.10，第三方依赖仅 click）。**零安装可用**：Agent 会自动回退到 `python sr-gtgenerator/scripts/gtgenerator.py ...` 调用；想用全局短命令 `gtgenerator` 可选执行 `pip install -e sr-gtgenerator/scripts`。

同步/更新时直接镜像仓库目录即可；skill 文件内不含任何本机路径，覆盖安全。`sr-askme/config.local.json` 与 `sr-config/profiles/timemachine.local.yaml` 是运行时生成的本地文件，若同步方式会清空目标目录，先备份这两个文件。

## 首次使用

运行一次 `/sr-askme`：它会收集并固化本机路径（workspace / Unity 工程 / 策划配置目录 / GTGenerator 工作目录，最后一项仅 sr-gtgenerator 使用），写入后不再询问。

## 完整性与校验

- **各 skill 内嵌的方法论快照以安装目录为准、改动即生效**（上游仓库版本仅供比对），因此不另存哈希清单——哈希清单是一份需要人维护的缓存，会随每次就地标注而腐化，而本仓库的 git 历史本身就在记录"哪个文件被改过"；
- `sr-gdd-html/resources/toolkit/` 是唯一的**原样内置、不得就地修改**的第三方件，其逐文件 SHA256 与再同步流程见 [sr-gdd-html/resources/PROVENANCE.md](sr-gdd-html/resources/PROVENANCE.md)。

## License

MIT（见 [LICENSE](LICENSE)）。内嵌快照的许可随其原始授权（MIT），版权头保留。
