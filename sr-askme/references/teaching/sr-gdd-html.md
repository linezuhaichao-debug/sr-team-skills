# sr-gdd-html 使用卡：评审宣讲 HTML

**什么时候用**："出评审会用的 HTML"、"把策划案做成宣讲页"。

```
/sr-gdd-html D:\GameDesignOS\workspace\proposals\英雄升级功能优化_人类可读版_20260902.md
```

裸 `/sr-gdd-html` 会先要源 GDD、宣讲范围和截图目录。**输入必须是已定稿的 GDD**——喂体验报告/复刻规格/会议纪要会被挡回来，先走 sr-gdd / sr-gdd-human 成稿。GDD 若没有"一个界面一节"的界面清单，也会停下来问，不硬凑。

**流程**：结构抽取（GDD → content.json）→ 截图准备 → 红线校验（lint_content.py）→ 渲染单文件 HTML → 视觉冒烟（smoke_check.mjs）→ 评审门。

三条硬约束：**只搬运不发明**（内容全来自源 GDD，改一处文案从 content.json 重跑）、**只放最终规则**（禁确认编号/用户原话/"拍板·已确认"过程措辞）、**单文件自包含**（截图 base64 内嵌、禁外链、禁散装资源目录；无图给指路占位框）。

**Human Gate**：`approve` / `revise` / `resupply_screenshots` / `reject`。

**产出**（`sr_workspace\proposals\`）：HTML 与同名 content.json 成对留档；决策记录落 `decisions\`。
