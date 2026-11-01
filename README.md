# Industrial Parts Demand and Customer Reordering

个人商业分析作品集项目，使用匿名化工业零部件采购数据，探索订单结构、客户再次请求同一物料的行为和物料需求。项目目前完成了数据审计、SQL 分析和三页 Power BI 报表。

## 数据来源

数据来自 Francesca Stefano、Francesco Zanichelli 和 Dietmar Jannach 发布的 [B2B-Parts-Rec v1](https://zenodo.org/records/19492687)，DOI 为 [10.5281/zenodo.19492687](https://doi.org/10.5281/zenodo.19492687)。Zenodo 记录的许可元数据标为 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)。六份 CSV 可从原始记录下载。

## 当前发现

- 六份 CSV 共 285,941 行，包含 24,532 个不同订单 ID、238 个客户 ID。
- 作者的[预处理脚本](https://github.com/Infraste03/B2B-Parts-Rec/blob/main/create_splits.py)只保留至少有 3 行记录的客户。按该规则筛选后正好是 285,919 行、219 个客户。原始数据的 24,532 个不同 `ORDER_ID` 才适合称为订单数。
- `PRICE_EXACT` 是单价。数据没有采购数量、订单金额或货币字段，因此不会将单价求和当作采购额。
- 日期经过匿名化平移，图表中的年份只表示数据集的匿名时间轴。
- 详细检查见 [数据审计](docs/data-audit.md)。

第一版商业分析采用全部 238 个客户。作者的 219 个客户口径用于对照，因为至少 3 行的筛选是为推荐系统训练、验证和测试划分准备的。

初步复购分析发现，73,020 个客户与物料组合中，有 34,664 个在之后的匿名日期再次出现，占 47.47%。这个指标按不同日期计算，避免将同一订单内的重复行当作再次采购。详见 [`sql/02_customer_reorders.sql`](sql/02_customer_reorders.sql)。

需求集中度分析发现：第一位客户贡献 19.58% 的不同订单，前 10 位客户合计贡献 58.96%；前 10 个物料编码占不同订单—物料组合的 2.52%。这些比例的分母不同，详见[集中度分析与口径](docs/demand-concentration.md)。

数据质量复核发现 44,781 个完全相同的额外明细行，涉及 2,395 个订单。由于缺少数量和唯一明细 ID，项目保留原始行，并让核心指标按不同订单、不同客户—物料组合或不同日期计算。详见[重复行核对](docs/duplicate-audit.md)。

## Power BI 报表

打开 [`powerbi/B2B_Parts_Demand_Overview.pbix`](powerbi/B2B_Parts_Demand_Overview.pbix)。第一页“需求总览”展示四个核心指标、72 个月的订单趋势和 13 个地区的订单分布；第二页“需求集中度”展示客户与物料出现频次的前三项占比及前十名排名；第三页“再次请求同一物料”展示客户—物料组合的重复出现和按客户订单数分组的结果。每页均注明数据口径。报表只载入汇总表，没有载入原始 CSV 明细。

这里的“再次出现占比”是 **客户与物料组合** 在至少两个不同的匿名日期出现的比例，不是客户留存率。地区图的“订单数”按地区分别去重；月度图按匿名月份分别去重。由于缺少数量与订单金额，本报表不展示采购量、销售额或采购额。

这是导入数据后的快照，并非实时数据流。若源 CSV 发生变化，先重新建立本地 SQLite 数据库，再导出汇总 CSV，最后在 Power BI Desktop 点击“刷新”：

```sh
node scripts/build_database.mjs data/raw data/b2b.sqlite
node scripts/export_powerbi_data.mjs data/b2b.sqlite data/reporting
```

导出脚本运行 [`sql/03_powerbi_views.sql`](sql/03_powerbi_views.sql)、[`sql/04_demand_views.sql`](sql/04_demand_views.sql) 和 [`sql/05_reorder_views.sql`](sql/05_reorder_views.sql)。报表使用 `overview.csv`、`monthly.csv`、`region.csv`、`concentration.csv`、`item_demand.csv`、`top_customers.csv`、`reorder_summary.csv` 和 `reorder_order_bands.csv`；脚本还导出完整客户再购表和地区再购表供进一步分析。若在另一台电脑刷新，先将 Power BI 的 CSV 来源路径改为那台电脑的 `data/reporting/`。本地数据库及 CSV 已被 Git 忽略。

## 下一步

1. 进一步核实完全相同行的业务含义；在得到来源说明前，继续保留原始行和来源位置。
2. 在[客户再次请求分析](docs/customer-reordering.md)的口径下，探索客户层级差异，并注意观察期和订单数带来的机会差异。
3. 用[面试介绍与常见追问](docs/interview-brief.md)说明项目问题、结果和局限；不要把出现频次说成采购数量或金额。

原始 CSV 保存在本地分析环境中。本仓库通过 Zenodo 链接提供数据来源。

## 运行第一组 SQL 检查

使用 Node.js 24 或更新版本。将从 Zenodo 下载的六份 CSV 放入本地 `data/raw/`，再在项目根目录运行：

```sh
node scripts/build_database.mjs data/raw data/b2b.sqlite
node scripts/run_checks.mjs data/b2b.sqlite
node scripts/run_checks.mjs data/b2b.sqlite sql/02_customer_reorders.sql
```

这会在本地创建只包含分析字段的数据库，并运行 [`sql/01_check_grain.sql`](sql/01_check_grain.sql)。`data/` 已被 Git 忽略。完整的 14 列原始 CSV 不会被修改。
