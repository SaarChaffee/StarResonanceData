local super = require("ui.component.loop_list_view_item")
local ShopTog2LoopItem = class("ShopTog2LoopItem", super)

function ShopTog2LoopItem:ctor()
end

function ShopTog2LoopItem:OnInit()
  self.functionCfg_ = Z.TableMgr.GetTable("FunctionTableMgr")
  self.lastRedId_ = nil
end

function ShopTog2LoopItem:OnUnInit()
  if self.lastRedId_ then
    Z.RedPointMgr.RemoveNodeItem(self.lastRedId_)
    self.lastRedId_ = nil
  end
end

function ShopTog2LoopItem:OnRefresh(data)
  if self.lastRedId_ then
    Z.RedPointMgr.RemoveNodeItem(self.lastRedId_)
    self.lastRedId_ = nil
  end
  self.data_ = data
  if self.data_.HasFatherType == 0 then
    self.lastRedId_ = string.zconcat(E.RedType.Shop, E.RedType.ShopOneTab, self.data_.Id)
  else
    self.lastRedId_ = string.zconcat(E.RedType.Shop, E.RedType.ShopTwoTab, self.data_.Id)
  end
  Z.RedPointMgr.LoadRedDotItem(self.lastRedId_, self.parent.UIView, self.uiBinder.node_dot)
  local name = self.functionCfg_.GetRow(self.data_.FunctionId).Name
  self.uiBinder.lab_name_1.text = name
  self.uiBinder.lab_name_2.text = name
  self.uiBinder.Ref:SetVisible(self.uiBinder.uianim_select, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, self.Index ~= #self.parent:GetData())
end

function ShopTog2LoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.uianim_select, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_side_click")
    end
    self.parent.UIView:Tog2Click(self.data_, self.Index, isClick)
  end
end

return ShopTog2LoopItem
