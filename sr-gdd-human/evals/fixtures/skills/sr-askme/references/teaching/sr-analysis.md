# sr-analysis 使用卡：分析素材 / 拆解竞品

**什么时候用**："分析这段录屏"、"拆一下这个竞品玩法"、"这个功能能不能复刻"。

```
/sr-analysis D:\recordings\新手期首战.mp4
```

裸 `/sr-analysis` 会先要素材路径和分析目标。素材支持：截图、录屏文件、PV/宣传片、商店页、视频链接。

**流程**：先确认"这次分析要改变什么决策"（VOI 门）→ 声明样本能证明什么、不能证明什么 → 产出**证据链报告**（体验报告 + 问题卡）→ 停在报告门：

| 选项 | 含义 |
| --- | --- |
| `accept_diagnosis` | 接受诊断结论，结束 |
| `enter_dissection` | 判定可参考，进入设计拆解，产出复刻规格 |
| `request_more_evidence` | 证据不足，补素材再来 |
| `route_to_ed_experiment` | 转交体验密度优化实验 |
| `revise_player_promise` | 回头修订玩家承诺 |
| `stop` | 终止 |

`enter_dissection` 后拆出**复刻规格**（迁移边界必须保留：题材/美术/IP/具体数值/运营节奏不得照搬），交接门 `route_to_sr-gdd-ai` 生成交接材料。

**产出**（`sr_workspace\`）：证据包落 `evidence\`；报告/问题卡/复刻规格/交接 JSON 落 `analysis\`。
