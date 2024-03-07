local extension = Package:new("jianyu_tg")
extension.extensionName = "jytest"

Fk:loadTranslationTable {
  ["jianyu_tg"] = [[简浴-集思广益]],
}

local function isFactor(a, b)
  return a ~= 0 and b ~= 0 and b % a == 0
end

local fenlv = fk.CreateTriggerSkill {
  name = "jy_fenlv",
  anim_type = "control",
  frequency = Skill.Compulsory,
  refresh_events = { fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_fenlv", data.card.number)
  end,
  events = { fk.CardUsing },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return (target == player and isFactor(data.card.number, player:getMark("@jy_fenlv"))) or
        isFactor(player:getMark("@jy_fenlv"), data.card.number)
  end,
  on_use = function(self, event, target, player, data)
    if target == player and isFactor(data.card.number, player:getMark("@jy_fenlv")) then
      player:drawCards(1, self.name)
    end
  end,
}
local fenlv_mod = fk.CreateTargetModSkill {
  name = "#jy_fenlv_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and isFactor(player:getMark("@jy_fenlv"), card.number)
  end,
}
fenlv:addRelatedSkill(fenlv_mod)

local function translateCardType(a)
  local t = {}
  t[Card.TypeBasic] = "基本牌"
  t[Card.TypeTrick] = "锦囊牌"
  t[Card.TypeEquip] = "装备牌"
  return t[a]
end

local zhunwang_mod = fk.CreateTriggerSkill {
  name = "#jy_zhunwang_mod",
  refresh_events = { fk.CardUsing },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) and translateCardType(data.card.type) == player:getMark("@jy_zhunwang") then
      player:broadcastSkillInvoke("jy_zhunwang")
      player.room:doAnimate("InvokeSkill", {
        name = "jy_zhunwang",
        player = player.id,
        skill_type = "control",
      })
    else
      player.room:setPlayerMark(player, "@jy_zhunwang", translateCardType(data.card.type))
    end
  end,
}
local zhunwang = fk.CreateTargetModSkill {
  name = "jy_zhunwang",
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(self) and translateCardType(card.type) == player:getMark("@jy_zhunwang")
  end,
}
zhunwang:addRelatedSkill(zhunwang_mod)

local zhitu = fk.CreateActiveSkill {
  name = "jy_zhitu",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) < 3
  end,
  card_num = 0,
  target_num = 0,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    local t = {}
    t["A"] = 1
    t["2"] = 2
    t["3"] = 3
    t["4"] = 4
    t["5"] = 5
    t["6"] = 6
    t["7"] = 7
    t["8"] = 8
    t["9"] = 9
    t["10"] = 10
    t["J"] = 11
    t["Q"] = 12
    t["K"] = 13
    local choices = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" }
    room:setPlayerMark(player, "@jy_fenlv",
      t[room:askForChoice(player, choices, self.name, "#jy_zhitu_ask")])
    player:drawCards(1, self.name)
  end,
}

-- local xuyu = General(extension, "jy__xuyu", "qun", 3, 3, General.Female)
-- xuyu:addSkill(zaisheng)
-- xuyu:addSkill(zhushe)

local peixiu = General(extension, "jy__peixiu", "qun", 3)
peixiu.subkingdom = "jin"
peixiu:addSkill(fenlv)
peixiu:addSkill(zhunwang)
peixiu:addSkill(zhitu)


Fk:loadTranslationTable {
  ["jy__xuyu"] = "絮雨",
  ["#jy__xuyu"] = "巡游医师",
  ["designer:jy__xuyu"] = "emo公主",
  ["cv:jy__xuyu"] = "刘十四",
  ["illustrator:jy__xuyu"] = "未知",
  ["~jy__xuyu"] = [[我熟悉这死亡的气息……]],

  ["jy_zaisheng"] = "再生",
  [":jy_zaisheng"] = [[每当一名角色不因使用而失去红色牌时，你可以令其回复1体力。若如此做，直到你下回合开始：每回合限一次，当该角色受到伤害后，你获得对其造成伤害的牌，并随机获得伤害来源手牌中一张伤害牌。]],
  ["$jy_zaisheng1"] = [[不要害怕。]],
  ["$jy_zaisheng2"] = [[让我来消除痛苦。]],

  ["jy_zhushe"] = "注射",
  [":jy_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制、无法响应；你造成伤害后，你令伤害目标回复等量体力并摸两张牌。]],
  ["$jy_zhushe1"] = [[准备好注射了。]],
  ["$jy_zhushe2"] = [[我的治疗是不会痛的。]],


  ["jy__peixiu"] = "简裴秀",
  ["#jy__peixiu"] = "晋图开秘",
  ["designer:jy__peixiu"] = "贾文和",
  ["cv:jy__peixiu"] = "暂无",
  -- ["illustrator:jy__peixiu"] = "官方",

  ["jy_fenlv"] = "分率",
  [":jy_fenlv"] = [[锁定技，你使用牌结算结束后记录此牌点数。你使用牌时，若此牌点数为〖分率〗记录点数的约数，你摸一张牌；你有已记录的点数，你使用点数为〖分率〗记录点数的倍数的牌无次数限制。]],
  ["@jy_fenlv"] = "分率",

  ["jy_zhunwang"] = "准望",
  [":jy_zhunwang"] = [[锁定技，你使用与你使用的上一张牌类型相同的牌无距离限制。]],
  ["@jy_zhunwang"] = "准望",

  ["jy_zhitu"] = "制图",
  [":jy_zhitu"] = [[出牌阶段限三次，你可以修改〖分率〗记录的点数，然后你摸一张牌。]],
  ["#jy_zhitu_ask"] = "修改“分率”",
}

return extension
