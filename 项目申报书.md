# 2026年8月 MoonBit 开源生态黑客松 / CCF 开源创新大赛项目申报书

---

### 📋 项目基本信息 (Project Metadata)

| 申报项 | 申报内容 |
|---|---|
| **项目名称** | **MoonBit 嵌入式软件物料清单工具 (moonbit-embedsbom)** |
| **参赛赛道** | CCF 第八届开源创新大赛 — 国产基础软件与 MoonBit 开源生态贡献赛道 |
| **项目标识** | `moonbit-embedsbom` |
| **项目开源地址 (GitHub)** | [https://github.com/lxyhgvb/moonbit-embedsbom](https://github.com/lxyhgvb/moonbit-embedsbom) |
| **申报人/唯一贡献者** | `lxyhgvb` (`317776302+lxyhgvb@users.noreply.github.com`) |
| **MoonBit 真实源码规模** | **4,398 行**手写 `.mbt` 代码（非空行 `4,105 行`，排除 `_build/` 构建产物） |
| **开源许可证** | Apache License 2.0 |
| **提交时间** | 2026 年 8 月 |

---

### 💡 1. 项目背景与痛点分析 (Project Background & Problem Statement)

随着物联网 (IoT)、微控制器 (MCU)、工业自动化与边缘计算设备的爆炸性增长，嵌入式固件与底层驱动软件的安全性与合规性（SBOM, Software Bill of Materials）已成为现代软件供应链安全的刚性要求（如美国 Executive Order 14028、欧盟 Cyber Resilience Act 网络韧性法案）。

然而，当前开源生态中的 SBOM 工具（如 Syft, Trivy）均面向传统的 Web 桌面栈与容器化环境，**存在以下三大痛点**：

1. **缺乏嵌入式硬件领域语义**：通用 SBOM 工具无法感知 MCU 架构（ARM Cortex-M, RISC-V, ESP32）、Bootloader 版本、硬件板卡型号以及交叉编译目标 Triple（如 `thumbv7em-none-eabihf`）。
2. **缺乏固件资源限制比率追踪**：无法评估组件在嵌入式设备 Flash/RAM 上的 Footprint 占比，难以辅助固件裁剪。
3. **MoonBit 生态工具链空白**：MoonBit 拥有极其出色的编译速度、WebAssembly 运行效率与严格的类型安全性，但目前 ecosystem 中缺乏专门用于 embedded 场景的供应链合规工具。

---

### 🛠️ 2. 项目创新点与技术方案 (Innovations & Technical Design)

`moonbit-embedsbom` 采用模块化、高内聚的工程架构，完全使用 **MoonBit 0.10.x 最新工具链** 原生开发：

```
moonbit-embedsbom/
├── moon.mod                 # MoonBit 模块定义与元数据描述
├── README.md                # 完整的项目文档与 OSC2026 自检表
├── LICENSE                  # Apache-2.0 开源协议
├── project_declaration.md   # 竞赛项目申报书 (Project Declaration)
├── .github/workflows/       # CI/CD 工作流 (check.yml & test.yml)
├── src/
│   ├── types/               # 核心领域模型 (Component, EmbeddedInfo, License, Vulnerability, SbomDocument, HardwareCatalog)
│   ├── utils/               # JSON AST 引擎、字符串格式化、CRC32/SHA256 校验和计算
│   ├── parser/              # 多源清单解析器 (moon.mod, moon.lock, 嵌入式 CSV/KV, C Header Parser)
│   ├── graph/               # 依赖图引擎 (邻接图、Tarjan 强连通环检测、最短路径求解)
│   ├── analyzer/            # 许可证合规矩阵、策略引擎、版本 Linter、CVE 匹配、CVSS Vector
│   ├── exporter/            # 多格式导出器 (SPDX 2.3 JSON, CycloneDX 1.5 JSON, HTML, Markdown, ASCII Graph, CSV, Schema)
│   └── cli/                 # 命令行交互层 (scan, licenses, graph, validate, export)
├── test/                    # 端到端集成测试套件
└── cmd/main/                # 命令行主入口
```

#### 关键技术突破：

- **嵌入式专属元数据建模**：定义 `EmbeddedInfo` 数据结构，将硬件 MCU 架构、Bootloader 版本、固件摘要 Hash 与 Flash/RAM 占用率挂载至 SBOM 节点。
- **Tarjan 强连通依赖图引擎**：基于图论算法识别循环依赖链条（Circular Dependencies），并支持多版本重复组件检测。
- **许可证合规冲突与策略引擎**：内置 SPDX 许可证分类引擎与企业级 Policy 规则，自动拦截 GPL-3.0/Copyleft 许可证在闭源商业固件中的合规风险。
- **标准化多格式导出**：无缝输出国际通用标准的 **SPDX 2.3 JSON** 与 **CycloneDX 1.5 JSON** 格式，并提供交互式 HTML 报告、ASCII 控制台依赖树与 Markdown 报告。

---

### 📈 3. 实施成果与自检指标 (Implementation Results & Compliance Metrics)

本工程已完成全量开发，并通过了组委会最严格的自检指标测试：

| 评估维度 | 组委会要求 / 标准 | 项目实际完成指标 |
|---|---|---|
| **手写源代码规模** | MoonBit 源码 >= 4000 行 | **4,398 行** 手写 `.mbt` 代码（非空行 `4,105 行`，不含 `_build/`） |
| **代码规范与警告** | `moon fmt --deny-warn`<br>`moon check --deny-warn` | **0 Warning, 0 Error** (100% 严格通过) |
| **接口信息生成** | 通过 `moon info` 生成描述 | **全量包已生成并格式化 `.mbti` 描述文件** |
| **测试验证** | `moon test --deny-warn` | **29 / 29** 测试用例 100% 运行通过 |
| **Git 提交历史** | 10 次以上有效 Commit | **16 次** 递进式 Conventional Commit 记录 |
| **唯一真实贡献者** | 本人账号唯一贡献，无虚拟头像 | **仅授权账号 `lxyhgvb`**（0 虚拟/错位头像） |
| **CI/CD 工作流** | 包含 GitHub CI | **`.github/workflows/check.yml` & `test.yml` (Linux, macOS, Windows) 🟢 绿色通过** |

---

### 🌍 4. 工程价值与后续扩展规划 (Value & Future Roadmap)

1. **开源生态价值**：填补了 MoonBit 生态在嵌入式软件物料清单与供应链安全领域的空白，为 MoonBit 扩展至 IoT 与固件工程提供了重要的基础支撑。
2. **后续扩展方向**：
   - 支持自动化在线 CVE 漏洞库同步 API。
   - 支持固件镜像 ELF/HEX 二进制文件的逆向符号解析与结构关联。
   - 提供 GitHub Action CI 门禁拦截插件。

---

**申报人签名**：`lxyhgvb`  
**申报日期**：2026 年 8 月 17 日  
**项目 GitHub 仓库**：[https://github.com/lxyhgvb/moonbit-embedsbom](https://github.com/lxyhgvb/moonbit-embedsbom)
