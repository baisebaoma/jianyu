local extension = Package:new("jianyu_lpl")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
     ["jianyu_lpl"] = "监狱：LPL篇",
     ["god"] = "神话再临·神",
}


-- 简自豪 设计：熊俊博 实现：反赌专家
local jianzihao = General(extension, "jianzihao", "god", 3, 3, General.Male)

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
    -- 装备区有牌时，你视为装备-1马
    if from:hasSkill(self) and from:getCardIds(from.Equip) ~= 0 then
      return -1
    end
    -- 装备区没牌时，你视为装备+1马
    if to:hasSkill(self) and from:getCardIds(from.Equip) == 0 then
      return 1
    end
    return 0
  end,
}

local zouwei_audio = fk.CreateTriggerSkill{
  name = "#zouwei_audio",

  refresh_events = {fk.EquipChanged},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("zouwei") and not player:isFakeSkill("zouwei")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player:getCardIds(player.Equip) ~= 0 then
      room:notifySkillInvoked(player, "zouwei", "offensive")
      player:broadcastSkillInvoke("zouwei", 1)
    elseif player:getCardIds(player.Equip) == 0 then
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
local zhuanhui = fk.CreateMaxCardsSkill {
  name = "zhuanhui",
  correct_func = function(self, player)
      if player:hasSkill(self.name) then
          local kingdoms = {}
          for _, p in ipairs(Fk:currentRoom().alive_players) do
              table.insertIfNeed(kingdoms, p.kingdom)
          end
          return #kingdoms
      else
          return 0
      end
  end,
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
        local id = room:askForCardChosen(p, p, "#kaiju-choose", self.name)  -- 他自己选一张牌
        room:obtainCard(player, id, false, fk.ReasonPrey)  -- 我从他那里拿一张牌来
        room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
      end
    end
  end,
}

-- 这个版本可以用，但是是你从所有人那里抽一张
-- local kaiju = fk.CreateTriggerSkill{
--   name = "kaiju",  -- kaiju$是主公技
--   anim_type = "masochism",
--   frequency = Skill.Compulsory,
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self.name) and player.phase == Player.Start
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     for _, p in ipairs(room:getOtherPlayers(player, true)) do
--       if not p:isAllNude() then
--         local id = room:askForCardChosen(player, p, "hej", self.name)  -- 我选他一张牌
--         room:obtainCard(player, id, false, fk.ReasonPrey)  -- 我从他那里拿一张牌来
--         room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
--       end
--     end
--   end,
-- }

-- 主公技，锁定技，当你的回合开始时，所有其他有牌的武将需要交给你一张牌，并视为对你使用一张【杀】。

-- room:useVirtualCard("slash", nil, player, table.map(self.cost_data, Util.Id2PlayerMapper), self.name, true)


jianzihao:addSkill(hongwen)
jianzihao:addSkill(zouwei)
jianzihao:addSkill(shengnu)
jianzihao:addSkill(zhuanhui)
jianzihao:addSkill(xizao)
jianzihao:addSkill(kaiju)


Fk:loadTranslationTable{
  ["jianzihao"] = "简自豪",

  ["hongwen"] = "红温",
  [":hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$hongwen1"] = "唉，不该出水银的。",
  ["$hongwen2"] = "哎，兄弟我为什么不打四带两对啊，兄弟？",
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

  ["zhuanhui"] = "转会",
  [":zhuanhui"] = "锁定技，这个技能没有什么屌用，但是能让你看起来有6个技能，很帅！<strong>这个武将由熊俊博设计！</strong>",
  -- [":zhuanhui"] = "<del>当你的体力值减少时，你可以变更势力。你无法变更为已经成为过的势力。</del>",
  ["$zhuanhui1"] = "被秀了，操。",

  ["xizao"] = "洗澡",
  [":xizao"] = "限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$xizao1"] = "怎么赢啊？你别瞎说啊，兄弟们。",
  ["$xizao2"] = "也不是稳赢吧，我觉得赢了！",

  ["kaiju"] = "开局",
  [":kaiju"] = "锁定技，当你的回合开始时，所有其他有牌的武将需要交给你一张牌，并视为对你使用一张【杀】。",
  ["$kaiju1"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对十，他四个9炸我，我不输了吗？",
  ["$kaiju2"] = "哇袄！！",
  ["#kaiju-choose"] = "简自豪的【开局】：你选择一张牌交给他，然后视为你对他使用了一张【杀】。",

  ["~jianzihao"] = "好像又要倒下了……",
}


local houguoyu = General(extension, "houguoyu", "shu", 0, 999, General.Male)
houguoyu.hidden = true

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
}

return extension