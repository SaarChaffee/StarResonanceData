local super = require("ui.component.loop_list_view_item")
local HouseLimitLangDict = {
  [E.HouseLimitType.WareHouse] = "HouseLimitWareHouse"
}
local HousePlayerLimitLangDict = {
  [E.HousePlayerLimitType.FurnitureEdit] = "HouseLimitFurnitureEdit",
  [E.HousePlayerLimitType.FurnitureMake] = "HouseLimitFurnitureMake",
  [E.HousePlayerLimitType.Production] = "HouseLimitProduction",
  [E.HousePlayerLimitType.Plant] = "HouseLimitPlant"
}
local HouseSwitchLoopItem = class("HouseSwitchLoopItem", super)

function HouseSwitchLoopItem:OnInit()
  self.data_ = nil
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.uiView_ = self.parent.UIView
  if self.houseData_:IsHomeOwner() then
    self.uiView_:AddAsyncClick(self.uiBinder.switch, function(isOn)
      if self.data_.limitType then
        self.houseVm_.AsyncSetAuthority(self.data_.limitType, isOn, self.uiView_.cancelSource:CreateToken())
      else
        self.houseVm_.AsyncSetPlayerAuthority(self.data_.charId, self.data_.playerLimitType, isOn, self.uiView_.cancelSource:CreateToken())
      end
    end)
  else
    self.uiBinder.switch.IsDisabled = true
    self.uiBinder.canvas_root.alpha = 0.5
  end
end

function HouseSwitchLoopItem:OnRefresh(data)
  self.data_ = data
  if data.playerLimitType then
    self.uiBinder.lab_desc.text = Lang(HousePlayerLimitLangDict[data.playerLimitType])
  else
    self.uiBinder.lab_desc.text = Lang(HouseLimitLangDict[data.limitType])
  end
  if self.uiBinder.switch.IsOn ~= data.value then
    self.uiBinder.switch:SetIsOnWithoutNotify(data.value)
  end
end

function HouseSwitchLoopItem:OnUnInit()
end

return HouseSwitchLoopItem
