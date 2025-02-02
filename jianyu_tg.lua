---@diagnostic disable: undefined-field
local extension = Package:new("jianyu_tg")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu_tg"] = [[简浴-投稿]],
}

-- 这里是一些这个包里用到的函数，先放在顶部，之后可能会搬运到别的地方

-- 把数字转化成字符串
local function translateCardType(cardType)
  local t = {}
  t[Card.TypeBasic] = "basic"
  t[Card.TypeTrick] = "trick"
  t[Card.TypeEquip] = "equip"
  return Fk:translate(t[cardType])
end

-- 统计一组牌里每种花色有多少张。
local function suitCount(ids)
  local suits = { 0, 0, 0, 0 }
  for _, id in ipairs(ids) do
    local s = Fk:getCardById(id).suit
    if s ~= Card.NoSuit then
      suits[s] = suits[s] + 1
    end
  end
  return suits
end

-- a是b的因数吗？
local function isFactor(a, b)
  return a > 0 and b > 0 and b % a == 0
end

-- 将点数和花色合并为一个字符串还给他
local function zhijinShow(suit, number)
  assert(type(suit) == "number" and type(number) == "number")
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

-- 选择一名副将不是狐狸分身的角色，将其副将替换为狐狸分身
local function set_kitsune(room, player, skillName, cancelable, prompt)
  local targets = table.map(table.filter(room:getAlivePlayers(), function(p)
    return p.deputyGeneral ~= "jy__jtqn_kitsune"
  end), Util.IdMapper)
  if #targets == 0 then return false end
  local result = room:askForChoosePlayers(player, targets, 1, 1, prompt or "#jy_fenshen-prompt",
    skillName,
    cancelable, false)
  if #result ~= 0 then
    room:changeHero(room:getPlayerById(result[1]), "jy__jtqn_kitsune", false, true, true, false) -- 最后一个参数是是否不改变他的体力上限
    return true
  end
end

-- 从上往下搜牌堆。系统里的搜牌堆函数是随机的
local function getCardsFromDrawPileTTB(room, checkFunc, num)
  local matched = {}
  for _, c in ipairs(room.draw_pile) do
    if checkFunc(Fk:getCardById(c)) then
      table.insert(matched, c)
      if #matched == num then break end
    end
  end
  return matched
end

-- 统计一堆玩家里手牌数的最大值和最小值
local function findHandCardMinMax(players)
  if #players == 0 then
    return nil, nil -- 返回空列表的情况
  end
  local list = table.map(players, function(p) return #p:getCardIds("h") end)
  local min = list[1] -- 假设第一个元素是最小值
  local max = list[1] -- 假设第一个元素是最大值
  for i = 2, #list do
    if list[i] < min then
      min = list[i] -- 更新最小值
    end
    if list[i] > max then
      max = list[i] -- 更新最大值
    end
  end
  return min, max -- 返回最小值和最大值
end

-- 一个玩家的武将牌上有没有这个技能？
local function is_general_skill(player, skill_name)
  local generals = { player.general, player.deputyGeneral }
  table.removeOne(generals, "")
  local general_skills = {}
  for _, g in ipairs(generals) do
    general_skills = table.connect(general_skills, Fk.generals[g].skills)
  end
  return table.contains(general_skills, Fk.skills[skill_name])
end

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
  name = "#jy_zhushe_mod",
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
    player:broadcastSkillInvoke("jy_xingtu")
    player.room:notifySkillInvoked(player, "jy_xingtu", "drawcard")
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

local zhunwang_mod = fk.CreateTriggerSkill {
  name = "#jy_zhunwang_mod",
  refresh_events = { fk.CardUsing },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    if translateCardType(data.card.type) == player:getMark("@jy_zhunwang") then
      player:broadcastSkillInvoke("jy_zhunwang")
      player.room:notifySkillInvoked(player, "jy_zhunwang", "offensive")
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
  is_prohibited = function(self, from, to)
    return from:hasSkill(self) and not (to == from or to:getNextAlive() == from or from:getNextAlive() == to)
  end,
}
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
        player:drawCards(1, self.name)
        return true
      end
    else
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade,club",
      }
      player.room:judge(judge)
      if judge.card.color == Card.Black then
        data.damage = data.damage + 1
      end
    end
    player:drawCards(1, self.name)
  end
}

local yujian = fk.CreateTriggerSkill {
  name = "jy_yujian",
  anim_type = "control",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askForGuanxing(player, room:getNCards(math.min(5, room:getTag("RoundCount")))) -- 这个函数只能显示 观星 思考中，没办法改变这个
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
  [":jy_xiuxing"] = [[锁定技，你使用牌无次数限制；你、你上家和下家之外的角色不是你使用牌的合法目标；你的攻击范围始终为1。]],

  ["jy_zitai"] = [[姿态]],
  [":jy_zitai"] = [[转换技，锁定技，当你造成或受到伤害时，你判定，阳：若为红色，防止之；阴：若为黑色，该伤害+1。然后你摸一张牌。]],

  ["jy_yujian"] = [[预见]],
  [":jy_yujian"] = [[准备阶段，你可以卜算X（X为游戏轮数且至多为5）。]],
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

-- 周不疑
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
        tos = table.map(dat.targets, function(p) return { p } end), -- TODO: 这有啥用？
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
    local ret = false
    local plist, cid = room:askForChooseCardAndPlayers(player, self.cost_data, 1, 1, nil,
      "#jy_yingcai-choose:::" .. data.card:toLogString(), self.name, true)
    if #plist > 0 then -- 如果他选择了目标，那就发动
      self.cost_data = { plist[1], cid }
      ret = true
    end
    room:setPlayerMark(player, "jy_yingcai_used", true)
    return ret
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
  ["~jy__guojia"] = [[咳咳……]],

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

  ["jy_yingcai"] = [[英才]],
  [":jy_yingcai"] = [[当你使用锦囊牌时，你可以弃一张牌，为该锦囊牌增加或减少一个目标（目标数至少为1）。]],
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
    local success, dat = room:askForUseActiveSkill(player, "#jy_taoqiu_viewas", "#jy_taoqiu-use", true,
      { bypass_distances = true })
    if success then
      assert(dat)
      local card = Fk:cloneCard("slash")
      card:addSubcards(dat.cards)
      card.skillName = self.name
      local use = {
        from = player.id,
        tos = table.map(dat.targets, function(p) return { p } end), -- TODO: 这有啥用？
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
  ["~jy__hbrz"] = [[非常抱歉……非常……抱歉……]],
  ["#jy__hbrz"] = [[灾厄之狐]],
  ["designer:jy__hbrz"] = [[白洲]],
  ["cv:jy__hbrz"] = [[斋藤千和]],
  ["illustrator:jy__hbrz"] = [[Nexon]],

  ["jy_yangbai"] = [[佯败]],
  [":jy_yangbai"] = [[结束阶段或你受到伤害后，若你的武将牌正面朝上，你可以翻面并摸三张牌。]],
  ["$jy_yangbai1"] = [[（笑）]],
  ["$jy_yangbai2"] = [[没意义的哟。]],

  ["jy_taoqiu"] = [[逃囚]],
  [":jy_taoqiu"] = [[其他角色的结束阶段，若你的武将牌背面朝上，你可以将一张牌当无距离限制的【杀】使用。若此【杀】造成伤害，你翻面。]],
  ["#jy_taoqiu-use"] = [[逃囚：你可以将一张牌当无距离限制的【杀】使用，若造成伤害，你翻面]],
  ["#jy_taoqiu_viewas"] = [[逃囚]],
  ["$jy_taoqiu1"] = [[别想逃哟！]],
  ["$jy_taoqiu2"] = [[就在那里死去吧！]],
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
      -- 无点数的牌会被设置为0，不必担心
      player:drawCards(data.card.number, self.name)
    end
  end,
  refresh_events = { fk.CardUsing },
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@jy_zhijin-phase") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "jy_zhijin_card-phase", -1)
    player.room:setPlayerMark(player, "@jy_zhijin-phase",
      zhijinShow(player:getMark("jy_zhijin_suit-phase"), player:getMark("jy_zhijin_card-phase")))
  end
}
local zhijin_prohibit = fk.CreateProhibitSkill {
  name = "#jy_zhijin_prohibit",
  prohibit_use = function(self, player, card)
    return player:hasSkill(self) and player:getMark("jy_zhijin_card-phase") <= 0 and
        player.phase == Player.Play
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
        return player.phase == Player.Start
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:changeShield(player, 1)
      -- room:addPlayerMark(player, "jy_xidi-turn")
      -- if player:getMark("@jy_xidi") < 2 then room:addPlayerMark(player, "@jy_xidi") end
    else
      -- 要求他使用一张虚拟杀
      -- local dmg = player:getMark("@jy_xidi")
      local success, dat = room:askForUseActiveSkill(player, "#jy_xidi_viewas", "#jy_xidi-use")
      if success then
        local card = Fk:cloneCard("slash")
        card.skillName = self.name
        card.is_jy_xidi = true
        room:useCard {
          from = player.id,
          tos = table.map(dat.targets, function(p) return { p } end), -- TODO: 这有啥用？
          card = card,
        }
      end
    end
  end,
  refresh_events = { fk.TurnEnd },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and player.shield > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:changeShield(player, -1)
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
  ["#jy__qexbj"] = [[暴发户]],
  ["designer:jy__qexbj"] = [[emo公主]],
  ["cv:jy__qexbj"] = [[大汪]],
  ["illustrator:jy__qexbj"] = [[未知]],
  ["~jy__qexbj"] = [[怎么会……这样……]],

  ["jy_zhijin"] = [[掷金]],
  ["@jy_zhijin-phase"] = [[掷金]],
  [":jy_zhijin"] = [[出牌阶段开始时，你可以判定，然后本阶段：你至多使用判定结果点数张牌；你使用与判定结果花色相同的牌时无距离和次数限制并摸X张牌，X为该牌点数。]],
  ["$jy_zhijin1"] = [[我就是为宝石而生的。]],
  ["$jy_zhijin2"] = [[我还没试过花钱买人的手脚。]],

  ["jy_xidi"] = [[西迪]],
  ["@jy_xidi"] = [[西迪]],
  ["#jy_xidi_viewas"] = [[西迪]],
  ["#jy_xidi-use"] = [[西迪：你视为使用一张【杀】]],
  [":jy_xidi"] = [[锁定技，你于回合外受到伤害后，你获得一点护甲；一名角色的回合结束时，你失去一点护甲；回合开始时，你视为使用一张【杀】。]],
  ["$jy_xidi1"] = [[就这？]],
  ["$jy_xidi2"] = [[西迪，拦住他们！]],

  -- ["jy_baoyang"] = [[包养]],
  -- ["@@jy_baoyang-turn"] = [[包养]],
  -- [":jy_baoyang"] = [[每轮开始时，你可以指定三个不同的牌名，然后依次从场上获得一张该牌名的牌。若如此做，本轮你首个回合开始前，你须交给一名其他角色三张牌并选择一项（每项限一次）：1.结束当前回合并令其执行一个额外回合；2.获得其一个技能（限定/觉醒/使命技除外）直到回合结束；3.观看其手牌并令其对你指定的目标使用其中一张。]],
  -- ["$jy_baoyang1"] = [[开个价吧。]],
  -- ["$jy_baoyang2"] = [[你知道该怎么做的对吧？]],
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
      function(p) return p:hasSkill("jy_maochong") and p ~= player end)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 and me and
        me:getSwitchSkillState("jy_maochong") == fk.SwitchYin
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

    -- 给target更改为阳（因为只有阴的时候才能发动这个技能）
    -- 这个技能目前可以正常触发转换
    player.room:setPlayerMark(target, MarkEnum.SwithSkillPreName .. "jy_maochong",
      fk.SwitchYang)
    target:addSkillUseHistory("jy_maochong") -- 加上这个更新UI

    room:moveCardTo(effect.cards, Player.Hand, target, fk.ReasonGive, self.name, nil, true)
    player:drawCards(1, "jy_maochong")
  end,
}
Fk:addSkill(maochong_other)
maochong:addRelatedSkill(maochong_extra)
maochong:addRelatedSkill(maochong_bypass)
maochong:addRelatedSkill(maochong_skills)

-- 即使是秦宜禄（https://gitee.com/qsgs-fans/tenyear/blob/master/tenyear_activity.lua）也会有显示bug。
-- overseas_sp2 曹肇跟我是一模一样的写法
local muhuo = fk.CreateTriggerSkill {
  name = "jy_muhuo",
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and player:distanceTo(target) <= 1 and
        player:distanceTo(target) >= 0 -- 需要判断 >= 0，因为如果目标因该伤害而死就是-1了
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player.maxHp - player.hp, self.name)
    player.room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. "jy_maochong",
      fk.SwitchYang)
    player:addSkillUseHistory("jy_maochong") -- 加上这个更新UI
    if target ~= player then
      player.room:setPlayerMark(target, "@jy_muhuo-turn", "")
    end
  end,
}
local muhuo_prohibit = fk.CreateProhibitSkill {
  name = "#jy_muhuo_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:hasSkill(self) and to:getMark("@jy_muhuo-turn") ~= 0
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
  ["#jy_maochong_extra"] = [[冒充]],
  [":jy_maochong"] = [[转换技，阳：你可将任意张牌当【杀】使用，该【杀】需使用等量张【闪】才能抵消且无次数限制，若你装备区有武器牌，该【杀】伤害+1；阴：其他角色的出牌阶段限一次，其可以将一张【杀】或武器牌正面朝上交给你并摸一张牌。]],
  ["#jy_maochong-active"] = [[你可以将一张【杀】或武器牌交给御稜名草，然后你摸一张牌]],
  ["jy_maochong_other&"] = [[冒充]],
  [":jy_maochong_other&"] = [[出牌阶段限一次，当御稜名草的〖冒充〗状态为阴时，你可以将一张【杀】或武器牌正面向上交给其，然后你摸一张牌。]],

  ["jy_muhuo"] = [[目祸]],
  ["@jy_muhuo-turn"] = [[目祸]],
  [":jy_muhuo"] = [[当一名角色受到伤害后，若你与其距离1以内且其未死亡，你可以摸X张牌（X为你已损失的体力值）并将〖冒充〗改为阳。若其不为你，本回合其不是你使用牌的合法目标。]],
}

local heiyong = fk.CreateTriggerSkill {
  name = "jy_heiyong",
  anim_type = "drawcard",
  events = { fk.CardUsing, fk.CardResponding, fk.TurnEnd },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and target == player) then return false end

    local mark = player:getMark("@$jy_heiyong-turn")
    if type(mark) ~= "table" then
      mark = {}
    end

    if event ~= fk.TurnEnd then
      return not table.contains(mark, data.card.name)
    else
      return #mark > player.maxHp
    end
  end,
  on_use = function(self, event, target, player, data)
    if event ~= fk.TurnEnd then
      local mark = player:getMark("@$jy_heiyong-turn")
      if type(mark) ~= "table" then
        mark = {}
        player.room:setPlayerMark(player, "@$jy_heiyong-turn", mark)
      end

      player:drawCards(1, self.name)
      table.insert(mark, data.card.name)
      player.room:setPlayerMark(player, "@$jy_heiyong-turn", mark)
    else
      player.room:loseHp(player, 1)
    end
  end,
}

local tjzs = General(extension, "jy__tjzs", "shu", 3, 3, General.Female)
tjzs:addSkill(heiyong)
-- tjzs:addSkill("jy_silie")

Fk:loadTranslationTable {
  ["jy__tjzs"] = [[铁甲战士]],
  ["#jy__tjzs"] = [[铁甲战士]],
  ["designer:jy__tjzs"] = [[Kasa]],
  ["cv:jy__tjzs"] = [[高达一号]],
  ["illustrator:jy__tjzs"] = [[未知]],

  ["jy_heiyong"] = [[黑拥]],
  [":jy_heiyong"] = [[锁定技，每回合每个牌名限一次，你使用或打出一张牌时，你摸一张牌；每名角色的回合结束时，若本回合你发动该技能的牌名数大于你的体力上限，你失去一点体力。]],
  ["$jy_heiyong1"] = [[龙战于野，其血玄黄！]],
  ["@$jy_heiyong-turn"] = [[黑拥]],
}

local fenshen = fk.CreateTriggerSkill {
  name = "jy_fenshen",
  frequency = Skill.Compulsory,
  anim_type = "support",
  events = { fk.Deathed, fk.EventPhaseChanging },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Deathed then
        return true
      else
        return target == player and
            data.to == Player.Start and player:getMark("jy_fenshen") == 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Deathed then
      if not set_kitsune(room, player, self.name, true, "#jy_fenshen-choose") then
        room:addPlayerMark(player, "@jy_fenshen")
      end
    else
      set_kitsune(room, player, self.name, false)
      room:setPlayerMark(player, "jy_fenshen", true)
    end
  end,
  refresh_events = { fk.DrawNCards },
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@jy_fenshen") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@jy_fenshen")
  end,
}

local renren = fk.CreateActiveSkill {
  name = "jy_renren",
  anim_type = "support",
  prompt = "#jy_renren-prompt",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  min_card_num = 1,
  target_num = 0,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    room:addPlayerMark(player, "@godsimayi_bear", #effect.cards)
  end,
}
local renren_jilve = fk.CreateTriggerSkill {
  name = "#jy_renren_jilve",
  refresh_events = { fk.AfterSkillEffect },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and
        (data.name == "jilue" and player:getMark("@godsimayi_bear") == 0 and player:hasSkill("jilue")) or
        (data.name == "jy_renren" and player:getMark("@godsimayi_bear") > 0 and not player:hasSkill("jilue"))
  end,
  on_refresh = function(self, event, target, player, data)
    if data.name == "jilue" then
      player.room:handleAddLoseSkills(player, "-jilue", nil, true, false)
    else
      player.room:handleAddLoseSkills(player, "jilue", nil, true, false)
    end
  end,
}
renren:addRelatedSkill(renren_jilve)

local kitsune_skill = fk.CreateTriggerSkill {
  name = "jy_kitsune_skill",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = { fk.EventPhaseChanging },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from == Player.Play and
        player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(data.from, true)
  end,
}

local jtqn = General(extension, "jy__jtqn", "shu", 4, 4, General.Female)
jtqn:addSkill(fenshen)
jtqn:addSkill(renren)
jtqn:addRelatedSkill("jilue")

local jtqn_kitsune = General(extension, "jy__jtqn_kitsune", "", 0, 0, General.Female)
jtqn_kitsune.total_hidden = true
jtqn_kitsune:addSkill(kitsune_skill)

Fk:loadTranslationTable {
  ["jy__jtqn"] = [[久田泉奈]],
  ["#jy__jtqn"] = [[最强忍者]],
  ["designer:jy__jtqn"] = [[笨蛋琪露诺]],
  ["cv:jy__jtqn"] = [[阿澄佳奈]],
  ["illustrator:jy__jtqn"] = [[kuro太]],
  ["~jy__jtqn"] = [[唔！好晕……]],

  ["jy__jtqn_kitsune"] = [[狐狸分身]],

  ["jy_fenshen"] = [[分身]],
  ["@jy_fenshen"] = [[分身]],
  [":jy_fenshen"] = [[锁定技，你首个回合开始时，你进行一次“分身”（将一名角色的副将替换为<font color="Fuchsia">狐狸分身</font>，不改变其体力上限）；当一名角色死亡后，你选择一项：①进行一次“分身”；②摸牌阶段摸牌数+1。<br><font color="grey">狐狸分身 多动：锁定技，每回合你首个出牌阶段结束后，额外执行一个出牌阶段。</font>]],
  ["#jy_fenshen-prompt"] = [[分身：将一名角色的副将替换为狐狸分身]],
  ["#jy_fenshen-choose"] = [[分身：将一名角色的副将替换为狐狸分身，点击取消摸牌阶段摸牌数+1]],
  ["$jy_fenshen1"] = [[这么宽敞的话，就连泉奈流忍术、百八式影分身之术也可以施展了吧。]],
  ["$jy_fenshen2"] = [[泉奈流忍法！]],
  ["$jy_fenshen3"] = [[（意义不明的小曲）]],
  ["$jy_fenshen4"] = [[这也是为了收集情报，藏在这边就行了吧。]],

  ["jy_renren"] = [[忍忍]],
  [":jy_renren"] = [[出牌阶段限一次，你可以弃置任意张牌获得等量“忍”。若你有“忍”，你视为拥有〖极略〗。]],
  ["#jy_renren-prompt"] = [[弃置任意张牌获得等量“忍”]],
  ["$jy_renren1"] = [[忍忍忍忍忍忍忍]],

  ["jy_kitsune_skill"] = [[多动]],
  [":jy_kitsune_skill"] = [[锁定技，每回合你首个出牌阶段结束后，额外执行一个出牌阶段。]],
}

local jiaofeng = fk.CreateTriggerSkill {
  name = "jy_jiaofeng",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = { fk.CardUseFinished },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Play and
        not table.find(player:getCardIds(Player.Hand),
          function(id) return Fk:getCardById(id).type == data.card.type end)
  end,
  on_use = function(self, event, target, player, data)
    local hands = player:getCardIds("h")
    player:showCards(hands)
    player:drawCards(2, self.name)
    player.room:setPlayerMark(player, "@jy_jiaofeng", "")
  end,
  refresh_events = { fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player:getMark("@jy_jiaofeng") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_jiaofeng", 0)
  end,
}
local jiaofeng_mod = fk.CreateTargetModSkill {
  name = "#jy_jiaofeng_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and player:getMark("@jy_jiaofeng") ~= 0
  end,
  -- bypass_distances = function(self, player, skill, card, to)
  --   return player:hasSkill(self) and player:getMark("@jy_jiaofeng") ~= 0
  -- end,
}
jiaofeng:addRelatedSkill(jiaofeng_mod)

Fk:loadTranslationTable {
  ["jy__zhanshige"] = [[战士鸽]],
  ["#jy__zhanshige"] = [[二代]],
  ["designer:jy__zhanshige"] = [[Kasa]],
  ["cv:jy__zhanshige"] = [[无]],
  ["illustrator:jy__zhanshige"] = [[未知]],

  ["jy_jiaofeng"] = [[交锋]],
  [":jy_jiaofeng"] = [[锁定技，出牌阶段，你使用牌后，若你的手牌中没有相同类型的牌，则你展示所有手牌、摸两张牌且你使用的下一张牌无次数限制。]],
  ["@jy_jiaofeng"] = [[交锋]],
}
local zsg = General(extension, "jy__zhanshige", "shu", 3, 3, General.Female)
zsg:addSkill(jiaofeng)

local yingyuan = fk.CreateTriggerSkill {
  name = "jy_yingyuan",
  events = { fk.AfterCardsMove },
  frequency = Skill.Compulsory,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self) then
      -- 如果是因为技能摸牌，不能是jy_shiyuan
      local e = room.logic:getCurrentEvent().parent
      if e and e.event == GameEvent.SkillEffect then
        local _skill = e.data[3]
        local skill = _skill.main_skill and _skill.main_skill or _skill
        if skill.name == "jy_shiyuan" then return false end
      end

      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            -- 不因使用而失去
            -- TODO：参考乐蔡重新写这个
            if (move.toArea == Card.DiscardPile or move.toArea == Card.Processing) and move.moveReason ~= fk.ReasonUse and move.from and (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and (room:getCardArea(info.cardId) == Card.DiscardPile or room:getCardArea(info.cardId) == Card.Processing) then
              data.is_jy_yingyuan_first = true
            end
            -- 连营
            if player:getMark("jy_yingyuan-turn") == 0 and player:isKongcheng() and info.fromArea == Card.PlayerHand then -- 每回合只能连一次
              data.is_jy_yingyuan_second = true
            end
            if data.is_jy_yingyuan_first and data.is_jy_yingyuan_second then break end -- 如果两个都满足了，不用再判断后面的了
          end
          -- 等循环完再判断
          if data.is_jy_yingyuan_first or data.is_jy_yingyuan_second then return true end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.is_jy_yingyuan_first then
      local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
      if #targets ~= 0 then
        local result = room:askForChoosePlayers(player, targets, 1, 1, "#jy_yingyuan-prompt",
          self.name, false, false)
        if #result ~= 0 then
          local to = room:getPlayerById(result[1])
          if not to.dead then
            to:drawCards(1, self.name)
          end
        end
      end
    end
    if data.is_jy_yingyuan_second then
      -- 未觉醒需失去体力
      if player:usedSkillTimes("jy_mouyuan", Player.HistoryGame) == 0 then
        room:loseHp(player, 1, self.name)
      end
      if not player.dead then
        player:drawCards(player.hp, self.name)
        room:setPlayerMark(player, "jy_yingyuan-turn", true)
      end
    end
  end,
}

local shiyuan = fk.CreateActiveSkill {
  name = "jy_shiyuan",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local card = Fk:getCardById(effect.cards[1])
    room:throwCard(effect.cards, self.name, from, from)
    if from:isAlive() then
      if translateCardType(card.type) == from:getMark("@jy_shiyuan") then
        -- 尝试搜索到一张同类型的牌
        local typ = card:getTypeString()
        local c
        local cards = room:getCardsFromPileByRule(".|.|.|.|.|" .. typ, 1, "drawPile")
        if #cards > 0 then
          c = cards[1]
        end
        if c then
          local targets = table.map(table.filter(room:getOtherPlayers(from), function(p)
            return true
          end), Util.IdMapper)
          if #targets == 0 then return false end
          local result = room:askForChoosePlayers(from, targets, 1, 1, "#jy_shiyuan-prompt:::" .. Fk:translate(typ),
            self.name,
            false, false)
          if #result ~= 0 then
            room:obtainCard(result[1], c, true, fk.ReasonPrey)
            -- 为觉醒技做铺垫，如果没有这个觉醒技就不要做任何事情
            if from:hasSkill("jy_mouyuan") and from:usedSkillTimes("jy_mouyuan", Player.HistoryGame) == 0 then
              local recordedTypes = from:getMark("@jy_mouyuan")
              if type(recordedTypes) ~= "table" then recordedTypes = {} end
              if not table.contains(recordedTypes, typ .. "_char") then
                table.insert(recordedTypes, typ .. "_char")
                room:setPlayerMark(from, "@jy_mouyuan", recordedTypes)
              end
            end
          end
        end
        from:setSkillUseHistory("jy_shiyuan", 0, Player.HistoryPhase)
      end
    end
  end,
}
local shiyuan_mod = fk.CreateTriggerSkill {
  name = "#jy_shiyuan_mod",
  refresh_events = { fk.CardUsing },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_shiyuan", translateCardType(data.card.type))
  end,
}
shiyuan:addRelatedSkill(shiyuan_mod)

local mouyuan = fk.CreateTriggerSkill {
  name = "jy_mouyuan",
  frequency = Skill.Wake,
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and
        player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return type(player:getMark("@jy_mouyuan")) == "table" and #player:getMark("@jy_mouyuan") == 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    -- 这样写会导致如果别的东西重置了我的所有技能，就无法修改应援了。不过这也符合技能描述不是嘛？没觉醒当然不能触发。
    room:setPlayerMark(player, "@jy_mouyuan", 0)
  end,
}

local yjds = General(extension, "jy__yjds", "wu", 4, 4, General.Female)
yjds:addSkill(shiyuan)
yjds:addSkill(yingyuan)
yjds:addSkill(mouyuan)

Fk:loadTranslationTable {
  ["jy__yjds"] = [[援护大师]],
  ["#jy__yjds"] = [[援神]],
  ["designer:jy__yjds"] = [[天使真央]],
  ["cv:jy__yjds"] = [[无]],
  ["illustrator:jy__yjds"] = [[未知]],

  ["jy_yingyuan"] = [[应援]],
  [":jy_yingyuan"] = [[锁定技，当你的牌不因使用或〖施援〗进入弃牌堆或处理区后，你令一名其他角色摸一张牌；每回合限一次，当你失去最后的手牌后，你<font color="red">失去一点体力</font>并摸等同于体力值张牌。]],
  ["#jy_yingyuan-prompt"] = [[应援：令一名其他角色摸一张牌]],

  ["jy_shiyuan"] = [[施援]],
  [":jy_shiyuan"] = [[出牌阶段限一次，你可以弃一张牌。若此牌与你使用的上一张牌类型相同，你令一名其他角色从牌堆获得一张同类型的牌（正面朝上）并重置此技能。]],
  ["@jy_shiyuan"] = [[施援]],
  ["#jy_shiyuan-prompt"] = [[施援：令一名其他角色获得一张%arg]],

  ["jy_mouyuan"] = [[谋援]],
  ["@jy_mouyuan"] = [[谋援]],
  [":jy_mouyuan"] = [[觉醒技，结束阶段，若〖施援〗已令其他角色获得三种类型的牌，你减一点体力上限令〖应援〗不再失去体力。]],
  ["$jy_mouyuan1"] = [[援神，启动！]],
  ["$jy_mouyuan2"] = [[援神，启动！]],
}

local choumou = fk.CreateTriggerSkill {
  name = "jy_choumou",
  anim_type = "control",
  events = { fk.CardUseFinished },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeEquip and data.card.sub_type == Card.SubtypeWeapon and
        not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cids = {}
    if room:askForSkillInvoke(player, self.name) then
      local cardNum = #player:getCardIds { Player.Hand, Player.Equip }
      if cardNum < 2 and cardNum > 0 then
        cids = room:askForDiscard(player, 2, 2, false, self.name, false) -- 直接给你弃完
      else
        cids = room:askForDiscard(player, 2, 2, true, self.name, true, nil, "#jy_choumou-ask")
      end
      if #cids ~= 0 then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:askForChooseToMoveCardInBoard(player, "#jy_choumou-move", self.name, true, nil)
    if #targets ~= 0 then
      targets = table.map(targets, function(id) return room:getPlayerById(id) end)
      room:askForMoveCardInBoard(player, targets[1], targets[2], self.name, "e")
    end
  end,
}

local anruo = fk.CreateTriggerSkill {
  name = "jy_anruo",
  anim_type = "control",
  events = { fk.Damaged },
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for _ = 1, data.damage do
      if self.cancel_cost or not player:hasSkill(self) then break end
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
    local cards
    local cs = room:askForCard(player, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#jy_anruo-prompt")
    if #cs ~= 0 then
      -- 放到牌堆顶
      room:moveCardTo(cs, Card.DrawPile, nil, fk.ReasonPut, self.name, nil, true)

      -- cards = room:getCardsFromPileByRule(".|.|heart,diamond|.|.|.", 2, "drawPile")
      cards = getCardsFromDrawPileTTB(room, function(card) return card.color == Card.Red end, 2)

      if #cards > 0 then
        room:moveCardTo(cards, Player.Hand, player, fk.ReasonPrey, self.name, nil, false,
          player.id)
      end
    else
      -- 选一张防具出来，然后使用
      -- cards = room:getCardsFromPileByRule(".|.|.|.|.|equip", 1, "drawPile")
      cards = getCardsFromDrawPileTTB(room,
        function(card) return card.type == Card.TypeEquip and card.sub_type == Card.SubtypeArmor end, 1)
      if #cards > 0 then
        room:moveCardTo(cards, Player.Hand, player, fk.ReasonPrey, self.name, nil, false,
          player.id)
        local card = Fk:getCardById(cards[1])
        if not player.dead and not player:isProhibited(player, card) and not player:prohibitUse(card) and
            table.contains(player:getCardIds("h"), cards[1]) then
          room:useCard({
            from = player.id,
            tos = { { player.id } }, -- 这里要两个括号，大彻大悟了
            card = card,
          })
        end
      end
    end
  end,
}

local cangfeng = fk.CreateTriggerSkill {
  name = "jy_cangfeng",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = { fk.AfterCardsMove },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type ~= Card.TypeBasic then -- 非基本牌
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local i = 0
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type ~= Card.TypeBasic then
            i = i + 1
          end
        end
      end
    end
    self.num = i
    self:doCost(event, target, player, data)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(self.num, self.name)
  end,
}

local simayi = General(extension, "jy__mou__simayi", "wei", 3)
simayi:addSkill(choumou)
simayi:addSkill(anruo)
simayi:addSkill(cangfeng)

Fk:loadTranslationTable {
  ["jy__mou__simayi"] = [[谋司马懿]],
  ["#jy__mou__simayi"] = [[韬谋韫势]],
  ["designer:jy__mou__simayi"] = [[rolin]],
  ["cv:jy__mou__simayi"] = [[无]],
  ["illustrator:jy__mou__simayi"] = [[官方]],

  ["jy_choumou"] = [[绸缪]],
  [":jy_choumou"] = [[一名角色使用武器牌后，你可以弃置两张牌（不足则全弃）将场上的一张装备牌移动至另一名角色的装备区内。]],
  ["#jy_choumou-ask"] = [[绸缪：你可以弃置两张牌将场上的一张装备牌移动至另一名角色的装备区内]],
  ["#jy_choumou-move"] = [[绸缪：选择两名角色，移动场上的一张装备牌]],

  ["jy_anruo"] = [[安弱]],
  [":jy_anruo"] = [[当你受到一点伤害后，你可以选择一项：①将一张装备牌置于牌堆顶并从牌堆从上往下获得两张红色牌；②使用牌堆第一张防具牌。]],
  ["#jy_anruo-prompt"] = [[安弱：选择一张装备牌置于牌堆顶并从牌堆从上往下获得两张红色牌，点击取消使用牌堆第一张防具牌]],

  ["jy_cangfeng"] = [[藏锋]],
  [":jy_cangfeng"] = [[锁定技，每当你因弃置而失去一张非基本牌后，你摸一张牌。]]
}

local nicai = fk.CreateTriggerSkill {
  name = "jy_nicai",
  mute = true,
  frequency = Skill.Compulsory,
  events = { fk.AfterCardsMove },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        return move.to == player.id and move.toArea == Player.Hand and move.skillName ~= self.name and
            move.moveReason == fk.ReasonDraw
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    self.is_only_greatest = true
    for _, p in ipairs(player.room:getOtherPlayers(player)) do
      if #p:getCardIds(Player.Hand) >= #player:getCardIds(Player.Hand) then
        self.is_only_greatest = false
        break
      end
    end
    if self.is_only_greatest then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.is_only_greatest then
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "negative")
      room:askForDiscard(player, 1, 1, true, self.name, false, nil, "#jy_nicai-prompt")
    else
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    end
  end,
}

local chayi = fk.CreateTriggerSkill {
  name = "jy_chayi",
  anim_type = "control",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and target.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local player_hands = player:getCardIds("h")
    local target_hands = target:getCardIds("h")
    local cards = room:askForPoxi(player, "jy_chayi_poxi", {
      { player.general, player_hands },
      { target.general, target_hands },
    }, { suitCount(player_hands), suitCount(target_hands) }, true)
    if #cards == 0 then return end
    local cards1 = table.filter(cards, function(id) return table.contains(player_hands, id) end) -- 选自己的牌
    local cards2 = table.filter(cards, function(id) return table.contains(target_hands, id) end) -- 选别人的牌
    local moveInfos = {}
    if #cards2 > 0 then
      table.insert(moveInfos, {
        from = target.id,
        ids = cards2,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = self.name,
      })
      if #cards1 > 0 then
        table.insert(moveInfos, {
          from = player.id,
          ids = cards1,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          proposer = player.id,
          skillName = self.name,
        })
      end
    elseif #cards1 > 0 then
      table.insert(moveInfos, {
        from = player.id,
        ids = cards1,
        to = target.id,
        toArea = Player.Hand,
        moveReason = fk.ReasonGive,
        proposer = player.id,
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
    if player.dead then return false end
    if #cards2 == 0 then
      room:drawCards(player, #cards1, self.name)
    end
  end,
}

Fk:addPoxiMethod {
  name = "jy_chayi_poxi",
  card_filter = function(to_select, selected, data, extra_data)
    local card = Fk:getCardById(to_select)
    if card.suit == Card.NoSuit then return false end

    -- 察异第一种情况的card_filter
    local function chayi_first()
      -- 这张牌不能是对方有的花色里的
      if extra_data[2][card.suit] ~= 0 then return false end
      -- 这张牌不能是和已选的牌花色相同的
      if suitCount(selected)[card.suit] ~= 0 then return false end
      return true
    end

    -- 察异第二种情况的card_filter
    local function chayi_second()
      local A, B
      -- 这张牌是A的，B是另一个人
      if table.contains(data[1][2], to_select) then
        A = 1
        B = 2
      else
        A = 2
        B = 1
      end
      -- 对于这张牌的这个花色，是否已经在选择里选择干净了？另一个人是否还有没被选的这个花色？
      local BTotal = extra_data[B][card.suit]
      local ASelected = suitCount(table.filter(selected, function(c) return table.contains(data[A][2], c) end))
          [card.suit]
      local BSelected = suitCount(table.filter(selected, function(c) return table.contains(data[B][2], c) end))
          [card.suit]
      if ASelected == BSelected then -- 如果被选择的这个花色两边已经相等了，那B只要还有一张没被选的这个花色就行
        return BTotal > BSelected
      elseif ASelected < BSelected then
        -- 如果A选的少一些，那一定可以
        return true
      else
        -- 如果B选的少一些，B剩下的该花色能不能比A多
        return BTotal - BSelected > ASelected
      end
    end

    -- 如果之前选择了对方的牌，就一定是第二种情况
    if #table.filter(selected, function(c) return table.contains(data[2][2], c) end) > 0 then
      return chayi_second()
    end
    -- 如果选择了对方有的花色，就一定是第二种情况
    if #table.filter(selected, function(c) return extra_data[2][Fk:getCardById(c).suit] > 0 end) > 0 then
      return chayi_second()
    end
    -- 如果选择了对方没有的花色，就一定是第一种情况
    if #table.filter(selected, function(c) return extra_data[2][Fk:getCardById(c).suit] == 0 end) > 0 then
      return chayi_first()
    end
    -- 其他的情况，两种可能都有
    return chayi_first() or
        chayi_second()
  end,
  feasible = function(selected, data)
    if #selected == 0 then return true end
    -- 如果选择了对方的牌，那一定就是第二种情况了。计算是否我们的每种花色相等。
    local isTargetSelected = table.find(selected, function(id) return table.contains(data[2][2], id) end)
    if isTargetSelected then
      local suits = { 0, 0, 0, 0 }
      for _, id in ipairs(selected) do
        local card = Fk:getCardById(id)
        if table.contains(data[1][2], id) then -- my card
          suits[card.suit] = suits[card.suit] + 1
        else                                   -- targets card
          suits[card.suit] = suits[card.suit] - 1
        end
      end
      for _, s in ipairs(suits) do
        if s ~= 0 then return false end
      end
      return true
    else -- 如果没选择对方的牌，那一定就是第一种情况了。计算是否没有对方的花色的牌，而且这些牌花色各不相同。
      -- my suits differ
      local suits = { false, false, false, false }
      for _, id in ipairs(selected) do
        local card = Fk:getCardById(id)
        if suits[card.suit] then return false end
        suits[card.suit] = true
      end
      -- his card suits not in
      for _, id in ipairs(data[2][2]) do
        local card = Fk:getCardById(id)
        if suits[card.suit] then return false end
      end
      return true
    end
  end,
  prompt = "#jy_chayi_poxi-prompt"
}

Fk:loadTranslationTable {
  ["jy__phhz"] = [[浦和花子]],
  ["#jy__phhz"] = [[隐匿的天才]],
  ["designer:jy__phhz"] = [[白洲]],
  ["cv:jy__phhz"] = [[无]],
  ["illustrator:jy__phhz"] = [[Nexon]],

  ["jy_nicai"] = [[匿才]],
  [":jy_nicai"] = [[当你不因此技能摸牌时，若你的手牌数为全场唯一最多，你弃置一张牌，否则你可以摸一张牌。]],
  ["#jy_nicai-prompt"] = [[匿才：弃置一张牌]],

  ["jy_chayi"] = [[察异]],
  [":jy_chayi"] = [[其他角色的结束阶段，你可以观看其手牌，然后可以选择一项：①交给其任意张花色不同且其没有该花色的手牌，然后你摸等量的牌；②弃置你与其等量张花色组合相同的手牌。]],
  ["#jy_chayi_poxi-prompt"] = [[察异：仅选择自己手牌则将之交给其并摸等量的牌，否则弃置之]],
  ["jy_chayi_poxi"] = [[察异选牌]],
}

local phhz = General(extension, "jy__phhz", "qun", 3, 3, General.Female)
phhz:addSkill(nicai)
phhz:addSkill(chayi)

-- local zhiheng = fk.CreateActiveSkill {
--   name = "jy_zhiheng",
--   anim_type = "drawcard",
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
--   end,
--   target_num = 0,
--   min_card_num = 1,
--   card_filter = function(self, to_select)
--     return not Self:prohibitDiscard(Fk:getCardById(to_select))
--   end,
--   on_use = function(self, room, effect)
--     local from = room:getPlayerById(effect.from)
--     local hand = from:getCardIds(Player.Hand)
--     local more = #hand > 0
--     for _, id in ipairs(hand) do
--       if not table.contains(effect.cards, id) then
--         more = false
--         break
--       end
--     end
--     room:throwCard(effect.cards, self.name, from, from)
--     room:drawCards(from, #effect.cards, self.name)
--     if from:isAlive() and more then
--       local choice = room:askForChoice(from, { "basic", "trick", "equip" }, self.name, "#jy_zhiheng_choose")
--       local cards = room:getCardsFromPileByRule(".|.|.|.|.|" .. choice, 1, "drawPile")
--       if #cards > 0 then room:obtainCard(effect.from, cards[1], true, fk.ReasonPrey) end
--     end
--   end,
-- }

Fk:addPoxiMethod {
  name = "jy_zhiheng_2",
  card_filter = function(to_select, selected)
    return #selected == 0
  end,
  feasible = function(selected)
    return #selected == 1
  end,
  prompt = function()
    return Fk:translate("#jy_zhiheng_2-prompt")
  end
}

local zhiheng_2 = fk.CreateActiveSkill {
  name = "jy_zhiheng_2",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  min_card_num = 1,
  card_filter = function(self, to_select)
    return not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local hand = from:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end
    room:throwCard(effect.cards, self.name, from, from)
    room:drawCards(from, #effect.cards, self.name)
    if from:isAlive() and more then
      local cards = room:getNCards(#effect.cards)
      local result = room:askForPoxi(from, "jy_zhiheng_2",
        { { "pile_draw", cards } })
      if #result > 0 then
        table.removeOne(cards, result[1])
        for i = #cards, 1, -1 do
          table.insert(room.draw_pile, 1, cards[i])
        end
        local c = result[1]
        room:obtainCard(effect.from, c, false, fk.ReasonJustMove)
      end
    end
  end,
}

-- Fk:addPoxiMethod {
--   name = "jy_wenmou",
--   card_filter = function(to_select, selected)
--     return #selected == 0
--   end,
--   feasible = function(selected)
--     return #selected == 1
--   end,
--   prompt = function()
--     return Fk:translate("#jy_wenmou-prompt")
--   end
-- }

-- local wenmou = fk.CreateTriggerSkill {
--   name = "jy_wenmou",
--   anim_type = "control",
--   events = { fk.TargetSpecified },
--   can_trigger = function(self, event, target, player, data)
--     if data.to == player.id and player:hasSkill(self) and
--         data.card and (data.card.trueName == "slash" or data.card.trueName == "duel") then
--       self.armors = {}
--       for _, c in ipairs(player.room.draw_pile) do
--         local card = Fk:getCardById(c)
--         if card.type == Card.TypeEquip and card.sub_type == Card.SubtypeArmor then
--           table.insert(self.armors, c)
--         end
--       end
--       return #self.armors > 0
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:loseHp(player, 1, self.name)
--     if player:isAlive() then
--       local cards = room:askForPoxi(player, "jy_wenmou", {
--         { "pile_draw", self.armors } })
--       if #cards == 0 then return false end
--       local card = Fk:getCardById(cards[1])
--       if not player.dead and not player:isProhibited(player, card) and not player:prohibitUse(card) then
--         room:useCard({
--           from = player.id,
--           tos = { { player.id } },
--           card = card,
--         })
--       end
--     end
--   end,
-- }

local quanyu = fk.CreateTriggerSkill {
  name = "jy_quanyu$",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, max = findHandCardMinMax(table.filter(room:getAlivePlayers(), function(p) return p.kingdom == "wu" end))
    local max_targets = table.map(table.filter(room:getAlivePlayers(), function(p)
      return p.kingdom == "wu" and #p:getCardIds("h") == max
    end), Util.IdMapper)
    if #max_targets > 1 then
      local result = room:askForChoosePlayers(player, max_targets, 1, 1, "#jy_quanyu_discard-prompt", self.name)
      if #result > 0 then
        self.cost_data = result[1]
        return true
      end
    elseif #max_targets == 1 then
      self.cost_data = max_targets[1]
      return room:askForSkillInvoke(player, self.name)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local p_player = room:getPlayerById(self.cost_data)
    local cid = room:askForCardChosen(player, p_player, "hej", self.name)
    room:throwCard({ cid }, self.name, p_player, player)

    local min, _ = findHandCardMinMax(table.filter(room:getAlivePlayers(), function(p) return p.kingdom == "wu" end))
    local min_targets = table.map(table.filter(room:getAlivePlayers(), function(p)
      return #p:getCardIds("h") == min
    end), Util.IdMapper)
    local result = room:askForChoosePlayers(player, min_targets, 1, 1, "#jy_quanyu_draw-prompt", self.name)
    if #result > 0 then
      room:getPlayerById(result[1]):drawCards(1, self.name)
    end
  end,
}

local qiongtu = fk.CreateViewAsSkill {
  name = "jy_qiongtu",
  anim_type = "support",
  pattern = "analeptic",
  card_filter = Util.FalseFunc,
  before_use = function(self, player)
    local room = player.room
    local choices = player:getAvailableEquipSlots()
    if #choices == 0 then return end
    local choice = room:askForChoice(player, choices, self.name, "#jy_qiongtu-ask")
    room:abortPlayerArea(player, choice)
    if player.dead then return end
  end,
  view_as = function(self)
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) < 1
        and (#player:getAvailableEquipSlots() > 0)
  end,
  enabled_at_response = function(self, player, response)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) < 1
        and (#player:getAvailableEquipSlots() > 0) and not response
  end,
}

local sunquan = General(extension, "jy__sunquan", "wu", 4)
sunquan:addSkill(zhiheng_2)
sunquan:addSkill(qiongtu)
sunquan:addSkill(quanyu)

Fk:loadTranslationTable {
  ["jy__sunquan"] = [[谋孙权]],
  ["#jy__sunquan"] = [[年轻的贤君]],
  ["designer:jy__sunquan"] = [[rolin]],
  ["cv:jy__sunquan"] = [[官方]],
  ["illustrator:jy__sunquan"] = [[官方]],
  ["~jy__sunquan"] = [[父亲，大哥，仲谋愧矣！]],

  ["jy_zhiheng"] = [[制衡]],
  [":jy_zhiheng"] = [[出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌。若你以此法弃置的牌中包括所有手牌，你可以从牌堆获得一张你指定类型的牌。]],
  ["#jy_zhiheng_choose"] = [[制衡：选择一种类型的牌获得]],
  ["$jy_zhiheng1"] = [[容我三思。]],
  ["$jy_zhiheng2"] = [[且慢！]],

  ["jy_zhiheng_2"] = [[制衡]],
  [":jy_zhiheng_2"] = [[出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌。若你以此法弃置的牌中包括所有手牌，你可以观看牌堆顶等量张牌并获得其中一张。]],
  ["jy_zhiheng_2_top"] = [[置于牌堆顶]],
  ["jy_zhiheng_2_get"] = [[获得]],
  ["@@jy_zhiheng_2-inhand-turn"] = [[制衡]],
  ["#jy_zhiheng_2-prompt"] = [[制衡：获得一张牌]],
  ["$jy_zhiheng_21"] = [[容我三思。]],
  ["$jy_zhiheng_22"] = [[且慢！]],

  ["jy_wenmou"] = [[稳谋]],
  [":jy_wenmou"] = [[当你成为【杀】或【决斗】的目标时，若牌堆中有防具牌，你可以失去一点体力观看牌堆中所有防具牌并使用其中一张。]],
  ["#jy_wenmou-prompt"] = [[稳谋：选择一张防具牌使用]],
  ["$jy_wenmou1"] = [[好舒服啊！]],

  ["jy_qiongtu"] = [[穷图]],
  [":jy_qiongtu"] = [[每回合限一次，你可以废除一个装备栏视为使用一张【酒】。]],
  ["#jy_qiongtu-ask"] = [[穷图：废除一个装备栏，视为使用一张【酒】]],
  ["$jy_qiongtu1"] = [[好舒服啊！]],

  ["jy_quanyu"] = [[权御]],
  [":jy_quanyu"] = [[主公技，准备阶段，你可以弃置一名手牌数最多的吴势力角色区域里的一张牌，然后你可以令一名手牌数最少的吴势力角色摸一张牌。]],
  ["#jy_quanyu_discard-prompt"] = [[权御：你可以弃置一名手牌数最多的吴势力角色区域里的一张牌]],
  ["#jy_quanyu_draw-prompt"] = [[权御：你可以令一名手牌数最少的吴势力角色摸一张牌]],
  ["$jy_quanyu1"] = [[有汝辅佐，甚好！]],
}

local jianyan = fk.CreateTriggerSkill {
  name = "jy_jianyan",
  events = { fk.PreCardEffect },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target and target:getMark("jy_jianyan-turn") == 1 and
        target.phase ~= Player.NotActive and
        not data.card.is_jy_jianyan and (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    if player:isAlive() then
      if player.room:askForChoice(player, { "#jy_jianyan_1", "#jy_jianyan_2" }, self.name, "#jy_jianyan-ask:" .. target.id .. "::" .. Fk:translate(data.card.name)) == "#jy_jianyan_1" then
        data.card.is_jy_jianyan = true
      else
        player.room:obtainCard(player, data.card, false, fk.ReasonPrey, player.id)
        if data.card.type == Card.TypeTrick then
          player.room:changeShield(player, 1)
        end
        return true
      end
    end
  end,
  refresh_events = { fk.Damage, fk.CardUsing, fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Damage then
        return data.card and data.card.is_jy_jianyan
      elseif event == fk.CardUsing then
        return target.phase ~= Player.NotActive and
            (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
      else
        return target.phase ~= Player.NotActive and
            (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and
            data.card.is_jy_jianyan
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.Damage then
      player:drawCards(data.damage)
    elseif event == fk.CardUsing then
      player.room:addPlayerMark(target, "jy_jianyan-turn")
    else
      player.room:doCardUseEffect(data)
      data.card.is_jy_jianyan = false
    end
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
  ["#jy__luotong"] = [[超模怪兽（但被我削了）]],
  ["designer:jy__luotong"] = [[贾文和]],
  ["cv:jy__luotong"] = [[无]],

  ["jy_jianyan"] = [[谏言]],
  [":jy_jianyan"] = [[一名角色于其回合内首次使用基本牌或普通锦囊牌时，你可以失去一点体力并选择一项：①此牌额外结算一次，其每造成一点伤害时，你摸一张牌；②此牌无效且你获得此牌，若为锦囊牌，你获得一点护甲。]],
  ["#jy_jianyan_1"] = [[此牌额外结算一次，其每造成一点伤害时，你摸一张牌]],
  ["#jy_jianyan_2"] = [[此牌无效且你获得此牌，若为锦囊牌，你获得一点护甲]],
  ["#jy_jianyan-ask"] = [[谏言：选择要对 %src 使用的 %arg 发动的效果]],

  ["jy_jimin"] = [[济民]],
  [":jy_jimin"] = [[锁定技，每名角色限一次，一名角色于其回合内使用【杀】指定你为目标时，此【杀】对你无效，然后你摸两张牌。]],
}

local guanxi = fk.CreateTriggerSkill {
  name = "jy_guanxi",
  mute = true,

  refresh_events = { fk.CardUseFinished },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player:getMark("@jy_guanxi") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@jy_guanxi", -1)
  end,

  events = { fk.RoundStart, fk.CardUseFinished },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.RoundStart then
        return true
      else
        return target == player and player:getMark("@jy_guanxi") == 0 and
            player:getMark("jy_guanxi_used-round") == 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.RoundStart then
      return player.room:askForSkillInvoke(player, self.name)
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.RoundStart then
      player:broadcastSkillInvoke(self.name, math.random(2))
      room:notifySkillInvoked(player, self.name, "control")
      local guanxing = room:askForGuanxing(player, room:getNCards(3))
      if #guanxing["bottom"] > 0 then
        room:setPlayerMark(player, "@jy_guanxi", #guanxing["bottom"])
      else
        room:setPlayerMark(player, "jy_guanxi_used-round", true)
      end
    else
      player:broadcastSkillInvoke(self.name, math.random(3, 4))
      room:notifySkillInvoked(player, self.name, "support")
      room:setPlayerMark(player, "jy_guanxi_used-round", true) -- 必须要先设这个，不然死循环
      -- 洞烛先机未必开了
      room:doIndicate(player.id, { room.current.id })
      room:useVirtualCard("foresight", nil, room.current, room.current, self.name)
    end
  end,
}

local huilan = fk.CreateViewAsSkill {
  name = "jy_huilan",
  anim_type = "defensive",
  pattern = "nullification",
  prompt = "#jy_huilan-prompt",
  view_as = function(self, cards)
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local min, max = findHandCardMinMax(player.room:getAlivePlayers())
    if #player.room:askForDiscard(player, 2, 2, true, self.name, true, nil, "#jy_huilan-ask:::" .. min .. ":" .. max) == 0 then
      player:drawCards(2, self.name)
    end
  end,
  after_use = function(self, player, use)
    local min, max = findHandCardMinMax(player.room:getAlivePlayers())
    local card_num = #player:getCardIds("h")
    if card_num == min then
      player:drawCards(max - min, self.name)
    elseif card_num == max then
      player.room:askForDiscard(player, max - min, max - min, false, self.name, false, nil, "#jy_huilan-discard:::" ..
        min)
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  enabled_at_response = function(self, player, response)
    return player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end
}

-- 本武将需开启gamemode包（https://gitee.com/qsgs-fans/gamemode）才能游玩
local fuxuan = General(extension, "jy__fuxuan", "qun", 3, 3, General.Female)
fuxuan:addSkill(guanxi)
fuxuan:addSkill(huilan)

Fk:loadTranslationTable {
  ["jy__fuxuan"] = [[符玄]],
  ["#jy__fuxuan"] = [[法眼无遗]],
  ["designer:jy__fuxuan"] = [[三秋]],
  ["cv:jy__fuxuan"] = [[花玲]],
  ["illustrator:jy__fuxuan"] = [[米哈游]],
  ["~jy__fuxuan"] = [[事已前定……么……]],

  ["jy_guanxi"] = [[观歙]],
  [":jy_guanxi"] = [[每轮开始时，你可以卜算3。若如此做，本轮你使用第X张牌结算后，当前回合角色视为使用【洞烛先机】（X为你卜算时置于牌堆底的牌数）。]],
  ["@jy_guanxi"] = [[观歙]],
  ["$jy_guanxi1"] = [[以额间之眼观之……]],
  ["$jy_guanxi2"] = [[本座先卜上一卦。]],
  ["$jy_guanxi3"] = [[如我所愿。]],
  ["$jy_guanxi4"] = [[卦象之内。]],

  ["jy_huilan"] = [[会览]],
  [":jy_huilan"] = [[每轮限一次，你可以摸两张牌或弃两张牌，视为使用【无懈可击】。然后若你的手牌数为全场最多，你弃至全场最少；若你的手牌数为全场最少，你摸至全场最多。]],
  ["#jy_huilan-prompt"] = [[会览：声明使用【无懈可击】，然后摸牌或弃牌]],
  ["#jy_huilan-ask"] = [[会览：弃两张牌，或点击取消摸两张牌。当前手牌数全场最少：%arg，全场最多：%arg2]],
  ["#jy_huilan-discard"] = [[会览：将手牌弃至 %arg 张]],
  ["$jy_huilan1"] = [[相与为一。]],
  ["$jy_huilan2"] = [[上下相易。]],
  ["$jy_huilan3"] = [[否极泰来。]],
}

local zhanshu = fk.CreateTriggerSkill {
  name = "jy_zhanshu",
  anim_type = "offensive",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and
        target.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "#jy_zhanshu_viewas", "#jy_zhanshu-use", true)
    self.cost_data = dat
    return success
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("duel")
    card:addSubcards(self.cost_data.cards)
    card.skillName = self.name
    room:useCard({
      from = player.id,
      tos = table.map(self.cost_data.targets, function(p) return { p } end), -- TODO: 这有啥用？
      card = card,
    })
  end,
}
local zhanshu_viewas = fk.CreateViewAsSkill {
  name = "#jy_zhanshu_viewas",
  anim_type = "offensive",
  pattern = "duel",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local c = Fk:cloneCard("duel")
    c.skillName = self.name
    return c
  end,
}
zhanshu:addRelatedSkill(zhanshu_viewas)

local zixing = fk.CreateTriggerSkill {
  name = "jy_zixing",
  anim_type = "drawcard",
  events = { fk.CardUseFinished, fk.CardRespondFinished },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.responseToEvent and data.responseToEvent.from == player.id and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#jy_zixing-prompt:" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    player.room:setPlayerMark(target, "jy_zixing-phase", true)
  end,
}
local zixing_prohibit = fk.CreateProhibitSkill {
  name = "#jy_zixing_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:hasSkill(self) and to:getMark("jy_zixing-phase") ~= 0
  end,
}
zixing:addRelatedSkill(zixing_prohibit)

local yzls = General(extension, "jy__yzls", "shu", 4, 4, General.Female)
yzls:addSkill(zhanshu)
yzls:addSkill(zixing)

Fk:loadTranslationTable {
  ["jy__yzls"] = [[宇泽玲纱]],
  ["#jy__yzls"] = [[正义自警团员]],
  ["designer:jy__yzls"] = [[白洲]],
  ["cv:jy__yzls"] = [[根本京里]],
  ["illustrator:jy__yzls"] = [[seu]],
  ["~jy__yzls"] = [[唔……抱歉……]],

  ["jy_zhanshu"] = [[战书]],
  ["#jy_zhanshu_viewas"] = [[战书]],
  [":jy_zhanshu"] = [[出牌阶段开始时，你可以视为使用【决斗】。]],
  ["#jy_zhanshu-use"] = [[战书：你可以视为使用【决斗】]],
  ["$jy_zhanshu1"] = [[在此参上！]],
  ["$jy_zhanshu2"] = [[一决胜负！]],

  ["jy_zixing"] = [[自省]],
  ["#jy_zixing-prompt"] = [[自省：你可以摸两张牌，然后本阶段 %src 不是你使用牌的合法目标]],
  [":jy_zixing"] = [[一名角色使用或打出牌响应你的牌时，你可以摸两张牌，然后本阶段其不是你使用牌的合法目标。]],
  ["$jy_zixing1"] = [[啊……难道说太大声了吗？影响到您了，对不起！]],
  ["$jy_zixing2"] = [[果……果然还是算了吧……会被认为是奇怪的人……]],
}

local suzhan = fk.CreateActiveSkill {
  name = "jy_suzhan",
  mute = true,
  prompt = "#jy_suzhan-prompt",
  -- 注意，can_use因为是在本地判定，所以用的是ClientPlayer，没有ServerPlayer那些函数
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
        #table.filter(Fk:currentRoom().alive_players, function(p) return #p:getCardIds("h") == 0 end) > 0
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards, card, extra_data)
    if #selected == 1 then return false end
    return Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  interaction = function(self)
    return UI.ComboBox { choices = { "摸一张牌", "摸两张牌" }, default = "摸两张牌" }
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke(self.name, math.random(3))
    room:notifySkillInvoked(player, self.name, "support")
    local n
    if self.interaction.data == "摸一张牌" then
      n = 1
    else
      n = 2
    end
    local to = room:getPlayerById(effect.tos[1])
    to:drawCards(n, self.name, "bottom")
    room:setPlayerMark(to, "jy_suzhan_" .. player.id .. "-turn", n) -- 先用这种笨办法吧，哈希表用起来不太对的样子
  end,
}
local suzhan_trigger = fk.CreateTriggerSkill {
  name = "#jy_suzhan_trigger",
  mute = true,
  frequency = Skill.Compulsory,
  events = { fk.AfterCardsMove },
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    -- if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      local from = room:getPlayerById(move.from)
      if from and from:getMark("jy_suzhan_" .. player.id .. "-turn") ~= 0 then
        self.cost_data = from
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return not from.dead and from:isKongcheng()
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local from = self.cost_data
    player:broadcastSkillInvoke("jy_suzhan", math.random(4, 5))
    player.room:notifySkillInvoked(player, "jy_suzhan", "drawcard")
    player:drawCards(2 * from:getMark("jy_suzhan_" .. player.id .. "-turn"), self.name)
    player.room:setPlayerMark(from, "jy_suzhan_" .. player.id .. "-turn", 0)
  end,
}
suzhan:addRelatedSkill(suzhan_trigger)

local zhuojing = fk.CreateViewAsSkill {
  name = "jy_zhuojing",
  anim_type = "defensive",
  pattern = "peach",
  prompt = "#jy_zhuojing-prompt",
  view_as = function(self)
    local card = Fk:cloneCard("peach")
    card.skillName = self.name
    card:addSubcards(Self:getCardIds("h"))
    return card
  end,
  after_use = function(self, player, use)
    if use.card.color == Card.NoColor and is_general_skill(player, self.name) then
      local room = player.room
      -- 选择一名有牌的角色。如果没有任何一个人满足要求，就不让他选。
      local targets = table.map(
        table.filter(room:getOtherPlayers(player), function(p) return #p:getCardIds("he") > 0 end),
        Util.IdMapper)
      if #targets == 0 then return end
      local result = room:askForChoosePlayers(player, targets, 1, 1, "#jy_zhuojing-choose:::" .. #use.card.subcards)
      if #result == 0 then return end
      local target = room:getPlayerById(result[1])
      room:askForDiscard(target, #use.card.subcards, #use.card.subcards, true, self.name, false, nil,
        "#jy_zhuojing-discard:" .. player.id .. "::" .. #use.card.subcards)
      local feasible = {}
      local total = {}
      -- 通过缩减描述达到更好的用户体验。
      -- 可以发动素绽？
      if #table.filter(player.room.alive_players, function(p) return #p:getCardIds("h") == 0 end) > 0 then
        table.insert(feasible, "jy_suzhan-short")
        table.insert(total, "jy_suzhan-short")
      end
      -- 可以发动濯荆？
      if target:canUse(Fk:cloneCard("peach")) and #target:getCardIds("h") ~= 0 then
        if is_general_skill(target, "jy_zhuojing") then --
          table.insert(feasible, "jy_zhuojing-long")    -- 只是相对short稍微长一点
          table.insert(total, "jy_zhuojing-long")
        else
          table.insert(feasible, "jy_zhuojing-short")
          table.insert(total, "jy_zhuojing-short")
        end
      else
        table.insert(total, "jy_zhuojing-short")
      end
      if #feasible > 0 then
        local skill_name = room:askForChoice(target, feasible, "#jy_zhuojing-skill",
          "#jy_zhuojing-skill:" .. player.id, true, total)

        -- 因为上面可能是传的short，在这里把short翻译回来
        if skill_name == "jy_suzhan-short" then skill_name = "jy_suzhan" end
        if skill_name == "jy_zhuojing-short" or skill_name == "jy_zhuojing-long" then skill_name = "jy_zhuojing" end

        local success, dat = room:askForUseActiveSkill(target, skill_name,
          "#jy_zhuojing-use::" .. target.id .. ":" .. Fk:translate(skill_name))
        if skill_name == "jy_zhuojing" and success and dat.cards then
          assert(dat)
          local card = Fk:cloneCard("peach")
          -- card:addSubcards(dat.cards)
          card:addSubcards(target:getCardIds("h")) -- 因为zhuojing没有选手牌这个动作，手牌数据不会传过来，所以在这里手动处理
          card.skillName = self.name
          room:useCard {
            from = target.id,
            tos = dat.targets,
            card = card,
          }
        end
      else
        room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zhuojing-fail"), { player, target })
      end
    end
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function(self, player, response)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end
}

local luocha = General(extension, "jy__luocha", "qun", 3, 4)
luocha:addSkill(suzhan)
luocha:addSkill(zhuojing)

Fk:loadTranslationTable {
  ["jy__luocha"] = [[罗刹]],
  ["#jy__luocha"] = [[化外羁旅]],
  ["designer:jy__luocha"] = [[三秋]],
  ["cv:jy__luocha"] = [[赵路]],
  ["illustrator:jy__luocha"] = [[米哈游]],
  ["~jy__luocha"] = [[没能……实现啊……]],

  ["jy_suzhan"] = [[素绽]],
  [":jy_suzhan"] = [[出牌阶段限一次，你可以令一名没有手牌的角色从牌堆底摸至多两张牌，本回合其下次失去最后的手牌后，你摸两倍的牌。]],
  ["jy_suzhan-short"] = [[素绽]],
  [":jy_suzhan-short"] = [[令一名没有手牌的角色从牌堆底摸至多两张牌，其本回合下次失去最后的手牌后，你摸两倍的牌。]],
  ["#jy_suzhan-prompt"] = [[素绽：选择一名没有手牌的角色摸一或两张牌，其本回合下次失去最后的手牌后你摸两倍的牌]],
  ["@jy_suzhan-round"] = [[<font color="yellow">素绽</font>]],
  ["$jy_suzhan1"] = [[白花盛放。]],
  ["$jy_suzhan2"] = [[领受天赐。]],
  ["$jy_suzhan3"] = [[喜欢便拿去吧。]],
  ["$jy_suzhan4"] = [[你看，这不就回来了么。]],
  ["$jy_suzhan5"] = [[清算的时刻到了。]],

  ["jy_zhuojing"] = [[濯荆]],
  [":jy_zhuojing"] = [[每回合限一次，你可以将所有手牌当【桃】使用。若此【桃】无颜色且你武将牌上有该技能，你可以令一名其他角色弃置等量牌，然后其可以视为发动〖素绽〗或〖濯荆〗。]],
  ["jy_zhuojing-long"] = [[濯荆]],
  [":jy_zhuojing-long"] = [[将所有手牌当【桃】使用。若此【桃】无颜色，你可以令一名其他角色弃置等量牌，然后其可以视为发动〖素绽〗或〖濯荆〗。]],
  ["jy_zhuojing-short"] = [[濯荆]],
  [":jy_zhuojing-short"] = [[将所有手牌当【桃】使用。]],
  ["#jy_zhuojing-prompt"] = [[濯荆：你可以将所有手牌当【桃】使用]],
  ["#jy_zhuojing-choose"] = [[濯荆：你可以令一名角色弃置 %arg 张牌，随后其可以视为发动〖素绽〗或〖濯荆〗]],
  ["#jy_zhuojing-discard"] = [[濯荆：弃置 %arg 张牌，随后你可以令一名没有手牌的角色摸牌或将所有手牌当【桃】使用]],
  ["#jy_zhuojing-skill"] = [[濯荆发动]],
  ["#jy_zhuojing-use"] = [[濯荆：%dest 令你发动 %arg，请指定目标]],
  ["#jy_zhuojing-fail"] = [[濯荆：不满足〖素绽〗或〖濯荆〗的发动条件，无法发动]],
  ["$jy_zhuojing1"] = [[永眠非终焉……]],
  ["$jy_zhuojing2"] = [[逝者将再临！]],
}

local zhaoyong = fk.CreateActiveSkill {
  name = "jy_zhaoyong",
  switch_skill_name = "jy_zhaoyong",
  anim_type = "switch",
  prompt = function(self, selected_cards, selected_targets)
    local card_name
    -- 因为此时还没有发动技能，所以不需要计算下一步
    if Self:getSwitchSkillState(self.name) == fk.SwitchYang then
      card_name = Fk:translate("await_exhausted")
    else
      card_name = Fk:translate("fire_attack")
    end
    return "#jy_zhaoyong:::" .. card_name
  end,
  can_use = function(self, player)
    local card_name
    if Self:getSwitchSkillState(self.name) == fk.SwitchYang then
      card_name = "await_exhausted"
    else
      card_name = "fire_attack"
    end
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
        U.canUseCardTo(player.room, player, player, Fk:cloneCard(card_name)) -- 虽然是传的ClientPlayer，但是可以用！
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    from:turnOver()
    local card_name
    if from:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      card_name = "await_exhausted"
    else
      card_name = "fire_attack"
    end
    if from:isAlive() then
      room:useVirtualCard(card_name, nil, from, from, self.name, false)
    end
  end,
}
local zhaoyong_trigger = fk.CreateTriggerSkill {
  name = "#jy_zhaoyong_trigger",
  events = { fk.AfterCardsMove },
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self) then
      -- 因为火攻或以逸待劳而弃牌，而且他们的父事件是zhaoyong
      local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        if use and use.card.name == "fire_attack" or use.card.name == "await_exhausted" then
          local ep = e.parent
          if ep and ep.event == GameEvent.SkillEffect then
            local _skill = ep.data[3]
            local skill = _skill.main_skill and _skill.main_skill or _skill
            if skill.name == "jy_zhaoyong" then
              for _, move in ipairs(data) do
                if move.from == player.id then
                  for _, info in ipairs(move.moveInfo) do
                    if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and move.from and (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and room:getCardArea(info.cardId) == Card.DiscardPile and Fk:getCardById(info.cardId).color == Card.Red then
                      return true
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local choices = { "#jy_zhaoyong_draw_to_4", "#jy_zhaoyong_reset" }
    local hand_num = #player:getCardIds("h")
    if hand_num >= 4 then
      table.removeOne(choices, "#jy_zhaoyong_draw_to_4")
    end
    local choice = player.room:askForChoice(player, choices, "jy_zhaoyong",
      "#jy_zhaoyong_choose", false, { "#jy_zhaoyong_draw_to_4", "#jy_zhaoyong_reset" })
    if choice == "#jy_zhaoyong_draw_to_4" then
      player:drawCards(4 - hand_num, self.name)
    else
      player:setSkillUseHistory("jy_zhaoyong", 0, Player.HistoryPhase)
    end
  end,
}
zhaoyong:addRelatedSkill(zhaoyong_trigger)

local dingfei = fk.CreateTriggerSkill {
  name = "jy_dingfei",
  anim_type = "defensive",
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.from and target == player and
        player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#jy_dingfei-prompt::" .. data.from.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 统计花色
    local hands = player:getCardIds("h")
    player:showCards(hands)

    local handsSuit = suitCount(hands)
    local hint = ""
    for c, s in ipairs(handsSuit) do
      if s == 0 then
        if c == Card.Spade then
          hint = hint .. [[♠ ]]
        elseif c == Card.Heart then
          hint = hint .. [[<font color="red">♥</font> ]]
        elseif c == Card.Club then
          hint = hint .. [[♣ ]]
        elseif c == Card.Diamond then
          hint = hint .. [[<font color="red">♦️</font> ]]
        end
      end
    end
    local is_4_suits = true
    for i = 1, 4 do
      if handsSuit[i] == 0 then
        is_4_suits = false
        break
      end
    end
    if is_4_suits then
      player.room:askForDiscard(data.from, 1, #data.from:getCardIds("h"), false,
        self.name,
        true, nil,
        "#jy_dingfei-discard-no-recover")
    else
      local discardedSuit = suitCount(
        player.room:askForDiscard(data.from, 1, #data.from:getCardIds("h"), false, self.name,
          true, nil,
          "#jy_dingfei-discard:" .. player.id .. "::" .. hint))
      for i = 1, 4 do
        if handsSuit[i] == 0 and discardedSuit[i] == 0 then
          room:recover({
            who = player,
            num = 1,
            recoverBy = player,
            skillName = self.name,
          })
          break
        end
      end
    end
  end,
}

local gnf = General(extension, "jy__guinaifen", "qun", 3, 3, General.Female)
gnf:addSkill(zhaoyong)
gnf:addSkill(dingfei)

Fk:loadTranslationTable {
  ["jy__guinaifen"] = "桂乃芬",
  ["#jy__guinaifen"] = "「街头行为表演艺术家」",
  ["designer:jy__guinaifen"] = "三秋",
  ["cv:jy__guinaifen"] = "小敢",
  ["illustrator:jy__guinaifen"] = "米哈游",
  ["~jy__guinaifen"] = [[哎呀，演砸了……]],

  ["jy_zhaoyong"] = "肇涌",
  [":jy_zhaoyong"] = [[转换技，出牌阶段限一次，你可以翻面并视为对自己使用①【以逸待劳】；②【火攻】（你需有手牌）。若你以此法弃置了红色牌，你可以将手牌摸至四张或令此技能视为未发动过。]],
  ["#jy_zhaoyong"] = [[肇涌：翻面并视为对自己使用【%arg】（弃置<font color="red">红色牌</font>以触发后续效果）]],
  ["#jy_zhaoyong_choose"] = "肇涌：选择后续效果",
  ["#jy_zhaoyong_draw_to_4"] = "将手牌摸至四张",
  ["#jy_zhaoyong_reset"] = "此技能视为未发动过",
  ["$jy_zhaoyong1"] = "恭喜发财！",
  ["$jy_zhaoyong2"] = "花开富贵！",

  ["jy_dingfei"] = "鼎沸",
  [":jy_dingfei"] = [[每回合限一次，你受到伤害后，可以展示所有手牌并令伤害来源弃置手牌。若你展示的手牌与其弃置的牌花色一共不足四种，你回复一点体力。]],
  ["#jy_dingfei-prompt"] = [[鼎沸：是否展示手牌并令 %dest 弃牌，你有概率回复一点体力]],
  ["#jy_dingfei-discard"] = [[鼎沸：弃置 %arg手牌至少各一张，否则 %src 回复一点体力]], -- 这里%arg后没留空格是故意的，因为%arg里本身最后就带空格
  ["#jy_dingfei-discard-no-recover"] = [[鼎沸：%src 令你弃任意张牌，你可以不弃，这次不会有什么效果]],
  ["$jy_dingfei1"] = [[哎哟，您可别放水。]],
  ["$jy_dingfei2"] = [[幸亏我练过！]],
  ["$jy_dingfei3"] = [[还来劲了啊你！]],
}

local duwu = fk.CreateTriggerSkill {
  name = "jy_duwu",
  anim_type = "control",
  events = { fk.EventPhaseProceeding },
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(2, self.name, "bottom")
    local room = player.room
    -- 将一张放到场上
    if player.dead or player:isNude() then return end
    local _, dat = room:askForUseActiveSkill(player, "#jy_duwu_move", "#jy_duwu_card", false)
    local card_id = dat and dat.cards[1] or player:getCardIds("he")[1]
    local choice = dat and dat.interaction or "Top"
    if choice == "Field" then
      assert(dat)
      local to = room:getPlayerById(dat.targets[1])
      local card = Fk:getCardById(card_id)
      if card.type == Card.TypeEquip then
        room:moveCardTo(card, Card.PlayerEquip, to, fk.ReasonPut, "jy_duwu", "", true, player.id)
        if not to.dead then
          to:reset()
        end
      elseif card.sub_type == Card.SubtypeDelayedTrick then
        -- FIXME : deal with visual DelayedTrick
        room:moveCardTo(card, Card.PlayerJudge, to, fk.ReasonPut, "jy_duwu", "", true, player.id)
      end
    else
      local drawPilePosition = 1
      if choice == "Bottom" then
        drawPilePosition = -1
      end
      room:moveCards({
        ids = {card_id},
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = "jy_duwu",
        drawPilePosition = drawPilePosition,
        moveVisible = true
      })
    end
  end,
}

local duwu_move = fk.CreateActiveSkill{
  name = "#jy_duwu_move",
  mute = true,
  card_num = 1,
  max_target_num = 1,
  interaction = function()
    return UI.ComboBox {choices = {"Field", "Top"}}
  end,
  card_filter = function(self, to_select, selected, targets)
    if #selected == 0 then
      if self.interaction.data == "Field" then
        local card = Fk:getCardById(to_select)
        return card.type == Card.TypeEquip or card.sub_type == Card.SubtypeDelayedTrick
      end
      return true
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and self.interaction.data == "Field" and #selected_cards == 1 then
      local card = Fk:getCardById(selected_cards[1])
      local target = Fk:currentRoom():getPlayerById(to_select)
      if card.type == Card.TypeEquip then
        return target:hasEmptyEquipSlot(card.sub_type)
      elseif card.sub_type == Card.SubtypeDelayedTrick then
        return not target:isProhibited(target, card)
      end
    end
    return false
  end,
  feasible = function(self, selected, selected_cards)
    if #selected_cards == 1 then
      if self.interaction.data == "Field" then
        return #selected == 1
      else
        return true
      end
    end
  end,
}
duwu:addRelatedSkill(duwu_move)

local aocai = fk.CreateTriggerSkill{
  name = "jy_aocai",
  events = {fk.EventPhaseChanging, fk.EventPhaseProceeding, fk.TargetConfirmed},
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.EventPhaseChanging then
      return target == player and data.to == Player.Draw
    elseif event == fk.EventPhaseProceeding then
      return target == player and player:hasSkill(self) and player.phase == Player.Start
    else
      if data.card and data.card.is_damage_card then
        for _, v in pairs(AimGroup:getAllTargets(data.tos)) do
          if v == player.id then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.EventPhaseChanging then
      room:notifySkillInvoked(player, self.name, "negative")
      return true
    else
      room:notifySkillInvoked(player, self.name, "drawcard")
      -- 直接使用观星当然简单多了，只是我觉得要多点两下有点呆。使用五谷丰登又会导致切换角色的时候烧条。总之不管怎么样都怪。
      -- 观星
      -- local result = room:askForGuanxing(player, room:getNCards(3), nil, {1, 1}, "jy_aocai", true, {"Top", "#jy_aocai_get"})
      -- local top, cid = result.top, result.bottom[1]
      -- for i = #top, 1, -1 do
      --   table.insert(room.draw_pile, 1, top[i])
      -- end
      -- room:obtainCard(player, cid, false, fk.ReasonPrey, player.id, self.name)
      -- 五谷丰登
      local card_ids = room:getNCards(2)
      room:fillAG(player, card_ids)
      local card_id = room:askForAG(player, card_ids, false, self.name)
      table.removeOne(card_ids, card_id)
      room:obtainCard(player, card_id, false, fk.ReasonPrey, player.id, self.name)
      for i = #card_ids, 1, -1 do
        table.insert(room.draw_pile, 1, card_ids[i])
      end
      room:closeAG()
    end
  end,
}

local qianlv = fk.CreateViewAsSkill {
  name = "jy_qianlv",
  anim_type = "control",
  prompt = "#jy_qianlv",
  pattern = ".",
  interaction = function (self)
    local all = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeTrick and card.sub_type ~= Card.SubtypeDelayedTrick) or card.type == Card.TypeBasic and not card.is_derived then
        table.insertIfNeed(all, card.name)
      end
    end
    local mark2 = Self:getMark("@$jy_qianlv_names") -- 这是禁止继续使用的
    if mark2 == 0 then mark2 = {} end
    local choices, all_choices = {}, {}
    -- local choices = {}
    for _, name in ipairs(all) do
      local card = Fk:cloneCard(name)
      card.skillName = self.name
      if (Fk.currentResponsePattern == nil and card.skill:canUse(Self, card) and not Self:prohibitUse(card)) or
          (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)) then
        table.insertIfNeed(all_choices, name)
        if not table.contains(mark2, name) then
          table.insertIfNeed(choices, name)
        end
      end
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type ~= Card.TypeBasic
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or self.interaction.data == nil then return nil end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  after_use = function(self, player, use)
    local mark = player:getMark("@$jy_qianlv_names")
    if mark == 0 then mark = {} end
    table.insertIfNeed(mark, use.card.name)
    player.room:setPlayerMark(player, "@$jy_qianlv_names", mark)
  end,
  enabled_at_response = function(self, player, response)
    if response then return false end -- 只能使用，不能打出
    if player:isNude() then return false end
    local used = player:getMark("@$jy_qianlv_names")
    if used == 0 then return true end
    for _, name in ipairs(used) do
      if Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name)) then return false end
    end
    return true
  end,
}

local mzgk = General(extension, "jy__mou__zhugeke", "wu", 3, 3)
mzgk:addSkill(aocai)
mzgk:addSkill(duwu)
mzgk:addSkill(qianlv)

Fk:loadTranslationTable {
  ["jy__mou__zhugeke"] = "谋诸葛恪",
  ["#jy__mou__zhugeke"] = "雄才大略",
  ["designer:jy__mou__zhugeke"] = "rolin",

  ["jy_aocai"] = "瑕玉",
  [":jy_aocai"] = [[锁定技，你跳过摸牌阶段；准备阶段或当你成为伤害牌的目标时，你观看牌堆顶两张牌并获得其中一张。]],
  -- ["#jy_aocai_get"] = [[获得]],

  ["jy_duwu"] = "跬步",
  [":jy_duwu"] = [[结束阶段，你可以从牌堆底获得两张牌，然后将一张牌置于场上或牌堆顶。]],
  ["#jy_duwu_move"] = [[跬步]],
  ["#jy_duwu_card"] = [[跬步：将一张牌置于场上或牌堆顶]],

  ["jy_qianlv"] = "黔驴",
  [":jy_qianlv"] = [[你可以将一张非基本牌当未以此法使用过的基本牌或普通锦囊牌使用。]],
  ["#jy_qianlv"] = [[黔驴：将一张非基本牌转化使用]],
  ["@$jy_qianlv_names"] = [[黔驴]],

  ["$jy_aocai1"] = "哼，易如反掌。",
  ["$jy_aocai2"] = "吾主圣明，泽披臣属。",
  ["$jy_duwu1"] = "破曹大功，正在今朝！",
  ["$jy_qianlv1"] = "全力攻城！言退者，斩！",
  ["~jy__mou__zhugeke"] = "重权震主，是我疏忽了……",
}

local quanlve = fk.CreateViewAsSkill {
  name = "jy_quanlve",
  anim_type = "control",
  prompt = "#jy_quanlve",
  pattern = ".",
  interaction = function (self)
    local all = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeTrick and card.sub_type ~= Card.SubtypeDelayedTrick and not card.is_damage_card) or card.type == Card.TypeBasic and not card.is_derived then
        table.insertIfNeed(all, card.name)
      end
    end
    local mark2 = Self:getMark("@$jy_quanlve_names") -- 这是禁止继续使用的
    if mark2 == 0 then mark2 = {} end
    local choices, all_choices = {}, {}
    -- local choices = {}
    for _, name in ipairs(all) do
      local card = Fk:cloneCard(name)
      card.skillName = self.name
      if (Fk.currentResponsePattern == nil and card.skill:canUse(Self, card) and not Self:prohibitUse(card)) or
          (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)) then
        table.insertIfNeed(all_choices, name)
        if not table.contains(mark2, name) then
          table.insertIfNeed(choices, name)
        end
      end
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then
      return Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
    elseif #selected == 2 then
      return false
    end
    return true
  end,
  view_as = function(self, cards)
    if #cards ~= 2 or self.interaction.data == nil then return nil end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
  after_use = function(self, player, use)
    local mark = player:getMark("@$jy_quanlve_names")
    if mark == 0 then mark = {} end
    table.insertIfNeed(mark, use.card.name)
    player.room:setPlayerMark(player, "@$jy_quanlve_names", mark)
  end,
  enabled_at_response = function(self, player, response)
    if response then return false end -- 只能使用，不能打出
    if player:isNude() then return false end
    local used = player:getMark("@$jy_quanlve_names")
    if used == 0 then return true end
    for _, name in ipairs(used) do
      if Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name)) then return false end
    end
    return true
  end,
}

local xutu = fk.CreateTriggerSkill {
  name = "jy_xutu",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = { fk.AfterCardsMove },
  -- 当有牌满足要求时直接返回true。其他的在这后面执行。
  -- 因为这个技能一定会触发，所以在这个技能最后擦屁股就行了。
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    for _, move in ipairs(data) do
      if move.from == player.id and (move.toArea == Card.DiscardPile or move.toArea == Card.Processing) then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            local suit = Fk:getCardById(info.cardId):getSuitString(true)
            local record = player:getTableMark("@jy_xutu_suits-round")
            if not table.contains(record, suit) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player.id and (move.toArea == Card.DiscardPile or move.toArea == Card.Processing) then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            local suit = Fk:getCardById(info.cardId):getSuitString(true)
            local record = player:getTableMark("@jy_xutu_suits-round")
            if not table.contains(record, suit) then
              -- 从这里开始询问花色
              local selected_suit = room:askForChoice(player, {"spade", "heart", "club", "diamond"}, self.name, "#jy_xutu")
              local randomId = room:getCardsFromPileByRule(".|.|"..selected_suit)
              if #randomId > 0 then
                room:obtainCard(player, randomId[1], true, fk.ReasonPrey)
              end
              -- 将这种花色加入不可选取的里面去
              table.insertIfNeed(record, suit)
              room:setPlayerMark(player, "@jy_xutu_suits-round", record)
            end
          end
        end
      end
    end
  end,
}

local mjs = General(extension, "jy__mou__jvshou", "qun", 3, 3)
mjs:addSkill(quanlve)
mjs:addSkill(xutu)

Fk:loadTranslationTable {
  ["jy__mou__jvshou"] = "谋沮授",
  ["#jy__mou__jvshou"] = "很厉害",
  ["designer:jy__mou__jvshou"] = "rolin",

  ["jy_quanlve"] = "权略",
  [":jy_quanlve"] = [[你可以将两张相同花色的牌当一张未以此法使用过的基本牌或非伤害普通锦囊牌使用。]],
  ["#jy_quanlve"] = "权略：将两张相同花色的牌转化使用",
  ["@$jy_quanlve_names"] = "权略",

  ["jy_xutu"] = "徐图",
  [":jy_xutu"] = [[锁定技，当你的一张牌进入弃牌堆或处理区后，若本轮内你没有相同花色的牌进入过，你从牌堆中获得一张指定花色的牌。]],
  ["#jy_xutu"] = "徐图：选择一种花色并获得一张该花色的牌",
  ["@jy_xutu_suits-round"] = [[徐图]],
}

return extension
