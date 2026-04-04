# 多 GPU 实验设置与结果汇总

## 表 5-8 多 GPU 实验设置

| GPU数 | 方案 | 数据规模 | 索引组织 | 批大小 | 候选数量 | k值 | 归并路径 | I/O 绑定 | 备注 |
| --- | --- | --- | --- | ---: | ---: | ---: | --- | --- | --- |
| 1 | Replicated | 10M | Full replica | 4096 | 128 | 50 | None | Topology-aware | 单卡吞吐扩展基线 |
| 2 | Replicated | 10M | Full replica | 4096 | 128 | 50 | None | Topology-aware | 双卡 replicated 扩展基线 |
| 4 | Replicated | 10M | Full replica | 4096 | 128 | 50 | None | Topology-aware | 四卡 replicated 扩展基线 |
| 4 | Local scoring + GPU merge | 100M | Sharded index | 3072 | 128 | 50 | NCCL all-gather + GPU merge | Topology-aware | 显存受限时的 GPU 侧归并兜底方案 |
| 4 | Local scoring + CPU aggregation | 100M | Sharded index | 3072 | 128 | 50 | CPU aggregation | Topology-aware | CPU 聚合对比基线 |
| 2 | Topology-aware binding | 100M | Full replica | 4096 | 128 | 50 | None | Topology-aware | I/O lane 绑定对比实验 |
| 4 | Topology-aware binding | 100M | Full replica | 4096 | 128 | 50 | None | Topology-aware | I/O lane 绑定对比实验 |
| 2 | Shared-path conflict | 100M | Full replica | 4096 | 128 | 50 | None | Shared PCIe/SSD path | 共享路径冲突对比基线 |
| 4 | Shared-path conflict | 100M | Full replica | 4096 | 128 | 50 | None | Shared PCIe/SSD path | 共享路径冲突对比基线 |

## 表 5-9 多 GPU 实验结果汇总

| GPU数 | 方案 | 数据规模 | QPS | avg_latency_ms | p99_latency_ms | CPU利用率 (%) | GPU利用率 (%) |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | Replicated | 10M | 12640.00 | 10.80 | 16.20 | 34.00 | 69.00 |
| 2 | Replicated | 10M | 24760.00 | 9.10 | 14.60 | 30.50 | 75.50 |
| 4 | Replicated | 10M | 47620.00 | 8.40 | 12.90 | 26.50 | 82.00 |
| 4 | Local scoring + GPU merge | 100M | 40180.00 | 11.60 | 19.40 | 32.00 | 78.00 |
| 4 | Local scoring + CPU aggregation | 100M | 28940.00 | 15.80 | 28.60 | 49.00 | 64.50 |
| 2 | Topology-aware binding | 100M | 24780.00 | 11.40 | 18.40 | 31.00 | 74.00 |
| 4 | Topology-aware binding | 100M | 47560.00 | 13.20 | 22.10 | 29.00 | 80.00 |
| 2 | Shared-path conflict | 100M | 21920.00 | 14.80 | 24.80 | 36.00 | 67.50 |
| 4 | Shared-path conflict | 100M | 33140.00 | 24.20 | 41.60 | 43.00 | 58.00 |
