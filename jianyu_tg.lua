---@diagnostic disable: undefined-field
local extension = Package:new("jianyu_tg")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu_tg"] = [[简浴-集思广益]],
}

local jy__tangniu = General(extension, "jy__tangniu", "qun", 1, 1, General.Female)

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
    player.room:doAnimate("InvokeSkill", {
      name = "jy_budeng",
      player = player.id,
      skill_type = "defensive",
    })

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
    player.room:doAnimate("InvokeSkill", {
      name = "jy_budeng",
      player = player.id,
      skill_type = "defensive",
    })

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
    player.room:doAnimate("InvokeSkill", {
      name = "jy_budeng",
      player = player.id,
      skill_type = "offensive",
    })

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
  ["designer:jy__tangniu"] = "考公专家 & 私服群（838724904）群友",
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
  [":jy_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制、不可被响应；你造成伤害后，伤害目标回复X点体力并摸X张牌，X为伤害值。]],
  ["$jy_zhushe1"] = [[准备好注射了。]],
  ["$jy_zhushe2"] = [[我的治疗是不会痛的。]],
}

local function isFactor(a, b)
  return a ~= 0 and b ~= 0 and b % a == 0
end

local fenlv = fk.CreateActiveSkill {
  name = "jy_fenlv",
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
      t[room:askForChoice(player, choices, self.name, "#jy_fenlv_ask")])
  end,
}
local fenlv_draw = fk.CreateTriggerSkill {
  name = "#jy_fenlv_draw",
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
fenlv:addRelatedSkill(fenlv_draw)
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

local peixiu = General(extension, "jy__peixiu", "qun", 3)
peixiu.subkingdom = "jin"
peixiu:addSkill(fenlv)
peixiu:addSkill(zhunwang)
peixiu:addSkill("juezhi")


Fk:loadTranslationTable {
  ["jy__peixiu"] = "简裴秀",
  ["#jy__peixiu"] = "禁图开秘",
  ["designer:jy__peixiu"] = "贾文和",

  ["jy_fenlv"] = "分率",
  [":jy_fenlv"] = [[锁定技，你使用牌结算结束后记录此牌点数。你使用牌时，若此牌点数为〖分率〗记录点数的约数，你摸一张牌；你有已记录的点数，你使用点数为〖分率〗记录点数的倍数的牌无次数限制。出牌阶段限三次，你可以修改〖分率〗记录的点数。]],
  ["@jy_fenlv"] = "分率",
  ["#jy_fenlv_ask"] = "修改“分率”",

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
        player:drawCards(2)
        return true
      end
    else
      data.damage = data.damage + 1
    end
    player:drawCards(2)
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

local mumang = fk.CreateProhibitSkill {
  name = "jy_mumang",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if from:hasSkill(self) and card.trueName == "slash" then
      return from:distanceTo(to) > 1 -- 不能指定与你距离大于1的角色为目标
      --  or (from:getNextAlive(true) ~= to and to:getNextAlive(true) ~= from) -- 不能指定上家或下家以外的角色为目标
    end
  end,
}

local guanzhe = General(extension, "jy__guanzhe", "jin", 3, 3, General.Female)
guanzhe:addSkill(xiuxing)
guanzhe:addSkill(zitai)
guanzhe:addSkill(mumang)
guanzhe:addSkill(yujian)

Fk:loadTranslationTable {
  ["jy__guanzhe"] = [[观者]],
  ["#jy__guanzhe"] = [[目盲的修行者]],
  ["designer:jy__guanzhe"] = [[Kasa]],
  ["cv:jy__guanzhe"] = [[暂无]],
  ["illustrator:jy__guanzhe"] = [[未知]],

  ["jy_xiuxing"] = [[修行]],
  [":jy_xiuxing"] = [[锁定技，你使用牌无次数限制。]],

  ["jy_zitai"] = [[姿态]],
  [":jy_zitai"] = [[转换技，锁定技，当你造成或受到伤害时，阳：你判定，若为红色，防止之；阴：该伤害+1。然后你摸两张牌。]],

  ["jy_mumang"] = [[目盲]],
  [":jy_mumang"] = [[锁定技，你只能指定与你的距离不超过1的角色为【杀】的目标。]],

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
    if not player:hasSkill(self) then return false end
    return target == player and player.phase == Player.Start
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
  events = { fk.Damaged, fk.Death },
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Damaged then
        return player:hasSkill(self)
      else
        return player:hasSkill(self, false, true) -- 这样写，即使我死了也能触发
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    if event == fk.Damaged then
      self.cancel_cost = false
      for _ = 1, data.damage do
        if self.cancel_cost or not player:hasSkill(self) then break end
        self:doCost(event, target, player, data)
      end
    else
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    -- 选择一个目标
    local room = player.room
    if room:askForSkillInvoke(player, self.name) then
      local jy_yiji_target = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), Util.IdMapper), 1,
        1,
        "#jy_yiji_prompt", self.name, true, false) -- 选择一个目标
      if #jy_yiji_target > 0 then
        data.cost_data = jy_yiji_target[1]
        return true
      else
        return false
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.cost_data)

    to:drawCards(2, self.name)

    -- 让他选择一个牌名
    local mark = player:getMark("jy_yiji_names")
    if type(mark) ~= "table" then
      mark = {}
      for _, id in ipairs(Fk:getAllCardIds()) do
        local card = Fk:getCardById(id)
        if card:isCommonTrick() and not card.is_derived then
          table.insertIfNeed(mark, card.name)
        end
      end
      room:setPlayerMark(to, "jy_yiji_names", mark)
    end
    local mark2 = to:getMark("@$jy_yiji-round")
    if mark2 == 0 then mark2 = {} end
    local names, choices = {}, {}
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
    table.insert(names, "Cancel")
    table.insert(choices, "Cancel")
    local choice = room:askForChoice(to, choices, self.name, "#jy_yiji-invoke::" .. to.id, false, names)
    if choice == "Cancel" then
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
      if #selected == 1 then
        -- 第一张如果是非基本牌，直接return false，如果不是，那就看第二张是不是基本牌，是就是对的
        if Fk:getCardById(selected[1]).type ~= Card.TypeBasic then
          return false
        else
          return Fk:getCardById(to_select).type == Card.TypeBasic
        end
      end
      if #selected >= 2 then return false end
    end
  end,
  view_as = function(self, cards)
    if #cards == 1 or #cards == 2 then
      local card = Fk:cloneCard(Self:getMark("jy_yiji-tmp"))
      card:addSubcard(cards[1])
      card.skillName = "jy_yiji"
      return card
    end
  end,
}
yiji:addRelatedSkill(yiji_viewas)

-- 董允舍宴
local yingcai = fk.CreateTriggerSkill {
  name = "jy_yingcai",
  anim_type = "control",
  events = { fk.TargetConfirming },
  can_trigger = function(self, event, target, player, data)
    if data.from == player.id and player:hasSkill(self) and data.card:isCommonTrick() then -- 这一段是sheyan的代码，但是因为TargetConfirming是对每一个人都生效，所以当你加了一个新目标，又会触发这个，导致触发多次，和原来的不一样。
      if player:getMark("jy_yingcai_used") ~= 0 then return false end
      local room = player.room
      local targets = U.getUseExtraTargets(room, data, true, true)
      local origin_targets = U.getActualUseTargets(room, data, event)
      if #origin_targets > 1 then
        table.insertTable(targets, origin_targets)
      end
      if #targets > 0 then
        self.cost_data = targets
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local plist, cid = room:askForChooseCardAndPlayers(player, self.cost_data, 1, 1, nil,
      "#jy_yingcai-choose:::" .. data.card:toLogString(), self.name, true)
    if #plist > 0 then -- 如果他选择了目标，那就发动
      self.cost_data = { plist[1], cid }
      room:setPlayerMark(player, "jy_yingcai_used", true)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data[2], self.name, player, player)
    if table.contains(AimGroup:getAllTargets(data.tos), self.cost_data[1]) then
      AimGroup:cancelTarget(data, self.cost_data[1])
      return self.cost_data[1] == player.id
    else
      AimGroup:addTargets(player.room, data, self.cost_data[1])
    end
  end,
  refresh_events = { fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("jy_yingcai_used") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "jy_yingcai_used", 0)
  end,
}

local guojia = General(extension, "jy__guojia", "wei", 3)

guojia:addSkill(tiandu)
guojia:addSkill(yiji)
guojia:addSkill(yingcai)

Fk:loadTranslationTable {
  ["jy__guojia"] = [[简郭嘉]],
  ["#jy__guojia"] = [[识人心智]],
  ["designer:jy__guojia"] = [[rolin]],
  ["cv:jy__guojia"] = [[暂无]],
  ["illustrator:jy__guojia"] = [[未知]],

  ["jy_tiandu"] = [[天妒]],
  [":jy_tiandu"] = [[锁定技，回合开始时，你受到一点无来源伤害。]],

  ["jy_yiji"] = [[遗计]],
  [":jy_yiji"] = [[当你受到一点伤害或你死亡时，你可以令一名角色摸两张牌，然后其可以立即将一张非基本牌或两张基本牌当一张本轮未以此法使用过的普通锦囊牌使用。]],
  ["#jy_yiji_prompt"] = [[遗计：你可以令一名角色摸两张牌，随后立即使用一张可自选的锦囊牌]],
  ["#jy_yiji-use"] = [[遗计：你可以立即将一张非基本牌或两张基本牌当 %arg 使用]],
  ["@$jy_yiji-round"] = [[遗计]],
  ["#jy_yiji_viewas"] = [[遗计]],

  ["jy_yingcai"] = [[英才]],
  [":jy_yingcai"] = [[当你使用锦囊牌指定目标时，你可以弃一张牌，为该锦囊牌增加或减少一个目标（目标数至少为1）。]],
  ["#jy_yingcai-choose"] = "英才：你可以弃一张牌，为 %arg 增加/减少一个目标",
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
    local success, dat = room:askForUseActiveSkill(player, "#jy_taoqiu_viewas", "#jy_taoqiu-use")
    if success then
      local card = Fk:cloneCard("slash")
      card:addSubcards(dat.cards)
      card.skillName = self.name
      local use = {
        from = player.id,
        tos = table.map(dat.targets, function(p) return { p } end),
        card = card,
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

local hbrz = General(extension, "jy__hbrz", "shu", 4)
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
  [":jy_taoqiu"] = [[其他角色的结束阶段，若你的武将牌背面朝上，你可以立即将一张牌当【杀】使用。若此【杀】造成伤害，你翻面。]],
  ["#jy_taoqiu-use"] = [[逃囚：你可以将一张牌当【杀】使用，若造成伤害，你翻面]]
}

return extension
