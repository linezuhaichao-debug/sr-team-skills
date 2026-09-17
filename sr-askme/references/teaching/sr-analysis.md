# sr-analysis 使用卡：分析素材 / 拆解竞品

**职责**：从游戏素材（截图、录屏、PV、商店页、视频链接）出证据链诊断，你判定可参考后拆成可复刻的规格，交 `sr-gdd-human` 出成稿。

**什么时候用**："分析这段录屏"、"拆一下这个竞品玩法"、"这个功能能不能复刻"。

**怎么用**：

```
/sr-analysis D:\recordings\新手期首战.mp4
```

**产出**（`<SR_WORKSPACE>\` 下）：证据包落 `evidence\<主题>\`；`analysis\` 下 experience-report（体验报告）、issue-cards（问题卡）、replication-spec（复刻规格）、sr-gdd-handoff（交接 JSON）；决策记录落 `decisions\`。
