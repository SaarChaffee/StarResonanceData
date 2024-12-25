local super = require("ui.component.loop_list_view_item")
local EquipBlessingLoopListItem = class("EquipBlessingLoopListItem", super)
local item = require("common.item_binder")

function EquipBlessingLoopListItem:ctor()
  self.itemData_ = nil
  super:ctor()
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipSystemVm_ = Z.VMMgr.GetVM("equip_system")
  self.equipRefineData_ = Z.DataMgr.Get("equip_refine_data")
end

function EquipBlessingLoopListItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = item.new(self.uiView_)
  self.selectedCount_ = 0
  self.itemClass_:Init({
    uiBinder = self.uiBinder.com_item_long_76
  })
  self.parent.UIView:AddClick(self.uiBinder.cont_num_module_tpl_new.btn_add, function()
    local count = self.selectedCount_ + 1
    self.parent:SetSelected(self.Index)
    if count > self.maxCount_ then
      count = self.maxCount_
    end
    self:checkRate(count)
  end)
  self.parent.UIView:AddClick(self.uiBinder.cont_num_module_tpl_new.btn_reduce, function()
    local count = self.selectedCount_ - 1
    self.parent:SetSelected(self.Index)
    if count < 0 or self.selectedCount_ == count then
      return
    end
    self.selectedCount_ = count
    self:refreshNum()
  end)
  self.parent.UIView:AddClick(self.uiBinder.cont_num_module_tpl_new.btn_max, function()
    if self.selectedCount_ == self.maxCount_ then
      if self.equipRefineData_.CurrentSuccessRate == 100 then
        Z.TipsVM.ShowTips(150018)
      end
      return
    end
    self.parent:SetSelected(self.Index)
    self:checkRate(self.maxCount_)
  end)
  self.parent.UIView:AddClick(self.uiBinder.cont_num_module_tpl_new.slider_temp, function(value)
    local value = math.floor(value)
    if self.selectedCount_ ~= value then
      self.parent:SetSelected(self.Index)
      if value > self.selectedCount_ then
        if self:checkRate(value) then
          self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
        end
      else
        self.selectedCount_ = value
        self:refreshNum()
      end
    end
  end)
end

function EquipBlessingLoopListItem:checkRate(count)
  if self.equipRefineData_.CurrentSuccessRate >= 100 then
    Z.TipsVM.ShowTips(150018)
    return true
  end
  if self.selectedCount_ == count then
    return
  end
  local rate = self.equipRefineData_.BaseSuccessRate + self.rate_ * count
  if 100 < rate then
    if not Z.UIMgr:IsActive("dialog") then
      self.uiView_:StopCheck()
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("EquipRefineExceedMaxSuccessRate", {val = rate}), function()
        self.selectedCount_ = count
        self:refreshNum()
        self.uiView_:StartCheck()
        Z.DialogViewDataMgr:CloseDialogView()
      end, function()
        self.uiView_:StartCheck()
        self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
        Z.DialogViewDataMgr:CloseDialogView()
      end)
    end
  else
    self.selectedCount_ = count
    self:refreshNum()
  end
end

function EquipBlessingLoopListItem:OnRefresh(data)
  self.data_ = data
  self:initUi()
end

function EquipBlessingLoopListItem:initUi()
  self.selectedCount_ = self.uiView_:GetSelectedCount(self.data_) or 0
  local itemCount = self.itemsVm_.GetItemTotalCount(self.data_)
  self.uiBinder.cont_num_module_tpl_new.Ref.UIComp:SetVisible(0 < itemCount)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, itemCount == 0)
  self.itemClass_:RefreshByData({
    uiBinder = self.uiBinder.com_item_long_76,
    configId = self.data_,
    lab = itemCount
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.selectedCount_ = self.uiView_:GetSelectedCount(self.data_) or 0
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.data_)
  local blessingRow = Z.TableMgr.GetRow("EquipRefineBlessingTableMgr", self.data_)
  self.uiBinder.lab_name.text = itemRow.Name
  self.rate_ = math.floor(blessingRow.EffectParameter / 100)
  local expendCount = math.ceil((100 - self.equipRefineData_.BaseSuccessRate) / self.rate_)
  self.maxCount_ = math.min(expendCount, itemCount)
  local rateStr = Z.RichTextHelper.ApplyColorTag(string.zconcat("+", self.rate_, "%"), "#cce992")
  self.uiBinder.lab_probability.text = Lang("EquipRefineBlessingProbabilityTips", {val = rateStr})
  self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
  self.uiBinder.lab_num.text = self.selectedCount_
  self.uiBinder.cont_num_module_tpl_new.slider_temp.minValue = 0
  self.uiBinder.cont_num_module_tpl_new.slider_temp.maxValue = self.maxCount_
end

function EquipBlessingLoopListItem:refreshNum()
  self.uiBinder.lab_num.text = self.selectedCount_
  if self.uiBinder.cont_num_module_tpl_new.slider_temp.value ~= self.selectedCount_ then
    self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
  end
  self.uiView_:OnChangeNum(self.data_, self.selectedCount_, self.selectedCount_ * self.rate_)
end

function EquipBlessingLoopListItem:OnSelected(isSelected)
  if isSelected then
    if self.maxCount_ == 0 then
      Z.TipsVM.ShowTips(150019)
      self.parent:UnSelectIndex(self.Index)
      return
    end
    self.uiView_:OnSelectedItem(self.data_, self.selectedCount_, self.selectedCount_ * self.rate_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function EquipBlessingLoopListItem:OnUnInit()
  self.itemClass_:UnInit()
end

return EquipBlessingLoopListItem
