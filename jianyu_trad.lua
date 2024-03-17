---@diagnostic disable: undefined-field
local extension = Package:new("jianyu_trad")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu_trad"] = [[简浴-经典]],
  ["trad"] = [[经典]],
}

-- 初版再生！！很强！！
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
      -- 该机制非常强！！警告！！
      if data.from then
        local cards = {}
        for _, i in ipairs(data.from:getCardIds(Player.Hand)) do
          if Fk:getCardById(i).is_damage_card then
            table.insert(cards, i)
          end
        end
        if #cards > 0 then
          room:obtainCard(player.id, cards[math.random(#cards)], true, fk.ReasonJustMove)
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
      room:doAnimate("InvokeSkill", {
        name = self.name,
        player = player.id,
        skill_type = "drawcard",
      })
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
trad__xuyu.hidden = true
trad__xuyu:addSkill(trad_zaisheng)
trad__xuyu:addSkill(trad_zhushe)

Fk:loadTranslationTable {
  ["jy__trad__xuyu"] = "经典絮雨",
  ["#jy__trad__xuyu"] = [[<font color="red">人机皇帝<br>这是未削弱版本，<br>因强度过高，这个武<br>将不会出现在选将框！</font>]],
  ["designer:jy__trad__xuyu"] = "emo公主",
  ["cv:jy__trad__xuyu"] = "刘十四",
  ["illustrator:jy__trad__xuyu"] = "未知",
  ["~jy__trad__xuyu"] = [[我熟悉这死亡的气息……]],

  ["jy_trad_zaisheng"] = "再生",
  ["@jy_trad_zaisheng"] = "再生",
  ["#jy_trad_zaisheng_prompt"] = [[是否发动〖再生〗令 %dest 回复一点体力且你获得增益效果？]],
  [":jy_trad_zaisheng"] = [[当一名角色不因使用而失去红色牌时，你可以令其回复一点体力。若如此做，直到你的下回合开始：每回合限一次，当该角色受到伤害后，你获得对其造成伤害的牌，并随机获得伤害来源手牌中一张伤害牌。]],
  ["$jy_trad_zaisheng1"] = [[不要害怕。]],
  ["$jy_trad_zaisheng2"] = [[让我来消除痛苦。]],

  ["jy_trad_zhushe"] = "注射",
  ["@jy_trad_zhushe-turn"] = "注射",
  ["#jy_trad_zhushe_prompt"] = "你可以重铸任意张牌，然后本回合获得〖注射〗的效果",
  [":jy_trad_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制、不可被响应；你造成伤害后，伤害目标回复X点体力并摸两张牌，X为伤害值。]],
  ["$jy_trad_zhushe1"] = [[准备好注射了。]],
  ["$jy_trad_zhushe2"] = [[我的治疗是不会痛的。]],
}


-- 这个是按照投稿时的描述做的经典版本修行，我认为它设计得有新意，所以保留了（但由于强度问题，无法进入PVP池子）。投稿描述原文如下：锁定技，你使用牌无次数限制；当你造成或受到伤害后，你需改变自身转换技的阴阳状态；你改变转换技阴阳状态时你摸2张牌。
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
          player.room:delay(1000)                     -- 停告诉玩家我们确实由A变B再变A动了一下（
          player.room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. s.name,
            player:getSwitchSkillState(s.name, true)) -- 经测试这个是没问题的
          player:addSkillUseHistory(s.name)           -- 加这个，在UI上更新
          local t = {}
          t[0] = "阳"
          t[1] = "阴"
          player.room:doBroadcastNotify("ShowToast",
            "修行：更改了 " .. Fk:translate(s.name) .. " 的阴阳状态，现在是：" .. t[player:getSwitchSkillState(s.name)]) -- 记得删
          player:drawCards(2)
        end
      end
    else
      player:drawCards(2)
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
    return player:hasSkill(self) and (data.to == player or data.from == player)
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

local trad__guanzhe = General(extension, "jy__trad__guanzhe", "jin", 3, 3, General.Female)
trad__guanzhe.hidden = true -- 不可以出现在选将框！！因为太强了！！
trad__guanzhe:addSkill(trad_xiuxing)
trad__guanzhe:addSkill(trad_zitai)
trad__guanzhe:addSkill(mumang)
trad__guanzhe:addSkill("jy_yujian")

Fk:loadTranslationTable {
  ["jy__trad__guanzhe"] = [[经典观者]],
  ["#jy__trad__guanzhe"] = [[<font color="red">人机皇帝<br>这是未削弱版本，<br>因强度过高，这个武<br>将不会出现在选将框！</font>]],
  ["designer:jy__trad__guanzhe"] = [[Kasa]],
  ["cv:jy__trad__guanzhe"] = [[无]],
  ["illustrator:jy__trad__guanzhe"] = [[未知]],

  ["jy_trad_xiuxing"] = [[修行]],
  [":jy_trad_xiuxing"] = [[锁定技，你使用牌无次数限制；当你造成或受到伤害后，你改变自身所有转换技的阴阳状态；你每以此法改变一个转换技的阴阳状态或发动一个转换技时，你摸两张牌。]],

  ["jy_trad_zitai"] = [[姿态]],
  [":jy_trad_zitai"] = [[转换技，锁定技，当你造成或受到伤害时，阳：你判定，若为红色，防止之；阴：该伤害+1。]],
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

-- 周不疑：一名角色的结束阶段，若其本回合未造成伤害，你可以声明一种普通锦囊牌（每轮每种牌名限一次），其可以将一张牌当你声明的牌使用
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
      room:setPlayerMark(to, "jy_trad_yiji_names", mark)
    end
    local mark2 = to:getMark("@$jy_trad_yiji-round")
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
    if #cards == 1 or #cards == 2 then
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

guojia:addSkill(tiandu)
guojia:addSkill(yiji)
guojia:addSkill(yingcai)

Fk:loadTranslationTable {
  ["jy__trad__guojia"] = [[经典简郭嘉]],
  ["#jy__trad__guojia"] = [[识人心智]],
  ["designer:jy__trad__guojia"] = [[rolin]],
  ["cv:jy__trad__guojia"] = [[暂无]],
  ["illustrator:jy__trad__guojia"] = [[未知]],

  ["jy_trad_tiandu"] = [[天妒]],
  [":jy_trad_tiandu"] = [[锁定技，回合开始时，你受到一点无来源伤害。]],

  ["jy_trad_yiji"] = [[遗计]],
  [":jy_trad_yiji"] = [[当你受到一点伤害或你死亡时，你可以令一名角色摸两张牌，然后其可以立即将一张非基本牌或两张基本牌当一张本轮未以此法使用过的普通锦囊牌使用。]],
  ["#jy_trad_yiji_prompt"] = [[遗计：你可以令一名角色摸两张牌，随后立即使用一张可自选的锦囊牌]],
  ["#jy_trad_yiji-use"] = [[遗计：你可以立即将一张非基本牌或两张基本牌当 %arg 使用]],
  ["@$jy_trad_yiji-round"] = [[遗计]],
  ["#jy_trad_yiji_viewas"] = [[遗计]],

  ["jy_trad_yingcai"] = [[英才]],
  [":jy_trad_yingcai"] = [[当你使用锦囊牌指定目标时，你可以弃一张牌，为该锦囊牌增加或减少一个目标（目标数至少为1）。]],
  ["#jy_trad_yingcai-choose"] = "英才：你可以弃一张牌，为 %arg 增加/减少一个目标",
}

return extension
