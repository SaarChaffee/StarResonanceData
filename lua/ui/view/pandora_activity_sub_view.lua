local UI = Z.UI
local super = require("ui.ui_subview_base")
local Pandora_activity_subView = class("Pandora_activity_subView", super)
local PANDORA_DEFINE = require("ui.model.pandora_define")

function Pandora_activity_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "pandora_activity_sub", "pandora/pandora_activity_sub", UI.ECacheLv.None)
  self.parent_ = parent
end

function Pandora_activity_subView:OnActive()
  local transLayer = Z.UIRoot:GetLayerTrans(self.parent_.uiLayer)
  self.uiBinder.Trans:SetOffsetMin(-transLayer.offsetMin.x, 0)
  self.uiBinder.Trans:SetOffsetMax(-transLayer.offsetMax.x, 0)
  self:bindEvents()
  self:initData()
  self.pandoraVM_:OpenPandoraAppByAppId(PANDORA_DEFINE.APP_ID.Activity)
end

function Pandora_activity_subView:OnDeActive()
  self:unBindEvents()
  self.pandoraVM_:ClosePandoraAppByAppId(PANDORA_DEFINE.APP_ID.Activity)
end

function Pandora_activity_subView:OnRefresh()
end

function Pandora_activity_subView:initData()
  self.pandoraData_ = Z.DataMgr.Get("pandora_data")
  self.pandoraVM_ = Z.VMMgr.GetVM("pandora")
end

function Pandora_activity_subView:bindEvents()
  Z.EventMgr:Add(PANDORA_DEFINE.EventName.ViewCreate, self.onPandoraViewCreate, self)
end

function Pandora_activity_subView:unBindEvents()
  Z.EventMgr:Remove(PANDORA_DEFINE.EventName.ViewCreate, self.onPandoraViewCreate, self)
end

function Pandora_activity_subView:onPandoraViewCreate(appId, extraInfo)
  if appId and (appId == PANDORA_DEFINE.APP_ID.Activity or self.pandoraVM_:CheckIsBelongToActivity(extraInfo)) then
    local go = self.pandoraData_:GetAppResource(appId)
    if go == nil then
      return
    end
    local targetNode = self.uiBinder.node_content
    if extraInfo ~= nil and extraInfo.windowConfig ~= nil and extraInfo.windowConfig.parameter ~= nil and extraInfo.windowConfig.parameter.containerType ~= nil then
      local containerType = math.floor(extraInfo.windowConfig.parameter.containerType)
      if containerType == 0 then
        targetNode = self.uiBinder.node_content
      elseif containerType == 1 then
        targetNode = self.uiBinder.node_tab
      elseif containerType == 2 then
        targetNode = self.uiBinder.node_popup
      end
    end
    Z.UIRoot:SetLayerTrans(go, self.parent_.uiLayer)
    Panda.Utility.ZLayerUtils.SetLayerRecursive(go.transform, Panda.Utility.ZLayerUtils.LAYER_UI)
    Z.UIRoot:ResetSubViewTrans(go, targetNode)
    go.transform:SetOffsetMin(0, 0)
    go.transform:SetOffsetMax(0, 0)
  end
end

function Pandora_activity_subView:GetActivityId()
  return nil
end

return Pandora_activity_subView
