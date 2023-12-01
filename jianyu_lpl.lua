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
-- 没写完，不过先拿去玩吧


jianzihao:addSkill(hongwen)
jianzihao:addSkill(zouwei)
jianzihao:addSkill(shengnu)
-- jianzihao:addSkill(zhuanhui)
jianzihao:addSkill(xizao)
-- jianzihao:addSkill(kaiju)


Fk:loadTranslationTable{
  ["jianzihao"] = "简自豪",

  ["hongwen"] = "红温",
  [":hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$hongwen1"] = "唉，不该出水银的。",
  ["$hongwen2"] = "哎，兄弟我为什么不打四带两对啊，兄弟？",
  ["$hongwen3"] = "好难受啊！",
  ["$hongwen4"] = "操，可惜！",
  ["$hongwen4"] = "那他咋想的呀？",

  ["zouwei"] = "走位",
  [":zouwei"] = "锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。",
  ["$zouwei1"] = "玩一下，不然我是不是一张牌没有出啊兄弟？",
  ["$zouwei2"] = "完了呀！",

  ["shengnu"] = "圣弩",
  [":shengnu"] = "锁定技，当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你获得此【诸葛连弩】。",
  ["$shengnu1"] = "哎兄弟们我这个牌不能拆吧？",

  ["zhuanhui"] = "转会",
  [":zhuanhui"] = "当你的体力值减少时，你可以变更势力。你无法变更为已经成为过的势力。",
  ["$zhuanhui1"] = "现在站在你面前的是S赛13冠王！",

  ["xizao"] = "洗澡",
  [":xizao"] = "限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$xizao1"] = "怎么赢啊？你别瞎说啊，兄弟们。",
  ["$xizao2"] = "也不是稳赢吧，我觉得赢了！",

  ["kaiju"] = "开局",
  [":kaiju"] = "主公技，锁定技，当你的回合开始时，与你势力不同的武将需要交给你一张牌（没有牌则不用交），并视为对你使用一张【杀】。",
  ["$kaiju1"] = "不是啊，我在一对鬼的时候我在打什么打一对是一对是他4个9炸我我不输了吗？",

  ["~jianzihao"] = "好像又要倒下了……",
}


local houguoyu = General(extension, "houguoyu", "shu", 0, 999, General.Male)
houguoyu.hidden = true

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
}

return extension