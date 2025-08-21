local super = require("ui.component.loop_list_view_item")
local ShopTog1LoopItem = class("ShopTog1LoopItem", super)

function ShopTog1LoopItem:ctor()
end

function ShopTog1LoopItem:OnInit()
  self.functionCfg_ = Z.TableMgr.GetTable("FunctionTableMgr")
end

function ShopTog1LoopItem:OnUnInit()
  self.functionCfg_ = nil
end

function ShopTog1LoopItem:OnRefresh(data)
  self.shopTabData_ = data
  local nameCfg = self.functionCfg_.GetRow(self.shopTabData_.fristLevelTabData.FunctionId)
  self.uiBinder.lab_on_content.text = nameCfg and nameCfg.Name or ""
  self.uiBinder.lab_off_content.text = nameCfg and nameCfg.Name or ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_off, self.Index ~= #self.parent.DataList)
  Z.RedPointMgr.LoadRedDotItem(data.redNodeId, self.parent.UIView, self.uiBinder.node_dot)
  self:setIsOn(false)
end

function ShopTog1LoopItem:OnSelected(isSelected, isClick)
  self:setIsOn(isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("UI_Tab_Special")
    end
    Z.RedPointMgr.OnClickRedDot(self.shopTabData_.redNodeId)
    self.parent.UIView:OnClickFirstShop(self.shopTabData_, self.Index, isClick)
  end
end

function ShopTog1LoopItem:setIsOn(isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isOn)
end

return ShopTog1LoopItem
