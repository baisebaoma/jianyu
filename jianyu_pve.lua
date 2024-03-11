---@diagnostic disable: undefined-field
local extension = Package:new("jianyu_pve")
extension.extensionName = "jianyu"

-- local U = require "packages/utility/utility"

Fk:loadTranslationTable {
    ["jianyu_pve"] = [[简浴-经典]],
}

-- 初版再生！！很强！！
local ex_zaisheng = fk.CreateTriggerSkill {
    name = "jy_ex_zaisheng",
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
            return target:getMark("@jy_ex_zaisheng") ~= 0 and data.to:getMark("jy_ex_zaisheng_triggered-round") == 0
        end
    end,
    on_cost = function(self, event, target, player, data)
        if event == fk.AfterCardsMove then
            return player.room:askForSkillInvoke(player, self.name, nil,
                "#jy_ex_zaisheng_prompt::" .. data.jy_zaisheng_moveFrom)
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
            room:setPlayerMark(jy_zaisheng_moveFrom, "@jy_ex_zaisheng", "")
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
            room:setPlayerMark(data.to, "jy_ex_zaisheng_triggered-round", 1)
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
            if p:getMark("@jy_ex_zaisheng") ~= 0 then
                room:setPlayerMark(p, "@jy_ex_zaisheng", 0)
            end
        end
    end,
}

local ex_zhushe = fk.CreateTriggerSkill {
    name = "jy_ex_zhushe",
    anim_type = 'drawcard',
    events = { fk.EventPhaseStart, fk.CardUsing, fk.Damage },
    mute = true,
    can_trigger = function(self, event, target, player, data)
        if player:hasSkill(self) and target == player then
            if event == fk.EventPhaseStart then
                return player.phase == Player.Start
            elseif event == fk.CardUsing then
                return player:getMark("@jy_ex_zhushe-turn") ~= 0
            else -- fk.Damage
                return player:getMark("@jy_ex_zhushe-turn") ~= 0 and not data.to.dead
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
            local cards = room:askForCard(player, 1, 999, true, self.name, true, nil, "#jy_ex_zhushe_prompt", nil, true)
            if #cards > 0 then
                room:throwCard(cards, self.name, player, player)
                if player:isAlive() then
                    player:drawCards(#cards, self.name)
                    room:setPlayerMark(player, "@jy_ex_zhushe-turn", "")
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
        else                -- fk.Damaged
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
local ex_zhushe_mod = fk.CreateTargetModSkill {
    name = "#jy_ex_zhushe_prompt_mod",
    bypass_times = function(self, player, skill, scope, card, to)
        return player:hasSkill(self) and player:getMark("@jy_ex_zhushe-turn") ~= 0
    end,
    bypass_distances = function(self, player, skill, card, to)
        return player:hasSkill(self) and player:getMark("@jy_ex_zhushe-turn") ~= 0
    end,
}
ex_zhushe:addRelatedSkill(ex_zhushe_mod)

local ex__xuyu = General(extension, "jy__ex__xuyu", "qun", 3, 3, General.Female)
ex__xuyu.hidden = true
ex__xuyu:addSkill(ex_zaisheng)
ex__xuyu:addSkill(ex_zhushe)

Fk:loadTranslationTable {
    ["jy__ex__xuyu"] = "经典絮雨",
    ["#jy__ex__xuyu"] = [[<font color="red">人机皇帝<br>这是未削弱版本，<br>因强度过高，这个武<br>将不会出现在选将框！</font>]],
    ["designer:jy__ex__xuyu"] = "emo公主",
    ["cv:jy__ex__xuyu"] = "刘十四",
    ["illustrator:jy__ex__xuyu"] = "未知",
    ["~jy__ex__xuyu"] = [[我熟悉这死亡的气息……]],

    ["jy_ex_zaisheng"] = "再生",
    ["@jy_ex_zaisheng"] = "再生",
    ["#jy_ex_zaisheng_prompt"] = [[是否发动〖再生〗令 %dest 回复一点体力且你获得增益效果？]],
    [":jy_ex_zaisheng"] = [[当一名角色不因使用而失去红色牌时，你可以令其回复一点体力。若如此做，直到你的下回合开始：每回合限一次，当该角色受到伤害后，你获得对其造成伤害的牌，并随机获得伤害来源手牌中一张伤害牌。]],
    ["$jy_ex_zaisheng1"] = [[不要害怕。]],
    ["$jy_ex_zaisheng2"] = [[让我来消除痛苦。]],

    ["jy_ex_zhushe"] = "注射",
    ["@jy_ex_zhushe-turn"] = "注射",
    ["#jy_ex_zhushe_prompt"] = "你可以重铸任意张牌，然后本回合获得〖注射〗的效果",
    [":jy_ex_zhushe"] = [[出牌阶段开始时，你可以重铸任意张牌。若如此做，本回合：你使用牌无距离和次数限制、不可被响应；你造成伤害后，伤害目标回复X点体力并摸两张牌，X为伤害值。]],
    ["$jy_ex_zhushe1"] = [[准备好注射了。]],
    ["$jy_ex_zhushe2"] = [[我的治疗是不会痛的。]],
}


-- 这个是按照投稿时的描述做的经典版本修行，我认为它设计得有新意，所以保留了（但由于强度问题，无法进入PVP池子）。投稿描述原文如下：锁定技，你使用牌无次数限制；当你造成或受到伤害后，你需改变自身转换技的阴阳状态；你改变转换技阴阳状态时你摸2张牌。
local ex_xiuxing = fk.CreateTriggerSkill {
    name = "jy_ex_xiuxing",
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
                    player.room:delay(1000)                       -- 停告诉玩家我们确实由A变B再变A动了一下（
                    player.room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. s.name,
                        player:getSwitchSkillState(s.name, true)) -- 经测试这个是没问题的
                    player:addSkillUseHistory(s.name)             -- 加上这个就可以更新武将牌上的黑白
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

local ex_zitai = fk.CreateTriggerSkill {
    name = "jy_ex_zitai",
    anim_type = "switch",
    switch_skill_name = "jy_zitai",
    frequency = Skill.Compulsory,
    events = { fk.DamageInflicted },
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(self) and (data.to == player or data.from == player)
    end,
    on_use = function(self, event, target, player, data)
        if player:getSwitchSkillState(self.name) == fk.SwitchYang then
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

local ex__guanzhe = General(extension, "jy__ex__guanzhe", "jin", 3, 3, General.Female)
ex__guanzhe.hidden = true -- 不可以出现在选将框！！因为太强了！！
ex__guanzhe:addSkill(ex_xiuxing)
ex__guanzhe:addSkill(ex_zitai)
ex__guanzhe:addSkill("jy_mumang")
ex__guanzhe:addSkill("jy_yujian")

Fk:loadTranslationTable {
    ["jy__ex__guanzhe"] = [[经典观者]],
    ["#jy__ex__guanzhe"] = [[<font color="red">人机皇帝<br>这是未削弱版本，<br>因强度过高，这个武<br>将不会出现在选将框！</font>]],
    ["designer:jy__ex__guanzhe"] = [[Kasa]],
    ["cv:jy__ex__guanzhe"] = [[无]],
    ["illustrator:jy__ex__guanzhe"] = [[未知]],

    ["jy_ex_xiuxing"] = [[修行]],
    [":jy_ex_xiuxing"] = [[锁定技，你使用牌无次数限制；当你造成或受到伤害后，你改变自身所有转换技的阴阳状态；你每以此法改变一个转换技的阴阳状态或发动一个转换技时，你摸两张牌。]],

    ["jy_ex_zitai"] = [[姿态]],
    [":jy_ex_zitai"] = [[转换技，锁定技，当你造成或受到伤害时，阳：你判定，若为红色，防止之；阴：该伤害+1。]],
}

return extension
