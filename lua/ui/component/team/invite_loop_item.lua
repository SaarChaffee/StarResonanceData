local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local InviteItem = class("InviteItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function InviteItem:ctor()
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.friendsMainVM_ = Z.VMMgr.GetVM("friends_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function InviteItem:OnInit()
end

function InviteItem:Refresh()
  local index = self.component.Index + 1
  self.charId_ = self.parent:GetDataByIndex(index)
  if self.charId_ == nil then
    return
  end
  self.uiBinder.lab_name.text = ""
  self.uiBinder.lab_gs.text = ""
  local socialData = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(self.charId_, self.parent.uiView.cancelSource:CreateToken())
  if not socialData then
    return
  end
  self.uiBinder.lab_name.text = socialData.basicData.name
  self.uiBinder.lab_gs.text = Lang("LvFormatSymbol", {
    val = socialData.basicData.level
  })
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.cont_popup, socialData, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.charId_, self.parent.uiView.cancelSource:CreateToken())
  end)
  local isInvite = self.teamData_:GetTeamInviteStatus(self.charId_)
  self.btnCanClick_ = not isInvite
  self:AddAsyncClick(self.uiBinder.btn_invite, function()
    if self.btnCanClick_ == true then
      self.btnCanClick_ = false
      if self.teamData_.TeamInfo.members[self.charId_] then
        Z.TipsVM.ShowTipsLang(1000623)
        return
      end
      local members = self.teamVM_.GetTeamMemData()
      if #members == 4 then
        Z.TipsVM.ShowTipsLang(1000619)
        return
      end
      self.teamVM_.AsyncInviteToTeam(self.charId_, self.parent.uiView.cancelSource:CreateToken())
    end
  end)
end

function InviteItem:refreshBtnInteractable(refreshCharId)
  if refreshCharId and refreshCharId ~= self.charId_ then
    return
  end
  local isInvite = self.teamData_:GetTeamInviteStatus(self.charId_)
  self.uiBinder.btn_invite.interactable = not isInvite
  self.btnCanClick_ = not isInvite
  self.uiBinder.btn_invite.IsDisabled = isInvite
end

function InviteItem:OnBeforePlayAnim()
  self.uiBinder.anim.OnPlay:AddListener(function()
    self.uiBinder.Ref.UIComp:SetVisible(true)
  end)
  local groupAnimComp = self.parent:GetContainerGroupAnimComp()
  if groupAnimComp then
    groupAnimComp:AddTweenContainer(self.uiBinder.anim)
    self.uiBinder.Ref.UIComp:SetVisible(false)
  end
end

function InviteItem:OnUnInit()
end

return InviteItem
