local super = require("ui.component.loop_list_view_item")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local HouseApplyLoopItem = class("HouseApplyLoopItem", super)

function HouseApplyLoopItem:OnInit()
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.uiView_ = self.parent.UIView
  self.uiView_:AddAsyncClick(self.uiBinder.btn_square_new.btn, function()
    local viewData = {
      applyInfo = self.data_,
      isRedact = false
    }
    self.houseVm_.OpenHouseInvitationLetterView(viewData)
  end)
end

function HouseApplyLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_player_name.text = data.charBasicData.basicData.name
  PlayerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.com_head_51_item, {
    avatarInfo = data.charBasicData.avatarInfo,
    basicData = data.charBasicData.basicData,
    professionData = data.charBasicData.professionData
  }, nil, self.uiView_.cancelSource:CreateToken())
  Z.CoroUtil.create_coro_xpcall(function()
    local str = self.houseVm_.AsyncGetHomelandCheckInContent(data.communityId, data.homeId, self.uiView_.cancelSource:CreateToken())
    self.uiBinder.lab_info.text = str == "" and Lang("HouseDefaultInvitation") or str
  end)()
end

function HouseApplyLoopItem:OnUnInit()
end

return HouseApplyLoopItem
