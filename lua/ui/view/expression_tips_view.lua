local UI = Z.UI
local super = require("ui.ui_subview_base")
local ExpressionTipsView = class("Expression_tipsView", super)
local worldproxy = require("zproxy.world_proxy")

function ExpressionTipsView:ctor(parent)
  self.panel = nil
  super.ctor(self, "expression_tips", "expression/expression_tips", UI.ECacheLv.None, parent)
  self.itemId_ = -1
end

function ExpressionTipsView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self:setUI()
  self:AddClick(self.panel.bg.Btn, function()
    self:Hide()
  end)
  self:AddAsyncClick(self.panel.cont_popup_btn_study.btn.Btn, function()
    if self.itemCount_ > 0 then
      local expressionData = Z.DataMgr.Get("expression_data")
      local ret = worldproxy.LearnExpressionAction(expressionData.ItemsSelectedData.Id, self.cancelSource:CreateToken())
      if ret == 0 then
        local vm = Z.VMMgr.GetVM("expression")
        vm.RefItemGroup()
      else
        local vm = Z.VMMgr.GetVM("expression")
        vm.RefItemGroup()
      end
    else
      Z.TipsVM.ShowTipsLang(100107)
    end
  end)
end

function ExpressionTipsView:OnClickLearn()
end

function ExpressionTipsView:setUI(itemId)
  local expressionData = Z.DataMgr.Get("expression_data"):GetItemsSelectedData()
  self.itemId_ = itemId or tonumber(expressionData.UnlockItem)
  if not self.itemId_ then
    self.panel.lab_name.TMPLab.text = ""
    self.panel.lab_up_2.TMPLab.text = ""
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local package = itemsVM.GetPackageInfobyItemId(self.itemId_)
  local itemInfo = package.items[self.itemId_]
  self.itemCount_ = 0
  if itemInfo then
    self.itemCount_ = itemInfo.count
  end
  local itemData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemId_)
  if itemData then
    self.panel.lab_name.TMPLab.text = itemData.Name
    self.panel.lab_down_2.TMPLab.text = expressionData.UnlockDes
    self.panel.lab_up_2.TMPLab.text = string.gsub(itemData.Description, "<br>", "\n")
    self.panel.popuo_item.Img:SetImage(itemsVM.GetItemIcon(self.itemId_))
  end
end

function ExpressionTipsView:OnDeActive()
end

return ExpressionTipsView
