local ModFabtassyDotTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")

function ModFabtassyDotTplItem.RefreshTpl(uibinder, isEmpty, isSuccess, level, showLevel, isNoSetSize)
  if level then
    if isEmpty then
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.LevelEmpty)
    else
      uibinder.img_dot:SetImage(MOD_DEFINE.SuccessTimesIcon.Level)
    end
    if showLevel and level then
      uibinder.lab_lv.text = Lang("Level", {val = level})
      uibinder.Ref:SetVisible(uibinder.lab_lv, true)
    else
      uibinder.Ref:SetVisible(uibinder.lab_lv, false)
    end
    if not isNoSetSize then
      uibinder.img_dot:SetNativeSize()
    end
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
    if not isNoSetSize then
      uibinder.img_dot:SetNativeSize()
    end
    uibinder.Trans:SetWidth(uibinder.rect_dot.sizeDelta.x)
  end
end

return ModFabtassyDotTplItem
