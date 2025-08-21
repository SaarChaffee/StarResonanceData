local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_dps_subView = class("Main_dps_subView", super)
local loopList = require("ui.component.loop_list_view")
local infoItem = require("ui.component.dps.dps_info_loop_item")
local groupItem = require("ui.component.dps.dps_loop_item")
local infoItemPc = require("ui.component.dps.dps_info_loop_item_pc")
local groupItemPc = require("ui.component.dps.dps_loop_item_pc")
local dpdLabs = {
  Lang("DpsDamage"),
  Lang("DpsCure"),
  Lang("DpsTakeDamage"),
  Lang("DpsDamageSecond"),
  Lang("DpsCureSecond")
}
local dpdPcLabs = {
  Lang("DpsDamage"),
  Lang("DpsCure"),
  Lang("DpsTakeDamage")
}

function Main_dps_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_dps_sub", "main/main_dps_sub", UI.ECacheLv.None, true)
  self.damageVm_ = Z.VMMgr.GetVM("damage")
  self.damageData_ = Z.DataMgr.Get("damage_data")
  self.dpsVm_ = Z.VMMgr.GetVM("dps")
end

function Main_dps_subView:initBinders()
  self.oneInfoNode_ = self.uiBinder.node_oneself
  self.emptyNode_ = self.uiBinder.node_empty
  self.groupNode_ = self.uiBinder.node_group
  self.resetBtn_ = self.uiBinder.btn_reset
  self.groupTimeLab_ = self.groupNode_.lab_time
  self.groupLoopList_ = self.groupNode_.scrollview_item
  self.groupTitleLab_ = self.groupNode_.lab_name
  self.dpdNode_ = self.uiBinder.node_dpd
  self.oneInfoTimeLab_ = self.oneInfoNode_.lab_time
  self.infoTitleLab_ = self.oneInfoNode_.lab_name
  self.returnBtn_ = self.oneInfoNode_.btn_return
  self.infoLoopList_ = self.oneInfoNode_.scrollview_item
end

function Main_dps_subView:beginTime()
  if self.isStating_ == true then
    return
  end
  self.isStating_ = true
  self.groupTitleLab_.text = Lang("InStatistics...")
  self.statTime_ = self.timerMgr:StartTimer(function()
    local str = Z.TimeFormatTools.FormatToDHMS(self.time_, false, true)
    self.groupTimeLab_.text = str
    self.oneInfoTimeLab_.text = str
    self.time_ = self.time_ + 1
  end, 1, -1, nil, function()
    self.groupTimeLab_.text = 0
    self.oneInfoTimeLab_.text = 0
    self.time_ = 0
    self.groupTitleLab_.text = Lang("StopStat")
  end, true)
end

function Main_dps_subView:initBtn()
  self:AddClick(self.returnBtn_, function()
    self.selectedItemData_ = nil
    self.groupNode_.Ref.UIComp:SetVisible(self.isOpenDes_)
    self.uiBinder.Ref:SetVisible(self.resetBtn_, true)
    self.dpdNode_.Ref.UIComp:SetVisible(true)
    self.oneInfoNode_.Ref.UIComp:SetVisible(false)
    self.groupNode_.Ref:SetVisible(self.groupLoopList_, true)
    self.emptyNode_.Ref.UIComp:SetVisible(not self.isOpenDes_)
  end)
  self:AddClick(self.resetBtn_, function()
    self.damageData_:RefreshData()
    self:refrehDamagePanel()
  end)
end

function Main_dps_subView:initUi()
  self.groupTimeLab_.text = 0
  self.oneInfoTimeLab_.text = 0
  self.time_ = 0
  self.groupTitleLab_.text = Lang("StopStat")
  local groupItemClass = Z.IsPCUI and groupItemPc or groupItem
  local groupItemName = Z.IsPCUI and "main_dps_group_item_tpl_pc" or "main_dps_group_item_tpl"
  self.groupListView_ = loopList.new(self, self.groupLoopList_, groupItemClass, groupItemName)
  self.groupListView_:Init({})
  local infoItemClass = Z.IsPCUI and infoItemPc or infoItem
  local infoItemName = Z.IsPCUI and "main_dps_oneself_item_tpl_pc" or "main_dps_oneself_item_tpl"
  self.infoListView_ = loopList.new(self, self.infoLoopList_, infoItemClass, infoItemName)
  self.infoListView_:Init({})
  self.dpdNode_.dpd:SetIsIgnoreSubmitEvent(true)
  self.dpdNode_.dpd:ClearOptions()
  self.dpdNode_.dpd:AddListener(function(index)
    self.selectedDpdIndex_ = index + 1
    self:refrehDamagePanel()
  end)
  self.dpdNode_.dpd:AddOptions(self.showDpdLabs_)
  self.isOpenDes_ = self.dpsVm_.CheckIsDpsTrackerOn()
  self.time_ = 0
  if self.isOpenDes_ then
    Z.EventMgr:Add(Z.ConstValue.Damage.RefreshPanel, self.refrehDamagePanel, self)
  end
  self.emptyNode_.Ref.UIComp:SetVisible(not self.isOpenDes_)
  self.groupNode_.Ref.UIComp:SetVisible(self.isOpenDes_)
  self.uiBinder.Ref:SetVisible(self.resetBtn_, true)
  self.dpdNode_.Ref.UIComp:SetVisible(true)
  self.oneInfoNode_.Ref.UIComp:SetVisible(false)
  self:refrehDamagePanel()
end

function Main_dps_subView:setGroupItemList()
  local showGroupItemList = {}
  self.groupListView_:RefreshListView(showGroupItemList)
end

function Main_dps_subView:initData()
  self.showDpdLabs_ = Z.IsPCUI and dpdPcLabs or dpdLabs
  self.selectedDpdIndex_ = 1
  self.isStating_ = false
end

function Main_dps_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initBinders()
  self:initBtn()
  self:initData()
  self:initUi()
end

function Main_dps_subView:GetAllHit()
  return self.allHit_
end

function Main_dps_subView:GetCurShowType()
  return self.selectedDpdIndex_
end

function Main_dps_subView:refrehDamagePanel()
  local tab = {}
  if self.selectedDpdIndex_ == E.DpsDpdTypeList.Damage or self.selectedDpdIndex_ == E.DpsDpdTypeList.DamageSecond then
    tab = self.damageVm_.GetTeamDamageDataByType()
  elseif self.selectedDpdIndex_ == E.DpsDpdTypeList.Cure or self.selectedDpdIndex_ == E.DpsDpdTypeList.CureSecond then
    tab = self.damageVm_.GetTeamDamageDataByType(E.EDamageType.Heal)
  else
    tab = self.damageVm_.GetTeamTakeDmg()
  end
  self.allHit_ = 0
  local selectedInfoData
  if 0 < #tab then
    for key, damageInfos in pairs(tab) do
      if selectedInfoData == nil and self.selectedItemData_ and self.selectedItemData_.charId == damageInfos.charId then
        selectedInfoData = damageInfos
      end
      self.allHit_ = self.allHit_ + damageInfos.allHit
    end
    if selectedInfoData then
      self:OnClickGroupItem(selectedInfoData)
    end
    if self.isStating_ == false then
      self:beginTime()
    end
  end
  table.sort(tab, function(left, right)
    return left.allHit > right.allHit
  end)
  self.groupListView_:RefreshListView(tab)
end

function Main_dps_subView:GetCutSelectedItemAllHit()
  if self.selectedItemData_ then
    return self.selectedItemData_.allHit
  end
  return 0
end

function Main_dps_subView:OnClickGroupItem(data)
  self.selectedItemData_ = data
  self.groupNode_.Ref.UIComp:SetVisible(false)
  self.emptyNode_.Ref.UIComp:SetVisible(false)
  self.groupNode_.Ref:SetVisible(self.groupLoopList_, false)
  self.oneInfoNode_.Ref.UIComp:SetVisible(true)
  self.uiBinder.Ref:SetVisible(self.resetBtn_, false)
  self.dpdNode_.Ref.UIComp:SetVisible(false)
  local skillData = table.zvalues(data.skillData)
  table.sort(skillData, function(left, right)
    return left.hit > right.hit
  end)
  self.infoListView_:RefreshListView(skillData)
end

function Main_dps_subView:OnDeActive()
  if self.groupListView_ then
    self.groupListView_:UnInit()
    self.groupListView_ = nil
  end
  if self.infoListView_ then
    self.infoListView_:UnInit()
    self.infoListView_ = nil
  end
  if self.isOpenDes_ then
    Z.EventMgr:Remove(Z.ConstValue.Damage.RefreshPanel, self.refrehDamagePanel, self)
  end
  self.selectedItemData_ = nil
end

function Main_dps_subView:OnRefresh()
end

return Main_dps_subView
