local extension = Package:new("jianyu_ex")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
  ["jianyu_ex"] = [[简浴-界限突破]],
  ["jy_ex"] = [[简浴界]],

  ["jy_zishang_ex"] = "反噬",
  [":jy_zishang_ex"] = "出牌阶段，你可以对自己造成1点伤害。",
}

local zishang_ex = fk.CreateActiveSkill {
  name = "jy_zishang_ex",
  anim_type = "masochism",
  can_use = function(self, player)
    return true
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return false
  end,
  target_num = 0,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    room:damage({
      from = player,
      to = player,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name,
    })
  end,
}

-- 简自豪
local jianzihao = General(extension, "jy_ex__jianzihao", "qun", 4)

jianzihao:addSkill("jy_kaiju_2")
jianzihao:addSkill("guixin")
jianzihao:addSkill("jy_sanjian")
jianzihao:addSkill("jy_shengnu")

Fk:loadTranslationTable {
  ["jy_ex__jianzihao"] = "界简自豪",
  ["~jy_ex__jianzihao"] = "好像又要倒下了……",
}

-- 李元浩
local liyuanhao = General(extension, "jy_ex__liyuanhao", "qun", 4)

liyuanhao:addSkill("jy_huxiao_2")
liyuanhao:addSkill("jy_huxiao_analeptic_2")
liyuanhao:addSkill("jy_huxiao_jink_2")
liyuanhao:addSkill("jy_erduanxiao_2")
liyuanhao:addSkill("wusheng")

Fk:loadTranslationTable {
  ["jy_ex__liyuanhao"] = "界李元浩",
}

-- 高天亮
local gaotianliang = General(extension, "jy_ex__gaotianliang", "qun", 4)

local yuyu = fk.CreateTriggerSkill {
  name = "jy_yuyu_ex",
  anim_type = "masochism",
  events = { fk.Damaged },
  on_use = function(self, event, target, player, data)
    player:drawCards(2)
  end,
}

gaotianliang:addSkill(zishang_ex)
gaotianliang:addSkill(yuyu)
gaotianliang:addSkill("jy_tianling")

Fk:loadTranslationTable {
  ["jy_ex__gaotianliang"] = "界高天亮",

  ["jy_yuyu_ex"] = "玉玉",
  [":jy_yuyu_ex"] = [[受到伤害时，你可以摸2张牌。]],
  ["$jy_yuyu_ex1"] = "我……我真的很想听到你们说话……",
  ["$jy_yuyu_ex2"] = "我天天被队霸欺负，他们天天骂我。",
  ["$jy_yuyu_ex3"] = "有什么话是真的不能讲的……为什么一定……每次都是……一个人在讲……",

  ["~jy_ex__gaotianliang"] = "顶不住啦！我每天都活在水深火热里面。",
}

-- 阿威罗
local aweiluo = General(extension, "jy_ex__aweiluo", "qun", 3)

-- 玉玊
local jy_yusu = fk.CreateTriggerSkill {
  name = "jy_yusu_ex",
  anim_type = "special",

  events = { fk.CardUsing, fk.CardResponding },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if data.card and
        not data.card:isVirtual() and target == player then
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = data.card
    player:addToPile("jy_aweiluo_dian", id, true, self.name)
  end,
}

aweiluo:addSkill(jy_yusu)
aweiluo:addSkill("jy_tiaoshui")
aweiluo:addSkill("jy_zishang_ex")
aweiluo:addSkill("jy_luojiao")
aweiluo:addSkill("jy_youlong")

Fk:loadTranslationTable {
  ["jy_ex__aweiluo"] = "界阿威罗",

  ["jy_yusu_ex"] = "玉玊",
  [":jy_yusu_ex"] = "使用或打出一张非虚拟牌时，可以将其作为“点”置于武将牌上。",
  ["$jy_yusu_ex1"] = "Siu...",

  ["~jy_ex__aweiluo"] = "Messi, Messi, Messi, Messi...",
}

-- 水晶哥
local yangfan = General(extension, "jy_ex__yangfan", "qun", 4)

yangfan:addSkill("jy_zishang_ex")
yangfan:addSkill("jy_sichi")
yangfan:addSkill("jy_jiangbei")

Fk:loadTranslationTable {
  ["jy_ex__yangfan"] = "界杨藩",
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
      room:changeMaxHp(player, -1)
      -- 治疗其
      room:recover({
        who = p,
        num = 3,
        recoverBy = player,
        skillName = self.name,
      })

      -- 获得其所有牌
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
  name = "jy_lihun_ex",
  anim_type = "masochism",
  can_use = function(self, player)
    if player:usedSkillTimes("jy_jieyin_ex", Player.HistoryGame) == 0 then return false end
    return true
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
    room:changeMaxHp(from, -2)
    from:setSkillUseHistory("jy_jieyin_ex", 0, Player.HistoryGame)
  end,
}

local meishu = fk.CreateTriggerSkill {
  frequency = fk.Compulsory,
  name = "jy_meishu_ex",
  anim_type = "support",
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.from and data.from:getMark("@jy_jieyin_ex") ~= 0
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
liuxian:addSkill(lihun)
liuxian:addSkill(meishu)

Fk:loadTranslationTable {
  ["jy_ex__liuxian"] = [[界刘仙]],
  ["@jy_jieyin_ex"] = "结姻",

  ["jy_jieyin_ex"] = "结姻",
  [":jy_jieyin_ex"] = [[限定技，出牌阶段，你可以减少一点体力上限、令一名已受伤的男性角色回复3点体力，然后你获得其所有牌并拥有其所有技能。]],

  ["jy_lihun_ex"] = "离婚",
  [":jy_lihun_ex"] = [[出牌阶段，你可以减少2点体力上限使〖结姻〗视为未发动过。]],

  ["jy_meishu_ex"] = "美鼠",
  [":jy_meishu_ex"] = [[锁定技，被〖结姻〗过的角色造成伤害后，你增加一点体力上限。]],
}

return extension
