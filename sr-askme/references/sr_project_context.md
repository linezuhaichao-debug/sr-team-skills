# SR 项目语境（写策划案前必读）

## 项目

- **文明之跃（Leaps of Civilization）**：移动端 SLG 策略手游
- 引擎 Unity 2022.3.62f2 + URP；C#（引擎层/确定性 sim）+ Lua/XLua（热更玩法逻辑），C# 热更经 HybridCLR
- 目标平台 Android/iOS

## 数值铁律

- 所有玩法数值 **data-driven**，**禁止硬编码**
- 配置来源分两处：通用玩法配置在 `<SR_PROJECT>/Assets/HotRes/Lua/LuaConfigs/`；RPG 战斗引擎（RPGBattleModule）单独读取 `<SR_PROJECT>/Assets/HotRes/RPGGame/RPG_Configs/`
- 多语言文本表在 `<SR_PROJECT>/Assets/HotRes/Lua/Locale/`，设计阶段默认使用 `string_zh_CN`；文案引用只标键名即可（内部默认走 `string_zh_CN`），未建键的文案标"待配表"
- 策划案中出现的每个数值必须标注来源：`配表名.字段名`；还没有配表的标注"待配表"
- 公式必须写出变量定义，不得只给结论数字

## 写作约束

- 中文写作；术语与项目代码命名保持一致（如 Buff、Handler、Manager 不翻译）
- 涉及战斗系统的设计，注意区分两种战斗，RPG战斗和SLG战斗
- gdd里不要出现具体的代码、技术选型、程序实现等程序同学需要考虑的内容
- 多语言 name/desc 键一律用项目通用格式，**禁止自造** `xxx_name_<id>` / `xxx_desc_<id>` 类键名：名称 `n{id}`、描述 `d{id}`（对应 `MultiLanguage` 的 `GetGIDNameId` / `GetGIDDescriptionId`，运行时 `i18n("n"..id)` / `i18n("d"..id)`）；`id` 取该实体配置的主键——如英雄取 `gid`，天赋取 `talentId`

## 受众默认

未特别说明时，策划案受众为本团队内部（策划 + 程序），不是对外 pitch。
