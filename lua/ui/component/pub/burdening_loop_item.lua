local super = require("ui.component.loop_grid_view_item")
local item = require("common.item_binder")
local BurdeningLoopItem = class("RecipeLoopItem", super)

function BurdeningLoopItem:ctor()
end

function BurdeningLoopItem:OnInit()
  self.uiView = self.parent.UIView
  self.pubData_ = Z.DataMgr.Get("pub_mixology_data")
  self.itemClass_ = item.new(self.uiView)
  self.uiView:AddClick(self.uiBinder.btn_minus, function()
    self.selectCount_ = self.selectCount_ - 1
    local isShow = self.selectCount_ > 0
    self.itemClass_:SetLab(self.selectCount_)
    self.itemClass_:SetSelected(isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, isShow)
    self.pubData_:RemoveBring(self.data_)
    self.uiView:SetBtnState()
  end)
end

function BurdeningLoopItem:OnUnInit()
end

function BurdeningLoopItem:Refresh(data)
  self.isSelect_ = false
  self.data_ = data
  self.selectCount_ = 0
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    configId = self.data_.Id,
    lab = self.selectCount_,
    labType = E.ItemLabType.Str,
    isClickOpenTips = false,
    isSquareItem = true
  })
end

function BurdeningLoopItem:RefreshState()
  if self.selectCount_ == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, true)
  end
end

function BurdeningLoopItem:OnPointerClick()
  local result = self.uiView:SelectLoopItem(self.data_)
  if result then
    self.selectCount_ = self.selectCount_ + 1
    self.itemClass_:SetLab(self.selectCount_)
    self.itemClass_:SetSelected(true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, true)
  else
    if self.pubData_:GetSelectMadeID() == self.data_.Id then
      return
    end
    Z.TipsVM.ShowTipsLang(130002)
  end
end

function BurdeningLoopItem:OnSelected(isSelected)
end

return BurdeningLoopItem
