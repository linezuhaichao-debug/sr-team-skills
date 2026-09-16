# sr-gdd-ai 使用卡：出功能 GDD（完整溯源版）

**什么时候用**："写策划案"、"出 GDD"、"把这个整理成功能文档"。

```
/sr-gdd-ai 基于 英雄改造v0.2.xlsx 出功能 GDD
```

裸 `/sr-gdd-ai` 会先要主题和上游材料。**没有哪份材料是硬性必须的**，最低输入是主题 + 一段能支撑规则粒度的描述；但"旧案（或同等详细度描述）+ 涉及配置表"齐备时效率最高。材料薄不阻塞——会触发决议问答，把关键取舍列成清单请你逐条拍板，**不替你做设计取舍**。

**成稿后 Human Gate**：

| 选项 | 含义 |
| --- | --- |
| `approve` | 批准，决策记录落盘为 accepted |
| `approve_with_conditions` | 有条件批准（条件写进备注） |
| `request_missing_evidence` | 缺上游材料，先补 |
| `revise` | 打回修改 |
| `reject` | 否决 |

**产出**（`sr_workspace\`）：功能 GDD 落 `proposals\<主题>_<日期>.md`；决策记录落 `decisions\`。

与 sr-gdd-human 的分工：本 skill 带证据溯源、配置契约、治理引用，适合正式立项留档。
