local extension = Package:new("jy_jianyu_ex")
extension.extensionName = "jianyu_ex"

Fk:loadTranslationTable {
  ["jy_jianyu_ex"] = [[简浴-增强]],
  ["xjb"] = "简浴",
  ["tym"] = "简浴",
  ["skl"] = "简浴",
  ["zer"] = "简浴",
}

-- 简自豪
local tym__jianzihao = General(extension, "tym__ex__jianzihao", "god", 4)

tym__jianzihao:addSkill("jy_kaiju_2")
tym__jianzihao:addSkill("jy_sanjian")
tym__jianzihao:addSkill("guixin")

Fk:loadTranslationTable {
  ["tym__ex__jianzihao"] = "简自豪",
  ["~tym__ex__jianzihao"] = "好像又要倒下了……",
}

-- 李元浩
local tym__liyuanhao = General(extension, "tym__ex__liyuanhao", "god", 4)

tym__liyuanhao:addSkill("jy_huxiao_2")
tym__liyuanhao:addSkill("jy_erduanxiao_2")
tym__liyuanhao:addSkill("wusheng")
tym__liyuanhao:addSkill("paoxiao")
tym__liyuanhao:addSkill("tieqi")

Fk:loadTranslationTable {
  ["tym__ex__liyuanhao"] = "李元浩",
}

-- 高天亮
local xjb__gaotianliang = General(extension, "xjb__ex__gaotianliang", "god", 8)

local jy_yuyu = fk.CreateTriggerSkill {
  name = "jy_yuyu_ex",
  anim_type = "masochism",
  events = { fk.Damaged },
  on_use = function(self, event, target, player, data)
    player:drawCards(8)
    player:turnOver()
    Fk:currentRoom():damage({
      from = player,
      to = player,
      damage = 1,
      damageType = fk.NormalDamage,
      skillName = self.name,
    })
  end,
}

xjb__gaotianliang:addSkill(jy_yuyu)
xjb__gaotianliang:addSkill("jizhi")

Fk:loadTranslationTable {
  ["xjb__ex__gaotianliang"] = "高天亮",

  ["jy_yuyu_ex"] = "玉玉",
  [":jy_yuyu_ex"] = [[受到伤害时，你可以摸8张牌并翻面，然后对自己造成1点伤害。]],
  ["#jy_yuyu_ex_draw3"] = "摸8张牌",
  ["#jy_yuyu_ex_draw4turnover"] = "摸8张牌并翻面，然后对自己造成1点伤害",
  ["$jy_yuyu_ex1"] = "我……我真的很想听到你们说话……",
  ["$jy_yuyu_ex2"] = "我天天被队霸欺负，他们天天骂我。",
  ["$jy_yuyu_ex3"] = "有什么话是真的不能讲的……为什么一定……每次都是……一个人在讲……",

  ["~xjb__ex__gaotianliang"] = "顶不住啦！我每天都活在水深火热里面。",
}

-- 阿威罗
local xjb__aweiluo = General(extension, "xjb__ex__aweiluo", "god", 4)

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
    local id = data.card
    player:addToPile("xjb__aweiluo_dian", id, true, self.name)
  end,
}

xjb__aweiluo:addSkill(jy_yusu)
xjb__aweiluo:addSkill("jy_tiaoshui")
xjb__aweiluo:addSkill("jy_luojiao")

Fk:loadTranslationTable {
  ["xjb__ex__aweiluo"] = "阿威罗",

  ["jy_yusu_ex"] = "玉玊",
  [":jy_yusu_ex"] = "使用或打出一张非虚拟牌时，可以将其作为“点”置于武将牌上。",
  ["@jy_yusu_basic_count"] = "玉玊",
  ["$jy_yusu_ex1"] = "Siu...",

  ["~xjb__ex__aweiluo"] = "Messi, Messi, Messi, Messi...",

}

-- 水晶哥
local zer__yangfan = General(extension, "zer__ex__yangfan", "god", 4)

zer__yangfan:addSkill("jy_sichi")
zer__yangfan:addSkill("jy_jiangbei")

Fk:loadTranslationTable {
  ["zer__ex__yangfan"] = "杨藩",
}

return extension
