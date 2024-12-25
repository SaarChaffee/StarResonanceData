local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_model_anim_subView = class("Personalzone_model_anim_subView", super)
local DEFINE = require("ui.model.personalzone_define")
local loopScrollRect_ = require("ui/component/loopscrollrect")
local tagItem = require("ui.component.personalzone.personalzone_main_bg_item")

function Personalzone_model_anim_subView:ctor(parent)
  self.panel = nil
  self.viewData = nil
  self.parent_ = parent
  super.ctor(self, "personalzone_model_anim_sub", "personalzone/personalzone_model_anim_sub", UI.ECacheLv.None)
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
end

function Personalzone_model_anim_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_update, function()
    Z.TipsVM.ShowTipsLang(1002102)
  end)
  self:AddAsyncClick(self.uiBinder.btn_save, function()
    Z.TipsVM.ShowTipsLang(1002103)
  end)
  self.bgScrollRect_ = loopScrollRect_.new(self.uiBinder.loopscroll_bg_item, self, tagItem)
  self:initTogs()
end

function Personalzone_model_anim_subView:OnDeActive()
end

function Personalzone_model_anim_subView:initTogs()
  self.togUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = self.uiBinder.ui_cash:GetString("cont_togs")
    for key, func in ipairs(DEFINE.ModelAnimFunctionId) do
      local unitName = "togs_" .. func.funcId
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.togs)
      if unit then
        unit.img_icon_ash:SetImage(func.icon)
        unit.img_icon:SetImage(func.icon)
        unit.Ref:SetVisible(unit.img_line, false)
        unit.Ref:SetVisible(unit.group_no_active, false)
        unit.Ref:SetVisible(unit.group_active, false)
        unit.tog_function.group = self.uiBinder.node_toggle
        self:AddClick(unit.tog_function, function()
          self:changeTag(func.funcId)
        end)
        unit.tog_function.isOn = false
        self.togUnits_[key] = unit
      end
    end
    self.togUnits_[1].tog_function.isOn = true
  end)()
end

function Personalzone_model_anim_subView:changeTag()
end

return Personalzone_model_anim_subView
