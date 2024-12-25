local super = require("ui.component.loopscrollrectitem")
local FriendDegreeItem = class("FriendDegreeItem", super)
local item = require("common.item_binder")

function FriendDegreeItem:ctor()
end

function FriendDegreeItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
end

function FriendDegreeItem:Refresh()
  self:onInitData()
end

function FriendDegreeItem:onInitData()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.uiBinder.lab_on.text = self.data_.Level
  self.uiBinder.lab_off.text = self.data_.Level
  local isCanGet = self.friendMainData_:GetFriendlinessLevel() >= self.data_.Level
  local isShowReceive = table.zcontains(self.friendMainData_:GetFriendlinessAwardList(), self.data_.Level)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isCanGet)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_get, isCanGet)
  self:updateAwardInfo(isShowReceive, isCanGet)
end

function FriendDegreeItem:updateAwardInfo(isShowReceive, isCanGet)
  local itemData = {}
  if self.data_.AwardID and self.data_.AwardID ~= 0 then
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(self.data_.AwardID)
    local value = awardList[1]
    if not value then
      self.uiBinder.cont_item.Ref.UIComp:SetVisible(false)
      return
    end
    itemData = {
      uiBinder = self.uiBinder.cont_item,
      configId = value.awardId,
      isSquareItem = true,
      PrevDropType = value.PrevDropType,
      isShowReceive = isShowReceive
    }
    itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
  else
    itemData = {
      uiBinder = self.uiBinder.cont_item,
      configId = self.data_.RewardID[1][1],
      lab = 1,
      isSquareItem = true,
      isShowReceive = isShowReceive
    }
  end
  if not isShowReceive and isCanGet then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, true)
    
    function itemData.clickCallFunc()
      local ret = self.friendsMainVm_.RewardTotalFriendlinessLv(self.data_.Level, self.parent.uiView.cancelSource:CreateToken())
      if ret.errCode == 0 then
        itemData.isShowReceive = true
        itemData.clickCallFunc = nil
        self.itemClass_:Init(itemData)
        self.friendMainData_:AddFriendlinessAwardList(self.data_.Level)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, false)
        local materials = {}
        table.insert(materials, {
          configId = itemData.configId,
          count = itemData.lab
        })
        local itemShowVm = Z.VMMgr.GetVM("item_show")
        itemShowVm.OpenItemShowView(materials)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, false)
  end
  
  function itemData.goToCallFunc()
    Z.UIMgr:CloseView("friend_degree_window")
  end
  
  self.itemClass_:Init(itemData)
  self.uiBinder.cont_item.Ref.UIComp:SetVisible(true)
end

function FriendDegreeItem:Selected(isSelected)
end

function FriendDegreeItem:OnUnInit()
  self.itemClass_:UnInit()
end

function FriendDegreeItem:OnReset()
end

return FriendDegreeItem
