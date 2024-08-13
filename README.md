# BTCsourcecode_Anal
目前很难在网络上找到针对比特币核心程序代码的分析，而本人在完成毕业设计的过程中进行了源码中一些关键功能的剖析，因此分享，希望能帮助更多研究BTC的朋友。

暂时先从我自己整理的文档里把一些关键部分的代码和对应的解释贴上来，后续有时间我再详细更新~

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
