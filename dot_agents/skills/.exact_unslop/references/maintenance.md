# 调研依据与试用案例

仅用于维护、比较版本和检查失败案例。日常使用 unslop 不读取本文件。

## 2026-09-23 调研

阅读了以下项目的 README 和技能源码。关注度取自当天可访问的 GitHub 页面，数值经过页面取整；它只能反映关注程度。本文只借鉴编辑判断，规则与工程、研究例子按用户用途编写。

| 项目 | 页面显示的关注度 | 采用的思路 | 不照搬的部分 |
| --- | --- | --- | --- |
| [blader/humanizer](https://github.com/blader/humanizer)，[源码](https://github.com/blader/humanizer/blob/main/SKILL.md) | 约 51.5k stars | 先检查空洞对比、无信息的收尾和虚设反对意见，再调整措辞；检查改写是否丢失主张 | 默认展示草稿、批评、终稿；英语标点习惯；与当前用途无关的文案示例 |
| [op7418/Humanizer-zh](https://github.com/op7418/Humanizer-zh)，[源码](https://github.com/op7418/Humanizer-zh/blob/main/SKILL.md) | 约 17.9k stars | 当前修订明确保留条件、确定程度、归因和完成状态；中文模式有修改与保留边界 | 31 条模式全部常驻入口的篇幅；润色已有文章的范围不足以覆盖日常技术解释 |
| [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)，[源码](https://github.com/hardikpandya/stop-slop/blob/main/SKILL.md) | 约 17.5k stars | 删除铺垫，直接写具体动作和事实 | 删除全部副词、每句必须有人作主语、禁止被动句等硬规则；自评分 |
| [ai-zixun/humanizer-zh](https://github.com/ai-zixun/humanizer-zh)，[源码](https://github.com/ai-zixun/humanizer-zh/blob/main/SKILL.md) | 约 160 stars | 中文段落衔接、翻译腔和重复价值判断的处理 | 主动询问是否采用作家口吻；偏长篇文章的多文件流程 |
| [theclaymethod/unslop 的编辑约束](https://github.com/theclaymethod/unslop/blob/main/references/core-contract.md) | 未纳入热度比较 | 根据上下文判断具体表达问题；清楚的文本可以不改；保护有效术语和原文证据 | 扫描器、预设和评分流程不适合常驻的短回复规则 |

也查了实际使用反馈：

- [Humanizer #183](https://github.com/blader/humanizer/issues/183)：用户肯定保留信息、减少误改的规则。这是个人使用经验。
- [Humanizer #229](https://github.com/blader/humanizer/issues/229)：作者报告，小规模比较中改写提高了可读性，但没有消除检测器判断出的 AI 特征。评审均来自同一模型家族，试验也未全部完成，不能据此推断中文或其他模型的效果。
- [Humanizer #269](https://github.com/blader/humanizer/issues/269)：用户指出，技术对话回复即使清除了常见词句，仍会因重复已知背景而显得机械。采用了按当前问题解释、避免重复已知概念的判断，同时保留独立交付物所需的上下文。

本次找到的公开反馈不足以证明哪个技能对 Opus、Sol 的中文工程与模型研究回复最好。因此保留 unslop 的名称，采用中文单文件入口，并针对用户明确提出的阅读困难编写规则。不会以 star 数、自评分、字数减少或禁词命中率宣称效果。

旧版中文附录在 2026-09-08 还参考过 [jiji262/humanizer-chinese](https://github.com/jiji262/humanizer-chinese) 和 [holygeek00/humanizer-zh-cn](https://github.com/holygeek00/humanizer-zh-cn)。本次没有重新评估它们，不将旧记录当作当前验证。

## 用于后续比较的案例

将请求与所需原始材料交给待测模型，只加载被测版本的 SKILL.md。评阅者再看下面的检查要点，避免让答案照着检查表作答。比较时记录模型、日期、完整输出；除技能版本外尽量使用相同上下文。需要多次运行和真人阅读，不能凭一次输出判断模型已稳定遵守。

以下均为虚构测试材料，没有实际运行记录。

### 1. 排错中的因果关系

请求：

> 帮我把排查结果讲清楚：GPU 利用率掉到 20%，CPU 满了。怀疑 loader 卡住，但没做 profiling。先看是不是预处理太慢。别写成一份长报告。

检查：解释 loader 指数据加载部分，性能分析尚未进行；CPU 忙与 GPU 等待只是可能的解释。给出针对加载或预处理耗时的检查，不断言根因已经确定，不堆新缩写。

### 2. 研究术语的解释

请求：

> 我有大学数学基础，但没做过这类模型。解释这段方法：训练时维护 EMA，更新式为 θ_avg ← 0.99θ_avg + 0.01θ，验证使用 θ_avg。它在做什么？

检查：解释 EMA、θ、θ_avg 及加权更新的含义，说明验证用平均权重；不只展开英文全称，不承诺一定提升精度。公式和系数保持原样。

### 3. 不可猜测的简称

请求：

> 润色：本轮做 QRS 收敛，接 H2 复用，完成后验闭环。

检查：承认缺少简称定义和具体操作，不能编造全称、算法或实现步骤；不要只换成另一组漂亮的抽象词。

### 4. 研究结果的限定

请求：

> 把这段实验记录改顺：batch=16，数据集 A，同一张 GPU。baseline 验证误差 0.18，新方法 0.16。各跑 1 个 seed。峰值显存从 8 GB 到 11 GB。未测吞吐。我觉得新方法可能有用。

检查：保留全部数字、条件和作者的谨慎判断；解释不熟悉的简称时不要擅改配置文本。不能写成稳定收益、吞吐提升、统计显著，也不能遗漏显存增加。

### 5. 已清楚的文字与真实否定

请求：

> 轻微润色，保留全部条件：当 `retry_count` 达到 3 时停止重试。未配置 `webhook_url` 时不会发送通知。当前只能手动启动，还不支持开机自启。

检查：可以完全不改。不得因“去 AI 味”删除否定条件或把需要手动操作写成自动化功能。

### 6. 简短状态回复

请求：

> 前面已讨论过原因。这次只告诉我状态：代码已改，12 个单元测试通过，集成测试没跑，还没部署。

检查：直接报告四项状态，不重复原因，不输出固定的背景、价值、总结，也不把测试通过写成问题已在线上解决。

### 7. 用户要求比较

请求：

> 用中文比较这两种策略：A 遇到错误立刻返回；B 最多重试 3 次，每次间隔 1 秒。不要引入其他假设。

检查：真实区别仍需说清，允许列表或表格；不能因为减少对比句而抹掉差异，也不能承诺 B 一定成功。

### 8. 语言与文本保护

请求：

> Polish this in English. Preserve all identifiers and the command: The loader serves as a pivotal bridge. It reads config.json. Run `runner --mode fast --retries 3`. Output is saved to out.csv. Validation has not run.

检查：保持英文；保留文件名、命令和未验证状态；删去空泛修辞，不增加测量结果。无须另读英文文件。

判断优先级：信息是否准确且完整，读者是否理解，是否自然且切题。只要关键信息被改错或补造，文风再流畅也不通过。
