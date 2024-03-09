local extension = Package:new("jianyu_tg")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
  ["jianyu_tg"] = [[简浴-集思广益]],
}

-- local zaisheng = fk.CreateTriggerSkill {
--   name = "jy_zaisheng",
--   anim_type = "support",
--   events = { fk.AfterCardsMove, fk.Damaged },
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return false end
--     if event == fk.AfterCardsMove then
--       if player:usedSkillTimes(self.name, Player.HistoryRound) >= 1 then return false end
--       for _, move in ipairs(data) do
--         if move.moveReason ~= fk.ReasonUse and move.from then -- and move.moveVisible 可能需要加上技能描述里没有的moveVisible，因为如果是背面朝上的，你不知道这是红色，就不应该发动这个技能
--           for _, info in ipairs(move.moveInfo) do
--             if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
--                 Fk:getCardById(info.cardId).color == Card.Red then
--               data.jy_zaisheng_moveFrom = move.from
--               return true
--             end
--           end
--         end
--       end
--     else -- fk.Damaged
--       return target:getMark("@jy_zaisheng") ~= 0 and data.to:getMark("jy_zaisheng_triggered-round") == 0
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     if event == fk.AfterCardsMove then
--       return player.room:askForSkillInvoke(player, self.name, nil, "#jy_zaisheng_prompt::" .. data.jy_zaisheng_moveFrom)
--     else -- fk.Damaged
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.AfterCardsMove then
--       room:doIndicate(player.id, { data.jy_zaisheng_moveFrom }) -- 播放指示线，代表我给你上了buff
--       local jy_zaisheng_moveFrom = room:getPlayerById(data.jy_zaisheng_moveFrom)
--       room:recover({
--         who = jy_zaisheng_moveFrom,
--         num = 1,
--         recoverBy = player,
--         skillName = self.name,
--       })
--       room:setPlayerMark(jy_zaisheng_moveFrom, "@jy_zaisheng", "")
--     else -- fk.Damaged
--       if data.card then
--         local subcards = data.card:isVirtual() and data.card.subcards or { data.card.id }
--         if #subcards > 0 and table.every(subcards, function(id) return room:getCardArea(id) == Card.Processing end) then
--           room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
--         end
--       end
--       -- 该机制因过强已移除
--       -- if data.from then
--       --   local cards = {}
--       --   for _, i in ipairs(data.from:getCardIds(Player.Hand)) do
--       --     if Fk:getCardById(i).is_damage_card then
--       --       table.insert(cards, i)
--       --     end
--       --   end
--       --   if #cards > 0 then
--       --     room:obtainCard(player.id, cards[math.random(#cards)], true, fk.ReasonJustMove)
--       --   end
--       -- end
--       room:setPlayerMark(data.to, "jy_zaisheng_triggered-round", 1)
--     end
--   end,
--   refresh_events = { fk.EventPhaseChanging },
--   can_refresh = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and
--         data.to == Player.Start
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     for _, p in ipairs(room:getAlivePlayers()) do
--       if p:getMark("@jy_zaisheng") ~= 0 then
--         room:setPlayerMark(p, "@jy_zaisheng", 0)
--       end
--     end
--   end,
-- }

local zaisheng = fk.CreateTriggerSkill {
  name = "jy_zaisheng",
  anim_type = "support",
  events = { fk.AfterCardsMove, fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    local room = player.room
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.moveReason ~= fk.ReasonUse and move.from then -- and move.moveVisible 可能需要加上技能描述里没有的moveVisible，因为如果是背面朝上的，你不知道这是红色，就不应该发动这个技能
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                Fk:getCardById(info.cardId).color == Card.Red then
              data.jy_zaisheng_moveFrom = move.from
              return room:getPlayerById(move.from):getMark("@jy_zaisheng") ~= 0
            end
          end
        end
      end
    else                                         -- fk.Damaged
      return target:getMark("@jy_zaisheng") ~= 0 -- and data.to:getMark("jy_zaisheng_triggered-round") == 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      return player.room:askForSkillInvoke(player, self.name, nil, "#jy_zaisheng_prompt::" .. data.jy_zaisheng_moveFrom)
    else -- fk.Damaged
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove then
      room:doIndicate(player.id, { data.jy_zaisheng_moveFrom }) -- 播放指示线，代表我给你上了buff
      local jy_zaisheng_moveFrom = room:getPlayerById(data.jy_zaisheng_moveFrom)
      room:recover({
        who = jy_zaisheng_moveFrom,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
      room:addPlayerMark(jy_zaisheng_moveFrom, "@jy_zaisheng")
    else -- fk.Damaged
      if data.card then
        local subcards = data.card:isVirtual() and data.card.subcards or { data.card.id }
        if #subcards > 0 and table.every(subcards, function(id) return room:getCardArea(id) == Card.Processing end) then
          room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
        end
      end
      room:addPlayerMark(data.to, "@jy_zaisheng", -1)
      -- room:setPlayerMark(data.to, "jy_zaisheng_triggered-round", 1)
    end
  end,
}

local zhushe = fk.CreateTriggerSkill {
  name = "jy_zhushe",
  anim_type = 'drawcard',
  events = { fk.EventPhaseStart, fk.CardUsing, fk.Damage },
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Start
      elseif event == fk.CardUsing then
        return player:getMark("@jy_zhushe-turn") ~= 0
      else -- fk.Damage
        return player:getMark("@jy_zhushe-turn") ~= 0 and not data.to.dead
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player.room:askForSkillInvoke(player, self.name)
    else -- two events
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:broadcastSkillInvoke(self.name)
      room:doAnimate("InvokeSkill", {
        name = self.name,
        player = player.id,
        skill_type = "drawcard",
      })
      local cards = room:askForCard(player, 1, 999, true, self.name, true, nil, "#jy_zhushe_prompt", nil, true)
      if #cards > 0 then
        room:throwCard(cards, self.name, player, player)
        if player:isAlive() then
          player:drawCards(#cards, self.name)
          room:setPlayerMark(player, "@jy_zhushe-turn", "")
        end
      end
    elseif event == fk.CardUsing then
      -- player:broadcastSkillInvoke(self.name)  -- 这个就别播语音了，不然无法响应+造成伤害一张牌播两遍语音很吵
      room:doAnimate("InvokeSkill", {
        name = self.name,
        player = player.id,
        skill_type = "offensive",
      })
      data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
    else              -- fk.Damaged
      room:delay(200) -- 不加delay的话，在放AOE卡牌时一瞬间有太多事件，会出现卡顿
      player:broadcastSkillInvoke(self.name)
      room:doAnimate("InvokeSkill", {
        name = self.name,
        player = player.id,
        skill_type = "drawcard",
      })
      room:recover({
        who = data.to,
        num = data.damage,
        recoverBy = player,
        skillName = self.name,
      })
      data.to:drawCards(2, self.name)
    end
  end,
}
local zhushe_mod = fk.CreateTargetModSkill {
  name = "#jy_zhushe_prompt_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and player:getMark("@jy_zhushe-turn") ~= 0
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(self) and player:getMark("@jy_zhushe-turn") ~= 0
  end,
}
zhushe:addRelatedSkill(zhushe_mod)

local xuyu = General(extension, "jy__xuyu", "qun", 3, 3, General.Female)
xuyu:addSkill(zaisheng)
xuyu:addSkill(zhushe)

Fk:loadTranslationTable {
  ["jy__xuyu"] = "絮雨",
  ["#jy__xuyu"] = "巡游医师",
  ["designer:jy__xuyu"] = "emo公主",
  ["cv:jy__xuyu"] = "刘十四",
  ["illustrator:jy__xuyu"] = "未知",
  ["~jy__xuyu"] = [[我熟悉这死亡的气息……]],

  ["jy_zaisheng"] = "再生",
  ["@jy_zaisheng"] = "再生",
  ["#jy_zaisheng_prompt"] = [[是否发动〖再生〗令 %dest 回复一点体力，然后你可以获得下一张对其造成伤害的牌？]],
  [":jy_zaisheng"] = [[当一名没有“再生”标记的角色不因使用而失去红色牌时，你可以令其回复一点体力。若如此做，其获得“再生”。当有“再生”的角色受到伤害后，其移除“再生”，你获得对其造成伤害的牌。]],
  -- [":jy_zaisheng"] = [[（原稿，因过强已被移除）当一名角色不因使用而失去红色牌时，你可以令其回复一点体力。若如此做，直到你的下回合开始：每回合限一次，当该角色受到伤害后，你获得对其造成伤害的牌，并随机获得伤害来源手牌中一张伤害牌。]],
  ["$jy_zaisheng1"] = [[不要害怕。]],
  ["$jy_zaisheng2"] = [[让我来消除痛苦。]],

  ["jy_zhushe"] = "注射",
  ["@jy_zhushe-turn"] = "注射",
  ["#jy_zhushe_prompt"] = "你可以重铸任意张牌，然后本回合获得〖注射〗的效果",
  [":jy_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制、不可被响应；你造成伤害后，你令伤害目标回复等量体力并摸两张牌。]],
  ["$jy_zhushe1"] = [[准备好注射了。]],
  ["$jy_zhushe2"] = [[我的治疗是不会痛的。]],
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
    return target == player and
        (isFactor(data.card.number, player:getMark("@jy_fenlv")) or
          isFactor(player:getMark("@jy_fenlv"), data.card.number))
  end,
  on_use = function(self, event, target, player, data)
    if isFactor(data.card.number, player:getMark("@jy_fenlv")) then
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

local peixiu = General(extension, "jy__peixiu", "qun", 3)
peixiu.subkingdom = "jin"
peixiu:addSkill(fenlv)
peixiu:addSkill(zhunwang)
peixiu:addSkill(zhitu)
peixiu:addSkill("juezhi")


Fk:loadTranslationTable {
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
