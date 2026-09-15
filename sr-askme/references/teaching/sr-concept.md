# sr-concept 使用卡：从创意到功能设计

**什么时候用**："我有个创意"、"想个新玩法"、"这个点子能不能做"。

```
/sr-concept 玩家可以回溯时间改写上一场战斗的结果
```

或直接说人话。裸 `/sr-concept`（不带创意）不会自动开始，会先要创意一句话和定位（本项目新功能 / 通用概念，默认项目内）。

**流程**：先复述创意并确认理解 → 产出**设计核三角报告**（concept seed、玩家动词清单、2~4 个 design nucleus 候选、假设台账、外部证据状态）→ 停在设计核门等你选择：

| 选项 | 含义 |
| --- | --- |
| `pick_nucleus_<编号>` | 选定设计核，进入第二阶段展开完整功能设计 |
| `merge_nuclei` | 合并候选，回炉调整 |
| `regenerate_options` | 候选都不行，重新生成 |
| `request_external_evidence` | 关键判断缺证据，先补最小验证 |
| `stop` | 终止 |

选定后展开**功能设计稿**（玩家承诺、核心循环、关键系统、scope gate、验证计划、配置项预测），迭代到认可后交接门选 `route_to_sr-gdd-ai` 自动生成交接材料。

**产出**（`sr_workspace\analysis\`）：concept-triage、feature-concept、sr-gdd-ai-handoff JSON；决策记录落 `decisions\`。
