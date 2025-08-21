local super = require("ui.component.loop_list_view_item")
local FishingLevelRewardItem = class("FishingLevelRewardItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function FishingLevelRewardItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.com_item_square_8
  })
end

function FishingLevelRewardItem:OnRefresh(fishingLevelRewardData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_function.Trans, not fishingLevelRewardData.isReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.com_item_square_8.Trans, fishingLevelRewardData.isReward)
  if fishingLevelRewardData.isReward then
    self:refreshItem(fishingLevelRewardData.awardData)
  else
    self:refreshFunction(fishingLevelRewardData.functionData)
  end
end

function FishingLevelRewardItem:refreshItem(awardData_)
  if awardData_ == nil then
    return
  end
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = awardData_.beGet ~= nil and awardData_.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  self.itemClass_:RefreshByData(itemData)
end

function FishingLevelRewardItem:refreshFunction(functionData)
  local funcRow = Z.TableMgr.GetRow("FunctionTableMgr", functionData.functionID)
  if not funcRow then
    return
  end
  self.uiBinder.btn_function.img_frame:SetImage(funcRow.Icon)
  self.uiBinder.btn_function.btn_function:AddListener(function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.Trans, Lang("FishingFunctionRewardTitle"), Z.Placeholder.Placeholder(functionData.desc, {
      val = funcRow.Name
    }))
  end)
  self.uiBinder.btn_function.Ref:SetVisible(self.uiBinder.btn_function.img_get, functionData.beGet)
end

function FishingLevelRewardItem:OnUnInit()
  self.itemClass_:UnInit()
end

function FishingLevelRewardItem:OnRecycle()
  self.uiBinder.com_item_square_8.rimg_icon.enabled = false
end

return FishingLevelRewardItem
