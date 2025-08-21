local UI = Z.UI
local super = require("ui.ui_view_base")
local Collection_membership_popupView = class("Collection_membership_popupView", super)
local MallItemTableMap = require("table.MallItemTableMap")
local loopListView = require("ui.component.loop_list_view")
local collection_membership_list = require("ui.component.collection.collection_membership_list")
local collection_membership_item = require("ui.component.collection.collection_membership_item")

function Collection_membership_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "collection_membership_popup")
  self.collectionVM_ = Z.VMMgr.GetVM("collection")
end

function Collection_membership_popupView:OnActive()
  self.openFirstTime = true
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.node_eff:SetEffectGoVisible(true)
  self.curPrivilegeRow_ = self.viewData.row
  self.loopItemListView_ = loopListView.new(self, self.uiBinder.loop_item, collection_membership_list, "collection_membership_list_tpl")
  self.loopItemListView_:Init({})
  self.loopBottomListView_ = loopListView.new(self, self.uiBinder.loop_bottom, collection_membership_item, "collection_membership_item_tpl")
  self.loopBottomListView_:Init({})
  self:BindBtnClick()
  local curLevel = Z.CollectionScoreHelper.GetCollectionCurLevel()
  local row = Z.TableMgr.GetTable("FashionLevelTableMgr").GetRow(curLevel)
  if row then
    self.uiBinder.lab_vip.text = row.Name
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade, true)
    self.uiBinder.img_grade:SetImage(string.zconcat("ui/atlas/collection/collection_grade_", curLevel))
    local img = string.zconcat(Z.ConstValue.Collection.CollectionTextureIconPath, row.Icon)
    self.uiBinder.rimg_icon:SetImage(img)
    self.uiBinder.rimg_icon_shadow:SetImage(img)
  else
    self.uiBinder.lab_vip.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade, false)
  end
  self:refreshBottomList()
  self:bindEvent()
end

function Collection_membership_popupView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Collection.FashionBenefitChange, self.refreshViewData, self)
end

function Collection_membership_popupView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Collection.FashionBenefitChange, self.refreshViewData, self)
end

function Collection_membership_popupView:refreshViewData()
  if self.curPrivilegeRow_.Type == E.FashionPrivilegeType.MoonGift then
    self:refreshMoonGift()
  end
end

function Collection_membership_popupView:BindBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("collection_membership_popup")
  end)
  self:AddClick(self.uiBinder.btn_goto, function()
    local quickjumpVm = Z.VMMgr.GetVM("quick_jump")
    quickjumpVm.DoJumpByConfigParam(self.curPrivilegeRow_.QuickJumpType, self.curPrivilegeRow_.QuickJumpParam)
  end)
  self:AddAsyncClick(self.uiBinder.btn_gain_all, function()
    self.collectionVM_.AsyncGetFashionBenefitReward(0, self.cancelSource:CreateToken())
  end)
end

function Collection_membership_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.node_eff:SetEffectGoVisible(false)
  self.loopItemListView_:UnInit()
  self.loopBottomListView_:UnInit()
  self:unBindEvent()
end

function Collection_membership_popupView:refreshBottomList()
  local showList = {}
  local selectIndex = 1
  for i = #self.viewData.list, 1, -1 do
    showList[#showList + 1] = self.viewData.list[i]
    if self.viewData.list[i].row.Id == self.curPrivilegeRow_.Id then
      selectIndex = #showList
    end
  end
  self.loopBottomListView_:RefreshListView(showList, false)
  self.loopBottomListView_:ClearAllSelect()
  self.loopBottomListView_:SetSelected(selectIndex)
  self:OnSelectItem(showList[selectIndex])
end

function Collection_membership_popupView:OnSelectItem(data)
  self.curPrivilegeRow_ = data.row
  self.uiBinder.lab_name.text = self.curPrivilegeRow_.Name
  if self.curPrivilegeRow_.Type == E.FashionPrivilegeType.ExchangeShop then
    self:refreshExchangeShop()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, data.unlock)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_gain, false)
  elseif self.curPrivilegeRow_.Type == E.FashionPrivilegeType.ExclusiveShop then
    self:refreshExclusiveShop()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, data.unlock)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_gain, false)
  else
    self:refreshMoonGift()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_gain, true)
  end
end

function Collection_membership_popupView:refreshExchangeShop()
  if not self.openFirstTime then
    Z.AudioMgr:Play("sys_general_selecting")
  else
    self.openFirstTime = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_info, false)
  self.uiBinder.lab_content.text = Lang("CollectionPrivilegeExchangeShopTips")
  self.uiBinder.lab_tips.text = ""
end

function Collection_membership_popupView:refreshExclusiveShop()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_info, true)
  self.uiBinder.lab_content.text = ""
  local mallItemIdList = {}
  local shopVM = Z.VMMgr.GetVM("shop")
  for _, row in ipairs(Z.TableMgr.GetTable("FashionLevelTableMgr").GetDatas()) do
    local IdList = MallItemTableMap.UnlockConditions[row.Id]
    if IdList then
      local mallList = {}
      for i = 1, #IdList do
        local row = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(IdList[i], true)
        if row and shopVM.CheckUnlockCondition(row.ShowLimitType) then
          mallList[#mallList + 1] = row
        end
      end
      mallItemIdList[#mallItemIdList + 1] = {
        MallList = mallList,
        Name = row.Name,
        Level = row.Id,
        Type = E.FashionPrivilegeType.ExclusiveShop
      }
    end
  end
  self.loopItemListView_:RefreshListView(mallItemIdList, false)
  self.uiBinder.lab_tips.text = Lang("CollectionPrivilegeExclusiveShopTips")
end

function Collection_membership_popupView:refreshMoonGift()
  if not self.openFirstTime then
    Z.AudioMgr:Play("sys_general_selecting")
  else
    self.openFirstTime = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_info, true)
  local hasReward = self.collectionVM_.HasMoonRewardCanGain()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gain_all, hasReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gain_all_not, not hasReward)
  self.uiBinder.lab_tips.text = Lang("CollectionPrivilegeMoonGiftTips")
  local moonGiftList = {}
  local fashionData = Z.DataMgr.Get("fashion_data")
  for _, row in pairs(fashionData:GetAllFashionPrivilegeRows()) do
    if row.Type == E.FashionPrivilegeType.MoonGift then
      moonGiftList[#moonGiftList + 1] = row
    end
  end
  table.sort(moonGiftList, function(a, b)
    return a.Level < b.Level
  end)
  self.loopItemListView_:RefreshListView(moonGiftList, false)
end

function Collection_membership_popupView:onStartAnimSelected()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_0)
end

return Collection_membership_popupView
