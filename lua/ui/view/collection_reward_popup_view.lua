local UI = Z.UI
local super = require("ui.ui_view_base")
local Collection_reward_popupView = class("Collection_reward_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local collection_reward_list_item = require("ui.component.collection.collection_reward_list_item")

function Collection_reward_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "collection_reward_popup")
end

function Collection_reward_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.collectionVM_ = Z.VMMgr.GetVM("collection")
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("collection_reward_popup")
  end)
  self:AddAsyncClick(self.uiBinder.btn_receive, function()
    local score = self.collectionVM_.GetFashionCollectionPoints()
    local fashionMgr = Z.ContainerMgr.CharSerialize.fashion
    local idList = {}
    for i = 1, #self.fashionLevelData_ do
      local row = self.fashionLevelData_[i].row
      if score >= row.Score and not fashionMgr.fashionReward[row.Id] then
        idList[#idList + 1] = row.Id
      end
    end
    if #idList == 0 then
      return
    end
    local ret = self.collectionVM_.AsyncGetFashionCollectionAward(idList, self.cancelSource:CreateToken())
    if ret then
      local data = {}
      for i = 1, #ret.rewards do
        data[#data + 1] = {
          configId = ret.rewards[i].configId,
          count = ret.rewards[i].count
        }
      end
      if 0 < #data then
        Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
      end
      self:refreshRewardState(true)
      self.uiBinder.btn_receive.IsDisabled = true
    end
  end)
  self:RefreshReceiveBtnState()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_list_fish, collection_reward_list_item, "collection_reward_list_item_tpl")
  self.loopListView_:Init(self.fashionLevelData_)
  self.uiBinder.lab_lv.text = ""
  local row = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.CollectionReward, true)
  if row then
    self.uiBinder.lab_title.text = row.Name
  else
    self.uiBinder.lab_title.text = ""
  end
end

function Collection_reward_popupView:refreshRewardState()
  local score = self.collectionVM_.GetFashionCollectionPoints()
  local fashionMgr = Z.ContainerMgr.CharSerialize.fashion
  for i = 1, #self.fashionLevelData_ do
    local row = self.fashionLevelData_[i].row
    self.fashionLevelData_[i].isComplete = score >= row.Score
    local isReceive = fashionMgr.fashionReward[row.Id]
    self.fashionLevelData_[i].isReceive = isReceive
    if isReceive then
      local redNodeName = string.zconcat("FashionCollectionScoreReward", row.Id)
      Z.RedPointMgr.UpdateNodeCount(redNodeName, 0)
      Z.RedPointMgr.RemoveChildNodeData(E.RedType.FashionCollectionScoreRewardRed, redNodeName)
    end
  end
  self.loopListView_:RefreshListView(self.fashionLevelData_, false)
end

function Collection_reward_popupView:RefreshReceiveBtnState()
  self.fashionLevelData_ = {}
  local score = self.collectionVM_.GetFashionCollectionPoints()
  local fashionMgr = Z.ContainerMgr.CharSerialize.fashion
  local isCanGet = false
  for _, row in ipairs(Z.TableMgr.GetTable("FashionCollectTableMgr").GetDatas()) do
    local isComplete = score >= row.Score
    local isReceive = fashionMgr.fashionReward[row.Id]
    isCanGet = isCanGet or isComplete and not isReceive
    self.fashionLevelData_[#self.fashionLevelData_ + 1] = {
      row = row,
      isComplete = score >= row.Score,
      isReceive = fashionMgr.fashionReward[row.Id]
    }
  end
  self.uiBinder.btn_receive.IsDisabled = not isCanGet
end

function Collection_reward_popupView:OnDeActive()
  self.loopListView_:UnInit()
end

return Collection_reward_popupView
