local super = require("ui.component.loop_list_view_item")
local PrepareBuffLoopItem = class("PrepareBuffLoopItem", super)
local buffType = {CookBuff = 101, DrugBuff = 102}
local BuffPathMap = {
  [buffType.CookBuff] = Z.Global.DungeonPrepareFoodBuffDefaultIcon,
  [buffType.DrugBuff] = Z.Global.DungeonPrepareMedicineBuffDefaultIcon
}

function PrepareBuffLoopItem:OnInit()
end

function PrepareBuffLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_right, data.buffTime > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_wrong, data.buffTime == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, data.buffTime == 0)
  local path = BuffPathMap[data.buffId]
  if path then
    self.uiBinder.rimg_icon:SetImage(path)
  end
  local qualityIconPath = Z.ConstValue.Item.SquareItemQualityPath .. 2
  self.uiBinder.img_quality:SetImage(qualityIconPath)
end

function PrepareBuffLoopItem:OnPointerClick()
  if self.data_.buffId == buffType.DrugBuff then
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.Trans, self.data_.buffTime > 0 and Lang("HeroDungeonPrepareMedicineYes") or Lang("HeroDungeonPrepareMedicineNo"))
  else
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.Trans, self.data_.buffTime > 0 and Lang("HeroDungeonPrepareFoodYes") or Lang("HeroDungeonPrepareFoodNo"))
  end
end

function PrepareBuffLoopItem:OnUnInit()
end

return PrepareBuffLoopItem
