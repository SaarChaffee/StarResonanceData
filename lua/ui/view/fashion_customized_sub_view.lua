local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_customized_subView = class("Fashion_customized_subView", super)
local loopListView = require("ui.component.loop_list_view")
local custom_Item = require("ui.component.fashion.fashion_custom_loop_item")
local unlock_Item = require("ui.component.fashion.fashion_unlock_loop_item")
local FashionAdvancedTableMap = require("table.FashionAdvancedTableMap")

function Fashion_customized_subView:ctor(parent)
  self.uiBinder = nil
  self.parentView_ = parent
  super.ctor(self, "fashion_customized_sub", "fashion/fashion_customized_sub", UI.ECacheLv.None, true)
end

function Fashion_customized_subView:OnActive()
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetWidth(Z.IsPCUI and 316 or 424)
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.isUnlock_ = false
  self.isUse_ = false
  self.baseIsUnclok_ = self.fashionVM_.GetFashionIsUnlock(self.viewData.fashionId)
  self:refreshBtnState()
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, false)
  self.customLoopList_ = loopListView.new(self, self.uiBinder.loop_list, custom_Item, "fashion_customized_tpl", true)
  self.customList_ = FashionAdvancedTableMap.FashionAdvanced[self.viewData.fashionId]
  if not self.customList_ then
    self.customList_ = {
      self.viewData.fashionId
    }
  end
  self.customLoopList_:Init(self.customList_)
  self.unlockLoopList_ = loopListView.new(self, self.uiBinder.loop_unlock, unlock_Item, "com_item_square_8", true)
  self.unlockLoopList_:Init({})
  local index = 1
  local wear = self.fashionData_:GetWear(self.viewData.region)
  if wear and wear.wearFashionId and 0 < wear.wearFashionId then
    for i = 1, #self.customList_ do
      if self.customList_[i] == wear.wearFashionId then
        index = i
        break
      end
    end
  end
  self.customLoopList_:SetSelected(index)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AllChange, self.refreshCustomList, self)
end

function Fashion_customized_subView:GetOriginalFashionId()
  return self.viewData.fashionId
end

function Fashion_customized_subView:OnDeActive()
  self.customLoopList_:UnInit()
  self.unlockLoopList_:UnInit()
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, false)
  Z.RedPointMgr.RemoveNodeItem(self.unlockRed_)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AllChange, self.refreshCustomList, self)
end

function Fashion_customized_subView:refreshCustomList()
  local index = self.customLoopList_:GetSelectedIndex()
  self.customLoopList_:RefreshListView(self.customList_, false)
  self.customLoopList_:ClearAllSelect()
  self.customLoopList_:SetSelected(index)
end

function Fashion_customized_subView:OnSelectFashion(fashionId, isUnlock, isCanUnlock, isUse)
  if isUnlock or fashionId == self.viewData.fashionId then
    self.unlockLoopList_:RefreshListView({}, false)
  else
    local row = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(fashionId, true)
    if row and row.Consume then
      local list = {}
      for i = 1, #row.Consume do
        list[#list + 1] = {
          ItemId = row.Consume[i][1],
          UnlockNum = row.Consume[i][2]
        }
      end
      self.unlockLoopList_:RefreshListView(list, false)
    else
      self.unlockLoopList_:RefreshListView({}, false)
    end
  end
  local wearData = self.fashionData_:GetWear(self.viewData.region)
  local originalFashionId = self.fashionVM_.GetOriginalFashionId(fashionId)
  if not wearData or wearData.wearFashionId ~= fashionId then
    local isUnlock = self.fashionVM_.GetFashionIsUnlock(originalFashionId)
    self.fashionVM_.SetFashionWear(self.viewData.region, {
      wearFashionId = fashionId,
      fashionId = originalFashionId,
      isUnlock = isUnlock
    })
    self.fashionData_:SetAdvanceSelectData(originalFashionId, fashionId)
  end
  self.isUnlock_ = isUnlock
  self.isCanUnlock_ = isCanUnlock
  self.isUse_ = isUse
  self.isAdvanced_ = self.viewData.fashionId ~= fashionId
  self.curFashionId_ = fashionId
  local usingFahsionId = self.fashionVM_.GetServerUsingFashionId(originalFashionId)
  self.isUsing_ = usingFahsionId == fashionId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_rewards, self.curFashionId_ ~= self.viewData.fashionId and not isUnlock)
  self:refreshBtnState()
  self:refreshCustomBtnRed()
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, self.showCustom_, self.customLab_, self.func_, self.isDisable_, self)
end

function Fashion_customized_subView:refreshBtnState()
  if not self.baseIsUnclok_ then
    self.customLab_ = "FashionAdvancedGetBaseFashion"
    self.func_ = self.openFashionTips
    self.isDisable_ = false
    self.showCustom_ = true
    return
  end
  if not self.isUnlock_ then
    self.customLab_ = "FashionCustomUnLock"
    self.func_ = self.asyncUnlockFashion
    self.isDisable_ = false
    self.showCustom_ = true
    return
  end
  if self.isUse_ then
    self.customLab_ = "FashionAdvancedUse"
    self.func_ = self.openStyleView
    self.isDisable_ = true
    self.showCustom_ = true
    return
  end
  if not self.isUsing_ then
    self.customLab_ = "FashionCustomSwitch"
    self.func_ = self.switchFashion
    self.isDisable_ = false
    self.showCustom_ = true
    return
  end
  self.showCustom_ = false
end

function Fashion_customized_subView:refreshCustomBtnRed()
  if self.unlockRed_ then
    Z.RedPointMgr.RemoveNodeItem(self.unlockRed_)
  end
  self.unlockRed_ = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, self.curFashionId_)
  Z.RedPointMgr.LoadRedDotItem(self.unlockRed_, self, self.parentView_:GetBtnCustomRef())
end

function Fashion_customized_subView:asyncUnlockFashion()
  if not self.curFashionId_ then
    return
  end
  if not self.isCanUnlock_ then
    Z.TipsVM.ShowTips(100002)
    return
  end
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = Lang("FashionCustomizedUnlockTips"),
    onConfirm = function()
      local ret = self.fashionVM_.UnlockAdvanceFashion(self.curFashionId_, self.cancelSource:CreateToken())
      if not ret then
        return
      end
      Z.RedPointMgr.OnClickRedDot(self.unlockRed_)
      Z.RedPointMgr.UpdateNodeCount(self.unlockRed_, 0)
      Z.RedPointMgr.RefreshRedNodeState(self.unlockRed_)
      local index = self.customLoopList_:GetSelectedIndex()
      self.customLoopList_:RefreshListView(self.customList_, false)
      self.customLoopList_:ClearAllSelect()
      self.customLoopList_:SetSelected(index)
    end
  }
  Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
end

function Fashion_customized_subView:saveFashion()
  self.fashionVM_.AsyncSaveAllFashion(self.cancelSource)
  self.customLoopList_:RefreshListView(self.customList_, false)
end

function Fashion_customized_subView:openStyleView()
  self.viewData.parentView:OpenStyleView()
end

function Fashion_customized_subView:switchFashion()
  local originalFashionId = self.fashionVM_.GetOriginalFashionId(self.curFashionId_)
  local ret = self.fashionVM_.AsyncSaveFashionTryOn(originalFashionId, self.curFashionId_, self.cancelSource:CreateToken())
  if ret == 0 then
    Z.TipsVM.ShowTips(120025)
  end
  self:refreshCustomList()
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, false)
end

function Fashion_customized_subView:openFashionTips()
  Z.TipsVM.ShowItemTipsView(self.uiBinder.node_tips, self.viewData.fashionId)
end

return Fashion_customized_subView
