# 内嵌上游快照清单（VENDORED）

本仓各 skill 内嵌的上游文件快照。来源：`GameDesignOS-SR`（本地仓库 `D:\TimeMachine\GameDesignOS\GameDesignOS-SR`，fork 自 DY-2026/GameDesignOS）。

- **基线 commit**：`0855025`（Harden v1.3.0.dev0 portability and release readiness，上游引用版本）。截至快照日（2026-09-15），`0855025..HEAD` 之间上游目录仅 README 变更，SKILL.md / references / templates / contracts 零漂移。
- **校验**：下表 SHA256 与文件不一致 = 文件被就地修改过，应回退或走再同步流程。
- **蒸馏件**（非原样快照，不在校验范围）：`sr-concept/references/concept-method.md`、`sr-gdd/references/evidence-boundary.md`、三个 `references/governance-check.md`——均由对应上游 SKILL.md 提炼，提炼规则见各文件头注。
- **有意裁剪**：上游 examples/、evals/、assets/、agents/ 均为开发脚手架，运行时不用，未携带；vendored SKILL.md 改名 METHOD.md 以免被递归 loader 误认为独立 skill。METHOD.md 内部引用被裁剪目录（examples/evals）时，按"非运行时依赖"处理。

## 再同步（上游更新时）

1. 在来源仓库 `git fetch` 后确认要跟进的 commit；
2. 按下表清单重新复制对应文件，改名 SKILL.md → METHOD.md；
3. `sha256sum -c` 核对，有变化的更新本表；
4. 若上游结构变化（文件改名/增删 reference），同步修改对应 SKILL.md 的引用路径与本表；
5. 通知团队成员重新同步 skill 目录。

## 快照文件（49 个）

| 文件 | SHA256 |
| --- | --- |
| `sr-concept/references/game-concept-architect/METHOD.md` | `0ecb39819fdeeb87c4ea2d26e26a6d35b883e6ff0108dd09417fad191a843157` |
| `sr-concept/references/game-concept-architect/references/concept-seed-extraction.zh-CN.md` | `f77a7f32e977ef13731ba5c98e7e853f13b1e9c25c22262abf326bc3cb4664f2` |
| `sr-concept/references/game-concept-architect/references/core-loop-expansion.zh-CN.md` | `5b1544cae7898a131e48d30687a34bae838664a0f1daa64c0cc37535396d49fa` |
| `sr-concept/references/game-concept-architect/references/design-nucleus-options.zh-CN.md` | `9aef385645d3a87766e5c1f3c7da07fc0ff54433799b56db83af785e03387ea6` |
| `sr-concept/references/game-concept-architect/references/external-feasibility-scan.zh-CN.md` | `f5bb2b3e59417fec5e3e871069fa400036b20192aeaf9339b397b9f203097590` |
| `sr-concept/references/game-concept-architect/references/game-dissection-lens.zh-CN.md` | `552c4e7c8a59a4690708f443495b4fc05911eef05c75609040a40614583b025c` |
| `sr-concept/references/game-concept-architect/references/genre-fit-matrix.zh-CN.md` | `de95c1fc3990cf9fd69dcee9b05c82bc1403c9934272a250848eee0825d26683` |
| `sr-concept/references/game-concept-architect/references/platform-business-fit.zh-CN.md` | `fef69e5481a526746bda5a6a55ceb2fdf531441f9ff266a87e035f8e51802a8c` |
| `sr-concept/references/game-concept-architect/references/player-promise-framework.zh-CN.md` | `fdfa1c373c7b65a2641ec8fb6400d5e8ff29a379064e9a3a35e79ff5f18c631d` |
| `sr-concept/references/game-concept-architect/references/production-feasibility.zh-CN.md` | `aeca1b8ecc726749951f659c88606fb807b1765847d41a1a26bf6b162fca25b0` |
| `sr-concept/references/game-concept-architect/references/production-profile-gate.zh-CN.md` | `3c607d0b9bf19a46687a0dfe9f6f2f43809b120dcce5ba8c81c7deaf169a59ec` |
| `sr-concept/references/game-concept-architect/references/prototype-validation-gate.zh-CN.md` | `1acb0600a2f7e7d567f183d14c0e00f695355c239a2845be2c4cdac56a54b5a0` |
| `sr-concept/references/game-concept-architect/references/reference-game-boundary.zh-CN.md` | `470b2a30d4499b40c2b8669dc17981542e8b19b030645fd0dd7c8c943e9dc370` |
| `sr-concept/references/game-concept-architect/references/scope-gate.zh-CN.md` | `d995ada4064e2957520a004374da498d578dae982e3f7bd57c6456e9b8e0c988` |
| `sr-concept/references/game-concept-architect/references/voi-feasibility-gate.zh-CN.md` | `3de7e4d3f40355c3f47a8507bcbccddd11996bdd45adc401d0732ec1745411f1` |
| `sr-concept/references/game-concept-architect/templates/idea-triage.md` | `0851d65a55d9dc0f9d00a5d8a8f80097199cdeeef3b692c51fbe2568b430b788` |
| `sr-concept/references/decision.schema.json` | `c93cb1b6e357310bc158967d10c13ff39081a1540abfc9f069b2d4176342b0ac` |
| `sr-analysis/references/game-experience-analyzer/METHOD.md` | `e6af6e7fdc82c2eb7caf8615461521651c31620b4b30250b8ea075231d0a6231` |
| `sr-analysis/references/game-experience-analyzer/references/analysis-mode-router.yaml` | `1be70bba8cda59b564d97a1ab344b0f1056dcdd93f0f0fd0a4cc057c5a6f51bf` |
| `sr-analysis/references/game-experience-analyzer/references/diagnosis-pack-router.yaml` | `008739220ffc5de33441c48b7130d0dc961924a1bd2b9f7357841b5803ccaff9` |
| `sr-analysis/references/game-experience-analyzer/references/evidence-taxonomy.zh-CN.md` | `5254bdc3c936c5ae324df32acf3eb7300018992c04bc36d4c73d232ad45831b9` |
| `sr-analysis/references/game-experience-analyzer/references/foresight-opportunity-lens.zh-CN.md` | `f42c78472b233a6ed3c763656a5201aedaaddb8fc146e2f68d0a8048e71c55bd` |
| `sr-analysis/references/game-experience-analyzer/references/four-step-experience-method.zh-CN.md` | `5081dfcb82fe9a6aafc39f3f2d4afa1f7c7698a258937ef2dfb1af20cb0ccc60` |
| `sr-analysis/references/game-experience-analyzer/references/game-dissection-diagnosis.zh-CN.md` | `0c24c4a37ea6e1c1cc23cf435fa36eaec6070b2e99745819349b37464126109c` |
| `sr-analysis/references/game-experience-analyzer/references/genre-strategy-router.yaml` | `37c53c729794d3a8ed2fe77a3f58b3088e51cc593e6a34538d37387e01f2ceaf` |
| `sr-analysis/references/game-experience-analyzer/references/sample-scope-gate.zh-CN.md` | `c3456535c76835f80023dbca6abb4edcbe75253f7c3b408d5edcefba6cb9c03a` |
| `sr-analysis/references/game-experience-analyzer/references/single-player-analysis.zh-CN.md` | `1cc02f9c122a4b81e930367e215ef05caaed39b74e418eefd2cc6d2448e1085e` |
| `sr-analysis/references/game-experience-analyzer/references/system-design-review-lens.zh-CN.md` | `138078f650bec41e7ced113a6f0b4375bf1e9ded8bb90cd1d58688e99aa3b769` |
| `sr-analysis/references/game-experience-analyzer/references/tooling-setup.zh-CN.md` | `6c5344c11670661a2e5d0f0a0b42183f253324067e32b6d2fe45d97779dce8a3` |
| `sr-analysis/references/game-experience-analyzer/references/trailer-heat-prediction.zh-CN.md` | `ba5057bf59d5885e297d54870eb10261e8dae538305f97602b69acb76abd8b8b` |
| `sr-analysis/references/game-experience-analyzer/references/video-analysis-workflow.zh-CN.md` | `87cd340c8a87da19741bfa189db6492cb29d64dc0edf6701d1eb00e898a9e9a9` |
| `sr-analysis/references/game-experience-analyzer/templates/analysis-input.json` | `2d9468ab1accb8605936fcaa288ac38bca4a676521ffb743dbb4318ca2c11be0` |
| `sr-analysis/references/game-experience-analyzer/templates/consulting-diagnosis-report.md` | `ef233cf88ba0f82067fb528b850aa53e66d4991e117fd712119da08ad663bad8` |
| `sr-analysis/references/game-experience-analyzer/templates/ed-handoff.md` | `c10c25ed38d379cca72006bfa732bcce437aa8a0fafc568a264dac4bdc3134e6` |
| `sr-analysis/references/game-experience-analyzer/templates/evidence-index.schema.json` | `ce73f777c347695062e70655cd3c6674463d2e8fd3dfe210f3035a9d13a94e8b` |
| `sr-analysis/references/game-experience-analyzer/templates/experience-report.md` | `ca20c9d528cb0c5ee16bc0396b2fcd538112420549bea15f471ad3e5fe4c73ac` |
| `sr-analysis/references/game-experience-analyzer/templates/game-dissection-report.md` | `d3f6fe3d9e7fcd6c04429662a7544d9a55abc893cc830b685315cf6ac6518f00` |
| `sr-analysis/references/game-experience-analyzer/templates/issue-card.md` | `74522bde0c90bb2dfa99f8fb266cee2606c67db26c12d4f8d36323a1087a7501` |
| `sr-analysis/references/game-experience-analyzer/templates/mode-output-map.yaml` | `a32cbb0106e509d07c0e0060fc1e7e4266dec5e6c3fe050c89b6560b93108c2a` |
| `sr-analysis/references/game-experience-analyzer/templates/quick-triage-report.md` | `27bcfb9adadbdd3b1ba08556d8e1993787ce2ace0eeef74c0be47f6c978f794b` |
| `sr-analysis/references/game-experience-analyzer/templates/structured-output.example.json` | `6344cf736a1d52a78888826f03a598766458c210b30c00f811a05968a7962869` |
| `sr-analysis/references/game-experience-analyzer/templates/structured-output.schema.json` | `1bd0dcb3a28587e930f64bde59becd2b04f3514f36a9b3120d1f20734c226d17` |
| `sr-analysis/references/game-experience-analyzer/templates/trailer-heat-report.md` | `94c83be469a2d4ab4ce8d3911fad83e378e460588737031e76688f84d89c94e7` |
| `sr-analysis/references/game-experience-analyzer/templates/validation-plan.md` | `9097105153dd28bc5aa51bd8c907adc2f53d08a10bc4ab1a5a1224e8b22e5ce4` |
| `sr-analysis/references/game-experience-analyzer/templates/visual-evidence-card.md` | `62ce135579e30ef7ce672cb964b76cbdd7441dbbc913b430c2dd8e710d153ae2` |
| `sr-analysis/references/game-experience-density-optimizer/ed-handoff-contract.md` | `bbbee8eadc4aec3fe5694458f6f5c391e1727594bf55db9d470006e7401cbc78` |
| `sr-analysis/references/decision.schema.json` | `c93cb1b6e357310bc158967d10c13ff39081a1540abfc9f069b2d4176342b0ac` |
| `sr-gdd/references/decision.schema.json` | `c93cb1b6e357310bc158967d10c13ff39081a1540abfc9f069b2d4176342b0ac` |
| `sr-askme/references/decision.schema.json` | `c93cb1b6e357310bc158967d10c13ff39081a1540abfc9f069b2d4176342b0ac` |
