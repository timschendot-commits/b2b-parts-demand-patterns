# 复现数据和刷新报表

## 准备

1. 安装 Node.js 24 或更新版本；不需要额外 npm 包。
2. 从[仓库](https://github.com/timschendot-commits/b2b-parts-demand-patterns)下载或克隆项目。
3. 确保本机可连接 [Zenodo B2B-Parts-Rec v1](https://zenodo.org/records/19492687)，并预留至少 1 GB 可用空间用于原始文件、数据库与重建过程中的临时文件。

在仓库根目录运行：

```sh
node scripts/rebuild_project.mjs
```

脚本首先检查 `data/raw/` 中六份原始 CSV 的文件大小和 MD5。缺失文件会从固定的 Zenodo 记录下载；下载前核对记录 ID、`cc-by-4.0` 许可元数据、文件名、大小和 MD5。然后建立 `data/b2b.sqlite`，导出 `data/reporting/` 中 13 份汇总 CSV，并检查核心指标。六份原始 CSV 合计 193,510,388 字节。已有完整文件时可运行：

```sh
node scripts/rebuild_project.mjs --no-download
```

若校验报告文件不匹配，先确认来源；不要直接用不匹配的数据覆盖既有分析结论。`data/` 和 `*.csv` 已被 Git 忽略，原始文件不会随正常 `git add` 进入仓库。

## Power BI

打开 [`powerbi/B2B_Parts_Demand_Overview.pbix`](../powerbi/B2B_Parts_Demand_Overview.pbix)即可查看已保存的四页双语报表快照。报表通过本地汇总 CSV 导入，不连接 Zenodo 实时数据。当前 PBIX 的 11 个 CSV 查询仍指向制作时的本地输出目录；本机原路径存在，已在 Power BI 中执行一次刷新。若在另一台电脑或移动仓库后刷新，先运行重建脚本，再在 Power BI Desktop 的 Power Query 中把各查询的 CSV `Source` 路径改为新仓库下 `data/reporting/` 对应文件，点击“关闭并应用”、刷新并保存。**只运行重建脚本不会自动改写 PBIX 内保存的数据。**

## 单项核查

```sh
node scripts/prepare_dataset.mjs data/raw --verify-only
node scripts/audit_exact_duplicates.mjs data/raw
node scripts/run_checks.mjs data/b2b.sqlite
node scripts/run_checks.mjs data/b2b.sqlite sql/07_summary_checks.sql
node scripts/validate_project.mjs
```

`sql/07_summary_checks.sql` 展示匿名年份、地区、物料前五名和集中度指标。其输出是样本描述，不能直接解释为真实历年趋势、地区市场规模或采购量。
