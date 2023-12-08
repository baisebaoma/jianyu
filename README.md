# 新月杀简浴包

[新月杀（FreeKill）](https://gitee.com/notify-ctrl/FreeKill)是一款开源、支持自定义的三国杀联机软件。

本仓库是新月杀的一个扩展包，其中包含我和我的好朋友们的原创武将！之所以叫作简浴包，是因为我们曾经踢足球时自称“简浴队”。所有设计均由我 [@baisebaoma](https://gitee.com/baisebaoma) 实现。

我们的关注点有：足球、英雄联盟等。

本包会保留所有群友设计的原始武将，仅作出文本描述和游戏体验方面的优化（例如，假如你的五个技能全是回合开始可以发动的，那我肯定是要改的）。如果根据以后的游玩体验，这些武将中有不够平衡、不够合理的设计，我会推出优化过后的版本，如界限突破等。

## 已实现武将

### 群·简自豪 体力3

![群·简自豪](./image/generals/avatar/xjb__jianzihao.jpg "群·简自豪")

> 该武将由玩家“导演片子怎么样了”设计。

开局：锁定技，当你的回合开始时，所有其他有牌的角色需要交给你一张牌，并视为对你使用一张【杀】。<br>
  <font size="2"><i>“从未如此美妙的开局！”——简自豪</i></font>

红温：锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。

走位：锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。

圣弩：当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得此【诸葛连弩】。

洗澡：限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。


### 群·界简自豪 体力3

![群·界简自豪](./image/generals/avatar/tym__jianzihao.jpg "群·界简自豪")

> 该武将由玩家“导演片子怎么样了”设计，我调整。
> 
> 经典的设计经群友体验，认为全场玩家负反馈都很高、风险过高、收益不匹配：没有拿到特定的防具（【藤甲】、【八卦阵】）前，会非常弱，拿到之后才会变得正常。这会导致玩家全力用手气卡刷防具和【闪】，如果没有就很大概率第一轮暴毙；消耗队友手牌；如果第一轮发动限定技并活了下来，也就只有 13 张左右的手牌，爆发能力有限。我将【开局】调整得更为主动，增加了一个技能【三件】~~群友要的~~，并相应削弱了别的技能，制作了这个版本。

开局：出牌阶段限一次，你选择若干名武将。你对他们【顺手牵羊】，然后被他们【杀】。

三件：锁定技，出牌阶段开始时，如果你的装备区有且仅有3张牌，你视为使用一张【酒】和一张【无中生有】。<br>
  <font size="1"><i>“又陷入劣势了，等乌兹三件套吧！”——不知道哪个解说说的</i></font>

红颜：锁定技，你的♠牌视为<font color='red'>♥</font>牌。

走位：锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。

圣弩：当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得此【诸葛连弩】。

洗澡：限定技，当你处于濒死状态且装备区有牌时，你可以弃掉所有装备区的牌、将体力恢复至1，然后每以此法弃掉一张牌，你摸一张牌。


### 群·李元浩 体力3

![群·李元浩](./image/generals/avatar/skl__liyuanhao.jpg "群·李元浩")

> 该武将由玩家“拂却心尘”设计。

虎啸：当你使用或打出一张【杀】时，你可以将牌堆顶的一张牌置于你的武将牌上，称为【啸】。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”——李元浩</i></font>

横刀：你可以将【啸】当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>

立马：你可以将【啸】当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>

二段：锁定技，当你的武将牌上有且仅有两张【啸】时，你选择失去一点体力或失去所有【啸】。

三件：锁定技，当你的装备区有且仅有防具和防御马时，你造成的伤害-1。
  <br><font size="1"><i>虎三件，指【中娅沙漏】、【水银之靴】、【大天使之杖】。一些人持不同的观点，但【大天使之杖】没有什么争议。</i></font>


### 群·界李元浩 体力3

![群·界李元浩](./image/generals/avatar/tym__liyuanhao.jpg "群·界李元浩")

> 该武将由玩家“拂却心尘”设计，我调整。

虎啸：当你使用或打出一张【杀】时，你可以将牌堆顶的一张牌置于你的武将牌上，称为【啸】。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”——李元浩</i></font>

横刀：你可以将【啸】当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>

立马：你可以将【啸】当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>

二段：锁定技，当你的角色牌上有且仅有两张【啸】时，你选择：弃掉所有【啸】并恢复一点体力，或将所有【啸】纳入手牌。


### 群·高天亮 体力4

![群·高天亮](./image/generals/avatar/xjb__gaotianliang.jpg "群·高天亮")

> 该武将由玩家“导演片子怎么样了”设计。

玉玉：锁定技，当你被没有【高天亮之敌】标记的角色使用【杀】造成了伤害时，你令其获得【高天亮之敌】标记。受到来自没有【高天亮之敌】标记的角色或因本次伤害而获得【高天亮之敌】标记的角色造成的伤害时，你可以摸三张牌，然后翻面。


### 群·赵乾熙 体力3

![群·赵乾熙](./image/generals/avatar/tym__zhaoqianxi.jpg "群·赵乾熙")

> 该武将由我设计。

锁定技，你造成的属性伤害+1。
  <font size="1"><br>特别提示：当你对被横置的角色造成属性伤害时，所有其他被横置的角色会受到的伤害+2。<br>这是因为你对主目标触发了【原神】，伤害+1，保存该值，然后你再对所有其他被连环的角色造成一次该值的属性伤害，再次触发【原神】，伤害+1。为了平衡这个，所以他虽然体力值仅为3，但只有一个技能。</font>

### 群·界赵乾熙 体力4

![群·赵乾熙（暂时用这张）](./image/generals/avatar/tym__zhaoqianxi.jpg "群·赵乾熙")

> 该武将由我设计。

原神：锁定技，所有<font color="purple">雷属性伤害</font>都会令目标进入<font color="purple">【雷附着】</font>状态，
  而<font color="red">火属性伤害</font>会令目标进入<font color="red">【火附着】</font>状态。
  <br />当一名<font color="purple">【雷附着】</font>状态的角色受到<font color="red">火属性伤害</font>时，
  本次伤害不会令其进入<font color="red">【火附着】</font>状态，而是移除<font color="purple">【雷附着】</font>状态并使该伤害+1；
  当一名<font color="red">【火附着】</font>状态的角色受到<font color="purple">雷属性伤害</font>时，
  本次伤害不会令其进入<font color="purple">【雷附着】</font>状态，而是移除<font color="red">【火附着】</font>状态并令其翻面。

附魔：当有角色使用【杀】造成无属性伤害时，你可以弃一张牌。若你弃的牌为：红色，将此次伤害改为<font color="red">火属性</font>；黑色，改为<font color="purple">雷属性</font>。

### 群·阿威罗 体力3

![群·阿威罗](./image/generals/avatar/xjb__aweiluo.jpg "群·阿威罗")

> 该武将由玩家“导演片子怎么样了”设计。

游龙：锁定技，你的回合开始时，从你开始，每名玩家选择一张手牌交给下家。

**：你的回合开始时，你可以将一张手牌置于你的武将牌上，称为【点】。

跳水：当你受到伤害时，你可以弃掉一张【点】。

罗*：当你的所有【点】花色均不同时，可以视为使用一张【**入侵】，每回合限一次；当你的【点】有4张时，可以视为使用一张【万箭齐发】。
<br><font size="1">已知问题：如果你的【点】有且仅有四张且花色都不同，
  那么【南蛮入侵】【万箭齐发】只能触发一个。这个问题将在后续修复。</font>

玉玊：出牌阶段，你每使用第二张基本牌时，可以将其作为【点】置于你的武将牌上。

## 想游玩我们的武将？

开启您的新月杀服务器，并输入 `install https://gitee.com/baisebaoma/jianyu` 添加本包即可。我们推荐使用 Gitee 链接。

注意：本包需要您的服务器上开启了[神话再临](https://gitee.com/notify-ctrl/shzl)包才可游玩，否则会出现问题。

## 发现了 bug？

请提交 PR 或 Issue，或发送电子邮件至 [baisebaoma@foxmail.com](mailto:baisebaoma@foxmail.com)。感谢！
