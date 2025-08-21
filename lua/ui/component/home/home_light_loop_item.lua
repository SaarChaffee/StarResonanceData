local super = require("ui.component.loop_list_view_item")
local HomeLightLoopItem = class("HomeLightLoopItem", super)

function HomeLightLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.stateSwitch_ = self.uiBinder.switch_state
  self.canvasRoot_ = self.uiBinder.canvas_root
  self.editBtn_ = self.uiBinder.btn_edit
  self.iconImg_ = self.uiBinder.rimg_icon
  self.nameLab_ = self.uiBinder.lab_name
  self.homeEditorVm_ = Z.VMMgr.GetVM("home_editor")
  self.uiView_:AddAsyncClick(self.stateSwitch_, function(isOn)
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    local state = isOn and E.HomelandLamplightState.HomelandLamplightStateOn or E.HomelandLamplightState.HomelandLamplightStateOff
    self.data_.state = state
    local ret = self.homeEditorVm_.AsyncSwitchLamplight(self.data_.uuid, state)
    if ret ~= 0 then
      self.stateSwitch_:SetStateWithoutNotifyInstant(not isOn)
    end
  end)
  self.uiView_:AddClick(self.editBtn_, function()
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    local name = self.data_.name
    local data = {
      title = Lang("HouseEditLampName"),
      inputContent = name,
      onConfirm = function(value)
        if value == "" or value == name then
          return
        end
        self.homeEditorVm_.AsyncSetFurnitureName(self.data_.uuid, value, self.uiView_.cancelSource:CreateToken())
      end,
      stringLengthLimitNum = Z.GlobalHome.LightNameLimit,
      inputDesc = ""
    }
    Z.TipsVM.OpenCommonPopupInput(data)
  end)
end

function HomeLightLoopItem:OnRefresh(data)
  self.data_ = data
  self.nameLab_.text = data.name
  self.iconImg_:SetImage(data.icon)
  local isOn = false
  if data.state ~= nil then
    local stateEnum = data.state:ToInt()
    if stateEnum == E.HomelandLamplightState.HomelandLamplightStateOn or stateEnum == E.HomelandLamplightState.HomelandLamplightStateDefault then
      isOn = true
    end
  end
  self.stateSwitch_:SetStateWithoutNotifyInstant(isOn)
  self.stateSwitch_.IsDisabled = not self.houseData_:CheckPlayerFurnitureEditLimit()
  self.canvasRoot_.alpha = self.stateSwitch_.IsDisabled and 0.5 or 1
end

function HomeLightLoopItem:OnPointerClick(go, eventData)
end

function HomeLightLoopItem:OnUnInit()
end

return HomeLightLoopItem
