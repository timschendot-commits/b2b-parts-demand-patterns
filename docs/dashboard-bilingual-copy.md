# Power BI 双语文案（已应用到报表）

原则：**英文为主，中文为辅**。页面标签和图表标题用简短的 `English / 中文`，详细口径放在页面底部；不要把 Power BI 软件菜单语言当作报表语言。日期一律称 *anonymized dates*，重复行为称 *repeat item requests* 或 *repeat customer–item pairs*，避免误称为客户留存率。

| 页面 | 页面标签 / 主标题 | 卡片与图表标题 |
| --- | --- | --- |
| 1 | `Overview / 总览`；`B2B Demand Overview / B2B 需求总览` | `Orders / 订单数`、`Customers / 客户数`、`Items / 物料数`、`Repeat-pair share / 组合再次出现占比 (%)`；`Orders by anonymized month / 匿名月份订单`、`Orders by region / 地区订单` |
| 2 | `Concentration / 集中度`；`Customer and Item Concentration / 客户与物料集中度` | `Top 10 customer share / 前十客户占比 (%)`、`Largest customer share / 最大客户占比 (%)`、`Top 10 item share / 前十物料占比 (%)`；`Top customers by orders / 客户订单排名`、`Top items by order appearances / 物料出现排名` |
| 3 | `Repeat Requests / 再次请求`；`Repeat Item Requests / 同一物料再次请求` | `Repeat-pair share / 组合再次出现占比 (%)`、`Customers with repeats / 有再次请求客户 (%)`、`Single-order customers / 仅一单客户`；`Repeat-pair share by order band / 按订单数组合占比 (%)`、`Customers by order band / 各订单组客户数` |
| 4 | `Customer Variation / 客户差异`；`Customer-level Variation / 客户之间的差异` | `Overall pair share / 组合合计占比 (%)`、`Median, all customers / 全部客户中位数 (%)`、`Median, 10+ orders / 至少10单中位数 (%)`；`Repeat-pair share, 10+ orders / 至少10单客户分布`、`Median repeat-pair share / 客户中位数 (%)` |

页面底部已写明订单去重、日期匿名化、地区图仅代表样本、无数量或订单金额，以及再次请求不等于客户留存。详细定义见[指标字典](kpi-dictionary.md)。

Power BI Desktop 菜单仍可保持中文，报表内容按英文为主、中文为辅呈现。[英文项目摘要](final-report.en.md)提供完整面试表述。
