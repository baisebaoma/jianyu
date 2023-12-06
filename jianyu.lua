local extension = Package:new("jy_jianyu")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
     ["jy_jianyu"] = "<font color=\"red\"><strong>监狱</strong></font>",
     ["god"] = "神话再临·神",
     ["xjb"] = "熊",
     ["tym"] = "唐",
     ["skl"] = "尚",
     ["buffed"] = "加强",
}

-- TODO: 加入你这个包之后，测试时如果烧条偶尔会变得CPU占用率很高。只有标包没有这个问题。

-- 熊简自豪
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
-- TODO: 没写好之前先禁用
-- -- 参考自孙尚香，formation君刘备
-- local jy_zouwei_audio = fk.CreateTriggerSkill{
--   name = "#jy_zouwei_audio",

--   refresh_events = {fk.AfterCardsMove},
--   -- 这个函数只有在装备区牌量变动时才检测
--   can_refresh = function(self, event, target, player, data)
--     if not player:hasSkill(self.name) then return end
--     for _, move in ipairs(data) do  -- 对着抄的，开始第一个循环
--       if move.from == player.id or move.to == player.id then  -- 这行对着抄的，判断是否是自己家
--         for _, info in ipairs(move.moveInfo) do  -- 对着抄的，第二个循环
--           if info.fromArea == Card.PlayerEquip or info.toArea == Card.PlayerEquip then  -- 对着抄的，在这里判断是去哪个区的
--             -- 不知道为啥用不了
--             if #player:getCardIds(Player.Equip) > 0  then  -- 他进了你的装备区之后，你的装备数量为1
--               print("检测到装备不等于0")
--               return true
--             end
--             -- 下面这个可以运行
--             if #player:getCardIds(Player.Equip) == 0 and info.fromArea == Card.PlayerEquip then  -- 他出了你的装备区之后，你的装备数量为0
--               return true
--             end
--           end
--         end
--       end
--     end
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     -- 有装备时，-1马
--     if #player:getCardIds(player.Equip) > 0 then
--       room:notifySkillInvoked(player, "jy_zouwei", "offensive")
--       player:broadcastSkillInvoke("jy_zouwei", 1)
--     -- 无装备时，+1马
--     elseif #player:getCardIds(player.Equip) == 0 then
--       room:notifySkillInvoked(player, "jy_zouwei", "defensive")
--       player:broadcastSkillInvoke("jy_zouwei", 2)
--     end
--   end,
-- }
-- jy_zouwei:addRelatedSkill(jy_zouwei_audio)

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
-- xjb__jianzihao:addSkill(jy_zhuanhui)

Fk:loadTranslationTable{
  ["xjb__jianzihao"] = "简自豪",

  ["jy_kaiju"] = "开局",
  [":jy_kaiju"] = [[锁定技，当你的回合开始时，所有其他有牌的角色需要交给你一张牌，并视为对你使用一张【杀】。<br>
  <font size="1"><i>“从未如此美妙的开局！”——简自豪</i></font>]],
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
  [":jy_shengnu"] = "当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得此【诸葛连弩】。",
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

      if not player.dead then
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
tym__jianzihao:addSkill("hongyan")
tym__jianzihao:addSkill("jy_zouwei")
tym__jianzihao:addSkill("jy_shengnu")
tym__jianzihao:addSkill(jy_xizao_2)

Fk:loadTranslationTable{
  ["tym__jianzihao"] = "界简自豪",

  ["jy_kaiju_2"] = "开局",
  [":jy_kaiju_2"] = "出牌阶段限一次，你选择若干名角色。你对他们【顺手牵羊】，然后被他们【杀】。",
  ["$jy_kaiju_21"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju_22"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju_23"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju_24"] = "好亏呀，我每一波都。",
  ["$jy_kaiju_25"] = "被秀了，操。",

  ["jy_sanjian"] = "三件",
  [":jy_sanjian"] = [[锁定技，出牌阶段开始时，如果你的装备区有且仅有3张牌，你视为使用一张【酒】和一张【无中生有】。<br>
  <font size="1"><i>“又陷入劣势了，等乌兹三件套吧！”——不知道哪个解说说的</i></font>]],
  ["$jy_sanjian1"] = "也不是稳赢吧，我觉得赢了！",

  ["jy_xizao_2"] = "洗澡",
  [":jy_xizao_2"] = "限定技，当你处于濒死状态且装备区有牌时，你可以弃掉所有装备区的牌、将体力恢复至1，然后每以此法弃掉一张牌，你摸一张牌。",
  ["$jy_xizao_21"] = "呃啊啊啊啊啊啊啊！！",
  ["$jy_xizao_22"] = "也不是稳赢吧，我觉得赢了！",

  ["~tym__jianzihao"] = "好像又要倒下了……",
}

-- 尚李元浩
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

-- 啸酒
-- 注释里是为了测试改成无中生有。保留在这里以防你后面还需要测试。
local jy_huxiao_analeptic = fk.CreateViewAsSkill{
  name = "jy_huxiao_analeptic",
  anim_type = "defensive",
  pattern = "analeptic",
  -- pattern = "ex_nihilo",
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
    -- local c = Fk:cloneCard("ex_nihilo")
    c.skillName = self.name
    -- print("克隆的牌c的参数：c.name ", c.name, " c.trueName ", c.trueName)
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

  -- can_trigger = function(self, event, target, player, data)
  --   -- 只判断是否有牌进出了你的特殊区，而不判断它是否是啸（因为比较复杂，等确定有可能了之后再判断，节省资源）
  --   if player:hasSkill(self) then -- 如果是有二段啸的角色
  --     local xiaos = player:getPile("skl__liyuanhao_xiao")
  --     player.is_xiao_changing = false -- 默认这次没有变化
  --     if #xiaos == 1 or #xiaos == 3 then  -- 如果啸是1或3
  --       -- 1是可以触发的，3不知道为啥触发不了。难道viewas不会移动牌吗？
  --       -- 我觉得有可能是这个原因。明天可以改成“用完牌之后”之类的。
  --       if #xiaos == 3 then print("二段笑（一段）已经检测到#xiaos为", #xiaos) end
  --       for _, move in ipairs(data) do  -- 如果有一张牌是进入或者离开我的特殊区，那么这个函数可以触发
  --         if (move.to == player.id and move.toArea == Card.PlayerSpecial) or
  --           (move.from == player.id and move.fromArea == Card.PlayerSpecial) then
  --           -- 去找一段代码，检测自己特殊区的牌离开的
  --           print("二段笑（一段）已经检测有牌从特殊区变动", #xiaos)
  --           -- 检测不到离开
  --           if move.to == player.id and move.toArea == Card.PlayerSpecial then
  --             print("二段笑（一段）已经检测有牌来到特殊区", #xiaos)
  --           end
  --           if move.from == player.id and move.fromArea == Card.PlayerSpecial then
  --             print("二段笑（一段）已经检测有牌从特殊区离开", #xiaos)
  --           end
  --           return true
  --         end
  --       end
  --     end
  --   end
  -- end,

  -- -- 根据守成改的版本，现在可以3-2了，但是不能1-2
  -- -- 我真的不知道为什么了。这样吧，把两个版本综合一下，写到下一个里面，这个就算完成了。以后再改。
  -- can_trigger = function(self, event, target, player, data)
  --   if not player:hasSkill(self) then return end  -- 如果我自己没有这个技能，那就算了
  --   local xiaos = player:getPile("skl__liyuanhao_xiao")
  --   player.is_xiao_changing = false
  --   for _, move in ipairs(data) do  -- 第一层循环，不知道为啥
  --     if move.from then  -- 照着抄的，牌离开
  --       print("有牌正打算离开")
  --       if move.from == player.id then
  --         print("有牌正打算从你家离开")
  --         if #xiaos == 3 then
  --           print("啸是3")
  --           for _, info in ipairs(move.moveInfo) do  -- 还有第二层循环。我自己的代码里没有第二层
  --             if info.fromArea == Card.PlayerSpecial then
  --               print("有牌正打算从你家特殊区离开")
  --               return true
  --             end
  --           end
  --         end
  --       end
  --     elseif move.to then  -- 照着抄的，牌离开
  --       print("有牌正打算来")
  --       if move.to == player.id then
  --         print("有牌正打算来你家")
  --         if #xiaos == 1 then
  --           print("啸是1")
  --           for _, info in ipairs(move.moveInfo) do  -- 还有第二层循环。我自己的代码里没有第二层
  --             if info.toArea == Card.PlayerSpecial then
  --               print("有牌正打算来你家特殊区")
  --               return true
  --             end
  --           end
  --         end
  --       end
  --     end
  --   end
  -- end,  -- 每个参数的结尾都要逗号。can_trigger是一个参数



  -- 测试通过。1-2，3-2都可以顺利触发。
  -- 我猜想原因是1-2的时候可能有多张牌进出，而3-2的时候只会有一张牌出去。但我搞不懂这个数据结构，
  -- 不知道为什么有一个是两层循环，有一个是一层循环。
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end  -- 如果我自己没有这个技能，那就算了

    local xiaos = player:getPile("skl__liyuanhao_xiao")
    player.is_xiao_changing = false

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
        if (move.to == player.id and move.toArea == Card.PlayerSpecial) or
          (move.from == player.id and move.fromArea == Card.PlayerSpecial) then
          -- 去找一段代码，检测自己特殊区的牌离开的
          -- print("二段笑（一段）已经检测有牌从特殊区变动", #xiaos)
          -- 检测不到离开
          -- if move.to == player.id and move.toArea == Card.PlayerSpecial then
          --   print("二段笑（一段）已经检测有牌来到特殊区", #xiaos)
          -- end
          return true
        end
      end
    end
  end,  -- 每个参数的结尾都要逗号。can_trigger是一个参数

  on_trigger = function(self, event, target, player, data)
    -- 触发之后，设置变量，告诉下一个函数有没有可能在发生变化
    player.is_xiao_changing = true
    -- print("二段笑（第一段） on_trigger已触发，现在是", player.is_xiao_changing, #player:getPile("skl__liyuanhao_xiao"))
  end,
}

local jy_erduanxiao_trigger = fk.CreateTriggerSkill{
  name = "#jy_erduanxiao_trigger",
  events = {fk.AfterCardsMove},
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return #player:getPile("skl__liyuanhao_xiao") == 2 and  -- 如果啸为2
      player.is_xiao_changing  -- 如果啸有可能在变化
  end,
  on_trigger = function(self, event, target, player, data)
    -- print("二段笑（第二段）已触发，", player.is_xiao_changing, #player:getPile("skl__liyuanhao_xiao"))
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
-- TODO: 加一个触发效果器

skl__liyuanhao:addSkill(jy_huxiao)
skl__liyuanhao:addSkill(jy_huxiao_analeptic)
skl__liyuanhao:addSkill(jy_huxiao_jink)
skl__liyuanhao:addSkill(jy_erduanxiao)
skl__liyuanhao:addSkill(jy_husanjian)

Fk:loadTranslationTable {
  ["skl__liyuanhao"] = "李元浩",
  ["skl__liyuanhao_xiao"] = "啸",

  ["jy_huxiao"] = "虎啸",
  [":jy_huxiao"] = [[当你使用或打出一张【杀】时，你可以将牌堆顶的一张牌置于你的角色牌上，称为【啸】。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”——李元浩</i></font>]],

  ["jy_huxiao_analeptic"] = "横刀",
  [":jy_huxiao_analeptic"] = [[你可以将【啸】当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>]],

  ["jy_huxiao_jink"] = "立马",
  [":jy_huxiao_jink"] = [[你可以将【啸】当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>]],

  ["jy_erduanxiao"] = "二段",
  [":jy_erduanxiao"] = "锁定技，当你的角色牌上有且仅有两张【啸】时，你选择失去一点体力或失去所有【啸】。",
  ["#jy_erduanxiao_trigger"] = "二段",
  ["#lose_xiao"] = "失去所有【啸】", 
  ["#lose_hp_1"] = "失去一点体力",

  ["jy_husanjian"] = "三件",
  [":jy_husanjian"] = [[锁定技，当你的装备区有且仅有防具和防御马时，你造成的伤害-1。
  <br><font size="1"><i>虎三件，指【中娅沙漏】、【水银之靴】、【大天使之杖】。一些人持不同的观点，但【大天使之杖】没有什么争议。</i></font>]],
}

-- 唐李元浩
local tym__liyuanhao = General(extension, "tym__liyuanhao", "qun", 3, 3, General.Male)

-- 界虎啸
-- 参考自铁骑，屯田，脑洞包明哲，克己（原来克己已经监视了使用和打出了，不用写那么复杂）
local jy_huxiao_2 = fk.CreateTriggerSkill{
  name = "jy_huxiao_2",
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
    player:addToPile("tym__liyuanhao_xiao", dummy, true, self.name)
  end,
}

-- 界啸酒
-- 注释里是为了测试改成无中生有。保留在这里以防你后面还需要测试。
local jy_huxiao_analeptic_2 = fk.CreateViewAsSkill{
  name = "jy_huxiao_analeptic_2",
  anim_type = "defensive",
  pattern = "analeptic",
  -- pattern = "ex_nihilo",
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
  anim_type = "negative",
  events = {fk.BeforeCardsMove},  -- 理论上来说每次牌的移动只有同一个方向的
  -- frequency = Skill.Compulsory,
  mute = true,

  -- 测试通过。1-2，3-2都可以顺利触发。
  -- 我猜想原因是1-2的时候可能有多张牌进出，而3-2的时候只会有一张牌出去。但我搞不懂这个数据结构，
  -- 不知道为什么有一个是两层循环，有一个是一层循环。
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end  -- 如果我自己没有这个技能，那就算了

    local xiaos = player:getPile("tym__liyuanhao_xiao")
    player.is_xiao_changing = false

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
        if (move.to == player.id and move.toArea == Card.PlayerSpecial) or
          (move.from == player.id and move.fromArea == Card.PlayerSpecial) then
          -- 去找一段代码，检测自己特殊区的牌离开的
          -- print("二段笑（一段）已经检测有牌从特殊区变动", #xiaos)
          -- 检测不到离开
          -- if move.to == player.id and move.toArea == Card.PlayerSpecial then
          --   print("二段笑（一段）已经检测有牌来到特殊区", #xiaos)
          -- end
          return true
        end
      end
    end
  end,  -- 每个参数的结尾都要逗号。can_trigger是一个参数

  on_trigger = function(self, event, target, player, data)
    -- 触发之后，设置变量，告诉下一个函数有没有可能在发生变化
    player.is_xiao_changing = true
    -- print("二段笑（第一段） on_trigger已触发，现在是", player.is_xiao_changing, #player:getPile("tym__liyuanhao_xiao"))
  end,
}

local jy_erduanxiao_trigger_2 = fk.CreateTriggerSkill{
  name = "#jy_erduanxiao_trigger_2",
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and -- 如果是有二段啸的角色
      #player:getPile("tym__liyuanhao_xiao") == 2 and  -- 如果啸为2
      player.is_xiao_changing  -- 如果啸有可能在变化
  end,

  on_cost = function(self, event, target, player, data)
    -- print("jy_erduanxiao_trigger 已触发，现在player.is_xiao_changing的值是", player.is_xiao_changing)
    local room = player.room
    -- 如果体力不是满的，两个选项都有；如果是满的，就黑掉【恢复体力】那个按钮。这个改动不需要改到标李元浩那边去，因为标李元浩是掉血。
    if player.hp ~= player.maxHp then
      self.choice = room:askForChoice(player, {"#lose_xiao_2", "#lose_hp_1_2"}, self.name)
    else
      self.choice = room:askForChoice(player, {"#lose_xiao_2"}, self.name, nil, nil, {"#lose_xiao_2", "#lose_hp_1_2"})
    end
    return true
  end,

  on_use = function(self, event, target, player, data)
    local xiaos = player:getPile("tym__liyuanhao_xiao")
    if self.choice == "#lose_xiao_2" then
      -- 将所有【啸】纳入自己的手牌
      player.room:moveCardTo(xiaos, Card.PlayerHand, player, fk.ReasonJustMove, self.name, "tym__liyuanhao_xiao", true, player.id)
    elseif self.choice == "#lose_hp_1_2" then
      -- 弃掉所有【啸】
      room:throwCard(xiaos, self.name, player, player)  -- 把啸全部扔掉
      -- 回复1点体力
      player.room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}
jy_erduanxiao_2:addRelatedSkill(jy_erduanxiao_trigger_2)

-- 界三件 已完成 测试通过
local jy_husanjian_2 = fk.CreateTriggerSkill{
  name = "jy_husanjian_2",
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
    return weapon and 
           not armor and
           not defensive_ride and 
           offensive_ride and
           not treasure
           -- 有且只有武器和-1马
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    room:notifySkillInvoked(player, self.name, "offensive")
    data.damage = data.damage + 1
  end,
}
-- TODO: 加一个触发效果器

-- 因为是两个不同的角色，两个角色的特殊区是不能通用的，所以必须分开写代码。
tym__liyuanhao:addSkill(jy_huxiao_2)
tym__liyuanhao:addSkill(jy_huxiao_analeptic_2)
tym__liyuanhao:addSkill(jy_huxiao_jink_2)
tym__liyuanhao:addSkill(jy_erduanxiao_2)
-- tym__liyuanhao:addSkill(jy_husanjian_2)

Fk:loadTranslationTable {
  ["tym__liyuanhao"] = "界李元浩",
  ["tym__liyuanhao_xiao"] = "<font color=\"gold\">啸</font>",

  ["jy_huxiao_2"] = "虎啸",
  [":jy_huxiao_2"] = [[当你使用或打出一张【杀】时，你可以将牌堆顶的一张牌置于你的角色牌上，称为【啸】。
  <br><font size="1"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有，冠军。”——李元浩</i></font>]],

  ["jy_huxiao_analeptic_2"] = "横刀",
  [":jy_huxiao_analeptic_2"] = [[你可以将【啸】当作【酒】使用或打出。
  <br><font size="1"><i>“谁敢横刀立马……”——钱晨</i></font>]],

  ["jy_huxiao_jink_2"] = "立马",
  [":jy_huxiao_jink_2"] = [[你可以将【啸】当作【闪】使用或打出。
  <br><font size="1"><i>“……唯我虎大将军！”——钱晨</i></font>]],

  ["jy_erduanxiao_2"] = "二段",
  [":jy_erduanxiao_2"] = "锁定技，当你的角色牌上有且仅有两张【啸】时，你选择：弃掉所有【啸】并恢复一点体力，或将所有【啸】纳入手牌。",
  ["#jy_erduanxiao_trigger_2"] = "二段",
  ["#lose_xiao_2"] = "将所有【啸】纳入手牌", 
  ["#lose_hp_1_2"] = "弃掉所有【啸】并恢复一点体力",
}


-- 阿伟罗
-- local xjb__aweiluo = General(extension, "xjb__aweiluo", "qun", 3, 3, General.Male)

-- xjb__aweiluo:addSkill("luanji")
-- xjb__aweiluo:addSkill("luanwu")

-- Fk:loadTranslationTable {
--   ["xjb__aweiluo"] = "阿伟罗",
-- }


-- -- -- 侯国玉
-- local tym__houguoyu = General(extension, "tym__houguoyu", "qun", 5, 5, General.Male)

-- tym__houguoyu:addSkill(jy_husanjian_2)
-- -- tym__houguoyu:addSkill("biyue")

-- Fk:loadTranslationTable {
--   ["tym__houguoyu"] = "侯国玉",
--   ["houguoyu"] = "侯国玉",
  
--   ["jy_husanjian_2"] = "三件",
--   [":jy_husanjian_2"] = [[锁定技，当你的装备区有且仅有武器和进攻马时，你造成的伤害+1。
--   <br><font size="1"><i>虎三件，有时也可以指【卢登的激荡】、【虚空之杖】和【灭世者的死亡之帽】。</i></font>]],
-- }


-- 高天亮

local xjb__gaotianliang = General(extension, "xjb__gaotianliang", "qun", 4, 4, General.Male)

local jy_yuyu = fk.CreateTriggerSkill{
  name = "jy_yuyu",
  anim_type = "masochism",
  events = {fk.Damaged},
  -- 遗计就是没有can_trigger的，遗计也不用判断player.hasSkill(self)，也不用判断伤害目标是自己，因为被省略了
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    self.this_time_slash = false
    if data.card and data.from and data.card.trueName == "slash" then  -- 如果是杀
      if not data.from:hasMark("@jy_gaotianliang_enemy") then 
        self.this_time_slash = true  -- 如果他是因为这次伤害变成了天敌，那么写在this_time_slash里
        room:setPlayerMark(data.from, "@jy_gaotianliang_enemy", "")  -- 空字符串也是true
      end
    end
    if self.this_time_slash or not data.from:hasMark("@jy_gaotianliang_enemy") then  -- 如果他不是敌人
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data) then  -- 那么问是否要发动
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3)
    player:turnOver()
    self.this_time_slash = false
  end,
}

xjb__gaotianliang:addSkill(jy_yuyu)

Fk:loadTranslationTable {
  ["xjb__gaotianliang"] = "高天亮",

  ["jy_yuyu"] = "玉玉",
  [":jy_yuyu"] = [[锁定技，当你被没有【高天亮之敌】标记的角色使用【杀】造成了伤害时，你令其获得【高天亮之敌】标记。
  受到来自没有【高天亮之敌】标记的角色或因本次伤害而获得【高天亮之敌】标记的角色造成的伤害时，你可以摸三张牌，然后翻面。]],
  ["@jy_gaotianliang_enemy"] = "高天亮之敌",
}

-- -- 赵乾熙
local tym__zhaoqianxi = General(extension, "tym__zhaoqianxi", "qun", 4, 4, General.Male)

-- 参考自藤甲。要把DamageInflicted改成DamageCaused，就是你对别人造成伤害的意思。
-- 如果是DamageInflicted，就是别人对你造成伤害的意思。
local jy_yuanshen = fk.CreateTriggerSkill{
  name = "jy_yuanshen",
  frequency = Skill.Compulsory,
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return false end
    return data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}

local jy_huoji = fk.CreateViewAsSkill{
  name = "jy_huoji",
  anim_type = "offensive",
  pattern = "fire__slash",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire__slash")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}

tym__zhaoqianxi:addSkill(jy_yuanshen)
tym__zhaoqianxi:addSkill(jy_huoji)

Fk:loadTranslationTable {
  ["tym__zhaoqianxi"] = "赵乾熙",
  
  ["jy_yuanshen"] = "原神",
  [":jy_yuanshen"] = [[锁定技，你造成的属性伤害+1。]],

  ["jy_huoji"] = "帽猫",
  [":jy_huoji"] = [[你可以将一张♠手牌当作【火杀】使用或打出。
  <br /><font size="1"><i><s>因为Beryl抽满命林尼歪了六次，所以他决定在新月杀中重拾自己的火。</s></i></font>]],
}

-- 界赵乾熙
local tym__zhaoqianxi_2 = General(extension, "tym__zhaoqianxi_2", "qun", 4, 4, General.Male)
-- tym__zhaoqianxi_2.hidden = true

local jy_yuanshen_2 = fk.CreateTriggerSkill{
  name = "jy_yuanshen_2",
  frequency = Skill.Compulsory,
  anim_type = "offensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)  -- player是我自己，只能让我自己播放这个动画
    if not player:hasSkill(self) then return false end
    return data.damageType ~= fk.NormalDamage and not data.is_jy_yuanshen_2_triggered  -- 如果这次没有被其他的该技能相应
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.damageType then
      -- 使用for循环以方便后面添加元素反应类型。每次只会有一种反应发生。
      -- element[1]是A属性类型，element[2]是A对应的附着标记，
      -- element[3]是A要反应的附着标记B，element[4]是要造成的效果
      -- Lua 的数组从1开始
      for _, element in ipairs(
        { {fk.FireDamage, "@jy_yuanshen_2_pyro", "@jy_yuanshen_2_electro", 
          function(self, event, target, player, data) data.damage = data.damage + 1 end},
        {fk.ThunderDamage, "@jy_yuanshen_2_electro", "@jy_yuanshen_2_pyro", 
          function(self, event, target, player, data) player.room:askForDiscard(data.to, 2, 2) end}, 
        }
      ) do
        if data.damageType == element[1] then  -- 如果是A属性伤害
          if data.to:getMark(element[3]) ~= 0 then  -- 如果目标有B附着
            room:setPlayerMark(data.to, element[3], 0)  -- 将B附着解除
            element[4](self, event, target, player, data)  -- 造成效果
            data.is_jy_yuanshen_2_triggered = true  -- 如果有多个拥有这个技能的人，告诉他不用再发动了
            return  -- 结束了，不用判断下一个了
          end
          if not data.to:hasMark(element[2]) then   -- 如果目标没有A附着
            room:setPlayerMark(data.to, element[2], 1)  -- 造成A附着
            return
          end
        end
      end
    end
  end,
}

-- 参考自悲歌
-- 因为如果每个无属性伤害都触发这个技能的话会极大增加等待时间，所以我的建议是更改成悲歌，只响应【杀】
local jy_fumo = fk.CreateTriggerSkill{
  name = "jy_fumo",
  anim_type = "masochism",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and 
      data.damageType == fk.NormalDamage and data.card and 
      data.card.trueName == "slash" and not data.to.dead and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#jy_fumo-invoke::"..target.id, true)
    if #card > 0 then
      room:doIndicate(player.id, {target.id})
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if target.dead then return false end
    local judge = {
      who = data.from,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Red then
      data.damageType = fk.FireDamage
    elseif judge.card.color == Card.Black then
      data.damageType = fk.ThunderDamage
    end
  end,
}

tym__zhaoqianxi_2:addSkill(jy_yuanshen_2)
tym__zhaoqianxi_2:addSkill(jy_fumo)

Fk:loadTranslationTable {
  ["tym__zhaoqianxi_2"] = "界赵乾熙",
  
  ["jy_yuanshen_2"] = "原神",
  [":jy_yuanshen_2"] = [[锁定技，所有角色的雷属性伤害都会令目标进入【雷附着】状态；
  所有角色的火属性伤害都会令目标进入【火附着】状态。
  当一名【雷附着】状态的角色受到火属性伤害时，移除【雷附着】状态并使该伤害+1；
  当一名【火附着】状态的角色受到雷属性伤害时，移除【火附着】状态并弃两张牌。
  这个技能只会触发一次，不论是否多个角色拥有这个技能。]],

  ["@jy_yuanshen_2_pyro"] = "<font color=\"red\">火附着</font>",
  ["@jy_yuanshen_2_electro"] = "<font color=\"violet\">雷附着</font>",

  ["jy_fumo"] = "附魔",
  ["#jy_fumo-invoke"] = "附魔：%dest 受到无属性伤害，你可以弃置一张牌令伤害来源判定，改为属性伤害。",
  [":jy_fumo"] = [[当有角色使用【杀】造成无属性伤害时，你可以弃一张牌并令伤害来源进行一次判定，
     若结果为：红色，将此次伤害改为火属性；黑色，将此次伤害改为雷属性。]],

}

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
     ["liyuanhao"] = "李元浩",
     ["aweiluo"] = "阿伟罗",
     ["gaotianliang"] = "高天亮",
     ["zhaoqianxi"] = "赵乾熙",
}

return extension
