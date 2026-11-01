# B2B Parts Demand Patterns — Project Summary

## Question and scope

This portfolio project asks whether industrial-parts orders are concentrated among customers, whether requests are concentrated among item codes, and how often a customer requests the same item on a later anonymized date. It uses all six original B2B-Parts-Rec v1 CSV files: 285,941 source lines, 24,532 distinct order IDs, and 238 customer IDs.

The unit of analysis matters. A source line is neither a whole order nor a purchased unit. Order counts use distinct `ORDER_ID` values. Item frequency uses distinct order–item combinations. A customer–item pair is considered repeated when it appears on at least two different request dates.

## Findings

| Finding | Evidence | Interpretation |
| --- | ---: | --- |
| Orders are concentrated among customers | The largest customer accounts for 19.58% of distinct orders; the top 10 account for 58.96% | Order share is not revenue or profit share. |
| Item requests are dispersed | The top 10 item codes account for 2.52% of 221,886 distinct order–item appearances | Frequency is not quantity or inventory demand. |
| Repeated requests are common but uneven | 34,664 of 73,020 customer–item pairs, or 47.47%, appear on different dates | This is a pair-level measure, not customer retention. |
| The typical customer differs from the pooled rate | Median customer-level repeat-pair share: 20.92% across 238 customers; 40.37% among 134 customers with at least 10 orders | The 10-order threshold is descriptive; differences do not establish causation. |

Regional totals also depend heavily on the sampled customer base. North America has 5,189 distinct orders from 7 customers, while Southern Europe has 4,147 from 102. These figures cannot be read as market-size rankings.

## Business use and limitations

The results can guide **questions to validate** with a business team: whether service for the largest customers is resilient, which frequently requested items are operationally critical, and how repeat requests differ among customers with comparable exposure. Decisions about stocking, supplier choice, or customer value require quantities, item descriptions, inventory, lead times, supplier data, revenue, and costs that this dataset does not provide.

All six files were checked against Zenodo sizes and MD5 checksums. The source contains 44,781 extra lines identical across all 14 fields. Because there is no quantity or unique line identifier, the project retains those lines and uses distinct orders, dates, and pairs for its central measures. Request dates were shifted for anonymity, so plotted years are a dataset timeline rather than real calendar years. See the [data audit](data-audit.md), [KPI definitions](kpi-dictionary.md), and [reproduction guide](reproduce.md).
