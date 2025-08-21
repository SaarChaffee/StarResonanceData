local super = require("ui.component.loop_list_view_item")
local CollectionMemberShipList = class("CollectionMemberShipList", super)
local loopListView = require("ui.component.loop_list_view")
local collection_membership_list_item = require("ui.component.collection.collection_membership_list_item")

function CollectionMemberShipList:OnInit()
  self.itemsDecomposeListView_ = loopListView.new(self, self.uiBinder.loop_item, collection_membership_list_item, "com_item_square_8")
  self.itemsDecomposeListView_:Init({})
  self.collectionVM_ = Z.VMMgr.GetVM("collection")
end

function CollectionMemberShipList:OnRefresh(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_can_get, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_got, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_cannot_get, false)
  if data.Type == E.FashionPrivilegeType.MoonGift then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_img, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade, true)
    local awardState = self.collectionVM_.GetMoonGiftRewardState(data.Id)
    if awardState == E.ReceiveRewardStatus.Received then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_got, true)
    elseif awardState == E.ReceiveRewardStatus.CanReceive then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_can_get, true)
      self.uiBinder.btn_get:RemoveAllListeners()
      self.uiBinder.btn_get:AddListener(function()
        Z.CoroUtil.create_coro_xpcall(function()
          self.collectionVM_.AsyncGetFashionBenefitReward(data.Id, self.parent.UIView.cancelSource:CreateToken())
        end)()
      end)
    elseif awardState == E.ReceiveRewardStatus.NotReceive then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_cannot_get, true)
    end
    local name, level = self.collectionVM_.GetFashionLevelNameByPrivilegeId(data.Id)
    self.uiBinder.lab_level.text = name
    self.uiBinder.img_grade:SetImage(string.zconcat("ui/atlas/collection/collection_grade_", level))
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(data.Parameter)
    for i = 1, #awardList do
      awardList[i].Type = E.FashionPrivilegeType.MoonGift
    end
    self.itemsDecomposeListView_:RefreshListView(awardList, false)
  elseif data.Type == E.FashionPrivilegeType.ExclusiveShop then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_img, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade, true)
    self.uiBinder.lab_level.text = data.Name
    self.uiBinder.img_grade:SetImage(string.zconcat("ui/atlas/collection/collection_grade_", data.Level))
    local showList = {}
    for i = 1, #data.MallList do
      showList[#showList + 1] = {
        row = data.MallList[i],
        Type = E.FashionPrivilegeType.ExclusiveShop
      }
    end
    self.itemsDecomposeListView_:RefreshListView(showList, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_img, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade, false)
    self.uiBinder.lab_level.text = ""
    self.uiBinder.lab_up.text = ""
    self.uiBinder.lab_down.text = ""
  end
end

function CollectionMemberShipList:OnUnInit()
  self.itemsDecomposeListView_:UnInit()
end

return CollectionMemberShipList
