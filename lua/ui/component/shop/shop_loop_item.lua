local super = require("ui.component.loopscrollrectitem")
local ShopLoopItem = class("ShopLoopItem", super)
local bgImgStr_ = "ui/atlas/season/seasonshop_item_quality_%d"

function ShopLoopItem:initZWidget()
  self.qualityBgImg_ = self.unit.img_quality_bg
  self.itemNameLab_ = self.unit.lab_item_name
  self.newIcom_ = self.unit.img_new
  self.newLab_ = self.unit.lab_new
  self.itemIconImg_ = self.unit.img_item_icon
  self.itemProjectionImg_ = self.unit.img_icon_projection
  self.timeNode_ = self.unit.img_time_bg
  self.timeLab_ = self.unit.lab_time
  self.weekTimeLab_ = self.unit.lab_week
  self.dayTimeLab_ = self.unit.lab_day
  self.moneyNode_ = self.unit.img_price_bg
  self.moneyIconImg_ = self.unit.img_price_icon
  self.lastMoneyLab_ = self.unit.lab_time
  self.moneyLab_ = self.unit.lab_price_num
  self.bigTimeNode_ = self.unit.img_buy_state_bg
  self.bigTimeLab_ = self.unit.lab_time
  self.discountNode_ = self.unit.img_discount_bg
  self.discountLab_ = self.unit.lab_discount_num
  self.offLab_ = self.unit.lab_off
end

function ShopLoopItem:ctor()
end

function ShopLoopItem:OnInit()
  self:initZWidget()
  self:AddClick(self.qualityBgImg_.Btn, function()
    logError("\232\180\173\228\185\176\229\149\134\229\159\142\233\129\147\229\133\183")
  end)
end

function ShopLoopItem:OnUnInit()
end

function ShopLoopItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.itemNameLab_.TMPLab.text = self.data_.ItemName
  local type = 0
  local param = 0
  if self.data_.Label then
    type = self.data_.Label[1]
    param = self.data_.Label[1]
  end
  if type == 0 then
    self.newIcom_:SetVisible(false)
    self.newIcom_:SetVisible(true)
    self.newLab_.TMPLab.text = Lang(param)
  end
  self:setCost(self.data_.Cost)
  self:showItem(self.data_.ItemId)
end

function ShopLoopItem:setCost(cost)
  local moneyNum = 0
  local moneyId = 0
  for id, num in pairs(cost) do
    moneyId = id
    moneyNum = num
  end
  local itemTablMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableData = itemTablMgr.GetRow(moneyId)
  self.moneyLab_.TMPLab.text = moneyNum
  if itemTableData == nil then
    return
  end
  local itemsVm = Z.VMMgr.GetVM("items")
  self.moneyIconImg_.Img:SetImage(itemsVm.GetItemIcon(moneyId))
end

function ShopLoopItem:showItem(id)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
  if itemCfg then
    local itemsVM = Z.VMMgr.GetVM("items")
    self.itemIconImg_.Img:SetImage(itemsVM.GetItemIcon(id))
    self.itemProjectionImg_.Img:SetImage(itemsVM.GetItemIcon(id))
    self.qualityBgImg_.Img:SetImage(string.format(bgImgStr_, itemCfg.Quality))
  end
end

return ShopLoopItem
