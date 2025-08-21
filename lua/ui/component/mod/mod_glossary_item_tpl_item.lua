local ModGlossaryItemTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")

function ModGlossaryItemTplItem.RefreshTpl(uibinder, effectId)
  local modData = Z.DataMgr.Get("mod_data")
  local config = modData:GetEffectTableConfig(effectId, 0)
  if config then
    uibinder.img_frame:SetImage(config.EffectConfigIcon)
  end
end

return ModGlossaryItemTplItem
