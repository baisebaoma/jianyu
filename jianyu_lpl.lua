local extension = Package:new("jianyu_lpl")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
     ["jianyu_lpl"] = "监狱：LPL篇",
     ["god"] = "神话再临·神",
}


-- 简自豪 设计：熊俊博 实现：反赌专家
local jianzihao = General(extension, "jianzihao", "god", 3, 3, General.Male)

-- 红温
local hongwen = fk.CreateFilterSkill{
  name = "hongwen",
  -- mute = true,
  card_filter = function(self, to_select, player)
    return (to_select.suit == Card.Spade or to_select.suit == Card.Club) and player:hasSkill(self)
  end,
  view_as = function(self, to_select)
    if to_select.suit == Card.Club then 
      return Fk:cloneCard(to_select.name, Card.Diamond, to_select.number)
    else -- Spade
      return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
    end
  end,
}

-- 走位
local zouwei = fk.CreateDistanceSkill{
  name = "zouwei",
  correct_func = function(self, from, to)
    -- 有装备时视为-1
    if from:hasSkill(self) and #from:getCardIds(Player.Equip) ~= 0 then
      -- 请使用#from:getCardIds(Player.Equip)来代表长度，
      -- 如果你只用from:getCardIds(Player.Equip)的话是代表这个数组
      return -1
    end
    -- 没装备时视为+1
    if to:hasSkill(self) and #to:getCardIds(Player.Equip) == 0 then
      return 1
    end
    return 0
  end,
}
-- 参考自孙尚香
local zouwei_audio = fk.CreateTriggerSkill{
  name = "#zouwei_audio",

  refresh_events = {fk.AfterCardsMove},
  -- 这个函数只有在装备区牌量变动时才检测
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            -- 当装备等于0或1的时候触发
            -- standard_cards/init.lua, line 1080: local handcards = player:getCardIds(Player.Hand)，我也不知道为啥用的是Player.Hand而不是player.hand，写就对了
            if #player:getCardIds(Player.Equip) <= 1 then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    -- 有装备时，-1马
    if #player:getCardIds(player.Equip) ~= 0 then
      room:notifySkillInvoked(player, "zouwei", "offensive")
      player:broadcastSkillInvoke("zouwei", 1)
    -- 无装备时，+1马
    elseif #player:getCardIds(player.Equip) == 0 then
      room:notifySkillInvoked(player, "zouwei", "defensive")
      player:broadcastSkillInvoke("zouwei", 2)
    end
  end,
}
zouwei:addRelatedSkill(zouwei_audio)

-- 圣弩
-- 参考自formation包的君刘备
local shengnu = fk.CreateTriggerSkill{
  name = "shengnu",
  anim_type = 'drawcard',
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
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


-- 转会
local zhuanhui = fk.CreateTriggerSkill{
  name = "zhuanhui",  -- kaiju$是主公技
  anim_type = "masochism",
  visible = false,
  frequency = Skill.Compulsory,
  events = {},  -- 这里是故意的，因为本来这个技能就没有实际效果
  can_trigger = function(self, event, target, player, data)
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
  end,
}

-- 洗澡
local xizao = fk.CreateTriggerSkill{
  name = "xizao",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    -- player:reset()
    player:drawCards(3, self.name)
    if player.dead or not player:isWounded() then return end
    -- 将体力回复至1点
    room:recover({
      who = player,
      num = math.min(1, player.maxHp) - player.hp,
      recoverBy = player,
      skillName = self.name,
    })
    player:turnOver()
  end,
}

-- 开局
-- 参考forest包贾诩 刘备 god包神曹操

local kaiju = fk.CreateTriggerSkill{
  name = "kaiju",  -- kaiju$是主公技
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true)) do
      if not p:isAllNude() then
        local id = room:askForCardChosen(p, p, "he", "#kaiju-choose")  -- 他自己用框选一张自己的牌，不包括判定区
        -- -- 下面这一堆是一起的，从贯石斧拿来的。
        -- local pattern
        -- if p:getEquipment(Card.SubtypeWeapon) then
        --   pattern = ".|.|.|.|.|.|^"..tostring(p:getEquipment(Card.SubtypeWeapon))
        -- else
        --   pattern = "."
        -- end
        -- local id = room:askForDiscard(p, 2, 2, true, self.name, false, ".", nil, true, false)
        -- -- 从贯石斧抄过来的
        room:obtainCard(player, id, false, fk.ReasonPrey)  -- 我从他那里拿一张牌来
        room:useVirtualCard("slash", nil, p, player, self.name, true)  -- 杀
      end
    end
  end,
}


-- local id = room:askForCardChosen(player, p, "hej", self.name)  -- 我选他一张牌

-- room:useVirtualCard("slash", nil, player, table.map(self.cost_data, Util.Id2PlayerMapper), self.name, true)


jianzihao:addSkill(zhuanhui)
jianzihao:addSkill(kaiju)
jianzihao:addSkill(hongwen)
jianzihao:addSkill(zouwei)
jianzihao:addSkill(shengnu)
jianzihao:addSkill(xizao)


Fk:loadTranslationTable{
  ["jianzihao"] = "简自豪",

  ["zhuanhui"] = "转会",
  [":zhuanhui"] = "<strong>这个武将由熊俊博设计！</strong>",
  -- [":zhuanhui"] = "<del>当你的体力值减少时，你可以变更势力。你无法变更为已经成为过的势力。</del>",
  ["$zhuanhui1"] = "被秀了，操。",

  ["kaiju"] = "开局",
  [":kaiju"] = "锁定技，当你的回合开始时，所有其他有牌的武将需要交给你一张牌，并视为对你使用一张【杀】。",
  ["$kaiju1"] = "不是啊，我炸一对鬼的时候我在打什么，打一对10。一对10，他四个9炸我，我不输了吗？",
  ["$kaiju2"] = "怎么赢啊？你别瞎说啊，兄弟们。",
  ["$kaiju3"] = "打这牌怎么打？兄弟们快教我，我看着头晕！",
  ["$kaiju4"] = "好亏呀，我每一波都。",
  ["#kaiju-choose"] = "简自豪【开局】，交给他一张牌，并视为对他使用一张【杀】",

  ["hongwen"] = "红温",
  [":hongwen"] = "锁定技，你的♠牌视为<font color='red'>♥</font>牌，你的♣牌视为<font color='red'>♦</font>牌。",
  ["$hongwen1"] = "唉，不该出水银的。",
  ["$hongwen2"] = "哎，兄弟我为什么不打四带两对啊，兄弟？",
  ["$hongwen3"] = "好难受啊！",
  ["$hongwen4"] = "操，可惜！",
  ["$hongwen5"] = "那他咋想的呀？",

  ["zouwei"] = "走位",
  [":zouwei"] = "锁定技，当你的装备区没有牌时，其他角色计算与你的距离时，始终+1；当你的装备区有牌时，你计算与其他角色的距离时，始终-1。",
  ["$zouwei1"] = "玩一下，不然我是不是一张牌没有出啊兄弟？",
  ["$zouwei2"] = "完了呀！",

  ["shengnu"] = "圣弩",
  [":shengnu"] = "锁定技，当【诸葛连弩】移至弃牌堆或其他角色的装备区时，你获得此【诸葛连弩】。",
  ["$shengnu1"] = "哎兄弟们我这个牌不能拆吧？",

  ["xizao"] = "洗澡",
  [":xizao"] = "限定技，当你处于濒死状态时，你可以将体力恢复至1，摸三张牌，然后翻面。",
  ["$xizao1"] = "哇袄！",
  ["$xizao2"] = "也不是稳赢吧，我觉得赢了！",

  ["~jianzihao"] = "好像又要倒下了……",
}


local houguoyu = General(extension, "houguoyu", "shu", 0, 999, General.Male)
houguoyu.hidden = true

Fk:loadTranslationTable {
     ["jianzihao"] = "简自豪",
     ["houguoyu"] = "侯国玉",
}

return extension