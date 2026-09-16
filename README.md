# SR Team Skills（独立版）

SR 团队工作流 skill 独立仓：8 个目录（7 个 `sr-*` 工作流 skill + `sr-askme` 配置/教学中枢），每个 skill 的方法论与资源**全部内嵌在自身目录内**，对其它仓库无运行时依赖。安装与跨 agent 的同步由使用者自管，无安装脚本。

| skill | 用途 |
| --- | --- |
| `sr-askme` | **先看这个**：首次使用引导（收集并固化 workspace / Unity 工程 / 策划配置目录路径）+ 全系列使用教学 + 共享项目语境宿主 |
| `sr-concept` | 创新功能设计：一句话创意 → 设计核三角报告 → 拍板 → 完整功能设计 → 交接 sr-gdd |
| `sr-analysis` | 体验诊断 + 设计拆解复刻：录屏/截图/PV/商店页 → 证据链报告 → 判定 → 复刻规格 → 交接 sr-gdd |
| `sr-gdd` | 功能 GDD（完整溯源版）：实现粒度功能文档，带证据溯源、配置契约、治理引用 |
| `sr-gdd-human` | 功能 GDD（人类可读版）：只留设计结果，规则+界面线框详细可读 |
| `sr-gdd-html` | 评审宣讲 HTML：已定稿 GDD → 单文件自包含宣讲页 |
| `sr-config` | 策划配置数据契约：规则 → 可追溯可读回验收的配置变更 |
| `sr-config-heroskill` | 英雄技能配置：技能详细设计 → 副玩法技能表 |

## 安装

把 8 个目录**成组**装入任意 agent 会扫描的 skill 根（DSH / Claude Code / Codex 的用户级或项目级 skill 目录均可），保持兄弟目录关系：

```
<skill根>/
├── sr-askme/
├── sr-concept/
├── sr-analysis/
├── sr-gdd/
├── sr-gdd-human/
├── sr-gdd-html/
├── sr-config/
└── sr-config-heroskill/
```

注意：

- **必须成组安装**——各 skill 第 0 步会读 `../sr-askme/references/` 下的共享语境，单独拷走某个 skill 会报"找不到 sr-askme"；
- 同步/更新时直接镜像仓库目录即可；skill 文件内不含任何本机路径，覆盖安全。但 `sr-askme/config.local.json` 与 `sr-config/profiles/timemachine.local.yaml` 是运行时生成的本地文件，若你的同步方式会清空目标目录，先备份这两个文件；
- 本机已装过旧版 team-skills（含 `shared/` 目录或下划线旧目录 `sr_gdd` 等）的，可删除旧目录避免重复加载。

## 首次使用

任一 `sr-*` skill 运行时，第 0 步会检查 `sr-askme/config.local.json`；不存在时由 sr-askme 引导配置三项路径（可先运行 `python sr-askme/tools/detect_paths.py` 自动探测建议值），写入后固化、不再询问。也可以直接 `/sr-askme` 主动配置或查看教学。

## 使用教学

`/sr-askme` 输出流水线全景与各 skill 的触发语、Human Gate 选项、示例；逐 skill 的使用卡在 `sr-askme/references/teaching/`。

## 完整性与校验

- 各 skill 内嵌的方法论快照与方法卡的逐文件 SHA256 见 [CHECKSUMS.txt](CHECKSUMS.txt)——与文件实际哈希不一致即说明文件被就地修改过，应回退或重灌；
- `sr-gdd-html/resources/toolkit/` 为第三方工具包原样内置，校验信息见 [sr-gdd-html/resources/PROVENANCE.md](sr-gdd-html/resources/PROVENANCE.md)。

## License

MIT（见 [LICENSE](LICENSE)）。内嵌快照的许可随上游（MIT），版权头保留。
