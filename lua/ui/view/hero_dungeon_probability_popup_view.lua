local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_probability_popupView = class("Hero_dungeon_probability_popupView", super)
local itemClass = require("common.item_binder")

function Hero_dungeon_probability_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_probability_popup")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.preview_ = Z.VMMgr.GetVM("item_preview")
end

function Hero_dungeon_probability_popupView:OnActive()
  self.dungeonId_ = self.viewData.dungeonId
  self:AddClick(self.uiBinder.btn_closed, function()
    self.vm_.CloseProbabilityPopup()
  end)
  self:AddClick(self.uiBinder.btn_confirmed, function()
    self.vm_.CloseProbabilityPopup()
    self.vm_.OpenTargetPopupView(self.dungeonId_)
  end)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.binderUpGet_ = itemClass.new(self)
  self.binderClothCur_ = itemClass.new(self)
  self.binderClothNext_ = itemClass.new(self)
  self.binderClothMax_ = itemClass.new(self)
end

function Hero_dungeon_probability_popupView:OnDeActive()
end

function Hero_dungeon_probability_popupView:OnRefresh()
  self:refreshUI()
end

function Hero_dungeon_probability_popupView:refreshUI()
  local buffId, buffCount, maxBuffCount, clothItemId, buffItemId = self.vm_.GetChallengeHeroDungeonProbability(self.dungeonId_)
  if buffId and buffCount and maxBuffCount and clothItemId and buffItemId then
    local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(clothItemId)
    if itemCfg then
      self.uiBinder.lab_name.text = itemCfg.Name
      self.uiBinder.lab_get.text = Lang("HeroDungeonProbabilityGetDes", {
        val = itemCfg.Name
      })
      local itemVM = Z.VMMgr.GetVM("items")
      local iconPath = itemVM.GetItemIcon(clothItemId)
      if iconPath then
        self.uiBinder.rimg_icon:SetImage(iconPath)
      end
    end
    self:initItemBinder(clothItemId, buffItemId)
    self.uiBinder.btn_check:RemoveAllListeners()
    self:AddClick(self.uiBinder.btn_check, function()
      self.preview_.GotoPreview(clothItemId)
    end)
    local isMax = maxBuffCount <= buffCount
    self.uiBinder.node_after_probability.Ref.UIComp:SetVisible(not isMax)
    self.uiBinder.node_current_probability.Ref.UIComp:SetVisible(not isMax)
    self.uiBinder.node_max_probability.Ref.UIComp:SetVisible(isMax)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_confirmed, not isMax)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow, not isMax)
    if isMax then
      self.vm_.SetProbabilityCountUI(maxBuffCount, self.uiBinder.node_max_probability)
    else
      self.vm_.SetProbabilityCountUI(buffCount, self.uiBinder.node_current_probability)
      self.vm_.SetProbabilityCountUI(buffCount + 1, self.uiBinder.node_after_probability)
    end
  end
end

function Hero_dungeon_probability_popupView:initItemBinder(clothItemId, buffItemId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(clothItemId)
  if itemCfg then
    self.binderClothCur_:InitCircleItem(self.uiBinder.binder_item_cloth_cur, clothItemId, nil, nil, nil, Z.ConstValue.QualityImgRoundBg)
    self.binderClothNext_:InitCircleItem(self.uiBinder.binder_item_cloth_next, clothItemId, nil, nil, nil, Z.ConstValue.QualityImgRoundBg)
    self.binderClothMax_:InitCircleItem(self.uiBinder.binder_item_cloth_max, clothItemId, nil, nil, nil, Z.ConstValue.QualityImgRoundBg)
  end
  local upItemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(buffItemId)
  if upItemCfg then
    local itemData = {
      uiBinder = self.uiBinder.binder_up_item,
      configId = buffItemId,
      isSquareItem = true
    }
    self.binderUpGet_:Init(itemData)
  end
end

return Hero_dungeon_probability_popupView
