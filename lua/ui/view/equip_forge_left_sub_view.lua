local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_forge_left_subView = class("Equip_forge_left_subView", super)
local loopGridView = require("ui/component/loop_grid_view")
local loopItem = require("ui/component/equip/equip_recast_popup_loop_item")
local previewItem = require("ui/component/equip/equip_forget_preview_loop_item")

function Equip_forge_left_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_forge_left_sub", "equip/equip_forge_left_sub", UI.ECacheLv.None)
end

function Equip_forge_left_subView:initBinders()
  self.closeBnt_ = self.uiBinder.btn_return
  self.previewItemList_ = self.uiBinder.loop_item_preview
  self.press_ = self.uiBinder.node_press
  self.lab_details_ = self.uiBinder.lab_details
  self.loopItem_ = self.uiBinder.loop_item
  self.emptyNode_ = self.uiBinder.node_empty
  self.haveNode_ = self.uiBinder.node_have
end

function Equip_forge_left_subView:initBtns()
  self:AddClick(self.closeBnt_, function()
    self:DeActive()
  end)
  self:EventAddAsyncListener(self.press_.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:DeActive()
    end
  end, nil, nil)
end

function Equip_forge_left_subView:initUi()
  self.previewLoopGridView_ = loopGridView.new(self, self.previewItemList_, previewItem, "com_item_long_2_8")
  self.loopGridView_ = loopGridView.new(self, self.loopItem_, loopItem, "com_item_long_2")
  self.items_ = {}
  if self.viewData and self.viewData.items then
    self.items_ = self.viewData.items
  end
  if self.viewData.isPreview then
    self.lab_details_.text = Lang("EquipCreatePerfectDes", {
      val = self.viewData.perfectValue or 100
    })
    self.previewLoopGridView_:Init(self.items_)
  else
    self.loopGridView_:Init(self.items_)
  end
  self.uiBinder.Ref:SetVisible(self.emptyNode_, self.viewData.isPreview)
  self.uiBinder.Ref:SetVisible(self.haveNode_, not self.viewData.isPreview)
  self:StartCheck()
end

function Equip_forge_left_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initBinders()
  self:initBtns()
  self:initUi()
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, true)
end

function Equip_forge_left_subView:GetCheck()
  return self.press_
end

function Equip_forge_left_subView:StartCheck()
  self.press_:StartCheck()
end

function Equip_forge_left_subView:StopCheck()
  self.press_:StopCheck()
end

function Equip_forge_left_subView:ClearSelected()
  self.loopGridView_:ClearAllSelect()
end

function Equip_forge_left_subView:GetIsRecast()
  return self.viewData.isRecast
end

function Equip_forge_left_subView:OnDeActive()
  self:StopCheck()
  if self.previewLoopGridView_ then
    self.previewLoopGridView_:UnInit()
    self.previewLoopGridView_ = nil
  end
  if self.loopGridView_ then
    self.loopGridView_:UnInit()
    self.loopGridView_ = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, false)
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

function Equip_forge_left_subView:OnRefresh()
end

return Equip_forge_left_subView
