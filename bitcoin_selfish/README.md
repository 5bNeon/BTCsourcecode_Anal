# 关于修改
## 收到自己挖到的区块
（Modified code section: src/validation.cpp, src/validation.h）
1.	由rpc里的函数调用ChainstateManager::ProcessNewBlock
2.	在ProcessNewBlock里通过CheckBlock检查工作量等信息
3.	ProcessNewBlock获取一个CChainState对象，由它调用自己类的AcceptBlock函数
4.	在AcceptBlock函数中判断，调用AcceptBlockHeader函数，若合法，则将该区块存到自私链vector中，s++。
若h=1且s=2，则正常进行后续操作并调用NewPoWValidBlock函数一个个公开自私链的区块，最后将s/h清零，清空vector；
否则，进行后续操作，不在网络公开但存储到磁盘，s++；

## 收到诚实矿工挖的区块
(Modified code section: src/validation.cpp, src/validation.h, src/net_processing.cpp)

ProcessBlock -> ProcessHonBlock -> AcceptHonBlock写入磁盘 ->NewPowValidBlock发送给对等节点CMPCT消息
1.	ProcessHonBlock获取一个CChainState对象，由它调用自己类的AcceptHonBlock函数
2.	在CS_AcceptBlock函数中判断当前hash与vector最后一个元素的hash的关系，如果合法则存储到vector，h++；
检查 若s=0，则直接对公开链vector中的区块（一定有且仅有一个）进行调用AcceptBlockHeader函数等流程完成公开和同步，最后将s/h清零，清空vector；
若s=1且h=1，则CS_AcceptBlock函数直接返回false
若s=1且h=2，则对公开链vector中的区块进行调用AcceptBlockHeader函数等流程完成公开和同步，最后将s/h清零，清空vector；
若s-h=1，则对自私链vector中的区块进行调用AcceptBlockHeader函数等流程完成公开和同步，最后将s/h清零，清空vector；
若s-h>1，则CS_AcceptBlock函数直接返回false

## 私有链构造
continued...



以下是BTC源码文档
The following is the README in BTC 
----------------------------------

Bitcoin Core integration/staging tree
=====================================

https://bitcoincore.org

For an immediately usable, binary version of the Bitcoin Core software, see
https://bitcoincore.org/en/download/.

What is Bitcoin Core?
---------------------

Bitcoin Core connects to the Bitcoin peer-to-peer network to download and fully
validate blocks and transactions. It also includes a wallet and graphical user
interface, which can be optionally built.

Further information about Bitcoin Core is available in the [doc folder](/doc).

License
-------

Bitcoin Core is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/licenses/MIT.

Development Process
-------------------

The `master` branch is regularly built (see `doc/build-*.md` for instructions) and tested, but it is not guaranteed to be
completely stable. [Tags](https://github.com/bitcoin/bitcoin/tags) are created
regularly from release branches to indicate new official, stable release versions of Bitcoin Core.

The https://github.com/bitcoin-core/gui repository is used exclusively for the
development of the GUI. Its master branch is identical in all monotree
repositories. Release branches and tags do not exist, so please do not fork
that repository unless it is for development reasons.

The contribution workflow is described in [CONTRIBUTING.md](CONTRIBUTING.md)
and useful hints for developers can be found in [doc/developer-notes.md](doc/developer-notes.md).

Testing
-------

Testing and code review is the bottleneck for development; we get more pull
requests than we can review and test on short notice. Please be patient and help out by testing
other people's pull requests, and remember this is a security-critical project where any mistake might cost people
lots of money.

### Automated Testing

Developers are strongly encouraged to write [unit tests](src/test/README.md) for new code, and to
submit new unit tests for old code. Unit tests can be compiled and run
(assuming they weren't disabled in configure) with: `make check`. Further details on running
and extending unit tests can be found in [/src/test/README.md](/src/test/README.md).

There are also [regression and integration tests](/test), written
in Python.
These tests can be run (if the [test dependencies](/test) are installed) with: `test/functional/test_runner.py`

The CI (Continuous Integration) systems make sure that every pull request is built for Windows, Linux, and macOS,
and that unit/sanity tests are run automatically.

### Manual Quality Assurance (QA) Testing

Changes should be tested by somebody other than the developer who wrote the
code. This is especially important for large or high-risk changes. It is useful
to add a test plan to the pull request description if testing the changes is
not straightforward.

Translations
------------

Changes to translations as well as new translations can be submitted to
[Bitcoin Core's Transifex page](https://www.transifex.com/bitcoin/bitcoin/).

Translations are periodically pulled from Transifex and merged into the git repository. See the
[translation process](doc/translation_process.md) for details on how this works.

**Important**: We do not accept translation changes as GitHub pull requests because the next
pull from Transifex would automatically overwrite them again.


