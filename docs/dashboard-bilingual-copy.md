# Power BI 双语文案（待应用到报表）

原则：**英文为主，中文为辅**。页面标签和图表标题用简短的 `English / 中文`，详细口径放在页面底部；不要把 Power BI 软件菜单语言当作报表语言。日期一律称 *anonymized dates*，重复行为称 *repeat item requests* 或 *repeat customer–item pairs*，避免误称为客户留存率。

| 页面 | 页面标签 / 主标题 | 卡片与图表标题 |
| --- | --- | --- |
| 1 | `Overview / 总览`；`B2B Demand Overview / B2B 需求总览` | `Orders / 订单数`、`Customers / 客户数`、`Items / 物料数`、`Repeat-pair share / 组合再次出现占比`；`Orders by anonymized month / 匿名月份订单`、`Orders by region / 地区订单` |
| 2 | `Concentration / 集中度`；`Customer and Item Concentration / 客户与物料集中度` | `Top customer share / 首位客户占比`、`Top 10 customer share / 前十客户占比`、`Top 10 item share / 前十物料占比`；`Top customers by orders / 客户订单排名`、`Top items by order appearances / 物料出现排名` |
| 3 | `Repeat Requests / 再次请求`；`Repeat Item Requests / 同一物料再次请求` | `Repeat pairs / 再次出现组合`、`Customers with repeats / 有再次请求客户`、`Single-order customers / 仅一单客户`；`Repeat-pair share by order band / 按订单数分组的组合占比` |
| 4 | `Customer Variation / 客户差异`；`Customer-level Variation / 客户之间的差异` | `Overall pair share / 组合合计占比`、`Median, all customers / 全部客户中位数`、`Median, 10+ orders / 至少10单中位数`；`Customer share distribution / 客户占比分布`、`Median by cohort / 分组中位数` |

**页面底部口径建议：** `Distinct order IDs; anonymized dates; no quantity or order value. / 订单按 ID 去重；日期已匿名化；无数量或订单金额。` 第 3、4 页还应补充：`Repeat = same customer and item on 2+ different dates; not retention. / 再次出现＝同一客户与物料出现在至少两个不同日期；非留存率。`

这是待应用到 PBIX 的用词清单；[英文项目摘要](final-report.en.md)和[指标字典](kpi-dictionary.md)提供完整解释。改完报表后，应在 Power BI Desktop 逐页检查文字是否被截断、数值是否保持一致，并保存 PBIX。
