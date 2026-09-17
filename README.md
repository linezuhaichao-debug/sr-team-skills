# SR Team Skills

SR 团队工作流 skill 仓：9 个目录（8 个 `sr-*` 工作流 skill + `sr-askme` 配置中枢），每个 skill 的方法论与资源**全部内嵌在自身目录内**，对其它仓库无依赖。

| skill | 用途 |
| --- | --- |
| `sr-askme` | 首次配置引导（固化本机路径）+ 共享项目语境宿主 |
| `sr-concept` | 创新功能设计：一句话创意 → 设计核候选报告 → 拍板 → 功能设计稿 |
| `sr-analysis` | 体验诊断 + 竞品拆解：录屏/截图/PV → 证据链报告 → 复刻规格 |
| `sr-gdd-human` | 功能 GDD 成稿（中间产物）：设计结果可读 + 决策过程留痕，供审核确认 |
| `sr-config` | 策划配置落地：按 GDD 把规则写成配置表变更，带读回验收 |
| `sr-gdd-ai` | 功能 GDD 定稿（最终交付物）：整合成没有决策过程的干净 GDD，交给程序 |
| `sr-gdd-html` | 评审宣讲 HTML：定稿 GDD → 单文件自包含宣讲页 |
| `sr-config-heroskill` | 英雄技能配置（独立技能）：技能详细设计 → 副玩法技能表 |
| `sr-gtgenerator` | GTGenerator 配置（独立技能）：GID 与多语言文本的新增/废弃/修改、导出 lua/Android 资源，自带 Python CLI |

## 推荐使用顺序

```
/sr-concept 或 /sr-analysis      ← 入口二选一：有创意走前者，有竞品素材走后者
        │
        ▼
/sr-gdd-human                    ← 生成过程层工作文档（可读结果 + 决策留痕，供审核确认）
        │
        ▼
/sr-config                       ← 根据 GDD 写成配置表
        │
        ▼
/sr-gdd-ai                       ← 整合成干净定稿（无决策过程，交给程序）
        │
        ▼
/sr-gdd-html                     ← 出评审会用的宣讲 HTML
```

所有 skill 也可以单独调用（如直接 `/sr-gdd-ai 基于 旧策划案.xlsx 出功能 GDD`）；`/sr-config-heroskill` 与 `/sr-gtgenerator` 独立使用，不在主线里。

## 安装

把 9 个目录**成组**装入任意 agent 会扫描的 skill 根（用户级或项目级均可），保持兄弟目录关系——各 skill 第 0 步会读 `../sr-askme/references/` 下的共享语境，单独拷走某个 skill 不可用。

`sr-gtgenerator` 额外带一个 Python CLI（Python ≥ 3.10，第三方依赖仅 click）。**零安装可用**：Agent 会自动回退到 `python sr-gtgenerator/scripts/gtgenerator.py ...` 调用；想用全局短命令 `gtgenerator` 可选执行 `pip install -e sr-gtgenerator/scripts`。

同步/更新时直接镜像仓库目录即可；skill 文件内不含任何本机路径，覆盖安全。`sr-askme/config.local.json` 与 `sr-config/profiles/timemachine.local.yaml` 是运行时生成的本地文件，若同步方式会清空目标目录，先备份这两个文件。

## 首次使用

运行一次 `/sr-askme`：它会收集并固化本机路径（workspace / Unity 工程 / 策划配置目录 / GTGenerator 工作目录，最后一项仅 sr-gtgenerator 使用），写入后不再询问。

## 完整性与校验

- 各 skill 内嵌的方法论快照与方法卡的逐文件 SHA256 见 [CHECKSUMS.txt](CHECKSUMS.txt)——与文件实际哈希不一致即说明文件被就地修改过，应回退或重灌；
- `sr-gdd-html/resources/toolkit/` 为第三方工具包原样内置，校验信息见 [sr-gdd-html/resources/PROVENANCE.md](sr-gdd-html/resources/PROVENANCE.md)。

## License

MIT（见 [LICENSE](LICENSE)）。内嵌快照的许可随其原始授权（MIT），版权头保留。
