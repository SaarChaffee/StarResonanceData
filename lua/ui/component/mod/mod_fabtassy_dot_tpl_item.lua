local ModFabtassyDotTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")

function ModFabtassyDotTplItem.RefreshTpl(uibinder, isEmpty, isSuccess, level, showLevel)
  if level then
    if isEmpty then
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.LevelEmpty)
    else
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.Level)
    end
    if showLevel and level then
      uibinder.lab_lv.text = Lang("Lv") .. level
      uibinder.Ref:SetVisible(uibinder.lab_lv, true)
    else
      uibinder.Ref:SetVisible(uibinder.lab_lv, false)
    end
    uibinder.img_dot:SetNativeSize()
    uibinder.Trans:SetWidth(uibinder.rect_dot.sizeDelta.x)
  else
    uibinder.Ref:SetVisible(uibinder.lab_lv, false)
    if isSuccess then
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.Success)
    elseif isEmpty then
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.Empty)
    else
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.Failed)
    end
    uibinder.img_dot:SetNativeSize()
    uibinder.Trans:SetWidth(uibinder.rect_dot.sizeDelta.x)
  end
end

return ModFabtassyDotTplItem
