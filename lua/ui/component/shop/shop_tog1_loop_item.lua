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
  if self.shopTabData_.fristLevelTabData.Id ~= E.MallType.ERecharge then
    local redNodeId = string.zconcat(E.RedType.Shop, E.RedType.ShopOneTab, self.shopTabData_.fristLevelTabData.Id)
    Z.RedPointMgr.LoadRedDotItem(redNodeId, self.parent.UIView, self.uiBinder.node_dot)
  end
  if self.shopTabData_.fristLevelTabData.FunctionId == E.FunctionID.MysteriousShop then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.MysteriousShopRed, self.parent.UIView, self.uiBinder.node_dot)
  end
  self:setIsOn(false)
  if self.shopTabData_.fristLevelTabData.Icon ~= "" then
    self.uiBinder.img_icon_on:SetImage(self.shopTabData_.fristLevelTabData.Icon)
    self.uiBinder.img_icon_off:SetImage(self.shopTabData_.fristLevelTabData.Icon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_on, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_off, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_on, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_off, false)
  end
end

function ShopTog1LoopItem:OnSelected(isSelected, isClick)
  self:setIsOn(isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("UI_Tab_Special")
    end
    if self.shopTabData_.fristLevelTabData.FunctionId == E.FunctionID.MysteriousShop then
      Z.RedPointMgr.OnClickRedDot(E.RedType.MysteriousShopRed)
    end
    self.parent.UIView:Tog1Click(self.shopTabData_)
  end
end

function ShopTog1LoopItem:setIsOn(isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isOn)
  self.uiBinder.node_eff:SetEffectGoVisible(isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isOn)
end

return ShopTog1LoopItem
