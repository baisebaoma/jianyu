---@diagnostic disable: undefined-field
local extension = Package:new("jianyu_tg")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu_tg"] = [[简浴-投稿]],
}

local jy__tangniu = General(extension, "jy__tangniu", "qun", 1, 1, General.Female)
jy__tangniu.hidden = true

-- 主函数啥也不做，只是为了承载下面的
local jy_budeng = fk.CreateTriggerSkill {
  name = "jy_budeng",
}
-- 不能受到伤害
local jy_budeng_damaged = fk.CreateTriggerSkill {
  mute = true,
  name = "#jy_budeng_damaged",
  frequency = Skill.Compulsory,
  events = { fk.DamageInflicted },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return target == player
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("jy_budeng")
    room:notifySkillInvoked(player, "jy_budeng", "defensive")

    return true
  end,
}
-- 跳过弃牌阶段
local jy_budeng_discard = fk.CreateTriggerSkill {
  mute = true,
  frequency = Skill.Compulsory,
  name = "#jy_budeng_discard",
  anim_type = "defensive",
  events = { fk.EventPhaseChanging },
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.to == Player.Discard then
      local room = player.room
      local logic = room.logic
      local e = logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      if e == nil then return false end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("jy_budeng")
    room:notifySkillInvoked(player, "jy_budeng", "defensive")

    return true
  end
}
-- 回合外有人使你摸了牌时你流失体力
local jy_budeng_card = fk.CreateTriggerSkill {
  mute = true,
  frequency = Skill.Compulsory,
  name = "#jy_budeng_card",
  anim_type = "offensive",
  events = { fk.AfterCardsMove },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if player.phase == Player.NotActive then
      for _, move in ipairs(data) do
        if move.to == player.id and move.from ~= player.id then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("jy_budeng")
    room:notifySkillInvoked(player, "jy_budeng", "defensive")

    local room = player.room
    -- room:loseHp(room.current, 1)
    room:loseHp(player, player.hp)
  end
}
jy_budeng:addRelatedSkill(jy_budeng_damaged)
jy_budeng:addRelatedSkill(jy_budeng_discard)
jy_budeng:addRelatedSkill(jy_budeng_card)

local jy_duili = fk.CreateTriggerSkill {
  name = "jy_duili",
  events = { fk.TargetSpecified },
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and
        data.card and data.card.trueName == "slash" then
      local target = player.room:getPlayerById(data.to)
      return target.gender == General.Male
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = player.room:getPlayerById(data.to)
    if to:isKongcheng() then
      player:drawCards(1, self.name)
    else
      local result = room:askForDiscard(to, 1, 1, false, self.name, true, ".", "#double_swords-invoke:" .. player.id)
      if #result == 0 then
        player:drawCards(1, self.name)
      end
    end
  end,
}

jy__tangniu:addSkill(jy_budeng)
jy__tangniu:addSkill(jy_duili)

Fk:loadTranslationTable {
  ["jy__tangniu"] = [[唐妞]],
  ["#jy__tangniu"] = "版本答案",
  ["designer:jy__tangniu"] = "考公专家 & 群友",
  ["cv:jy__tangniu"] = "暂无",
  ["illustrator:jy__tangniu"] = "看不腻的妞",

  ["jy_budeng"] = "不等",
  [":jy_budeng"] = [[锁定技，防止你受到的伤害；你跳过弃牌阶段；你于其他角色的回合内获得牌（包括有牌进入你的判定区）时，你失去所有体力。<br><font color="grey">受到伤害≠我掉血；弃牌阶段≠我要弃；接受礼物≠我同意。</font>]],

  ["jy_duili"] = "对立",
  [":jy_duili"] = [[当你指定男性角色为【杀】的目标后，你可以令其选择一项：弃置一张手牌，或令你摸一张牌。]],
}

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
              local from = room:getPlayerById(move.from)
              return from:getMark("@jy_zaisheng") == 0 and not from.dead -- 没有再生标记，而且没有死
            end
          end
        end
      end
    else -- fk.Damaged
      return target:getMark("@jy_zaisheng") ~= 0 and
          not target.dead
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
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|heart,diamond",
      }
      room:judge(judge)
      if judge.card.color == Card.Red then
        room:doIndicate(player.id, { data.jy_zaisheng_moveFrom }) -- 播放指示线，代表我给你上了buff
        local jy_zaisheng_moveFrom = room:getPlayerById(data.jy_zaisheng_moveFrom)
        room:recover({
          who = jy_zaisheng_moveFrom,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
        room:setPlayerMark(jy_zaisheng_moveFrom, "@jy_zaisheng", "")
      end
    else -- fk.Damaged
      if data.card then
        local subcards = data.card:isVirtual() and data.card.subcards or { data.card.id }
        if #subcards > 0 and table.every(subcards, function(id) return room:getCardArea(id) == Card.Processing end) then
          room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
        end
      end
      room:setPlayerMark(data.to, "@jy_zaisheng", 0)
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
      room:notifySkillInvoked(player, self.name, "drawcard")
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
      room:notifySkillInvoked(player, self.name, "drawcard")
      data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
    else              -- fk.Damaged
      room:delay(200) -- 不加delay的话，在放AOE卡牌时一瞬间有太多事件，会出现卡顿
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:recover({
        who = data.to,
        num = data.damage,
        recoverBy = player,
        skillName = self.name,
      })
      data.to:drawCards(data.damage, self.name)
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
  ["#jy_zaisheng_prompt"] = [[是否发动〖再生〗进行判定，若成功则 %dest 回复一点体力且你获得下一张对其造成伤害的牌？]],
  [":jy_zaisheng"] = [[当一名没有“再生”标记的角色不因使用而失去红色牌时，你可以判定，若为红色，其回复一点体力并获得“再生”。当一名有“再生”的角色受到伤害后，你获得对其造成伤害的牌，然后其移除“再生”。]],
  ["$jy_zaisheng1"] = [[不要害怕。]],
  ["$jy_zaisheng2"] = [[让我来消除痛苦。]],

  ["jy_zhushe"] = "注射",
  ["@jy_zhushe-turn"] = "注射",
  ["#jy_zhushe_prompt"] = "你可以重铸任意张牌，然后本回合获得〖注射〗的效果",
  [":jy_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制且不可被响应；你造成伤害后，伤害目标回复X点体力并摸X张牌，X为伤害值。]],
  ["$jy_zhushe1"] = [[准备好注射了。]],
  ["$jy_zhushe2"] = [[我的治疗是不会痛的。]],
}

local function isFactor(a, b)
  return a ~= 0 and b ~= 0 and b % a == 0
end

local xingtu = fk.CreateActiveSkill {
  name = "jy_xingtu",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) < 5
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
    room:setPlayerMark(player, "@jy_xingtu",
      t[room:askForChoice(player, choices, self.name, "#jy_xingtu_ask")])
  end,
}
local xingtu_draw = fk.CreateTriggerSkill {
  name = "#jy_xingtu_draw",
  mute = true,
  anim_type = "control",
  frequency = Skill.Compulsory,
  refresh_events = { fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_xingtu", data.card.number)
  end,
  events = { fk.CardUsing },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return target == player and
        isFactor(data.card.number, player:getMark("@jy_xingtu"))
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke(xingtu.name)
    room:notifySkillInvoked(player, xingtu.name, "drawcard")
    player:drawCards(1, self.name)
  end,
}
local xingtu_mod = fk.CreateTargetModSkill {
  name = "#jy_xingtu_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and isFactor(player:getMark("@jy_xingtu"), card.number)
  end,
}
xingtu:addRelatedSkill(xingtu_draw)
xingtu:addRelatedSkill(xingtu_mod)

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
      room:notifySkillInvoked(player, "jy_zhunwang", "drawcard")
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

local peixiu = General(extension, "jy__peixiu", "qun", 3)
peixiu.subkingdom = "jin"
peixiu:addSkill(xingtu)
peixiu:addSkill(zhunwang)

Fk:loadTranslationTable {
  ["jy__peixiu"] = "简裴秀",
  ["#jy__peixiu"] = "禁图开秘",
  ["designer:jy__peixiu"] = "贾文和",

  ["jy_xingtu"] = "行图",
  [":jy_xingtu"] = [[锁定技，你使用牌时，若此牌的点数是X（X为你使用的上一张牌的点数）的约数，你摸一张牌。你使用点数为X的倍数的牌无次数限制。出牌阶段限五次，你可以修改X。]],
  ["@jy_xingtu"] = "行图",
  ["#jy_xingtu_ask"] = "修改“行图”",

  ["jy_zhunwang"] = "准望",
  [":jy_zhunwang"] = [[锁定技，你使用与你使用的上一张牌类型相同的牌无距离限制。]],
  ["@jy_zhunwang"] = "准望",
}

local xiuxing = fk.CreateTargetModSkill {
  name = "jy_xiuxing",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self)
  end,
}
-- 祈写的
local mumang = fk.CreateAttackRangeSkill {
  name = "#jy_xiuxing_mumang",
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      if from:getMark("jy_mumang_a-turn") > 0 then
        return -from:getMark("jy_mumang_a-turn")
      elseif from:getMark("jy_mumang_b-turn") > 0 then
        return from:getMark("jy_mumang_b-turn")
      end
    end
  end,
}
local mumang_trigger = fk.CreateTriggerSkill {
  name = "#jy_xiuxing_mumang_trigger",
  mute = true,
  refresh_events = { fk.EventPhaseStart, fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Start and player:getAttackRange() ~= 1
      else
        return data.card.sub_type == Card.SubtypeWeapon or data.card.sub_type == Card.SubtypeTreasure
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      if player:getAttackRange() > 1 then
        room:setPlayerMark(player, "jy_mumang_a-turn", player:getAttackRange() - 1)
      elseif player:getAttackRange() == 0 then
        room:setPlayerMark(player, "jy_mumang_b-turn", 1)
      end
    else
      room:setPlayerMark(player, "jy_mumang_a-turn", 0)
      room:setPlayerMark(player, "jy_mumang_b-turn", 0)
      if player:getAttackRange() > 1 then
        room:setPlayerMark(player, "jy_mumang_a-turn", player:getAttackRange() - 1)
      elseif player:getAttackRange() == 0 then
        room:setPlayerMark(player, "jy_mumang_b-turn", 1)
      end
    end
  end,
}
local cancel = fk.CreateProhibitSkill {
  name = "#jy_xiuxing_cancel",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    return from:hasSkill(self) and from:distanceTo(to) > from:getAttackRange()
  end,
}

-- mumang:addRelatedSkill(mumang_trigger)
xiuxing:addRelatedSkill(mumang)
xiuxing:addRelatedSkill(mumang_trigger)
xiuxing:addRelatedSkill(cancel)

local zitai = fk.CreateTriggerSkill {
  name = "jy_zitai",
  anim_type = "switch",
  switch_skill_name = "jy_zitai",
  frequency = Skill.Compulsory,
  events = { fk.DamageInflicted },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (data.to == player or data.from == player)
  end,
  on_use = function(self, event, target, player, data)
    -- 我好像懂了，转换技是on_use之前就会转换
    if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|heart,diamond",
      }
      player.room:judge(judge)
      if judge.card.color == Card.Red then
        player:drawCards(2, self.name)
        return true
      end
    else
      data.damage = data.damage + 1
    end
    player:drawCards(2, self.name)
  end
}

local yujian = fk.CreateTriggerSkill {
  name = "jy_yujian",
  anim_type = "control",
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askForGuanxing(player, room:getNCards(math.min(5, room:getTag("RoundCount"))))
  end,
}

local guanzhe = General(extension, "jy__guanzhe", "jin", 3, 3, General.Female)
guanzhe:addSkill(xiuxing)
guanzhe:addSkill(zitai)
guanzhe:addSkill(yujian)

Fk:loadTranslationTable {
  ["jy__guanzhe"] = [[观者]],
  ["#jy__guanzhe"] = [[目盲的修行者]],
  ["designer:jy__guanzhe"] = [[Kasa]],
  ["cv:jy__guanzhe"] = [[暂无]],
  ["illustrator:jy__guanzhe"] = [[未知]],

  ["jy_xiuxing"] = [[修行]],
  [":jy_xiuxing"] = [[锁定技，你使用牌无次数限制；你攻击范围外的角色不是你使用牌的合法目标；你的攻击范围始终为1。]],

  ["jy_zitai"] = [[姿态]],
  [":jy_zitai"] = [[转换技，锁定技，当你造成或受到伤害时，阳：你判定，若为红色，防止之；阴：该伤害+1。然后你摸两张牌。]],

  ["jy_yujian"] = [[预见]],
  [":jy_yujian"] = [[准备阶段开始时，你可以观看牌堆顶的X张牌，然后将任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。（X为游戏轮数且至多为5）。]],
  -- [":jy_yujian"] = [[准备阶段开始时，你可以观看牌堆顶的X张牌，然后弃置其中任意数量的牌，将其余的牌依次放回牌堆顶。（X为游戏轮数且至多为5）]],
}

local tiandu = fk.CreateTriggerSkill {
  name = "jy_tiandu",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  mod_target_filter = Util.TrueFunc,
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self) and target == player and player.phase == Player.Start then
      for _, p in ipairs(room:getOtherPlayers(player, true)) do
        if p.hp < player.hp then return true end -- 只要找到一个比我血还少的，就可以触发了
      end
      return false
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage({
      to = player,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name,
    })
  end,
}

-- 周不疑：一名角色的结束阶段，若其本回合未造成伤害，你可以声明一种普通锦囊牌（每轮每种牌名限一次），其可以将一张牌当你声明的牌使用
local yiji = fk.CreateTriggerSkill {
  name = "jy_yiji",
  anim_type = "support",
  events = { fk.Damaged },
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for _ = 1, data.damage do
      if self.cancel_cost or not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = player

    -- 让他选择一个牌名
    local mark = player:getMark("jy_yiji_names")
    if type(mark) ~= "table" then
      mark = {}
      for _, id in ipairs(Fk:getAllCardIds()) do
        local card = Fk:getCardById(id)
        if card:isCommonTrick() and not card.is_derived and not card.is_damage_card then
          table.insertIfNeed(mark, card.name)
        end
      end
      room:setPlayerMark(player, "jy_yiji_names", mark)
    end
    local mark2 = player:getMark("@$jy_yiji-round")
    if mark2 == 0 then mark2 = {} end
    local names, choices = {}, {}
    table.insert(names, "#jy_yiji_draw2")
    table.insert(choices, "#jy_yiji_draw2")
    for _, name in ipairs(mark) do
      local card = Fk:cloneCard(name)
      card.skillName = self.name
      if target:canUse(card) and not target:prohibitUse(card) then
        table.insert(names, name)
        if not table.contains(mark2, name) then
          table.insert(choices, name)
        end
      end
    end
    local choice = room:askForChoice(to, choices, self.name, "#jy_yiji_prompt", false, names)
    if choice == "#jy_yiji_draw2" then
      to:drawCards(2, self.name)
      return true
    else
      room:doIndicate(player.id, { to.id })
    end

    -- 问他用哪个牌，并且要他用
    mark = player:getMark("@$jy_yiji-round")
    if mark == 0 then mark = {} end
    table.insert(mark, choice)
    room:setPlayerMark(player, "@$jy_yiji-round", mark)
    room:doIndicate(player.id, { target.id })
    room:setPlayerMark(to, "jy_yiji-tmp", choice)

    local success, dat = room:askForUseActiveSkill(to, "#jy_yiji_viewas", "#jy_yiji-use:::" .. Fk:translate(choice))
    room:setPlayerMark(to, "jy_yiji-tmp", 0)
    if success then
      local card = Fk:cloneCard(choice)
      card:addSubcards(dat.cards)
      card.skillName = self.name
      room:useCard {
        from = to.id,
        tos = table.map(dat.targets, function(p) return { p } end),
        card = card,
      }
      room:setPlayerMark(to, "jy_yiji-tmp", 0)
    end
  end,
}
local yiji_viewas = fk.CreateViewAsSkill {
  name = "#jy_yiji_viewas",
  anim_type = "offensive",
  card_filter = function(self, to_select, selected)
    if Self:getMark("jy_yiji-tmp") ~= 0 then
      if #selected == 0 then return true end
      return false
    end
  end,
  view_as = function(self, cards)
    if #cards == 1 then
      local card = Fk:cloneCard(Self:getMark("jy_yiji-tmp"))
      card:addSubcard(cards[1])
      card.skillName = "jy_yiji"
      return card
    end
  end,
}
yiji:addRelatedSkill(yiji_viewas)

-- 董允舍宴
-- 目前已经改成了经典版本，所以先这样

-- local yingcai = fk.CreateTriggerSkill {
--   name = "jy_yingcai",
--   anim_type = "control",
--   events = { fk.TargetConfirming },
--   can_trigger = function(self, event, target, player, data)
--     if data.from == player.id and player:hasSkill(self) and data.card:isCommonTrick() then -- 这一段是sheyan的代码，但是因为TargetConfirming是对每一个人都生效，所以当你加了一个新目标，又会触发这个，导致触发多次，和原来的不一样。
--       if player:getMark("jy_yingcai_used") ~= 0 then return false end
--       local room = player.room
--       local targets = U.getUseExtraTargets(room, data, true, true)
--       local origin_targets = U.getActualUseTargets(room, data, event)
--       if #origin_targets > 1 then
--         table.insertTable(targets, origin_targets)
--       end
--       if #targets > 0 then
--         self.cost_data = targets
--         return true
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local ret = false
--     local plist = room:askForChoosePlayers(player, self.cost_data, 1, 1,
--       "#jy_yingcai-choose:::" .. data.card:toLogString(), self.name, true)
--     if #plist > 0 then -- 如果他选择了目标，那就发动
--       self.cost_data = plist[1]
--       ret = true
--     end
--     room:setPlayerMark(player, "jy_yingcai_used", true)
--     return ret
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if table.contains(AimGroup:getAllTargets(data.tos), self.cost_data) then
--       AimGroup:cancelTarget(data, self.cost_data)
--       return self.cost_data == player.id
--     else
--       AimGroup:addTargets(player.room, data, self.cost_data)
--     end
--   end,
--   refresh_events = { fk.CardUseFinished },
--   can_refresh = function(self, event, target, player, data)
--     return player:hasSkill(self) and player:getMark("jy_yingcai_used") ~= 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     player.room:setPlayerMark(player, "jy_yingcai_used", 0)
--   end,
-- }

local guojia = General(extension, "jy__guojia", "wei", 3)

guojia:addSkill(tiandu)
guojia:addSkill(yiji)
guojia:addSkill("jy_trad_yingcai")

Fk:loadTranslationTable {
  ["jy__guojia"] = [[简郭嘉]],
  ["#jy__guojia"] = [[识人心智]],
  ["designer:jy__guojia"] = [[rolin]],
  ["cv:jy__guojia"] = [[暂无]],
  ["illustrator:jy__guojia"] = [[未知]],
  ["$jy__guojia"] = [[咳咳……]],

  ["jy_tiandu"] = [[天妒]],
  [":jy_tiandu"] = [[锁定技，回合开始时，若你体力值不为全场最低，你受到一点无来源伤害。]],
  ["$jy_tiandu1"] = [[就这样吧。]],
  ["$jy_tiandu2"] = [[哦？]],

  ["jy_yiji"] = [[遗计]],
  [":jy_yiji"] = [[当你受到一点伤害时，你可以选择一项：摸两张牌；将一张牌当一张本轮未以此法使用过的非伤害类普通锦囊牌使用。]],
  ["#jy_yiji_prompt"] = [[遗计：你可以摸两张牌，或将一张牌当一张本轮未以此法使用过的非伤害类普通锦囊牌使用]],
  ["#jy_yiji-use"] = [[遗计：你可以将一张牌当 %arg 使用]],
  ["@$jy_yiji-round"] = [[遗计]],
  ["#jy_yiji_viewas"] = [[遗计]],
  ["#jy_yiji_draw2"] = [[<font color="gold">摸两张牌</font>]],
  ["$jy_yiji1"] = [[也好。]],
  ["$jy_yiji2"] = [[罢了。]],

  -- ["jy_yingcai"] = [[英才]],
  -- [":jy_yingcai"] = [[当你使用普通锦囊牌时，你可以为此牌增加或减少一个目标（无距离限制，目标数至少为1）。]],
  -- ["#jy_yingcai-choose"] = "英才：为 %arg 增加/减少一个目标",
}

local yangbai = fk.CreateTriggerSkill {
  name = "jy_yangbai",
  anim_type = "defensive",
  events = { fk.EventPhaseEnd, fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.faceup then
      if event == fk.EventPhaseEnd then
        return player.phase == Player.Finish
      else
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if not player.dead then
      player:turnOver()
      player:drawCards(3, self.name)
    end
  end,
}

local taoqiu = fk.CreateTriggerSkill {
  name = "jy_taoqiu",
  anim_type = "offensive",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and
        target.phase == Player.Finish and
        not player.faceup
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "#jy_taoqiu_viewas", "#jy_taoqiu-use", true,
      { bypass_distances = true })
    if success then
      local card = Fk:cloneCard("slash")
      card:addSubcards(dat.cards)
      card.skillName = self.name
      local use = {
        from = player.id,
        tos = table.map(dat.targets, function(p) return { p } end),
        card = card,
        extraData = { bypass_distances = true },
      }
      room:useCard(use)
      if use.damageDealt then
        player:turnOver()
      end
    end
  end,
}
local taoqiu_viewas = fk.CreateViewAsSkill {
  name = "#jy_taoqiu_viewas",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return true
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")

    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
taoqiu:addRelatedSkill(taoqiu_viewas)

local hbrz = General(extension, "jy__hbrz", "shu", 4, 4, General.Female)
hbrz:addSkill(yangbai)
hbrz:addSkill(taoqiu)

Fk:loadTranslationTable {
  ["jy__hbrz"] = [[狐坂若藻]],
  ["#jy__hbrz"] = [[灾厄之狐]],
  ["designer:jy__hbrz"] = [[白洲]],
  ["cv:jy__hbrz"] = [[无]],
  ["illustrator:jy__hbrz"] = [[Nexon]],

  ["jy_yangbai"] = [[佯败]],
  [":jy_yangbai"] = [[结束阶段或你受到伤害后，若你的武将牌正面朝上，你可以翻面并摸三张牌。]],

  ["jy_taoqiu"] = [[逃囚]],
  [":jy_taoqiu"] = [[其他角色的结束阶段，若你的武将牌背面朝上，你可以将一张牌当无距离限制的【杀】使用。若此【杀】造成伤害，你翻面。]],
  ["#jy_taoqiu-use"] = [[逃囚：你可以将一张牌当无距离限制的【杀】使用，若造成伤害，你翻面]],
  ["#jy_taoqiu_viewas"] = [[逃囚]],
}

local jianyan = fk.CreateTriggerSkill {
  name = "jy_jianyan",
  events = { fk.CardUsing },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target:getMark("jy_jianyan-turn") == 1 and target.phase ~= Player.NotActive and
        (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and data.card.is_damage_card
  end,
  on_use = function(self, event, target, player, data)
    data.card.is_jy_jianyan = true
  end,
  refresh_events = { fk.Damaged, fk.CardUsing },
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Damaged then
        return data.card and data.card.is_jy_jianyan
      else
        return target.phase ~= Player.NotActive and
            (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and data.card.is_damage_card
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.Damaged then player:drawCards(data.damage) else player.room:addPlayerMark(target, "jy_jianyan-turn") end
  end,
}

local jimin = fk.CreateTriggerSkill {
  name = "jy_jimin",
  events = { fk.TargetConfirmed },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.to == player.id and
        player.room:getPlayerById(data.from):getMark("jy_jimin") == 0 and
        data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    -- 取消你自己当做目标
    table.insertIfNeed(data.nullifiedTargets, player.id)
    player.room:setPlayerMark(player.room:getPlayerById(data.from), "jy_jimin", true)
    player:drawCards(2, self.name)
  end,
}

local luotong = General(extension, "jy__luotong", "wu", 4)
luotong:addSkill(jianyan)
luotong:addSkill(jimin)

Fk:loadTranslationTable {
  ["jy__luotong"] = [[简骆统]],

  ["jy_jianyan"] = [[谏言]],
  [":jy_jianyan"] = [[锁定技，一名角色于其回合内首次使用伤害类基本牌或普通锦囊牌时，该牌每造成一点伤害，你摸一张牌。]],

  ["jy_jimin"] = [[济民]],
  [":jy_jimin"] = [[锁定技，每名角色限一次，一名角色使用【杀】指定你为目标时，该牌对你无效，然后你摸两张牌。]],
}

-- TODO：还没写
-- local baoyang = fk.CreateActiveSkill {
--   name = "jy_baoyang",
--   expand_pile = function() return U.getMark(Self, "jy_baoyang_cards") end,
--   card_filter = function(self, to_select, selected)
--     if #selected > 0 then return false end
--     if not table.contains(U.getMark(Self, "jy_baoyang_cards"), to_select) then return false end
--     local target = table.find(Fk:currentRoom().alive_players, function(p) return p:getMark("@@jy_baoyang-turn") > 0 end)
--     if not target then return end
--     local card = Fk:getCardById(to_select)
--     return target:canUse(card) and not target:prohibitUse(card)
--   end,
--   target_filter = function(self, to_select, selected, selected_cards)
--     if #selected_cards ~= 1 then return false end
--     local card = Fk:getCardById(selected_cards[1])
--     local card_skill = card.skill
--     local room = Fk:currentRoom()
--     local target = table.find(room.alive_players, function(p) return p:getMark("@@jy_baoyang-turn") > 0 end)
--     if not target then return end
--     if card_skill:getMinTargetNum() == 0 or #selected >= card_skill:getMaxTargetNum(target, card) then return false end
--     return not target:isProhibited(room:getPlayerById(to_select), card) and
--         card_skill:modTargetFilter(to_select, selected, target.id, card, true)
--   end,
--   feasible = function(self, selected, selected_cards)
--     if #selected_cards ~= 1 then return false end
--     local card = Fk:getCardById(selected_cards[1])
--     local card_skill = card.skill
--     local target = table.find(Fk:currentRoom().alive_players, function(p) return p:getMark("@@jy_baoyang-turn") > 0 end)
--     if not target then return end
--     return #selected >= card_skill:getMinTargetNum() and #selected <= card_skill:getMaxTargetNum(target, card)
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = table.find(room.alive_players, function(p) return p:getMark("@@jy_baoyang-turn") > 0 end)
--     if not target then return end
--     room:useCard({
--       from = target.id,
--       tos = table.map(effect.tos, function(pid) return { pid } end),
--       card = Fk:getCardById(effect.cards[1]),
--       extraUse = true,
--     })
--   end,
-- }
-- local baoyang_trigger = fk.CreateTriggerSkill {
--   name = "#jy_baoyang_trigger",
--   events = { fk.TurnStart },
--   frequency = Skill.Compulsory,
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and target == player
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local targets = room:getOtherPlayers(player)
--     if #targets > 0 then
--       local to = table.random(targets)
--       room:setPlayerMark(to, "@@jy_baoyang-turn", 1)
--     end
--   end,

--   refresh_events = { fk.StartPlayCard },
--   can_refresh = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self)
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     local ids = {}
--     local to = table.find(room.alive_players, function(p) return p:getMark("@@jy_baoyang-turn") > 0 end)
--     if to then
--       ids = to.player_cards[Player.Hand]
--     end
--     room:setPlayerMark(player, "jy_baoyang_cards", ids)
--   end,
-- }
-- baoyang:addRelatedSkill(baoyang_trigger)

local function zhijinShow(suit, number)
  if type(suit) ~= "number" or type(number) ~= "number" then
    return ""
  end
  local suits = {}
  suits[Card.Spade] = [[♠]]
  suits[Card.Heart] = [[<font color="red">♥</font>]]
  suits[Card.Club] = [[♣]]
  suits[Card.Diamond] = [[<font color="red">♦</font>]]
  if suits[suit] then
    return suits[suit] .. number
  end
  return ""
end

local zhijin = fk.CreateTriggerSkill {
  name = "jy_zhijin",
  anim_type = "drawcard",
  events = { fk.EventPhaseStart, fk.CardUsing },
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Play
      else
        return not data.card:isVirtual() and data.card.suit == player:getMark("jy_zhijin_suit-phase") and data.card.suit and
            data.card.number
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player.room:askForSkillInvoke(player, self.name)
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local judge = {
        who = player,
        reason = self.name,
      }
      room:judge(judge)
      room:setPlayerMark(player, "jy_zhijin_card-phase", judge.card.number)
      room:setPlayerMark(player, "jy_zhijin_suit-phase", judge.card.suit)
      room:setPlayerMark(player, "@jy_zhijin-phase", zhijinShow(judge.card.suit, judge.card.number))
    else
      player:drawCards(2, self.name)
    end
  end,
  refresh_events = { fk.CardUsing },
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      return data.card.type ~= Card.TypeEquip
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "jy_zhijin_card-phase", -1)
    player.room:setPlayerMark(player, "@jy_zhijin-phase",
      zhijinShow(player:getMark("jy_zhijin_suit-phase"), player:getMark("jy_zhijin_card-phase")))
  end
}
local zhijin_prohibit = fk.CreateProhibitSkill {
  name = "#jy_zhijin_prohibit",
  frequency = Skill.Compulsory,
  prohibit_use = function(self, player, card)
    return player:hasSkill(self) and player:getMark("jy_zhijin_card-phase") <= 0 and card.type ~= Card.TypeEquip
  end,
}
local zhijin_mod = fk.CreateTargetModSkill {
  name = "#jy_zhijin_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and card.suit == player:getMark("jy_zhijin_suit-phase") and to
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(self) and card.suit == player:getMark("jy_zhijin_suit-phase") and to
  end,
}
zhijin:addRelatedSkill(zhijin_prohibit)
zhijin:addRelatedSkill(zhijin_mod)

local xidi = fk.CreateTriggerSkill {
  name = "jy_xidi",
  events = { fk.Damaged, fk.EventPhaseStart },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.Damaged then
        return player.phase == Player.NotActive
      else
        return player.phase == Player.Start and player:getMark("@jy_xidi") ~= 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      -- TODO：只要这个技能触发过，那回合结束时就减一点护甲（因为每次受到伤害都获得一点护甲，而失去体力是不会减护甲的，所以一定会有一点护甲留存）
      room:changeShield(player, 1)
      -- room:addPlayerMark(player, "jy_xidi-turn")
      room:addPlayerMark(player, "@jy_xidi")
    else
      -- 要求他使用一张虚拟杀
      local dmg = player:getMark("@jy_xidi")
      local success, dat = room:askForUseActiveSkill(player, "#jy_xidi_viewas", "#jy_xidi-use:::" .. dmg)
      if success then
        local card = Fk:cloneCard("slash")
        card.skillName = self.name
        card.is_jy_xidi = true
        room:useCard {
          from = player.id,
          tos = table.map(dat.targets, function(p) return { p } end),
          card = card,
        }
      end
    end
  end,
  refresh_events = { fk.EventPhaseEnd, fk.DamageInflicted },
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseEnd then
        return player.shield > 0
      else
        return data.card and data.card.is_jy_xidi
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseEnd then
      player.room:changeShield(player, -player.shield)
    else
      data.damage = data.damage + player:getMark("@jy_xidi") - 1
      player.room:setPlayerMark(player, "@jy_xidi", 0)
    end
  end
}
local xidi_viewas = fk.CreateViewAsSkill {
  name = "#jy_xidi_viewas",
  anim_type = "offensive",
  pattern = "analeptic",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c.is_jy_xidi = true
    return c
  end,
}
xidi:addRelatedSkill(xidi_viewas)

local qexbj = General(extension, "jy__qexbj", "qun", 3, 3, General.Female)
qexbj:addSkill(zhijin)
qexbj:addSkill(xidi)
-- qexbj:addSkill(baoyang)

Fk:loadTranslationTable {
  ["jy__qexbj"] = [[切尔西伯爵]],
  ["designer:jy__qexbj"] = [[emo公主]],
  ["~jy__qexbj"] = [[怎么会……这样……]],

  ["jy_zhijin"] = [[掷金]],
  ["@jy_zhijin-phase"] = [[掷金]],
  [":jy_zhijin"] = [[出牌阶段开始时，你可以判定，然后本阶段：你至多使用判定结果点数张非装备牌；你使用与判定结果花色相同的牌时无距离和次数限制并摸两张牌。]],
  ["$jy_zhijin1"] = [[我就是为宝石而生的。]],
  ["$jy_zhijin2"] = [[我还没试过花钱买人的手脚。]],

  ["jy_xidi"] = [[西迪]],
  ["@jy_xidi"] = [[西迪]],
  ["#jy_xidi_viewas"] = [[西迪]],
  ["#jy_xidi-use"] = [[西迪：你需视为使用一张基础伤害值为 %arg 的【杀】]],
  [":jy_xidi"] = [[锁定技，你于回合外受到伤害后，你获得1点护甲和1枚“西迪”；一名角色的回合结束时，你失去所有护甲；回合开始时，若你有“西迪”，你移除所有“西迪”视为使用一张基础伤害值为“西迪”数的【杀】。]],
  ["$jy_xidi1"] = [[就这？]],
  ["$jy_xidi2"] = [[西迪，拦住他们！]],

  ["jy_baoyang"] = [[包养]],
  ["@@jy_baoyang-turn"] = "包养",
  [":jy_baoyang"] = [[每轮开始时，你可以指定三个不同的牌名，然后依次从场上获得一张该牌名的牌。若如此做，本轮你首个回合开始前，你须交给一名其他角色三张牌并选择一项（每项限一次）：1.结束当前回合并令其执行一个额外回合；2.获得其一个技能（限定/觉醒/使命技除外）直到回合结束；3.观看其手牌并令其使用其中一张。]],
  ["$jy_baoyang1"] = [[开个价吧。]],
  ["$jy_baoyang2"] = [[你知道该怎么做的对吧？]],
}

local maochong = fk.CreateViewAsSkill {
  name = "jy_maochong",
  anim_type = "switch",
  switch_skill_name = "jy_maochong",
  card_filter = function(self, to_select, selected)
    return true
  end,
  view_as = function(self, cards)
    if #cards > 0 then
      local card = Fk:cloneCard("slash")
      card:addSubcards(cards)
      card.skillName = self.name
      card.jy_maochong = #cards
      return card
    end
  end,
  enabled_at_play = function(self, player)
    return player:getSwitchSkillState(self.name) == fk.SwitchYang
  end,
  enabled_at_response = function(self, player, response)
    return player:getSwitchSkillState(self.name) == fk.SwitchYang
  end,
}
local maochong_extra = fk.CreateTriggerSkill {
  name = "#jy_maochong_extra",
  mute = true,
  frequency = Skill.Compulsory,
  events = { fk.TargetSpecified },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return target == player and data.card.trueName == "slash" and data.card.jy_maochong
  end,
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = data.fixedResponseTimes or {}
    data.fixedResponseTimes["jink"] = data.card.jy_maochong
  end,
  refresh_events = { fk.DamageInflicted },
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return data.from == player and data.card and data.card.trueName == "slash" and data.card.jy_maochong and
        player:getEquipment(Card.SubtypeWeapon)
  end,
  on_refresh = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
local maochong_bypass = fk.CreateTargetModSkill {
  name = "#jy_maochong_bypass",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and to and card.jy_maochong
  end,
}
local maochong_skills = fk.CreateTriggerSkill {
  name = "#maochong_skills",
  mute = true,
  refresh_events = { fk.EventAcquireSkill, fk.EventLoseSkill, fk.BuryVictim, fk.AfterPropertyChange },
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return data == self
    elseif event == fk.BuryVictim then
      return target:hasSkill(self, true, true)
    elseif event == fk.AfterPropertyChange then
      return target == player
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local attached_huangtian = table.find(room.alive_players, function(p)
      return p ~= player and p:hasSkill(self, true)
    end)
    if attached_huangtian and not player:hasSkill("jy_maochong_other&", true, true) then
      room:handleAddLoseSkills(player, "jy_maochong_other&", nil, false, true)
    elseif not attached_huangtian and player:hasSkill("jy_maochong_other&", true, true) then
      room:handleAddLoseSkills(player, "-jy_maochong_other&", nil, false, true)
    end
  end,
}
local maochong_other = fk.CreateActiveSkill {
  name = "jy_maochong_other&",
  anim_type = "support",
  prompt = "#jy_maochong-active",
  mute = true,
  can_use = function(self, player)
    local me = table.find(Fk:currentRoom().alive_players,
      function(p) return p:hasSkill(maochong.name) and p ~= player end)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 and me and
        me:getSwitchSkillState(maochong.name) == fk.SwitchYin
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected < 1 and
        (card.trueName == "slash" or (card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon))
  end,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room.alive_players, function(p) return p:hasSkill("jy_maochong") and p ~= player end)
    local target
    if #targets == 1 then
      target = targets[1]
    else
      target = room:getPlayerById(room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, nil,
        self.name, false)[1])
    end
    if not target then return false end
    room:notifySkillInvoked(player, "jy_maochong")
    player:broadcastSkillInvoke("jy_maochong")
    room:doIndicate(effect.from, { target.id })

    -- 给target更改阴阳状态
    player.room:setPlayerMark(target, MarkEnum.SwithSkillPreName .. maochong.name,
      target:getSwitchSkillState(maochong.name, true))
    target:addSkillUseHistory(maochong.name)

    room:moveCardTo(effect.cards, Player.Hand, target, fk.ReasonGive, self.name, nil, true)
    player:drawCards(1, maochong.name)
  end,
}
Fk:addSkill(maochong_other)
maochong:addRelatedSkill(maochong_extra)
maochong:addRelatedSkill(maochong_bypass)
maochong:addRelatedSkill(maochong_skills)

local muhuo = fk.CreateTriggerSkill {
  name = "jy_muhuo",
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and player:distanceTo(target) <= 1 and
        player:distanceTo(target) >= 0 -- 需要判断 >= 0，因为如果目标因该伤害而死就是-1了
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(math.min(player.maxHp - player.hp, 5), self.name)
    player.room:setPlayerMark(target, MarkEnum.SwithSkillPreName .. maochong.name,
      fk.SwitchYin)
    player:addSkillUseHistory(maochong.name)
    if target ~= player then
      player.room:setPlayerMark(target, "jy_muhuo-turn", "")
    end
  end,
}
local muhuo_prohibit = fk.CreateProhibitSkill {
  name = "#jy_muhuo_prohibit",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    return from:hasSkill(self) and to:getMark("jy_muhuo-turn") ~= 0
  end,
}
muhuo:addRelatedSkill(muhuo_prohibit)

local ylmc = General(extension, "jy__ylmc", "wei", 3, 4, General.Female)
ylmc:addSkill(maochong)
ylmc:addSkill(muhuo)

Fk:loadTranslationTable {
  ["jy__ylmc"] = [[御稜名草]],
  ["#jy__ylmc"] = [[冒充会长]],
  ["designer:jy__ylmc"] = [[白洲]],
  ["cv:jy__ylmc"] = [[无]],
  ["illustrator:jy__ylmc"] = [[Nexon]],

  ["jy_maochong"] = [[冒充]],
  [":jy_maochong"] = [[转换技，阳：你可将X（X由你选择且至少为1）张牌当【杀】使用，该【杀】无次数限制，当你使用该【杀】指定一个目标后，该角色需依次使用X张【闪】才能抵消此【杀】，若你的装备区有武器牌，该【杀】伤害+1；阴：其他角色的出牌阶段限一次，其可以将一张【杀】或武器牌正面朝上交给你，然后其摸一张牌。]],
  ["#jy_maochong-active"] = [[你可以将一张【杀】或武器牌交给御稜名草，然后你摸一张牌]],
  ["jy_maochong_other&"] = [[冒充]],
  [":jy_maochong_other&"] = [[出牌阶段限一次，当御稜名草的〖冒充〗状态为阴时，你可以将一张【杀】或武器牌正面向上交给其，然后你摸一张牌。]],

  ["jy_muhuo"] = [[目祸]],
  [":jy_muhuo"] = [[当一名角色受到伤害后，若你与其距离1以内且其未死亡，你可以摸X张牌（X为你已损失的体力值且至多为5）并将〖冒充〗状态改为阴。若其不为你，你本回合不能再对其使用牌。]],
}

local tjzs = General(extension, "jy__tjzs", "shu", 3, 3, General.Female)
tjzs:addSkill("jy_trad_heiyong")
tjzs:addSkill("jy_juewu")

Fk:loadTranslationTable {
  ["jy__tjzs"] = [[铁甲战士]],
  ["#jy__tjzs"] = [[铁甲战士]],
  ["designer:jy__tjzs"] = [[Kasa]],
  ["cv:jy__tjzs"] = [[AI莱依拉]],
  ["illustrator:jy__tjzs"] = [[未知]],
}

return extension
