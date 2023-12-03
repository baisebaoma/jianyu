local extension = Package:new("jianyu_lpl")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
     ["jianyu_lpl"] = "<font color=\"red\"><strong>监狱-LPL</strong></font>",
     ["god"] = "神话再临·神",
     ["first"] = "熊",
     ["second"] = "冠军限定",
}


-- 第一代简自豪 设计：熊俊博 实现：反赌专家
local first__jianzihao = General(extension, "first__jianzihao", "qun", 3, 3, General.Male)

-- 红温
local hongwen = fk.CreateFilterSkill{
  name = "hongwen",
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
local zouwei = fk.CreateDistanceSkill{
  name = "zouwei",
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
local zouwei_audio = fk.CreateTriggerSkill{
  name = "#zouwei_audio",

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
      room:notifySkillInvoked(player, "zouwei", "offensive")
      player:broadcastSkillInvoke("zouwei", 1)
    -- 无装备时，+1马
    elseif #player:getCardIds(player.Equip) == 0 then
      room:notifySkillInvoked(player, "zouwei", "defensive")
      player:broadcastSkillInvoke("zouwei", 2)
    end
  end,
}
zouwei:addRelatedSkill(zouwei_audio)

-- 圣弩
-- 参考自formation包的君刘备
local shengnu = fk.CreateTriggerSkill{
  name = "shengnu",
  anim_type = 'drawcard',
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
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
local zhuanhui = fk.CreateTriggerSkill{
  name = "zhuanhui",  -- kaiju$是主公技
  frequency = Skill.Compulsory,
  events = {},  -- 这是故意的，因为本来这个技能就没有实际效果
}

-- 洗澡
local xizao = fk.CreateTriggerSkill{
  name = "xizao",
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

local kaiju = fk.CreateTriggerSkill{
  name = "kaiju",  -- kaiju$是主公技
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
        -- 其实这里可以优化成贯石斧那种逻辑，也就是只在下面选择，但我不会
        local id = room:askForCardChosen(p, p, "he", "#kaiju-choose")  -- 他自己用框选一张自己的牌，不包括判定区
        room:obtainCard(player, id, false, fk.ReasonPrey)  -- 我从他那里拿一张牌来
        room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
      end
    end
  end,
}

-- local id = room:askForCardChosen(player, p, "hej", self.name)  -- 我选他一张牌

-- room:useVirtualCard("slash", nil, player, table.map(self.cost_data, Util.Id2PlayerMapper), self.name, true)

first__jianzihao:addSkill(kaiju)
first__jianzihao:addSkill(hongwen)
first__jianzihao:addSkill(zouwei)
first__jianzihao:addSkill(shengnu)
first__jianzihao:addSkill(xizao)
-- first__jianzihao:addSkill(zhuanhui)

Fk:loadTranslationTable{
  ["first__jianzihao"] = "简自豪",

  ["zhuanhui"] = "转会",
  [":zhuanhui"] = [[锁定技，这个技能是为了告诉你下面这些提示。<br>
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
  -- [":zhuanhui"] = "<del>当你的体力值减少时，你可以变更势力。你无法变更为已经成为过的势力。</del>",

  ["kaiju"] = "开局",
  [":kaiju"] = [[锁定技，当你的回合开始时，所有其他有牌的武将需要交给你一张牌，并视为对你使用一张【杀】。<br>
  <font size="2"><i>“从未如此美妙的开局！”——简自豪</i></font>]],
  ["$kaiju1"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$kaiju2"] = "怎么赢啊？你别瞎说啊！",
  ["$kaiju3"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$kaiju4"] = "好亏呀，我每一波都。",
  ["$kaiju5"] = "被秀了，操。",
  ["#kaiju-choose"] = "交给简自豪一张牌，视为对他使用【杀】",

  ["hongwen"] = "红温",
  [":hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$hongwen1"] = "唉，不该出水银的。",
  ["$hongwen2"] = "哎，兄弟我为什么不打四带两对儿啊，兄弟？",
  ["$hongwen3"] = "好难受啊！",
  ["$hongwen4"] = "操，可惜！",
  ["$hongwen5"] = "那他咋想的呀？",

  ["zouwei"] = "走位",
  [":zouwei"] = "锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。",
  ["$zouwei1"] = "玩一下，不然我是不是一张牌没有出啊兄弟？",
  ["$zouwei2"] = "完了呀！",

  ["shengnu"] = "圣弩",
  [":shengnu"] = "锁定技，当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你获得此【诸葛连弩】。",
  ["$shengnu1"] = "哎兄弟们我这个牌不能拆吧？",
  ["$shengnu2"] = "补刀瞬间回来了！",

  ["xizao"] = "洗澡",
  [":xizao"] = "限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$xizao1"] = "呃啊啊啊啊啊啊啊！！",
  ["$xizao2"] = "也不是稳赢吧，我觉得赢了！",

  ["~first__jianzihao"] = "好像又要倒下了……",
}


-- 侯国玉
local houguoyu = General(extension, "houguoyu", "shu", 5, 10, General.Male)
houguoyu.hidden = true

local waao = fk.CreateTriggerSkill{
  name = "waao",
  frequency = Skill.Compulsory,
  events = {},  -- 这是故意的，因为本来这个技能就没有实际效果
}

houguoyu:addSkill("paoxiao")
houguoyu:addSkill("qianxun")

Fk:loadTranslationTable {
  ["houguoyu"] = "侯国玉",
}


-- 第二代简自豪
local second__jianzihao = General(extension, "second__jianzihao", "qun", 3, 3, General.Male)
second__jianzihao.hidden = true

local sanjian = fk.CreateTriggerSkill{
  name = "sanjian",
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
    -- room:useVirtualCard("peach", nil, player, player, self.name, false)
    room:useVirtualCard("ex_nihilo", nil, player, player, self.name, false)
  end,
}

-- local kaiju_2 = fk.CreateActiveSkill{
--   name = "kaiju_2",
--   anim_type = "offensive",
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
--   end,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0
--   end,
--   target_filter = function(self, to_select, selected)
--     return #selected <= 3 and to_select ~= Self.id and
--       not Fk:currentRoom():getPlayerById(to_select).isAllNude()  -- 选择三个目标，这三个不能是自己，也不能是裸装
--   end,
--   min_target_num = 1,
--   min_card_num = 0,
--   on_use = function(self, room, use)
--     local player = room:getPlayerById(use.from)
--     for p in use.tos do
--       room:useVirtualCard("snatch", nil, player, p, self.name, true)  -- 顺
--       room:useVirtualCard("fire__slash", nil, p, player, self.name, true)  -- 火杀
--     end
--   end,
-- }

local kaiju_2 = fk.CreateActiveSkill{
  name = "kaiju_2",
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

      -- room:useVirtualCard("snatch", nil, player, p, self.name, true)  -- 顺

      local snatch = Fk:cloneCard("snatch")
      snatch.skillName = self.name
      local new_use = { ---@type CardUseStruct
        from = use.from,  -- 应该是直接传id
        tos = { { to } },
        card = snatch,
        prohibitedCardNames = { "nullification" },
      }
      room:useCard(new_use)

      room:useVirtualCard("fire__slash", nil, p, player, self.name, true)  -- 火杀
    end
  end,
}

local xizao_2 = fk.CreateTriggerSkill{
  name = "xizao_2",
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

second__jianzihao:addSkill(kaiju_2)
second__jianzihao:addSkill(sanjian)
-- second__jianzihao:addSkill("paoxiao")
second__jianzihao:addSkill("hongyan")
-- second__jianzihao:addSkill("zouwei")
second__jianzihao:addSkill(xizao_2)


Fk:loadTranslationTable{
  ["second__jianzihao"] = "简自豪",

  ["kaiju_2"] = "开局",
  [":kaiju_2"] = "出牌阶段限一次，你选择若干名武将，视为你对他们使用【顺手牵羊】，然后被他们【火杀】。以此法使用的【顺手牵羊】无法被【无懈可击】响应；你不能选择带有【谦逊】（标准版）技能的武将为目标。",
  ["$kaiju_21"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$kaiju_22"] = "怎么赢啊？你别瞎说啊！",
  ["$kaiju_23"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$kaiju_24"] = "好亏呀，我每一波都。",
  ["$kaiju_25"] = "被秀了，操。",

  ["sanjian"] = "三件",
  [":sanjian"] = [[锁定技，出牌阶段开始时，如果你的装备区有且仅有3张牌，你视为使用一张【酒】、一张【无中生有】。<br>
  <font size="2"><i>“又陷入劣势了，等乌兹三件套吧！”——不知道哪个解说说的</i></font>]],
  ["$sanjian1"] = "也不是稳赢吧，我觉得赢了！",

  ["xizao_2"] = "洗澡",
  [":xizao_2"] = "限定技，当你处于濒死状态且装备区有牌时，你可以弃掉所有装备区的牌、将体力恢复至1，然后每以此法弃掉一张牌，你摸一张牌。",
  ["$xizao_21"] = "呃啊啊啊啊啊啊啊！！",
  ["$xizao_22"] = "也不是稳赢吧，我觉得赢了！",

  ["~second__jianzihao"] = "好像又要倒下了……",
}

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
}

return extension