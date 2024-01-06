local extension = Package:new("jy_jianyu_ex")
extension.extensionName = "jianyu_ex"

Fk:loadTranslationTable {
  ["jy_jianyu_ex"] = [[简浴-界限突破]],
}

-- 简自豪
local jy__jianzihao = General(extension, "jy__ex__jianzihao", "qun", 4)

jy__jianzihao:addSkill("jy_kaiju_2")
jy__jianzihao:addSkill("jy_sanjian")
jy__jianzihao:addSkill("jy_hongwen")
jy__jianzihao:addSkill("jy_shengnu")
jy__jianzihao:addSkill("jy_zouwei")
jy__jianzihao:addSkill("guixin")

Fk:loadTranslationTable {
  ["jy__ex__jianzihao"] = "界简自豪",
  ["~jy__ex__jianzihao"] = "好像又要倒下了……",
}

-- 李元浩
local jy__liyuanhao = General(extension, "jy__ex__liyuanhao", "qun", 4)

jy__liyuanhao:addSkill("jy_huxiao_2")
jy__liyuanhao:addSkill("jy_huxiao_analeptic_2")
jy__liyuanhao:addSkill("jy_huxiao_jink_2")
jy__liyuanhao:addSkill("jy_erduanxiao_2")
jy__liyuanhao:addSkill("wusheng")
jy__liyuanhao:addSkill("paoxiao")

Fk:loadTranslationTable {
  ["jy__ex__liyuanhao"] = "界李元浩",
}

-- 高天亮
local jy__gaotianliang = General(extension, "jy__ex__gaotianliang", "qun", 8)

local jy_yuyu = fk.CreateTriggerSkill {
  name = "jy_yuyu_ex",
  anim_type = "masochism",
  events = { fk.Damaged },
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(5)
    player:turnOver()
    room:damage({
      from = player,
      to = player,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name,
    })
  end,
}

jy__gaotianliang:addSkill(jy_yuyu)
jy__gaotianliang:addSkill("jy_tianling")

Fk:loadTranslationTable {
  ["jy__ex__gaotianliang"] = "界高天亮",

  ["jy_yuyu_ex"] = "玉玉",
  [":jy_yuyu_ex"] = [[受到伤害时，你可以摸5张牌并翻面，然后对自己造成1点伤害。]],
  ["$jy_yuyu_ex1"] = "我……我真的很想听到你们说话……",
  ["$jy_yuyu_ex2"] = "我天天被队霸欺负，他们天天骂我。",
  ["$jy_yuyu_ex3"] = "有什么话是真的不能讲的……为什么一定……每次都是……一个人在讲……",

  ["~jy__ex__gaotianliang"] = "顶不住啦！我每天都活在水深火热里面。",
}

-- 阿威罗
local jy__aweiluo = General(extension, "jy__ex__aweiluo", "qun", 4)

-- 玉玊
local jy_yusu = fk.CreateTriggerSkill {
  name = "jy_yusu_ex",
  anim_type = "special",

  events = { fk.CardResponding, fk.CardUsing },
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
    player:addToPile("jy__aweiluo_dian", id, true, self.name)
    room:damage({
      from = player,
      to = player,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name,
    })
  end,
}

jy__aweiluo:addSkill(jy_yusu)
jy__aweiluo:addSkill("jy_youlong")
jy__aweiluo:addSkill("jy_tiaoshui")
jy__aweiluo:addSkill("jy_luojiao")

Fk:loadTranslationTable {
  ["jy__ex__aweiluo"] = "界阿威罗",

  ["jy_yusu_ex"] = "玉玊",
  [":jy_yusu_ex"] = "使用或打出一张非虚拟牌时，可以将其作为“点”置于武将牌上，然后对自己造成1点伤害。",
  ["$jy_yusu_ex1"] = "Siu...",

  ["~jy__ex__aweiluo"] = "Messi, Messi, Messi, Messi...",

}

-- 水晶哥
local jy__yangfan = General(extension, "jy__ex__yangfan", "qun", 4)

local jy_zishang_ex = fk.CreateActiveSkill {
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
    room:damage({
      from = use.from,
      to = use.from,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name,
    })
  end,
}

jy__yangfan:addSkill("jy_sichi")
jy__yangfan:addSkill("jy_jiangbei")
jy__yangfan:addSkill(jy_zishang_ex)

Fk:loadTranslationTable {
  ["jy__ex__yangfan"] = "界杨藩",

  ["jy_zishang_ex"] = "自伤",
  [":jy_zishang_ex"] = "出牌阶段，你可以对自己造成1点伤害。",
}

return extension
