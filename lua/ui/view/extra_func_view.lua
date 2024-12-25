local UI = Z.UI
local super = require("ui.ui_subview_base")
local Extra_funcView = class("Extra_funcView", super)
local sceneLayerBtnUnit_ = require("ui.uiunit.scene_layer_btn_unit")

function Extra_funcView:ctor(parent)
  self.panel = nil
  super.ctor(self, "extra_func_tpl", "extrafunc/extra_func_tpl", UI.ECacheLv.None, parent)
  self.sceneLayerBtnUnit = sceneLayerBtnUnit_.new()
end

function Extra_funcView:OnActive()
  self:BindLuaAttrWatchers()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
end

function Extra_funcView:OnDeActive()
  self.sceneLayerBtnUnit:UnInit()
end

function Extra_funcView:UpdateSceneLayerBtnVisible()
  self.canSwitchLayer_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCanSwitchLayer")).Value
  self.sceneLayerBtnUnit:UnInit()
  if self.canSwitchLayer_ == 1 then
    self.sceneLayerBtnUnit:Init(self, self.panel)
  end
end

function Extra_funcView:BindLuaAttrWatchers()
  self.sceneLayerVisibleWatcher = self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrCanSwitchLayer")
  }, Z.EntityMgr.PlayerEnt, self.UpdateSceneLayerBtnVisible)
end

return Extra_funcView
