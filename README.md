# B2B Parts Demand Patterns

An AI-assisted, reproducible Power BI portfolio project based on the anonymized [B2B-Parts-Rec v1](https://zenodo.org/records/19492687) dataset. It examines customer concentration, item-request frequency, and repeated requests for the same item. The four-page report uses distinct orders and customer–item pairs rather than treating CSV rows as orders or quantities.

**At a glance:** The top 10 customers account for 58.96% of distinct orders, while the top 10 items account for just 2.52% of distinct order–item appearances. Overall, 47.47% of customer–item pairs appear on at least two different anonymized dates; the median customer-level share is 20.92%. These are descriptive patterns, not revenue, retention, or inventory measures. See the [English project summary](docs/final-report.en.md), [Power BI report](powerbi/B2B_Parts_Demand_Overview.pbix), and [interview brief](docs/interview-brief.md).

## 中文说明

用公开的匿名工业零部件采购数据，研究**订单由谁产生、物料需求有多分散、哪些客户会再次请求同一物料**。这是一个可复现的商业分析作品集项目：从原始文件校验、数据审计、SQL 汇总到四页 Power BI 报表，均有明确的数据口径。

## 核心发现

| 观察 | 已核对的结果 | 应怎样理解 |
| --- | ---: | --- |
| 客户集中度 | 前 10 位客户占 58.96% 的不同订单 | 对少数客户的订单依赖较高；这不是营收占比 |
| 物料分散度 | 前 10 个物料只占 2.52% 的不同订单—物料组合 | 请求分散在许多匿名物料编码上；这不是采购件数 |
| 同一物料再次出现 | 47.47% 的客户—物料组合出现在至少两个不同匿名日期 | 按组合汇总的比例；不是客户留存率 |
| 客户之间的差异 | 全部客户的客户比例中位数为 20.92%；至少 10 单客户为 40.37% | 典型客户与合计比例不同；分组差异不能解释成因果关系 |

完整解释、适用范围和可执行的后续业务问题见[项目结论](docs/final-report.md)。

## 查看成果

- [四页 Power BI 报表](powerbi/B2B_Parts_Demand_Overview.pbix)：需求总览、需求集中度、再次请求同一物料、客户之间的差异。报表是已导入汇总数据的快照，不是实时数据流。
- [指标字典](docs/kpi-dictionary.md)：逐项列出分子、分母、数据粒度和不能做的推断。
- [数据审计](docs/data-audit.md)与[重复行核对](docs/duplicate-audit.md)：交代来源、字段、缺失、匿名时间和口径差异。
- [面试说明](docs/interview-brief.md)：可以向招聘方准确介绍项目及 AI 的协助范围。
- [英文项目摘要](docs/final-report.en.md)与[中英双语报表文案](docs/dashboard-bilingual-copy.md)：用于英文或双语面试展示。
- [复现与刷新说明](docs/reproduce.md)：从 Zenodo 校验原始文件，到重建汇总数据和刷新 PBIX。

## 一条命令重建数据

需要 Node.js 24 或更新版本。在仓库根目录运行：

```sh
node scripts/rebuild_project.mjs
```

首次运行从固定的 [Zenodo v1 记录](https://zenodo.org/records/19492687)下载六份 CSV（共约 193.5 MB），逐份核对大小和 MD5，然后建立本地 SQLite 数据库、导出 13 份 Power BI 汇总 CSV，并检查关键指标。若原始文件已经保存在 `data/raw/`，可运行 `node scripts/rebuild_project.mjs --no-download`。详细步骤见[复现与刷新说明](docs/reproduce.md)。

`data/`、数据库和所有 CSV 都被 Git 忽略；**本仓库不包含原始 CSV**。PBIX 中保存的是报表所需的已导入数据。换一台电脑刷新时，需要在 Power Query 中把 CSV 来源重新指向该电脑的 `data/reporting/`。

## 数据与许可

数据来源：Francesca Stefano、Francesco Zanichelli、Dietmar Jannach，[B2B-Parts-Rec v1](https://zenodo.org/records/19492687)，DOI [10.5281/zenodo.19492687](https://doi.org/10.5281/zenodo.19492687)。Zenodo 记录的许可元数据为 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)；作者的[数据字典与研究代码](https://github.com/Infraste03/B2B-Parts-Rec)另在 GitHub 提供。本项目从 Zenodo 原始 CSV 生成本地汇总，未公开再分发六份原始文件。

数据没有采购数量、订单金额、货币、交付、库存和供应商字段；`PRICE_EXACT` 是单价。请求日期经过匿名化平移，因此图上的年份是**匿名时间轴**，不能直接与真实年份的市场事件对应。详见[项目结论](docs/final-report.md)。
