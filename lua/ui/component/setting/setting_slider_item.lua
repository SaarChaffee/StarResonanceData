local SettingSliderItem = class("SettingSliderItem")

function SettingSliderItem:ctor()
  self.slider_ = nil
  self.lab_ = nil
  self.settingId_ = nil
  self.settingVm_ = Z.VMMgr.GetVM("setting")
  self.onEndDrag_ = nil
end

function SettingSliderItem:Init(slider, lab, settingId, min, max, curValue, labUseInt)
  self.slider_ = slider
  self.lab_ = lab
  self.settingId_ = settingId
  if slider then
    slider.minValue = min
    slider.maxValue = max
    local value = settingId and self.settingVm_.Get(settingId) or curValue
    value = Mathf.Clamp(value, min, max)
    slider.value = value
    if lab then
      lab.text = labUseInt and math.floor(value) or value
    end
    slider:AddListener(function(v)
      if lab then
        lab.text = labUseInt and math.floor(v) or v
      end
    end)
    slider:AddDragEndListener(function()
      if settingId then
        self.settingVm_.Set(settingId, slider.value)
      end
      if self.onEndDrag_ then
        self.onEndDrag_()
      end
    end)
  end
end

function SettingSliderItem:SetExOnEndDrag(action)
  self.onEndDrag_ = action
end

return SettingSliderItem
