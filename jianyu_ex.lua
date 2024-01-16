local extension = Package:new("jianyu_ex")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
  ["jianyu_ex"] = [[简浴-界限突破]],
  ["jy_ex"] = [[简浴界]],
}

local liuxian = General(extension, "jy_ex__liuxian", "god", 3, 3, General.Female)

local jieyin = fk.CreateActiveSkill {
  frequency = Skill.Limited,
  name = "jy_jieyin_ex",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    local s = Fk:currentRoom():getPlayerById(to_select)

    return to_select ~= Self.id and  -- 如果目标不是自己
        s.gender == General.Male and -- 而且是男的
        s.maxHp ~= s.hp and          -- 而且受了伤
        #selected < 1                -- 而且只选了一个
  end,
  target_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    for _, to in ipairs(use.tos) do
      local p = room:getPlayerById(to)

      room:setPlayerMark(p, "@jy_jieyin_ex", "")
      -- room:changeMaxHp(player, -1)
      -- 治疗其
      room:recover({
        who = p,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })

      -- 治疗自己
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })

      -- 获得其所有装备区和判定区的牌
      if not p:isNude() then
        local cards_id = p:getCardIds { Player.Hand, Player.Equip, Player.Judge }
        local dummy = Fk:cloneCard 'slash'
        dummy:addSubcards(cards_id)
        room:obtainCard(player.id, dummy, false, fk.ReasonPrey)
      end

      -- 获得其所有技能
      local skills = {}
      for _, s in ipairs(p.player_skills) do
        if not (s.attached_equip or s.name[#s.name] == "&") then
          table.insertIfNeed(skills, s.name)
        end
      end
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, true, false)
      end
    end
  end,
}

local lihun = fk.CreateActiveSkill {
  name = "jy_lihun", -- 为了方便这个技能在将魂斗场模式被禁，所以使用这个名字
  anim_type = "masochism",
  can_use = function(self, player)
    local room = player.room
    if player:usedSkillTimes("jy_jieyin_ex", Player.HistoryGame) == 0 then return false end
    return player.hp > math.max(#room.alive_players, 4) -- 不允许紫砂
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local x = math.max(#room.alive_players, 4)
    room:changeMaxHp(from, -x)
    from:setSkillUseHistory("jy_jieyin_ex", 0, Player.HistoryGame)
  end,
}

local meishu = fk.CreateTriggerSkill {
  frequency = fk.Compulsory,
  name = "jy_meishu",
  anim_type = "support",
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    local is_jieyin = (data.from and data.from:getMark("@jy_jieyin_ex") ~= 0) or
        (data.to and data.to:getMark("@jy_jieyin_ex") ~= 0)
    return player:hasSkill(self) and is_jieyin
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
  end,
}

liuxian:addSkill(jieyin)
liuxian:addSkill(meishu)
liuxian:addSkill(lihun)

Fk:loadTranslationTable {
  ["jy_ex__liuxian"] = [[刘仙]],
  ["@jy_jieyin_ex"] = "结姻",

  ["jy_jieyin_ex"] = "结姻",
  [":jy_jieyin_ex"] = [[限定技，出牌阶段，你可以令一名已受伤的男性角色与你各回复1点体力，然后你获得其所有牌并拥有其所有技能。]],

  ["jy_lihun"] = "离婚",
  [":jy_lihun"] = [[出牌阶段，你可以减少X点体力上限使〖结姻〗视为未发动过，X为存活角色数且至少为4。]],

  ["jy_meishu"] = "美鼠",
  [":jy_meishu"] = [[锁定技，被〖结姻〗过的角色造成或受到伤害后，你增加一点体力上限。]],
}

return extension
