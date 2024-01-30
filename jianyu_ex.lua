local extension = Package:new("jianyu_ex")
extension.extensionName = "jianyu"

Fk:loadTranslationTable {
  ["jianyu_ex"] = [[简浴-测试]],
  ["jy_ex"] = [[简浴测试]],
}

local liaoran = General(extension, "jy_ex__liaoran", "god", 3)

local jy_fuzhu = fk.CreateTriggerSkill {
  name = "jy_fuzhu",
  anim_type = "support",
  events = { fk.EventPhaseChanging },
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
        and data.to == Player.Start and player:usedSkillTimes(self.name, Player.HistoryGame) < 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 显示对话框，要求回复一个技能名字。最好能做查询，查出来是否真的是需要的技能
    -- TODO：UI变好看一点
    local skill_name = room:askForCustomDialog(player, self.name,
      "packages/jianyu/qml/fuzhu.qml")
    local sk = Fk.skills[skill_name] -- 好像可以用 Util.Name2SkillMapper(skill_name)，但是原理和这一句是一样的
    if sk then
      -- player.general.trueName 应该是没问题的
      room:doBroadcastNotify("ShowToast", player.general.trueName .. " 发动 服主 获得了一个新技能 " .. sk.trueName .. "！")
      room:handleAddLoseSkills(player, skill_name, nil, true, false)
    else
      room:doBroadcastNotify("ShowToast", player.general.trueName .. " 发动了 服主 ，但是因为输入错误，没有获得技能！")
    end
  end,
}

liaoran:addSkill(jy_fuzhu)

Fk:loadTranslationTable {
  ["jy_ex__liaoran"] = [[了然]],

  ["jy_fuzhu"] = "服主",
  [":jy_fuzhu"] = [[每局游戏限两次，你的回合开始时，你可以获得服务器上任意一个技能。<br><font size="1">你需要知道这个技能的name参数（如：paoxiao、jy_lingfu、mou__tieji）。若输入错误，你不会获得技能。</font>]],

  ["jy_diaoxian"] = "掉线",
  [":jy_diaoxian"] = [[锁定技，所有角色的准备阶段，其判定，若点数为：J，跳过判定阶段；Q，跳过摸牌阶段；K，跳过出牌阶段；A，跳过弃牌阶段。其获得该判定牌。]],
}

return extension
