local super = require("ui.component.loop_list_view_item")
local UnionPositionMemberItem = class("UnionPositionMemberItem", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function UnionPositionMemberItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function UnionPositionMemberItem:OnInit()
  self.uiBinder.btn_modify:AddListener(function()
    self:onModifyBtnClick()
  end)
end

function UnionPositionMemberItem:OnRefresh(data)
  self.uiBinder.lab_name.text = data.socialData.basicData.name
  self.uiBinder.lab_gs.text = data.socialData.fightPoint or 0
  self.uiBinder.lab_position.text = self.unionVM_:GetOfficialName(data.baseData.officialId)
  local isPresident = data.baseData.officialId == E.UnionPositionDef.President
  local isShowBtn = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetMemberPosition) and not isPresident
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_modify, isShowBtn)
  if self.headItem_ then
    self.headItem_:UnInit()
  end
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, data.socialData, function()
    self:onHeadItemClick()
  end)
end

function UnionPositionMemberItem:OnUnInit()
  self.uiBinder.btn_modify:RemoveAllListeners()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
end

function UnionPositionMemberItem:onModifyBtnClick()
  local viewData = {}
  viewData.positionTrans = self.uiBinder.trans_position
  viewData.memberData = self:GetCurData()
  self.unionVM_:OpenAppointEditTipsView(viewData)
end

function UnionPositionMemberItem:onHeadItemClick()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(curData.socialData.basicData.charID, self.parent.UIView.cancelSource:CreateToken())
  end)()
end

return UnionPositionMemberItem
