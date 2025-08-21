local ChemistryItemTpl = {}
local chemistryDefine = require("ui.model.chemistry_define")

function ChemistryItemTpl.RefreshTpl(uibinder, configId, config)
  if config == nil then
    config = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(configId)
  end
  if config == nil then
    return
  end
  uibinder.img_quality:SetImage(chemistryDefine.MaterialQualityPath .. config.Quality)
  local itemsVM = Z.VMMgr.GetVM("items")
  local icon = itemsVM.GetItemIcon(config.RelatedItemId)
  uibinder.rimg_icon:SetImage(icon)
  uibinder.lab_content.text = config.Name
end

return ChemistryItemTpl
