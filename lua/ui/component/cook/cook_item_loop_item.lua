local super = require("ui.component.loop_grid_view_item")
local CookItem = class("CookItem", super)
local itemClass = require("common.item_binder")

function CookItem:ctor()
end

function CookItem:OnInit()
end

function CookItem:OnRefresh(data)
  self.uiView_ = self.parent.UIView
  self.data_ = data
  self.itemClass_ = itemClass.new(self.uiView_)
  local itemPreviewData = {
    uiBinder = self.uiBinder,
    configId = self.data_.configId,
    isSquareItem = true,
    isClickOpenTips = false
  }
  itemPreviewData.lab = self.data_.count
  itemPreviewData.labType = E.ItemLabType.Num
  self.itemClass_:Init(itemPreviewData)
  self:SetShowClose(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, false)
  if self.uiView_:IsNeedSelected(self.data_.configId) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, true)
    self:SetShowClose(true)
  end
  self.uiView_:AddClick(self.uiBinder.btn_minus, function()
    self.uiView_:UnSelected(self.data_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, false)
    self:SetShowClose(false)
  end)
end

function CookItem:OnBeforePlayAnim()
end

function CookItem:OnPointerClick(go, eventData)
  local flag = self.uiView_:OnSelectedFood(self.data_)
  if flag then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, true)
    self:SetShowClose(true)
  end
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.data_.configId)
end

function CookItem:SetShowClose(show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_minus, false)
end

function CookItem:OnUnInit()
  self.itemClass_:UnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

return CookItem
