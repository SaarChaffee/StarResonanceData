local super = require("ui.component.interaction.interaction_btn_base")
local InteractionBtnStaticObj = class("InteractionBtnStaticObj", super)

function InteractionBtnStaticObj:AsyncInit(uiData)
  super.AsyncInit(self, uiData)
  local ids = string.zsplit(uiData.triggerData, "|")
  self.objId_ = tonumber(ids[1])
  self.posId_ = tonumber(ids[2])
  return true
end

function InteractionBtnStaticObj:OnBtnClick(cancelSource)
  Z.InteractionMgr:BeginStaticInteraction(self.objId_, self.posId_)
end

return InteractionBtnStaticObj
