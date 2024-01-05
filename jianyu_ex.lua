local extension = Package:new("jy_jianyu_ex")
extension.extensionName = "jianyu_ex"

-- DIY真诚意见：所有你这个包的东西都加一个你自己的开头，这样防止和别人的重名。比如我的"huxiao"一开始就和别人重名了。

local U = require "packages/utility/utility"
local Q = require "packages/jianyu/question" -- 考公大学生用的题库

Fk:loadTranslationTable {
  ["jy_jianyu_ex"] = [[简浴-增强]],
  ["xjb"] = "简浴",
  ["tym"] = "简浴",
  ["skl"] = "简浴",
  ["zer"] = "简浴",
}

-- 简自豪
local tym__jianzihao = General(extension, "tym__ex__jianzihao", "god", 3)

tym__jianzihao:addSkill("jy_kaiju_2")
tym__jianzihao:addSkill("jy_sanjian")
tym__jianzihao:addSkill("jy_hongwen")
tym__jianzihao:addSkill("jy_zouwei")
tym__jianzihao:addSkill("jy_shengnu")
tym__jianzihao:addSkill("jy_xizao")
tym__jianzihao:addSkill("guixin")

Fk:loadTranslationTable {
  ["tym__ex__jianzihao"] = "简自豪",
  ["~tym__ex__jianzihao"] = "好像又要倒下了……",
}

-- 李元浩
local tym__liyuanhao = General(extension, "tym__ex__liyuanhao", "qun", 3)

tym__liyuanhao:addSkill("jy_huxiao_2")
tym__liyuanhao:addSkill("jy_huxiao_analeptic_2")
tym__liyuanhao:addSkill("jy_huxiao_jink_2")
tym__liyuanhao:addSkill("jy_erduanxiao_2")
tym__liyuanhao:addSkill("wusheng")
tym__liyuanhao:addSkill("paoxiao")
tym__liyuanhao:addSkill("tieqi")

Fk:loadTranslationTable {
  ["tym__ex__liyuanhao"] = "界李元浩",
}

-- 高天亮
local xjb__gaotianliang = General(extension, "xjb__ex__gaotianliang", "god", 8)

local jy_yuyu = fk.CreateTriggerSkill {
  name = "jy_yuyu_ex",
  anim_type = "masochism",
  events = { fk.Damaged },
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    self.this_time_slash = false
    if data.card and data.from and data.card.trueName == "slash" then -- 如果是杀
      if data.from:getMark("@jy_yuyu_enemy") == 0 then                -- 如果他不是敌人
        self.this_time_slash = true                                   -- 如果他是因为这次伤害变成了天敌，那么写在this_time_slash里
        room:setPlayerMark(data.from, "@jy_yuyu_enemy", "")           -- 空字符串也是true
      end
    end
    if self.this_time_slash or data.from:getMark("@jy_yuyu_enemy") == 0 then -- 如果他不是敌人
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cost = room:askForSkillInvoke(player, self.name, data)
    if cost then
      local choices = { "#jy_yuyu_ex_draw3", "#jy_yuyu_ex_draw4turnover" }
      self.choice = room:askForChoice(player, choices, self.name, "#jy_yuyu_ask_which") -- 如果玩家确定使用，询问用哪个
    end
    return cost
  end,
  on_use = function(self, event, target, player, data)
    if self.choice == "#jy_yuyu_draw3" then
      player:drawCards(8)
    else
      player:drawCards(8)
      player:turnOver()
      Fk:currentRoom():damage({
        from = player,
        to = player,
        damage = 1,
        damageType = fk.NormalDamage,
        skillName = self.name,
      })
    end
    self.this_time_slash = false
  end,
}

xjb__gaotianliang:addSkill(jy_yuyu)

Fk:loadTranslationTable {
  ["xjb__ex__gaotianliang"] = "高天亮",

  ["jy_yuyu_ex"] = "玉玉",
  [":jy_yuyu"] = [[1. 锁定技，当有角色对你使用【杀】造成了伤害时，其获得“致郁”标记；<br>
  2. 受到没有“致郁”标记的角色或因本次伤害而获得“致郁”标记的角色造成的伤害时，你可以选择一项：摸4张牌；摸8张牌并翻面，然后对自己造成1点伤害。]],
  ["#jy_yuyu_ex_draw3"] = "摸4张牌",
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

  refresh_events = { fk.EventPhaseEnd },
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
        and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@jy_yusu_basic_count", 0)
  end,

  events = { fk.CardResponding, fk.CardUsing },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if player.phase ~= Player.NotActive and data.card and
        target == player then
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jy_yusu_basic_count")
    return room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = data.card
    player:addToPile("xjb__aweiluo_dian", id, true, self.name)
    room:setPlayerMark(player, "@jy_yusu_basic_count", "#jy_yusu_triggered")
  end,
}

xjb__aweiluo:addSkill("jy_youlong")
xjb__aweiluo:addSkill("jy_hebao")
xjb__aweiluo:addSkill("jy_tiaoshui")
xjb__aweiluo:addSkill(jy_yusu)
xjb__aweiluo:addSkill("jy_luojiao")

Fk:loadTranslationTable {
  ["xjb__ex__aweiluo"] = "阿威罗",

  ["jy_yusu_ex"] = "玉玊",
  [":jy_yusu_ex"] = "你的回合内，使用或打出牌时，可以将其作为“点”置于武将牌上。",
  ["@jy_yusu_basic_count"] = "玉玊",
  ["$jy_yusu_ex1"] = "Siu...",

  ["~xjb__ex__aweiluo"] = "Messi, Messi, Messi, Messi...",

}

-- 水晶哥

-- 失去技能：原创之魂2017薛综
-- 觉醒技：山包邓艾
-- 受到伤害：一将2013曹冲
-- 没有次数距离限制：星火燎原刘焉
-- 无法被响应：tenyear_huicui1 #gonghu_delay
-- 立即使用一张牌：诸葛恪，借刀

local zer__yangfan = General(extension, "zer__ex__yangfan", "god", 4)

zer__yangfan:addSkill("jy_sichi")
zer__yangfan:addSkill("jy_jiangbei")

Fk:loadTranslationTable {
  ["zer__ex__yangfan"] = "杨藩",
}

return extension
