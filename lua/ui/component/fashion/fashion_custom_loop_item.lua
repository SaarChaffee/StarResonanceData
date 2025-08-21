local super = require("ui.component.loop_grid_view_item")
local FashionCustomLoopItem = class("FashionCustomLoopItem", super)
local rimgBgRoot = "ui/textures/vehicle/"
local defaultImage = "vehicle_skin_01"
local imgLineBgColor = {
  [1] = E.FashionCustomsizedLineColor.Green,
  [2] = E.FashionCustomsizedLineColor.Blue,
  [3] = E.FashionCustomsizedLineColor.Pruple,
  [4] = E.FashionCustomsizedLineColor.Yellow,
  [5] = E.FashionCustomsizedLineColor.Red
}

function FashionCustomLoopItem:OnInit()
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
end

function FashionCustomLoopItem:OnRefresh(data)
  self.data_ = data
  self:refreshFashionData()
  self:refreshLockState()
  self:refreshUseState()
  self:refreshBg()
  self:refreshCustomItemRed()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function FashionCustomLoopItem:refreshFashionData()
  local fashionTableRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.data_, true)
  if not fashionTableRow then
    return
  end
  self.uiBinder.lab_num.text = fashionTableRow.Score
  local row = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(self.data_, true)
  if row then
    self.uiBinder.rimg_icon:SetImage(row.Icon)
    self.isCanUnlock_ = self.fashionVM_.IsFashionAdvancedCanUnlock(row)
    self.uiBinder.lab_name.text = row.Name
    self.uiBinder.rimg_bg:SetImage(string.zconcat(rimgBgRoot, row.banner))
    local color = imgLineBgColor[row.Quality] or E.FashionCustomsizedLineColor.Green
    self.uiBinder.img_line:SetColorByHex(color)
  else
    local fashionId = self.parent.UIView:GetOriginalFashionId()
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(fashionId, true)
    if itemRow then
      self.uiBinder.rimg_icon:SetImage(itemRow.Icon)
      self.uiBinder.lab_name.text = itemRow.Name
    end
    self.uiBinder.rimg_bg:SetImage(string.zconcat(rimgBgRoot, defaultImage))
    self.uiBinder.img_line:SetColorByHex(E.FashionCustomsizedLineColor.Green)
  end
end

function FashionCustomLoopItem:refreshLockState()
  local fashionId = self.parent.UIView:GetOriginalFashionId()
  if fashionId == self.data_ then
    self.isUnlock_ = self.fashionVM_.GetFashionIsUnlock(fashionId)
  else
    self.isUnlock_ = self.fashionVM_.GetFashionAdvancedIsUnlock(fashionId, self.data_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not self.isUnlock_)
end

function FashionCustomLoopItem:refreshBg()
  if self.isUnlock_ then
    self.uiBinder.canvas_bg.alpha = 1
    self.uiBinder.canvas_info.alpha = 1
  else
    self.uiBinder.canvas_bg.alpha = 0.2
    self.uiBinder.canvas_info.alpha = 0.6
  end
end

function FashionCustomLoopItem:refreshUseState()
  local originalFashionId = self.fashionVM_.GetOriginalFashionId(self.data_)
  self.isUse_ = self.fashionVM_.GetServerUsingFashionId(originalFashionId) == self.data_
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_use, self.isUse_ and self.isUnlock_)
end

function FashionCustomLoopItem:refreshCustomItemRed()
  self.regionRed_ = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemRed, self.data_)
  Z.RedPointMgr.LoadRedDotItem(self.regionRed_, self.parent.UIView, self.uiBinder.node_red)
end

function FashionCustomLoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  if isSelected then
    self.parent.UIView:OnSelectFashion(self.data_, self.isUnlock_, self.isCanUnlock_, self.isUse_)
    Z.RedPointMgr.OnClickRedDot(self.regionRed_)
  end
end

function FashionCustomLoopItem:OnUnInit()
  Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
end

function FashionCustomLoopItem:OnRecycle()
  Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
end

return FashionCustomLoopItem
