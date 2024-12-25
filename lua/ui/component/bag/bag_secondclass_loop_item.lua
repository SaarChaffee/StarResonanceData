local super = require("ui.component.loop_list_view_item")
local BagSecondClassLoopItem = class("BagSecondClassLoopItem", super)
local bagRed = require("rednode.bag_red")
local noSelectColor = Color.New(1, 1, 1, 0.4)
local selectColor = Color.New(1, 1, 1, 1)

function BagSecondClassLoopItem:ctor()
end

function BagSecondClassLoopItem:OnInit()
  Z.EventMgr:Add(Z.ConstValue.Backpack.RefreshSecondClassItemLine, self.refreshLine, self)
end

function BagSecondClassLoopItem:OnRefresh(data)
  self.isSelected_ = false
  self.packageType_ = self.parent.UIView:GetSelectedPackageType()
  local itemPackageItem = Z.TableMgr.GetTable("ItemPackageTableMgr").GetRow(self.packageType_)
  local path = ""
  if itemPackageItem then
    if itemPackageItem.Id == E.BackPackItemPackageType.Item then
      path = "ui/atlas/bag/secondclass/"
    elseif itemPackageItem.Id == E.BackPackItemPackageType.Equip then
      path = "ui/atlas/bag/equip_bag/"
    elseif itemPackageItem.Id == E.BackPackItemPackageType.Mod then
      path = "ui/atlas/bag/mod_bag/"
    elseif itemPackageItem.Id == E.BackPackItemPackageType.ResonanceSkill then
      path = "ui/atlas/bag/resonance_skill_bag/"
    end
  end
  self.uiBinder.Trans:SetWidth(self.uiBinder.unselected_node.rect.width)
  local str = ""
  if self.Index == 1 then
    self.id_ = -1
    self.uiBinder.selected_img:SetImage("ui/atlas/bag/secondclass/bag_icon_all")
    str = Lang("All")
  else
    self.data_ = data
    self.id_ = tonumber(self.data_[2])
    self.uiBinder.selected_img:SetImage(path .. self.data_[4])
    str = self.data_[3]
  end
  self.uiBinder.selected_img:SetColor(noSelectColor)
  self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.unselected_node, true)
  if itemPackageItem then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, self.Index == 1)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line01, true)
  end
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.Trans, self.parent.UIView)
  local resonanceNodeId = bagRed.GetResonanceSubTabRedId(self.packageType_, self.id_)
  Z.RedPointMgr.LoadRedDotItem(resonanceNodeId, self.parent.UIView, self.uiBinder.Trans)
end

function BagSecondClassLoopItem:refreshLine(index)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line01, index - self.Index ~= 1)
end

function BagSecondClassLoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.unselected_node, not isSelected)
  if self.isSelected_ == isSelected then
    return
  end
  self.isSelected_ = isSelected
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_side_click")
    end
    self:OnStartPlayAnim()
    local backpackView = self.parent.UIView
    backpackView:OnSecondClassSelected(self.id_)
    self.uiBinder.Trans:SetWidth(self.uiBinder.selected_node.rect.width)
    self.uiBinder.selected_img:SetColor(selectColor)
    Z.EventMgr:Dispatch(Z.ConstValue.Backpack.RefreshSecondClassItemLine, self.Index)
  else
    self.uiBinder.selected_img:SetColor(noSelectColor)
    self.uiBinder.Trans:SetWidth(self.uiBinder.unselected_node.rect.width)
  end
  self.parent:OnItemSizeChanged(self.Index)
end

function BagSecondClassLoopItem:OnStartPlayAnim()
end

function BagSecondClassLoopItem:OnUnInit()
  local resonanceNodeId = bagRed.GetResonanceSubTabRedId(self.packageType_, self.id_)
  Z.RedPointMgr.RemoveNodeItem(resonanceNodeId)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.RefreshSecondClassItemLine, self.refreshLine, self)
end

function BagSecondClassLoopItem:OnReset()
  self.isSelected_ = false
end

return BagSecondClassLoopItem
