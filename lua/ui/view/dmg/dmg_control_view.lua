local UI = Z.UI
local super = require("ui.ui_view_base")
local Dmg_controlView = class("Dmg_controlView", super)
local dmgVm = Z.VMMgr.GetVM("damage")
local gmVm = Z.VMMgr.GetVM("gm")
local dmgData = Z.DataMgr.Get("damage_data")
local fightTestPanelAttrParaTab = Z.Global.FightTestPanelAttrPara
local monsterFormationTab = Z.Global.MonsterFormation
local trainingHallIdTab = Z.Global.TrainingHallId
local FightTestPanelButton = Z.Global.FightTestPanelButton
local FightTestPanelButtonPlayer = Z.Global.FightTestPanelButtonPlayer
local loopScrollRect = require("ui/component/loopscrollrect")
local attrLoopItem = require("ui.component.damage.dmg_control_attr_loop_item")
local buffLoopItem = require("ui.component.damage.dmg_control_buff_loop_item")
local monsterLoopItem = require("ui.component.damage.dmg_control_monster_loop_item")
local dummyLoopItem = require("ui.component.damage.dmg_control_dummy_loop_item")
local skillLoopItem = require("ui.component.damage.dmg_control_skill_loop_item")
local targetLoopItem = require("ui.component.damage.dmg_control_target_loop_item")
local selectedType = {
  Role = 1,
  Monster = 2,
  Dummy = 3
}

function Dmg_controlView:ctor()
  self.panel = nil
  super.ctor(self, "dmg_control")
  self.attrView_ = require("ui/view/dmg/dmg_attr_pop_view").new(self)
  self.progressbarView_ = require("ui/view/dmg/dmg_progressbar_pop_view").new(self)
  dmgVm.InitControlData()
end

function Dmg_controlView:initZWidget()
  self.targetNode_ = self.panel.node_input_target
  self.skillNode_ = self.panel.node_input_skill
  self.monsterNode_ = self.panel.node_input_monster
  self.dummyNode_ = self.panel.node_input_dummy
  self.attrNode_ = self.panel.node_input_attr
  self.buffNode_ = self.panel.node_input_buff
  self.attrLoop_ = self.attrNode_.node_loop
  self.buffLoop_ = self.buffNode_.node_loop
  self.skillLoop_ = self.skillNode_.node_loop
  self.targetLoop_ = self.targetNode_.node_loop
  self.monsterLoop_ = self.monsterNode_.node_loop
  self.dummyLoop_ = self.dummyNode_.node_loop
  self.nodeData_ = self.panel.node_data
  self.refreshDataBtn_ = self.panel.n_common_btn_4.btn
  self.packDataBtn_ = self.panel.btn_pack_data
  self.showDataBtn_ = self.panel.btn_show_data
  self.lockBtn_ = self.panel.btn_lock
  self.packDataBtn_:SetVisible(true)
  self.showDataBtn_:SetVisible(false)
  self.setBtn_ = self.panel.btn_set
  self.openstatsBtn_ = self.panel.btn_openstats
  self.closeBtn_ = self.panel.btn_close
  self.arrowBtn_ = self.panel.btn_arrow
  self.openBtn_ = self.panel.btn_open
  self.monsterSelect_ = self.panel.node_monster
  self.roleSelect_ = self.panel.node_role
  self.dummySelect_ = self.panel.node_dummy
  self.addDummyBtn_ = self.panel.node_add_dummy.btn
  self.functionNode_ = self.panel.node_function
  self.function2Node_ = self.panel.node_function2
  self.callOneMonsterBtn_ = self.panel.addmonster
  self.callMoreMonsterBtn_ = self.panel.add_monster_more
  self.monsterAttrBtn_ = self.panel.allmonster_attr
  self.enterSecneBtn_ = self.panel.btn_enter
  self.killAllMonsterNode_ = self.panel.alldead_btn
  self.delBuffBtn_ = self.panel.btn_delete_buff
  self.addBuffBtn_ = self.panel.btn_add_buff
  self.resetAttrBtn_ = self.panel.btn_reset_attr
  self.addAttrBtn_ = self.panel.btn_add_attr
  self.buffParmInput_ = self.panel.node_buffparm.input_buff_parm
  self.roleBuffToggleNode_ = self.panel.panel_role_01
  self.aiEventNode_ = self.panel.node_aievent
  self.aiSendBtn = self.aiEventNode_.btn_send
  self.aiEventInput_ = self.aiEventNode_.input_buff_parm
  self.buffEventNode_ = self.panel.node_buffevent
  self.buffSendBtn = self.buffEventNode_.btn_send
  self.buffEventInput_ = self.buffEventNode_.input_buff_parm
end

function Dmg_controlView:initBtnFunc()
  self:AddClick(self.refreshDataBtn_.Btn, function()
    self:initNearMonsterData()
    if self.dmgTimer ~= nil then
      self.timerMgr:StopTimer(self.dmgTimer)
      self.dmgTimer = nil
    end
    self:initDamageData()
  end)
  self:AddClick(self.arrowBtn_.Btn, function()
    self.panel.node_parent:SetVisible(false)
    self.nodeData_:SetVisible(false)
    self.panel.mid_parent:SetVisible(false)
    self.arrowBtn_:SetVisible(false)
    self.openBtn_:SetVisible(true)
  end)
  self:AddClick(self.openBtn_.Btn, function()
    self.panel.node_parent:SetVisible(true)
    self.panel.mid_parent:SetVisible(true)
    self.arrowBtn_:SetVisible(true)
    self.openBtn_:SetVisible(false)
    self.nodeData_:SetVisible(true)
    self.packDataBtn_:SetVisible(true)
    self.showDataBtn_:SetVisible(false)
  end)
  self.targetNode_.input.Input:AddSelectListener(function(bool)
    self:initNearMonsterData()
    self:refreshTargetDro()
    self.targetLoop_:SetVisible(#dmgData.ControlNearMonsterTab > 0)
  end)
  self.monsterNode_.input.Input:AddSelectListener(function(bool)
    self.monsterLoop_:SetVisible(#dmgData.ShowMonsterDroData > 0)
  end)
  self.dummyNode_.input.Input:AddSelectListener(function(bool)
    self.dummyLoop_:SetVisible(#dmgData.ShowDummyDroData > 0)
  end)
  self.skillNode_.input.Input:AddSelectListener(function(bool)
    self.skillLoop_:SetVisible(dmgData.ShowSkillDroData and #dmgData.ShowSkillDroData > 0)
  end)
  self.buffNode_.input.Input:AddSelectListener(function(bool)
    self.buffLoop_:SetVisible(#dmgData.ShowBuffDroData > 0)
  end)
  self.attrNode_.input.Input:AddSelectListener(function(bool)
    self.attrLoop_:SetVisible(#dmgData.ShowAttrDroData > 0)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.monsterLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.monsterLoop_:SetVisible(false)
    end
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.dummyLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.dummyLoop_:SetVisible(false)
    end
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.buffLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.buffLoop_:SetVisible(false)
    end
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.skillLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.skillLoop_:SetVisible(false)
    end
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.targetLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.targetLoop_:SetVisible(false)
    end
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.attrLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.attrLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.buffParmInput_.Input, function(str)
    self.buffParm_ = str
  end)
  self:AddClick(self.panel.node_input_monster.input.Input, function(str)
    if dmgData.IsSelectedMonsterDro then
      dmgData.IsSelectedMonsterDro = false
      return
    end
    dmgData.ShowMonsterDroData = dmgVm.DimFindData(str, dmgData.ControlMonsterTab)
    table.insert(dmgData.ShowMonsterDroData, "")
    self.monsterScrollRect_:SetData(dmgData.ShowMonsterDroData)
    self.monsterLoop_:SetVisible(#dmgData.ShowMonsterDroData > 0)
  end)
  self:AddClick(self.panel.node_input_dummy.input.Input, function(str)
    if dmgData.IsSelectedMonsterDro then
      dmgData.IsSelectedMonsterDro = false
      return
    end
    dmgData.ShowDummyDroData = dmgVm.DimFindData(str, dmgData.ControlDummyTab)
    table.insert(dmgData.ShowDummyDroData, "")
    self.dummyScrollRect_:SetData(dmgData.ShowDummyDroData)
    self.dummyLoop_:SetVisible(#dmgData.ShowDummyDroData > 0)
  end)
  self:AddClick(self.skillNode_.input.Input, function(str)
    if dmgData.IsSelectedSkillDro then
      dmgData.IsSelectedSkillDro = false
      return
    end
    dmgData.ShowSkillDroData = dmgVm.DimFindData(str, dmgData.ControlSkillTab)
    table.insert(dmgData.ShowSkillDroData, "")
    self.skillScrollRect_:SetData(dmgData.ShowSkillDroData)
    self.skillLoop_:SetVisible(#dmgData.ShowSkillDroData > 0)
  end)
  self:AddClick(self.panel.node_input_buff.input.Input, function(str)
    if dmgData.IsSelectedBuffDro then
      dmgData.IsSelectedBuffDro = false
      return
    end
    dmgData.ShowBuffDroData = dmgVm.DimFindData(str, dmgData.ControlBuffData)
    table.insert(dmgData.ShowBuffDroData, "")
    self.buffScrollRect_:SetData(dmgData.ShowBuffDroData)
    self.buffLoop_:SetVisible(#dmgData.ShowBuffDroData > 0)
  end)
  self:AddClick(self.panel.node_input_attr.input.Input, function(str)
    if dmgData.IsSelectedAttrDro then
      dmgData.IsSelectedAttrDro = false
      return
    end
    dmgData.ShowAttrDroData = dmgVm.DimFindData(str, dmgData.ControlFightAttrData)
    table.insert(dmgData.ShowAttrDroData, "")
    self.attrScrollRect_:SetData(dmgData.ShowAttrDroData)
    self.attrLoop_:SetVisible(#dmgData.ShowAttrDroData > 0)
  end)
  self:AddClick(self.monsterSelect_.btn.Btn, function()
    self.isSelectRole_ = false
    self.selectedType = selectedType.Monster
    if self.isOpenControl_ then
      self.panel.panel_control:SetVisible(true)
    end
    self.function2Node_.lab_name.TMPLab.text = Lang("Summon")
    self:isSelectMonster()
    self:isSelectFunc1(true)
  end)
  self:AddClick(self.dummySelect_.btn.Btn, function()
    self.isSelectRole_ = false
    self.selectedType = selectedType.Dummy
    if self.isOpenControl_ then
      self.panel.panel_control:SetVisible(true)
    end
    self.function2Node_.lab_name.TMPLab.text = Lang("Summon")
    self:isSelectMonster()
    self:isSelectFunc1(true)
  end)
  self:AddClick(self.roleSelect_.btn.Btn, function()
    self.isSelectRole_ = true
    self.selectedType = selectedType.Role
    self:isSelectMonster()
    self.function2Node_.lab_name.TMPLab.text = Lang("Special")
    self:isSelectFunc1(true)
  end)
  self:AddAsyncClick(self.callOneMonsterBtn_.btn.Btn, function()
    if dmgData.ControlSelectMonsterData == "" then
      return
    end
    local monsterId = string.split(dmgData.ControlSelectMonsterData, " ")[1]
    local cmdInfo = "addMonster " .. monsterId .. ","
    for index, value in pairs(dmgData.ControlMonsterAttrTab) do
      cmdInfo = string.zconcat(cmdInfo, index, "|", value .. "|")
    end
    dmgData.ControlMonsterAttrTab = {}
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddClick(self.monsterAttrBtn_.btn.Btn, function()
    self.attrView_:Active(nil, self.panel.subview_parent.Trans)
  end)
  self:AddAsyncClick(self.callMoreMonsterBtn_.btn.Btn, function()
    local monsterId = monsterFormationTab[dmgData.ControlFormationIndex][2]
    local distance = monsterFormationTab[dmgData.ControlFormationIndex][3]
    local attrStruct = {}
    attrStruct.attrs = dmgData.ControlMonsterAttrTab
    local str = ""
    for attrId, value in pairs(dmgData.ControlMonsterAttrTab) do
      str = string.zconcat(str, attrId, "|", value, "|")
    end
    str = str:sub(1, -2)
    local cmdInfo = string.zconcat("dmgPnlAddGroupMonster ", monsterId, ",", distance, ",", str)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.killAllMonsterNode_.btn.Btn, function()
    local istrainingHall = false
    local scenceId = Z.StageMgr.GetCurrentSceneId()
    for key, value in pairs(trainingHallIdTab[1]) do
      if scenceId == value then
        istrainingHall = true
      end
    end
    if istrainingHall then
      gmVm.SubmitGmCmd("gmKillAllMonster", self.cancelSource)
    end
  end, nil, nil)
  self:AddAsyncClick(self.targetNode_.dead_target.btn.Btn, function()
    local cmdInfo = "killNpc " .. dmgData.ControlNowSelectTargetUuid
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.skillNode_.use_skill.btn.Btn, function()
    if dmgData.ControlNowSelectTargetUuid ~= 0 and dmgData.ControlSkillId ~= 0 then
      local cmdInfo = string.zconcat("monsterForceUseSkill ", dmgData.ControlNowSelectTargetUuid, ",", dmgData.ControlSkillId)
      gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
    end
  end)
  self:AddAsyncClick(self.addBuffBtn_.btn.Btn, function()
    local cmdInfo = string.zconcat("addBuff ", dmgData.ControlBuffId, ",", dmgData.ControlNowSelectTargetUuid, ",", dmgData.ControlBuffCount, ",", dmgData.ControlBuffTime, ",", self.buffParm_)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.delBuffBtn_.btn.Btn, function()
    local cmdInfo = string.zconcat("delBuff ", dmgData.ControlBuffId, ",", dmgData.ControlNowSelectTargetUuid)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.resetAttrBtn_.btn.Btn, function()
    gmVm.SubmitGmCmd("clearGMAttr", self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.addAttrBtn_.btn.Btn, function()
    local attrId = tonumber(dmgData.ControlAttrId)
    local fightAttr = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(attrId)
    local tempAttr = Z.TableMgr.GetTable("TempAttrTableMgr").GetRow(attrId)
    if fightAttr then
      local type = self.attrType
      local id = fightAttr[type]
      local cmdInfo = string.zconcat("addGMAttr ", id, "|", dmgData.ControlAttrCount, ",", dmgData.ControlNowSelectTargetUuid)
      gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
    end
    if tempAttr then
      local cmdInfo = string.zconcat("addGMTempAttr ", dmgData.ControlAttrId, "|", dmgData.ControlAttrCount, " ", dmgData.ControlNowSelectTargetUuid)
      gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
    end
  end, nil, nil)
  self:AddAsyncClick(self.panel.toggle_ai.Tog, function(isOn)
    local tepe = 1
    if isOn then
      tepe = 0
    end
    local cmdInfo = string.zconcat("banAi ", dmgData.ControlNowSelectTargetUuid, ",", tepe)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end)
  self:AddAsyncClick(self.enterSecneBtn_.btn.Btn, function()
    local cmdInfo = string.zconcat("enterScene ", trainingHallIdTab[1][1])
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end)
  self:AddClick(self.panel.input_buff_time.Input, function(str)
    dmgData.ControlBuffTime = tonumber(str) * 1000
  end)
  self:AddClick(self.panel.input_buff_count.Input, function(str)
    dmgData.ControlBuffCount = str
  end)
  self:AddClick(self.panel.input_attr_content.Input, function(str)
    dmgData.ControlAttrCount = str
  end)
  self:AddClick(self.closeBtn_.Btn, function()
    Z.UIMgr:CloseView("dmg_control")
  end)
  self:AddClick(self.lockBtn_.Btn, function()
    self.switch = not self.switch
    self.panel.mid_parent.Ref.CanvasGroup.interactable = self.switch
    self.panel.mid_parent.Ref.CanvasGroup.blocksRaycasts = self.switch
    self.panel.node_parent.Ref.CanvasGroup.interactable = self.switch
    self.panel.node_parent.Ref.CanvasGroup.blocksRaycasts = self.switch
  end)
  self:AddClick(self.setBtn_.Btn, function()
    self.progressbarView_:Active(nil, self.panel.subview_parent.Trans)
  end)
  self:AddClick(self.function2Node_.btn.Btn, function()
    self:isSelectFunc1(false)
  end)
  self:AddClick(self.functionNode_.btn.Btn, function()
    self:isSelectFunc1(true)
  end)
  self:AddClick(self.openstatsBtn_.Btn, function()
    dmgVm.OpenDamageView()
  end)
  self:AddClick(self.packDataBtn_.Btn, function()
    self.panel.mid_parent:SetVisible(false)
    self.packDataBtn_:SetVisible(false)
    self.showDataBtn_:SetVisible(true)
  end)
  self:AddClick(self.showDataBtn_.Btn, function()
    self.panel.mid_parent:SetVisible(true)
    self.packDataBtn_:SetVisible(true)
    self.showDataBtn_:SetVisible(false)
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    local toggleTpl = self:GetPrefabCacheData("toggle")
    if toggleTpl == "" or toggleTpl == nil then
      return
    end
    for key, value in pairs(FightTestPanelButton) do
      local buffId = key
      local buffName = Lang(value)
      local unit = self:AsyncLoadUiUnit(toggleTpl, "monster" .. buffId, self.panel.panel_down.Trans, self.cancelSource:CreateToken())
      if unit then
        unit.lab_name.TMPLab.text = buffName
        self:AddAsyncClick(unit.tog_control_tpl.Tog, function(isOn)
          if dmgData.ControlNowSelectTargetUuid ~= 0 then
            local gmName = ""
            if isOn then
              gmName = "addBuff "
            else
              gmName = "delBuff "
            end
            local cmdInfo = string.zconcat(gmName, buffId)
            gmVm.SubmitGmCmd(cmdInfo, self.cancelSource, tonumber(dmgData.ControlNowSelectTargetUuid))
          end
        end)
      end
    end
    for key, value in pairs(FightTestPanelButtonPlayer) do
      local buffId = key
      local buffName = Lang(value)
      local unit = self:AsyncLoadUiUnit(toggleTpl, "player" .. buffId, self.roleBuffToggleNode_.Trans)
      if unit then
        unit.lab_name.TMPLab.text = buffName
        self:AddAsyncClick(unit.tog_control_tpl.Tog, function(isOn)
          local gmName = ""
          if isOn then
            gmName = "addBuff "
          else
            gmName = "delBuff "
          end
          local cmdInfo = string.zconcat(gmName, buffId)
          gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
        end)
      end
    end
  end)()
  self:AddClick(self.aiEventInput_.Input, function(str)
    self.aiEventName_ = str
  end)
  self:AddClick(self.buffEventInput_.Input, function(str)
    self.buffEventName_ = str
  end)
  self:AddAsyncClick(self.aiSendBtn.btn.Btn, function()
    if dmgData.ControlNowSelectTargetUuid == "" then
      return
    end
    local cmdInfo = string.zconcat("addAiEvent ", dmgData.ControlNowSelectTargetUuid, ",", self.aiEventName_)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.buffSendBtn.btn.Btn, function()
    if dmgData.ControlNowSelectTargetUuid == "" then
      return
    end
    local cmdInfo = string.zconcat("addBuffCustomEvent ", dmgData.ControlNowSelectTargetUuid, ",", self.buffEventName_)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
  self:AddAsyncClick(self.addDummyBtn_.Btn, function()
    if dmgData.ControlSelectDummyData == "" then
      return
    end
    local dummyId = string.split(dmgData.ControlSelectDummyData, " ")[1]
    local cmdInfo = string.zconcat("addEntity ", Z.PbEnum("EEntityType", "EntDummy"), ",", dummyId)
    gmVm.SubmitGmCmd(cmdInfo, self.cancelSource)
  end, nil, nil)
end

function Dmg_controlView:OnActive()
  self.isSelectRole_ = false
  self.attrTitle_ = {}
  self.attrcontent_ = {}
  self.isOpenControl_ = true
  self.buffParm_ = ""
  self.aiEventName_ = ""
  self.buffEventName_ = ""
  self:initZWidget()
  self.monsterScrollRect_ = loopScrollRect.new(self.monsterLoop_.VLoopScrollRect, self, monsterLoopItem)
  self.skillScrollRect_ = loopScrollRect.new(self.skillLoop_.VLoopScrollRect, self, skillLoopItem)
  self.buffScrollRect_ = loopScrollRect.new(self.buffLoop_.VLoopScrollRect, self, buffLoopItem)
  self.attrScrollRect_ = loopScrollRect.new(self.attrLoop_.VLoopScrollRect, self, attrLoopItem)
  self.targetScrollRect_ = loopScrollRect.new(self.targetLoop_.VLoopScrollRect, self, targetLoopItem)
  self.dummyScrollRect_ = loopScrollRect.new(self.dummyLoop_.VLoopScrollRect, self, dummyLoopItem)
  for key, value in ipairs(fightTestPanelAttrParaTab) do
    table.insert(self.attrTitle_, Lang(value[1]))
    table.insert(self.attrcontent_, value[1])
  end
  self.switch = true
  self:initBtnFunc()
  dmgData:Init()
  dmgVm.ChangeDrowIndex()
  self:initNearMonsterData()
  self:initDamageData()
  self:allDropdownMgr()
  self:BindEvents()
  self.selectedType = selectedType.Monster
  self:isSelectMonster()
  self:isSelectFunc1(true)
end

function Dmg_controlView:isSelectFunc1(flag)
  self.function2Node_.on:SetVisible(not flag)
  self.function2Node_.off:SetVisible(flag)
  self.functionNode_.off:SetVisible(not flag)
  self.functionNode_.on:SetVisible(flag)
  self.panel.panel_dummy:SetVisible(false)
  if self.selectedType == selectedType.Role then
    self.roleBuffToggleNode_:SetVisible(not flag)
    self.panel.panel_arr:SetVisible(flag)
    self.panel.panel_monster_one:SetVisible(false)
  elseif self.selectedType == selectedType.Monster then
    self.panel.panel_monster_one:SetVisible(not flag)
    self.panel.panel_control:SetVisible(flag)
  elseif self.selectedType == selectedType.Dummy then
    self.panel.panel_monster_one:SetVisible(false)
    self.panel.panel_control:SetVisible(flag)
    self.panel.panel_dummy:SetVisible(flag)
  end
  self.panel.panel_buff:SetVisible(flag)
end

function Dmg_controlView:isSelectMonster()
  self.roleBuffToggleNode_:SetVisible(self.selectedType == selectedType.Role)
  self.panel.panel_arr:SetVisible(self.selectedType == selectedType.Role)
  self.monsterSelect_.off:SetVisible(self.selectedType ~= selectedType.Monster)
  self.monsterSelect_.on:SetVisible(self.selectedType == selectedType.Monster)
  self.roleSelect_.off:SetVisible(self.selectedType ~= selectedType.Role)
  self.roleSelect_.on:SetVisible(self.selectedType == selectedType.Role)
  self.dummySelect_.off:SetVisible(self.selectedType ~= selectedType.Dummy)
  self.dummySelect_.on:SetVisible(self.selectedType == selectedType.Dummy)
  if self.selectedType == selectedType.Role then
    self.panel.panel_control:SetVisible(false)
    dmgData.ControlSkillTab = {}
    dmgData.ControlNowSelectTargetUuid = Z.EntityMgr.PlayerUuid
  elseif self.selectedType == selectedType.Monster then
    self:initNearMonsterData()
    self:refreshTargetDro()
  elseif self.selectedType == selectedType.Dummy then
    self:initNearDummyData()
    self:refreshTargetDro()
  end
end

function Dmg_controlView:initNearMonsterData()
  local tab = dmgVm.GetNearEntityByType(Z.PbEnum("EEntityType", "EntMonster"))
  dmgData.ControlNearMonsterTab = {}
  if tab then
    for key, value in pairs(tab) do
      local monsterTab = dmgVm.GetMonsterTab(value)
      local targetName
      if monsterTab then
        targetName = monsterTab.Name
      end
      table.insert(dmgData.ControlNearMonsterTab, value .. " " .. targetName)
    end
    table.insert(dmgData.ControlNearMonsterTab, dmgData.PlayerUuid .. " " .. Z.ContainerMgr.CharSerialize.charBase.name)
  else
    dmgData.ControlNearMonsterTab = {}
    table.insert(dmgData.ControlNearMonsterTab, dmgData.PlayerUuid .. " " .. Z.ContainerMgr.CharSerialize.charBase.name)
  end
end

function Dmg_controlView:initNearDummyData()
  local tab = dmgVm.GetNearEntityByType(Z.PbEnum("EEntityType", "EntDummy"))
  dmgData.ControlNearDummyTab = {}
  if tab then
    for key, value in pairs(tab) do
      local dummyTab = dmgVm.GetDummyTabByUuid(value)
      local targetName
      if dummyTab then
        targetName = dummyTab.Name
      end
      table.insert(dmgData.ControlNearDummyTab, value .. " " .. targetName)
    end
  end
end

function Dmg_controlView:hideControl(isHide)
  if not self.isSelectRole_ then
    self.panel.panel_control:SetVisible(isHide)
  end
  self.monsterSelect_.off:SetVisible(not isHide)
  self.monsterSelect_.on:SetVisible(isHide)
  if isHide then
    self:initNearMonsterData()
    self:refreshTargetDro()
  end
end

function Dmg_controlView:allDropdownMgr()
  self.panel.gm_input_tpl11.panel_dropdown.TMPDropdown:ClearAll()
  self.attrType = self.attrcontent_[1]
  self.panel.gm_input_tpl11.panel_dropdown.TMPDropdown:AddListener(function(index)
    self.attrType = self.attrcontent_[index + 1]
  end, true)
  self.panel.gm_input_tpl11.panel_dropdown.TMPDropdown:AddOptions(self.attrTitle_)
  self:refreshTargetDro()
  self.targetScrollRect_:SetSelected(0)
  self:refreshMonsterMoreDro()
  self:refreshAttrDro()
  self:refreshBuffDro()
  self:refreshMonsterDro()
  self:refreshDummyDro()
end

function Dmg_controlView:refreshAttrDro()
  if dmgData.ControlFightAttrData == nil then
    dmgData.ControlSelectedAttrData = ""
    return
  end
  dmgData.ControlSelectedAttrData = dmgData.ControlFightAttrData[1]
  dmgData.IsSelectedAttrDro = true
  self.panel.node_input_attr.input.Input.text = dmgData.ControlSelectedAttrData
  dmgData.ControlAttrId = string.split(dmgData.ControlSelectedAttrData, " ")[1]
  dmgData.ShowAttrDroData = dmgData.ControlFightAttrData
  self.attrScrollRect_:SetData(dmgData.ControlFightAttrData)
end

function Dmg_controlView:refreshMonsterMoreDro()
  if dmgData.ControlMonsterFormationTab == nil then
    dmgData.ControlFormationIndex = 0
    return
  end
  dmgData.ControlFormationIndex = 1
  self.panel.node_input_body.panel_dropdown.TMPDropdown:ClearAll()
  self.panel.node_input_body.panel_dropdown.TMPDropdown:AddListener(function(index)
    dmgData.ControlFormationIndex = index + 1
  end, true)
  self.panel.node_input_body.panel_dropdown.TMPDropdown:AddOptions(dmgData.ControlMonsterFormationTab)
end

function Dmg_controlView:refreshBuffDro()
  if dmgData.ControlBuffData == nil then
    dmgData.ControlBuffId = 0
    return
  end
  dmgData.IsSelectedBuffDro = true
  local buffData = dmgData.ControlBuffData[1]
  self.panel.node_input_buff.input.Input.text = buffData
  dmgData.ControlBuffId = string.split(buffData, " ")[1]
  dmgData.ShowBuffDroData = dmgData.ControlBuffData
  self.buffScrollRect_:SetData(dmgData.ControlBuffData)
  self.buffScrollRect_:SetSelected(0)
end

function Dmg_controlView:refreshMonsterDro()
  if dmgData.ControlMonsterTab == nil then
    dmgData.ControlSelectMonsterData = ""
    return
  end
  dmgData.ControlSelectMonsterData = dmgData.ControlMonsterTab[1]
  dmgData.IsSelectedMonsterDro = true
  self.panel.node_input_monster.input.Input.text = dmgData.ControlSelectMonsterData
  dmgData.ShowMonsterDroData = dmgData.ControlMonsterTab
  self.monsterScrollRect_:SetData(dmgData.ControlMonsterTab)
  self.monsterScrollRect_:SetSelected(0)
end

function Dmg_controlView:refreshDummyDro()
  if dmgData.ControlDummyTab == nil then
    dmgData.ControlSelectDummyData = ""
    return
  end
  dmgData.ControlSelectDummyData = dmgData.ControlDummyTab[1]
  dmgData.IsSelectedMonsterDro = true
  self.panel.node_input_dummy.input.Input.text = dmgData.ControlSelectDummyData
  dmgData.ShowDummyDroData = dmgData.ControlDummyTab
  self.dummyScrollRect_:SetData(dmgData.ControlDummyTab)
  self.dummyScrollRect_:SetSelected(0)
end

function Dmg_controlView:refreshTargetDro()
  local tab = {}
  if self.selectedType == selectedType.Monster then
    tab = dmgData.ControlNearMonsterTab
  elseif self.selectedType == selectedType.Dummy then
    tab = dmgData.ControlNearDummyTab
  end
  if tab == nil or #tab == 0 then
    dmgData.ControlNowSelectTargetUuid = 0
    self.targetScrollRect_:SetData({})
    return
  end
  local tagetData = tab[1]
  dmgData.ControlNowSelectTargetUuid = string.split(tagetData, " ")[1]
  local uuid = string.split(tagetData, " ")[1]
  if uuid ~= nil then
    if self.selectedType == selectedType.Monster then
      dmgData.ControlSkillTab = dmgVm.GetMonsterSkills(uuid)
    elseif self.selectedType == selectedType.Dummy then
      dmgData.ControlSkillTab = dmgVm.GetDummySkills(uuid)
    end
    dmgData.ShowSkillDroData = dmgData.ControlSkillTab
  end
  self.targetScrollRect_:SetData(tab)
end

function Dmg_controlView:refreshSkillDro()
  if dmgData.ControlSkillTab == nil then
    dmgData.ControlSkillId = 0
    return
  end
  dmgData.IsSelectedSkillDro = true
  dmgData.ControlSkillId = string.split(dmgData.ShowSkillDroData[1], " ")[1]
  self.skillNode_.input.Input.text = dmgData.ShowSkillDroData[1]
  dmgData.ShowSkillDroData = dmgData.ControlSkillTab
  self.skillScrollRect_:SetData(dmgData.ControlSkillTab)
  self.skillScrollRect_:SetSelected(0)
end

function Dmg_controlView:TargetSelected(data)
  if data == nil then
    return
  end
  self.targetLoop_:SetVisible(false)
  self.targetNode_.input.Input.text = data
  local uuid = string.split(data, " ")[1]
  if self.selectedType == selectedType.Monster then
    dmgData.ControlSkillTab = dmgVm.GetMonsterSkills(uuid)
  elseif self.selectedType == selectedType.Dummy then
    dmgData.ControlSkillTab = dmgVm.GetMonsterSkills(uuid)
  end
  dmgData.ShowSkillDroData = dmgData.ControlSkillTab
  dmgData.ControlNowSelectTargetUuid = uuid
  local entity = Z.EntityMgr:GetEntity(uuid)
  if entity then
    self:selectMonster(entity)
  end
  self:refreshSkillDro()
end

function Dmg_controlView:MonsterSelected(data)
  if data == nil then
    return
  end
  self.monsterLoop_:SetVisible(false)
  if self.panel.node_input_monster.input.Input.text == data then
    return
  end
  dmgData.IsSelectedMonsterDro = true
  self.panel.node_input_monster.input.Input.text = data
  dmgData.ControlSelectMonsterData = data
end

function Dmg_controlView:DummySelected(data)
  if data == nil then
    return
  end
  self.dummyLoop_:SetVisible(false)
  if self.panel.node_input_dummy.input.Input.text == data then
    return
  end
  dmgData.IsSelectedMonsterDro = true
  self.panel.node_input_dummy.input.Input.text = data
  dmgData.ControlSelectDummyData = data
end

function Dmg_controlView:SkillSelected(selectData)
  if selectData == nil then
    return
  end
  self.skillLoop_:SetVisible(false)
  if self.skillNode_.input.Input.text == selectData then
    return
  end
  dmgData.IsSelectedSkillDro = true
  dmgData.ControlSkillId = string.split(selectData, " ")[1]
  self.skillNode_.input.Input.text = selectData
end

function Dmg_controlView:BuffSelected(data)
  if data == nil then
    return
  end
  self.buffLoop_:SetVisible(false)
  if self.panel.node_input_buff.input.Input.text == data then
    return
  end
  dmgData.IsSelectedBuffDro = true
  self.panel.node_input_buff.input.Input.text = data
  dmgData.ControlBuffId = string.split(data, " ")[1]
end

function Dmg_controlView:AttrSelected(data)
  if data == nil then
    return
  end
  self.attrLoop_:SetVisible(false)
  if self.panel.node_input_attr.input.Input.text == data then
    return
  end
  dmgData.IsSelectedAttrDro = true
  self.panel.node_input_attr.input.Input.text = data
  dmgData.ControlAttrId = string.split(data, " ")[1]
end

function Dmg_controlView:selectPlayer()
  self:hideControl(false)
end

function Dmg_controlView:initDamageData()
  self.time_ = 1
  self.hit_ = 0
  self.panel.lab_dmg.TMPLab.text = "0"
  self.panel.lab_sdmg.TMPLab.text = "0"
  self.panel.lab_count.TMPLab.text = "0"
  self.panel.lab_time.TMPLab.text = "0"
  self.panel.input_buff_count.Input.text = dmgData.ControlBuffCount
end

function Dmg_controlView:refreshDmgData(hit, count)
  self.hit_ = self.hit_ + hit
  self.panel.lab_dmg.TMPLab.text = self.hit_
  self.panel.lab_sdmg.TMPLab.text = self.hit_ / self.time_
  self.panel.lab_count.TMPLab.text = count
  self.panel.lab_time.TMPLab.text = self.time_
  self.tim_ = 0
  if not self.dmgTimer then
    self:startTimer()
  end
end

function Dmg_controlView:startTimer()
  self.dmgTimer = self.timerMgr:StartTimer(function()
    self.tim_ = self.tim_ + 1
    self.time_ = self.time_ + 1
    self.panel.lab_time.TMPLab.text = self.time_
    self.panel.lab_sdmg.TMPLab.text = self.hit_ / self.time_
    if self.tim_ >= 2 then
      self.timerMgr:StopTimer(self.dmgTimer)
      self.dmgTimer = nil
    end
  end, 1, -1)
end

function Dmg_controlView:selectMonster(ent)
end

function Dmg_controlView:setBgColorAndAlpha(a)
  if a <= 10 then
    a = 10
  end
  local v4 = Color.New(0.3333333333333333, 0.3333333333333333, 0.3333333333333333, a / 100)
  self.panel.node_parent.Img:SetColor(v4)
  self.panel.bg.Img:SetColor(v4)
end

function Dmg_controlView:OnDeActive()
  self.attrView_:OnDeActive()
end

function Dmg_controlView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Damage.ControlRefreshData, self.refreshDmgData, self)
  Z.EventMgr:Add(Z.ConstValue.Damage.ControlRefreshColor, self.setBgColorAndAlpha, self)
  self.panel.top_container.EventTrigger.onDrag:AddListener(function(go, pointerData)
    self.dragGmBtn = true
    local pos = self.panel.content.Ref:GetPosition()
    self.panel.content.Ref:SetPosition(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
  end)
end

function Dmg_controlView:OnRefresh()
end

return Dmg_controlView
