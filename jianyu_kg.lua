local extension = Package:new("jianyu_kg")
extension.extensionName = "jianyu"

local Q = require "packages/jianyu/question" -- 考公大学生用的题库

-- TODO: 这两个武将太耦合了，建议重写。

Fk:loadTranslationTable {
  ["jianyu_kg"] = [[简浴-考公]],
}

local jy_zuoti = fk.CreateActiveSkill {
  name = "jy_zuoti",
  anim_type = "control",
  mute = true,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke(self.name, math.random(4))
    room:notifySkillInvoked(player, self.name, "drawcard")
    -- 随机从题库拿一道题
    local questionFull = Q.getRandomQuestion()

    local question = questionFull[1]
    local answers = questionFull[2]
    local correct_answer = questionFull[3]

    ------------------------------------------
    -- 插入换行符，每若干个字符一次
    local function insert_br(str, ct)
      local result = ""
      local count = 0
      local in_br = false -- 用于检测是否在原本的 <br> 之内

      -- TODO：如果这是最后一个字符，那么不要添加br了
      for char in str:gmatch("[%z\1-\127\194-\244_][\128-\191]*") do
        if char == "<" then
          in_br = true
        elseif char == ">" and in_br then
          in_br = false
          count = 0
        end

        if not in_br then
          result = result .. char
          count = count + 1

          -- 每ct个字符插入一个<br>
          if count == ct then
            result = result .. "<br>"
            count = 0
          end
        else
          result = result .. char
        end
      end

      return result
    end

    local question_wrap = insert_br(question, 40)
    local answers_wrap = {}
    for _, a in ipairs(answers) do
      table.insert(answers_wrap, insert_br(a, 30))
    end
    -----------------------------------------------

    -- 建立输出到战报里的所有选项
    local answers_string = ""
    for i, a in ipairs(answers) do
      if i ~= #answers then
        answers_string = answers_string .. a .. "<br>"
      else
        answers_string = answers_string .. a
      end
    end

    -- 做题
    -- 不仅要让自己看到题目，还要让全场所有人看到题目。
    room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_ob"))
    room:sendLog {
      type = "%from 的题目：<br>%arg<br>%arg2",
      from = player.id,
      arg = question,
      arg2 = answers_string,
    }

    local answers_short = {}
    for _, a in ipairs(answers) do
      table.insert(answers_short, a[1])
    end

    local choice = room:askForChoice(player, answers_wrap, "#jy_zuoti_q", question_wrap) -- 把skillName改成question可能可以
    if choice[1] == correct_answer then                                                  -- 仅判断choice[1]，因为答案只保留正确选项的选项名字（ABCD）
      player:broadcastSkillInvoke(self.name, math.random(5, 7))

      room:addPlayerMark(player, "@jy_zuoti_correct_count")
      room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_correct"))
      room:sendLog {
        type = "#jy_zuoti_correct_log",
        from = player.id,
        arg = correct_answer[1],
      }

      -- cheat，从谋徐盛抄来的
      local cardType = { 'basic', 'trick', 'equip' }
      local cardTypeName = room:askForChoice(player, cardType, self.name, "#jy_zuoti_choose_card")
      local card_types = { Card.TypeBasic, Card.TypeTrick, Card.TypeEquip }
      cardType = card_types[table.indexOf(cardType, cardTypeName)]

      local allCardIds = Fk:getAllCardIds()
      local allCardMapper = {}
      local allCardNames = {}
      for _, id in ipairs(allCardIds) do
        local card = Fk:getCardById(id)
        if card.type == cardType then
          if allCardMapper[card.name] == nil and not Fk:cloneCard(card.name).is_derived then -- 我改了这里，禁止抽衍生牌
            table.insert(allCardNames, card.name)
          end

          allCardMapper[card.name] = allCardMapper[card.name] or {}
          table.insert(allCardMapper[card.name], id)
        end
      end

      if #allCardNames == 0 then
        return
      end

      local cardName = room:askForChoice(player, allCardNames, self.name)
      local toGain -- = room:printCard(cardName, Card.Heart, 1)
      if #allCardMapper[cardName] > 0 then
        toGain = allCardMapper[cardName][math.random(1, #allCardMapper[cardName])]
      end
      room:obtainCard(player, toGain, true, fk.ReasonPrey)
    else
      player:broadcastSkillInvoke(self.name, math.random(8, 10))
      room:addPlayerMark(player, "@jy_zuoti_incorrect_count")
      room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_incorrect"))
      room:sendLog {
        type = "#jy_zuoti_incorrect_log",
        from = player.id,
        arg = choice[1],
        arg2 = correct_answer,
      }
    end
  end,
}

-- touhou_standard extremely_wicked
local jy_jieju = fk.CreateActiveSkill {
  name = "jy_jieju",
  frequency = Skill.Quest,
  anim_type = "positive",
  can_use = function(self, player)
    return player:usedSkillTimes("jy_zuoti", Player.HistoryPhase) ~= 0 and
        -- player:usedSkillTimes(self.name, Player.HistoryPhase) <= 1 and
        not player:getQuestSkillState("jy_jieju")
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
    local hp_to_be_lost = 1
    room:loseHp(from, hp_to_be_lost, self.name)
    -- room:throwCard(effect.cards, self.name, from, from)
    from:setSkillUseHistory("jy_zuoti", 0, Player.HistoryPhase)
  end,
}
local jy_jieju_success = fk.CreateTriggerSkill {
  name = "#jy_jieju_success",
  anim_type = "positive",
  events = {
    fk.EventPhaseStart,
  },
  can_trigger = function(self, event, target, player)
    if player:getQuestSkillState("jy_jieju") then
      return false
    end
    return player:hasSkill("jy_jieju") and player.phase == Player.Finish and
        player:getMark("@jy_zuoti_correct_count") >= player:getMark("@jy_zuoti_incorrect_count") + 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    room:updateQuestSkillState(player, "jy_jieju")
    player:drawCards(2, "jy_jieju")
    room:recover({
      who = player,
      num = 2,
      recoverBy = player,
      skillName = self.name,
    })
    room:handleAddLoseSkills(player, "jizhi", nil, true, false)
    room:handleAddLoseSkills(player, "kanpo", nil, true, false)
    room:handleAddLoseSkills(player, "xiangle", nil, true, false)
  end
}
local jy_jieju_fail = fk.CreateTriggerSkill {
  name = "#jy_jieju_fail",
  anim_type = "negative",
  events = {
    fk.EventPhaseStart,
  },
  can_trigger = function(self, event, target, player)
    if player:getQuestSkillState("jy_jieju") then
      return false
    end
    return player:hasSkill("jy_jieju") and player.phase == Player.Finish and
        player:getMark("@jy_zuoti_incorrect_count") >= player:getMark("@jy_zuoti_correct_count") + 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    room:updateQuestSkillState(player, "jy_jieju", true)
    player:turnOver()
    room:handleAddLoseSkills(player, "jy_yuyu", nil, true, false)
    room:handleAddLoseSkills(player, "jy_hongwen", nil, true, false)
  end
}
jy_jieju:addRelatedSkill(jy_jieju_success)
jy_jieju:addRelatedSkill(jy_jieju_fail)

local jy_guina = fk.CreateActiveSkill {
  mute = true,
  name = "jy_guina",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 3
  end,
  card_filter = function(self, card)
    return false
  end,
  card_num = 0,
  target_num = 1,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local me = room:getPlayerById(effect.from)
    me:broadcastSkillInvoke(self.name, math.random(4))
    room:notifySkillInvoked(me, self.name, "drawcard")
    local player = room:getPlayerById(effect.tos[1])
    -- 随机从题库拿一道题
    local questionFull = Q.getRandomQuestion()

    local question = questionFull[1]
    local answers = questionFull[2]
    local correct_answer = questionFull[3]

    ------------------------------------------
    -- 插入换行符，每若干个字符一次
    local function insert_br(str, ct)
      local result = ""
      local count = 0
      local in_br = false -- 用于检测是否在原本的 <br> 之内

      -- TODO：如果这是最后一个字符，那么不要添加br了
      for char in str:gmatch("[%z\1-\127\194-\244_][\128-\191]*") do
        if char == "<" then
          in_br = true
        elseif char == ">" and in_br then
          in_br = false
          count = 0
        end

        if not in_br then
          result = result .. char
          count = count + 1

          -- 每ct个字符插入一个<br>
          if count == ct then
            result = result .. "<br>"
            count = 0
          end
        else
          result = result .. char
        end
      end

      return result
    end

    local question_wrap = insert_br(question, 40)
    local answers_wrap = {}
    for _, a in ipairs(answers) do
      table.insert(answers_wrap, insert_br(a, 30))
    end
    -----------------------------------------------

    -- 建立输出到战报里的所有选项
    local answers_string = ""
    for i, a in ipairs(answers) do
      if i ~= #answers then
        answers_string = answers_string .. a .. "<br>"
      else
        answers_string = answers_string .. a
      end
    end

    -- 做题
    -- 不仅要让自己看到题目，还要让全场所有人看到题目。
    room:doBroadcastNotify("ShowToast", Fk:translate("#jy_zuoti_ob"))
    room:sendLog {
      type = "%from 的题目：<br>%arg<br>%arg2",
      from = player.id,
      arg = question,
      arg2 = answers_string,
    }

    local answers_short = {}
    for _, a in ipairs(answers) do
      table.insert(answers_short, a[1])
    end

    -- local your_question_wrap = "归纳：回答行测真题，若正确你可以自选一张牌，<br>若错误本阶段其所有牌额外指定你为目标：<br><br>" .. question

    local choice = room:askForChoice(player, answers_wrap, "#jy_zuoti_q", question_wrap)
    if choice[1] == correct_answer then                     -- 仅判断choice[1]，因为答案只保留正确选项的选项名字（ABCD）
      me:broadcastSkillInvoke(self.name, math.random(5, 6)) -- 播放选择正确的语音

      -- room:addPlayerMark(player, "@jy_zuoti_correct_count")
      room:doBroadcastNotify("ShowToast", Fk:translate("#jy_guina_correct"))
      room:sendLog {
        type = "#jy_zuoti_correct_log",
        from = player.id,
        arg = correct_answer[1],
      }

      -- cheat，从谋徐盛抄来的
      local cardType = { 'basic', 'trick', 'equip' }
      local cardTypeName = room:askForChoice(player, cardType, self.name, "#jy_guina_choose_card")
      local card_types = { Card.TypeBasic, Card.TypeTrick, Card.TypeEquip }
      cardType = card_types[table.indexOf(cardType, cardTypeName)]

      local allCardIds = Fk:getAllCardIds()
      local allCardMapper = {}
      local allCardNames = {}
      for _, id in ipairs(allCardIds) do
        local card = Fk:getCardById(id)
        if card.type == cardType then
          if allCardMapper[card.name] == nil and not Fk:cloneCard(card.name).is_derived then -- 我改了这里，禁止抽衍生牌
            table.insert(allCardNames, card.name)
          end

          allCardMapper[card.name] = allCardMapper[card.name] or {}
          table.insert(allCardMapper[card.name], id)
        end
      end

      if #allCardNames == 0 then
        return
      end

      local cardName = room:askForChoice(player, allCardNames, self.name)
      local toGain -- = room:printCard(cardName, Card.Heart, 1)
      if #allCardMapper[cardName] > 0 then
        toGain = allCardMapper[cardName][math.random(1, #allCardMapper[cardName])]
      end
      room:obtainCard(player, toGain, true, fk.ReasonPrey)
    else
      me:broadcastSkillInvoke(self.name, math.random(7, 8)) -- 播放选择错误的语音

      -- room:addPlayerMark(player, "@jy_zuoti_incorrect_count")
      room:doBroadcastNotify("ShowToast", Fk:translate("#jy_guina_incorrect"))
      room:sendLog {
        type = "#jy_zuoti_incorrect_log",
        from = player.id,
        arg = choice[1],
        arg2 = correct_answer,
      }
      room:setPlayerMark(player, "@jy_guina-phase", "") -- 给这个人上标记，标记为被点名的
    end
  end,
}
local jy_guina_refresh = fk.CreateTriggerSkill {
  name = "#jy_guina_refresh",
  refresh_events = { fk.TargetConfirming, fk.Damaged },
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.TargetConfirming then
      -- if data.card then 这个事件只针对牌，所以不需要判断是否有牌
      return data.from == player.id and
          (data.card:isCommonTrick() or data.card.type == Card.TypeBasic)
    else
      return data.to:getMark("@jy_guina-phase") ~= 0 -- data.from == player
      -- 因为这两个事件的data.to和from对应的数据结构不一样
    end
  end,
  on_refresh = function(self, event, target, player, data)
    -- TODO：借刀等带副目标的不会生效
    local room = player.room
    if event == fk.TargetConfirming then
      local guina_players = {} -- 用来画指示线的
      local targets = AimGroup:getAllTargets(data.tos)
      for _, p in ipairs(room:getAlivePlayers()) do
        if p:getMark("@jy_guina-phase") ~= 0 and not table.contains(targets, p.id) then
          -- 判断目标是否不能成为这张牌的目标
          if not Self:isProhibited(p, data.card) then
            AimGroup:addTargets(player.room, data, p.id)
            table.insert(guina_players, p.id)
          end
        end
      end
      if #guina_players ~= 0 then
        room:notifySkillInvoked(player, "jy_guina", "drawcard")
        room:doIndicate(data.from, guina_players)
      end
    else
      room:notifySkillInvoked(player, "jy_guina", "drawcard")
      player:drawCards(2, "jy_guina")
    end
  end,
}
jy_guina:addRelatedSkill(jy_guina_refresh)


local jy__kgdxs = General(extension, "jy__kgdxs", "qun", 6, 6, General.Female)
jy__kgdxs:addSkill(jy_zuoti)
jy__kgdxs:addSkill(jy_jieju)
jy__kgdxs:addRelatedSkill("jizhi")
jy__kgdxs:addRelatedSkill("kanpo")
jy__kgdxs:addRelatedSkill("xiangle")
jy__kgdxs:addRelatedSkill("jy_yuyu")
jy__kgdxs:addRelatedSkill("jy_hongwen")


local kgds = General(extension, "jy__kgds", "god", 4)
kgds:addSkill(jy_guina)

local total_papers, total_questions = Q.questionCount()

Fk:loadTranslationTable {
  ["jy__kgdxs"] = "考公大学生",
  ["#jy__kgdxs"] = "公喜发财",
  ["designer:jy__kgdxs"] = "考公专家",
  ["cv:jy__kgdxs"] = "侯小菲",
  ["illustrator:jy__kgdxs"] = "网络图片",
  ["~jy__kgdxs"] = [[老师，对不起……]],

  ["jy_zuoti"] = "做题",
  [":jy_zuoti"] = [[出牌阶段限一次，你可以回答一道行测真题。若正确，你获得一张你指定的非衍生牌名的牌。<br><font color="grey">收录2018-2024《行测》]] .. total_papers .. [[套共]] .. total_questions .. [[题，经人工筛选，不含图形推理、资料分析。</font>]],
  ["#jy_zuoti_q"] = "行测真题",
  ["#jy_zuoti_see_log"] = [[做题：请在战报中查看完整题干]],
  ["#jy_zuoti_ob"] = [[正在做题！其他角色可以在战报中查看这道题目的完整题干和选项。]],
  ["#jy_zuoti_correct"] = [[答对了！你可以自选一张牌！<br>你可以在战报中查看正确答案。]],
  ["#jy_zuoti_incorrect"] = [[答错了，不过没有什么惩罚，你学到了新知识！<br>你可以在战报中查看正确答案。]],
  ["#jy_zuoti_choose_card"] = [[自选一张牌（尽量不要是自己区域内同牌名的牌）]],
  ["@jy_zuoti_correct_count"] = "答对",
  ["#jy_zuoti_correct_log"] = "%from 回答正确，正确答案：%arg。",
  ["@jy_zuoti_incorrect_count"] = "答错",
  ["#jy_zuoti_incorrect_log"] = "%from 选择了：%arg，正确答案：%arg2。",
  ["$jy_zuoti1"] = [[伟大的智慧之神，我最近每晚都在熬夜复习，考试就请让我通过吧！拜托了拜托了……]],
  ["$jy_zuoti2"] = [[唉，为什么报告和论文永远写不完？为什么？]],
  ["$jy_zuoti3"] = [[嗯哼，我也不想熬夜补课题进度。你想陪我一起吗？]],
  ["$jy_zuoti4"] = [[别害怕。]],
  ["$jy_zuoti5"] = [[好厉害，好羡慕……你还真是什么都会呀！]],
  ["$jy_zuoti6"] = [[哇！突然感觉不困了！]],
  ["$jy_zuoti7"] = [[还是你眼睛尖……]],
  ["$jy_zuoti8"] = [[现在逃还来得及吗？]],
  ["$jy_zuoti9"] = [[完了完了完了……]],
  ["$jy_zuoti10"] = [[啊……我……我要不行了……]],

  ["jy_jieju"] = "熬夜",
  [":jy_jieju"] = [[使命技，出牌阶段，你可以失去一点体力使〖做题〗视为未发动过。<br>
  成功：回合结束时，若你答对比答错至少多2次，你摸2张牌、回复2点体力，然后获得〖集智〗、〖看破〗、〖享乐〗；<br>
  失败：回合结束时，若你答错比答对至少多2次，你翻面，然后获得〖玉玉〗、〖红温〗。]],
  ["#jy_jieju_success"] = "结局：成功",
  ["#jy_jieju_fail"] = "结局：失败",

  ["jy__kgds"] = "考公专家",
  ["#jy__kgds"] = "正厅级",
  ["designer:jy__kgds"] = "考公专家",
  ["cv:jy__kgds"] = "桑毓泽",
  ["illustrator:jy__kgds"] = "网络图片",
  ["~jy__kgds"] = "“庸人”么……呵……",

  ["jy_guina"] = "归纳",
  [":jy_guina"] = [[出牌阶段限三次，你可以令一名角色回答一道行测真题。若正确，其获得一张其指定的非衍生牌名的牌，否则其获得“归纳”直到本阶段结束。你使用基本牌与普通锦囊牌时，额外指定有“归纳”的角色为目标；有“归纳”的角色受到伤害时，你摸两张牌。<br><font color="grey">收录2018-2024《行测》]] .. total_papers .. [[套共]] .. total_questions .. [[题，经人工筛选，不含图形推理、资料分析。</font>]],
  ["@jy_guina-phase"] = "归纳",
  ["#jy_guina_correct"] = [[答对了！你可以自选一张牌获得！<br>你可以在战报中查看正确答案。]],
  ["#jy_guina_incorrect"] = [[答错了，本阶段的所有牌会额外指定你为目标！<br>你可以在战报中查看正确答案。]],
  ["#jy_guina_choose_card"] = [[自选一张牌（尽量不要是自己区域内同牌名的牌）]],
  ["$jy_guina1"] = [[让我来考考你。]],
  ["$jy_guina2"] = [[由我提问了。]],
  ["$jy_guina3"] = [[期待各位的应答。]],
  ["$jy_guina4"] = [[动动脑子！]],
  ["$jy_guina5"] = [[不错，加五分。]],
  ["$jy_guina6"] = [[做得好，加十分。]],
  ["$jy_guina7"] = [[零分，下一个！]],
  ["$jy_guina8"] = [[负分！]],
}

return extension
