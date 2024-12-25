local UI = Z.UI
local super = require("ui.ui_subview_base")
local Cook_replace_subView = class("Cook_replace_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local cookReplaceLoopItem = require("ui.component.cook.cook_replace_selected_loop_item")

function Cook_replace_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "cook_replace_sub", "cook/cook_replace_sub", UI.ECacheLv.None)
  self.parent = parent
  self.vm_ = Z.VMMgr.GetVM("cook")
end

function Cook_replace_subView:OnActive()
  self.press = self.uiBinder.press
  self.gridViewRect_ = self.uiBinder.grid_view
  self:EventAddAsyncListener(self.press.ContainGoEvent, function(isContain)
    if not isContain then
      self:DeActive()
    end
  end, nil, nil)
  self.gridViewLoop_ = loopGridView.new(self, self.gridViewRect_, cookReplaceLoopItem, "com_item_square_8")
  self.gridViewLoop_:Init(self.viewData.data)
end

function Cook_replace_subView:OnDeActive()
  self.press:StopCheck()
  if self.gridViewLoop_ then
    self.gridViewLoop_:UnInit()
  end
end

function Cook_replace_subView:OnSelected(data)
  self.parent:SetMainMaterial(self.viewData.type, data)
  self:DeActive()
end

function Cook_replace_subView:OnRefresh()
  self.press:StartCheck()
end

return Cook_replace_subView
