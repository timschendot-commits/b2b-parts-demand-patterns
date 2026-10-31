# Global B2B Procurement & Demand Intelligence

个人商业分析作品集项目，使用匿名化工业零部件采购数据，探索订单结构、客户复购和物料需求。项目目前处于数据审计阶段。

## 数据来源

数据来自 Francesca Stefano、Francesco Zanichelli 和 Dietmar Jannach 发布的 [B2B-Parts-Rec v1](https://zenodo.org/records/19492687)，DOI 为 [10.5281/zenodo.19492687](https://doi.org/10.5281/zenodo.19492687)。Zenodo 记录的许可元数据标为 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)。六份 CSV 可从原始记录下载。

## 当前发现

- 六份 CSV 共 285,941 行，包含 24,532 个不同订单 ID、238 个客户 ID。
- Zenodo 简介列出的 285,919 个订单和 219 家客户与直接审计结果不同，原因仍待核查。
- `PRICE_EXACT` 是单价。数据没有采购数量、订单金额或货币字段，因此不会将单价求和当作采购额。
- 日期经过匿名化平移，图表中的年份只表示数据集的匿名时间轴。
- 详细检查见 [数据审计](docs/data-audit.md)。

## 计划

1. 确定订单、明细行、重复记录和复购的计算口径。
2. 编写可复现的 SQL 导入和分析查询。
3. 用 Power BI 制作订单、客户和物料需求报表。
4. 记录分析方法、发现和局限。

原始 CSV 保存在本地分析环境中。本仓库通过 Zenodo 链接提供数据来源。
