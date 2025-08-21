local super = require("ui.component.loop_list_view_item")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local HouseSetLoopItem = class("HouseSetLoopItem", super)

function HouseSetLoopItem:OnInit()
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.uiView_ = self.parent.UIView
  self.uiView_:AddClick(self.uiBinder.binder_head.img_bg, function()
  end)
end

function HouseSetLoopItem:OnRefresh(data)
  self.data_ = data
  if data.state == E.HouseSetOptionType.Member and data.cohabitantInfo.communityChar == nil then
    Z.CoroUtil.create_coro_xpcall(function()
      self.data_.cohabitantInfo.communityChar = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(self.data_.charId, self.uiView_.cancelSource:CreateToken())
      self:RefreshUI(self.data_)
    end)()
  else
    self:RefreshUI(self.data_)
  end
end

function HouseSetLoopItem:RefreshUI(data)
  local isMember = data.state == E.HouseSetOptionType.Member
  local isSet = data.state == E.HouseSetOptionType.Set
  local isApply = data.state == E.HouseSetOptionType.Apply
  if isSet then
    self.uiBinder.lab_display_off.text = Lang("HouseSetItemSet")
    self.uiBinder.lab_display_on.text = Lang("HouseSetItemSet")
  elseif isApply then
    self.uiBinder.lab_display_off.text = Lang("HouseSetItemApply")
    self.uiBinder.lab_display_on.text = Lang("HouseSetItemApply")
  else
    local name = data.cohabitantInfo.communityChar.basicData.name
    self.uiBinder.lab_name_off.text = name
    self.uiBinder.lab_name_on.text = name
    local isQuitCohabitant = false
    if data.cohabitantInfo.quitCohabitant ~= nil then
      local quitTime = data.cohabitantInfo.quitCohabitant.time
      if quitTime + Z.GlobalHome.HouseDivorceCountdown > Z.TimeTools.Now() / 1000 then
        isQuitCohabitant = true
      end
    end
    if isQuitCohabitant then
      local quitDesc = Z.RichTextHelper.ApplyColorTag(Lang("HouseNotCohabiting"), "#ff6300")
      self.uiBinder.lab_display_off.text = quitDesc
      self.uiBinder.lab_display_on.text = quitDesc
    else
      self.uiBinder.lab_display_off.text = ""
      self.uiBinder.lab_display_on.text = ""
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name_on, isMember)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name_off, isMember)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_set_off, isSet)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_set_on, isSet)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_info, isMember and self.houseData_:IsCharHomeOwner(data.charId))
  self.uiBinder.binder_head.Ref.UIComp:SetVisible(isMember)
  if isMember then
    PlayerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, data.cohabitantInfo.communityChar, function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_.charId, self.uiView_.cancelSource:CreateToken())
    end, self.uiView_.cancelSource:CreateToken())
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
end

function HouseSetLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not isSelected)
  if isSelected then
    self.uiView_:OnSelectedLeftTab(self.data_, self.Index)
  end
end

function HouseSetLoopItem:OnUnInit()
end

return HouseSetLoopItem
