local super = require("ui.component.loop_list_view_item")
local HouseBoardLogLoopItem = class("HouseBoardLogLoopItem", super)

function HouseBoardLogLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
end

function HouseBoardLogLoopItem:OnRefresh(data)
  self.uiBinder.btn_chankan.Ref.UIComp:SetVisible(false)
  self.uiBinder.lab_time.text = Z.TimeFormatTools.TicksFormatTime(data.time * 1000, E.TimeFormatType.YMD, false, true)
  local values = {}
  if data.operatorChar then
    values.val1 = data.operatorChar.charBasicData.basicData.name
  end
  if data.targetChar then
    values.val2 = data.targetChar.charBasicData.basicData.name
  end
  local type = data.type
  if data.type == E.HouseBoardType.PlayerAuthority then
    local authorityType = tonumber(data.content[1])
    if authorityType == E.HousePlayerLimitType.FurnitureEdit then
      values.val3 = Lang("HouseLimitFurnitureEdit")
    elseif authorityType == E.HousePlayerLimitType.FurnitureMake then
      values.val3 = Lang("HouseLimitFurnitureMake")
    end
    local isOpen = data.content[2]
    if isOpen == "True" then
      values.val4 = Lang("CanEditor")
    else
      values.val4 = Lang("NotEditor")
    end
  elseif data.type == E.HouseBoardType.Authority then
    local authorityType = tonumber(data.content[1])
    if authorityType == E.HouseLimitType.WareHouse then
      local isOpen = data.content[2]
      if isOpen ~= "True" then
        type = 13
      end
    end
  end
  self.uiBinder.lab_info.text = Lang("CommunityBulletinBoard" .. type, values)
end

function HouseBoardLogLoopItem:OnUnInit()
end

return HouseBoardLogLoopItem
