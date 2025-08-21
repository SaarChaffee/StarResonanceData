local UI = Z.UI
local super = require("ui.ui_view_base")
local House_invitation_letter_popupView = class("House_invitation_letter_popupView", super)
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function House_invitation_letter_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_invitation_letter_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function House_invitation_letter_popupView:initUiBinders()
  self.leftBtn_ = self.uiBinder.btn_left
  self.rightBtn_ = self.uiBinder.btn_right
  self.leftLab_ = self.uiBinder.lab_left
  self.rightLab_ = self.uiBinder.lab_right
  self.headNode_ = self.uiBinder.node_head
  self.headBinder_ = self.uiBinder.com_head_51_item
  self.infoInput_ = self.uiBinder.input_info
  self.infoLab_ = self.uiBinder.lab_info
  self.nameLab_ = self.uiBinder.lab_name
  self.haveNode_ = self.uiBinder.lab_have_house
  self.nodeInfo_ = self.uiBinder.node_info
  self.press_ = self.uiBinder.node_press
  self.sceneMask_ = self.uiBinder.scene_mask
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function House_invitation_letter_popupView:initUi()
  self.leftLab_.text = not self.isRedact_ and Lang("Reject") or Lang("close")
  self.rightLab_.text = not self.isRedact_ and Lang("Accept") or Lang("Save")
  self.haveNode_.text = Lang("HouseInvitationTips")
  self.haveNode_:AddListener(function()
    self.houseVm_.OpenAnnouncementsLink()
  end)
  self.nameLab_.text = self.applyInfo_.charBasicData.basicData.name
  self.uiBinder.Ref:SetVisible(self.infoInput_, self.isRedact_)
  self.uiBinder.Ref:SetVisible(self.infoLab_, not self.isRedact_)
  self.uiBinder.Ref:SetVisible(self.haveNode_, not self.isRedact_ and self.isHaveHouse_)
  self.uiBinder.Ref:SetVisible(self.headNode_, not self.isRedact_)
  self.uiBinder.Ref:SetVisible(self.nodeInfo_, not self.isRedact_)
  PlayerPortraitHgr.InsertNewPortraitBySocialData(self.headBinder_, self.applyInfo_.charBasicData, nil, self.cancelSource:CreateToken())
  self:asyncGetCheckInContent()
end

function House_invitation_letter_popupView:asyncGetCheckInContent()
  Z.CoroUtil.create_coro_xpcall(function()
    local checkInContent = self.houseVm_.AsyncGetHomelandCheckInContent(self.applyInfo_.communityId, self.applyInfo_.homeId, self.cancelSource:CreateToken())
    self.infoLab_.text = checkInContent ~= "" and checkInContent or Lang("HouseDefaultInvitation")
  end)()
end

function House_invitation_letter_popupView:initData()
  self.isRedact_ = self.viewData.isRedact
  self.applyInfo_ = self.viewData.applyInfo
  self.isHaveHouse_ = self.houseData_:GetHomeId() ~= 0
end

function House_invitation_letter_popupView:initBtns()
  self:AddAsyncClick(self.leftBtn_, function()
    if self.isRedact_ then
    else
      self.houseVm_.AsyncAcceptRejectInvitation(self.applyInfo_.charId, self.applyInfo_.homeId, false, self.cancelSource:CreateToken())
    end
    self.houseVm_.CloseHouseInvitationLetterView()
  end)
  self:AddAsyncClick(self.rightBtn_, function()
    if self.isRedact_ then
    elseif self.isHaveHouse_ then
      self.houseVm_.OpenAnnouncements(function(cancelToken)
        self.houseVm_.AsyncAcceptRejectInvitation(self.applyInfo_.charId, self.applyInfo_.homeId, true, cancelToken)
      end)
    else
      self.houseVm_.AsyncAcceptRejectInvitation(self.applyInfo_.charId, self.applyInfo_.homeId, true, self.cancelSource:CreateToken())
    end
    self.houseVm_.CloseHouseInvitationLetterView()
  end)
  self:EventAddAsyncListener(self.press_.ContainGoEvent, function(isContainer)
    if not isContainer then
      self.houseVm_.CloseHouseInvitationLetterView()
    end
  end)
end

function House_invitation_letter_popupView:OnActive()
  self:initUiBinders()
  self:initData()
  self:initBtns()
  self:initUi()
end

function House_invitation_letter_popupView:OnDeActive()
end

function House_invitation_letter_popupView:OnRefresh()
end

return House_invitation_letter_popupView
