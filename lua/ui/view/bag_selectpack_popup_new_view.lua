local UI = Z.UI
local super = require("ui.ui_view_base")
local Bag_selectpack_popup_newView = class("Bag_selectpack_popup_newView", super)
local loopListView = require("ui.component.loop_list_view")
local bagSelectFashionItem = require("ui.component.bag.bag_select_fashion_item")
local bagFashionItemWidth = 386
local bagFashionItemOffset = 80
local windowOpenEffect = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit"

function Bag_selectpack_popup_newView:ctor()
  self.uiBinder = nil
  super.ctor(self, "bag_selectpack_popup_new")
end

function Bag_selectpack_popup_newView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:CreatEFFGO(windowOpenEffect, Vector3.zero)
  self.uiBinder.node_effect:SetEffectGoVisible(true)
  self.uiBinder.btn_no:AddListener(function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_yes, function()
    if not self.selectIndex_ then
      return
    end
    self:useItem()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self.uiBinder.btn_yes.IsDisabled = true
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, bagSelectFashionItem, "bag_selectpack_item_tpl_new")
  self:initSelectData()
end

function Bag_selectpack_popup_newView:OnDeActive()
  self.selectIndex_ = nil
  self.loopListView_:UnInit()
  self.uiBinder.node_effect:ReleseEffGo()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
end

function Bag_selectpack_popup_newView:OnShow()
  self.uiBinder.anim:PlayOnce("anim_bag_selectpack_popup_new_open_01")
  self.uiBinder.anim_dotween:Play(Z.DOTweenAnimType.Open)
end

function Bag_selectpack_popup_newView:OnHide()
  self.uiBinder.anim:PlayOnce("anim_bag_selectpack_popup_new_open_start")
end

function Bag_selectpack_popup_newView:initSelectData()
  local awardPreviewVM = Z.VMMgr.GetVM("awardpreview")
  local awardTableList = awardPreviewVM.GetAllAwardPreListByIds(self.viewData.awardId)
  if not awardTableList then
    return
  end
  if self.viewData.itemId then
    self.itemFunctionTable_ = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(self.viewData.itemId)
  end
  if self.itemFunctionTable_ and self.itemFunctionTable_.TipText and self.itemFunctionTable_.TipText ~= "" then
    self.uiBinder.lab_content.text = self.itemFunctionTable_.TipText
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, false)
  end
  self.selectData_ = {}
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr")
  for i = 1, #awardTableList do
    local itemData = {}
    local awardTable = awardTableList[i]
    itemData.itemId = awardTable.awardId
    itemData.itemNum = awardTable.awardNum
    itemData.bindInfo = awardTable.BindInfo and awardTable.BindInfo[i] or 0
    itemData.index = awardTable.Index
    itemData.selectNum = 0
    itemData.isLimit = false
    itemData.isHave = false
    itemData.showIndex = i
    if self.itemFunctionTable_ then
      local limitTypeList = self.itemFunctionTable_.RepeatLimit
      local itemTable = itemTable.GetRow(itemData.itemId)
      for i = 1, #limitTypeList do
        if itemTable.Type == limitTypeList[i] then
          local itemsVM = Z.VMMgr.GetVM("items")
          local ownNum = itemsVM.GetItemTotalCount(itemData.itemId)
          itemData.isHave = 0 < ownNum
          itemData.isLimit = true
          break
        end
      end
    end
    self.selectData_[#self.selectData_ + 1] = itemData
  end
  table.sort(self.selectData_, function(left, right)
    if left.isHave then
      if right.isHave then
        return left.showIndex < right.showIndex
      else
        return false
      end
    elseif right.isHave then
      return true
    else
      return left.showIndex < right.showIndex
    end
  end)
  self.loopListView_:SetIsCenter(#self.selectData_ <= 3)
  self.loopListView_:Init(self.selectData_)
end

function Bag_selectpack_popup_newView:SetSelected(index, awardIndex)
  self.loopListView_:SetSelected(index)
  self.selectIndex_ = awardIndex - 1
  self.uiBinder.btn_yes.IsDisabled = false
end

function Bag_selectpack_popup_newView:useItem()
  local itemsVM = Z.VMMgr.GetVM("items")
  local selectData = {
    [self.selectIndex_] = 1
  }
  local param = itemsVM.AssembleUseItemParam(self.viewData.itemId, self.viewData.itemUuid, 1)
  param.select = selectData
  itemsVM.AsyncUseItemByUuid(param, self.cancelSource:CreateToken())
end

function Bag_selectpack_popup_newView:OnInputBack()
  if self.IsResponseInput then
    Z.UIMgr:CloseView(self.viewConfigKey)
  end
end

return Bag_selectpack_popup_newView
