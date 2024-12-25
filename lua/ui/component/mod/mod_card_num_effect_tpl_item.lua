local ModCardNumEffectTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function ModCardNumEffectTplItem.RefreshTpl(uibinder, isLock, effects)
  if isLock or effects == nil or #effects == 0 then
    uibinder.img_icon:SetColor(Color.New(1, 1, 1, 0.2))
  else
    uibinder.img_icon:SetColor(Color.New(1, 1, 1, 1))
  end
  if isLock then
    uibinder.Ref:SetVisible(uibinder.group_lock, true)
    uibinder.Ref:SetVisible(uibinder.lab_unactivat, false)
  else
    uibinder.Ref:SetVisible(uibinder.group_lock, false)
    uibinder.Ref:SetVisible(uibinder.lab_unactivat, #effects == 0)
  end
  local showEffects = {}
  if effects then
    showEffects = effects
  end
  for i = 1, MOD_DEFINE.ModEffectMaxCount do
    local effect = showEffects[i]
    local img = uibinder["img_" .. i]
    if effect then
      uibinder.Ref:SetVisible(img, true)
      uibinder["lab_num_" .. i].text = effect.level
      ModGlossaryItemTplItem.RefreshTpl(uibinder["glossary_item_" .. i], effect.effectId, effect.level)
    else
      uibinder.Ref:SetVisible(img, false)
    end
  end
end

return ModCardNumEffectTplItem
