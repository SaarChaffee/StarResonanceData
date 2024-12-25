local super = require("ui.component.loopscrollrectitem")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local UnionMemberListItem = class("UnionMemberListItem", super)

function UnionMemberListItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function UnionMemberListItem:OnInit()
  self:Selected(false)
end

function UnionMemberListItem:OnReset()
end

function UnionMemberListItem:OnUnInit()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
end

function UnionMemberListItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self:SetUI(self.data_)
end

function UnionMemberListItem:SetUI(data)
  local basicData = data.socialData.basicData
  local positionName = self.unionVM_:GetOfficialName(data.baseData.officialId)
  self.uiBinder.lab_name_select.text = basicData.name
  self.uiBinder.lab_posts_select.text = positionName
  self.uiBinder.lab_grade_select.text = basicData.level
  self.uiBinder.lab_active_select.text = data.baseData.weekActivePoints .. "/" .. data.baseData.historyActivePoints
  self.uiBinder.lab_state_select.text = self.unionVM_:GetLastTimeDesignText(basicData.offlineTime)
  if basicData.offlineTime == 0 then
    self.uiBinder.img_icon_state:SetImage(Z.ConstValue.UnionRes.StateOnIcon)
  else
    self.uiBinder.img_icon_state:SetImage(Z.ConstValue.UnionRes.StateOffIcon)
  end
  if self.headItem_ then
    self.headItem_:UnInit()
  end
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.bind_head, data.socialData, function()
    self:onItemClick()
  end)
end

function UnionMemberListItem:Selected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function UnionMemberListItem:OnPointerClick(go, eventData)
  self:onItemClick()
end

function UnionMemberListItem:onItemClick()
  Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.socialData.basicData.charID, self.parent.uiView.cancelSource:CreateToken())
  end)()
end

return UnionMemberListItem
