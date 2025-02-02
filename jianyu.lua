local extension = Package:new("jianyu_standard")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu"] = [[简浴]],
  ["jianyu_standard"] = [[简浴]],
  ["jy"] = "简浴",
}

-- 简自豪
local jy__jianzihao = General(extension, "jy__jianzihao", "qun", 5)

-- 红温
local jy_hongwen = fk.CreateFilterSkill {
  name = "jy_hongwen",
  card_filter = function(self, to_select, player)
    return player:hasSkill(self) and to_select.suit ~= Card.Heart
  end,
  view_as = function(self, to_select)
    return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
  end,
}

-- 走位
local jy_zouwei = fk.CreateDistanceSkill {
  name = "jy_zouwei",
  correct_func = function(self, from, to)
    -- 有装备时视为-1
    if from:hasSkill(self) and #from:getCardIds(Player.Equip) ~= 0 then
      return -1
    end
    -- 没装备时视为+1
    if to:hasSkill(self) and #to:getCardIds(Player.Equip) == 0 then
      return 1
    end
    return 0
  end,
}
-- TODO：写一个语音触发，游戏开始时、装备时、没有装备时

-- 圣弩
-- 参考自formation包的君刘备
local jy_shengnu = fk.CreateTriggerSkill {
  name = "jy_shengnu",
  anim_type = 'drawcard',
  events = { fk.AfterCardsMove },
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryGame) ~= 0 then return false end
    for _, move in ipairs(data) do
      if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "crossbow" then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "crossbow" then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(ids)
    player.room:obtainCard(player, dummy, true, fk.ReasonPrey)
  end,
}

-- 洗澡
local jy_xizao = fk.CreateTriggerSkill {
  name = "jy_xizao",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = { fk.AskForPeaches },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and
        player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    -- player:reset()
    -- player:drawCards(3, self.name)
    if player.dead or not player:isWounded() then return end
    room:recover({
      who = player,
      num = math.max(#room:getAllPlayers() - #room:getAlivePlayers(), 1) - player.hp,
      recoverBy = player,
      skillName = self.name,
    })
    player:turnOver()
  end,
}

-- 开局
-- 参考forest包贾诩 刘备 god包神曹操

local jy_kaiju = fk.CreateTriggerSkill {
  name = "jy_kaiju", -- jy_kaiju$是主公技
  anim_type = "masochism",
  -- frequency = Skill.Compulsory,
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if #p:getCardIds("he") ~= 0 and not player.dead then -- 如果我自己死了，那就不要继续了
        local id = room:askForCard(p, 1, 1, true, self.name, false, nil, "#jy_kaiju-choose")
        if #id ~= 0 then
          room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, false, nil)
          room:useVirtualCard("slash", nil, p, player, self.name, true) -- 杀
        end
      end
    end
  end,
}

-- local id = room:askForCardChosen(player, p, "hej", self.name)  -- 我选他一张牌

jy__jianzihao:addSkill(jy_kaiju)
jy__jianzihao:addSkill(jy_hongwen)
-- jy__jianzihao:addSkill(jy_zouwei)
jy__jianzihao:addSkill(jy_shengnu)
-- jy__jianzihao:addSkill(jy_xizao)


Fk:loadTranslationTable {
  ["jy__jianzihao"] = "简自豪",
  ["#jy__jianzihao"] = "澡子哥",
  ["designer:jy__jianzihao"] = "导演片子怎么样了 & 考公专家",
  ["cv:jy__jianzihao"] = "简自豪",
  ["illustrator:jy__jianzihao"] = "简自豪",

  ["jy_kaiju"] = "开局",
  [":jy_kaiju"] = [[准备阶段，你可以令其他有牌的角色交给你一张牌并视为对你使用【杀】。<br>
  <font color="grey"><i>“从未如此美妙的开局！”</i></font>]],
  ["$jy_kaiju1"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju2"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju3"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju4"] = "好亏呀，我每一波都。",
  ["$jy_kaiju5"] = "被秀了，操。",
  ["$jy_kaiju6"] = "从未如此美妙的开局！请为我欢呼，为我喝，喝，喝彩，OK？",
  ["$jy_kaiju7"] = "如此美妙的开局，这是我近两天来第一次啊！",
  ["$jy_kaiju8"] = "Oh my God，我要珍惜这段时光，我要好好地将它珍惜！",
  ["#jy_kaiju-choose"] = "开局：交给简自豪一张牌，视为对其使用【杀】",

  ["jy_hongwen"] = "红温",
  [":jy_hongwen"] = "锁定技，你的非<font color='red'>♥</font>牌视为<font color='red'>♥</font>牌。",
  ["$jy_hongwen1"] = "唉，不该出水银的。",
  ["$jy_hongwen2"] = "哎，兄弟我为什么不打四带两对儿啊，兄弟？",
  ["$jy_hongwen3"] = "好难受啊！",
  ["$jy_hongwen4"] = "操，可惜！",
  ["$jy_hongwen5"] = "这是咋想的呀？",

  ["jy_zouwei"] = "走位",
  [":jy_zouwei"] = "锁定技，当你的装备区没有牌时，其他角色计算与你的距离+1；当你的装备区有牌时，你计算与其他角色的距离-1。",
  ["$jy_zouwei1"] = "玩一下，不然我是不是一张牌没有出啊兄弟？",
  ["$jy_zouwei2"] = "完了呀！",

  ["jy_shengnu"] = "圣弩",
  [":jy_shengnu"] = "限定技，当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你可以获得之。",
  ["$jy_shengnu1"] = "哎兄弟们我这个牌不能拆吧？",
  ["$jy_shengnu2"] = "补刀瞬间回来了！",
  ["$jy_shengnu3"] = "恶心我，我也恶心你啊，互恶心呗！",

  ["jy_xizao"] = "洗澡",
  [":jy_xizao"] = "限定技，你处于濒死状态时，可以将体力恢复至X点并翻面（X为阵亡角色数且至少为1）。",
  ["$jy_xizao1"] = "呃啊啊啊啊啊啊啊！！",
  ["$jy_xizao2"] = "也不是稳赢吧，我觉得赢了！",
  ["$jy_xizao3"] = "真的我是真玩不了，这跟变态没关系，我好他妈的气！",

  ["~jy__jianzihao"] = "好像又要倒下了……",
}


-- 第二代简自豪
local jy__new__jianzihao = General(extension, "jy__new__jianzihao", "god", 3)
jy__new__jianzihao.total_hidden = true

local jy_sanjian = fk.CreateTriggerSkill {
  name = "jy_sanjian",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = { fk.EventPhaseStart },                    -- 事件开始时
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) -- 如果是我这名角色，如果是有这个技能的角色，如果是出牌阶段，如果这名角色的装备数是3
        and player.phase == Player.Play and #player:getCardIds(Player.Equip) >= 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("analeptic", nil, player, player, self.name, false)
    room:useVirtualCard("ex_nihilo", nil, player, player, self.name, false)
  end,
}

local jy_kaiju_2 = fk.CreateActiveSkill {
  name = "jy_kaiju_2",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    -- 判断目标是否不能成为【顺手牵羊】的目标
    local s = Fk:currentRoom():getPlayerById(to_select)
    local snatch = Fk:cloneCard("snatch")
    if Self:isProhibited(s, snatch) then -- 前面的是自己，后面的是别人！
      return false
    end

    return to_select ~= Self.id and -- 如果目标不是自己
        not s:isAllNude() and       -- 而且不是啥也没有，那就可以对他用这个技能
        #selected < 2
  end,
  min_target_num = 1,
  max_target_num = 2,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    -- TODO：sort use.tos
    for _, to in ipairs(use.tos) do
      local p = room:getPlayerById(to)

      if not player.dead then
        room:useVirtualCard("snatch", nil, player, p, self.name, true) -- 顺
      end
    end
  end,
}

jy__new__jianzihao:addSkill(jy_kaiju_2)
jy__new__jianzihao:addSkill(jy_sanjian)
jy__new__jianzihao:addSkill("jy_shengnu")
jy__new__jianzihao:addSkill("jy_xizao")

Fk:loadTranslationTable {
  ["jy__new__jianzihao"] = "神简自豪",
  ["#jy__new__jianzihao"] = "无冕之王",
  ["designer:jy__new__jianzihao"] = "考公专家",
  ["cv:jy__new__jianzihao"] = "简自豪",
  ["illustrator:jy__new__jianzihao"] = "简自豪",

  ["jy_kaiju_2"] = "开局",
  [":jy_kaiju_2"] = "出牌阶段限一次，你可以指定至多2名角色，视为你对其使用【顺手牵羊】（无距离限制）。",
  ["$jy_kaiju_21"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$jy_kaiju_22"] = "怎么赢啊？你别瞎说啊！",
  ["$jy_kaiju_23"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$jy_kaiju_24"] = "好亏呀，我每一波都。",
  ["$jy_kaiju_25"] = "被秀了，操。",
  ["$jy_kaiju_26"] = "从未如此美妙的开局！请为我欢呼，为我喝，喝，喝彩，OK？",
  ["$jy_kaiju_27"] = "如此美妙的开局，这是我近两天来第一次啊！",
  ["$jy_kaiju_28"] = "Oh my God，我要珍惜这段时光，我要好好地将它珍惜！",

  ["jy_sanjian"] = "三件",
  [":jy_sanjian"] = [[锁定技，出牌阶段开始时，若你的装备区有至少三张牌，你视为使用【酒】和【无中生有】。]],
  ["$jy_sanjian1"] = "也不是稳赢吧，我觉得赢了！",

  ["~jy__jianzihao"] = "好像又要倒下了……",
}

-- 李元浩
local jy__liyuanhao = General(extension, "jy__liyuanhao", "qun", 4)

local jy_huxiao = fk.CreateViewAsSkill {
  name = "jy_huxiao",
  mute = true,
  pattern = "jink,analeptic",

  expand_pile = "jy__liyuanhao_xiao",

  enabled_at_play = function(self, player)
    return #player:getPile("jy__liyuanhao_xiao") ~= 0
  end,
  enabled_at_response = function(self, player, response)
    return #player:getPile("jy__liyuanhao_xiao") ~= 0
  end,

  interaction = function()
    local names = {}
    for _, name in ipairs({ "jink", "analeptic" }) do
      local c = Fk:cloneCard(name)
      if (Fk.currentResponsePattern == nil and c.skill:canUse(Self, c)) or
          (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c)) then
        table.insertIfNeed(names, name)
      end
    end
    return UI.ComboBox { choices = names }
  end,

  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    if #Self:getPile("jy__liyuanhao_xiao") == 0 then return false end
    if Self:getPileNameOfId(to_select) ~= "jy__liyuanhao_xiao" then return false end
    return true
  end,

  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    if #cards ~= 1 then
      return nil
    end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(cards)
    return card
  end,
}
local jy_huxiao_xiao = fk.CreateTriggerSkill {
  name = "#jy_huxiao_xiao",
  mute = true,
  events = { fk.CardResponding, fk.CardUsing }, -- 包括了使用和打出
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      return target == player
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "jy_huxiao")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("jy_huxiao")
    room:notifySkillInvoked(player, "jy_huxiao", "drawcard")
    -- player:drawCards(1, self.name)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(room:getNCards(1))
    player:addToPile("jy__liyuanhao_xiao", dummy, true, self.name)
  end,
}
-- 界二段
local jy_erduanxiao = fk.CreateTriggerSkill {
  name = "#jy_erduanxiao",
  anim_type = "support",
  mute = true,
  refresh_events = { fk.BeforeCardsMove }, -- 理论上来说每次牌的移动只有同一个方向的
  frequency = Skill.Compulsory,

  -- 测试通过。1-2，3-2都可以顺利触发。
  -- 我猜想原因是1-2的时候可能有多张牌进出，而3-2的时候只会有一张牌出去。但我搞不懂这个数据结构，
  -- 不知道为什么有一个是两层循环，有一个是一层循环。
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end -- 如果我自己没有这个技能，那就算了

    local xiaos = player:getPile("jy__liyuanhao_xiao")
    player.is_xiao_changing = nil -- TODO：建议改成data.is_xiao_changing

    -- 判断是否有牌出去
    for _, move in ipairs(data) do -- 第一层循环，不知道为啥
      if move.from then            -- 照着抄的，牌离开
        -- print("有牌正打算离开")
        if move.from == player.id then
          -- print("有牌正打算从你家离开")
          if #xiaos == 3 then
            -- print("啸是3")
            for _, info in ipairs(move.moveInfo) do       -- 还有第二层循环。我自己的代码里没有第二层
              if info.fromArea == Card.PlayerSpecial then -- 出去的时候不需要判断specialName，因为去的是弃牌堆
                -- print("有牌正打算从你家特殊区离开")
                return true
              end
            end
          end
        end
      end
    end

    -- 判断是否有牌进来
    if #xiaos == 1 then -- 如果啸是1
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerSpecial and
            move.specialName == "jy__liyuanhao_xiao" then
          return true
        end
      end
    end
  end,

  on_refresh = function(self, event, target, player, data)
    local xiaos = player:getPile("jy__liyuanhao_xiao")
    player.is_xiao_changing = #xiaos
  end,

  events = { fk.AfterCardsMove },
  can_trigger = function(self, event, target, player, data)
    local xiaos = player:getPile("jy__liyuanhao_xiao")
    if #xiaos == player.is_xiao_changing then return false end
    return player:hasSkill(self) and               -- 如果是有二段啸的角色
        #player:getPile("jy__liyuanhao_xiao") == 2 -- 如果啸为2
  end,

  on_cost = function(self, event, target, player, data)
    return true
  end,

  on_use = function(self, event, target, player, data)
    local xiaos = player:getPile("jy__liyuanhao_xiao")
    local room = player.room
    player:broadcastSkillInvoke("jy_huxiao")
    room:notifySkillInvoked(player, "jy_huxiao", "drawcard")
    -- 将所有“啸”纳入自己的手牌
    room:moveCardTo(xiaos, Card.PlayerHand, player, fk.ReasonJustMove, self.name, "jy__liyuanhao_xiao", true,
      player.id)
    -- room:recover({
    --   who = player,
    --   num = 1,
    --   recoverBy = player,
    --   skillName = self.name,
    -- })
    player:drawCards(1, self.name)
  end,
}
jy_huxiao:addRelatedSkill(jy_erduanxiao)
jy_huxiao:addRelatedSkill(jy_huxiao_xiao)

jy__liyuanhao:addSkill(jy_huxiao)

Fk:loadTranslationTable {
  ["jy__liyuanhao"] = "李元浩",
  ["#jy__liyuanhao"] = "虎大将军",
  ["designer:jy__liyuanhao"] = "拂却心尘 & 考公专家",
  ["cv:jy__liyuanhao"] = "暂无",
  ["illustrator:jy__liyuanhao"] = "李元浩",

  ["jy__liyuanhao_xiao"] = "啸",

  ["jy_huxiao"] = "虎啸",
  [":jy_huxiao"] = [[当你使用或打出一张【杀】时，你可以将牌堆顶的一张牌置于武将牌上（称为“啸”）。你可以将一张“啸”当【酒】或【闪】使用或打出。当你的“啸”数为2时，你获得所有“啸”并摸一张牌。<br><font color="grey"><i>“我希望我的后辈们能够记住，在你踏上职业道路的这一刻开始，你的目标就只有冠军。”</i></font>]],
}

-- 高天亮
local jy__gaotianliang = General(extension, "jy__gaotianliang", "shu", 4)

local jy_yuyu = fk.CreateTriggerSkill {
  name = "jy_yuyu",
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
      local choices = { "#jy_yuyu_draw3", "#jy_yuyu_draw4turnover" }
      self.choice = room:askForChoice(player, choices, self.name, "#jy_yuyu_ask_which") -- 如果玩家确定使用，询问用哪个
    end
    return cost
  end,
  on_use = function(self, event, target, player, data)
    if self.choice == "#jy_yuyu_draw3" then
      player:drawCards(2, self.name)
    else
      player:drawCards(2, self.name)
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
local jy_yuyu_trigger = fk.CreateTriggerSkill {
  name = "#jy_yuyu_trigger",
  mute = true,
  events = { fk.DamageCaused },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.to:getMark("@jy_yuyu_enemy") ~= 0 and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("jy_yuyu")
    room:notifySkillInvoked(player, "jy_yuyu")
    data.damage = data.damage + 1
  end,
}
jy_yuyu:addRelatedSkill(jy_yuyu_trigger)

jy__gaotianliang:addSkill(jy_yuyu)

Fk:loadTranslationTable {
  ["jy__gaotianliang"] = "高天亮",
  ["#jy__gaotianliang"] = "沉默寡言",
  ["designer:jy__gaotianliang"] = "导演片子怎么样了 & 考公专家",
  ["cv:jy__gaotianliang"] = "高天亮",
  ["illustrator:jy__gaotianliang"] = "高天亮",

  ["jy_yuyu"] = "玉玉",
  [":jy_yuyu"] = [[你受到伤害后：若该伤害是【杀】造成的，你令伤害来源获得“玉玉”标记；若伤害来源没有“玉玉”或因本次伤害而获得“玉玉”，你可以选择一项：摸两张牌；摸两张牌并翻面，然后对自己造成一点伤害。你使用【杀】对有“玉玉”的角色造成伤害时，该伤害+1。]],
  ["@jy_yuyu_enemy"] = "玉玉",
  ["#jy_yuyu_ask_which"] = "玉玉：请选择",
  ["#jy_yuyu_draw3"] = "摸两张牌",
  ["#jy_yuyu_draw4turnover"] = "摸两张牌并翻面，然后对自己造成一点伤害（可以再次触发〖玉玉〗）",
  ["$jy_yuyu1"] = "我……我真的很想听到你们说话……",
  ["$jy_yuyu2"] = "我天天被队霸欺负，他们天天骂我。",
  ["$jy_yuyu3"] = "有什么话是真的不能讲的……为什么一定……每次都是……一个人在讲……",

  ["~jy__gaotianliang"] = "顶不住啦！我每天都活在水深火热里面。",
}

-- 阿威罗
local jy__aweiluo = General(extension, "jy__aweiluo", "qun", 3)

-- 游龙
local jy_youlong = fk.CreateTriggerSkill {
  name = "jy_youlong",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
        and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers(player, true)) do
      -- getAlivePlayers 只需要一个参数。这里为什么两个也行？
      if not p:isKongcheng() then -- 如果他有手牌
        local id = room:askForCard(p, 1, 1, false, self.name, false, nil, "#jy_youlong-choose")
        assert(id)
        local next = p.next -- 下家
        while next.dead do  -- 一直找，直到找到一个活的下家
          next = next.next
        end
        room:moveCardTo(id, Card.PlayerHand, next, fk.ReasonJustMove, self.name, nil, false, player.id)
      end
    end
  end,
}

-- 核爆
local jy_hebao = fk.CreateTriggerSkill {
  name = "jy_hebao",
  anim_type = "special",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local id = room:askForCard(player, 1, 1, false, self.name, true, nil, "#jy_hebao-choose")
    player:addToPile("jy_aweiluo_dian", id, true, self.name)
  end,
}

-- 跳水
local jy_tiaoshui = fk.CreateTriggerSkill {
  name = "jy_tiaoshui",
  anim_type = "special",
  frequency = Skill.Limited,
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    local dians = player:getPile("jy_aweiluo_dian")
    return target == player and target:hasSkill(self.name) and
        #dians ~= 0 and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- local dians = player:getPile("jy_aweiluo_dian")
    -- 以后“选择一张特殊区的牌并且弃置”这个要求就这么写。
    local id = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|jy_aweiluo_dian|.|.|.", "#jy_tiaoshui",
      "jy_aweiluo_dian", true)
    room:throwCard(id, self.id, player, player)
    -- askForDiscard 函数是不能对特殊区的牌生效的
    -- local id = room:askForDiscard(player, 1, 1, false, self.name, true, ".|.|.|jy_aweiluo_dian|.|.|.", "#jy_tiaoshui", false, true)
  end,
}

-- 罗绞
-- 这个技能难以实现。目前好像还没看到其他的武将是“特殊区牌量变化时执行效果”的，一般都是某个特定的时机触发，
-- 如邓艾，在准备阶段才判断有几张。所以我注释写详细一点，方便其他开发者参考。
-- 其实前面的两个李元浩也是这样。不过这个技能比那两个更复杂，解释这个会比较好。
--
-- 新月杀现有的函数无法判断一张牌移动时，如果是离开特殊区，离开的是否是某特定的特殊区（在这个技能里，是“点”）。我们作如下设计：
-- 罗绞主技能监视“卡牌移动前”事件，将卡牌移动前的“点”数量记录，并传给另一个关联技能，其监视“卡牌移动后”事件，也记录一次移动后“点”的数量。
-- 如果卡牌移动之后“点”数没有变化，那么不要触发。
-- 这样就能防止当其他人给我挂上或丢掉其他特殊区的牌时，也触发我们的技能。

-- TODO：可以参考曹植落英，把这个技能写得更简洁（上面的技能也是）。但是能跑就行（
local jy_luojiao = fk.CreateTriggerSkill {
  name = "jy_luojiao",
  anim_type = "offensive",
  refresh_events = { fk.BeforeCardsMove },                  -- 在每次牌移动之前
  mute = true,                                              -- 不声明使用了这个技能

  can_refresh = function(self, event, target, player, data) -- 使用refresh而不是trigger，是因为这个技能不需要询问玩家是否触发
    if not player:hasSkill(self) then return end            -- 如果我自己没有这个技能，那就不触发了

    -- 先清理自家变量
    player.is_luojiao_archery_attack_may_be_triggered = false
    player.is_dian_may_changing = nil

    local dians = player:getPile("jy_aweiluo_dian") -- dians是“点”的牌

    -- 判断是否有牌进出特殊区
    -- 为什么不用data传参数，因为这里是BeforeCardsMove，后面是AfterCardsMove，两个不是同一个事件，data不一样。用player

    -- 判断是否有牌出去
    for _, move in ipairs(data) do
      if move.from then
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerSpecial then -- 出去的时候不需要判断，因为去的是弃牌堆
              -- 如果点是5，那么有可能可以触发万箭齐发
              if #dians == 5 then player.is_luojiao_archery_attack_may_be_triggered = true end
              return true
            end
          end
        end
      end
    end

    -- 判断是否有牌进来
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerSpecial and move.specialName == "jy_aweiluo_dian" then
        -- 如果点是3，那么有可能可以触发万箭齐发
        if #dians == 3 then player.is_luojiao_archery_attack_may_be_triggered = true end
        return true
      end
    end
  end,

  on_refresh = function(self, event, target, player, data)
    -- 触发之后，设置变量，告诉下一个函数有没有可能在发生变化
    local dians = player:getPile("jy_aweiluo_dian")
    player.is_dian_may_changing = #dians
    -- 必须使用player来储存该变量，因为后面的事件使用的是另一个函数jy_luojiao_after，如果你用self，那个函数是看不到的
  end,
}
-- 使用同一个函数来判断是否触发了南蛮和万箭
local jy_luojiao_after = fk.CreateTriggerSkill {
  name = "#jy_luojiao_after",     -- 这个技能的名字
  events = { fk.AfterCardsMove }, -- 卡牌移动之后，如果can_trigger返回真，那就可以发动这个技能

  -- can_trigger是用来判断是否能触发这个技能的，返回真就能触发，返回假就不能触发
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if not player.is_dian_may_changing then return false end -- 如果“点”有可能在变化

    local dians = player:getPile("jy_aweiluo_dian")
    -- 如果卡牌移动前和移动后“点”相同，那就证明是其他的特殊区的牌，直接return
    if player.is_dian_may_changing == #dians then return false end

    -- 判断是否有两张同样花色的“点”，若有返回false，若没有返回true
    if #dians == 0 then return false end -- 设计者说1张也可以发动南蛮
    local dict = {}
    local is_luojiao_suit_satisfied = true
    for _, c in ipairs(dians) do
      local suit = Fk:getCardById(c).suit
      if dict[suit] then
        -- 有相同的花色，不执行
        is_luojiao_suit_satisfied = false
        break
      else
        dict[suit] = true
      end
    end

    -- 万箭需要满足的条件：点数为4，且之前已经告诉我有可能触发
    player.is_archery_attack =
        player.is_luojiao_archery_attack_may_be_triggered and
        #player:getPile("jy_aweiluo_dian") == 4

    -- 南蛮需要满足的条件：花色全部不同
    -- 且本回合未使用过（目前已删除）
    player.is_savage_assault = is_luojiao_suit_satisfied
    -- and player:usedSkillTimes(self.name) == 0

    -- 万箭或南蛮满足，返回真
    return player.is_archery_attack or player.is_savage_assault
  end,

  -- on_cost代表执行该技能时要做什么事情
  on_cost = function(self, event, target, player, data)
    local room = player.room
    self.first = nil -- 如果两个条件都满足，这个变量存储谁是第一个使用的牌

    -- 如果两个条件都满足
    if player.is_archery_attack and player.is_savage_assault then
      if room:askForSkillInvoke(player, self.name, nil, "#jy_luojiao_both_ask") then        -- 都触发了，询问是否要使用罗绞
        local choices = { "archery_attack", "savage_assault" }
        self.first = room:askForChoice(player, choices, self.name, "#jy_luojiao_ask_which") -- 如果玩家确定使用，询问先用哪张牌
        return true
      end
    end

    -- 因为南蛮触发的比万箭多，所以把南蛮放到前面提高效率

    -- 如果南蛮的条件满足
    if player.is_savage_assault then
      if room:askForSkillInvoke(player, self.name, nil, "#jy_luojiao_savage_assault_ask") then -- 那么问是否要发动
        self.do_savage_assault = true
        return true
      end
    end

    -- 如果万箭的条件满足
    if player.is_archery_attack then
      if room:askForSkillInvoke(player, self.name, nil, "#jy_luojiao_archery_attack_ask") then -- 那么问是否要发动
        self.do_archery_attack = true
        return true
      end
    end

    -- 如果玩家选择不触发，那擦屁股，这次“点”结算完成了
    self.do_archery_attack = false
    self.do_savage_assault = false
    self.first = nil
    player.is_dian_may_changing = false
    player.is_archery_attack = false
    player.is_savage_assault = false
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    if self.first then -- 如果self.first这个值有，那就代表两个条件同时满足
      local cards
      local skill_names
      -- 这样写方便以后扩展，也可以更好地移植到别的代码里去
      if self.first == "archery_attack" then -- 如果玩家选择先用万箭
        cards = { "archery_attack", "savage_assault" }
        skill_names = { "#jy_luojiao_archery_attack", "#jy_luojiao_savage_assault" }
      else
        cards = { "savage_assault", "archery_attack" }
        skill_names = { "#jy_luojiao_savage_assault", "#jy_luojiao_archery_attack" }
      end
      -- assert(#cards == #skill_names)
      -- 对于
      for i = 1, #cards do
        if room:askForSkillInvoke(player, skill_names[i]) then         -- 如果同意发动这个技能
          room:notifySkillInvoked(player, skill_names[i], "offensive") -- 在武将上显示这个技能的名字
          player:broadcastSkillInvoke("jy_luojiao")                    -- 播放这个技能的语音
          room:useVirtualCard(cards[i], nil, player, room:getOtherPlayers(player, true), self.name, true)
        end
      end
    else -- 如果没有两个条件同时满足，那满足谁就执行谁
      -- 满足万箭，执行万箭
      if self.do_archery_attack then
        room:notifySkillInvoked(player, "jy_luojiao", "offensive")
        player:broadcastSkillInvoke("jy_luojiao")
        room:useVirtualCard("archery_attack", nil, player, room:getOtherPlayers(player, true), self.name, true)
      end
      -- 满足南蛮，执行南蛮
      if self.do_savage_assault then
        room:notifySkillInvoked(player, "jy_luojiao", "offensive")
        player:broadcastSkillInvoke("jy_luojiao")
        room:useVirtualCard("savage_assault", nil, player, room:getOtherPlayers(player, true), self.name, true)
      end
    end
    -- 一次“点”的变化结算完成，把所有变量都设为初始
    self.do_archery_attack = false
    self.do_savage_assault = false
    self.first = nil
    player.is_dian_may_changing = false
    player.is_archery_attack = false
    player.is_savage_assault = false
  end
}
jy_luojiao:addRelatedSkill(jy_luojiao_after)

-- 玉玊
local jy_yusu = fk.CreateTriggerSkill {
  name = "jy_yusu",
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
    if type(player:getMark("@jy_yusu_basic_count")) ~= "number" then return false end
    if player.phase ~= Player.NotActive and data.card and
        data.card.type == Card.TypeBasic and target == player then
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jy_yusu_basic_count")
    local basic_count = player:getMark("@jy_yusu_basic_count")
    if basic_count == 2 then -- 第二张基本牌
      return room:askForSkillInvoke(player, self.name)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = data.card
    player:addToPile("jy_aweiluo_dian", id, true, self.name)
    room:setPlayerMark(player, "@jy_yusu_basic_count", "#jy_yusu_triggered")
  end,
}
jy__aweiluo:addSkill(jy_youlong)
jy__aweiluo:addSkill(jy_hebao)
jy__aweiluo:addSkill(jy_tiaoshui)
jy__aweiluo:addSkill(jy_yusu)
jy__aweiluo:addSkill(jy_luojiao)

Fk:loadTranslationTable {
  ["jy__aweiluo"] = "阿威罗",
  ["#jy__aweiluo"] = "绝代双骄",
  ["designer:jy__aweiluo"] = "导演片子怎么样了 & 考公专家",
  ["cv:jy__aweiluo"] = "克里斯蒂亚诺·罗纳尔多·多斯·桑托斯·阿威罗 & 刘嘉远",
  ["illustrator:jy__aweiluo"] = "《时代》封面",

  ["jy_aweiluo_dian"] = "点",

  ["jy_youlong"] = "游龙",
  ["#jy_youlong-choose"] = "游龙：选择一张手牌交给下家",
  [":jy_youlong"] = "锁定技，准备阶段，有手牌的角色依次将一张手牌交给下家。",
  ["$jy_youlong1"] = "翩若惊鸿！婉若游龙！",

  ["jy_hebao"] = "核爆",
  [":jy_hebao"] = "准备阶段，你可以将一张手牌作为“点”置于武将牌上。",
  ["#jy_hebao-choose"] = "核爆：选择一张手牌成为“点”",
  ["$jy_hebao1"] = "Siu~",

  ["jy_tiaoshui"] = "跳水",
  [":jy_tiaoshui"] = "限定技，你受到伤害后，可以弃置一张“点”。",
  ["#jy_tiaoshui"] = "弃置一张“点”",
  ["$jy_tiaoshui1"] = "Siu, hahahaha!",

  ["jy_luojiao"] = "罗绞",
  [":jy_luojiao"] = [[每当你的“点”的数量变化后：若你有“点”且任意2张“点”的花色都不相同，你可以视为使用【南蛮入侵】；若你有4张“点”，你可以视为使用【万箭齐发】。]],
  ["$jy_luojiao1"] = "Muchas gracias afición, esto es para vosotros, Siuuu!!",
  ["#jy_luojiao_after"] = "罗绞",
  ["#jy_luojiao_archery_attack"] = "罗绞·万箭",
  ["#jy_luojiao_savage_assault"] = "罗绞·南蛮",
  ["#jy_luojiao_archery_attack_ask"] = "“点”数量为4，是否发动 罗绞·万箭",
  ["#jy_luojiao_savage_assault_ask"] = "“点”花色不同，是否发动 罗绞·南蛮",
  ["#jy_luojiao_both_ask"] = "罗绞 两个条件同时达成，是否发动",
  ["#jy_luojiao_ask_which"] = "罗绞 两个条件同时达成并发动，请选择要先视为使用的牌",

  ["jy_yusu"] = "玉玊",
  [":jy_yusu"] = "你的回合内，你使用或打出第二张基本牌时，你可以将其作为“点”置于武将牌上。",
  ["@jy_yusu_basic_count"] = "玉玊",
  ["$jy_yusu1"] = "Siu...",
  ["#jy_yusu_triggered"] = "已触发",

  ["~jy__aweiluo"] = "Messi, Messi, Messi, Messi...",

}

-- 水晶哥

-- 失去技能：原创之魂2017薛综
-- 觉醒技：山包邓艾
-- 受到伤害：一将2013曹冲
-- 没有次数距离限制：星火燎原刘焉
-- 无法被响应：tenyear_huicui1 #gonghu_delay
-- 使用一张牌：诸葛恪，借刀
local jy__yangfan = General(extension, "jy__yangfan", "qun", 4)

-- 四吃3的选牌规则
Fk:addPoxiMethod {
  name = "jy_sichi_3",
  card_filter = function(to_select, selected)
    -- 三张同类型的牌或两张不同类型的牌

    -- 如果已选择卡牌数小于等于1，直接返回真，因为还不知道到底要选的是相同的还是不同的类型
    if #selected <= 1 then return true end

    -- 如果已选择卡牌数大于等于3，直接返回假，因为不可能再通过多选一张满足条件了
    if #selected >= 3 then return false end

    -- 如果已选择卡牌数为2，检查它们的类型是否相同
    if #selected == 2 then
      local type = Fk:getCardById(to_select).type
      local type1 = Fk:getCardById(selected[1]).type
      local type2 = Fk:getCardById(selected[2]).type
      -- 如果两张卡牌类型相同，那么对和它们类型相同的牌返回真，因为只能这样满足条件了
      if type1 == type2 then
        return type == type1
        -- 如果两张卡牌类型不同，那么已经满足要求了，返回假
      else
        return false
      end
    end
    -- 如果以上条件都不满足，返回真
    return true
  end,
  feasible = function(selected)
    if #selected <= 1 then
      return false
    elseif #selected == 2 then
      return Fk:getCardById(selected[1]).type ~= Fk:getCardById(selected[2]).type
    elseif #selected == 3 then
      return Fk:getCardById(selected[1]).type == Fk:getCardById(selected[2]).type and
          Fk:getCardById(selected[2]).type == Fk:getCardById(selected[3]).type
    end
  end,
  prompt = function()
    return Fk:translate("#jy_sichi_3")
  end
}
-- 四吃
local jy_sichi = fk.CreateTriggerSkill {
  name = "jy_sichi",
  anim_type = "masochism",
  events = { fk.Damaged },
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#jy_sichi-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 亮出四张牌
    local card_ids = room:getNCards(4)
    -- 放到过程区
    room:moveCards({
      ids = card_ids,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
    })
    -- 看花色有多少种，测试通过
    local dict = { false, false, false, false }
    local suit_count = 0
    for _, c in ipairs(card_ids) do
      local suit = Fk:getCardById(c).suit
      if not dict[suit] then
        dict[suit] = true
        suit_count = suit_count + 1
      end
    end
    assert(suit_count <= 4 and suit_count >= 1)
    -- TODO:其实主要是担心如果用..它不会翻译成中文。有空可以试一下
    local msg
    if suit_count == 1 then
      msg = "#jy_sichi_suits_1"
    elseif suit_count == 2 then
      msg = "#jy_sichi_suits_2"
    elseif suit_count == 3 then
      msg = "#jy_sichi_suits_3"
    elseif suit_count == 4 then
      msg = "#jy_sichi_suits_4"
    end
    room:doBroadcastNotify("ShowToast", Fk:translate(msg))

    -- 一种花色：全部给一个人，测试通过
    if suit_count == 1 then
      -- 不能直接用room:getOtherPlayers(player)，因为这个函数返回的是player，而askForChoosePlayers需要的是id（integer）。
      -- 无法让这些展示的牌在结算完成之前保留在屏幕上，火攻也不行
      local targets = table.map(room:getAlivePlayers(), Util.IdMapper)
      local result = room:askForChoosePlayers(player, targets, 1, 1, "#jy_sichi_1", self.name, true, false) -- 这玩意返回的是id列表
      if #result ~= 0 then                                                                                  -- 点击取消，就给自己
        room:moveCardTo(card_ids, Player.Hand, room:getPlayerById(result[1]), fk.ReasonGive, self.name, nil, false,
          player.id)
      else
        room:moveCardTo(card_ids, Player.Hand, player, fk.ReasonGive, self.name, nil, false, player.id)
      end

      -- 2种花色：判断是否有可以使用的牌。如果有，选择其中一张可以使用的牌，然后选择目标并使用，如果没有，弃置一张牌
      -- 因为我们只选一张，所以用addSubcard就可以了。如果你要移植这个函数到别的地方去，那就记得改单复数（
    elseif suit_count == 2 then
      -- 1. 先判断是否全都无法使用，如果全都无法使用，直接让他弃牌，把这几张牌都丢到弃牌堆去，结束这个技能
      local is_any_card_usable = false
      for _, c in ipairs(card_ids) do
        if U.canUseCard(room, player, Fk:getCardById(c), true) then
          is_any_card_usable = true
          break
        end
      end
      -- is_any_card_usable = false  -- 测试用的，记得改回来
      if not is_any_card_usable then
        room:doBroadcastNotify("ShowToast", Fk:translate("#jy_sichi_2_failed_toast"))
        room:askForDiscard(player, 1, 1, true, self.name, false, ".", "#jy_sichi_2_failed", false)
        room:moveCards({
          ids = card_ids,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
        })
        -- 在此处已经把垃圾丢完了，所以可以放心return
        return false
      end

      -- 2. 如果有可以使用的牌，用五谷丰登（神吕蒙）的方式把牌展示出来，其中不可使用的牌变灰，让他选择一张没有变灰的牌
      table.forEach(room.players, function(p)
        room:fillAG(p, card_ids) -- 让每个人都能看到AG
      end)

      for i = 1, #card_ids do                                            -- 对于所有的牌
        local id = card_ids[i]
        if not U.canUseCard(room, player, Fk:getCardById(id), true) then -- 如果这张牌无法使用
          room:takeAG(player, id)                                        -- 把这张牌标记为被拿了（也就是变灰）
          -- table.removeOne(card_ids, id)  -- 把这张牌从所有的牌中移除。此时不需要。
        end
      end
      local card_id = room:askForAG(player, card_ids, false, self.name) -- 要求你拿一张
      room:takeAG(player, card_id)
      table.removeOne(card_ids, card_id)                                -- 将这张牌从card_ids移除，因为最后要把所有的card_ids都弃掉
      room:closeAG()
      -- card_id 即为被选的牌

      local dummy = Fk:cloneCard("dilu")

      -- 3. 选择完毕后，放入他的手牌，并要求他为这张牌指定目标
      dummy:addSubcard(card_id)
      room:obtainCard(player.id, dummy, true, fk.ReasonPrey)

      local card = Fk:getCardById(card_id)

      -- TODO：这个肯定有更好的方式
      local name = card.trueName
      local number
      local suit

      if card.number == 11 then
        number = "J"
      elseif card.number == 12 then
        number = "Q"
      elseif card.number == 13 then
        number = "K"
      elseif card.number == 1 then
        number = "A"
      else
        number = tostring(card.number)
      end

      if card.suit == Card.Spade then
        suit = "spade"
      elseif card.suit == Card.Heart then
        suit = "heart"
      elseif card.suit == Card.Club then
        suit = "club"
      elseif card.suit == Card.Diamond then
        suit = "diamond"
      end

      -- 牌名|点数|花色  -- 这个exppattern.lua里用例子给的写法，可以匹配到
      local pattern = name .. "|" .. number .. "|" .. suit
      -- 雷杀火杀的匹配用truename即可，反正花色和点数会限制别的牌
      local use = room:askForUseCard(player, card.name, pattern, "#jy_sichi_2_use", false) -- 这里填false也没用，反正是可以取消的

      -- useCard
      if use then room:useCard(use) end

      -- 3种花色：选牌，然后所有人各摸一张
    elseif suit_count == 3 then
      local get = room:askForPoxi(player, "jy_sichi_3", {
        { self.name, card_ids },
      }, nil, true)
      if #get > 0 then
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(get)
        room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
      end
      -- 所有其他人各摸一张
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p.dead then
          p:drawCards(1, self.name)
        end
      end

      -- 4种花色：选择至多3名角色，你和他们各失去一点体力
    elseif suit_count == 4 then
      -- 业炎
      -- 这里只能选择除了自己以外的角色，因为自己肯定是要掉血的
      local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
        return true
      end), Util.IdMapper)
      local result = room:askForChoosePlayers(player, targets, 0, 3, "#jy_sichi_4", self.name) -- 这玩意返回的是id列表
      room:loseHp(player, 1, self.name)
      for _, p in ipairs(result) do
        local p_player = room:getPlayerById(p)
        if not p_player.dead then room:loseHp(p_player, 1, self.name) end
      end
    end

    -- 移动到弃牌堆，最后一起丢，前面的不用丢
    card_ids = table.filter(card_ids, function(id) return room:getCardArea(id) == Card.Processing end)
    if #card_ids > 0 then
      room:moveCards({
        ids = card_ids,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end,
}

-- ol_sp1 sheyan
local jy_huapen = fk.CreateTriggerSkill {
  name = "jy_huapen",
  anim_type = "control",
  events = { fk.TargetConfirming },
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.from ~= player.id and data.card and
        data.card.suit == Card.Club and
        (data.card:isCommonTrick() or data.card.type == Card.TypeBasic) then
      local previous_targets = AimGroup:getAllTargets(data.tos)
      if #AimGroup:getAllTargets(data.tos) ~= 1 then return false end -- 如果目标不是一个，那就不用管了
      -- 借刀杀人也被判定为单体卡牌
      -- 如果目标里面已经有我自己了，那就不要判定了
      for _, v in pairs(previous_targets) do
        if v == player.id then
          return false
        end
      end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club,diamond",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart then
      room:doIndicate(data.from, { player.id })      -- 播放指示线
      -- TODO：这里写的不对吧，targets根本就没用上
      if #AimGroup:getAllTargets(data.tos) == 1 then -- 如果只有一个人，那么把我也加进去
        table.insertTable(targets, AimGroup:getAllTargets(data.tos))
      end
      TargetGroup:pushTargets(data.targetGroup, player.id)
    end
  end,
}

local jy_boshi = fk.CreateTriggerSkill {
  name = "jy_boshi",
  frequency = Skill.Wake,
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
        player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("@jy_boshi_judge_count") >= #player.room:getAlivePlayers()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:setPlayerMark(player, "@jy_boshi_judge_count", 0) -- 清空标记
    room:handleAddLoseSkills(player, "-jy_huapen")
    room:handleAddLoseSkills(player, "jy_jiangbei")
  end,
  refresh_events = { fk.AskForRetrial },
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        player:usedSkillTimes("jy_boshi", Player.HistoryGame) == 0 -- 如果觉醒技未发动过，可以更新数值（发动过了就不更新了）
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jy_boshi_judge_count")
  end,
}

-- TODO: 重写这个技能，把它们放到一起
-- ♥无法被响应
local jy_jiangbei = fk.CreateTriggerSkill {
  name = "jy_jiangbei",
  frequency = Skill.Compulsory,
  events = { fk.CardUsing },
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if target == player and data.card.suit == Card.Heart then
      return data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
  end,
}
-- ♣没有距离次数限制
local jy_jiangbei_club = fk.CreateTargetModSkill {
  name = "#jy_jiangbei_club",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill("jy_jiangbei") and card.suit == Card.Club and to
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill("jy_jiangbei") and card.suit == Card.Club and to
  end,
}
-- ♣无视防具
-- 注意：targetSpecified事件只有一个data.to，因为是对每个target做一次。
-- local jy_jiangbei_club_2 = fk.CreateTriggerSkill {
--   name = "#jy_jiangbei_club_2",
--   frequency = Skill.Compulsory,
--   events = { fk.TargetSpecified },
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return false end
--     if target == player and data.card and data.card.suit == Card.Club then
--       return data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local to = room:getPlayerById(data.to)
--     local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
--     if use_event == nil then return end
--     room:addPlayerMark(to, fk.MarkArmorNullified)
--     use_event:addCleaner(function()
--       room:removePlayerMark(to, fk.MarkArmorNullified)
--     end)
--   end,
-- }
-- 计算出牌阶段使用打出了多少张红桃梅花。一旦使用打出了别的牌，就变为字符串。
-- TargetSpecified对每个目标都会执行一次，所以改成CardUsing。前面的虎啸也一并改了已经。
local jy_jiangbei_draw_count = fk.CreateTriggerSkill {
  name = "#jy_jiangbei_draw_count",
  mute = true,
  frequency = Skill.Compulsory,
  refresh_events = { fk.CardResponding, fk.CardUsing }, -- 包括了使用和打出
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card and player.phase == Player.Play then
      return target == player
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    -- 如果是红桃和梅花
    if (data.card.suit == Card.Club or data.card.suit == Card.Heart) and
        type(player:getMark("@jy_jiangbei_draw")) == "number" then -- 并且没有使用打出过别的花色
      room:addPlayerMark(player, "@jy_jiangbei_draw")
      -- else
      --   room:setPlayerMark(player, "@jy_jiangbei_draw", "#jy_jiangbei_no") -- 如果设置成字符串了，代表不允许摸牌了
    end
  end,
}
-- 出牌阶段结束时摸等量的牌
local jy_jiangbei_draw = fk.CreateTriggerSkill {
  name = "#jy_jiangbei_draw",
  anim_type = "special",

  -- 出牌阶段开始时把已使用打出的红桃梅花数设置成0
  refresh_events = { fk.EventPhaseStart },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and
        player.phase == Player.Play -- 在我的出牌阶段
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_jiangbei_draw", 0)
  end,

  events = { fk.EventPhaseEnd }, -- 包括了使用和打出
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
        and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    -- if type(player:getMark("@jy_jiangbei_draw")) == "number" then -- 只有是数字的时候，代表可以摸牌
    player:drawCards(player:getMark("@jy_jiangbei_draw"), self.name)
    -- end
    room:setPlayerMark(player, "@jy_jiangbei_draw", 0) -- 无论能不能摸牌，都要清理掉这个标记
  end,
}
jy_jiangbei:addRelatedSkill(jy_jiangbei_club)
-- jy_jiangbei:addRelatedSkill(jy_jiangbei_club_2)
jy_jiangbei:addRelatedSkill(jy_jiangbei_draw_count)
jy_jiangbei:addRelatedSkill(jy_jiangbei_draw)

jy__yangfan:addSkill(jy_sichi)
jy__yangfan:addSkill(jy_huapen)
jy__yangfan:addSkill(jy_boshi)
jy__yangfan:addRelatedSkill(jy_jiangbei)

Fk:loadTranslationTable {
  ["jy__yangfan"] = "杨藩",
  ["#jy__yangfan"] = "一鱼四吃",
  ["designer:jy__yangfan"] = "敏敏伊人梦中卿 & 考公专家",
  ["cv:jy__yangfan"] = "暂无",
  ["illustrator:jy__yangfan"] = "杨藩",

  ["jy_sichi"] = "四吃",
  [":jy_sichi"] = [[你受到伤害后，可以展示牌堆顶的4张牌，根据其花色数：1，令一名角色获得之；2，获得其中一张可以使用的牌并可以使用之，若都无法使用，你弃一张牌；3，获得3张同类型或2张不同类型的牌，然后其他角色摸一张牌；4，你与至多3名角色各失去一点体力。]],
  ["#jy_sichi-invoke"] = [[四吃：你可以大概率获得增益效果、小概率获得减益效果]],

  ["#jy_sichi_suits_1"] = "四吃：1种花色，选择一名角色获得这些牌",
  ["#jy_sichi_suits_2"] = "四吃：2种花色，获得一张可使用的牌并可以使用",
  ["#jy_sichi_suits_3"] = "四吃：3种花色，获得3张同类型或2张不同类型的牌，然后其他角色各摸一张牌",
  ["#jy_sichi_suits_4"] = "四吃：4种花色，选择至多3名角色一起失去1点体力",

  ["#jy_sichi_1"] = "四吃：选择一名角色获得这些牌，点击取消选择自己",
  ["#jy_sichi_2"] = "四吃：获得其中一张牌并可以使用",
  ["#jy_sichi_2_use"] = "四吃：你可以使用这张牌",
  ["#jy_sichi_2_failed_toast"] = "四吃：2种花色，没有可使用的牌，弃一张牌",
  ["#jy_sichi_2_failed"] = "四吃：没有可使用的牌，弃一张牌",
  ["jy_sichi_3"] = "四吃",
  ["#jy_sichi_3"] = "四吃：选择其中3张同类型的牌或2张不同类型的牌获得，然后除你以外的角色各摸一张牌",
  ["#jy_sichi_4"] = "四吃：选择至多3名角色，你和他们各失去一点体力",

  ["jy_huapen"] = "花盆",
  [":jy_huapen"] = [[锁定技，其他角色使用♣普通锦囊牌或基本牌指定唯一角色为目标时，若不为你，则你进行判定，若判定结果不为<font color="red">♥</font>，则你也成为该牌的目标。]],

  ["jy_boshi"] = "搏时",
  [":jy_boshi"] = [[觉醒技，准备阶段，若你已判定过至少X次（X为存活角色数），你减一点体力上限、失去〖花盆〗并获得〖奖杯〗。]],
  ["@jy_boshi_judge_count"] = "搏时",

  ["jy_jiangbei"] = "奖杯",
  [":jy_jiangbei"] = [[锁定技，你的♣基本牌和锦囊牌无距离和次数限制；你的<font color="red">♥</font>基本牌和锦囊牌不可被响应；出牌阶段结束时，你摸X张牌（X为你出牌阶段使用或打出的♣和<font color="red">♥</font>牌数）。]],
  ["#jy_jiangbei_heart"] = "奖杯",
  ["#jy_jiangbei_club"] = "奖杯",
  ["#jy_jiangbei_club_2"] = "奖杯",
  ["@jy_jiangbei_draw"] = "奖杯",
  ["#jy_jiangbei_no"] = "不可摸牌",
  -- TODO：改一下这里，按照sp公孙瓒义从改，只提示触发了义从。
}

-- 参考：廖化，英姿，蛊惑，血裔
local jy__mou__gaotianliang = General(extension, "jy__mou__gaotianliang", "god", 4)
jy__mou__gaotianliang.total_hidden = true

local jy_tianling = fk.CreateViewAsSkill {
  name = "jy_tianling",
  anim_type = "special",
  pattern = ".",
  interaction = function()
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick()
          -- and card.trueName ~= "ex_nihilo" and card.trueName ~= "snatch" and card.trueName ~= "amazing_grace"
          and not card.is_derived and
          ((Fk.currentResponsePattern == nil and Self:canUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        table.insertIfNeed(names, card.name)
      end
    end
    if #names == 0 then return false end
    return UI.ComboBox { choices = names }
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    self.cost_data = cards
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local cards = self.cost_data
    local card_id = cards[1]
    use.card:addSubcard(card_id)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@jy_tianling") ~= 0 and not player:isKongcheng() and player.phase ~= Player.NotActive and
        player:usedSkillTimes(self.name, Player.HistoryTurn) < 5
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@jy_tianling") ~= 0 and player.phase ~= Player.NotActive and not response and
        not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) < 5
  end,
}
local jy_tianling_yuyu = fk.CreateTriggerSkill {
  name = "#jy_tianling_yuyu",
  anim_type = "masochism",

  refresh_events = { fk.EventPhaseEnd },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and
        target.phase == Player.Judge and
        player:getMark("@jy_tianling") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jy_tianling", 0)
  end,

  events = { fk.EventPhaseStart },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player == target and player.phase == Player.Discard
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askForDiscard(player, 2, 2, true, self.name, true, nil, "#jy_tianling-prompt")
    if #cards == 0 then
      room:loseHp(player, 1, self.name)
    end
    room:setPlayerMark(player, "@jy_tianling", "")
  end,
}
local jy_tianling_dangxian = fk.CreateTriggerSkill {
  name = "#jy_tianling_dangxian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = { fk.EventPhaseChanging },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        data.to == Player.Start and player:getMark("@jy_tianling") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, true)
  end,
}
jy_tianling:addRelatedSkill(jy_tianling_yuyu)
jy_tianling:addRelatedSkill(jy_tianling_dangxian)

local jy_yali = fk.CreateTriggerSkill {
  name = "jy_yali",
  events = { fk.EventPhaseChanging },
  anim_type = "negative",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.to == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
}

local jy_fengnu = fk.CreateViewAsSkill {
  name = "jy_fengnu",
  anim_type = "special",
  pattern = ".",
  interaction = function()
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeTrick
          and not card.is_derived and
          ((Fk.currentResponsePattern == nil and Self:canUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        table.insertIfNeed(names, card.name)
      end
    end
    if #names == 0 then return false end
    return UI.ComboBox { choices = names }
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 2 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    self.cost_data = cards
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    use.card:addSubcards(self.cost_data)
    player.room:removePlayerMark(player, "@jy_fengnu-turn")
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@jy_fengnu-turn") ~= 0 and player:getMark("@jy_fengnu-turn") > 0 and
        #player:getCardIds("h") >= 2 and
        player.phase ~= Player.NotActive
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@jy_fengnu-turn") ~= 0 and player:getMark("@jy_fengnu-turn") > 0 and
        player.phase ~= Player.NotActive and not response and
        #player:getCardIds("h") >= 2
  end,
}
local jy_fengnu_trigger = fk.CreateTriggerSkill {
  name = "#jy_fengnu_trigger",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = { fk.TurnStart },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@jy_fengnu-turn", #room.alive_players)
    room:changeMaxHp(player, -1)
  end,
}
jy_fengnu:addRelatedSkill(jy_fengnu_trigger)

-- jy__mou__gaotianliang:addSkill(jy_yali)
-- jy__mou__gaotianliang:addSkill(jy_tianling)
jy__mou__gaotianliang:addSkill(jy_fengnu)
-- jy__mou__gaotianliang:addSkill(jy_yali)

Fk:loadTranslationTable {
  ["jy__mou__gaotianliang"] = "神高天亮",
  ["#jy__mou__gaotianliang"] = "凤鸣九天",
  ["designer:jy__mou__gaotianliang"] = "拂却心尘 & 考公专家",
  ["cv:jy__mou__gaotianliang"] = "暂无",
  ["illustrator:jy__mou__gaotianliang"] = "高天亮",

  ["jy_tianling"] = "开朗",
  [":jy_tianling"] = [[弃牌阶段开始时，你可以弃两张牌或失去一点体力。若如此做，你的下一个回合：准备阶段后执行一个额外的出牌阶段；判定阶段结束前，你可以将一张手牌当任意锦囊牌使用，至多5次。]],
  ["@jy_tianling"] = "开朗",
  ["#jy_tianling-prompt"] = "开朗：弃置两张牌或点击取消失去一点体力",
  ["#jy_tianling_dangxian"] = "开朗",
  ["#jy_tianling_yuyu"] = "开朗",

  ["jy_yali"] = [[绝境]],
  [":jy_yali"] = [[锁定技，你跳过摸牌阶段。]],

  ["jy_fengnu"] = [[凤怒]],
  ["@jy_fengnu-turn"] = [[凤怒]],
  ["#jy_fengnu_trigger"] = [[凤怒]],
  [":jy_fengnu"] = [[锁定技，你的回合开始时，你失去一点体力上限；你的回合内限X次，你可以将两张手牌当任意锦囊牌使用（X为存活角色数）。]],
}

local jy__raiden = General(extension, "jy__raiden", "god", 3, 3, General.Female)

local jy_leiyan = fk.CreateActiveSkill {
  name = "jy_leiyan",
  anim_type = "support",
  can_use = function(self, player)
    -- local room = player.room
    -- 如果所有人都有雷眼，那么就不能发动
    local all_players = true

    -- 在这里写room:getAlivePlayers不行
    -- Fk:currentRoom():getAlivePlayer也不行。因为这里用的是客户端Room。
    -- 这几个函数定义在服务端Room里
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:getMark("@jy_raiden_leiyan") == 0 then
        all_players = false
        break
      end
    end

    return not all_players and
        player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return Fk:currentRoom():getPlayerById(to_select):getMark("@jy_raiden_leiyan") == 0 and #selected == 0
  end,
  target_num = 1,
  on_use = function(self, room, use)
    for _, to in ipairs(use.tos) do
      local p = room:getPlayerById(to)
      room:setPlayerMark(p, "@jy_raiden_leiyan", "")
    end
  end,
}
local jy_leiyan_trigger = fk.CreateTriggerSkill {
  name = "#jy_leiyan_trigger",
  mute = true,
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = { fk.Damage },
  can_trigger = function(self, event, target, player, data)
    if not data.from then return false end -- 如果这次伤害没有伤害来源，就不用看了
    local from = data.from
    return from:getMark("@jy_raiden_leiyan") ~= 0 and
        player:hasSkill(self)
        and not data.is_leiyan
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local to = data.to

    if not target.dead then
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|club,spade",
      }
      room:judge(judge)
      if judge.card.color == Card.Black then
        player:broadcastSkillInvoke("jy_leiyan")
        room:doIndicate(player.id, { to.id }) -- 播放指示线
        room:damage({
          from = player,
          to = to,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = "jy_leiyan",
          is_leiyan = true,
        })
      end
    end
  end,
}
jy_leiyan:addRelatedSkill(jy_leiyan_trigger)

local jy_zhenshuo = fk.CreateActiveSkill {
  name = "jy_zhenshuo",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected, selected_targets)
    return #selected ~= 3 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  card_num = 3,
  target_filter = function(self, to_select, selected)
    return to_select ~= Self.id and Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
  end,
  target_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    local to = room:getPlayerById(use.tos[1])
    room:throwCard(use.cards, self.name, player, player)
    room:delay(900)
    room:damage({
      from = player,
      to = to,
      damage = 1,
      damageType = fk.ThunderDamage,
      skillName = self.name,
    })
    room:setPlayerMark(player, "@jy_zhenshuo-phase", "")
  end,
}
local zhenshuo_paoxiao = fk.CreateTargetModSkill {
  name = "#jy_zhenshuo_paoxiao",
  frequency = Skill.Compulsory,
  bypass_times = function(self, player, skill, scope)
    return player:hasSkill("jy_zhenshuo") and skill.trueName == "slash_skill" and
        player:getMark("@jy_zhenshuo-phase") ~= 0 and
        scope == Player.HistoryPhase
  end,
}
local zhenshuo_enter_dying = fk.CreateTriggerSkill {
  name = "#jy_zhenshuo_enter_dying",
  mute = true,
  frequency = Skill.Compulsory,
  refresh_events = { fk.EnterDying },
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill("jy_zhenshuo") and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(table.filter(room:getAlivePlayers(), function(p) return p:getMark("@jy_raiden_leiyan") ~= 0 end)) do
      room:setPlayerMark(p, "@jy_raiden_leiyan", 0)
    end
  end,
}
jy_zhenshuo:addRelatedSkill(zhenshuo_paoxiao)
jy_zhenshuo:addRelatedSkill(zhenshuo_enter_dying)

jy__raiden:addSkill(jy_leiyan)
jy__raiden:addSkill(jy_zhenshuo)

Fk:loadTranslationTable {
  ["jy__raiden"] = [[雷电将军]],
  ["#jy__raiden"] = "一心净土",
  ["designer:jy__raiden"] = "考公专家",
  ["cv:jy__raiden"] = "菊花花",
  ["illustrator:jy__raiden"] = "米哈游",

  ["~jy__raiden"] = "浮世一梦……",

  ["jy_leiyan"] = "雷眼",
  [":jy_leiyan"] = [[出牌阶段限一次，你可以令一名角色获得<font color="Fuchsia">雷眼</font>。有<font color="Fuchsia">雷眼</font>的角色不以此法造成伤害后，你判定，若为黑色，则你对目标造成一点雷电伤害。你进入濒死状态时，移除所有<font color="Fuchsia">雷眼</font>。]],
  ["@jy_raiden_leiyan"] = [[<font color="Fuchsia">雷眼</font>]],
  ["#jy_leiyan_trigger"] = "雷眼",
  ["$jy_leiyan1"] = "泡影看破！",
  ["$jy_leiyan2"] = "无处遁逃！",
  ["$jy_leiyan3"] = "威光无赦！",

  ["jy_zhenshuo"] = "真说",
  ["@jy_zhenshuo-phase"] = [[<font color="Fuchsia">真说</font>]],
  [":jy_zhenshuo"] = [[出牌阶段限一次，你可以弃三张牌对一名攻击范围内的角色造成一点雷电伤害，然后本阶段你使用【杀】无次数限制。]],
  ["$jy_zhenshuo1"] = "此刻，寂灭之时！",
  ["$jy_zhenshuo2"] = "稻光，亦是永恒！",
  ["$jy_zhenshuo3"] = "无念，断绝！",
}

local jy__ayato = General(extension, "jy__ayato", "qun", 4)

local jy_jinghua = fk.CreateTriggerSkill {
  name = "jy_jinghua",
  anim_type = "offensive",
  events = { fk.CardRespondFinished, fk.CardUseFinished },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card and data.card.type == Card.TypeBasic and
        target == player and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local extraData = { bypass_times = true }                                                                      -- 加上这个，就可以让它就算之前使用过杀，也可以再使用了
    self.jinghua_use = player.room:askForUseCard(player, "slash", "slash|.|.", "#jy_jinghua_use", true, extraData) -- 这里填false也没用，反正是可以取消的
    return self.jinghua_use
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local disresponsiveList = table.map(room.alive_players, Util.IdMapper)
    self.jinghua_use.extraUse = true -- 加上这个，就可以让它不计入次数了，也就是说还可以再使用一张杀
    self.jinghua_use.disresponsiveList = disresponsiveList
    room:useCard(self.jinghua_use)
  end,
}

local jy_jianying = fk.CreateTriggerSkill {
  frequency = Skill.Compulsory,
  name = "jy_jianying",
  anim_type = "defensive",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and
        target.phase == Player.Finish and
        #player:getCardIds(Player.Hand) < 2
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}

jy__ayato:addSkill(jy_jinghua)
jy__ayato:addSkill(jy_jianying)

--[[
  获取原神配音方法：去下面网站找到你的角色的页面，然后查看源文件，搜索配音即可。
  https://bbs.mihoyo.com/ys/obc/channel/map/189/25?bbs_presentation_style=no_header
]]

Fk:loadTranslationTable {
  ["jy__ayato"] = [[神里绫人]],
  ["#jy__ayato"] = "磐祭叶守",
  ["designer:jy__ayato"] = "考公专家",
  ["cv:jy__ayato"] = "赵路",
  ["illustrator:jy__ayato"] = "米哈游",

  ["~jy__ayato"] = "世事无常……",

  ["jy_jinghua"] = "镜花",
  [":jy_jinghua"] = [[每回合限一次，你使用或打出一张基本牌后，可以使用一张无次数限制且不可被响应的【杀】。]],
  ["$jy_jinghua1"] = "苍流水影。",
  ["$jy_jinghua2"] = "剑影。",
  ["#jy_jinghua_use"] = "镜花：你可以使用一张无次数限制且不可响应的【杀】",

  ["jy_jianying"] = "渐盈",
  [":jy_jianying"] = [[锁定技，每名角色的结束阶段，若你的手牌少于2张，你摸一张牌。]],
  ["$jy_jianying1"] = "冒进是大忌。",
  ["$jy_jianying2"] = "呵……余兴节目。",
}

local jy__liuxian = General(extension, "jy__liuxian", "god", 3, 3, General.Female)

local jy_jieyin = fk.CreateActiveSkill {
  frequency = Skill.Limited,
  name = "jy_jieyin",
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

      -- 获得其所有牌
      if not p:isNude() then
        local cards_id = p:getCardIds("hej")
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

      room:setPlayerMark(p, "jy_jieyin-phase", true)
    end
  end,
}
local jieyin_prohibit = fk.CreateProhibitSkill {
  name = "#jy_jieyin_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:hasSkill(self) and to:getMark("jy_jieyin-phase") ~= 0
  end,
}
jy_jieyin:addRelatedSkill(jieyin_prohibit)

jy__liuxian:addSkill(jy_jieyin)

Fk:loadTranslationTable {
  ["jy__liuxian"] = [[刘仙]],
  ["#jy__liuxian"] = "人中龙凤",
  ["designer:jy__liuxian"] = "考公专家",
  ["cv:jy__liuxian"] = "暂无",
  ["illustrator:jy__liuxian"] = "意间AI",

  ["jy_jieyin"] = "结姻",
  [":jy_jieyin"] = [[限定技，出牌阶段，你可以令一名已受伤的男性角色与你各回复1点体力，你获得其所有牌并视为拥有其所有技能。若如此做，本阶段其不是你使用牌的合法目标。]],
  ["$jy_jieyin1"] = [[夫君，身体要紧。]],
  ["$jy_jieyin2"] = [[他好，我也好。]],
}

local jy__huohuo = General(extension, "jy__huohuo", "wu", 3, 3, General.Female)

-- TODO：可以不写这个
local jy_bazhen = fk.CreateTriggerSkill {
  name = "jy_bazhen",
  events = { fk.AskForCardUse, fk.AskForCardResponse },
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isFakeSkill(self) and
        (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
        not player:getEquipment(Card.SubtypeArmor) and player:getMark(fk.MarkArmorNullified) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judgeData = {
      who = player,
      reason = "eight_diagram",
      pattern = ".|.|heart,diamond",
    }
    room:judge(judgeData)

    if judgeData.card.color == Card.Red then
      if event == fk.AskForCardUse then
        data.result = {
          from = player.id,
          card = Fk:cloneCard('jink'),
        }
        data.result.card.skillName = "eight_diagram"
        data.result.card.skillName = "bazhen"

        if data.eventData then
          data.result.toCard = data.eventData.toCard
          data.result.responseToEvent = data.eventData.responseToEvent
        end
      else
        data.result = Fk:cloneCard('jink')
        data.result.skillName = "eight_diagram"
        data.result.skillName = "bazhen"
      end
      return true
    end
  end
}

local jy_lingfu = fk.CreateActiveSkill {
  name = "jy_lingfu",
  anim_type = "offensive",
  min_target_num = 1,
  max_target_num = 3,
  min_card_num = 3,
  max_card_num = 5,
  can_use = function(self, player)
    return #player:getCardIds { Player.Hand, Player.Equip } >= 3 and player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    if Self:prohibitDiscard(Fk:getCardById(to_select)) then return end
    return #selected < 5
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return #selected < #selected_cards - 2 -- and to.hp ~= to.maxHp
  end,
  feasible = function(self, selected, selected_cards)
    return #selected + 2 == #selected_cards
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    room:delay(600)
    for _, id in ipairs(effect.tos) do
      local to = room:getPlayerById(id)
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
      to:drawCards(2, self.name)
      if not to.faceup then
        to:turnOver()
      end
      if to.chained then
        to:setChainState(false)
      end
      if #to:getCardIds(Player.Judge) ~= 0 then
        local cards_id = to:getCardIds(Player.Judge)
        local dummy = Fk:cloneCard 'slash'
        dummy:addSubcards(cards_id)
        room:obtainCard(player.id, dummy, false, fk.ReasonPrey)
      end
    end
  end,
}

jy__huohuo:addSkill(jy_bazhen)
jy__huohuo:addSkill(jy_lingfu)

Fk:loadTranslationTable {
  ["jy__huohuo"] = [[藿藿]],
  ["#jy__huohuo"] = "令奉贞凶",
  ["designer:jy__huohuo"] = "考公专家",
  ["cv:jy__huohuo"] = "葛子瑞 & 刘北辰",
  ["illustrator:jy__huohuo"] = "米哈游",

  ["~jy__huohuo"] = [[投……投降……]],

  ["jy_bazhen"] = "八阵",
  [":jy_bazhen"] = [[锁定技，若你没有装备防具，视为你装备着【八卦阵】。]],
  ["$jy_bazhen1"] = "尾巴：走你。 藿藿：啊啊啊——",
  ["$jy_bazhen2"] = "不要啊救命啊——",
  ["$jy_bazhen3"] = "怎么还没结束……",
  ["$jy_bazhen4"] = "说不定我也能做到……",

  ["jy_lingfu"] = "驱邪",
  [":jy_lingfu"] = [[出牌阶段限一次，你可以弃置X+2张牌并令X名角色（X由你选择且不能大于3）回复一点体力、摸两张牌、重置武将牌，最后你获得其判定区的牌。]],
  ["$jy_lingfu1"] = [[驱邪……缚魅……]],
  ["$jy_lingfu2"] = [[灵符……保命……]],
}

local argenti = General(extension, "jy__argenti", "qun", 4)

local chunmei = fk.CreateTriggerSkill {
  frequency = Skill.Compulsory,
  name = "jy_chunmei",
  anim_type = "defensive",
  events = { fk.Damage },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (data.from == player or data.to == player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|heart,diamond",
    }
    room:judge(judge)
    if judge.card.color == Card.Red and not player.dead then
      room:obtainCard(player.id, judge.card)
    end
  end
}

local zhuhua = fk.CreateActiveSkill {
  name = "jy_zhuhua",
  anim_type = "offensive",
  min_card_num = 3,
  max_card_num = 4,
  can_use = function(self, player)
    -- return #player:getCardIds(Player.Hand) >= 3
    return true
  end,
  card_filter = function(self, to_select, selected)
    if Self:prohibitDiscard(Fk:getCardById(to_select)) then return false end
    -- if not table.contains(Self:getHandlyIds(true), to_select) then return false end
    if #selected == 4 then return false end
    if #selected == 0 then
      return true
    else
      return Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
    end
  end,
  feasible = function(self, selected, selected_cards)
    return #selected_cards == 3 or #selected_cards == 4
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    if #effect.cards == 3 then
      room:useVirtualCard("archery_attack", nil, player, room:getOtherPlayers(player, true), self.name, true)
    else
      room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
      room:delay(1000)
      for _, p in ipairs(room:getOtherPlayers(player, true)) do
        if not player.dead then -- 如果我自己死了（因为各种乱七八糟的技能弹反），那就不要继续了
          room:damage({
            from = player,
            to = p,
            damage = 1,
            damageType = fk.NormalDamage,
          })
        end
      end
    end
  end,
}

argenti:addSkill(chunmei)
argenti:addSkill(zhuhua)

Fk:loadTranslationTable {
  ["jy__argenti"] = [[银枝]],
  ["#jy__argenti"] = "荆冠芳勋",
  ["designer:jy__argenti"] = "考公专家",
  ["cv:jy__argenti"] = "梁达伟",
  ["illustrator:jy__argenti"] = "米哈游",

  ["~jy__argenti"] = [[没找到……「祂」……]],

  ["jy_chunmei"] = "纯美",
  [":jy_chunmei"] = [[锁定技，你造成或受到伤害时进行判定，若为红色，你获得该判定牌。]],

  ["jy_zhuhua"] = "驻花",
  [":jy_zhuhua"] = [[出牌阶段，你可以弃三张相同花色的牌并视为使用【万箭齐发】；你可以弃四张相同花色的牌并对其他所有角色造成一点伤害。]],
  ["$jy_zhuhua1"] = [[再次见到那道光芒之前……]],
  ["$jy_zhuhua2"] = [[银河中的一切美丽，我将捍卫至最后一刻！]],
  ["$jy_zhuhua3"] = [[……献给伊德莉拉。]],
}


local guiyi = fk.CreateTriggerSkill {
  name = "jy_guiyi",
  anim_type = "offensive",
  events = { fk.EventPhaseProceeding },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and
        target.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "#jy_guiyi_viewas", "#jy_guiyi-use", true)
    if success then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("duel")
    card:addSubcards(self.cost_data.cards)
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = table.map(self.cost_data.targets, function(p) return { p } end),
      card = card,
      extraData = { bypass_distances = true },
    }
    room:useCard(use)
    if use.damageDealt and use.damageDealt[player.id] then
      room:killPlayer({ who = player.id })
    end
  end,
}
local guiyi_viewas = fk.CreateViewAsSkill {
  name = "#jy_guiyi_viewas",
  anim_type = "offensive",
  pattern = "duel",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return true
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("duel")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
guiyi:addRelatedSkill(guiyi_viewas)

Fk:loadTranslationTable {
  ["jy__gambler"] = [[赌徒]],
  ["#jy__gambler"] = "游刃有余",
  ["designer:jy__gambler"] = "考公专家",
  ["cv:jy__gambler"] = "暂无",
  ["illustrator:jy__gambler"] = "米哈游",

  ["jy_guiyi"] = [[命弈]],
  [":jy_guiyi"] = [[每名角色的结束阶段，你可以将一张牌当【决斗】使用。若此【决斗】对你造成伤害，你死亡。]],
  ["#jy_guiyi_viewas"] = [[命弈]],
  ["#jy_guiyi-use"] = [[命弈：将一张牌当【决斗】使用，若其对你造成伤害则你死亡]],
}

local gambler = General(extension, "jy__gambler", "qun", 8)
gambler:addSkill(guiyi)
gambler:addSkill("benghuai")

local pojun = fk.CreateTriggerSkill {
  name = "jy_pojun",
  anim_type = "offensive",
  events = { fk.TargetSpecified },
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      local to = player.room:getPlayerById(data.to)
      return not to.dead and not to:isNude()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:getPlayerById(data.to)
    if data.to > 0 then
      return player.room:askForSkillInvoke(player, self.name, nil,
        "#jy_pojun-invoke::" .. data.to .. ":" .. math.min(2, #to:getCardIds("hej")))
    else
      return player.room:askForSkillInvoke(player, self.name, nil,
        "#jy_pojun-invoke-robot::" .. data.to)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, { data.to })
    local to = room:getPlayerById(data.to)
    if data.to > 0 then
      local cards = room:askForCardsChosen(player, to, 1, 2, "hej", self.name)
      room:moveCardTo(cards, Player.Hand,
        player, fk.ReasonPrey, "jy_pojun")
    else
      room:moveCardTo(to:getCardIds("hej"), Player.Hand,
        player, fk.ReasonPrey, "jy_pojun")
    end
  end,
}

-- local jiedao = fk.CreateViewAsSkill {
--   name = "jy_jiedao",
--   anim_type = "offensive",
--   pattern = "slash,analeptic",
--   enabled_at_play = function(self, player, response)
--     return #table.filter(player:getCardIds("he"), function(c)
--       local card = Fk:getCardById(c)
--       return card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon
--     end) ~= 0
--   end,
--   enabled_at_response = function(self, player, response)
--     return #table.filter(player:getCardIds("he"), function(c)
--       local card = Fk:getCardById(c)
--       return card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon
--     end) ~= 0
--   end,
--   interaction = function()
--     local names = {}
--     for _, name in ipairs({ "slash", "analeptic" }) do
--       local c = Fk:cloneCard(name)
--       if (Fk.currentResponsePattern == nil and c.skill:canUse(Self, c)) or
--           (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c)) then
--         table.insertIfNeed(names, name)
--       end
--     end
--     return UI.ComboBox { choices = names }
--   end,
--   card_filter = function(self, to_select, selected)
--     if #selected == 1 then return false end
--     local card = Fk:getCardById(to_select)
--     return card.type == Card.TypeEquip and card.sub_type == Card.SubtypeWeapon
--   end,
--   view_as = function(self, cards)
--     if not self.interaction.data then return nil end
--     if #cards ~= 1 then
--       return nil
--     end
--     local card = Fk:cloneCard(self.interaction.data)
--     card.skillName = self.name
--     card:addSubcards(cards)
--     return card
--   end,
-- }
-- local jiedao_weapon = fk.CreateTriggerSkill {
--   name = "#jy_jiedao_weapon",
--   anim_type = 'control',
--   events = { fk.AfterCardsMove },
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return false end
--     for _, move in ipairs(data) do
--       if move.to ~= player.id and move.toArea == Card.PlayerEquip then
--         for _, info in ipairs(move.moveInfo) do
--           local c = Fk:getCardById(info.cardId)
--           if c.type == Card.TypeEquip and c.sub_type == Card.SubtypeWeapon then
--             return true
--           end
--         end
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:loseHp(player, 1)
--     if not player:isAlive() then return end
--     local ids = {}
--     for _, move in ipairs(data) do
--       if move.to ~= player.id and (move.toArea == Card.PlayerEquip or move.toArea == Card.DiscardPile) then
--         for _, info in ipairs(move.moveInfo) do
--           local c = Fk:getCardById(info.cardId)
--           if c.type == Card.TypeEquip and c.sub_type == Card.SubtypeWeapon then
--             table.insert(ids, info.cardId)
--           end
--         end
--       end
--     end
--     local dummy = Fk:cloneCard("dilu")
--     dummy:addSubcards(ids)
--     room:obtainCard(player, dummy, true, fk.ReasonPrey)
--     local use = room:askForUseCard(player, "slash", nil, "#jy_jiedao_slash", true)
--     if use then room:useCard(use) end
--   end,
-- }
-- jiedao:addRelatedSkill(jiedao_weapon)

local xusheng = General(extension, "jy__xusheng", "wu", 3)
xusheng:addSkill(pojun)
-- xusheng:addSkill(jiedao)

Fk:loadTranslationTable {
  ["jy__xusheng"] = [[劫徐盛]],
  ["#jy__xusheng"] = "杀机器人妙手",
  ["designer:jy__xusheng"] = "考公专家",
  ["~jy__xusheng"] = "盛只恨，不能再为主公，破敌致胜了！",

  ["$jy_pojun1"] = "犯大吴疆土者，盛必击而破之！",
  ["$jy_pojun2"] = "若敢来犯，必教你大败而归！",

  ["jy_pojun"] = [[破军]],
  ["#jy_pojun-invoke"] = "破军：你可以获得 %dest 区域内至多 %arg 张牌",
  ["#jy_pojun-invoke-robot"] = "破军：%dest 是机器人，所以你可以获得其区域内所有牌！",
  ["#jy_pojun_delay"] = [[破军]],
  [":jy_pojun"] = [[当你使用【杀】指定一个目标后，你可以获得其区域内至多两张牌。]],

  -- ["jy_jiedao"] = [[劫刀]],
  -- ["#jy_jiedao"] = "劫刀：将一张武器牌当【杀】或【酒】使用或打出",
  -- ["#jy_jiedao_weapon"] = [[劫刀]],
  -- ["#jy_jiedao_slash"] = [[劫刀：你可以使用一张【杀】]],
  -- [":jy_jiedao"] = [[你可以将一张武器牌当【杀】或【酒】使用或打出。当武器牌移至其他角色的装备区时，你可以失去一点体力并获得之，若如此做，你可以使用一张【杀】。]],
  -- ["$jy_jiedao1"] = [[战将临阵，斩关刈城！]],
}

local wanghun = fk.CreateTriggerSkill {
  name = "jy_wanghun",
  switch_skill_name = "jy_wanghun",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = { fk.TurnEnd },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      if player.hp == 1 then
        player.room:recover({
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      end
    else
      player:drawCards(1, self.name)
      local hands = #player:getCardIds("h")
      if hands > 4 then
        player.room:askForDiscard(player, hands - 4, hands - 4, true, self.name, false, ".", "#jy_wanghun_discard", false)
      end
    end
  end,
}

local function doExecute(player, target, damage)
  local room = player.room
  room:doIndicate(player.id, { target.id })
  -- room:changeShield(target, -target.shield)
  room:damage({
    from = player,
    to = target,
    damage = damage,
    damageType = fk.NormalDamage,
    skillName = "jy_yonghen",
  })
  if not target:isAlive() then
    -- player:drawCards(1, "jy_yonghen")
    -- room:handleAddLoseSkills(player, "jy_trad_xiuxing")
    -- room:changeMaxHp(player, -player.maxHp + 1)
    local targets = table.map(room:getOtherPlayers(player, true), Util.IdMapper)
    local result = room:askForChoosePlayers(player, targets, 1, 1, "#jy_yonghen-ask", "jy_yonghen", true, false)
    if #result == 0 then
      player:setSkillUseHistory("jy_yonghen", 0, Player.HistoryGame)
    else
      doExecute(player, room:getPlayerById(result[1]), 1)
    end
  end
end

local yonghen = fk.CreateTriggerSkill {
  name = "jy_yonghen",
  anim_type = "offensive",
  frequency = Skill.Limited,
  events = { fk.HpChanged },
  can_trigger = function(self, event, target, player, data)
    return target ~= player and target.hp == 1 and player:hasSkill(self) and
        player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil,
      "#jy_yonghen-invoke::" .. target.id)
  end,
  on_use = function(self, event, target, player, data)
    doExecute(player, target, 1)
  end,
}

local pyke = General(extension, "jy__pyke", "qun", 2)
pyke:addSkill(wanghun)
pyke:addSkill(yonghen)
-- pyke:addRelatedSkill("jy_trad_xiuxing")

Fk:loadTranslationTable {
  ["jy__pyke"] = [[派克]],
  ["#jy__pyke"] = "血港鬼影",
  ["designer:jy__pyke"] = "考公专家",
  ["cv:jy__pyke"] = "彭博",
  ["illustrator:jy__pyke"] = "Riot",

  ["jy_wanghun"] = [[亡魂]],
  [":jy_wanghun"] = [[转换技，锁定技，每名角色的回合结束时，你发动此技能，①若你体力值为1，你回复一点体力；②你摸一张牌，然后将手牌弃至4张。]],
  ["#jy_wanghun_discard"] = [[亡魂：将手牌弃至4张]],

  ["jy_yonghen"] = [[涌恨]],
  [":jy_yonghen"] = [[限定技，当一名其他角色的体力值改变为1后，你可以对其造成1点伤害。若该伤害结算后其死亡，则你选择一项：对一名其他角色重复此流程，或重置此技能。]],
  ["#jy_yonghen-invoke"] = [[涌恨：你可以对 %dest 造成1点伤害，若其死亡则可继续或重置该技能！]],
  ["#jy_yonghen-ask"] = [[涌恨：对一名其他角色造成1点伤害，若其死亡则可继续，点击取消重置该技能]],
  ["$jy_yonghen1"] = [[没有痛苦，长眠吧。]],
  ["$jy_yonghen2"] = [[欢迎来到……深渊……]],
}

local kanxi = fk.CreateTriggerSkill {
  name = "jy_kanxi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if player:getMark("@jy_ruju") == 0 then
        return target ~= player and data.from ~= player
      else
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(data.damage, self.name)
  end,
}

local ruju = fk.CreateActiveSkill {
  name = "jy_ruju",
  anim_type = "offensive",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
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
    room:changeMaxHp(player, -1)
    room:setPlayerMark(player, "@jy_ruju", "")
  end,
}
-- local ruju_trigger = fk.CreateTriggerSkill {
--   name = "#jy_ruju_trigger",
--   refresh_events = { fk.TurnStart },
--   can_refresh = function(self, event, target, player, data)
--     return target == player and player:hasSkill("jy_ruju") and player:getMark("@jy_ruju") ~= 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     player.room:setPlayerMark(player, "@jy_ruju", 0)
--   end,
-- }
-- ruju:addRelatedSkill(ruju_trigger)

local test = General(extension, "jy__test", "qun", 4, 4)
test:addSkill(kanxi)
test:addSkill(ruju)

Fk:loadTranslationTable {
  ["jy__test"] = [[乐子人]],
  ["#jy__test"] = "测试",
  ["designer:jy__test"] = "考公专家",
  ["cv:jy__test"] = "无",
  ["illustrator:jy__test"] = "无",

  ["jy_kanxi"] = [[看戏]],
  [":jy_kanxi"] = [[锁定技，一名其他角色受到伤害后，若伤害来源不为你，你摸等同于伤害值张牌。]],

  ["jy_ruju"] = [[入局]],
  ["#jy_ruju_trigger"] = [[入局]],
  ["@jy_ruju"] = [[入局]],
  ["#jy_ruju"] = [[入局：你可以减一点体力上限，将〖看戏〗改为所有伤害均可触发摸牌]],
  [":jy_ruju"] = [[限定技，出牌阶段，你可以减一点体力上限，将〖看戏〗改为所有伤害均可触发摸牌。]],
}

local jisu = fk.CreateTriggerSkill{
  name = "jy_jisu",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    self.count = 0
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            self.count = self.count - 1
          end
        end
      end
    end
    for _, move in ipairs(data) do
      if move.to and move.to == player.id and move.toArea == Player.Equip then
        self.count = self.count + 1
      end
    end
    return self.count ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = self.count

    -- 如果count大于0，表示有卡牌进入装备区，增加体力上限并恢复体力
    if count > 0 then
      room:changeMaxHp(player, count)  -- 增加体力上限
      room:recover { num = count, skillName = self.name, who = player, recoverBy = player }  -- 回复体力
    -- 如果count小于0，表示有卡牌离开装备区，减少体力上限并失去体力
    elseif count < 0 then
      room:loseHp(player, -count, self.name)      -- 失去体力（-count是负值，表示减少）
      room:changeMaxHp(player, count)  -- 减少体力上限
    end
  end,
}

local rengdao = fk.CreateActiveSkill {
  name = "jy_rengdao",
  anim_type = "offensive",
  can_use = function(self, player)
    return #table.filter(Fk:currentRoom().alive_players, function(p) return p ~= player and p.maxHp == p.hp end) > 0
  end,
  min_card_num = 0,
  max_card_num = 1,
  card_filter = function(self, to_select, selected, selected_targets)
    return #selected ~= 1 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, to_select, selected)
    local s = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and s.hp == s.maxHp and #selected < 1
  end,
  target_num = 1,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    local p = room:getPlayerById(use.tos[1])
    if #use.cards == 0 then
      room:loseHp(player, 1, self.name)
    else
      room:moveCardTo(use.cards[1], Card.PlayerHand, p, fk.ReasonGive, self.name, nil, false, nil)
    end
    if not player.dead and not p.dead then
      room:damage({
        from = player,
        to = p,
        damage = 1,
        damageType = fk.NormalDamage,
        skillName = self.name,
      })
    end
    player:drawCards(1, self.name)
  end,
}

local function changeAvatar(player, previous, after)
  if player.general == previous then
    player.general = after
    player.room:broadcastProperty(player, "general")
    return
  end
  if player.deputyGeneral == previous then
    player.deputyGeneral = after
    player.room:broadcastProperty(player, "deputyGeneral")
  end
end

local function dayao_awake (room, player, skill_name)
  local maxHpAdded = player.maxHp - player.hp
  room:changeMaxHp(player, maxHpAdded)
  player:drawCards(maxHpAdded, skill_name)
  room:recover { num = 1, skillName = skill_name, who = player, recoverBy = player}
  room:setPlayerMark(player, "jy_dayao_maxHpAdded", maxHpAdded)
  room:setPlayerMark(player, "@jy_dayao", 2 * player.maxHp)
  changeAvatar(player, "jy__drmundo", "jy__hidden__drmundo")
end

local dayao = fk.CreateActiveSkill {
  name = "jy_dayao",
  anim_type = "defensive",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    dayao_awake(room, player, self.name)
  end,
}
local dayao_trigger = fk.CreateTriggerSkill {
  name = "#jy_dayao_trigger",
  anim_type = "defensive",
  mute = true,
  frequency = Skill.Limited,
  events = { fk.Damaged },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        player:usedSkillTimes(dayao.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, dayao.name)
    player:setSkillUseHistory(dayao.name, 1, Player.HistoryGame)
    dayao_awake(room, player, "jy_dayao")
  end,
}
local dayao_heal = fk.CreateTriggerSkill {
  name = "#jy_dayao_heal",
  frequency = Skill.Compulsory,
  events = { fk.CardUsing },
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("@jy_dayao") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@jy_dayao")
    if player:isWounded() then room:recover { num = 1, skillName = self.name, who = player, recoverBy = player} end
    if player:getMark("@jy_dayao") == 0 then
      room:changeMaxHp(player, -player:getMark("jy_dayao_maxHpAdded"))
      room:removePlayerMark(player, "jy_dayao_maxHpAdded")
      changeAvatar(player, "jy__hidden__drmundo", "jy__drmundo")
    end
  end,
}
dayao:addRelatedSkill(dayao_trigger)
dayao:addRelatedSkill(dayao_heal)

local mundo = General(extension, "jy__drmundo", "jin", 3, 3)
mundo:addSkill(jisu)
mundo:addSkill(rengdao)
mundo:addSkill(dayao)

-- TODO: find a new avatar jpg
local hidden_mundo = General(extension, "jy__hidden__drmundo", "jin", 3, 3)
hidden_mundo:addSkill("jisu")
hidden_mundo:addSkill("rengdao")
hidden_mundo:addSkill("dayao")
hidden_mundo.total_hidden = true

Fk:loadTranslationTable {
  ["jy__drmundo"] = [[蒙多医生]],
  ["jy__hidden__drmundo"] = [[蒙多医生]],
  ["#jy__drmundo"] = "祖安狂人",
  ["designer:jy__drmundo"] = "考公专家",
  ["cv:jy__drmundo"] = "无",
  ["illustrator:jy__drmundo"] = "无",

  ["jy_jisu"] = [[激素]],
  [":jy_jisu"] = [[锁定技，你的体力上限和体力+X（X为你装备区牌数）。]],
  -- <br><font color="grey">每当一张牌进入你的装备区后，你增加一点体力上限然后回复一点体力；每当你失去一张装备区的牌后，你失去一点体力然后减少一点体力上限。</font>

  ["jy_rengdao"] = [[扔刀]],
  [":jy_rengdao"] = [[出牌阶段，你可以对一名未受伤的其他角色造成一点伤害并摸一张牌。你需先失去一点体力或将一张装备牌交给其。]],

  ["jy_dayao"] = [[打药]],
  ["#jy_dayao_trigger"] = [[打药]],
  ["#jy_dayao_heal"] = [[打药]],
  ["@jy_dayao"] = [[<font color="green">打药</font>]],
  [":jy_dayao"] = [[限定技，出牌阶段或你受到伤害后，你可以增加<strong>已损失体力值点</strong>体力上限、摸等量张牌并回复一点体力。然后<strong>两倍体力上限</strong>次，一名角色使用牌时，你回复一点体力。最后你失去以此法获得的体力上限。]],
}

return extension
