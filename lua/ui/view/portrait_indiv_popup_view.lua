local UI = Z.UI
local super = require("ui.ui_view_base")
local Portrait_indiv_popupView = class("Portrait_indiv_popupView", super)
local portrair_moudle = require("ui.view.portrair_moudle_view").new()

function Portrait_indiv_popupView:ctor()
  self.panel = nil
  super.ctor(self, "portrait_indiv_popup")
  self.vm_ = Z.VMMgr.GetVM("portrait_indiv_popup")
end

function Portrait_indiv_popupView:OnActive()
  self.panel.cont_base2_popup.scenemask.SceneMask:SetSceneMaskByKey(self.SceneMaskKey)
  self.curSubViewType_ = self.viewData.subViewType
  self.items_ = {
    [1] = {
      subView = portrair_moudle,
      container = self.panel.cont_base2_popup.cont_tog_head
    }
  }
  for k, v in pairs(self.items_) do
    local type = k
    self:AddAsyncClick(v.container.off.img_btn.Btn, function()
      self:onchangeSubView(type)
    end, nil, nil)
  end
  self:AddClick(self.panel.cont_base2_popup.cont_close.btn.Btn, function()
    self.vm_.ClosePortraitView()
  end)
  self:onchangeSubView(self.curSubViewType_, true)
end

function Portrait_indiv_popupView:OnDeActive()
  for key, value in pairs(self.items_) do
    if value.subView then
      value.subView:DeActive()
    end
  end
end

function Portrait_indiv_popupView:OnRefresh()
end

function Portrait_indiv_popupView:onchangeSubView(subViewType, force)
  if subViewType == self.curSubViewType_ and not force then
    return
  end
  local prevItem = self.items_[self.curSubViewType_]
  if prevItem then
    if prevItem.subView then
      prevItem.subView:DeActive()
      prevItem.container.on:SetVisible(false)
      prevItem.container.off:SetVisible(true)
    end
    self.curSubViewType_ = subViewType
    local item = self.items_[self.curSubViewType_]
    if item then
      item.container.on:SetVisible(true)
      item.container.off:SetVisible(false)
      if item.subView then
        item.subView:Active(self.viewData.data, self.panel.cont_base2_popup.content.Trans)
      else
        Z.DialogViewDataMgr:OpenOKDialog(Lang("FuncNoDevelopment"))
      end
    end
  end
end

return Portrait_indiv_popupView
