# Industrial Parts Demand and Customer Reordering

数据审计日期：2026 年 10 月 31 日

## 数据来源与许可

- 来源是 Zenodo 的 [B2B-Parts-Rec v1](https://zenodo.org/records/19492687)，DOI 为 10.5281/zenodo.19492687。作者为 Francesca Stefano、Francesco Zanichelli、Dietmar Jannach。
- Zenodo 记录的 [API 元数据](https://zenodo.org/api/records/19492687) 标记 `license.id = cc-by-4.0`。该许可允许复制和再分发，条件包括署名、提供许可链接和说明修改。详见 [Creative Commons 条款摘要](https://creativecommons.org/licenses/by/4.0/)。作者的 [GitHub 仓库](https://github.com/Infraste03/B2B-Parts-Rec)另标 GPL-3.0，项目引用 Zenodo 数据记录的 CC BY 4.0，并注明出处。
- 六份原始 CSV 已下载在本地 `work/raw/`，合计 193,510,388 字节。各文件 MD5 与 Zenodo 公布值全部一致。没有向用户的 GitHub 上传文件。

## 审计结果

| 检查项 | 结果 | 对项目的影响 |
| --- | ---: | --- |
| 文件与格式 | 6 份，2024—2029，每份 14 列，以分号分隔 | 导入时选择分号分隔 |
| 总行数 | 285,941 | 按明细行计数 |
| 订单 ID | 24,532 个不同值 | 一个订单对应多行，不能将行数命名为订单数 |
| 客户 ID | 238 个不同值 | 作者筛除少于 3 行的客户后剩 219 个 |
| 物料 ID | 21,143 个不同值 | 可统计不同物料及客户物料组合 |
| 完全相同的行 | 44,781 行，15.66% | 未确认代表重复导出还是同项多件，暂不删除 |
| 缺失 LINE_ID | 5,560 行，1.94% | 生产线维度需显示“未知” |
| 缺失 PRODMODEL_DESCRIPTION | 107 行，0.04% | 此列是编码向量，初版报表不用 |
| PRICE_EXACT | 全部可解析，12,428 行为零，4.35%；无负值 | 可研究单价分布，零价原因未说明 |
| 日期 | 格式有效，2024-01-02 至 2029-12-20 | 作者称日期统一平移，不能当真实日历日期解读 |
| 地区 | 13 个宏观地区 | 可看地区需求记录数，不能细化到国家 |

Zenodo 简介称 285,919 个订单、219 家客户。直接审计六份文件得到 285,941 行、24,532 个订单 ID、238 个客户 ID。[作者的预处理脚本](https://github.com/Infraste03/B2B-Parts-Rec/blob/main/create_splits.py)按每个客户至少 3 行筛选。原始文件中有 16 个客户各 1 行、3 个客户各 2 行，剔除这 22 行后，恰好是 285,919 行、219 个客户。因此简介中的“订单”很可能指筛选后的明细行，不能用于 `ORDER_ID` 的不同值计数。全部 24,532 个订单 ID 只对应一个客户和一个日期，其中 15,085 个订单 ID 对应多个物料 ID，说明数据适合从订单和订单明细两个层次建模。字段定义见[作者仓库的数据字典](https://github.com/Infraste03/B2B-Parts-Rec)。

第一版商业分析保留全部 238 个客户。219 个客户的筛选口径仅用于与作者的推荐系统实验对照。初版订单 KPI 使用 `COUNT(DISTINCT ORDER_ID)`，明细行 KPI 使用 `COUNT(*)`，两者分别标注。

## 字段与能回答的问题

主要字段有 `ORDER_ID`、`CUSTOMER_ID`、`REQUEST_DATE`、`ITEM_ID`、`PROJECT_ID`、`LINE_ID`、`MACHINE_ID`、`PRODUCT_MODEL_ID`、`LOCATION` 和 `PRICE_EXACT`。另有四列描述向量，它们是编码后的数字数组，无法直接作为人类可读的物料名称或机器名称。

可以计算不同订单数、明细行数、活跃客户数、不同物料数、客户再次采购同一物料的比例、客户与物料的采购间隔，以及匿名时间轴上的需求变化。这些指标需要明确采用原始行、去重行还是订单层次，初版先保留原始行并标注口径。

数据没有采购数量、订单总金额、货币、交付日期、供应商、库存或真实国家。`PRICE_EXACT` 是单价，因此不能将它求和当作采购额，也不能计算采购总量、真实销售额、交付准时率、库存周转或供应商表现。跨地区单价比较也需要先确认货币和定价口径。

## 下一步项目方案

1. 建立本地项目文件夹和对应 GitHub 仓库。第一版只放 `README.md`、`docs/data-audit.md` 和 `.gitignore`，说明数据来源、许可、审计差异与后续分析问题。原始 CSV 保留在本地，仓库 README 链接 Zenodo 下载页即可。
2. 确定分析口径。保留完全相同的行，继续调查其业务含义，定义“订单”“明细行”“复购”的计算方法，保留原始数据与处理结果之间的可追溯关系。
3. 扩展 SQL 导入与查询文件。第一组粒度检查已完成，接着做客户复购、物料覆盖和地区分布等分析，再用查询结果核对 Power BI 中的数字。
4. 制作首版 Power BI 报表。首页展示订单数、活跃客户、不同物料和匿名时间轴趋势，第二页分析客户复购与物料需求。每个图表旁注明口径和日期匿名化限制。

建议的仓库起步结构：

```text
b2b-parts-demand-patterns/
  README.md
  .gitignore
  docs/
    data-audit.md
  sql/                  # SQL 写好后加入
  powerbi/              # 报表做好后加入
```

公开仓库创建时，README 应注明作者、Zenodo DOI、CC BY 4.0 许可、原始数据链接，以及分析处理是否修改数据。此阶段不需要上传六份原始 CSV。
