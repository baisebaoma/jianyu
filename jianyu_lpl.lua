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
    return to_select.suit == Card.Spade or to_select.suit == Card.Club and player:hasSkill(self)
  end,
  view_as = function(self, to_select)
    if to_select.suit == Card.Club then 
      return Fk:cloneCard(to_select.name, Card.Diamond, to_select.number)
    end
    if to_select.suit == Card.Spade then 
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
-- 下面这玩意还没写好，先别动
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
-- jianzihao:addSkill(shengnu)
-- jianzihao:addSkill(zhuanhui)
jianzihao:addSkill(xizao)
-- jianzihao:addSkill(kaiju)


Fk:loadTranslationTable{
  ["jianzihao"] = "简自豪",

  ["hongwen"] = "红温",
  [":hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$hongwen1"] = "哼……",

  ["zouwei"] = "走位",
  [":zouwei"] = "锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。",
  ["$zouwei1"] = "冲刺，冲！",
  ["$zouwei2"] = "别杀我，我错了！",

  ["shengnu"] = "圣弩",
  [":shengnu"] = "锁定技，当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你获得此【诸葛连弩】。",
  ["$shengnu1"] = "让我们来猎杀那些陷入黑暗中的人吧！",

  ["zhuanhui"] = "转会",
  [":zhuanhui"] = "当你的体力值减少时，你可以变更势力。你无法变更为已经成为过的势力。",
  ["$zhuanhui1"] = "现在站在你面前的是S赛13冠王！",

  ["xizao"] = "洗澡",
  [":xizao"] = "限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$xizao1"] = "这游戏玩不玩无所谓了，洗澡去了！",
  ["$xizao2"] = "待我洗澡归来，又是乱杀之时！",

  ["kaiju"] = "开局",
  [":kaiju"] = "<strong>主公技</strong>，锁定技，当你的回合开始时，与你势力不同的武将需要交给你一张牌（没有牌则不用交），并视为对你使用一张【杀】。",
  ["$kaiju1"] = "从未有如此美妙的开局！",

  ["~jianzihao"] = "又没能……突破八强……",
}


local houguoyu = General(extension, "houguoyu", "shu", 0, 999, General.Male)
houguoyu.hidden = true

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
}

return extension