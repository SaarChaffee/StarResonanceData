local WorldBossScoreLoopItem = class("WorldBossScoreLoopItem")
local itemBinder = require("common.item_binder")

function WorldBossScoreLoopItem:ctor()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function WorldBossScoreLoopItem:Init(viewParent, uiBinder)
  self.view_ = viewParent
  self.uiBinder = uiBinder
  if self.itemBinder_ == nil then
    self.itemBinder_ = itemBinder.new(self.view_)
  end
  self.itemBinder_:Init({
    uiBinder = uiBinder.com_item
  })
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
end

function WorldBossScoreLoopItem:Refresh(param)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardData_ = param.awardData
  self.param_ = param
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder.com_item
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  itemData.isClickOpenTips = false
  self.itemBinder_:RefreshByData(itemData)
  self.itemBinder_:SetRedDot(Z.RedPointMgr.GetRedState(self.worldBossVM_:GetScoreItemRedName(self.param_.scoreNum)))
  self:SetUI()
end

function WorldBossScoreLoopItem:UnInit()
  self.view_ = nil
  self.uiBinder = nil
  self.param_ = nil
  self.worldBossVM_ = nil
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.tipsId_ = nil
end

function WorldBossScoreLoopItem:SetUI()
  self.uiBinder.lab_num.text = self.param_.scoreNum
  self.view_:AddAsyncClick(self.uiBinder.btn_item, function()
    local worldBossInfo = Z.ContainerMgr.CharSerialize.personalWorldBossInfo
    local receiveData = worldBossInfo.scoreAwardInfo
    local curNum = worldBossInfo.score or 0
    local canReceive = curNum >= self.param_.scoreNum
    if receiveData then
      local rewardState = receiveData[self.param_.stateID]
      if rewardState and rewardState.awardStatus == E.ReceiveRewardStatus.Received then
        canReceive = false
      end
    end
    if canReceive then
      local ret = self.worldBossVM_:AsyncReceiveScoreReward(self.param_.stateID, self.view_.cancelSource:CreateToken())
      if ret == 0 then
        self.itemBinder_:SetRedDot(false)
      end
    else
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.param_.awardID)
    end
  end)
end

function WorldBossScoreLoopItem:SetRootPos(posX, posY)
  self.uiBinder.Trans:SetAnchorPosition(posX, posY)
end

function WorldBossScoreLoopItem:SetState(scoreNum, isReceive)
  local isScoreEnough = scoreNum >= self.param_.scoreNum
  self:SetVisible(self.uiBinder.img_on, isScoreEnough)
  self.itemBinder_:SetReceive(isReceive)
end

function WorldBossScoreLoopItem:SetVisible(comp, isVisible)
  self.uiBinder.Ref:SetVisible(comp, isVisible)
end

function WorldBossScoreLoopItem:ClearData()
  self.param_ = nil
end

function WorldBossScoreLoopItem:GetData()
  return self.param_
end

return WorldBossScoreLoopItem
