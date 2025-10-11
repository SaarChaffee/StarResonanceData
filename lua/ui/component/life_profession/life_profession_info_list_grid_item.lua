local super = require("ui.component.loop_grid_view_item")
local LifeProfessionInfoListGridItem = class("LifeProfessionInfoListGridItem", super)
local item = require("common.item_binder")

function LifeProfessionInfoListGridItem:ctor()
  self.lifeProfessionVm_ = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function LifeProfessionInfoListGridItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_show
  })
end

function LifeProfessionInfoListGridItem:OnRefresh(data)
  self.lifeType = data.lifeType
  self.data = data
  self.itemClass_:HideUi()
  local configData
  local icon = ""
  local name = ""
  local content = ""
  if self.lifeType == E.ELifeProfessionMainType.Collection then
    configData = Z.TableMgr.GetRow("LifeCollectListTableMgr", data.productId)
    icon = configData.Icon
    name = configData.Name
    local unlockConditions = self.parentUIView.isConsume and configData.UnlockCondition or configData.UnlockConditionZeroCost
    local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", configData.LifeProId)
    content = Lang("NeedProfessionLevel", {
      professionName = config.Name,
      needLevel = self.parentUIView.isConsume and configData.NeedLevel[1] or configData.NeedLevel[2]
    })
    if table.zcount(unlockConditions) > 0 then
      local conditionDescList = Z.ConditionHelper.GetConditionDescList(unlockConditions)
      for _, value in pairs(conditionDescList) do
        content = value.showPurview
        break
      end
    end
  else
    configData = Z.TableMgr.GetRow("LifeProductionListTableMgr", data.productId)
    icon = self.itemsVm_.GetItemIcon(configData.RelatedItemId)
    name = configData.Name
    if 0 < #data.subProductList then
      content = Lang("NeedMultiFormula")
    elseif table.zcount(configData.UnlockCondition) > 0 then
      local conditionDescList = Z.ConditionHelper.GetConditionDescList(configData.UnlockCondition)
      for _, value in pairs(conditionDescList) do
        content = value.showPurview
        break
      end
    else
      local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", configData.LifeProId)
      content = Lang("NeedProfessionLevel", {
        professionName = config.Name,
        needLevel = configData.NeedLevel
      })
    end
  end
  local quality = configData.Quality
  self.itemClass_:setQuality(Z.ConstValue.Item.SquareItemQualityPath .. quality)
  self.itemClass_:SetIcon(icon)
  local isProductionUnlocked = self.lifeProfessionVm_.IsProductUnlocked(configData.LifeProId, configData.Id, self.parentUIView.isConsume)
  self.itemClass_:SetImgLockState(not isProductionUnlocked)
  local isProductionHasCost = self.lifeProfessionVm_.IsProductHasCost(configData.LifeProId, configData.Id)
  self.itemClass_:SetImgTradeState(isProductionHasCost and self.parentUIView.isConsume)
  self.uiBinder.lab_title.text = name
  self.uiBinder.lab_content.text = content
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock, isProductionUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function LifeProfessionInfoListGridItem:OnUnInit()
  self.itemClass_:UnInit()
end

function LifeProfessionInfoListGridItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.parentUIView:OnSelectItem(self.data)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

return LifeProfessionInfoListGridItem
