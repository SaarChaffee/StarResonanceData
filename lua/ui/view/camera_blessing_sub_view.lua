local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_blessing_subView = class("Camera_blessing_subView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local camera_invited_item_ = require("ui/component/camerasys/camera_invited_item")
local CameraDisbandTeamKey = "CameraDisbandTeam"
local SDKDefine = require("ui.model.sdk_define")

function Camera_blessing_subView:ctor(parent)
  self.uiBinder = nil
  self.parent = parent
  super.ctor(self, "camera_blessing_sub", "photograph/camera_blessing_sub", UI.ECacheLv.None)
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
end

function Camera_blessing_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initBtn()
  self:bindEvents()
  self.itemsScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_item, camera_invited_item_, "camera_invited_item_tpl")
  self.itemsScrollRect_:Init({})
  self:refreshLoopList()
  self:setDisbandTeam()
  self:setLabTitle()
  local isUnlock = self.gotoFuncVM_.FuncIsOn(E.FunctionID.TencentWechatOriginalShare, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, isUnlock and not Z.GameContext.IsPC and not Z.SDKDevices.IsCloudGame)
  self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_share.group_press_check:StopCheck()
end

function Camera_blessing_subView:setDisbandTeam()
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, CameraDisbandTeamKey) then
    local isDisbandTeam = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, CameraDisbandTeamKey, false)
    self.uiBinder.tog_disband_team.isOn = isDisbandTeam
  end
end

function Camera_blessing_subView:getSelectIndex()
  local index = 1
  if self.memberData_ or #self.memberData_ > 0 then
    for k, v in pairs(self.memberData_) do
      if v.info.charId == self.cameraMemberData_:GetSelectMemberCharId() then
        return k - 1
      end
    end
  end
  return index
end

function Camera_blessing_subView:OnDeActive()
  self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
  self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_moments.gameObject)
  self.uiBinder.node_share.group_press_check:StopCheck()
  self.itemsScrollRect_:UnInit()
  self:removeEvents()
  self.itemsScrollRect_ = nil
  self.parent:setLeftNodeIsShow(true)
end

function Camera_blessing_subView:OnRefresh()
  local index = self:getSelectIndex()
  self.itemsScrollRect_:SelectIndex(index)
end

function Camera_blessing_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.CameraMember.CameraMemberListUpdate, self.refreshLoopList, self)
  Z.EventMgr:Add(Z.ConstValue.CameraMember.CameraMemberDataUpdate, self.updateMemberData, self)
end

function Camera_blessing_subView:removeEvents()
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.CameraMemberListUpdate, self.refreshLoopList, self)
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.CameraMemberDataUpdate, self.updateMemberData, self)
end

function Camera_blessing_subView:initBtn()
  self:AddClick(self.uiBinder.btn_add, function()
    Z.UIMgr:OpenView("camera_invited_photo_popup")
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    self:DeActive()
  end)
  self.uiBinder.tog_disband_team:AddListener(function(isOn)
    self.cameraMemberVM_:SetDisbandTeam(isOn)
  end)
  self:AddClick(self.uiBinder.btn_share, function()
    self.uiBinder.node_share.Ref.UIComp:SetVisible(true)
    self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
    self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_moments.gameObject)
    self.uiBinder.node_share.group_press_check:StartCheck()
  end)
  self:EventAddAsyncListener(self.uiBinder.node_share.group_press_check.ContainGoEvent, function(isContain)
    if not isContain then
      self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
      self.uiBinder.node_share.group_press_check:StopCheck()
    end
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.node_share.btn_wechat, function()
    self.sdkVM_.SDKOriginalShare({
      SDKDefine.ORIGINAL_SHARE_FUNCTION_TYPE.PhotoTogether,
      false
    })
  end)
  self:AddAsyncClick(self.uiBinder.node_share.btn_moments, function()
    self.sdkVM_.SDKOriginalShare({
      SDKDefine.ORIGINAL_SHARE_FUNCTION_TYPE.PhotoTogether,
      true
    })
  end)
end

function Camera_blessing_subView:refreshLoopList()
  self.memberData_ = self.cameraMemberData_:AssemblyMemberListData(true)
  self.itemsScrollRect_:RefreshListView(self.memberData_)
  self:setLabTitle()
end

function Camera_blessing_subView:updateMemberData(loopIndex, charId)
  local memberData = self.cameraMemberData_:GetMemberDataByCharId(charId)
  if not memberData then
    return
  end
  local memberInfo = {info = memberData, isShowRefreshBtn = true}
  self.itemsScrollRect_:RefreshDataByIndex(loopIndex, memberInfo)
  self.itemsScrollRect_:RefreshItemByItemIndex(loopIndex)
end

function Camera_blessing_subView:OnSelectedItem()
  if self.itemsScrollRect_ and #self.itemsScrollRect_:GetData() > 0 then
    self.itemsScrollRect_:ClearAllSelect()
    self.itemsScrollRect_:SelectIndex(0)
  end
end

function Camera_blessing_subView:setLabTitle()
  local cur = #self.memberData_
  local limit = Z.IsPCUI and Z.Global.PhotographTeamMemberLimit[1] or Z.Global.PhotographTeamMemberLimit[2]
  self.uiBinder.lab_blessing_item.text = Lang("PhotoTeamMemberCount", {val1 = cur, val2 = limit})
end

return Camera_blessing_subView
