local UI = Z.UI
local super = require("ui.ui_view_base")
local Wardrobe_collection_tipsView = class("Wardrobe_collection_tipsView", super)

function Wardrobe_collection_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "wardrobe_collection_tips")
end

function Wardrobe_collection_tipsView:OnActive()
  self.uiBinder.Trans.parent = self.viewData.parent
  self.uiBinder.Trans:SetLocalPos(0, 0, 0)
  self.uiBinder.Trans:SetWidth(448)
  self.uiBinder.Trans:SetHeight(510)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView("wardrobe_collection_tips")
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  local collectionVM = Z.VMMgr.GetVM("collection")
  local num = collectionVM.GetFashionCollectionPoints(self.viewData)
  local allParam = {val = num}
  self.uiBinder.lab_title.text = Lang("FashionCollectionTitle", allParam)
  local suitYellowCount = 0
  local suitPurpleCount = 0
  local suitGreenCount = 0
  local clothesYellowCount = 0
  local clothesPurpleCount = 0
  local clothesGreenCount = 0
  local ornamentYellowCount = 0
  local ornamentPurpleCount = 0
  local ornamentGreenCount = 0
  if self.viewData.personalZone and self.viewData.personalZone.fashionCollectQualityCount then
    for regionId, collectInfo in pairs(self.viewData.personalZone.fashionCollectQualityCount) do
      local yellowCount = collectInfo.qualityCount[E.ItemQuality.Yellow] and collectInfo.qualityCount[E.ItemQuality.Yellow] or 0
      local purpleCount = collectInfo.qualityCount[E.ItemQuality.Purple] and collectInfo.qualityCount[E.ItemQuality.Purple] or 0
      local greenCount = collectInfo.qualityCount[E.ItemQuality.Green] and collectInfo.qualityCount[E.ItemQuality.Green] or 0
      if regionId == E.FashionRegion.Suit then
        suitYellowCount = suitYellowCount + yellowCount
        suitPurpleCount = suitPurpleCount + purpleCount
        suitGreenCount = suitGreenCount + greenCount
      elseif regionId == E.FashionRegion.UpperClothes or regionId == E.FashionRegion.Pants then
        clothesYellowCount = clothesYellowCount + yellowCount
        clothesPurpleCount = clothesPurpleCount + purpleCount
        clothesGreenCount = clothesGreenCount + greenCount
      else
        ornamentYellowCount = ornamentYellowCount + yellowCount
        ornamentPurpleCount = ornamentPurpleCount + purpleCount
        ornamentGreenCount = ornamentGreenCount + greenCount
      end
    end
  end
  self.uiBinder.lab_yellow_suit.text = suitYellowCount
  self.uiBinder.lab_purple_suit.text = suitPurpleCount
  self.uiBinder.lab_green_suit.text = suitGreenCount
  self.uiBinder.lab_yellow_clothes.text = clothesYellowCount
  self.uiBinder.lab_purple_clothes.text = clothesPurpleCount
  self.uiBinder.lab_green_clothes.text = clothesGreenCount
  self.uiBinder.lab_yellow_ornament.text = ornamentYellowCount
  self.uiBinder.lab_purple_ornament.text = ornamentPurpleCount
  self.uiBinder.lab_green_ornament.text = ornamentGreenCount
end

function Wardrobe_collection_tipsView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Wardrobe_collection_tipsView:OnRefresh()
end

return Wardrobe_collection_tipsView
