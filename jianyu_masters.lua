local extension = Package:new("jianyu_masters")
extension.extensionName = "jianyu"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["jianyu_masters"] = [[简浴-联动]],
}

-- 因为下面几个都属于高手系列差不多，所以都放到一起写了，降低耦合度

-- 下面的这一堆函数是用于判断“这个玩家是否是满足某一属性的玩家”，有可能是它的名字符合，也有可能是它的势力符合，或者还有别的判断标准。总之不是特定的针对某个势力的，不要误以为是。

-- 以武将名为判定是否为原神角色的标准。按照bwiki排序，截至5.2版本
-- 已不再收集其他包写的非角色的怪物。
-- 使用哈希表，时间复杂度低
local genshin_names = {
    ["凯亚"] = true,
    ["重云"] = true,
    ["诺艾尔"] = true,
    ["凝光"] = true,
    ["行秋"] = true,
    ["芭芭拉"] = true,
    ["班尼特"] = true,
    ["安柏"] = true,
    ["香菱"] = true,
    ["丽莎"] = true,
    ["菲谢尔"] = true,
    ["雷泽"] = true,
    ["北斗"] = true,
    ["砂糖"] = true,
    ["迪奥娜"] = true,
    ["辛焱"] = true,
    ["罗莎莉亚"] = true,
    ["烟绯"] = true,
    ["早柚"] = true,
    ["九条裟罗"] = true,
    ["托马"] = true,
    ["五郎"] = true,
    ["云堇"] = true,
    ["久岐忍"] = true,
    ["鹿野院平藏"] = true,
    ["柯莱"] = true,
    ["多莉"] = true,
    ["坎蒂丝"] = true,
    ["莱依拉"] = true,
    ["珐露珊"] = true,
    ["瑶瑶"] = true,
    ["米卡"] = true,
    ["卡维"] = true,
    ["绮良良"] = true,
    ["琳妮特"] = true,
    ["菲米尼"] = true,
    ["夏洛蒂"] = true,
    ["夏沃蕾"] = true,
    ["嘉明"] = true,
    ["七七"] = true,
    ["旅行者"] = true,
    ["原神"] = true,
    ["派蒙"] = true,
    ["莫娜"] = true,
    ["迪卢克"] = true,
    ["刻晴"] = true,
    ["琴"] = true,
    ["温迪"] = true,
    ["可莉"] = true,
    ["达达利亚"] = true,
    ["钟离"] = true,
    ["阿贝多"] = true,
    ["甘雨"] = true,
    ["魈"] = true,
    ["胡桃"] = true,
    ["优菈"] = true,
    ["枫原万叶"] = true,
    ["神里绫华"] = true,
    ["宵宫"] = true,
    ["雷电将军"] = true,
    ["埃洛伊"] = true,
    ["珊瑚宫心海"] = true,
    ["荒泷一斗"] = true,
    ["申鹤"] = true,
    ["八重神子"] = true,
    ["神里绫人"] = true,
    ["夜兰"] = true,
    ["提纳里"] = true,
    ["赛诺"] = true,
    ["妮露"] = true,
    ["纳西妲"] = true,
    ["流浪者"] = true,
    ["艾尔海森"] = true,
    ["迪希雅"] = true,
    ["白术"] = true,
    ["林尼"] = true,
    ["那维莱特"] = true,
    ["莱欧斯利"] = true,
    ["芙宁娜"] = true,
    ["娜维娅"] = true,
    ["闲云"] = true,
    ["千织"] = true,
    ["阿蕾奇诺"] = true,
    ["赛索斯"] = true,
    ["克洛琳德"] = true,
    ["希格雯"] = true,
    ["艾梅莉埃"] = true,
    ["玛拉妮"] = true,
    ["基尼奇"] = true,
    ["希诺宁"] = true,
    ["恰斯卡"] = true,
    ["欧洛伦"] = true,
    -- 以下是已知的怪物
    ["兽境猎犬"] = true,
    ["深渊咏者"] = true,
    ["海乱鬼"] = true,
    ["遗迹守卫"] = true,
    ["遗迹猎者"] = true,
  }
  
  local function is_genshin(player)
    return genshin_names[Fk:translate(player.general)] or
        genshin_names[Fk:translate(player.deputyGeneral)]
  end
  
  local function is_majsoul(player)
    return player.kingdom == "que"
  end
  
  local function is_moe(player)
    return player.kingdom == "moe"
  end
  
  -- 这里的顺序使用的是首字母，可以参考yz.lol.qq.com，目前更新至安蓓萨
  local lol_names = {
    ["亚托克斯"] = true,
    ["阿狸"] = true,
    ["阿卡丽"] = true,
    ["阿克尚"] = true,
    ["阿利斯塔"] = true,
    ["阿木木"] = true,
    ["安蓓萨"] = true,
    ["艾尼维亚"] = true,
    ["安妮"] = true,
    ["厄斐琉斯"] = true,
    ["艾希"] = true,
    ["奥瑞利安·索尔"] = true,
    ["奥瑞利安索尔"] = true,
    ["阿萝拉"] = true,
    ["阿兹尔"] = true,
    ["巴德"] = true,
    ["卑尔维斯"] = true,
    ["布里茨"] = true,
    ["布兰德"] = true,
    ["布隆"] = true,
    ["贝蕾亚"] = true,
    ["凯特琳"] = true,
    ["卡蜜尔"] = true,
    ["卡西奥佩娅"] = true,
    ["科加斯"] = true,
    ["库奇"] = true,
    ["德莱厄斯"] = true,
    ["黛安娜"] = true,
    ["德莱文"] = true,
    ["蒙多医生"] = true,
    ["蒙多"] = true,
    ["艾克"] = true,
    ["伊莉丝"] = true,
    ["伊芙琳"] = true,
    ["伊泽瑞尔"] = true,
    ["费德提克"] = true,
    ["菲奥娜"] = true,
    ["菲兹"] = true,
    ["加里奥"] = true,
    ["普朗克"] = true,
    ["盖伦"] = true,
    ["纳尔"] = true,
    ["古拉加斯"] = true,
    ["格雷福斯"] = true,
    ["格温"] = true,
    ["赫卡里姆"] = true,
    ["黑默丁格"] = true,
    ["彗"] = true,
    ["俄洛伊"] = true,
    ["艾瑞莉娅"] = true,
    ["艾翁"] = true,
    ["迦娜"] = true,
    ["嘉文四世"] = true,
    ["贾克斯"] = true,
    ["杰斯"] = true,
    ["烬"] = true,
    ["金克丝"] = true,
    ["卡莎"] = true,
    ["卡莉丝塔"] = true,
    ["卡尔玛"] = true,
    ["卡尔萨斯"] = true,
    ["卡萨丁"] = true,
    ["卡特琳娜"] = true,
    ["凯尔"] = true,
    ["凯隐"] = true,
    ["凯南"] = true,
    ["卡兹克"] = true,
    ["千珏"] = true,
    ["克烈"] = true,
    ["克格莫"] = true,
    ["奎桑提"] = true,
    ["乐芙兰"] = true,
    ["李青"] = true,
    ["蕾欧娜"] = true,
    ["莉莉娅"] = true,
    ["丽桑卓"] = true,
    ["卢锡安"] = true,
    ["璐璐"] = true,
    ["拉克丝"] = true,
    ["墨菲特"] = true,
    ["玛尔扎哈"] = true,
    ["茂凯"] = true,
    ["易"] = true,
    ["易大师"] = true,
    ["米利欧"] = true,
    ["厄运小姐"] = true,
    ["好运小姐"] = true,
    ["孙悟空"] = true,
    ["悟空"] = true,
    ["莫德凯撒"] = true,
    ["莫甘娜"] = true,
    ["纳亚菲利"] = true,
    ["娜美"] = true,
    ["内瑟斯"] = true,
    ["诺提勒斯"] = true,
    ["妮蔻"] = true,
    ["奈德丽"] = true,
    ["尼菈"] = true,
    ["魔腾"] = true,
    ["努努和威朗普"] = true,
    ["奥拉夫"] = true,
    ["奥莉安娜"] = true,
    ["奥恩"] = true,
    ["潘森"] = true,
    ["波比"] = true,
    ["派克"] = true,
    ["奇亚娜"] = true,
    ["奎因"] = true,
    ["洛"] = true,
    ["拉莫斯"] = true,
    ["雷克塞"] = true,
    ["芮尔"] = true,
    ["烈娜塔·戈拉斯克"] = true,
    ["烈娜塔"] = true,
    ["雷克顿"] = true,
    ["雷恩加尔"] = true,
    ["锐雯"] = true,
    ["兰博"] = true,
    ["瑞兹"] = true,
    ["莎弥拉"] = true,
    ["瑟庄妮"] = true,
    ["赛娜"] = true,
    ["萨勒芬妮"] = true,
    ["瑟提"] = true,
    ["萨科"] = true,
    ["慎"] = true,
    ["希瓦娜"] = true,
    ["辛吉德"] = true,
    ["赛恩"] = true,
    ["希维尔"] = true,
    ["斯卡纳"] = true,
    ["斯莫德"] = true,
    ["娑娜"] = true,
    ["索拉卡"] = true,
    ["斯维因"] = true,
    ["塞拉斯"] = true,
    ["辛德拉"] = true,
    ["塔姆"] = true,
    ["塔莉垭"] = true,
    ["泰隆"] = true,
    ["塔里克"] = true,
    ["提莫"] = true,
    ["锤石"] = true,
    ["崔丝塔娜"] = true,
    ["特朗德尔"] = true,
    ["泰达米尔"] = true,
    ["崔斯特"] = true,
    ["图奇"] = true,
    ["乌迪尔"] = true,
    ["厄加特"] = true,
    ["韦鲁斯"] = true,
    ["薇恩"] = true,
    ["维迦"] = true,
    ["维克兹"] = true,
    ["薇古丝"] = true,
    ["蔚"] = true,
    ["佛耶戈"] = true,
    ["维克托"] = true,
    ["弗拉基米尔"] = true,
    ["沃利贝尔"] = true,
    ["沃里克"] = true,
    ["霞"] = true,
    ["泽拉斯"] = true,
    ["赵信"] = true,
    ["亚索"] = true,
    ["永恩"] = true,
    ["约里克"] = true,
    ["悠米"] = true,
    ["扎克"] = true,
    ["劫"] = true,
    ["泽丽"] = true,
    ["吉格斯"] = true,
    ["基兰"] = true,
    ["佐伊"] = true,
    ["婕拉"] = true,
  }
  
  local function is_lol(player)
    return lol_names[Fk:translate(player.general)] or
        lol_names[Fk:translate(player.deputyGeneral)]
  end
  
  -- 下面这一堆函数是用来快速制作高手系列的。
  
  local master_events = { fk.EventPhaseProceeding, fk.TargetConfirming, fk.Damage }
  
  local function master_can_trigger(is_fun, property)
    return function(self, event, target, player, data)
      if not player:hasSkill(self) then return false end
      if event == fk.EventPhaseProceeding then
        if not (target == player and (player.phase == Player.Start or player.phase == Player.Finish) and player:getMark("jy_masters-phase") == 0) then return false end
        local room = player.room
        local is_exist = false
        for _, p in ipairs(room:getOtherPlayers(player)) do
          if is_fun(p) then
            is_exist = true
            break
          end
        end
        if is_exist then return false end
        -- 确认自己有没有哪个武将牌有这个技能。
        -- TODO：感觉这个可以写一个函数！别的技能也用得上！
        local generals
        if player.deputyGeneral == "" then
          generals = { player.general }
        else
          generals = { player.general, player.deputyGeneral }
        end
        for _, g in ipairs(generals) do
          if table.contains(Fk.generals[g].skills, self) then
            self.general = g
            return true
          end
        end
      elseif event == fk.TargetConfirming then
        if data.from == player.id and
            (data.card:isCommonTrick() or data.card.type == Card.TypeBasic) and
            player:getMark("jy_master_" .. property) == 0 then -- 这个标记是为了防止同一张牌指定多个目标时问询多次
          -- 检查是否所有的目标角色已经被选中。只要有一个没被选中，那就return true
          local targets = AimGroup:getAllTargets(data.tos)
          for _, p in ipairs(player.room:getOtherPlayers(player)) do
            if is_fun(p) and not table.contains(targets, p.id) and not Self:isProhibited(p, data.card) then
              return true
            end
          end
        end
      elseif event == fk.Damage then
        return (target and is_fun(target) and target ~= player) or (target == player and is_fun(data.to))
      end
    end
  end
  
  local function master_on_cost(is_fun, property)
    return function(self, event, target, player, data)
      if event == fk.EventPhaseProceeding then
        return true
      elseif event == fk.TargetConfirming then
        local room = player.room
        room:setPlayerMark(player, "jy_master_" .. property, true)
        -- 直接询问是否要指定别的目标
        local initial_targets = AimGroup:getAllTargets(data.tos)
        local targets = table.map(table.filter(room:getOtherPlayers(player),
            function(p)
              return is_fun(p) and not table.contains(initial_targets, p.id) and
                  not Self:isProhibited(p, data.card)
            end),
          Util.IdMapper)
        local result = room:askForChoosePlayers(player, targets, 1, #room.alive_players,
          "#jy_master_" .. property .. "-ask",
          self.name)
        if #result > 0 then
          data.cost_data = result
          return true
        end
      else
        return true
      end
    end
  end
  
  local function master_on_use(is_fun)
    return function(self, event, target, player, data)
      local room = player.room
      if event == fk.EventPhaseProceeding then
        room:setPlayerMark(player, "jy_masters-phase", true) -- 防止你因为选择高手而继续刷将和回复体力
        local generals = { "jy__genshin__master", "jy__que__master",
          "jy__moe__master", "jy__lol__master", "jy__liuxian", "jy__huohuo",
          "jy__kgdxs", "jy__kgds", "jy__gambler", "jy__qexbj" }
        -- 不能选择场上已有的武将
        table.removeOne(generals, self.general)
        for _, p in ipairs(room:getAlivePlayers()) do
          table.removeOne(generals, p.general)
          table.removeOne(generals, p.deputyGeneral)
        end
        generals = table.connect(generals, room:getNGenerals(18 - #generals))
        local general = room:askForGeneral(player, generals, 1, true) -- true 才是禁止替换
        room:changeHero(player, general, false, self.general == player.deputyGeneral, true)
        if player.phase == Player.Start then
          room:recover({
            who = player,
            num = 1,
            recoverBy = player,
            skillName = self.name,
          })
        end
      elseif event == fk.TargetConfirming then
        for _, pid in ipairs(data.cost_data) do
          AimGroup:addTargets(room, data, pid)
        end
        room:doIndicate(data.from, data.cost_data)
      else
        player:drawCards(1, self.name)
      end
    end
  end
  
  local master_refresh_events = { fk.CardUseFinished }
  
  local function master_can_refresh(property)
    return function(self, event, target, player, data)
      return player:hasSkill(self) and
          player:getMark("jy_master_" .. property) ~= 0
    end
  end
  
  local function master_on_refresh(property)
    return function(self, event, target, player, data) player.room:setPlayerMark(player, "jy_master_" .. property, 0) end
  end
  
  -- 生成一个对应的技能。
  local function master_createTriggerSkill(is_fun, property)
    return fk.CreateTriggerSkill {
      name = "jy_master_" .. property,
      events = master_events,
      can_trigger = master_can_trigger(is_fun, property),
      on_cost = master_on_cost(is_fun, property),
      on_use = master_on_use(is_fun),
      refresh_events = master_refresh_events,
      can_refresh = master_can_refresh(property),
      on_refresh = master_on_refresh(property)
    }
  end
  
  local ysgs = General(extension, "jy__genshin__master", "qun", 4, 4, General.Female)
  ysgs:addSkill(master_createTriggerSkill(is_genshin, "genshin"))
  
  local qhgs = General(extension, "jy__que__master", "que", 4, 4, General.Female)
  qhgs:addSkill(master_createTriggerSkill(is_majsoul, "majsoul"))
  
  local mgs = General(extension, "jy__moe__master", "moe", 4, 4, General.Female)
  mgs:addSkill(master_createTriggerSkill(is_moe, "moe"))
  
  local lmgs = General(extension, "jy__lol__master", "qun", 4, 4, General.Female)
  lmgs:addSkill(master_createTriggerSkill(is_lol, "lol"))
  
  local function master_des(property)
    return [[你使用普通锦囊牌和基本牌可以额外指定任意<font color="red">]] ..
        property ..
        [[</font>角色为目标。除你以外的<font color="red">]] ..
        property ..
        [[</font>角色造成伤害后或你对<font color="red">]] ..
        property ..
        [[</font>角色造成伤害后，你摸一张牌。准备阶段或结束阶段，若除你以外没有存活的<font color="red">]] ..
        property ..
        [[</font>角色且你武将牌上有该技能，你变更该武将，若为准备阶段，你回复一点体力。]]
  end
  
  Fk:loadTranslationTable {
    ["jy__genshin__master"] = "原神高手",
    ["#jy__genshin__master"] = "考公专家",
    ["designer:jy__genshin__master"] = "考公专家",
    ["cv:jy__genshin__master"] = "AI德丽莎",
    ["illustrator:jy__genshin__master"] = "德丽莎",
    ["~jy__genshin__master"] = "不玩了！再也不玩了！",
  
    ["jy_master_genshin"] = "原神",
    [":jy_master_genshin"] = master_des("原神"),
    ["$jy_master_genshin1"] = [[玩原神玩的！]],
    ["$jy_master_genshin2"] = [[不玩原神导致的！]],
    ["$jy_master_genshin3"] = [[原神，启动！]],
    ["#jy_master_genshin-ask"] = [[原神：你可以额外指定任意原神角色为目标]],
  
    ["jy__que__master"] = "雀魂高手",
    ["#jy__que__master"] = "祈",
    ["designer:jy__que__master"] = "考公专家",
    ["cv:jy__que__master"] = "AI德丽莎",
    ["illustrator:jy__que__master"] = "德丽莎",
    ["~jy__que__master"] = "不玩了！再也不玩了！",
  
    ["jy_master_majsoul"] = "雀神",
    [":jy_master_majsoul"] = master_des("雀势力"),
    ["$jy_master_majsoul1"] = [[玩雀魂玩的！]],
    ["$jy_master_majsoul2"] = [[不玩雀魂导致的！]],
    ["$jy_master_majsoul3"] = [[雀魂，启动！]],
    ["#jy_master_majsoul-ask"] = [[雀神：你可以额外指定任意雀势力角色为目标]],
  
    ["jy__moe__master"] = "萌包高手",
    ["#jy__moe__master"] = "emo公主",
    ["designer:jy__moe__master"] = "考公专家",
    ["cv:jy__moe__master"] = "AI德丽莎",
    ["illustrator:jy__moe__master"] = "德丽莎",
    ["~jy__moe__master"] = "不玩了！再也不玩了！",
  
    ["jy_master_moe"] = "萌神",
    [":jy_master_moe"] = master_des("萌势力"),
    ["$jy_master_moe1"] = [[玩萌包玩的！]],
    ["$jy_master_moe2"] = [[不玩萌包导致的！]],
    ["$jy_master_moe3"] = [[萌包，启动！]],
    ["#jy_master_moe-ask"] = [[萌神：你可以额外指定任意萌势力角色为目标]],
  
    ["jy__lol__master"] = "联盟高手",
    ["#jy__lol__master"] = "考公专家",
    ["designer:jy__lol__master"] = "考公专家",
    ["cv:jy__lol__master"] = "AI德丽莎",
    ["illustrator:jy__lol__master"] = "德丽莎",
    ["~jy__lol__master"] = "不玩了！再也不玩了！",
  
    ["jy_master_lol"] = "盟神",
    [":jy_master_lol"] = master_des("英雄联盟"),
    ["$jy_master_lol1"] = [[玩英雄联盟玩的！]],
    ["$jy_master_lol2"] = [[不玩英雄联盟导致的！]],
    ["$jy_master_lol3"] = [[英雄联盟，启动！]],
    ["#jy_master_lol-ask"] = [[盟神：你可以额外指定任意英雄联盟角色为目标]],
  }
  
  --- masters end here
  return extension
  