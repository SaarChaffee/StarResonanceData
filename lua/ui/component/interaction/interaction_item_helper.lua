local normalPath = "ui/atlas/npc/talk_btn_bg_off"
local isShowContKyeIcon = function(unit, isShow)
  unit.Ref:SetVisible(unit.cont_key_icon.Ref, isShow)
end
local setSelectState = function(unit, isOn)
  unit.Ref:SetVisible(unit.cont_off, not isOn)
  unit.Ref:SetVisible(unit.cont_on, isOn)
end
local initInteractionItem = function(unit, contentStr, iconPath)
  contentStr = contentStr or ""
  iconPath = iconPath or "ui/atlas/npc/talk_icon_chat"
  isShowContKyeIcon(unit, false)
  unit.Ref.UIComp:SetVisible(true)
  setSelectState(unit, false)
  if unit.cont_pressdown then
    unit.Ref:SetVisible(unit.cont_pressdown, false)
  end
  unit.Ref:SetVisible(unit.cont_collecting, false)
  unit.img_icon:SetImage(iconPath)
  unit.img_bg_off:SetImage(normalPath)
  unit.lab_content.text = contentStr
end
local addCommonListener = function(unit)
  unit.btn_interaction.OnPointDownEvent:AddListener(function()
    if unit.cont_pressdown then
      unit.Ref:SetVisible(unit.cont_pressdown, true)
    end
  end)
  unit.btn_interaction.OnPointUpEvent:AddListener(function()
    if unit.cont_pressdown then
      unit.Ref:SetVisible(unit.cont_pressdown, false)
    end
  end)
end
local ret = {
  InitInteractionItem = initInteractionItem,
  AddCommonListener = addCommonListener,
  IsShowContKyeIcon = isShowContKyeIcon,
  SetSelectState = setSelectState
}
return ret
