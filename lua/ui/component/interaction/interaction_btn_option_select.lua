local super = require("ui.component.interaction.interaction_btn_base")
local InteractionBtnOptionSelect = class("InteractionBtnOptionSelect", super)

function InteractionBtnOptionSelect:AsyncInit(uiData, btnType)
  self.interactionBtnType_ = btnType
  local data = string.zsplit(uiData.triggerData, "=")
  local btnId = tonumber(data[1])
  self.params_ = data[2]
  local interBtnCfg = Z.TableMgr.GetTable("InteractBtnTableMgr").GetRow(btnId)
  if interBtnCfg == nil then
    logError("interBtnCfg not found, templateId={0}", self.templateId_)
    return
  end
  self.unitContentStr_ = interBtnCfg.Name
  self.unitIcon_ = interBtnCfg.IconPath
  self.unitName_ = string.zconcat("OptionSelect", btnId)
  return true
end

function InteractionBtnOptionSelect:GetNew()
  return false
end

function InteractionBtnOptionSelect:OnBtnClick(cancelSource)
  local interactionVm = Z.VMMgr.GetVM("interaction")
  interactionVm.AsyncUserOptionSelect(self.params_, cancelSource:CreateToken())
end

return InteractionBtnOptionSelect
