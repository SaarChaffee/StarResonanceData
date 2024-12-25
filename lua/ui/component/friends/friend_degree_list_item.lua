local super = require("ui.component.loopscrollrectitem")
local FriendDegreeListItem = class("FriendDegreeListItem", super)
local item = require("common.item_binder")

function FriendDegreeListItem:ctor()
end

function FriendDegreeListItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
end

function FriendDegreeListItem:Refresh()
  self:onInitData()
end

function FriendDegreeListItem:onInitData()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.uiBinder.lab_energy_num.text = self.data_.Level
  self.uiBinder.lab_info.text = self.data_.Content
  self:updateAwardInfo()
end

function FriendDegreeListItem:updateAwardInfo()
  local friendLinessData = self.friendMainData_:GetFriendLinessData(self.parent.uiView.viewData.charId)
  if not friendLinessData then
    return
  end
  local isShowReceive = table.zcontains(friendLinessData.friendLinessGetAwardList, self.data_.Level)
  local isCanGet = self.data_.Level <= friendLinessData.friendLinessLevel
  self.uiBinder.lab_info_ref:SetWidth(569)
  if #self.data_.RewardID >= 1 and #self.data_.RewardID[1] >= 2 then
    local awardItemId = self.data_.RewardID[1][1]
    local awardItemCount = self.data_.RewardID[1][2]
    if awardItemId and awardItemCount then
      local itemData = {
        uiBinder = self.uiBinder.cont_item,
        configId = awardItemId,
        labType = E.ItemLabType.Str,
        lab = awardItemCount,
        isSquareItem = true,
        isShowReceive = isShowReceive
      }
      self:initRewardItem(itemData, isShowReceive, isCanGet)
    end
  elseif self.data_.AwardID and self.data_.AwardID ~= 0 then
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(self.data_.AwardID)
    local value = awardList[1]
    local itemData = {
      uiBinder = self.uiBinder.cont_item,
      configId = value.awardId,
      isSquareItem = true,
      isShowReceive = isShowReceive
    }
    itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
    self:initRewardItem(itemData, isShowReceive, isCanGet)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_red, false)
    self.uiBinder.lab_info_ref:SetWidth(700)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_slider, isCanGet)
end

function FriendDegreeListItem:initRewardItem(itemData, isShowReceive, isCanGet)
  if not isShowReceive and isCanGet then
    function itemData.clickCallFunc()
      local ret = self.friendsMainVm_.RewardPersonalFriendlinessLv(self.parent.uiView.viewData.charId, self.data_.Level, self.parent.uiView.cancelSource:CreateToken())
      
      if ret.errCode == 0 then
        itemData.isShowReceive = true
        itemData.clickCallFunc = nil
        self.itemClass_:Init(itemData)
        self.friendMainData_:AddFriendLinessAwardId(self.parent.uiView.viewData.charId, self.data_.Level)
        local materials = {}
        table.insert(materials, {
          configId = itemData.configId,
          count = itemData.lab
        })
        local itemShowVm = Z.VMMgr.GetVM("item_show")
        itemShowVm.OpenItemShowView(materials)
        self.uiBinder.Ref:SetVisible(self.uiBinder.group_red, false)
      else
        Z.TipsVM.ShowTips(ret.errCode)
      end
    end
    
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_red, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_red, false)
  end
  
  function itemData.goToCallFunc()
    Z.UIMgr:CloseView("friend_degree_popup")
  end
  
  self.itemClass_:Init(itemData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
end

function FriendDegreeListItem:Selected(isSelected)
end

function FriendDegreeListItem:OnUnInit()
  self.itemClass_:UnInit()
end

function FriendDegreeListItem:OnReset()
end

return FriendDegreeListItem
