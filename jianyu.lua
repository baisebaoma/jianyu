local extension = Package:new("jy_jianyu")
extension.extensionName = "jianyu"

-- DIY真诚意见：所有你这个包的东西都加一个你自己的开头，这样防止和别人的重名。比如我的"huxiao"一开始就和别人重名了。

local U = require "packages/utility/utility"
local Q = require "packages/jianyu/question"

Fk:loadTranslationTable {
     ["jy_jianyu"] = "简浴",
     ["xjb"] = "导演",
     ["tym"] = "反赌专家",
     ["skl"] = "拂却心尘",
     ["zer"] = "敏敏伊人",
}

-- 熊简自豪
local xjb__jianzihao = General(extension, "xjb__jianzihao", "qun", 3)

-- 红温
local jy_hongwen = fk.CreateFilterSkill{
  name = "jy_hongwen",
  card_filter = function(self, to_select, player)
    return (to_select.suit == Card.Spade or to_select.suit == Card.Club) and player:hasSkill(self)
  end,
  view_as = function(self, to_select)
    if to_select.suit == Card.Club then 
      return Fk:cloneCard(to_select.name, Card.Diamond, to_select.number)
    else -- Spade
      return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
    end
  end,
}

-- 走位
local jy_zouwei = fk.CreateDistanceSkill{
  name = "jy_zouwei",
  correct_func = function(self, from, to)
    -- 有装备时视为-1
    if from:hasSkill(self) and #from:getCardIds(Player.Equip) ~= 0 then
      return -1
    end
    -- 没装备时视为+1
    if to:hasSkill(self) and #to:getCardIds(Player.Equip) == 0 then
      return 1
    end
    return 0
  end,
}

-- 圣弩
-- 参考自formation包的君刘备
local jy_shengnu = fk.CreateTriggerSkill{
  name = "jy_shengnu",
  anim_type = 'drawcard',
  events = {fk.AfterCardsMove},
  -- frequency = Skill.Compulsory,  -- 我觉得还是把这个关掉比较好，因为多个简自豪的时候会混乱。
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "crossbow" then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "crossbow" then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(ids)
    player.room:obtainCard(player, dummy, true, fk.ReasonPrey)
  end,
}


-- 洗澡
local jy_xizao = fk.CreateTriggerSkill{
  name = "jy_xizao",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    -- player:reset()
    player:drawCards(3, self.name)
    if player.dead or not player:isWounded() then return end
    room:recover({
      who = player,
      num = math.min(1, player.maxHp) - player.hp,
      recoverBy = player,
      skillName = self.name,
    })
    player:turnOver()
  end,
}

-- 开局
-- 参考forest包贾诩 刘备 god包神曹操

local jy_kaiju = fk.CreateTriggerSkill{
  name = "jy_kaiju",  -- jy_kaiju$是主公技
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() and not player.dead then  -- 如果我自己死了，那就不要继续了
        -- local id = room:askForCardChosen(p, p, "he", "#jy_kaiju-choose")
        -- 只能和
        -- room:obtainCard(player, id, false, fk.ReasonPrey)
        -- 一起用，原因不明。下面这个实现方法也可以。测了一圈，感觉是obtainCard的问题。
        local id = room:askForCard(p, 1, 1, true, self.name, false, nil, "#jy_kaiju-choose")
        room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, false, nil)

        room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
      end
    end
  end,
}

-- local id = room:askForCardChosen(player, p, "hej", self.name)  -- 我选他一张牌

xjb__jianzihao:addSkill(jy_kaiju)
xjb__jianzihao:addSkill(jy_hongwen)
xjb__jianzihao:addSkill(jy_zouwei)
xjb__jianzihao:addSkill(jy_shengnu)
xjb__jianzihao:addSkill(jy_xizao)

Fk:loadTranslationTable{
  ["xjb__jianzihao"] = "简自豪",

  ["jy_kaiju"] = "开局",
  [":jy_kaiju"] = [[锁定技，准备阶段，所有其他有牌的角色需要交给你一张牌，并视为对你使用一张【杀】。<br>
  <font size="1"><i>“从未如此美妙的开局！”</i></font>]],
  ["$jy_kaiju1"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju2"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju3"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju4"] = "好亏呀，我每一波都。",
  ["$jy_kaiju5"] = "被秀了，操。",
  ["$jy_kaiju6"] = "从未如此美妙的开局！请为我欢呼，为我喝，喝，喝彩，OK？",
  ["$jy_kaiju7"] = "如此美妙的开局，这是我近两天来第一次啊！",
  ["$jy_kaiju8"] = "Oh my God，我要珍惜这段时光，我要好好地将它珍惜！",
  ["#jy_kaiju-choose"] = "交给简自豪一张牌，视为对他使用【杀】",

  ["jy_hongwen"] = "红温",
  [":jy_hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$jy_hongwen1"] = "唉，不该出水银的。",
  ["$jy_hongwen2"] = "哎，兄弟我为什么不打四带两对儿啊，兄弟？",
  ["$jy_hongwen3"] = "好难受啊！",
  ["$jy_hongwen4"] = "操，可惜！",
  -- ["$jy_hongwen5"] = "这是咋想的呀？",  -- 这条语音太吵了

  ["jy_zouwei"] = "走位",
  [":jy_zouwei"] = "锁定技，当装备区没有牌时，其他角色计算与你的距离时，始终+1；当装备区有牌时，你计算与其他角色的距离时，始终-1。",
  ["$jy_zouwei1"] = "玩一下，不然我是不是一张牌没有出啊兄弟？",
  ["$jy_zouwei2"] = "完了呀！",

  ["jy_shengnu"] = "圣弩",
  [":jy_shengnu"] = "当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得之。",
  ["$jy_shengnu1"] = "哎兄弟们我这个牌不能拆吧？",
  ["$jy_shengnu2"] = "补刀瞬间回来了！",
  ["$jy_shengnu3"] = "恶心我，我也恶心你啊，互恶心呗！",

  ["jy_xizao"] = "洗澡",
  [":jy_xizao"] = "限定技，处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$jy_xizao1"] = "呃啊啊啊啊啊啊啊！！",
  ["$jy_xizao2"] = "也不是稳赢吧，我觉得赢了！",
  ["$jy_xizao3"] = "真的我是真玩不了，这跟变态没关系，我好他妈的气！",

  ["~xjb__jianzihao"] = "好像又要倒下了……",
}


-- 第二代简自豪
local tym__jianzihao = General(extension, "tym__jianzihao", "qun", 3)

local jy_sanjian = fk.CreateTriggerSkill{
  name = "jy_sanjian",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},  -- 事件开始时
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)  -- 如果是我这个角色，如果是有这个技能的角色，如果是出牌阶段，如果这个角色的装备数是3
      and player.phase == Player.Play and #player:getCardIds(Player.Equip) == 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("analeptic", nil, player, player, self.name, false)
    room:useVirtualCard("ex_nihilo", nil, player, player, self.name, false)
  end,
}

local jy_kaiju_2 = fk.CreateActiveSkill{
  name = "jy_kaiju_2",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)

    -- 判断目标是否不能成为【顺手牵羊】的目标
    s = Fk:currentRoom():getPlayerById(to_select)
    local snatch = Fk:cloneCard("snatch")
    if Self:isProhibited(s, snatch) then  -- 前面的是自己，后面的是别人！
      return false
    end

    return to_select ~= Self.id and -- 如果目标不是自己
      not s:isAllNude()  -- 而且不是啥也没有，那就可以对他用这个技能
  end,
  min_target_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    -- TODO：sort use.tos
    for _, to in ipairs(use.tos) do
      local p = room:getPlayerById(to)

      if not player.dead then
        room:useVirtualCard("snatch", nil, player, p, self.name, true)  -- 顺
        room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
      end
    end
  end,
}

local jy_xizao_2 = fk.CreateTriggerSkill{
  name = "jy_xizao_2",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and 
    player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and #player:getCardIds(Player.Equip) ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    -- player:reset()
    player:drawCards(3, self.name)
    if player.dead or not player:isWounded() then return end
    -- 将体力回复至1点
    room:recover({
      who = player,
      num = math.min(1, player.maxHp) - player.hp,
      recoverBy = player,
      skillName = self.name,
    })
    equip_num = #player:getCardIds(Player.Equip)
    player:throwAllCards("e")
    player:drawCards(equip_num)
  end,
}

tym__jianzihao:addSkill(jy_kaiju_2)
tym__jianzihao:addSkill(jy_sanjian)
tym__jianzihao:addSkill("hongyan")  -- 这个技能要加风火林山包才能使用！
tym__jianzihao:addSkill("jy_zouwei")
tym__jianzihao:addSkill("jy_shengnu")
tym__jianzihao:addSkill(jy_xizao_2)

Fk:loadTranslationTable{
  ["tym__jianzihao"] = "界简自豪",

  ["jy_kaiju_2"] = "开局",
  [":jy_kaiju_2"] = "出牌阶段限一次，你选择若干名角色，依次视为你对其使用一张【顺手牵羊】，然后被其使用一张【杀】。",
  ["$jy_kaiju_21"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju_22"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju_23"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju_24"] = "好亏呀，我每一波都。",
  ["$jy_kaiju_25"] = "被秀了，操。",
  ["$jy_kaiju_26"] = "从未如此美妙的开局！请为我欢呼，为我喝，喝，喝彩，OK？",
  ["$jy_kaiju_27"] = "如此美妙的开局，这是我近两天来第一次啊！",
  ["$jy_kaiju_28"] = "Oh my God，我要珍惜这段时光，我要好好地将它珍惜！",

  ["jy_sanjian"] = "三件",
  [":jy_sanjian"] = [[锁定技，出牌阶段开始时，若装备区有且仅有3张牌，你视为使用一张【酒】和一张【无中生有】。]],
  ["$jy_sanjian1"] = "也不是稳赢吧，我觉得赢了！",

  ["jy_xizao_2"] = "洗澡",
  [":jy_xizao_2"] = "限定技，处于濒死状态且装备区有牌时，你可以弃置所有装备区的牌、将体力恢复至1，然后每以此法弃置一张牌，你摸一张牌。",
  ["$jy_xizao_21"] = "呃啊啊啊啊啊啊啊！！",
  ["$jy_xizao_22"] = "也不是稳赢吧，我觉得赢了！",
  ["$jy_xizao_23"] = "真的我是真玩不了，这跟变态没关系，我好他妈的气！",

  ["~tym__jianzihao"] = "好像又要倒下了……",
}

-- 尚李元浩
local skl__liyuanhao = General(extension, "skl__liyuanhao", "qun", 3)

-- 虎啸
-- 参考自铁骑，屯田，脑洞包明哲，克己（原来克己已经监视了使用和打出了，不用写那么复杂）
local jy_huxiao = fk.CreateTriggerSkill{
  name = "jy_huxiao",
  anim_type = "special",
  events = {fk.CardResponding, fk.CardUsing},  -- 包括了使用和打出
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      return target == player
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(room:getNCards(1))
    player:addToPile("skl__liyuanhao_xiao", dummy, true, self.name)
  end,
}

-- 啸酒
local jy_huxiao_analeptic = fk.CreateViewAsSkill{
  name = "jy_huxiao_analeptic",
  anim_type = "defensive",
  pattern = "analeptic",
  expand_pile = "skl__liyuanhao_xiao",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local xiaos = Self:getPile("skl__liyuanhao_xiao")
    if #xiaos == 0 then return false end
    return Self:getPileNameOfId(to_select) == "skl__liyuanhao_xiao"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}

-- 啸闪
local jy_huxiao_jink = fk.CreateViewAsSkill{
  name = "jy_huxiao_jink",
  anim_type = "defensive",
  pattern = "jink",
  expand_pile = "skl__liyuanhao_xiao",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local xiaos = Self:getPile("skl__liyuanhao_xiao")
    if #xiaos == 0 then return false end
    return Self:getPileNameOfId(to_select) == "skl__liyuanhao_xiao"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("jink")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}

-- 二段
-- 首先BeforeCardsMove判断一次是否有牌进/出你的特殊区，然后如果有，
-- 再在AfterCardsMove里判断是否这张牌是啸，而且啸的数量变成了2。
-- 参考自周泰，界周泰，国战formation守成
local jy_erduanxiao = fk.CreateTriggerSkill{
  name = "jy_erduanxiao",
  anim_type = "negative",
  events = {fk.BeforeCardsMove},  -- 理论上来说每次牌的移动只有同一个方向的
  -- frequency = Skill.Compulsory,
  mute = true,

  -- 测试通过。1-2，3-2都可以顺利触发。
  -- 我猜想原因是1-2的时候可能有多张牌进出，而3-2的时候只会有一张牌出去。但我搞不懂这个数据结构，
  -- 不知道为什么有一个是两层循环，有一个是一层循环。
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end  -- 如果我自己没有这个技能，那就算了

    local xiaos = player:getPile("skl__liyuanhao_xiao")
    player.is_xiao_changing = nil

    -- 判断是否有牌出去
    for _, move in ipairs(data) do  -- 第一层循环，不知道为啥
      if move.from then  -- 照着抄的，牌离开
        -- print("有牌正打算离开")
        if move.from == player.id then
          -- print("有牌正打算从你家离开")
          if #xiaos == 3 then
            -- print("啸是3")
            for _, info in ipairs(move.moveInfo) do  -- 还有第二层循环。我自己的代码里没有第二层
              if info.fromArea == Card.PlayerSpecial then
                -- print("有牌正打算从你家特殊区离开")
                return true
              end
            end
          end
        end
      end
    end
    
    -- 判断是否有牌进来
    if #xiaos == 1 then  -- 如果啸是1
      for _, move in ipairs(data) do  -- 如果有一张牌是进入或者离开我的特殊区，那么这个函数可以触发
        if move.to == player.id and move.toArea == Card.PlayerSpecial and
          move.specialName == "skl__liyuanhao_xiao" then
          return true
        end
      end
    end
  end,

  on_trigger = function(self, event, target, player, data)
    -- 触发之后，设置变量，告诉下一个函数有没有可能在发生变化
    local xiaos = player:getPile("skl__liyuanhao_xiao")
    player.is_xiao_changing = #xiaos
  end,
}

local jy_erduanxiao_trigger = fk.CreateTriggerSkill{
  name = "#jy_erduanxiao_trigger",
  events = {fk.AfterCardsMove},
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    local xiaos = player:getPile("skl__liyuanhao_xiao")
    -- 如果卡牌移动前和移动后“点”相同，那就证明是其他的特殊区的牌，直接return
    if player.is_xiao_changing == #xiaos then return false end

    if not player:hasSkill(self) then return false end
    return #xiaos == 2  -- 如果啸为2
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"#lose_xiao", "#lose_hp_1"}, self.name)
    if choice == "#lose_xiao" then
      local xiaos = player:getPile("skl__liyuanhao_xiao")
      room:throwCard(xiaos, self.name, player, player)  -- 把啸全部扔掉
    elseif choice == "#lose_hp_1" then
      room:loseHp(player, 1, self.name) -- 失去一点体力
      player.is_xiao_changing = false
    end
  end,
}
jy_erduanxiao:addRelatedSkill(jy_erduanxiao_trigger)

-- 三件 已完成 测试通过
local jy_husanjian = fk.CreateTriggerSkill{
  name = "jy_husanjian",
  frequency = Skill.Compulsory,
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return false end
    -- 现在 target 已经是 player，并且 player 拥有这个技能了。这个时候再来看他的装备区
    local weapon = Fk:getCardById(player:getEquipment(Card.SubtypeWeapon))
    local armor = Fk:getCardById(player:getEquipment(Card.SubtypeArmor))
    local defensive_ride = Fk:getCardById(player:getEquipment(Card.SubtypeDefensiveRide))
    local offensive_ride = Fk:getCardById(player:getEquipment(Card.SubtypeOffensiveRide))
    local treasure = Fk:getCardById(player:getEquipment(Card.Treasure))
    return not weapon and 
           armor and
           defensive_ride and 
           not offensive_ride and
           not treasure
           -- 有且只有防具和+1马
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    room:notifySkillInvoked(player, self.name, "masochism")  -- 如果这个技能改了，建议把这里的特效也改一下。
    data.damage = data.damage - 1
  end,
}

skl__liyuanhao:addSkill(jy_huxiao)
skl__liyuanhao:addSkill(jy_huxiao_analeptic)
skl__liyuanhao:addSkill(jy_huxiao_jink)
skl__liyuanhao:addSkill(jy_erduanxiao)
skl__liyuanhao:addSkill(jy_husanjian)

Fk:loadTranslationTable {
  ["skl__liyuanhao"] = "李元浩",
  ["skl__liyuanhao_xiao"] = "啸",

  ["jy_huxiao"] = "虎啸",
  [":jy_huxiao"] = [[当你使用或打出一张【杀】时，可以将牌堆顶的一张牌置于武将牌上，称为“啸”。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”</i></font>]],

  ["jy_huxiao_analeptic"] = "横刀",
  [":jy_huxiao_analeptic"] = [[你可以将“啸”当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>]],

  ["jy_huxiao_jink"] = "立马",
  [":jy_huxiao_jink"] = [[你可以将“啸”当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>]],

  ["jy_erduanxiao"] = "二段",
  [":jy_erduanxiao"] = "锁定技，有且仅有两张“啸”时，你选择失去一点体力或失去所有“啸”。",
  ["#jy_erduanxiao_trigger"] = "二段",
  ["#lose_xiao"] = "失去所有“啸”", 
  ["#lose_hp_1"] = "失去一点体力",

  ["jy_husanjian"] = "三件",
  [":jy_husanjian"] = [[锁定技，当装备区有且仅有防具和防御马时，你造成的伤害-1。
  <br><font size="1"><i>虎三件，指【中娅沙漏】、【水银之靴】、【大天使之杖】。一些人持不同的观点，但【大天使之杖】没有什么争议。</i></font>]],
}

-- 唐李元浩
-- 在活动服环境里，也许没那么强？
local tym__liyuanhao = General(extension, "tym__liyuanhao", "qun", 3)

-- 界虎啸
-- 参考自铁骑，屯田，脑洞包明哲，克己（原来克己已经监视了使用和打出了，不用写那么复杂）
local jy_huxiao_2 = fk.CreateTriggerSkill{
  name = "jy_huxiao_2",
  anim_type = "special",
  events = {fk.CardResponding, fk.CardUsing},  -- 包括了使用和打出
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      return target == player
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(room:getNCards(1))
    player:addToPile("tym__liyuanhao_xiao", dummy, true, self.name)
  end,
}

-- 界啸酒
local jy_huxiao_analeptic_2 = fk.CreateViewAsSkill{
  name = "jy_huxiao_analeptic_2",
  anim_type = "defensive",
  pattern = "analeptic",
  expand_pile = "tym__liyuanhao_xiao",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local xiaos = Self:getPile("tym__liyuanhao_xiao")
    if #xiaos == 0 then return false end
    return Self:getPileNameOfId(to_select) == "tym__liyuanhao_xiao"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("analeptic")
    -- local c = Fk:cloneCard("ex_nihilo")
    c.skillName = self.name
    -- print("克隆的牌c的参数：c.name ", c.name, " c.trueName ", c.trueName)
    c:addSubcard(cards[1])
    return c
  end,
}

-- 界啸闪
local jy_huxiao_jink_2 = fk.CreateViewAsSkill{
  name = "jy_huxiao_jink_2",
  anim_type = "defensive",
  pattern = "jink",
  expand_pile = "tym__liyuanhao_xiao",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local xiaos = Self:getPile("tym__liyuanhao_xiao")
    if #xiaos == 0 then return false end
    return Self:getPileNameOfId(to_select) == "tym__liyuanhao_xiao"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("jink")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}


-- 界二段
-- 这里的jy_erduanxiao_2全部都是抄上面普通李元浩的，因为只有数值差异。如果上面的改了，这里也得改
local jy_erduanxiao_2 = fk.CreateTriggerSkill{
  name = "jy_erduanxiao_2",
  anim_type = "support",
  events = {fk.BeforeCardsMove},  -- 理论上来说每次牌的移动只有同一个方向的
  -- frequency = Skill.Compulsory,
  mute = true,

  -- 测试通过。1-2，3-2都可以顺利触发。
  -- 我猜想原因是1-2的时候可能有多张牌进出，而3-2的时候只会有一张牌出去。但我搞不懂这个数据结构，
  -- 不知道为什么有一个是两层循环，有一个是一层循环。
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end  -- 如果我自己没有这个技能，那就算了

    local xiaos = player:getPile("tym__liyuanhao_xiao")
    player.is_xiao_changing = nil

    -- 判断是否有牌出去
    for _, move in ipairs(data) do  -- 第一层循环，不知道为啥
      if move.from then  -- 照着抄的，牌离开
        -- print("有牌正打算离开")
        if move.from == player.id then
          -- print("有牌正打算从你家离开")
          if #xiaos == 3 then
            -- print("啸是3")
            for _, info in ipairs(move.moveInfo) do  -- 还有第二层循环。我自己的代码里没有第二层
              if info.fromArea == Card.PlayerSpecial then  -- 出去的时候不需要判断specialName，因为去的是弃牌堆
                -- print("有牌正打算从你家特殊区离开")
                return true
              end
            end
          end
        end
      end
    end
    
    -- 判断是否有牌进来
    if #xiaos == 1 then  -- 如果啸是1
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerSpecial and
          move.specialName == "tym__liyuanhao_xiao" then
          return true
        end
      end
    end
  end,

  on_trigger = function(self, event, target, player, data)
    local xiaos = player:getPile("skl__liyuanhao_xiao")
    player.is_xiao_changing = #xiaos
  end,
}

local jy_erduanxiao_trigger_2 = fk.CreateTriggerSkill{
  name = "#jy_erduanxiao_trigger_2",
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    local xiaos = player:getPile("skl__liyuanhao_xiao")
    if #xiaos == player.is_xiao_changing then return false end
    return player:hasSkill(self) and -- 如果是有二段啸的角色
      #player:getPile("tym__liyuanhao_xiao") == 2  -- 如果啸为2
  end,

  on_cost = function(self, event, target, player, data)
    -- print("jy_erduanxiao_trigger 已触发，现在player.is_xiao_changing的值是", player.is_xiao_changing)
    local room = player.room
    local choices = {"#lose_xiao_2", "#lose_hp_1_2"}
    -- 如果体力不是满的，两个选项都有；如果是满的，就黑掉【恢复体力】那个按钮。这个改动不需要改到标李元浩那边去，因为标李元浩是掉血。
    if player.hp ~= player.maxHp then
      self.choice = room:askForChoice(player, choices, self.name)
    else
      self.choice = room:askForChoice(player, {"#lose_xiao_2"}, self.name, nil, nil, choices)
    end
    return true
  end,

  on_use = function(self, event, target, player, data)
    local xiaos = player:getPile("tym__liyuanhao_xiao")
    local room = player.room
    if self.choice == "#lose_xiao_2" then
      -- 将所有“啸”纳入自己的手牌
      room:moveCardTo(xiaos, Card.PlayerHand, player, fk.ReasonJustMove, self.name, "tym__liyuanhao_xiao", true, player.id)
    elseif self.choice == "#lose_hp_1_2" then
      -- 弃置所有“啸”
      room:throwCard(xiaos, self.name, player, player)  -- 把啸全部扔掉
      -- 回复1点体力
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}
jy_erduanxiao_2:addRelatedSkill(jy_erduanxiao_trigger_2)

-- 因为是两个不同的角色，两个角色的特殊区是不能通用的，所以必须分开写代码。
tym__liyuanhao:addSkill(jy_huxiao_2)
tym__liyuanhao:addSkill(jy_huxiao_analeptic_2)
tym__liyuanhao:addSkill(jy_huxiao_jink_2)
tym__liyuanhao:addSkill(jy_erduanxiao_2)
tym__liyuanhao:addSkill("paoxiao")

Fk:loadTranslationTable {
  ["tym__liyuanhao"] = "界李元浩",
  ["tym__liyuanhao_xiao"] = "<font color=\"gold\">啸</font>",

  ["jy_huxiao_2"] = "虎啸",
  [":jy_huxiao_2"] = [[当你使用或打出一张【杀】时，可以将牌堆顶的一张牌置于武将牌上，称为“啸”。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”</i></font>]],

  ["jy_huxiao_analeptic_2"] = "横刀",
  [":jy_huxiao_analeptic_2"] = [[你可以将“啸”当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>]],

  ["jy_huxiao_jink_2"] = "立马",
  [":jy_huxiao_jink_2"] = [[你可以将“啸”当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>]],

  ["jy_erduanxiao_2"] = "二段",
  [":jy_erduanxiao_2"] = [[锁定技，有且仅有两张“啸”时，
  选择：弃置所有“啸”并恢复一点体力；将所有“啸”纳入手牌。]],
  ["#jy_erduanxiao_trigger_2"] = "二段",
  ["#lose_xiao_2"] = [[将所有“啸”纳入手牌]], 
  ["#lose_hp_1_2"] = [[弃置所有“啸”并恢复一点体力]],
}

-- 高天亮
local xjb__gaotianliang = General(extension, "xjb__gaotianliang", "qun", 4)

local jy_yuyu = fk.CreateTriggerSkill{
  name = "jy_yuyu",
  anim_type = "masochism",
  events = {fk.Damaged},
  -- 遗计就是没有can_trigger的，遗计也不用判断player.hasSkill(self)，也不用判断伤害目标是自己，因为被省略了
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    self.this_time_slash = false
    if data.card and data.from and data.card.trueName == "slash" then  -- 如果是杀
      if data.from:getMark("@jy_yuyu_enemy") == 0 then   -- 如果他不是敌人
        self.this_time_slash = true  -- 如果他是因为这次伤害变成了天敌，那么写在this_time_slash里
        room:setPlayerMark(data.from, "@jy_yuyu_enemy", "")  -- 空字符串也是true
      end
    end
    if self.this_time_slash or data.from:getMark("@jy_yuyu_enemy") == 0 then  -- 如果他不是敌人
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cost = room:askForSkillInvoke(player, self.name, data)
    if cost then
      local choices = {"#jy_yuyu_draw3", "#jy_yuyu_draw4turnover"} 
      self.choice = room:askForChoice(player, choices, self.name, "#jy_yuyu_ask_which")  -- 如果玩家确定使用，询问用哪个
    end
    return cost
  end,
  on_use = function(self, event, target, player, data)
    if self.choice == "#jy_yuyu_draw3" then
      player:drawCards(3)
    else
      player:drawCards(6)
      player:turnOver()
    end
    self.this_time_slash = false
  end,
}

xjb__gaotianliang:addSkill(jy_yuyu)

Fk:loadTranslationTable {
  ["xjb__gaotianliang"] = "高天亮",

  ["jy_yuyu"] = "玉玉",
  [":jy_yuyu"] = [[1. 锁定技，当有角色对你使用【杀】造成了伤害时，其获得【致郁】标记；<br>
  2. 受到没有【致郁】标记的角色或因本次伤害而获得【致郁】标记的角色造成的伤害时，你可以选择一项：摸三张牌；摸六张牌并翻面。]],
  ["@jy_yuyu_enemy"] = "致郁",
  ["#jy_yuyu_ask_which"] = "玉玉：请选择你要触发的效果",
  ["#jy_yuyu_draw3"] = "摸三张牌",
  ["#jy_yuyu_draw4turnover"] = "摸六张牌并翻面",
  ["$jy_yuyu1"] = "我……我真的很想听到你们说话……",
  ["$jy_yuyu2"] = "我天天被队霸欺负，他们天天骂我。",
  ["$jy_yuyu3"] = "有什么话是真的不能讲的……为什么一定……每次都是……一个人在讲……",

  ["~xjb__gaotianliang"] = "顶不住啦！我每天都活在水深火热里面。",
}

-- -- 赵乾熙
-- local tym__zhaoqianxi = General(extension, "tym__zhaoqianxi", "qun", 4)

-- -- 参考自藤甲。要把DamageInflicted改成DamageCaused，就是你对别人造成伤害的意思。
-- -- 如果是DamageInflicted，就是别人对你造成伤害的意思。
-- local jy_yuanshen = fk.CreateTriggerSkill{
--   name = "jy_yuanshen",
--   frequency = Skill.Compulsory,
--   anim_type = "offensive",
--   refresh_events = {fk.DamageCaused},
--   can_refresh = function(self, event, target, player, data)
--     if not (target == player and player:hasSkill(self)) then return false end
--     return data.damageType ~= fk.NormalDamage and not data.chain
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.damage = data.damage + 1
--   end,
-- }

-- local jy_cathat = fk.CreateViewAsSkill{
--   name = "jy_cathat",
--   anim_type = "offensive",
--   pattern = "slash",
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then return end
--     local card = Fk:cloneCard("fire__slash")
--     card.skillName = self.name
--     card:addSubcard(cards[1])
--     return card
--   end,
-- }

-- local jy_hatcat = fk.CreateViewAsSkill{
--   name = "jy_hatcat",
--   anim_type = "offensive",
--   pattern = "slash",
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then return end
--     local card = Fk:cloneCard("thunder__slash")
--     card.skillName = self.name
--     card:addSubcard(cards[1])
--     return card
--   end,
-- }

-- tym__zhaoqianxi:addSkill(jy_yuanshen)
-- tym__zhaoqianxi:addSkill(jy_cathat)
-- tym__zhaoqianxi:addSkill(jy_hatcat)

-- Fk:loadTranslationTable {
--   ["tym__zhaoqianxi"] = "赵乾熙",
  
--   ["jy_yuanshen"] = "原力",
--   [":jy_yuanshen"] = [[锁定技，你造成的非【铁锁连环】传导的属性伤害+1。]],

--   ["jy_cathat"] = "猫帽",
--   [":jy_cathat"] = [[你可以将一张♠手牌当作【火杀】使用或打出。]],

--   ["jy_hatcat"] = "帽猫",
--   [":jy_hatcat"] = [[你可以将一张♠手牌当作【雷杀】使用或打出。
--   <br /><font size="1"><i><s>因为Beryl抽满命林尼歪了六次，所以他决定在新月杀中为自己设计一套林尼的技能。</s></i></font>]],
-- }

-- -- 界赵乾熙
-- local tym__2__zhaoqianxi = General(extension, "tym__2__zhaoqianxi", "qun", 4)
-- -- tym__2__zhaoqianxi.hidden = true

-- local jy_yuanshen_2 = fk.CreateTriggerSkill{
--   name = "jy_yuanshen_2",
--   frequency = Skill.Compulsory,
--   anim_type = "offensive",
--   events = {fk.DamageInflicted},
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return false end
--     return (data.damageType == fk.FireDamage or data.damageType == fk.ThunderDamage) and
--       not data.is_jy_yuanshen_2_triggered
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if data.damageType then
--       -- 使用for循环以方便后面添加元素反应类型。每次只会有一种反应发生。
--       -- element[1]是A属性类型，element[2]是A对应的附着标记，
--       -- element[3]是A要反应的附着标记B，element[4]是要造成的效果
--       -- element[5]是这个反应需要造成的广播提示
--       -- Lua 的数组从1开始
--       for _, element in ipairs({ 
--         {fk.FireDamage, "@jy_yuanshen_2_pyro", "@jy_yuanshen_2_electro", 
--           function(self, event, target, player, data) data.damage = data.damage + 1 end,
--           "#jy_yuanshen_2_reaction_1",
--         },
--         {fk.ThunderDamage, "@jy_yuanshen_2_electro", "@jy_yuanshen_2_pyro", 
--           function(self, event, target, player, data) 
--             data.to:turnOver()  -- 受到伤害的人翻面
--           end,
--           "#jy_yuanshen_2_reaction_2",
--         }, 
--       }) do
--         if data.damageType == element[1] then  -- 如果是A属性伤害
--           if data.to:getMark(element[3]) ~= 0 then  -- 如果目标有B附着
--             room:setPlayerMark(data.to, element[3], 0)  -- 将B附着解除
--             room:doBroadcastNotify("ShowToast", Fk:translate(element[5]))  -- 广播发生了元素反应。先广播再造成效果！
--             element[4](self, event, target, player, data)  -- 造成效果
--             data.is_jy_yuanshen_2_triggered = true  -- 如果有多个拥有这个技能的人，告诉他不用再发动了
--             return  -- 结束了，不用判断下面的了
--           end
--           if data.to:getMark(element[2]) == 0 then   -- 如果目标没有A附着
--             room:setPlayerMark(data.to, element[2], "")  -- 造成A附着
--             data.is_jy_yuanshen_2_triggered = true  -- 如果有多个拥有这个技能的人，告诉他不用再发动了
--             return
--           end
--         end
--       end
--     end
--   end,
-- }

-- -- 参考自悲歌
-- local jy_fumo = fk.CreateTriggerSkill{
--   name = "jy_fumo",
--   anim_type = "masochism",
--   events = {fk.DamageInflicted},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and 
--       data.damageType == fk.NormalDamage and not data.to.dead and not player:isNude()
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#jy_fumo-invoke::"..target.id, true)
--     if #card > 0 then
--       room:doIndicate(player.id, {target.id})  -- 播放指示线
--       self.cost_data = card
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:throwCard(self.cost_data, self.name, player, player)
--     if target.dead then return false end
--     card = Fk:getCardById(self.cost_data[1])  -- 这张被弃置的牌是通过self.cost_data传过来的，是一个int table，你得转化成一张card
--     if card.color == Card.Red then
--       data.damageType = fk.FireDamage
--     elseif card.color == Card.Black then
--       data.damageType = fk.ThunderDamage
--     end
--   end,
-- }

-- tym__2__zhaoqianxi:addSkill(jy_yuanshen_2)
-- tym__2__zhaoqianxi:addSkill(jy_fumo)

-- Fk:loadTranslationTable {
--   ["tym__2__zhaoqianxi"] = "界赵乾熙",
  
--   ["jy_yuanshen_2"] = "原神",
--   [":jy_yuanshen_2"] = [[锁定技，当有角色受到<font color="red">火焰</font>或<font color="Fuchsia">雷电</font>伤害时，若其没有该技能造成的属性标记，令其获得对应属性标记；
--   若其拥有该技能造成的属性标记且与此次伤害属性不同，则依据伤害属性造成对应效果并移除标记：<font color="Fuchsia">雷电伤害</font>其翻面；<font color="red">火焰伤害</font>该伤害+1。该技能对每次伤害只会触发一次，不论场上是否有多个角色拥有该技能。]],
--   ["#jy_yuanshen_2_reaction_1"] = [[<font color="red">火焰伤害</font>与<font color="Fuchsia">【雷电】</font>发生反应，伤害+1]],
--   ["#jy_yuanshen_2_reaction_2"] = [[<font color="Fuchsia">雷电伤害</font>与<font color="red">【火焰】</font>发生反应，目标翻面]],

--   ["@jy_yuanshen_2_pyro"] = [[<font color="red">火焰</font>]],
--   ["@jy_yuanshen_2_electro"] = [[<font color="Fuchsia">雷电</font>]],

--   ["jy_fumo"] = "附魔",
--   ["#jy_fumo-invoke"] = "附魔：%dest 受到伤害，你可以弃置一张牌，改为属性伤害",
--   [":jy_fumo"] = [[当有角色受到无属性伤害时，
--   你可以弃置一张牌，根据颜色变更伤害属性：
--   <font color="red">红色</font>，改为<font color="red">火焰</font>；
--   黑色，改为<font color="Fuchsia">雷电</font>。]],
-- }

-- 阿威罗
local xjb__aweiluo = General(extension, "xjb__aweiluo", "qun", 3)

-- 游龙
local jy_youlong = fk.CreateTriggerSkill{
  name = "jy_youlong",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) 
      and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers(player, true)) do
      if not p:isKongcheng() then  -- 如果他有手牌
        local id = room:askForCard(p, 1, 1, false, self.name, false, nil, "#jy_youlong-choose")
        assert(id)
        local next = p.next  -- 下家
        while next.dead do  -- 一直找，直到找到一个活的下家
          next = next.next
        end
        room:moveCardTo(id, Card.PlayerHand, next, fk.ReasonJustMove, self.name, nil, false, player.id)
      end
    end
  end,
}

-- 核爆
local jy_hebao = fk.CreateTriggerSkill{
  name = "jy_hebao",
  anim_type = "special",
  events = {fk.EventPhaseProceeding},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local id = room:askForCard(player, 1, 1, false, self.name, true, nil, "#jy_hebao-choose")
    player:addToPile("xjb__aweiluo_dian", id, true, self.name)
  end,
}

-- 跳水
local jy_tiaoshui = fk.CreateTriggerSkill{
  name = "jy_tiaoshui",
  anim_type = "special",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    local dians = player:getPile("xjb__aweiluo_dian")
    return target == player and target:hasSkill(self.name) and 
      #dians ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dians = player:getPile("xjb__aweiluo_dian")
    -- 以后“选择一张特殊区的牌并且弃置”这个要求就这么写。
    local id = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|xjb__aweiluo_dian|.|.|.", "#jy_tiaoshui", "xjb__aweiluo_dian", true)
    room:throwCard(id, self.id, player, player)
    -- askForDiscard 函数是不能对特殊区的牌生效的
    -- local id = room:askForDiscard(player, 1, 1, false, self.name, true, ".|.|.|xjb__aweiluo_dian|.|.|.", "#jy_tiaoshui", false, true)
  end,
}

-- 罗绞
-- 这个技能难以实现。目前好像还没看到其他的武将是“特殊区牌量变化时立即执行效果”的，一般都是某个特定的时机触发，
-- 如邓艾，在准备阶段才判断有几张。所以我注释写详细一点，方便其他开发者参考。
-- 其实前面的两个李元浩也是这样。不过这个技能比那两个更复杂，解释这个会比较好。
-- 
-- 新月杀现有的函数无法判断一张牌移动时，如果是离开特殊区，离开的是否是某特定的特殊区（在这个技能里，是“点”）。我们作如下设计：
-- 罗绞主技能监视“卡牌移动前”事件，将卡牌移动前的“点”数量记录，并传给另一个关联技能，其监视“卡牌移动后”事件，也记录一次移动后“点”的数量。
-- 如果卡牌移动之后“点”数没有变化，那么不要触发。
-- 这样就能防止当其他人给我挂上或丢掉其他特殊区的牌时，也触发我们的技能。
local jy_luojiao = fk.CreateTriggerSkill{
  name = "jy_luojiao",
  anim_type = "offensive",
  refresh_events = {fk.BeforeCardsMove},  -- 在每次牌移动之前
  mute = true,  -- 不声明使用了这个技能

  can_refresh = function(self, event, target, player, data)  -- 使用refresh而不是trigger，是因为这个技能不需要询问玩家是否触发
    if not player:hasSkill(self) then return end  -- 如果我自己没有这个技能，那就不触发了

    -- 先清理自家变量
    player.is_luojiao_archery_attack_may_be_triggered = false
    player.is_dian_may_changing = nil

    local dians = player:getPile("xjb__aweiluo_dian")  -- dians是“点”的牌

    -- 判断是否有牌进出特殊区
    -- 为什么不用data传参数，因为这里是BeforeCardsMove，后面是AfterCardsMove，两个不是同一个事件，data不一样。用player

    -- 判断是否有牌出去
    for _, move in ipairs(data) do
      if move.from then
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerSpecial then  -- 出去的时候不需要判断，因为去的是弃牌堆
              -- 如果点是5，那么有可能可以触发万箭齐发
              if #dians == 5 then player.is_luojiao_archery_attack_may_be_triggered = true end
              return true
            end
          end
        end
      end
    end
    
    -- 判断是否有牌进来
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerSpecial and move.specialName == "xjb__aweiluo_dian" then
        -- 如果点是3，那么有可能可以触发万箭齐发
        if #dians == 3 then player.is_luojiao_archery_attack_may_be_triggered = true end
        return true
      end
    end
  end,

  on_refresh = function(self, event, target, player, data)
    -- 触发之后，设置变量，告诉下一个函数有没有可能在发生变化
    local dians = player:getPile("xjb__aweiluo_dian")
    player.is_dian_may_changing = #dians
    -- 必须使用player来储存该变量，因为后面的事件使用的是另一个函数jy_luojiao_after，如果你用self，那个函数是看不到的
  end,
}
-- 使用同一个函数来判断是否触发了南蛮和万箭
local jy_luojiao_after = fk.CreateTriggerSkill{
  name = "#jy_luojiao_after",  -- 这个技能的名字
  events = {fk.AfterCardsMove},  -- 卡牌移动之后，如果can_trigger返回真，那就可以发动这个技能

  -- can_trigger是用来判断是否能触发这个技能的，返回真就能触发，返回假就不能触发
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if not player.is_dian_may_changing then return false end  -- 如果“点”有可能在变化

    local dians = player:getPile("xjb__aweiluo_dian")
    -- 如果卡牌移动前和移动后“点”相同，那就证明是其他的特殊区的牌，直接return
    if player.is_dian_may_changing == #dians then return false end

    -- 判断是否有两张同样花色的“点”，若有返回false，若没有返回true
    if #dians == 0 then return false end  -- 设计者说1张也可以发动南蛮
    dict = {}
    local is_luojiao_suit_satisfied = true
    for _, c in ipairs(dians) do
      local suit = Fk:getCardById(c).suit
      if dict[suit] then
        -- 有相同的花色，不执行
        is_luojiao_suit_satisfied = false
        break
      else
        dict[suit] = true
      end
    end

    -- 万箭需要满足的条件：点数为4，且之前已经告诉我有可能触发
    player.is_archery_attack = 
      player.is_luojiao_archery_attack_may_be_triggered and
      #player:getPile("xjb__aweiluo_dian") == 4

    -- 南蛮需要满足的条件：花色全部不同，且本回合未使用过
    player.is_savage_assault = is_luojiao_suit_satisfied and
      player:usedSkillTimes(self.name) == 0

    -- 万箭或南蛮满足，返回真
    return player.is_archery_attack or player.is_savage_assault
  end,

  -- on_cost代表执行该技能时要做什么事情
  on_cost = function(self, event, target, player, data)
    local room = player.room
    self.first = nil  -- 如果两个条件都满足，这个变量存储谁是第一个使用的牌

    -- 如果两个条件都满足
    if player.is_archery_attack and player.is_savage_assault then
      if room:askForSkillInvoke(player, self.name, nil, "#jy_luojiao_both_ask") then  -- 都触发了，询问是否要使用罗绞
        local choices = {"archery_attack", "savage_assault"} 
        self.first = room:askForChoice(player, choices, self.name, "#jy_luojiao_ask_which")  -- 如果玩家确定使用，询问先用哪张牌
        return true
      end
    end

    -- 因为南蛮触发的比万箭多，所以把南蛮放到前面提高效率

    -- 如果南蛮的条件满足
    if player.is_savage_assault then 
      if room:askForSkillInvoke(player, self.name, nil, "#jy_luojiao_savage_assault_ask") then  -- 那么问是否要发动
        self.do_savage_assault = true
        return true
      end
    end
    
    -- 如果万箭的条件满足
    if player.is_archery_attack then
      if room:askForSkillInvoke(player, self.name, nil, "#jy_luojiao_archery_attack_ask") then  -- 那么问是否要发动
        self.do_archery_attack = true
        return true
      end
    end

    -- 如果玩家选择不触发，那擦屁股，这次“点”结算完成了
    self.do_archery_attack = false
    self.do_savage_assault = false
    self.first = nil
    player.is_dian_may_changing = false
    player.is_archery_attack = false
    player.is_savage_assault = false
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    if self.first then  -- 如果self.first这个值有，那就代表两个条件同时满足
      local cards
      local skills
      -- 这样写方便以后扩展，也可以更好地移植到别的代码里去
      if self.first == "archery_attack" then  -- 如果玩家选择先用万箭
        cards = {      "archery_attack",              "savage_assault"}
        skill_names = {"#jy_luojiao_archery_attack", "#jy_luojiao_savage_assault"}
      else
        cards = {      "savage_assault",              "archery_attack"}
        skill_names = {"#jy_luojiao_savage_assault", "#jy_luojiao_archery_attack"}
      end
      -- assert(#cards == #skill_names)
      -- 对于
      for i = 1, #cards do
        if room:askForSkillInvoke(player, skill_names[i]) then  -- 如果同意发动这个技能
          room:notifySkillInvoked(player, skill_names[i], "offensive")  -- 在武将上显示这个技能的名字
          player:broadcastSkillInvoke("jy_luojiao")  -- 播放这个技能的语音
          room:useVirtualCard(cards[i], nil, player, room:getOtherPlayers(player, true), self.name, true)
        end
      end
    else  -- 如果没有两个条件同时满足，那满足谁就执行谁
      -- 满足万箭，执行万箭
      if self.do_archery_attack then
        room:notifySkillInvoked(player, "jy_luojiao", "offensive")
        player:broadcastSkillInvoke("jy_luojiao")
        room:useVirtualCard("archery_attack", nil, player, room:getOtherPlayers(player, true), self.name, true)
      end
      -- 满足南蛮，执行南蛮
      if self.do_savage_assault then
        room:notifySkillInvoked(player, "jy_luojiao", "offensive")
        player:broadcastSkillInvoke("jy_luojiao")
        room:setPlayerMark(player, "@jy_is_luojiao_savage_assault_used", "#jy_luojiao_used")
        room:useVirtualCard("savage_assault", nil, player, room:getOtherPlayers(player, true), self.name, true)
      end
    end
    -- 一次“点”的变化结算完成，把所有变量都设为初始
    self.do_archery_attack = false
    self.do_savage_assault = false
    self.first = nil
    player.is_dian_may_changing = false
    player.is_archery_attack = false
    player.is_savage_assault = false
  end
}
local jy_luojiao_set_0 = fk.CreateTriggerSkill{
  name = "#jy_luojiao_set_0",
  mute = true,
  frequency = Skill.Compulsory,
  visible = false,
  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    -- 任何一个人回合都要发动
    return player:hasSkill(self)
      and target.phase == Player.Finish and  -- 如果是这个人的回合结束阶段
      player:getMark("@jy_is_luojiao_savage_assault_used") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_is_luojiao_savage_assault_used", 0)  -- 将罗绞南蛮发动过的标记设为0（也就是取消显示）
  end,
}
jy_luojiao:addRelatedSkill(jy_luojiao_after)
jy_luojiao:addRelatedSkill(jy_luojiao_set_0)

-- 玉玊
local jy_yusu = fk.CreateTriggerSkill{
  name = "jy_yusu",
  anim_type = "special",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if player.phase ~= Player.NotActive and data.card and 
    data.card.type == Card.TypeBasic and target == player then  -- target == player：触发者是你自己
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jy_yusu_basic_count")
    basic_count = player:getMark("@jy_yusu_basic_count")
    if basic_count == 2 then  -- 第二张基本牌
      return room:askForSkillInvoke(player, self.name)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = data.card
    player:addToPile("xjb__aweiluo_dian", id, true, self.name)
  end,
}
local jy_yusu_set_0 = fk.CreateTriggerSkill{
  name = "#jy_yusu_set_0",
  mute = true,
  frequency = Skill.Compulsory,
  visible = false,
  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@jy_yusu_basic_count", 0)
  end,
}
jy_yusu:addRelatedSkill(jy_yusu_set_0)

xjb__aweiluo:addSkill(jy_youlong)
xjb__aweiluo:addSkill(jy_hebao)
xjb__aweiluo:addSkill(jy_tiaoshui)
xjb__aweiluo:addSkill(jy_yusu)
xjb__aweiluo:addSkill(jy_luojiao)

Fk:loadTranslationTable {
  ["xjb__aweiluo"] = "阿威罗",
  ["xjb__aweiluo_dian"] = "点",

  ["jy_youlong"] = "游龙",
  ["#jy_youlong-choose"] = "游龙：选择一张牌交给下家",
  [":jy_youlong"] = "锁定技，准备阶段，有手牌的角色依次将一张手牌交给下家。",
  ["$jy_youlong1"] = "翩若惊鸿！婉若游龙！",

  ["jy_hebao"] = "核爆",
  [":jy_hebao"] = "准备阶段，可以将一张手牌置于武将牌上，称为“点”。",
  ["#jy_hebao-choose"] = "核爆：选择一张手牌成为“点”",
  ["$jy_hebao1"] = "Siu~",

  ["jy_tiaoshui"] = "跳水",
  [":jy_tiaoshui"] = "受到伤害时，可以弃置一张“点”。",
  ["#jy_tiaoshui"] = "弃置一张“点”",
  ["$jy_tiaoshui1"] = "Siu, hahahaha!",

  ["jy_luojiao"] = "罗绞",
  [":jy_luojiao"] = [[当“点”的数量变化后：<br>
  1. 若你没有两张及以上相同花色的“点”，可以视为立即使用一张【南蛮入侵】，每回合限一次；<br>
  2. 若你有4张“点”，可以视为立即使用一张【万箭齐发】。]],
  ["$jy_luojiao1"] = "Muchas gracias afición, esto es para vosotros, Siuuu!!",
  ["#jy_luojiao_after"] = "罗绞",
  ["#jy_luojiao_archery_attack"] = "罗绞·万箭",
  ["#jy_luojiao_savage_assault"] = "罗绞·南蛮",
  ["#jy_luojiao_archery_attack_ask"] = "“点”数量为4，是否发动 罗绞·万箭",
  ["#jy_luojiao_savage_assault_ask"] = "“点”花色不同，是否发动 罗绞·南蛮，每回合限一次",
  ["@jy_is_luojiao_savage_assault_used"] = "罗绞",
  ["#jy_luojiao_both_ask"] = "罗绞 两个条件同时达成，是否发动",
  ["#jy_luojiao_ask_which"] = "罗绞 两个条件同时达成并发动，请选择要先视为使用的牌",
  ["#jy_luojiao_used"] = "已南蛮",

  ["jy_yusu"] = "玉玊",
  [":jy_yusu"] = "出牌阶段，使用第二张基本牌时，可以将其作为“点”置于武将牌上。",
  ["@jy_yusu_basic_count"] = "玉玊",
  ["$jy_yusu1"] = "Siu...",

  ["~xjb__aweiluo"] = "Messi, Messi, Messi, Messi...",

}

-- 水晶哥

-- 失去技能：原创之魂2017薛综
-- 觉醒技：山包邓艾
-- 受到伤害：一将2013曹冲
-- 没有次数距离限制：星火燎原刘焉
-- 无法被响应：tenyear_huicui1 #gonghu_delay
-- 立即使用一张牌：诸葛恪，借刀

local zer__yangfan = General(extension, "zer__yangfan", "qun", 4)

-- 四吃3的选牌规则
Fk:addPoxiMethod{
  name = "jy_sichi_3",
  card_filter = function(to_select, selected)
    -- 三张同类型的牌或两张不同类型的牌

    -- 如果已选择卡牌数小于等于1，直接返回真，因为还不知道到底要选的是相同的还是不同的类型
    if #selected <= 1 then return true end

    -- 如果已选择卡牌数大于等于3，直接返回假，因为不可能再通过多选一张满足条件了
    if #selected >= 3 then return false end
    
    -- 如果已选择卡牌数为2，检查它们的类型是否相同
    if #selected == 2 then
        local type = Fk:getCardById(to_select).type
        local type1 = Fk:getCardById(selected[1]).type
        local type2 = Fk:getCardById(selected[2]).type
        -- 如果两张卡牌类型相同，那么对和它们类型相同的牌返回真，因为只能这样满足条件了
        if type1 == type2 then
            return type == type1
        -- 如果两张卡牌类型不同，那么已经满足要求了，返回假
        else
          return false
        end
    end
    -- 如果以上条件都不满足，返回真
    return true
  end,
  feasible = function(selected)
    if #selected <= 1 then return false
    elseif #selected == 2 then return Fk:getCardById(selected[1]).type ~= Fk:getCardById(selected[2]).type
    elseif #selected == 3 then return Fk:getCardById(selected[1]).type == Fk:getCardById(selected[2]).type and 
      Fk:getCardById(selected[2]).type == Fk:getCardById(selected[3]).type
    end
  end,
  prompt = function ()
    return Fk:translate("#jy_sichi_3")
  end
}
-- 四吃
local jy_sichi = fk.CreateTriggerSkill{
  name = "jy_sichi",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 亮出四张牌
    local card_ids = room:getNCards(4)

    -- 放到过程区
    room:moveCards({
      ids = card_ids,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
    })

    -- player:showCards(card_ids)  -- 这个和上面的是一个效果，区别在于这个可以在牌上显示是自己展示的

    -- 看花色有多少种，测试通过
    dict = {false, false, false, false}
    local suit_count = 0
    for _, c in ipairs(card_ids) do
      local suit = Fk:getCardById(c).suit
      if not dict[suit] then 
        dict[suit] = true
        suit_count = suit_count + 1
      end
    end

    assert(suit_count <= 4 and suit_count >= 1)
    
    -- TODO:其实主要是担心如果用..它不会翻译成中文。有空可以试一下
    local msg
    if suit_count == 1 then
      msg = "#jy_sichi_suits_1"
    elseif suit_count == 2 then
      msg = "#jy_sichi_suits_2"
    elseif suit_count == 3 then
      msg = "#jy_sichi_suits_3"
    elseif suit_count == 4 then
      msg = "#jy_sichi_suits_4"
    end
    room:doBroadcastNotify("ShowToast", Fk:translate(msg))

    -- suit_count = 2  -- 测试用的，记得删掉

    -- 一种花色：全部给一个人，测试通过
    if suit_count == 1 then
      -- 不能直接用room:getOtherPlayers(player)，因为这个函数返回的是player，而askForChoosePlayers需要的是id（integer）。
      -- 无法让这些展示的牌在结算完成之前保留在屏幕上，火攻也不行
      local targets = table.map(table.filter(room:getAlivePlayers(), function(p)
        return true end), Util.IdMapper)
      local result = room:askForChoosePlayers(player, targets, 1, 1, "#jy_sichi_1", self.name, true, false)  -- 这玩意返回的是id列表
      if #result ~= 0 then  -- 点击取消，就给自己
        room:moveCardTo(card_ids, Player.Hand, room:getPlayerById(result[1]), fk.ReasonGive, self.name, nil, false, player.id)
      else
        room:moveCardTo(card_ids, Player.Hand, player, fk.ReasonGive, self.name, nil, false, player.id)
      end

    -- 2种花色：判断是否有可以使用的牌。如果有，选择其中一张可以使用的牌，然后选择目标并使用，如果没有，弃置一张牌
    -- 因为我们只选一张，所以用addSubcard就可以了。如果你要移植这个函数到别的地方去，那就记得改单复数（
    elseif suit_count == 2 then
      -- 1. 先判断是否全都无法使用，如果全都无法使用，直接让他弃牌，把这几张牌都丢到弃牌堆去，结束这个技能
      local is_any_card_usable = false
      for _, c in ipairs(card_ids) do
        if U.canUseCard(room, player, Fk:getCardById(c), true) then is_any_card_usable = true break end
      end
      -- is_any_card_usable = false  -- 测试用的，记得改回来
      if not is_any_card_usable then
        room:doBroadcastNotify("ShowToast", Fk:translate("#jy_sichi_2_failed_toast"))
        room:askForDiscard(player, 1, 1, true, self.name, false, ".", "#jy_sichi_2_failed", false)
        room:moveCards({
          ids = card_ids,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
        })
        -- 在此处已经把垃圾丢完了，所以可以放心return
        return false
      end
      
      -- 2. 如果有可以使用的牌，用五谷丰登（神吕蒙）的方式把牌展示出来，其中不可使用的牌变灰，让他选择一张没有变灰的牌
      table.forEach(room.players, function(p)
        room:fillAG(p, card_ids)  -- 让每个人都能看到AG
      end)

      for i = 1, #card_ids do  -- 对于所有的牌
        local id = card_ids[i]
        if not U.canUseCard(room, player, Fk:getCardById(id), true) then  -- 如果这张牌无法使用
          room:takeAG(player, id)  -- 把这张牌标记为被拿了（也就是变灰）
          -- table.removeOne(card_ids, id)  -- 把这张牌从所有的牌中移除。此时不需要。
        end
      end
      local card_id = room:askForAG(player, card_ids, false, self.name)  -- 要求你拿一张
      room:takeAG(player, card_id)
      table.removeOne(card_ids, card_id)  -- 将这张牌从card_ids移除，因为最后要把所有的card_ids都弃掉
      room:closeAG()
      -- card_id 即为被选的牌

      local dummy = Fk:cloneCard("dilu")

      -- 3. 选择完毕后，放入他的手牌，并要求他为这张牌指定目标
      dummy:addSubcard(card_id)
      room:obtainCard(player.id, dummy, true, fk.ReasonPrey)

      local card = Fk:getCardById(card_id)

      local name = card.trueName
      local number
      local suit

      if card.number == 11 then
        number = "J"
      elseif card.number == 12 then
        number = "Q"
      elseif card.number == 13 then
        number = "K"
      elseif card.number == 1 then
        number = "A"
      else
        number = tostring(card.number)
      end

      if card.suit == Card.Spade then
        suit = "spade"
      elseif card.suit == Card.Heart then
        suit = "heart"
      elseif card.suit == Card.Club then
        suit = "club"
      elseif card.suit == Card.Diamond then
        suit = "diamond"
      end

      -- 牌名|点数|花色  -- 这个exppattern.lua里用例子给的写法，可以匹配到
      local pattern = name.."|"..number.."|"..suit
      -- 雷杀火杀的匹配用truename即可，反正花色和点数会限制别的牌
      local use = room:askForUseCard(player, card.name, pattern, "#jy_sichi_2_use", false)  -- 这里填false也没用，反正是可以取消的
      
      -- useCard
      if use then room:useCard(use) end

    -- 3种花色：选牌，然后所有人各摸一张
    elseif suit_count == 3 then
      local get = room:askForPoxi(player, "jy_sichi_3", {
        { self.name, card_ids },
      }, nil, true)
      if #get > 0 then
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(get)
        room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
      end
      -- 所有其他人各摸一张
      for _, p in ipairs(room:getOtherPlayers(player)) do
        p:drawCards(1, self.name)
      end

    -- 4种花色：选择至多3个角色，你和他们各失去一点体力
    elseif suit_count == 4 then
      -- 业炎
      -- 这里只能选择除了自己以外的角色，因为自己肯定是要掉血的
      local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
        return true end), Util.IdMapper)
      local result = room:askForChoosePlayers(player, targets, 0, 3, "#jy_sichi_4", self.name)  -- 这玩意返回的是id列表
      room:loseHp(player, 1, self.name)
      for _, p in ipairs(result) do
        local p_player = room:getPlayerById(p)
        if not p_player.dead then room:loseHp(p_player, 1, self.name) end
      end
    end

    -- 移动到弃牌堆，最后一起丢，前面的不用丢
    card_ids = table.filter(card_ids, function(id) return room:getCardArea(id) == Card.Processing end)
    if #card_ids > 0 then
      room:moveCards({
        ids = card_ids,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end,
}

-- ol_sp1 sheyan
-- TODO：如果别人用♣借刀杀人指定了另外两个目标，并且判定为♥指定我为目标，借自己的刀杀自己，杀出不出去，只能给刀
local jy_huapen = fk.CreateTriggerSkill{
  name = "jy_huapen",
  anim_type = "control",
  events = {fk.TargetConfirming},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.from ~= player.id and data.card and 
      data.card.suit == Card.Club and
      (data.card:isCommonTrick() or data.card.type == Card.TypeBasic) then
      local previous_targets = AimGroup:getAllTargets(data.tos)
      if #AimGroup:getAllTargets(data.tos) ~= 1 then return false end  -- 如果目标不是一个，那就不用管了
      -- 借刀杀人也被判定为单体卡牌。也许本来就是？
      -- 如果目标里面已经有我自己了，那就不要判定了
      for _, v in pairs(previous_targets) do
        if v == player.id then
          return false
        end
      end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    local previous_targets = AimGroup:getAllTargets(data.tos)

    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|heart",
    }
    room:judge(judge)
    if judge.card.suit == Card.Heart then
      room:doIndicate(data.from, {player.id})  -- 播放指示线
      if #AimGroup:getAllTargets(data.tos) == 1 then  -- 如果只有一个人，那么把我也加进去
        table.insertTable(targets, AimGroup:getAllTargets(data.tos))
      end
      TargetGroup:pushTargets(data.targetGroup, player.id)
    end
  end,
}

local jy_boshi = fk.CreateTriggerSkill{
  name = "jy_boshi",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("@jy_boshi_judge_count") >= 10
    -- 10才是正确的数值
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name,
    })
    player:drawCards(3, self.name)

    room:setPlayerMark(player, "@jy_boshi_judge_count", 0)  -- 清空标记

    room:handleAddLoseSkills(player, "-jy_huapen")

    room:handleAddLoseSkills(player, "jy_jiangbei")
  end,
}
local jy_boshi_count = fk.CreateTriggerSkill{
  name = "#jy_boshi_count",
  mute = true,
  refresh_events = {fk.AskForRetrial},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and 
      player:usedSkillTimes("jy_boshi", Player.HistoryGame) == 0  -- 如果觉醒技未发动过，可以更新数值（发动过了就不更新了）
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jy_boshi_judge_count")
  end,
}
jy_boshi:addRelatedSkill(jy_boshi_count)

-- 测试通过
-- 主函数啥也不做，只是为了承载下面的
local jy_jiangbei = fk.CreateTriggerSkill{
  name = "jy_jiangbei",
}
-- ♥无法被响应
local jy_jiangbei_heart = fk.CreateTriggerSkill{
  name = "#jy_jiangbei_heart",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if target == player and data.card.suit == Card.Heart then
      return data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(jy_jiangbei.name)
    data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
  end,
}
-- ♣没有距离次数限制
local jy_jiangbei_club = fk.CreateTargetModSkill{
  name = "#jy_jiangbei_club",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and card.suit == Card.Club and to
  end,
  bypass_distances =  function(self, player, skill, card, to)
    return player:hasSkill(self) and card.suit == Card.Club and to
  end,
}
-- ♣无视防具
local jy_jiangbei_club_2 = fk.CreateTriggerSkill{
  name = "#jy_jiangbei_club_2",
  frequency = Skill.Compulsory,
  events = { fk.TargetSpecified },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if target == player and data.card and data.card.suit == Card.Club then
      return data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    if use_event == nil then return end
    room:addPlayerMark(to, fk.MarkArmorNullified)
    use_event:addCleaner(function()
      room:removePlayerMark(to, fk.MarkArmorNullified)
    end)
  end,
}
-- 出牌阶段开始时把已使用打出的红桃梅花数设置成0
local jy_jiangbei_set_0 = fk.CreateTriggerSkill{
  name = "#jy_jiangbei_set_0",
  mute = true,
  frequency = Skill.Compulsory,
  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and
      player.phase == Player.Play -- 在我的出牌阶段
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_jiangbei_draw", 0)
  end,
}
-- 计算出牌阶段使用打出了多少张红桃梅花。一旦使用打出了别的牌，就变为字符串。
-- TargetSpecified对每个目标都会执行一次，所以改成CardUsing。前面的虎啸也一并改了已经。
local jy_jiangbei_draw_count = fk.CreateTriggerSkill{
  name = "#jy_jiangbei_draw_count",
  mute = true,
  frequency = Skill.Compulsory,
  refresh_events = {fk.CardResponding, fk.CardUsing},  -- 包括了使用和打出
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card and player.phase == Player.Play then
      return target == player
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    -- 如果是红桃和梅花
    if (data.card.suit == Card.Club or data.card.suit == Card.Heart) and
      type(player:getMark("@jy_jiangbei_draw")) == "number" then  -- 并且没有使用打出过别的花色
      room:addPlayerMark(player, "@jy_jiangbei_draw")
    else
      room:setPlayerMark(player, "@jy_jiangbei_draw", "#jy_jiangbei_no")  -- 如果设置成字符串了，代表不允许摸牌了
    end
  end,
}
-- 出牌阶段结束时摸等量的牌
local jy_jiangbei_draw = fk.CreateTriggerSkill{
  name = "#jy_jiangbei_draw",
  anim_type = "special",
  events = {fk.EventPhaseEnd},  -- 包括了使用和打出
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
      and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if type(player:getMark("@jy_jiangbei_draw")) == "number" then -- 只有是数字的时候，代表可以摸牌
      player:drawCards(player:getMark("@jy_jiangbei_draw"), self.name)
    end
    room:setPlayerMark(player, "@jy_jiangbei_draw", 0)  -- 无论能不能摸牌，都要清理掉这个标记
  end,
}
jy_jiangbei:addRelatedSkill(jy_jiangbei_heart)
jy_jiangbei:addRelatedSkill(jy_jiangbei_club)
jy_jiangbei:addRelatedSkill(jy_jiangbei_club_2)
jy_jiangbei:addRelatedSkill(jy_jiangbei_set_0)
jy_jiangbei:addRelatedSkill(jy_jiangbei_draw_count)
jy_jiangbei:addRelatedSkill(jy_jiangbei_draw)

zer__yangfan:addSkill(jy_sichi)
zer__yangfan:addSkill(jy_huapen)
zer__yangfan:addSkill(jy_boshi)
zer__yangfan:addRelatedSkill(jy_jiangbei)

Fk:loadTranslationTable {
  ["zer__yangfan"] = "杨藩",

  ["jy_sichi"] = "四吃",
  [":jy_sichi"] = [[受到伤害后，你可以展示牌堆顶的4张牌，根据花色数量触发效果。<br>
  1种：选择一名角色获得这些牌；<br>
  2种：获得其中一张可以使用的牌并可以立即使用。若所有的牌都无法使用，弃一张牌；<br>
  3种：获得其中3张同类型的牌或2张不同类型的牌，然后除你以外的其他角色各摸一张牌；<br>
  4种：选择至多3名角色，你与其各失去一点体力。]],

  ["#jy_sichi_suits_1"] = "四吃：1种花色，选择一个角色获得这些牌",
  ["#jy_sichi_suits_2"] = "四吃：2种花色，获得一张可使用的牌并可以立即使用，若没有则弃牌",
  ["#jy_sichi_suits_3"] = "四吃：3种花色，获得其中一部分牌，然后其他角色各摸一张牌",
  ["#jy_sichi_suits_4"] = "四吃：4种花色，选择角色和自己一起失去体力",

  ["#jy_sichi_1"] = "四吃：选择一个角色获得所有牌，点击取消选择自己",
  ["#jy_sichi_2"] = "四吃：选择其中一张牌并使用",
  ["#jy_sichi_2_use"] = "四吃：你可以立即使用这张牌",
  ["#jy_sichi_2_failed_toast"] = "四吃：2种花色，但没有任何可以使用的牌，所以需要弃一张牌",
  ["#jy_sichi_2_failed"] = "四吃：没有可使用的牌，你需要弃一张牌",
  ["jy_sichi_3"] = "四吃",
  ["#jy_sichi_3"] = "四吃：选择其中3张同类型的牌或2张不同类型的牌获得，然后除你以外的角色各摸一张牌",
  ["#jy_sichi_4"] = "四吃：选择至多3名角色，你和他们各失去一点体力",

  ["jy_huapen"] = "花盆",
  [":jy_huapen"] = [[锁定技，其他角色使用♣非延时锦囊牌或基本牌指定了有且仅有一个不为你的目标时，
  你进行一次判定，若为<font color="red">♥</font>，额外指定你为目标。（含【借刀杀人】）]],

  ["jy_boshi"] = "搏十",
  [":jy_boshi"] = [[觉醒技，准备阶段，若你已判定过至少10次，你增加一点体力上限、回复一点体力、
  摸3张牌、失去技能【花盆】，然后获得技能【奖杯】。]],
  ["@jy_boshi_judge_count"] = "搏十",

  ["jy_jiangbei"] = "奖杯",
  [":jy_jiangbei"] = [[锁定技，你使用的花色为♣的基本牌和锦囊牌无视距离和防具、没有次数限制；
  你使用的花色为<font color="red">♥</font>的基本牌和锦囊牌不可被响应；
  出牌阶段结束时，若你出牌阶段只使用或打出过♣和<font color="red">♥</font>牌，摸等量的牌。]],
  ["#jy_jiangbei_heart"] = "奖杯",
  ["#jy_jiangbei_club"] = "奖杯",
  ["#jy_jiangbei_club_2"] = "奖杯",
  ["@jy_jiangbei_draw"] = "奖杯",
  ["#jy_jiangbei_no"] = "不可摸牌",
  -- TODO：改一下这里，按照sp公孙瓒义从改，只提示触发了义从。
}

local tym__kgdxs = General(extension, "tym__kgdxs", "qun", 4)

-- 获得一张牌：谋徐盛cheat
-- 还可以继续发动：甄姬洛神
-- 出牌阶段主动：界简自豪开局
-- 选择：界李元浩二段
-- 使命技：不知道，到时候再说

local jy_zuoti = fk.CreateActiveSkill{
  name = "jy_zuoti",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    -- 随机从题库拿一道题
    local questionFull = Q.getRandomQuestion()

    local question = questionFull[1]
    local answers = questionFull[2]
    local correct_answer = questionFull[3]

    ------------------------------------------
    -- 插入换行符，每若干个字符一次
    local function insert_br(str, ct)
      local result = ""
      local count = 0
      local in_br = false -- 用于检测是否在原本的 <br> 之内
    
      -- TODO：如果这是最后一个字符，那么不要添加br了
      for char in str:gmatch("[%z\1-\127\194-\244_][\128-\191]*") do
        if char == "<" then
          in_br = true
        elseif char == ">" and in_br then
          in_br = false
          count = 0
        end
    
        if not in_br then
          result = result .. char
          count = count + 1
    
          -- 每ct个字符插入一个<br>
          if count == ct then
            result = result .. "<br>"
            count = 0
          end
        else
          result = result .. char
        end
      end
    
      return result
    end

    local question_wrap = insert_br(question, 40)
    local answers_wrap = {}
    for _, a in ipairs(answers) do
      table.insert(answers_wrap, insert_br(a, 30))
    end 
    -----------------------------------------------

    -- 建立输出到战报里的所有选项
    local answers_string = ""
    for i, a in ipairs(answers) do
      if i ~= #answers then
        answers_string = answers_string .. a .. "<br>"
      else answers_string = answers_string .. a
      end
    end

    -- 做题
    -- 不仅要让自己看到题目，还要让全场所有人看到题目。
    room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_ob"))
    room:sendLog{
      type = "%from 的题目：<br>%arg<br>%arg2",
      from = player.id,
      arg = question,
      arg2 = answers_string,
    }
    
    local answers_short = {}
    for _, a in ipairs(answers) do
      table.insert(answers_short, a[1])
    end

    local choice = room:askForChoice(player, answers_wrap, self.name, question_wrap)
    if choice[1] == correct_answer then  -- 仅判断choice[1]，因为答案只保留正确选项的选项名字（ABCD）
      room:addPlayerMark(player, "@jy_zuoti_correct_count")
      room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_correct"))
      room:sendLog{
        type = "#jy_zuoti_correct_log",
        from = player.id,
        arg = correct_answer[1],
      }
      
      -- cheat，从谋徐盛抄来的，应该不会有什么问题
      local from = room:getPlayerById(effect.from)
      local cardType = { 'basic', 'trick', 'equip' }
      local cardTypeName = room:askForChoice(from, cardType, self.name)
      local card_types = {Card.TypeBasic, Card.TypeTrick, Card.TypeEquip}
      cardType = card_types[table.indexOf(cardType, cardTypeName)]

      local allCardIds = Fk:getAllCardIds()
      local allCardMapper = {}
      local allCardNames = {}
      for _, id in ipairs(allCardIds) do
        local card = Fk:getCardById(id)
        if card.type == cardType then
          if allCardMapper[card.name] == nil then
            table.insert(allCardNames, card.name)
          end

          allCardMapper[card.name] = allCardMapper[card.name] or {}
          table.insert(allCardMapper[card.name], id)
        end
      end

      if #allCardNames == 0 then
        return
      end

      local cardName = room:askForChoice(from, allCardNames, self.name)
      local toGain -- = room:printCard(cardName, Card.Heart, 1)
      if #allCardMapper[cardName] > 0 then
        toGain = allCardMapper[cardName][math.random(1, #allCardMapper[cardName])]
      end

      -- from:addToPile(self.name, toGain, true, self.name)
      -- room:setCardMark(Fk:getCardById(toGain), "@@test_cheat-phase", 1)
      -- room:setCardMark(Fk:getCardById(toGain), "@@test_cheat-inhand", 1)
      room:obtainCard(effect.from, toGain, true, fk.ReasonPrey)
    else
      room:addPlayerMark(player, "@jy_zuoti_incorrect_count")
      room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_incorrect"))
      room:sendLog{
        type = "#jy_zuoti_incorrect_log",
        from = player.id,
        arg = choice[1],
        arg2 = correct_answer,
      }
    end
  end,
}

-- touhou_standard extremely_wicked
local jy_jieju = fk.CreateActiveSkill {
  name = "jy_jieju",
  frequency = Skill.Quest,
  anim_type = "positive",
  can_use = function(self, player)
    return player:usedSkillTimes("jy_zuoti", Player.HistoryPhase) ~= 0 and 
      -- player:usedSkillTimes(self.name, Player.HistoryPhase) <= 1 and 
      not player:getQuestSkillState("jy_jieju")
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:loseHp(from, 1, self.name)  -- 从弃牌改为失去体力
    -- room:throwCard(effect.cards, self.name, from, from)
    from:setSkillUseHistory("jy_zuoti", 0, Player.HistoryPhase)
  end,
}
local jy_jieju_success = fk.CreateTriggerSkill {
  name = "#jy_jieju_success",
  anim_type = "positive",
  events = {
      fk.EventPhaseStart,
  },
  can_trigger = function(self, event, target, player)
      if player:getQuestSkillState("jy_jieju") then
          return false
      end
      return player:hasSkill("jy_jieju") and player.phase == Player.Finish and 
        player:getMark("@jy_zuoti_correct_count") >= player:getMark("@jy_zuoti_incorrect_count") + 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    -- room:notifySkillInvoked(player, "jy_jieju")
    room:updateQuestSkillState(player, "jy_jieju")
    -- room:changeMaxHp(player, 1)
    player:drawCards(3)
    player.room:handleAddLoseSkills(player, "jizhi", nil, true, false)
    player.room:handleAddLoseSkills(player, "kanpo", nil, true, false)
    player.room:handleAddLoseSkills(player, "xiangle", nil, true, false)
  end
}
local jy_jieju_fail = fk.CreateTriggerSkill {
  name = "#jy_jieju_fail",
  anim_type = "negative",
  events = {
      fk.EventPhaseStart,
  },
  can_trigger = function(self, event, target, player)
      if player:getQuestSkillState("jy_jieju") then
          return false
      end
      return player:hasSkill("jy_jieju") and player.phase == Player.Finish and 
        player:getMark("@jy_zuoti_incorrect_count") >= player:getMark("@jy_zuoti_correct_count") + 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    room:updateQuestSkillState(player, "jy_jieju", true)
    room:changeMaxHp(player, -1)
    player:turnOver()
    room:handleAddLoseSkills(player, "jy_yuyu", nil, true, false)
    room:handleAddLoseSkills(player, "jy_hongwen", nil, true, false)
  end
}
jy_jieju:addRelatedSkill(jy_jieju_success)
jy_jieju:addRelatedSkill(jy_jieju_fail)

tym__kgdxs:addSkill(jy_zuoti)
tym__kgdxs:addSkill(jy_jieju)
tym__kgdxs:addRelatedSkill("jizhi")
tym__kgdxs:addRelatedSkill("kanpo")
tym__kgdxs:addRelatedSkill("xiangle")
tym__kgdxs:addRelatedSkill("jy_yuyu")
tym__kgdxs:addRelatedSkill("jy_hongwen")

local total_papers, total_questions = Q.questionCount()

Fk:loadTranslationTable {
  ["tym__kgdxs"] = "考公大学生",

  ["jy_zuoti"] = "做题",
  [":jy_zuoti"] = [[出牌阶段限一次，你做一道行测真题。若正确，你可以获得一张想要的牌。<br>
  <font size="1">推荐操作时长：60秒；自备纸笔以应对数学题。<br>
  当前收录试卷：]]..total_papers..[[套，题目总量：]]..total_questions..[[（含相同），经人工筛选，不含图形推理、资料分析，全部取自2018-2023国家公务员录用考试《行测》真题。<br>
  你选择的这张牌可能来自于任何位置，包括其他角色的区域、你自己的手牌。所以建议先把同牌名的牌使用掉。</font>]],
  ["#jy_zuoti_see_log"] = [[做题：请在战报中查看完整题干]],
  ["#jy_zuoti_ob"] = [[正在做题！请在战报中查看这道题目的完整题干和选项。]],
  ["#jy_zuoti_correct"] = [[答对了！可以从场上随机位置获取一张想要的牌！<br>你可以在战报中查看正确答案。]],
  ["#jy_zuoti_incorrect"] = [[答错了！不过没有什么惩罚，你学习到了新知识！<br>你可以在战报中查看正确答案。]],
  ["@jy_zuoti_correct_count"] = "答对",
  ["#jy_zuoti_correct_log"] = "%from 回答正确，正确答案：%arg。",
  ["@jy_zuoti_incorrect_count"] = "答错",
  ["#jy_zuoti_incorrect_log"] = "%from 选择了：%arg，正确答案：%arg2。",

  ["jy_jieju"] = "熬夜",
  [":jy_jieju"] = [[使命技，出牌阶段，你失去一点体力使【做题】视为未发动过。<br>
  成功：回合结束时，若你【做题】答对比答错至少多3，你摸3张牌，然后获得技能【集智】、【看破】、【享乐】；<br>
  失败：回合结束时，若你【做题】答错比答对至少多3，你翻面、减一点体力上限，然后获得技能【玉玉】、【红温】。]],
  ["#jy_jieju_success"] = "结局：成功",
  ["#jy_jieju_fail"] = "结局：失败",

}

-- 参考：廖化，英姿，蛊惑，血裔
local skl__mou__gaotianliang = General(extension, "skl__mou__gaotianliang", "qun", 4)


local jy_tianling = fk.CreateViewAsSkill{
  name = "jy_tianling",
  anim_type = "special",
  pattern = ".",
  interaction = function()
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and card.trueName ~= "ex_nihilo" and card.trueName ~= "snatch"
      and not card.is_derived and
      ((Fk.currentResponsePattern == nil and Self:canUse(card)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        table.insertIfNeed(names, card.name)
      end
    end
    if #names == 0 then return false end
    return UI.ComboBox { choices = names }
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    self.cost_data = cards
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local cards = self.cost_data
    local card_id = cards[1]
    use.card:addSubcard(card_id)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@jy_tianling") ~= 0 and not player:isKongcheng() and player.phase ~= Player.NotActive
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@jy_tianling") ~= 0 and player.phase ~= Player.NotActive and not response and not player:isKongcheng()
  end,
  -- TODO:自己的回合濒死的时候也会亮，但实际上没用
}
local jy_tianling_yuyu = fk.CreateTriggerSkill{
  name = "#jy_tianling_yuyu",
  anim_type = "masochism",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player == target and player.phase == Player.Discard
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"#jy_tianling_1hp", "#jy_tianling_2cards"}
    local choice

    -- 检测他是否没有两张牌可以弃了，如果是，就黑掉弃两张牌那个按钮
    if #player:getCardIds{Player.Hand, Player.Equip} < 2 then
      choice = room:askForChoice(player, {"#jy_tianling_1hp"}, self.name, nil, nil, choices)
    -- 如果可以做选择，就让他做选择
    else
      choice = room:askForChoice(player, choices, self.name)
    end

    if choice == "#jy_tianling_1hp" then
      room:loseHp(player, 1, self.name)
    else
      room:askForDiscard(player, 2, 2, true, self.name, false)
    end
    room:setPlayerMark(player, "@jy_tianling", "")
  end,
}
local jy_tianling_dangxian = fk.CreateTriggerSkill{
  name = "#jy_tianling_dangxian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and 
      data.to == Player.Start and player:getMark("@jy_tianling") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, true)
  end,
}
local jy_tianling_set_0 = fk.CreateTriggerSkill{
  name = "#jy_tianling_set_0",
  mute = true,
  frequency = Skill.Compulsory,
  visible = false,
  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and
      target.phase == Player.Judge and
      player:getMark("@jy_tianling") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_tianling", 0)
  end,
}
jy_tianling:addRelatedSkill(jy_tianling_yuyu)
jy_tianling:addRelatedSkill(jy_tianling_dangxian)
jy_tianling:addRelatedSkill(jy_tianling_set_0)

local jy_yali = fk.CreateTriggerSkill{
  name = "jy_yali",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n + math.max(player.hp - #player:getCardIds(Player.Hand), 0)
  end,
}
local jy_yali_maxcards = fk.CreateMaxCardsSkill{
  name = "#jy_yali_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(self) then
      return player.maxHp
    end
  end,
}
jy_yali:addRelatedSkill(jy_yali_maxcards)

skl__mou__gaotianliang:addSkill(jy_tianling)
skl__mou__gaotianliang:addSkill(jy_yali)

Fk:loadTranslationTable {
  ["skl__mou__gaotianliang"] = "谋高天亮",

  ["jy_tianling"] = "天灵",
  [":jy_tianling"] = [[弃牌阶段开始时，你可以弃置两张牌或失去一点体力。若如此做，你的下一个回合：准备阶段后执行一个额外的出牌阶段；判定阶段结束前，你的手牌可当作除【无中生有】和【顺手牵羊】外的所有锦囊牌使用。]],
  ["@jy_tianling"] = "天灵",
  ["#jy_tianling_1hp"] = "失去一点体力",
  ["#jy_tianling_2cards"] = "弃置2张牌",
  ["#jy_tianling_dangxian"] = "天灵",
  ["#jy_tianling_yuyu"] = "天灵",

  ["jy_yali"] = "压力",
  [":jy_yali"] = [[锁定技，你的手牌上限等于你的体力上限；你的摸牌阶段额外摸X-Y张牌且至少为0，X为你的体力值，Y为你的手牌数。]],

}

local tym__raiden = General(extension, "tym__raiden", "god", 4, 4, General.Female)

local jy_leiyan = fk.CreateActiveSkill{
  name = "jy_leiyan",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return Fk:currentRoom():getPlayerById(to_select):getMark("@jy_raiden_leiyan") == 0 and #selected < 1
  end,
  target_num = 1,
  on_use = function(self, room, use)
    local to = room:getPlayerById(use.tos[1])
    room:setPlayerMark(to, "@jy_raiden_leiyan", "")
  end,
}
local jy_leiyan_trigger = fk.CreateTriggerSkill{
  name = "#jy_leiyan_trigger",
  mute = true,
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if not data.from then return false end  -- 如果这次伤害没有伤害来源，就不用看了
    local from = data.from
    return from:getMark("@jy_raiden_leiyan") ~= 0 and player:hasSkill(self)
      -- and not data.is_leiyan  -- 现在已经解除了这个限制，雷眼可以再次触发雷眼
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local to = data.to
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club",
    }
    room:judge(judge)

    if judge.card.suit == Card.Spade then
      local marks = player:getMark("@jy_raiden_yuanli")
      room:doIndicate(from.id, {player.id})  -- 播放指示线，意思是“令我获得了一点愿力”
      player:broadcastSkillInvoke("jy_leiyan")
      room:addPlayerMark(player, "@jy_raiden_yuanli")

    elseif judge.card.suit == Card.Club then
      if not target.dead then
        player:broadcastSkillInvoke("jy_leiyan")
        room:doIndicate(player.id, {to.id})  -- 播放指示线
        -- room:delay(400)
        room:damage({
          from = player,
          to = to,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = "jy_leiyan",
          -- is_leiyan = true,
        })
      end
    end
  end,
}
jy_leiyan:addRelatedSkill(jy_leiyan_trigger)

local jy_zhenshuo = fk.CreateActiveSkill{
  name = "jy_zhenshuo",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and 
      player:getMark("@jy_raiden_yuanli") ~= 0
  end,
  card_filter = function(self, to_select, selected, selected_targets)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return to_select ~= Self.id
  end,
  target_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    local to = room:getPlayerById(use.tos[1])
    local dmg = player:getMark("@jy_raiden_yuanli")
    room:setPlayerMark(player, "@jy_raiden_yuanli", 0)

    room:throwCard(use.cards, self.name, player, player)

    -- TODO:参考mobile_effect，写一个超牛逼的动画
    -- room:doSuperLightBox("packages/jianyu/qml/FirstBlood.qml")
    room:delay(1145 + 141 * dmg)

      room:damage({
        from = player,
        to = to,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = "jy_leiyan",
      })

    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@jy_raiden_leiyan") ~= 0 then
        p:drawCards(dmg * 3)
      end
    end

  end,
}

local jy_yuanshen = fk.CreateTriggerSkill{
  mute = true,
  name = "jy_yuanshen",
  frequency = Skill.Compulsory,
  anim_type = "offensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return (data.damageType == fk.FireDamage or data.damageType == fk.ThunderDamage) and
      not data.is_jy_yuanshen_triggered
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.damageType then
      -- 使用for循环以方便后面添加元素反应类型。每次只会有一种反应发生。
      -- element[1]是A属性类型，element[2]是A对应的附着标记，
      -- element[3]是A要反应的附着标记B，element[4]是要造成的效果
      -- element[5]是这个反应需要造成的广播提示
      -- Lua 的数组从1开始
      for _, element in ipairs({ 
        {fk.FireDamage, "@jy_yuanshen_pyro", "@jy_yuanshen_electro", 
          function(self, event, target, player, data) data.damage = data.damage + 1 end,
          "#jy_yuanshen_reaction_1",
        },
        {fk.ThunderDamage, "@jy_yuanshen_electro", "@jy_yuanshen_pyro", 
          function(self, event, target, player, data) 
            data.to:turnOver()  -- 受到伤害的人翻面
          end,
          "#jy_yuanshen_reaction_2",
        }, 
      }) do
        if data.damageType == element[1] then  -- 如果是A属性伤害
          if data.to:getMark(element[3]) ~= 0 then  -- 如果目标有B附着
            room:setPlayerMark(data.to, element[3], 0)  -- 将B附着解除
            player:broadcastSkillInvoke("jy_yuanshen")
            room:doBroadcastNotify("ShowToast", Fk:translate(element[5]))  -- 广播发生了元素反应。先广播再造成效果！
            room:sendLog{
              type = element[5],
              from = data.to.id,
            }
            element[4](self, event, target, player, data)  -- 造成效果
            data.is_jy_yuanshen_triggered = true  -- 如果有多个拥有这个技能的人，告诉他不用再发动了
            return  -- 结束了，不用判断下面的了
          end
          if data.to:getMark(element[2]) == 0 then   -- 如果目标没有A附着
            room:setPlayerMark(data.to, element[2], "")  -- 造成A附着
            data.is_jy_yuanshen_triggered = true  -- 如果有多个拥有这个技能的人，告诉他不用再发动了
            return
          end
        end
      end
    end
  end,
}

tym__raiden:addSkill(jy_leiyan)
tym__raiden:addSkill(jy_zhenshuo)
tym__raiden:addSkill(jy_yuanshen)  -- 赋给了雷电将军，别的用引号

Fk:loadTranslationTable {
  ["tym__raiden"] = "雷电将军",
  ["~tym__raiden"] = "浮世一梦……",

  ["jy_leiyan"] = "雷眼",
  [":jy_leiyan"] = [[出牌阶段限一次，你令一名角色获得<font color="Fuchsia">雷罚恶曜之眼</font>标记。持有<font color="Fuchsia">雷罚恶曜之眼</font>标记的角色造成伤害后，你进行一次判定，若为：♠，你获得1枚<font color="Fuchsia">愿力</font>标记；♣，你对伤害目标造成1点雷电伤害。]],
  ["@jy_raiden_leiyan"] = [[<font color="Fuchsia">雷罚恶曜之眼</font>]],
  ["@jy_raiden_yuanli"] = [[<font color="Fuchsia">愿力</font>]],
  ["#jy_leiyan_trigger"] = "雷眼",
  ["$jy_leiyan1"] = "泡影看破！",
  ["$jy_leiyan2"] = "无处遁逃！",
  ["$jy_leiyan3"] = "威光无赦！",
  ["#jy_yuanli_full"] = [[<font color="Fuchsia">愿力</font>已满！]],

  ["jy_zhenshuo"] = "真说",
  [":jy_zhenshuo"] = [[出牌阶段限一次，你弃所有<font color="Fuchsia">愿力</font>标记来对一名其他角色造成1点雷电伤害，然后所有持有<font color="Fuchsia">雷罚恶曜之眼</font>标记的角色摸3X张牌，X等同于所弃<font color="Fuchsia">愿力</font>标记数。]],
  ["$jy_zhenshuo1"] = "此刻，寂灭之时！",
  ["$jy_zhenshuo2"] = "稻光，亦是永恒！",
  ["$jy_zhenshuo3"] = "无念，断绝！",

  ["jy_yuanshen"] = "原神",
  [":jy_yuanshen"] = [[锁定技，当有角色受到<font color="red">火焰</font>或<font color="Fuchsia">雷电</font>伤害时，若其没有属性标记，其获得对应属性标记；若其拥有属性标记且与伤害属性不同，则移除标记并按照以下规则触发效果：<br>
  <font color="Fuchsia">雷电伤害</font>与<font color="red">【火焰】</font>发生反应，令其翻面；<br>
  <font color="red">火焰伤害</font>与<font color="Fuchsia">【雷电】</font>发生反应，伤害+1。<br>
  该技能对每次伤害只会触发一次，不论场上是否有多个角色拥有该技能。]],
  ["#jy_yuanshen_reaction_1"] = [[<font color="red">火焰伤害</font>与<font color="Fuchsia">【雷电】</font>发生反应，伤害+1]],
  ["#jy_yuanshen_reaction_2"] = [[<font color="Fuchsia">雷电伤害</font>与<font color="red">【火焰】</font>发生反应，翻面]],

  ["@jy_yuanshen_pyro"] = [[<font color="red">火焰</font>]],
  ["@jy_yuanshen_electro"] = [[<font color="Fuchsia">雷电</font>]],
  ["$jy_yuanshen1"] = "（音乐）",
}

local tym__ayato = General(extension, "tym__ayato", "qun", 4)

local jy_jinghua = fk.CreateTriggerSkill{
  frequency = Skill.Compulsory,
  name = "jy_jinghua",
  anim_type = "offensive",
  events = {fk.CardResponding, fk.CardUseFinished},
  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self)
      and target.phase == Player.Finish and  -- 如果是这个人的回合结束阶段
      player:getMark("@jy_jinghua") ~= 0
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card and data.card.type == Card.TypeBasic and target == player and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 添加一个标记
    -- room:setPlayerMark(player, "@jy_jinghua", "")

    -- 询问是否要使用一张杀
    local extraData = {bypass_times = true}
    local use = room:askForUseCard(player, "slash", "slash|.|.", "#jy_jinghua_use", true, extraData)  -- 这里填false也没用，反正是可以取消的

    -- useCard
    if use then
      use.extraUse = true  -- 加上这个，就可以让它不计入次数了
      room:useCard(use)
    end

    -- 其他的交给别的函数
  end,
  on_refresh = function(self, event, target, player, data)
    -- local room = player.room
    -- room:setPlayerMark(player, "@jy_jinghua", 0)
  end,
}

-- 测试通过，没什么问题
local jy_jianying = fk.CreateTriggerSkill{
  frequency = Skill.Compulsory,
  name = "jy_jianying",
  anim_type = "defensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    -- 任何一个人回合都要发动
    return player:hasSkill(self)
      and target.phase == Player.Finish and  -- 如果是这个人的回合结束阶段
      #player:getCardIds(Player.Hand) < 2
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1)
  end,
}

tym__ayato:addSkill(jy_jinghua)
tym__ayato:addSkill(jy_jianying)

Fk:loadTranslationTable {
  ["tym__ayato"] = "神里绫人",
  ["~tym__ayato"] = "世事无常……",

  ["jy_jinghua"] = "镜花",
  [":jy_jinghua"] = [[每回合限一次，使用或打出基本牌后，你可以使用一张不计入使用次数的【杀】。]],
  ["@jy_jinghua"] = "镜花",
  ["$jy_jinghua1"] = "苍流水影！",
  ["$jy_jinghua2"] = "剑影！",
  ["#jy_jinghua_use"] = "镜花：你可以立即使用一张【杀】",

  ["jy_jianying"] = "渐盈",
  [":jy_jianying"] = [[锁定技，每个角色的结束阶段，若你的手牌数小于2，你摸一张牌。]],
  ["$jy_jianying1"] = "冒进是大忌。",
  ["$jy_jianying2"] = "呵……余兴节目。",
}

-- for k, v in pairs(Fk.translations["zh_CN"]) do
--   v = string.gsub(v, "原神技", "<font color=\"skyblue\">原神技</font>")
--   Fk.translations["zh_CN"][k] = v
-- end

return extension
