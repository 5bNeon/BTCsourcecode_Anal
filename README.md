# Bitcoin-core-code_Analysis & Selfish_miner_core-code
## 关于本仓库
目前很难在公开网络上找到针对比特币核心程序代码的分析，本人在做相关项目的过程中对源码中一些关键功能（主要与挖矿、处理区块相关）的剖析，因此分享，希望能帮助更多研究BTC的朋友。

关于该项目，设计并实现了一个[比特币公链自私挖矿攻击软件](https://github.com/5bNeon/Bitcoin-core-code_Analysis_and_Selfish_miner_core-code/tree/main/bitcoin_selfish)，通过将该软件直接部署([部署教程](https://github.com/5bNeon/Bitcoin-core-code_Analysis_and_Selfish_miner_core-code/tree/main/DEPLOY_DOC.md))到比特币系统上，就能够实现自私交易节点并对系统发起自私挖矿攻击。
创新性工作体现在三方面：
* 本工作在相关领域内首次对比特币核心程序中与挖矿相关的代码进行了研究分析。
* 本工作通过对比特币核心程序进行修改实现了可以部署在比特币系统执行自私挖矿策略的自私挖矿攻击软件。
* 通过构建私有链并调整网络参数，本工作搭建了一个类似比特币公链的本地系统用于验证自私挖矿攻击软件，在该系统搭建出自私挖矿攻击情景，验证了自私挖矿攻击的可行性。

本工作设计出的自私挖矿攻击软件和比特币私有链系统能够为研究人员提供了一个在真实比特币网络上研究自私挖矿攻击的方式，帮助更好地理解、观察和应对可能的自私挖矿行为。


**暂时先从我自己整理的文档里把一些关键部分的代码和对应的解释贴上来，后续我再详细更新~**

## 1、bfgminer（挖矿软件）如何与bitcoin内核通信
1.1 通过blkmaker 库，它提供了与比特币节点进行通信的功能

1.2 bfgminer开源库中的drive-cpu.c里面的cpu_scanhash包含了挖矿过程，挖到后会调用submit_nonce提交函数

1.3 紧接着bfgminer/miner.c中有如下次序的函数调用：submit_nonce-> submit_noffset_nonce-> submit_work_async2-> _submit_work_async-> DL_APPEND(submit_waiting, work)

提交过程：
submit_waiting是一个双向链表
submit_work_thread-> begin_submission-> pop_curl_entry2（弹出curl_ent）-> submit_upstream_work_request生成 JSON 请求字符串（Line5388调用libblkmaker的blkmk_submit_jansson函数） ->
json_rpc_call_async JSON-RPC 调用->
curl_multi_perform执行多个传输操作

bitcoin监听rpc：
bitcoin/src/rpc/mining.cpp中，最后cmds中各个名字对应该cpp文件中一个函数，

包含submitblock和getblocktemplate等...
其中blkmk_submit_jansson函数生成的json对象的method属性为submitblock
Submitblock函数中包含
chainman.UpdateUncommittedBlockStructures和
chainman.ProcessNewBlock。
该函数使用的tmpl，是来自最初提交的work，最初生成的work也是来自于bfgminer/miner.c: Line6042调用libblkmaker的blktmpl_request_jansson
函数生成的json对象的method属性为getblocktemplate
