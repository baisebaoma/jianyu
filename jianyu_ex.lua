local extension = Package:new("jianyu_ex")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
  ["jianyu_ex"] = [[简浴-测试]],
  ["jy_ex"] = [[简浴测试]],
}

local liaoran = General(extension, "jy_ex__liaoran", "god", 3)
-- liaoran.total_hidden = true

-- local jy_fuzhu = fk.CreateTriggerSkill {
--   name = "jy_fuzhu",
--   anim_type = "support",
--   events = { fk.EventPhaseChanging },
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self)
--         and data.to == Player.Start and player:usedSkillTimes(self.name, Player.HistoryGame) < 2
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     -- TODO：UI变好看一点
--     local skill_name = room:askForCustomDialog(player, self.name,
--       "packages/jianyu/qml/fuzhu.qml")
--     local sk = Fk.skills[skill_name] -- 好像可以用 Util.Name2SkillMapper(skill_name)，但是原理和这一句是一样的
--     if sk then
--       room:doBroadcastNotify("ShowToast", "服主：获得了一个新技能 " .. Fk:translate(skill_name) .. "！")
--       room:handleAddLoseSkills(player, skill_name, nil, true, false)
--     else
--       room:doBroadcastNotify("ShowToast", "服主：因为输入错误，没有获得技能！")
--     end
--   end,
-- }

-- liaoran:addSkill(jy_fuzhu)

Fk:loadTranslationTable {
  ["jy_ex__liaoran"] = [[了然]],

  -- ["jy_fuzhu"] = "服主",
  -- [":jy_fuzhu"] = [[每局游戏限两次，你的回合开始时，你可以获得服务器上任意一个技能。<br><font size="1">你需要知道这个技能的name参数（如：paoxiao、jy_lingfu、mou__tieji）。若输入错误，你不会获得技能。</font>]],
}

return extension
