---@diagnostic disable: undefined-field
local extension = Package:new("jianyu_trad")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu_trad"] = [[简浴-PVE]],
  ["trad"] = [[经典]],
}

local rjhd = [[<font color="red">人机皇帝<br>因强度过高，本武将不会出现在选将框。</font>]]
local pve = [[<font color="red">人机皇帝<br>本武将专为PVE设计，不会出现在选将框。</font>]]

local trad_zaisheng = fk.CreateTriggerSkill {
  name = "jy_trad_zaisheng",
  anim_type = "support",
  events = { fk.AfterCardsMove, fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.AfterCardsMove then
      if player:usedSkillTimes(self.name, Player.HistoryRound) >= 1 then return false end
      for _, move in ipairs(data) do
        if move.moveReason ~= fk.ReasonUse and move.from then -- and move.moveVisible 可能需要加上技能描述里没有的moveVisible，因为如果是背面朝上的，你不知道这是红色，就不应该发动这个技能
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                Fk:getCardById(info.cardId).color == Card.Red then
              data.jy_zaisheng_moveFrom = move.from
              return true
            end
          end
        end
      end
    else -- fk.Damaged
      return target:getMark("@jy_trad_zaisheng") ~= 0 and data.to:getMark("jy_trad_zaisheng_triggered-round") == 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      return player.room:askForSkillInvoke(player, self.name, nil,
        "#jy_trad_zaisheng_prompt::" .. data.jy_zaisheng_moveFrom)
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
      room:setPlayerMark(jy_zaisheng_moveFrom, "@jy_trad_zaisheng", "")
    else -- fk.Damaged
      if data.card then
        local subcards = data.card:isVirtual() and data.card.subcards or { data.card.id }
        if #subcards > 0 and table.every(subcards, function(id) return room:getCardArea(id) == Card.Processing end) then
          room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
        end
      end
      if data.from then
        local cards = {}
        for _, i in ipairs(data.from:getCardIds(Player.Hand)) do
          if Fk:getCardById(i).is_damage_card then
            table.insert(cards, i)
          end
        end
        if #cards > 0 then
          room:moveCardTo(cards, Player.Hand,
            player, fk.ReasonPrey, self.name)
        end
      end
      room:setPlayerMark(data.to, "jy_trad_zaisheng_triggered-round", 1)
    end
  end,
  refresh_events = { fk.EventPhaseChanging },
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        data.to == Player.Start
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@jy_trad_zaisheng") ~= 0 then
        room:setPlayerMark(p, "@jy_trad_zaisheng", 0)
      end
    end
  end,
}

local trad_zhushe = fk.CreateTriggerSkill {
  name = "jy_trad_zhushe",
  anim_type = 'drawcard',
  events = { fk.EventPhaseStart, fk.CardUsing, fk.Damage },
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Start
      elseif event == fk.CardUsing then
        return player:getMark("@jy_trad_zhushe-turn") ~= 0
      else -- fk.Damage
        return player:getMark("@jy_trad_zhushe-turn") ~= 0 and not data.to.dead
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
      local cards = room:askForCard(player, 1, 999, true, self.name, true, nil, "#jy_trad_zhushe_prompt", nil, true)
      if #cards > 0 then
        room:throwCard(cards, self.name, player, player)
        if player:isAlive() then
          player:drawCards(#cards, self.name)
          room:setPlayerMark(player, "@jy_trad_zhushe-turn", "")
        end
      end
    elseif event == fk.CardUsing then
      -- player:broadcastSkillInvoke(self.name)  -- 这个就别播语音了，不然无法响应+造成伤害一张牌播两遍语音很吵
      room:notifySkillInvoked(player, self.name, "offensive")
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
      data.to:drawCards(2, self.name)
    end
  end,
}
local trad_zhushe_mod = fk.CreateTargetModSkill {
  name = "#jy_trad_zhushe_prompt_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and player:getMark("@jy_trad_zhushe-turn") ~= 0
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(self) and player:getMark("@jy_trad_zhushe-turn") ~= 0
  end,
}
trad_zhushe:addRelatedSkill(trad_zhushe_mod)

local trad__xuyu = General(extension, "jy__trad__xuyu", "qun", 3, 3, General.Female)
trad__xuyu.total_hidden = true
trad__xuyu:addSkill(trad_zaisheng)
trad__xuyu:addSkill(trad_zhushe)

Fk:loadTranslationTable {
  ["jy__trad__xuyu"] = "典絮雨",
  ["#jy__trad__xuyu"] = rjhd,
  ["designer:jy__trad__xuyu"] = "emo公主",
  ["cv:jy__trad__xuyu"] = "刘十四",
  ["illustrator:jy__trad__xuyu"] = "未知",
  ["~jy__trad__xuyu"] = [[我熟悉这死亡的气息……]],

  ["jy_trad_zaisheng"] = "再生",
  ["@jy_trad_zaisheng"] = "再生",
  ["#jy_trad_zaisheng_prompt"] = [[是否发动〖再生〗令 %dest 回复一点体力且你获得增益效果？]],
  [":jy_trad_zaisheng"] = [[当一名角色不因使用而失去红色牌时，你可以令其回复一点体力。若如此做，直到你的下回合开始，当该角色受到伤害后，你获得对其造成伤害的牌，并获得伤害来源手牌中所有伤害牌。]],
  ["$jy_trad_zaisheng1"] = [[不要害怕。]],
  ["$jy_trad_zaisheng2"] = [[让我来消除痛苦。]],

  ["jy_trad_zhushe"] = "注射",
  ["@jy_trad_zhushe-turn"] = "注射",
  ["#jy_trad_zhushe_prompt"] = "你可以重铸任意张牌，然后本回合获得〖注射〗的效果",
  [":jy_trad_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制、不可被响应；你造成伤害后，伤害目标回复X点体力并摸两张牌，X为伤害值。]],
  ["$jy_trad_zhushe1"] = [[准备好注射了。]],
  ["$jy_trad_zhushe2"] = [[我的治疗是不会痛的。]],
}


-- 我认为它设计得有新意，所以保留了（但由于强度问题，无法进入PVP池子）。
local trad_xiuxing = fk.CreateTriggerSkill {
  name = "jy_trad_xiuxing",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = { fk.Damaged, fk.AfterSkillEffect },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.Damaged then
      return data.to == player or data.from == player
    else
      return target == player and data:isSwitchSkill() and not player.dead
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.Damaged then
      for _, s in ipairs(player.player_skills) do
        if s:isSwitchSkill() then
          player.room:delay(200)                      -- 停告诉玩家我们确实由A变B再变A动了一下。延迟降低优化手感
          player.room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. s.name,
            player:getSwitchSkillState(s.name, true)) -- 经测试这个是没问题的
          player:addSkillUseHistory(s.name)           -- 加这个，在UI上更新
          -- 使用addSkillUseHistory会导致一些限制使用次数的技能无法继续发动
          -- player:setSkillUseHistory(s.name, player:usedSkillTimes(s.name), Player.HistoryTurn) -- 加这个，在UI上更新
          local t = {}
          t[0] = "阳"
          t[1] = "阴"
          player.room:doBroadcastNotify("ShowToast",
            "修行：已将 " .. Fk:translate(s.name) .. " 改为 " .. t[player:getSwitchSkillState(s.name)])
          player:drawCards(2, self.name)
        end
      end
    else
      player:drawCards(2, self.name)
    end
  end,
}
local trad_xiuxing_mod = fk.CreateTargetModSkill {
  name = "#jy_trad_xiuxing_mod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self)
  end,
}
trad_xiuxing:addRelatedSkill(trad_xiuxing_mod)

local trad_zitai = fk.CreateTriggerSkill {
  name = "jy_trad_zitai",
  anim_type = "switch",
  switch_skill_name = "jy_trad_zitai",
  frequency = Skill.Compulsory,
  events = { fk.DamageInflicted },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.from == player
  end,
  on_use = function(self, event, target, player, data)
    local isYang = player:getSwitchSkillState(self.name, true) ==
        fk.SwitchYang -- 这是从许攸https://gitee.com/qsgs-fans/shzl/blob/master/shadow.lua抄来的，不可能错的
    if isYang then    -- 这里必须传true，因为到执行这一行代码的时候已经改变了状态
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|heart,diamond",
      }
      player.room:judge(judge)
      if judge.card.color == Card.Red then
        player.room:changeShield(player, 1)
        return true
      end
    else
      data.damage = data.damage + 1
    end
  end
}

local mumang = fk.CreateAttackRangeSkill {
  name = "jy_trad_mumang",
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
  name = "#jy_trad_mumang_trigger",
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
mumang:addRelatedSkill(mumang_trigger)

local trad__guanzhe = General(extension, "jy__trad__guanzhe", "jin", 6, 6, General.Female)
trad__guanzhe.hidden = true
trad__guanzhe:addSkill(trad_xiuxing)
trad__guanzhe:addSkill(trad_zitai)
-- trad__guanzhe:addSkill("jy_zhaoyong")
trad__guanzhe:addSkill("jy_yujian")

Fk:loadTranslationTable {
  ["jy__trad__guanzhe"] = [[典观者]],
  ["#jy__trad__guanzhe"] = rjhd,
  ["designer:jy__trad__guanzhe"] = [[Kasa]],
  ["cv:jy__trad__guanzhe"] = [[无]],
  ["illustrator:jy__trad__guanzhe"] = [[未知]],

  ["jy_trad_xiuxing"] = [[修行]],
  [":jy_trad_xiuxing"] = [[锁定技，你使用牌无次数限制；当你造成或受到伤害后，改变你所有转换技的状态。你每以此法改变一个转换技的状态或发动一个转换技时，你摸两张牌。]],

  ["jy_trad_mumang"] = [[目盲]],
  [":jy_trad_mumang"] = [[锁定技，你的攻击范围始终为1。]],

  ["jy_trad_zitai"] = [[姿态]],
  [":jy_trad_zitai"] = [[转换技，锁定技，当你造成伤害时，阳：你判定，若为红色，防止之并获得一点护甲；阴：该伤害+1。]],
}

local tiandu = fk.CreateTriggerSkill {
  name = "jy_trad_tiandu",
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

-- tenyear_sp3 周不疑：一名角色的结束阶段，若其本回合未造成伤害，你可以声明一种普通锦囊牌（每轮每种牌名限一次），其可以将一张牌当你声明的牌使用
local yiji = fk.CreateTriggerSkill {
  name = "jy_trad_yiji",
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
      for _ = 1, data.damage do
        if not player:hasSkill(self) then break end
        self:doCost(event, target, player, data)
      end
    else
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    -- 选择一个目标
    local room = player.room
    local jy_trad_yiji_target = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), Util.IdMapper),
      1,
      1,
      "#jy_trad_yiji_prompt", self.name, true, false) -- 选择一个目标
    if #jy_trad_yiji_target > 0 then
      data.cost_data = jy_trad_yiji_target[1]
      return true
    else
      return false
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.cost_data)

    to:drawCards(2, self.name)

    -- 让他选择一个牌名
    local mark = player:getMark("jy_trad_yiji_names")
    if type(mark) ~= "table" then
      mark = {}
      for _, id in ipairs(Fk:getAllCardIds()) do
        local card = Fk:getCardById(id)
        if card:isCommonTrick() and not card.is_derived then
          table.insertIfNeed(mark, card.name)
        end
      end
      room:setPlayerMark(player, "jy_trad_yiji_names", mark)
    end
    local mark2 = player:getMark("@$jy_trad_yiji-round") -- 这是禁止继续使用的
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
    local choice = room:askForChoice(to, choices, self.name, "#jy_trad_yiji-invoke::" .. to.id, false, names)
    if choice == "Cancel" then
      return true
    else
      room:doIndicate(player.id, { to.id })
    end

    -- 问他用哪个牌，并且要他用
    mark = player:getMark("@$jy_trad_yiji-round")
    if mark == 0 then mark = {} end
    table.insert(mark, choice)
    room:setPlayerMark(player, "@$jy_trad_yiji-round", mark)
    room:doIndicate(player.id, { target.id })
    room:setPlayerMark(to, "jy_trad_yiji-tmp", choice)

    local success, dat = room:askForUseActiveSkill(to, "#jy_trad_yiji_viewas",
      "#jy_trad_yiji-use:::" .. Fk:translate(choice))
    room:setPlayerMark(to, "jy_trad_yiji-tmp", 0)
    if success then
      local card = Fk:cloneCard(choice)
      card:addSubcards(dat.cards)
      card.skillName = self.name
      room:useCard {
        from = to.id,
        tos = table.map(dat.targets, function(p) return { p } end),
        card = card,
      }
      room:setPlayerMark(to, "jy_trad_yiji-tmp", 0)
    end
  end,
}
local yiji_viewas = fk.CreateViewAsSkill {
  name = "#jy_trad_yiji_viewas",
  anim_type = "offensive",
  card_filter = function(self, to_select, selected)
    if Self:getMark("jy_trad_yiji-tmp") ~= 0 then
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
    if (#cards == 1 and Fk:getCardById(cards[1]).type ~= Card.TypeBasic) or #cards == 2 then
      local card = Fk:cloneCard(Self:getMark("jy_trad_yiji-tmp"))
      card:addSubcard(cards[1])
      card.skillName = "jy_trad_yiji"
      return card
    end
  end,
}
yiji:addRelatedSkill(yiji_viewas)

-- 董允舍宴
local yingcai = fk.CreateTriggerSkill {
  name = "jy_trad_yingcai",
  anim_type = "control",
  events = { fk.TargetConfirming },
  can_trigger = function(self, event, target, player, data)
    if data.from == player.id and player:hasSkill(self) and data.card:isCommonTrick() then -- 这一段是sheyan的代码，但是因为TargetConfirming是对每一个人都生效，所以当你加了一个新目标，又会触发这个，导致触发多次，和原来的不一样。
      if player:getMark("jy_trad_yingcai_used") ~= 0 then return false end
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
      "#jy_trad_yingcai-choose:::" .. data.card:toLogString(), self.name, true)
    if #plist > 0 then -- 如果他选择了目标，那就发动
      self.cost_data = { plist[1], cid }
      ret = true
    end
    room:setPlayerMark(player, "jy_trad_yingcai_used", true)
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
    return player:hasSkill(self) and player:getMark("jy_trad_yingcai_used") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "jy_trad_yingcai_used", 0)
  end,
}

local guojia = General(extension, "jy__trad__guojia", "wei", 3)
guojia.hidden = true
guojia:addSkill(tiandu)
guojia:addSkill(yiji)
guojia:addSkill(yingcai)

Fk:loadTranslationTable {
  ["jy__trad__guojia"] = [[典简郭嘉]],
  ["#jy__trad__guojia"] = rjhd,
  ["designer:jy__trad__guojia"] = [[rolin]],
  ["cv:jy__trad__guojia"] = [[暂无]],
  ["illustrator:jy__trad__guojia"] = [[未知]],
  ["~jy__trad__guojia"] = [[咳咳……]],

  ["jy_trad_tiandu"] = [[天妒]],
  [":jy_trad_tiandu"] = [[锁定技，回合开始时，你受到一点无来源伤害。]],
  ["$jy_trad_tiandu1"] = [[就这样吧。]],
  ["$jy_trad_tiandu2"] = [[哦？]],

  ["jy_trad_yiji"] = [[遗计]],
  [":jy_trad_yiji"] = [[当你受到一点伤害或你死亡时，你可以令一名角色摸两张牌，然后其可以将一张非基本牌或两张基本牌当一张本轮未以此法使用过的普通锦囊牌使用。]],
  ["#jy_trad_yiji_prompt"] = [[遗计：你可以令一名角色摸两张牌，随后使用一张可自选的锦囊牌]],
  ["#jy_trad_yiji-use"] = [[遗计：你可以将一张非基本牌或两张基本牌当 %arg 使用]],
  ["@$jy_trad_yiji-round"] = [[遗计]],
  ["#jy_trad_yiji_viewas"] = [[遗计]],
  ["#jy_trad_yiji-invoke"] = [[遗计：选择一个牌名，你可以将一部分牌当该牌使用]],
  ["$jy_trad_yiji1"] = [[也好。]],
  ["$jy_trad_yiji2"] = [[罢了。]],

  ["jy_trad_yingcai"] = [[英才]],
  [":jy_trad_yingcai"] = [[当你使用锦囊牌时，你可以弃一张牌，为该锦囊牌增加或减少一个目标（目标数至少为1）。]],
  ["#jy_trad_yingcai-choose"] = "英才：你可以弃一张牌，为 %arg 增加/减少一个目标",
}

local heiyong = fk.CreateTriggerSkill {
  name = "jy_trad_heiyong",
  anim_type = "drawcard",
  events = { fk.CardUsing, fk.CardResponding },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and target == player) then return false end
    local mark = player:getMark("@$jy_trad_heiyong-turn")
    if type(mark) ~= "table" then
      mark = {}
    end
    return not table.contains(mark, data.card.name)
  end,
  on_use = function(self, event, target, player, data)
    if event ~= fk.TurnEnd then
      local mark = player:getMark("@$jy_trad_heiyong-turn")
      if type(mark) ~= "table" then
        mark = {}
        player.room:setPlayerMark(player, "@$jy_trad_heiyong-turn", mark)
      end
      player:drawCards(2, self.name)
      table.insert(mark, data.card.name)
      player.room:setPlayerMark(player, "@$jy_trad_heiyong-turn", mark)
    end
  end,
}

-- local silie = fk.CreateTriggerSkill {
--   name = "jy_trad_silie",
--   anim_type = "offensive",
--   events = { fk.HpLost, fk.DamageInflicted },
--   frequency = Skill.Compulsory,
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return false end
--     if event == fk.HpLost then
--       return target == player
--     else
--       return data.from and data.from == player and player:getMark("@jy_trad_silie") ~= 0
--     end
--   end,
--   on_trigger = function(self, event, target, player, data)
--     if event == fk.HpLost then
--       for _ = 1, data.num do
--         self:doCost(event, target, player, data)
--       end
--     else
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     if event == fk.HpLost then
--       player.room:addPlayerMark(player, "@jy_trad_silie")
--     else
--       data.damage = data.damage + 1
--       player.room:addPlayerMark(player, "@jy_trad_silie", -1)
--     end
--   end,
-- }

local juewu = fk.CreateTriggerSkill {
  name = "jy_juewu",
  anim_type = "offensive",
  events = { fk.DamageInflicted },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.to.id < 0 and data.to.maxHp >= 3
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + data.to.maxHp // 3
  end,
}

local tjzs = General(extension, "jy__trad__tjzs", "shu", 6, 6, General.Female)
tjzs.hidden = true
tjzs:addSkill(heiyong)
tjzs:addSkill("longdan")
tjzs:addSkill(juewu)

Fk:loadTranslationTable {
  ["jy__trad__tjzs"] = [[典铁甲战士]],
  ["#jy__trad__tjzs"] = pve,
  ["designer:jy__trad__tjzs"] = [[Kasa]],
  ["cv:jy__trad__tjzs"] = [[高达一号]],
  ["illustrator:jy__trad__tjzs"] = [[未知]],

  ["jy_trad_heiyong"] = [[黑拥]],
  [":jy_trad_heiyong"] = [[锁定技，每回合每个牌名限一次，你使用或打出牌时，你摸两张牌。]],
  ["$jy_trad_heiyong1"] = [[龙战于野，其血玄黄！]],
  ["@$jy_trad_heiyong-turn"] = [[黑拥]],

  ["jy_trad_silie"] = [[撕裂]],
  [":jy_trad_silie"] = [[锁定技，你失去一点体力时，获得1枚“撕裂”；你造成伤害时，弃1枚“撕裂”令此伤害+1。]],
  ["@jy_trad_silie"] = [[撕裂]],

  ["jy_juewu"] = [[死神]],
  [":jy_juewu"] = [[锁定技，一名机器人受到伤害时，其每有3点体力上限，该伤害+1。]],
}

local otto = General(extension, "jy__trad__god", "god", 3)
otto.hidden = true

local jy_fuzhu = fk.CreateTriggerSkill {
  name = "jy_fuzhu",
  anim_type = "support",
  events = { fk.TurnStart },
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- TODO：UI变好看一点
    local skill_name = room:askForCustomDialog(player, self.name,
      "packages/jianyu/qml/fuzhu.qml")
    if #skill_name > 12 then return false end
    if not skill_name:match("^[a-z_]+$") then return false end
    local sk = Fk.skills[skill_name] -- 可以用 Util.Name2SkillMapper(skill_name)，原理一样
    if sk then
      room:handleAddLoseSkills(player, skill_name, nil, true, false)
    end
  end,
}

otto:addSkill(jy_fuzhu)

Fk:loadTranslationTable {
  ["jy__trad__god"] = [[侯国玉]],
  ["#jy__trad__god"] = rjhd,
  ["designer:jy__trad__god"] = [[考公专家]],
  ["cv:jy__trad__god"] = [[无]],
  ["illustrator:jy__trad__god"] = [[侯国玉]],

  ["jy_fuzhu"] = "哇袄",
  [":jy_fuzhu"] = [[回合开始时，你可以获得一个想要的技能。<br><font color="grey">输入这个技能的name参数（如paoxiao）以获得技能，你的输入必须仅含小写英文字母和下划线且长度不得超过12。若输入错误，你不会获得技能。<br>不知道拿什么？试试输入：cheat！</font>]],
}

local pojun = fk.CreateTriggerSkill {
  name = "jy_trad_pojun",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = { fk.TargetSpecified },
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      local to = player.room:getPlayerById(data.to)
      return not to.dead
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, { data.to })
    local to = room:getPlayerById(data.to)
    local cards = to:getCardIds("hej")
    room:moveCardTo(cards, Player.Hand,
      player, fk.ReasonJustMove, "jy_trad_pojun") -- 使用ReasonJustMove，防止其他技能阻止移动牌
    room:changeShield(player, #cards)
  end,
}

local xusheng = General(extension, "jy__trad__xusheng", "wu", 4)
xusheng.hidden = true
xusheng:addSkill(pojun)
xusheng:addSkill("jy_juewu")

local fangzhu = fk.CreateTriggerSkill {
  name = "jy_trad_fangzhu",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = { fk.Damaged },
  on_use = function(self, event, target, player, data)
    local room = player.room
    local robots = table.filter(room:getAlivePlayers(), function(p) return p.id < 0 end)
    local x = player.maxHp - player.hp
    for _, p in ipairs(robots) do
      if p.faceup then p:turnOver() end
      -- -- 因为有的模式判定死亡不是很对，所以这里手动写一下死亡（尽管他好像还是没死。肯定是有什么别的包里写了什么全局技能）
      -- if p.maxHp - x <= 0 then
      --   room:killPlayer({ who = p.id })
      -- end
      room:changeMaxHp(p, -x)
      -- if p.maxHp <= 0 then
      --   room:killPlayer({ who = p.id })
      -- end
    end
    -- room:changeMaxHp(player, x)
    -- room:changeShield(player, x)
  end,
}

-- local xingshang = fk.CreateTriggerSkill {
--   name = "jy_trad_xingshang",
--   anim_type = "offensive",
--   events = { fk.EventPhaseStart },
--   can_trigger = function(self, event, target, player, data)
--     return target.id < 0 and player:hasSkill(self) and target.phase == Player.Play
--   end,
--   on_trigger = function(self, event, target, player, data)
--     return player.room:askForSkillInvoke(player, self.name, data, "#jy_trad_xingshang-prompt:" .. target.id)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:moveCardTo(target:getCardIds("hej"), Player.Hand,
--       player, fk.ReasonPrey, self.name)
--   end,
-- }

-- local songwei = fk.CreateTriggerSkill {
--   name = "jy_trad_songwei",
--   anim_type = "offensive",
--   events = { fk.TurnStart },
--   can_trigger = function(self, event, target, player, data)
--     return target.id < 0 and player:hasSkill(self) and target.kingdom == "wei"
--   end,
--   on_trigger = function(self, event, target, player, data)
--     return player.room:askForSkillInvoke(player, self.name, data, "#jy_trad_songwei-prompt:" .. target.id)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:moveCardTo(target:getCardIds("hej"), Player.Hand,
--       player, fk.ReasonPrey, self.name)
--     room:changeMaxHp(player, target.maxHp)
--   end,

-- }

local caopi = General(extension, "jy__trad__caopi", "wei", 3, 3)
caopi.hidden = true
caopi:addSkill(fangzhu)
caopi:addSkill("xingshang")
-- caopi:addSkill(songwei)

Fk:loadTranslationTable {
  ["jy__trad__xusheng"] = [[典劫徐盛]],
  ["#jy__trad__xusheng"] = pve,
  ["designer:jy__trad__xusheng"] = "考公专家",
  ["~jy__trad__xusheng"] = "盛只恨，不能再为主公，破敌致胜了！",

  ["$jy_trad_pojun1"] = "犯大吴疆土者，盛必击而破之！",
  ["$jy_trad_pojun2"] = "若敢来犯，必教你大败而归！",

  ["jy_trad_pojun"] = [[破军]],
  ["#jy_trad_pojun_delay"] = [[破军]],
  [":jy_trad_pojun"] = [[锁定技，当你使用【杀】指定一个目标后，你获得其区域内所有牌和X点护甲（X为以此法获得的牌数）。]],

  ["jy__trad__caopi"] = [[典曹丕]],
  ["#jy__trad__caopi"] = pve,
  ["designer:jy__trad__caopi"] = "考公专家",

  ["jy_trad_fangzhu"] = [[放逐]],
  [":jy_trad_fangzhu"] = [[锁定技，你受到伤害后，所有机器人翻至背面并减X点体力上限（X为你已损失的体力值）。]],
  -- [[锁定技，你受到伤害后，所有机器人翻至背面并减X点体力上限，然后你增加X点体力上限并获得X点护甲（X为你已损失的体力值）。]]
  ["jy_trad_xingshang"] = [[行殇]],
  [":jy_trad_xingshang"] = [[一名机器人的出牌阶段开始时，你可以获得其区域内所有牌。]],
  ["#jy_trad_xingshang-prompt"] = [[行殇：你可以获得 %src 区域内所有牌]],

  ["jy_trad_songwei"] = [[颂威]],
  [":jy_trad_songwei"] = [[魏势力机器人的回合开始时，你可以获得其区域内所有牌并加X点体力上限（X为其体力上限）。]],
  ["#jy_trad_songwei-prompt"] = [[颂威：你可以获得 %src 区域内所有牌]],
}

local yitong = fk.CreateTriggerSkill {
  name = "jy_trad_yitong",
  anim_type = "drawcard",
  events = { fk.CardUsing, fk.CardResponding },
  frequency = Skill.Compulsory,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- local x = player:usedSkillTimes(self.name, Player.HistoryTurn)
    for _, r in ipairs(table.filter(room:getAlivePlayers(), function(p) return p.id < 0 end)) do
      room:damage({
        from = player,
        to = r,
        damage = 1,
        damageType = fk.NormalDamage,
        skillName = self.name,
      })
      room:askForDiscard(r, 2, 2, false, self.name, false)
    end
  end,
}

local liaoran = General(extension, "jy__trad__liaoran", "qun", 3, 3)
liaoran.hidden = true
liaoran:addSkill(yitong)
liaoran:addSkill("jy_juewu")

Fk:loadTranslationTable {
  ["jy__trad__liaoran"] = [[典了然]],
  ["#jy__trad__liaoran"] = pve,
  ["designer:jy__trad__liaoran"] = "了然",

  ["jy_trad_yitong"] = [[亿统]],
  [":jy_trad_yitong"] = [[锁定技，你使用或打出牌时，你对所有机器人造成一点伤害并令其弃置两张牌。]],
}

local zhiheng = fk.CreateActiveSkill {
  name = "jy_trad_zhiheng",
  anim_type = "drawcard",
  prompt = function(self, selected_cards, selected_targets)
    if #selected_cards == 0 and #selected_targets == 0 then
      return "#jy_trad_zhiheng"
    end

    if #selected_targets > 0 then
      return "#jy_trad_zhiheng-other"
    else
      return "#jy_trad_zhiheng-self"
    end
  end,
  can_use = function(self, player)
    -- 如果有一个人有牌，那就可以亮起来技能按钮
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if #p:getCardIds("he") ~= 0 then
        return true
      end
    end
  end,
  card_filter = function(self, card, to_select, selected)
    return not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  min_card_num = 0,
  mod_target_filter = function(self, to_select, selected, user, card)
    local player = Fk:currentRoom():getPlayerById(to_select)
    return user ~= to_select and not player:isAllNude()
  end,
  target_filter = function(self, to_select, selected, selected_cards, card)
    if #selected < self:getMaxTargetNum(Self, card) then
      return self:modTargetFilter(to_select, selected, Self.id, card) and #selected_cards == 0
    end
  end,
  min_target_num = 0,
  max_target_num = 1,
  on_use = function(self, room, use)
    local card_num = 0
    local from = room:getPlayerById(use.from)
    if #use.cards == 0 then
      for _, to in ipairs(use.tos) do
        -- 选了其他人，弃别人的
        local p = room:getPlayerById(to)
        local cards = room:askForCardsChosen(from, p, 1, #p:getCardIds("he"), "he", self.name)
        room:throwCard(cards, self.name, to, from)
        card_num = #cards
      end
    else
      -- 选了自己的牌，弃自己的
      room:throwCard(use.cards, self.name, from, from)
      card_num = #use.cards
    end
    if from:isAlive() then
      -- 给自己摸牌
      from:drawCards(card_num, self.name)
    end
  end,
}

local sunquan = General(extension, "jy__trad__sunquan", "wu", 4, 4)
sunquan.hidden = true
sunquan:addSkill(zhiheng)

Fk:loadTranslationTable {
  ["jy__trad__sunquan"] = [[典孙权]],
  ["#jy__trad__sunquan"] = pve,
  ["designer:jy__trad__sunquan"] = "考公专家",
  ["~jy__trad__sunquan"] = [[父亲，大哥，仲谋愧矣！]],

  ["$jy_trad_zhiheng1"] = [[容我三思。]],
  ["$jy_trad_zhiheng2"] = [[且慢！]],

  ["jy_trad_zhiheng"] = [[制衡]],
  ["#jy_trad_zhiheng"] = [[制衡：选择自己的牌或一名其他角色]],
  ["#jy_trad_zhiheng-other"] = [[制衡：弃置该角色的牌，然后摸等量的牌]],
  ["#jy_trad_zhiheng-self"] = [[制衡：弃置自己的牌，然后摸等量的牌]],
  [":jy_trad_zhiheng"] = [[出牌阶段，你可以弃置一名角色任意张牌，然后你摸等量的牌。]],
}

return extension
