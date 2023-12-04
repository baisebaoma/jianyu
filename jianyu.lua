local extension = Package:new("jy_jianyu")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
     ["jy_jianyu"] = "<font color=\"red\"><strong>监狱包</strong></font>",
     ["god"] = "神话再临·神",
     ["xjb"] = "熊",
     ["tym"] = "唐",
     ["skl"] = "尚",
}


-- 第一代简自豪 设计：熊俊博 实现：反赌专家
local xjb__jianzihao = General(extension, "xjb__jianzihao", "qun", 3, 3, General.Male)

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
      -- 请使用#from:getCardIds(Player.Equip)来代表长度，
      -- 如果你只用from:getCardIds(Player.Equip)的话是代表这个数组
      return -1
    end
    -- 没装备时视为+1
    if to:hasSkill(self) and #to:getCardIds(Player.Equip) == 0 then
      return 1
    end
    return 0
  end,
}
-- 参考自孙尚香
local jy_zouwei_audio = fk.CreateTriggerSkill{
  name = "#jy_zouwei_audio",

  refresh_events = {fk.AfterCardsMove},
  -- 这个函数只有在装备区牌量变动时才检测
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip or info.toArea == Card.PlayerEquip then
            -- 当装备等于0或1的时候触发
            -- standard_cards/init.lua, line 1080: local handcards = player:getCardIds(Player.Hand)，我也不知道为啥用的是Player.Hand而不是player.hand，写就对了
            if #player:getCardIds(Player.Equip) <= 1 then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    -- 有装备时，-1马
    if #player:getCardIds(player.Equip) ~= 0 then
      room:notifySkillInvoked(player, "jy_zouwei", "offensive")
      player:broadcastSkillInvoke("jy_zouwei", 1)
    -- 无装备时，+1马
    elseif #player:getCardIds(player.Equip) == 0 then
      room:notifySkillInvoked(player, "jy_zouwei", "defensive")
      player:broadcastSkillInvoke("jy_zouwei", 2)
    end
  end,
}
jy_zouwei:addRelatedSkill(jy_zouwei_audio)

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


-- 转会
local jy_zhuanhui = fk.CreateTriggerSkill{
  name = "jy_zhuanhui",  -- jy_kaiju$是主公技
  frequency = Skill.Compulsory,
  events = {},  -- 这是故意的，因为本来这个技能就没有实际效果
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
    -- 将体力回复至1点
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
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() then
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
-- xjb__jianzihao:addSkill(jy_zhuanhui)

Fk:loadTranslationTable{
  ["xjb__jianzihao"] = "简自豪",

  ["jy_zhuanhui"] = "转会",
  [":jy_zhuanhui"] = [[锁定技，这个技能是为了告诉你下面这些提示。<br>
  <font size="1"><strong>这个武将由熊俊博于2023年12月1日设计！</strong><br>
  经过12月2日群友们的测试，感觉更多是一个娱乐武将。如果你一定要玩，请参考下面的：
  <strong>玩法提示</strong><br>
  活过第一轮！<br>
  如果有防具，你就能安全、强大地偷牌。<br>
  你很脆，你也不强，但你可以恶心场上所有的人。<br>
  <strong>队友提示</strong><br>
  优先将防具、【闪】、【桃】、【酒】交给他。<br>
  <strong>敌方提示</strong><br>
  使用能增强【杀】的技能和武器，如【无双】、【青釭剑】。<br>
  优先拆除防具。<br>
  谨慎对待摸到的【诸葛连弩】。<br></font>

  ]],
  -- [":jy_zhuanhui"] = "<del>当你的体力值减少时，你可以变更势力。你无法变更为已经成为过的势力。</del>",

  ["jy_kaiju"] = "开局",
  [":jy_kaiju"] = [[锁定技，当你的回合开始时，所有其他有牌的武将需要交给你一张牌，并视为对你使用一张【杀】。<br>
  <font size="2"><i>“从未如此美妙的开局！”——简自豪</i></font>]],
  ["$jy_kaiju1"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju2"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju3"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju4"] = "好亏呀，我每一波都。",
  ["$jy_kaiju5"] = "被秀了，操。",
  ["#jy_kaiju-choose"] = "交给简自豪一张牌，视为对他使用【杀】",

  ["jy_hongwen"] = "红温",
  [":jy_hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$jy_hongwen1"] = "唉，不该出水银的。",
  ["$jy_hongwen2"] = "哎，兄弟我为什么不打四带两对儿啊，兄弟？",
  ["$jy_hongwen3"] = "好难受啊！",
  ["$jy_hongwen4"] = "操，可惜！",
  ["$jy_hongwen5"] = "那他咋想的呀？",

  ["jy_zouwei"] = "走位",
  [":jy_zouwei"] = "锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。",
  ["$jy_zouwei1"] = "玩一下，不然我是不是一张牌没有出啊兄弟？",
  ["$jy_zouwei2"] = "完了呀！",

  ["jy_shengnu"] = "圣弩",
  [":jy_shengnu"] = "锁定技，当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得此【诸葛连弩】。",
  ["$jy_shengnu1"] = "哎兄弟们我这个牌不能拆吧？",
  ["$jy_shengnu2"] = "补刀瞬间回来了！",

  ["jy_xizao"] = "洗澡",
  [":jy_xizao"] = "限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$jy_xizao1"] = "呃啊啊啊啊啊啊啊！！",
  ["$jy_xizao2"] = "也不是稳赢吧，我觉得赢了！",

  ["~xjb__jianzihao"] = "好像又要倒下了……",
}


-- 第二代简自豪
local tym__jianzihao = General(extension, "tym__jianzihao", "qun", 3, 3, General.Male)

local jy_sanjian = fk.CreateTriggerSkill{
  name = "jy_sanjian",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},  -- 事件开始时
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)  -- 如果是我这个角色，如果是有这个技能的角色，如果是出牌阶段，如果这个角色的装备数是3
      and player.phase == Player.Play and #player:getCardIds(Player.Equip) == 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("analeptic", nil, player, player, self.name, false)
    if player.hp ~= player.maxHp then
      room:useVirtualCard("peach", nil, player, player, self.name, false)
    end
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

    -- 判断目标是否有谦逊
    local is_qianxun = false
    for _, s in ipairs(Fk:currentRoom():getPlayerById(to_select).player_skills) do
      if s.name == "qianxun" then
        is_qianxun = true
      end
    end

    -- 不会写这个，我想直接以顺手牵羊的形式判断能不能被顺
    -- local player = Fk:currentRoom():getPlayerById(Self.id)
    -- local snatch = Fk:cloneCard("snatch")
    -- local is_qianxun = Fk:currentRoom():getPlayerById(to_select):isProhibited(player, snatch)
    
    -- print(Fk:currentRoom():getPlayerById(to_select).general.name, " 的is_qianxun的值为 ", is_qianxun)


    return to_select ~= Self.id and not is_qianxun and -- 如果目标不是自己，而且没有谦逊
      not Fk:currentRoom():getPlayerById(to_select):isAllNude()  -- 而且不是裸装。函数要用冒号
  end,
  min_target_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    for _, to in ipairs(use.tos) do
      local p = room:getPlayerById(to)

      room:useVirtualCard("snatch", nil, player, p, self.name, true)  -- 顺
      
      -- 顺手牵羊，但不能被无懈可击响应（那我为啥不直接顺？）
      -- local snatch = Fk:cloneCard("snatch")
      -- snatch.skillName = self.name
      -- local new_use = { ---@type CardUseStruct
      --   from = use.from,  -- 应该是直接传id
      --   tos = { { to } },
      --   card = snatch,
      --   prohibitedCardNames = { "nullification" },
      -- }
      -- room:useCard(new_use)

      room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
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
    -- 将体力回复至3点
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
-- tym__jianzihao:addSkill("hongyan") -- 为了平衡而做出的决定。这样八卦阵和藤甲都是可以的。
tym__jianzihao:addSkill(jy_xizao_2)

Fk:loadTranslationTable{
  ["tym__jianzihao"] = "简自豪",

  ["jy_kaiju_2"] = "夺冠",
  [":jy_kaiju_2"] = [[出牌阶段限一次，你选择若干名武将。你对他们【顺手牵羊】，然后被他们【杀】。
  <br><font size="2"><i>“加入EDG，成为世界冠军！”</i></font>]],
  ["$jy_kaiju_21"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju_22"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju_23"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju_24"] = "好亏呀，我每一波都。",
  ["$jy_kaiju_25"] = "被秀了，操。",

  ["jy_sanjian"] = "三件",
  [":jy_sanjian"] = [[锁定技，出牌阶段开始时，如果你的装备区有且仅有3张牌，你视为使用一张【酒】、一张【桃】和一张【无中生有】。<br>
  <font size="2"><i>“又陷入劣势了，等乌兹三件套吧！”——不知道哪个解说说的</i></font>]],
  ["$jy_sanjian1"] = "也不是稳赢吧，我觉得赢了！",

  ["jy_xizao_2"] = "洗澡",
  [":jy_xizao_2"] = "限定技，当你处于濒死状态且装备区有牌时，你可以弃掉所有装备区的牌、将体力恢复至1，然后每以此法弃掉一张牌，你摸一张牌。",
  ["$jy_xizao_21"] = "呃啊啊啊啊啊啊啊！！",
  ["$jy_xizao_22"] = "也不是稳赢吧，我觉得赢了！",

  ["~tym__jianzihao"] = "好像又要倒下了……",
}

-- 侯国玉
local tym__houguoyu = General(extension, "tym__houguoyu", "qun", 4, 4, General.Male)

tym__houguoyu:addSkill("guose")
tym__houguoyu:addSkill("qianxun")
tym__houguoyu:addSkill("biyue")

Fk:loadTranslationTable {
  ["tym__houguoyu"] = "侯国玉",
  ["houguoyu"] = "侯国玉",
}

-- 李元浩
local skl__liyuanhao = General(extension, "skl__liyuanhao", "qun", 3, 3, General.Male)

-- 虎啸
-- 参考自铁骑，屯田，脑洞包明哲，克己（原来克己已经监视了使用和打出了，不用写那么复杂）
local jy_huxiao = fk.CreateTriggerSkill{
  name = "jy_huxiao",
  anim_type = "special",
  events = {fk.CardResponding, fk.TargetSpecified},  -- 包括了使用和打出
  -- frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card.trueName == "slash" then
      -- 使用是TS，打出是CR
      if event == fk.TargetSpecified or event == fk.CardResponding then
        return target == player
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(room:getNCards(1))
    player:addToPile("skl__liyuanhao_xiao", dummy, true, self.name)
  end,
}

-- 啸闪
local jy_huxiao_jink = fk.CreateViewAsSkill{
  name = "jy_huxiao_jink",
  anim_type = "defensive",
  pattern = "jink",
  expand_pile = "skl__liyuanhao_xiao",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "skl__liyuanhao_xiao"
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

-- 啸酒
local jy_huxiao_analeptic = fk.CreateViewAsSkill{
  name = "jy_huxiao_analeptic",
  anim_type = "defensive",
  pattern = "analeptic",
  expand_pile = "skl__liyuanhao_xiao",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "skl__liyuanhao_xiao"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    -- print("克隆的牌c的参数：c.name ", c.name, " c.trueName ", c.trueName)
    c:addSubcard(cards[1])
    return c
  end,
}

-- 二段
-- 首先BeforeCardsMove判断一次是否有牌进/出你的特殊区，然后如果有，
-- 再在AfterCardsMove里判断是否这张牌是啸，而且导致啸的数量变成了2。
-- 天才！
-- 参考自周泰，界周泰
local jy_erduanxiao = fk.CreateTriggerSkill{
  name = "jy_erduanxiao",
  anim_type = "negative",
  events = {fk.BeforeCardsMove},  -- 理论上来说每次牌的移动只有同一个方向的
  frequency = Skill.Compulsory,
  mute = true,

  can_trigger = function(self, event, target, player, data)
    -- 只判断是否有牌进出了你的特殊区，而不判断它是否是啸（因为比较复杂，等确定有可能了之后再判断，节省资源）
    local xiaos = player:getPile("skl__liyuanhao_xiao")
    player.is_xiao_changing = false -- 默认这次没有变化
    if player:hasSkill(self) and -- 如果是有二段啸的武将
      #xiaos == 1 or #xiaos == 3 then  -- 如果啸是1和3
      for _, move in ipairs(data) do  -- 如果有一张牌是进入或者离开我的特殊区，那么这个函数可以触发
        return (move.to == player.id and move.toArea == Card.PlayerSpecial) or
          (move.from == player.id and move.fromArea == Card.PlayerSpecial)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    -- 触发之后，设置变量，告诉下一个函数有没有可能在发生变化
    player.is_xiao_changing = true
    -- print("jy_erduanxiao 已触发，现在player.is_xiao_changing的值是", player.is_xiao_changing)
  end,
}

local jy_erduanxiao_trigger = fk.CreateTriggerSkill{
  name = "#jy_erduanxiao_trigger",
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and -- 如果是有二段啸的武将
      #player:getPile("skl__liyuanhao_xiao") == 2 and  -- 如果啸为2
      player.is_xiao_changing  -- 如果啸有可能在变化
  end,
  on_use = function(self, event, target, player, data)
    -- print("jy_erduanxiao_trigger 已触发，现在player.is_xiao_changing的值是", player.is_xiao_changing)
    local room = player.room
    local choice = room:askForChoice(player, {"#lose_xiao", "#lose_hp_1"}, self.name)
    if choice == "#lose_xiao" then
      local xiaos = player:getPile("skl__liyuanhao_xiao")
      room:throwCard(xiaos, self.name, player, player)  -- 全部扔掉
    elseif choice == "#lose_hp_1" then
      room:loseHp(player, 1, self.name)
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
    room:notifySkillInvoked(player, self.name, "offensive")
    data.damage = data.damage + 1
  end,
}

skl__liyuanhao:addSkill(jy_huxiao)
skl__liyuanhao:addSkill(jy_huxiao_jink)
skl__liyuanhao:addSkill(jy_huxiao_analeptic)
skl__liyuanhao:addSkill(jy_erduanxiao)
skl__liyuanhao:addSkill(jy_husanjian)

Fk:loadTranslationTable {
  ["skl__liyuanhao"] = "李元浩",
  ["skl__liyuanhao_xiao"] = "啸",

  ["jy_huxiao"] = "虎啸",
  [":jy_huxiao"] = [[当你使用或打出一张【杀】时，你可以将牌堆顶的一张牌置于你的武将牌上，称为【啸】。
  <br><font size="2"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”——李元浩</i></font>]],

  ["jy_huxiao_jink"] = "横刀",
  [":jy_huxiao_jink"] = [[你可以将【啸】当作【闪】使用或打出。
  <br><font size="2"><i>“谁敢横刀立马……”——钱晨</i></font>]],

  ["jy_huxiao_analeptic"] = "立马",
  [":jy_huxiao_analeptic"] = [[你可以将【啸】当作【酒】使用或打出。
  <br><font size="2"><i>“……唯我虎大将军！”——钱晨</i></font>]],

  ["jy_erduanxiao"] = "二段",
  [":jy_erduanxiao"] = "锁定技，当你的武将牌上有两张【啸】时，你选择失去一点体力或失去所有【啸】。",
  ["#jy_erduanxiao_trigger"] = "二段",
  ["#lose_xiao"] = "失去所有【啸】", 
  ["#lose_hp_1"] = "失去1点体力",

  ["jy_husanjian"] = "三件",
  [":jy_husanjian"] = [[锁定技，当你的装备区有且仅有防具和防御马时，你造成的伤害+1。
  <br><font size="2"><i>虎三件，指【中娅沙漏】、【水银之靴】、【大天使之杖】、【永霜】、【兰德里的苦楚】里面的三件。不同的人有不同的观点，但【大天使之杖】定在其列。</i></font>]],
}

-- 阿伟罗
local xjb__aweiluo = General(extension, "xjb__aweiluo", "qun", 3, 3, General.Male)

xjb__aweiluo:addSkill("luanji")
xjb__aweiluo:addSkill("luanwu")

Fk:loadTranslationTable {
  ["xjb__aweiluo"] = "阿伟罗",
}

-- 高天亮

-- 可能有bug:不是一次伤害，而是一滴伤害
local xjb__gaotianliang = General(extension, "xjb__gaotianliang", "qun", 3, 3, General.Male)

local jy_yuyu = fk.CreateTriggerSkill{
  name = "jy_yuyu",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(3)
    player:turnOver()
  end,
}

xjb__gaotianliang:addSkill(jy_yuyu)

Fk:loadTranslationTable {
  ["xjb__gaotianliang"] = "高天亮",

  ["jy_yuyu"] = "玉玉",
  [":jy_yuyu"] = "当你受到伤害时，你可以摸三张牌，然后翻面。"
}

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
     ["liyuanhao"] = "李元浩",
     ["aweiluo"] = "阿伟罗",
     ["gaotianliang"] = "高天亮",
}

return extension
