local super = require("ui.component.loop_list_view_item")
local FishingItemSelectLoopItem = class("FishingItemSelectLoopItem", super)
local itemClass = require("common.item_binder")

function FishingItemSelectLoopItem:ctor()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.itemClass_ = itemClass.new(self)
end

function FishingItemSelectLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function FishingItemSelectLoopItem:OnRefresh(data)
  self.data = data
  self.itemConfig_ = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.configId)
  self:refreshUI()
end

function FishingItemSelectLoopItem:refreshUI()
  if self.itemConfig_ then
    self.uiBinder.uisteer:ClearSteerList()
    local isFishBait = self.data.type == E.FishingItemType.FishBait
    local isFishingRod = not isFishBait
    if self.Index == 1 then
      local parm = isFishBait and 2 or 1
      Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer, E.DynamicSteerType.Fishing, parm)
    end
    self.uiBinder.lab_name.text = self.itemConfig_.Name
    self.uiBinder.lab_introduce.text = self.itemConfig_.Description
    self.uiBinder.btn_use:RemoveAllListeners()
    self.itemClass_:InitCircleItem(self.uiBinder.fishing_item_round, self.data.configId, self.data.uuid, self.itemConfig_.Quality, nil, Z.ConstValue.QualityImgRoundBg)
    self.uiBinder.fishing_item_round.btn_temp:RemoveAllListeners()
    self:AddAsyncListener(self.uiBinder.fishing_item_round.btn_temp, function()
      self.parentUIView:ShowItemTips(self.uiBinder.fishing_item_round.Trans, self.data.configId, self.data.uuid)
    end)
    self.uiBinder.fishing_item_round.Ref:SetVisible(self.uiBinder.fishing_item_round.lab_content, isFishBait)
    self.uiBinder.fishing_item_round.Ref:SetVisible(self.uiBinder.fishing_item_round.img_label, isFishBait)
    self.uiBinder.fishing_item_round.Ref:SetVisible(self.uiBinder.fishing_item_round.img_frame, isFishingRod)
    if isFishBait then
      self.uiBinder.fishing_item_round.lab_content.text = self.itemsVM_.GetItemTotalCount(self.data.configId)
    elseif isFishingRod then
      local rodConfigId_ = self.itemsVM_.GetItemTabDataByUuid(self.data.uuid).Id
      local fishingRodRow_ = Z.TableMgr.GetTable("FishingRodTableMgr").GetRow(rodConfigId_)
      if not fishingRodRow_ then
        return
      end
      local res = fishingRodRow_.Durability
      local fillAmount = 0
      if res ~= 0 then
        fillAmount = self.fishingData_:GetFishingRodDurability(self.data.uuid) / res
      end
      self.uiBinder.fishing_item_round.img_on.fillAmount = fillAmount
    end
    local isSelect_ = false
    if isFishBait then
      isSelect_ = self.fishingData_.FishBait == self.data.configId
    elseif isFishingRod then
      isSelect_ = self.fishingData_.FishingRod == self.data.uuid
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_use, not isSelect_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_used, isSelect_)
    self.uiBinder.btn_use:AddListener(function()
      if isFishBait then
        self.parentUIView:OnItemSelect(self.data.configId)
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvent, string.zconcat(E.SteerGuideEventType.Fishing, "=", 1))
      elseif isFishingRod then
        self.parentUIView:OnItemSelect(self.data.uuid)
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvent, string.zconcat(E.SteerGuideEventType.Fishing, "=", 2))
      end
    end)
  end
end

function FishingItemSelectLoopItem:OnUnInit()
  self.uiBinder.uisteer:ClearSteerList()
end

return FishingItemSelectLoopItem
