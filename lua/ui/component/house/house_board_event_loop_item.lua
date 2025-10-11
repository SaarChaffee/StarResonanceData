local super = require("ui.component.loop_list_view_item")
local HouseBoardEventLoopItem = class("HouseBoardEventLoopItem", super)

function HouseBoardEventLoopItem:OnInit()
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.uiView_ = self.parent.UIView
  self.uiView_:AddClick(self.uiBinder.btn_chankan.btn, function()
    self.houseVm_.OpenHouseSetView({
      charId = self.selectedCharId_,
      type = E.HouseSetOptionType.Member
    })
  end)
end

function HouseBoardEventLoopItem:OnRefresh(data)
  self.uiBinder.btn_chankan.Ref.UIComp:SetVisible(true)
  self.uiBinder.lab_time.text = Z.TimeFormatTools.TicksFormatTime(data.time * 1000, E.TimeFormatType.YMD, false, true)
  Z.CoroUtil.create_coro_xpcall(function()
    self.selectedCharId_ = 0
    local str = ""
    local ownerCharId = self.houseData_:GetHomeOwnerCharId()
    local socialData = self.socialVm_.AsyncGetSocialDataTypeBasic(ownerCharId, self.uiView_.cancelSource:CreateToken())
    if socialData then
      if data.type == E.HouseBoardEventType.Quite then
        local communityPlayerInfo = data.communityPlayerInfo
        if communityPlayerInfo then
          local charSocialData = self.socialVm_.AsyncGetSocialDataTypeBasic(communityPlayerInfo.charId, self.uiView_.cancelSource:CreateToken())
          if charSocialData then
            self.selectedCharId_ = communityPlayerInfo.charId
            if communityPlayerInfo.isInitiativeQuit then
              str = Lang("CommunityBulletinBoard6", {
                val1 = charSocialData.basicData.name,
                val2 = socialData.basicData.name
              })
            else
              str = Lang("CommunityBulletinBoard6", {
                val2 = charSocialData.basicData.name,
                val1 = socialData.basicData.name
              })
            end
          end
        end
      elseif data.type == E.HouseBoardEventType.Transfer then
        local communityTransfer = data.communityTransfer
        if communityTransfer then
          local transferSocialData = self.socialVm_.AsyncGetSocialDataTypeBasic(communityTransfer.charId, self.uiView_.cancelSource:CreateToken())
          if transferSocialData then
            self.selectedCharId_ = communityTransfer.charId
            str = Lang("CommunityBulletinBoard0", {
              val1 = socialData.basicData.name,
              val2 = transferSocialData.basicData.name
            })
          end
        end
      end
    end
    self.uiBinder.lab_info.text = str
  end)()
end

function HouseBoardEventLoopItem:OnUnInit()
end

return HouseBoardEventLoopItem
