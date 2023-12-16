# 新月杀简浴包

[新月杀（FreeKill）](https://gitee.com/notify-ctrl/FreeKill)是一款开源、支持自定义的三国杀联机软件。

本仓库是新月杀的一个扩展包，其中包含我和我的好朋友们的原创武将！之所以叫作简浴包，是因为我们曾经踢足球时自称“监狱队”，而本扩展包的第一个武将是简自豪，故名。所有设计均由我 [@baisebaoma](https://gitee.com/baisebaoma) 实现。

我们的关注点有：足球、英雄联盟等。

本扩展包在新月杀软件中的名字为“简浴”。

本扩展包会保留所有群友设计的原始武将，仅作出文本描述和游戏体验方面的优化（例如，假如你的五个技能全是回合开始可以发动的，那我肯定是要改的）。如果根据以后的游玩体验，这些武将中有不够平衡、不够合理的设计，我会推出优化过后的版本，如界限突破等。

## 想游玩我们的武将？

1. 本扩展包已上线新月杀活动服：<a href="huosan.top">huosan.top</a>，欢迎试用！

2. 如果您有自己的新月杀服务器，请输入 `install https://gitee.com/baisebaoma/jianyu` 添加本扩展包即可。需要您的服务器上开启了[神话再临](https://gitee.com/notify-ctrl/shzl)扩展包才可游玩，否则会出现问题。

## 已实现武将

> 注：此处文本更新日期为2023/12/15，仅供参考，可能已有修改，请以游戏内描述为准。

### 群·简自豪 体力3

![群·简自豪](./image/generals/avatar/xjb__jianzihao.jpg "群·简自豪")

> 该武将由玩家“导演片子怎么样了”设计。

开局：锁定技，回合开始时，所有其他有牌的角色需要交给你一张牌，并视为对你使用一张【杀】。<br>
  <font size="1"><i>“从未如此美妙的开局！”</i></font>

红温：锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。

走位：锁定技，当装备区没有牌时，其他角色计算与你的距离时，始终+1；当装备区有牌时，你计算与其他角色的距离时，始终-1。

圣弩：当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得之。

洗澡：限定技，处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。


### 群·界简自豪 体力3

![群·界简自豪](./image/generals/avatar/tym__jianzihao.jpg "群·界简自豪")

> 该武将由玩家“导演片子怎么样了”设计，我调整。
> 
> 经典的设计经群友体验，认为全场玩家负反馈都很高、风险过高、收益不匹配：没有拿到特定的防具（【藤甲】、【八卦阵】）前，会非常弱，拿到之后才会变得正常。这会导致玩家全力用手气卡刷防具和【闪】，如果没有就很大概率第一轮暴毙；消耗队友手牌；如果第一轮发动限定技并活了下来，也就只有 13 张左右的手牌，爆发能力有限。我将【开局】调整得更为主动，增加了一个技能【三件】~~群友要的~~，并相应削弱了别的技能，制作了这个版本。

开局：出牌阶段限一次，你选择若干名角色。按照你选择的顺序，视为你对他们各使用一张【顺手牵羊】，然后被他们各使用一张【杀】。

三件：锁定技，出牌阶段开始时，若装备区有且仅有3张牌，你视为使用一张【酒】和一张【无中生有】。

洗澡：限定技，处于濒死状态且装备区有牌时，你可以弃置所有装备区的牌、将体力恢复至1，然后每以此法弃置一张牌，你摸一张牌。

红颜：锁定技，你的♠牌视为<font color='red'>♥</font>牌。

走位：锁定技，当装备区没有牌时，其他角色计算与你的距离时，始终+1；当装备区有牌时，你计算与其他角色的距离时，始终-1。

圣弩：当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得之。


### 群·李元浩 体力3

![群·李元浩](./image/generals/avatar/skl__liyuanhao.jpg "群·李元浩")

> 该武将由玩家“拂却心尘”设计。

虎啸：当你使用或打出一张【杀】时，可以将牌堆顶的一张牌置于武将牌上，称为【啸】。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”</i></font>

横刀：你可以将【啸】当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>

立马：你可以将【啸】当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>

二段：锁定技，有且仅有两张【啸】时，你选择失去一点体力或失去所有【啸】。

三件：锁定技，当装备区有且仅有防具和防御马时，你造成的伤害-1。
  <br><font size="1"><i>虎三件，指【中娅沙漏】、【水银之靴】、【大天使之杖】。一些人持不同的观点，但【大天使之杖】没有什么争议。</i></font>


### 群·界李元浩 体力3

![群·界李元浩](./image/generals/avatar/tym__liyuanhao.jpg "群·界李元浩")

> 该武将由玩家“拂却心尘”设计，我加强。<s>但是还是感觉追不上活动服武将的强度</s>

虎啸：当你使用或打出一张【杀】时，可以将牌堆顶的一张牌置于武将牌上，称为<font color="gold">【啸】</font>。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”</i></font>

横刀：你可以将<font color="gold">【啸】</font>当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>

立马：你可以将<font color="gold">【啸】</font>当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>

二段：锁定技，有且仅有两张<font color="gold">【啸】</font>时，
  选择：弃置所有<font color="gold">【啸】</font>并恢复一点体力；将所有<font color="gold">【啸】</font>纳入手牌。

### 群·侯国玉 体力8

![群·侯国玉](./image/generals/avatar/tym__houguoyu.jpg "群·侯国玉")

> 该武将由我设计。

哇袄：锁定技，装备区有且仅有武器和进攻马时，你造成的伤害+1。

制衡：出牌阶段限一次，你可以弃置至少一张牌然后摸等量的牌。

崩坏：锁定技，结束阶段，若你不是体力值最小的角色，你选择减1点体力上限或失去1点体力。

暴虐：主公技，其他群雄武将造成伤害后，其可以进行一次判定，若判定结果为♠，你回复1点体力。

### 群·高天亮 体力4

![群·高天亮](./image/generals/avatar/xjb__gaotianliang.jpg "群·高天亮")

> 该武将由玩家“导演片子怎么样了”设计。

玉玉：1. 锁定技，当有角色对你使用【杀】造成了伤害时，其获得【高天亮之敌】标记；<br>
  2. 受到没有【高天亮之敌】标记的角色或因本次伤害而获得【高天亮之敌】标记的角色造成的伤害时，你可以选择一项：摸三张牌；摸四张牌并翻面。

### 群·赵乾熙 体力3

![群·赵乾熙](./image/generals/avatar/tym__zhaoqianxi.jpg "群·赵乾熙")

> 该武将由我设计。

原神：锁定技，你造成的属性伤害+1。
  <font size="1"><br>提示：<br>
  1. 当你对被横置的角色造成属性伤害时，所有其他被横置的角色会受到的伤害+2，
  因为【铁锁连环】的效果是将你对主目标造成的伤害值（触发【原神】，+1）记录，然后令你对其他所有被横置的角色也造成一次这个值的伤害（再次触发【原神】，+1）。<br>
  2. 当你是双将且另一个武将是界赵乾熙、你发动了【附魔】转化成属性伤害时，
  不会触发这个技能。</font>

猫帽：你可以将一张♠手牌当作【火杀】使用或打出。

帽猫：你可以将一张♠手牌当作【雷杀】使用或打出。
  <br /><font size="1"><i><s>因为Beryl抽满命林尼歪了六次，所以他决定在新月杀中为自己设计一套林尼的技能。</s></i></font>

### 群·界赵乾熙 体力4

![群·界赵乾熙](./image/generals/avatar/tym__zhaoqianxi_2.jpg "群·界赵乾熙")

> 该武将由我设计。

> 新月杀群群友“小嘤嘤”帮助我写了下面这一版描述，感谢！

原神：锁定技，当有角色受到<font color="red">火焰</font>或<font color="Fuchsia">雷电</font>伤害时，若其没有该技能造成的属性标记，令其获得对应属性标记；
  若其拥有该技能造成的属性标记且与此次伤害属性不同，则依据伤害属性造成对应效果并移除标记：<font color="Fuchsia">雷电伤害</font>其翻面；<font color="red">火焰伤害</font>该伤害+1。

附魔：当有角色受到无属性伤害时，
  你可以弃置一张牌，根据颜色变更伤害属性：
  <font color="red">红色</font>，改为<font color="red">火焰</font>；
  黑色，改为<font color="Fuchsia">雷电</font>。

### 群·阿威罗 体力3

![群·阿威罗](./image/generals/avatar/xjb__aweiluo.jpg "群·阿威罗")

> 该武将由玩家“导演片子怎么样了”设计。

游龙：锁定技，回合开始时，有手牌的角色依次将一张手牌交给下家。

核爆：回合开始时，可以将一张手牌置于武将牌上，称为【点】。

跳水：受到伤害时，可以弃置一张【点】。

玉玊：出牌阶段，你每使用第二张基本牌时，可以将其作为【点】置于你的武将牌上。

罗绞：当【点】的数量变化后：<br>
  1. 若你没有两张及以上相同花色的【点】，可以视为立即使用一张【南蛮入侵】，每回合限一次；<br>
  2. 若你有4张【点】，可以视为立即使用一张【万箭齐发】。

## 正在开发的武将

### 群·杨藩 体力4

（暂无肖像）

> 该武将由玩家“敏敏伊人梦中卿”设计。

四吃：受到伤害后，你可以亮出牌堆顶4张牌，根据花色数量触发效果：
1，将这些牌交给一名角色；
2，使用其中一张牌，若都无法使用，则你弃置一张牌；
3，获得其中三张同类型的牌或其中两张不同类型的牌，其余角色各摸一张牌；
4，选择至多3名角色，你与其各失去一点体力。
随后，将剩余的牌置入弃牌堆。

花盆：锁定技，当其他角色使用♣锦囊牌或基本牌，并有且仅有一个不为你的目标时，你进行一次判定，若为<font color="red">♥</font>，则额外指定你为目标。

bo10：觉醒技，准备阶段开始时，当你的判定次数达到10次时，你增加一点体力上限，回复3点体力，摸3张牌，失去技能【花盆】，获得技能【奖杯】。

奖杯：锁定技，你使用的♣基本牌和锦囊牌无视距离和防具、没有使用次数限制；你使用的<font color="red">♥</font>基本牌和锦囊牌无法被响应；出牌阶段结束时，若你出牌阶段只使用过♣和<font color="red">♥</font>牌，摸等量的牌。

## 发现了 bug？

请提交 PR 或 Issue，或发送电子邮件至 [baisebaoma@foxmail.com](mailto:baisebaoma@foxmail.com)。感谢！
