# 向招聘方介绍这个项目

## English interview pitch (about 45 seconds)

I used an anonymized industrial-parts dataset to build a reproducible B2B demand analysis in SQL and Power BI. The first step was checking the unit of analysis: the six CSVs contain 285,941 source rows, but only 24,532 distinct order IDs. The report then examines customer concentration, item-request frequency, and repeated requests for the same item. One result is that 47.47% of customer–item pairs appear on at least two different anonymized dates. The median customer-level share is only 20.92%, so the overall figure does not describe a typical customer. I used AI to help implement the pipeline and report, and documented the definitions, checks, and limitations. The dataset has no quantities or order values, so I do not present these frequencies as purchase volume or revenue.

### Short answers to likely follow-up questions

**Why are there fewer orders than rows?** A single order can have multiple source lines. The project counts 24,532 distinct `ORDER_ID` values, rather than treating 285,941 rows as orders.

**Is 47.47% a retention rate?** No. It is the share of distinct customer–item pairs observed on at least two different anonymized request dates: 34,664 out of 73,020 pairs.

**Why is the median customer-level share 20.92%?** The overall 47.47% pools all pairs, giving more weight to customers with many item pairs. The median first calculates a share for each of the 238 customers and then finds the midpoint.

**What is the project's most interesting finding?** The 47.47% pooled figure is much higher than the 20.92% median customer-level figure. A sensitivity check excludes the 10 customers with the most orders and finds a 41.87% pooled rate among the remaining customers. This makes the weighting and customer mix visible; it does not establish a causal effect.

**Can this report recommend inventory levels?** No. The dataset lacks quantities, inventory, lead times, and suppliers. It identifies patterns worth investigating with operational data.

## 中文面试说明

## 约 45 秒的说明

这是我用公开的匿名工业零部件数据做的 B2B 需求分析作品集项目。数据有六份年度 CSV。项目先核对了数据粒度：285,941 是原始明细行，真正不同的订单 ID 有 24,532 个，因此分析中把订单数和明细行数分开计算。之后用 SQL 生成汇总数据，在 Power BI 中做了需求总览、需求集中度、客户再次请求同一物料和客户差异四页报表。一个发现是：73,020 个客户—物料组合中，47.47% 在至少两个不同的匿名日期出现；按客户分别计算，238 位客户的中位数是 20.92%，说明总体比例不能代表典型客户。这个指标不能当作客户留存率。我借助 AI 完成实现，并把指标定义、核对结果和局限整理成可复核的文档：日期经过平移，也没有采购数量或订单金额，所以没有把出现频次说成销售额或采购量。

## 常见追问的简短回答

**为什么不是 285,941 个订单？** 一份订单可以有多行；按不同 `ORDER_ID` 统计是 24,532 个。285,941 是原始明细行数。

**47.47% 是留存率吗？** 不是。分母是 73,020 个不同客户—物料组合，分子是其中在至少两个不同匿名日期出现的 34,664 个组合。

**为什么总体是 47.47%，客户中位数却是 20.92%？** 前者把所有客户—物料组合放在一起计算，组合多的客户权重更大；后者先算每位客户的比例，再取 238 位客户的中位数。只看至少 10 单的 134 位客户，中位数是 40.37%。详见[客户差异分析](customer-differences.md)。

**这个项目最值得讲的发现是什么？** 47.47% 的合计比例明显高于 20.92% 的客户中位数。排除订单最多的前 10 位客户后，剩余客户的合计比例为 41.87%。这个核查提示我们先看分母和客户结构，不能把总体数值当作典型客户，也不能据此推断因果关系。

**为什么保留重复行？** 六份 CSV 中有 44,781 个额外重复行，但数据没有数量或唯一明细 ID，无法确认这些行的业务含义。项目保留原始行，用不同订单和不同日期的计数方式避免它们误导主要指标。详见[重复行核对](duplicate-audit.md)。

**这份报表能指导补货或供应商选择吗？** 目前不能。它没有数量、库存、交付和供应商字段；现阶段适合描述请求模式，并提出下一步需要补充哪些业务数据。
