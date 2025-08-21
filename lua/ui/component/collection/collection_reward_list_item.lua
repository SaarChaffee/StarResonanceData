local super = require("ui.component.loop_list_view_item")
local CollectionRewardListItem = class("CollectionRewardListItem", super)
local loopListView = require("ui.component.loop_list_view")
local commonRewardItem = require("ui.component.explore_monster.explore_monster_reward_item")

function CollectionRewardListItem:OnInit()
  self.awardScrollRect_ = loopListView.new(self.parent.UIView, self.uiBinder.loop_list_item, commonRewardItem, "com_item_square_8")
  self.awardScrollRect_:Init({})
  self.uiBinder.btn_receive:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local collectionVM = Z.VMMgr.GetVM("collection")
      local ret = collectionVM.AsyncGetFashionCollectionAward({
        self.data_.row.Id
      }, self.parent.UIView.cancelSource:CreateToken())
      if ret then
        local data = {}
        for i = 1, #ret.rewards do
          data[#data + 1] = {
            configId = ret.rewards[i].configId,
            count = ret.rewards[i].count
          }
        end
        Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
        self:refreshState(true, true)
        local redNodeName = string.zconcat("FashionCollectionScoreReward", self.data_.row.Id)
        Z.RedPointMgr.UpdateNodeCount(redNodeName, 0)
        Z.RedPointMgr.RemoveChildNodeData(E.RedType.FashionCollectionScoreRewardRed, redNodeName)
        self.parent.UIView:RefreshReceiveBtnState()
      end
    end)()
  end)
end

function CollectionRewardListItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_lv.text = data.row.Score
  self.uiBinder.lab_content.text = Lang("CollectionRewardListItem", {
    val = data.row.Score
  })
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(data.row.AwardId)
  for _, v in pairs(awardList) do
    v.beGet = false
  end
  self.awardScrollRect_:RefreshListView(awardList)
  self:refreshState(data.isComplete, data.isReceive)
end

function CollectionRewardListItem:refreshState(isComplete, isReceive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_complete, isComplete and isReceive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_receive, isComplete and not isReceive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_ing, not isComplete and not isReceive)
end

function CollectionRewardListItem:OnUnInit()
  self.awardScrollRect_:UnInit()
  self.uiBinder.btn_receive:RemoveAllListeners()
end

return CollectionRewardListItem
