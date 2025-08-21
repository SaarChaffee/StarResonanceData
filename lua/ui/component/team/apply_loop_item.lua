local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local playerPortraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local ApplyItem = class("ApplyItem", super)

function ApplyItem:ctor()
end

function ApplyItem:OnInit()
  self:AddAsyncClick(self.uiBinder.btn_accept, function()
    self.teamVm_.AsyncDealApplyJoin(self.data_.charId, true, self.parent.uiView.cancelSource:CreateToken())
    self:refreshList(self.index_)
    local unitName = string.zconcat(E.InvitationTipsType.TeamRequest, "_", self.data_.charId, "_", Lang("RequestJoinTeam"))
    Z.EventMgr:Dispatch(Z.ConstValue.InvitationClearTipsUnit, unitName)
  end)
  self:AddAsyncClick(self.uiBinder.btn_refuse, function()
    self.teamVm_.AsyncDealApplyJoin(self.data_.charId, false, self.parent.uiView.cancelSource:CreateToken())
    self:refreshList(self.index_)
    local unitName = string.zconcat(E.InvitationTipsType.TeamRequest, "_", self.data_.charId, "_", Lang("RequestJoinTeam"))
    Z.EventMgr:Dispatch(Z.ConstValue.InvitationClearTipsUnit, unitName)
  end)
  self:AddAsyncClick(self.uiBinder.btn_head, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.charId, self.parent.uiView.cancelSource:CreateToken())
  end)
end

function ApplyItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  local basicData = self.data_.userSummaryData.basicData
  self.uiBinder.lab_name.text = basicData.name
  self.uiBinder.lab_gs.text = self.data_.userSummaryData.fightPoint
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.modelId_ = Z.ModelManager:GetModelIdByGenderAndSize(basicData.gender, basicData.bodySize)
  local avatarInfo = self.data_.userSummaryData.avatarInfo
  local viewData = {
    id = avatarInfo.avatarId,
    modelId = self.modelId_,
    charId = self.data_.charId,
    token = self.parent.uiView.cancelSource:CreateToken()
  }
  playerPortraitMgr.InsertNewPortrait(self.uiBinder.node_head, viewData)
  local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.data_.userSummaryData.professionData.professionId)
  if professionSystemTableRow then
    self.uiBinder.img_icon:SetImage(professionSystemTableRow.Icon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
  end
end

function ApplyItem:refreshList(index)
  self.parent.uiView:ReomveScrollData(index)
end

function ApplyItem:OnBeforePlayAnim()
end

function ApplyItem:OnUnInit()
end

return ApplyItem
