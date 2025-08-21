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
    if self.maxUseCount_ == self.selectedCount_ then
      Z.TipsVM.ShowTips(150031, {
        val = self.maxUseCount_
      })
      return
    end
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
  Z.EventMgr:Add(Z.ConstValue.Equip.RefineRateChange, self.refineRateChange, self)
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
      end, function()
        self.uiView_:StartCheck()
        self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
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
  if self.IsSelected then
    self:SetCanSelect(false)
  end
end

function EquipBlessingLoopListItem:initUi()
  local selectedInfo = self.uiView_:GetSelectedInfo(self.data_)
  self.selectedCount_ = selectedInfo and selectedInfo.num or 0
  self.itemCount_ = self.itemsVm_.GetItemTotalCount(self.data_)
  self.uiBinder.cont_num_module_tpl_new.Ref.UIComp:SetVisible(0 < self.itemCount_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, self.itemCount_ == 0)
  self.itemClass_:RefreshByData({
    uiBinder = self.uiBinder.com_item_long_76,
    configId = self.data_,
    lab = self.itemCount_
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, selectedInfo ~= nil)
  if selectedInfo then
  end
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.data_)
  self.uiBinder.lab_name.text = itemRow.Name
  local blessingRow = Z.TableMgr.GetRow("EquipRefineBlessingTableMgr", self.data_)
  self.maxUseCount_ = 0
  self.rate_ = 0
  if blessingRow then
    self.maxUseCount_ = blessingRow.UseMaxNum
    self.rate_ = math.floor(blessingRow.EffectParameter / 100)
  end
  local expendCount = math.ceil((100 - self.equipRefineData_.BaseSuccessRate) / self.rate_)
  self.maxCount_ = math.min(expendCount, self.itemCount_, self.maxUseCount_)
  self.uiBinder.lab_num.text = self.selectedCount_ .. "/" .. self.maxUseCount_
  local rateStr = Z.RichTextHelper.ApplyColorTag(string.zconcat("+", self.rate_, "%"), "#cce992")
  self.uiBinder.lab_probability.text = Lang("EquipRefineBlessingProbabilityTips", {val = rateStr})
  self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
  self.uiBinder.cont_num_module_tpl_new.slider_temp.minValue = 0
  self.uiBinder.cont_num_module_tpl_new.slider_temp.maxValue = self.maxCount_
end

function EquipBlessingLoopListItem:refreshNum()
  self.uiBinder.lab_num.text = self.selectedCount_ .. "/" .. self.maxUseCount_
  if self.uiBinder.cont_num_module_tpl_new.slider_temp.value ~= self.selectedCount_ then
    self.uiBinder.cont_num_module_tpl_new.slider_temp.value = self.selectedCount_
  end
  self.uiView_:OnChangeNum(self.data_, self.selectedCount_, self.selectedCount_ * self.rate_)
  if self.selectedCount_ == 0 then
    self.parent:UnSelectIndex(self.Index)
  end
end

function EquipBlessingLoopListItem:OnSelected(isSelected)
  if table.zcount(self.equipRefineData_.CurSelBlessingData) == Z.Global.MaxEquipEnchantItemNum and not self.equipRefineData_.CurSelBlessingData[self.data_] then
    Z.TipsVM.ShowTips(150030, {
      val = Z.Global.MaxEquipEnchantItemNum
    })
    self.parent:UnSelectIndex(self.Index)
    return
  end
  self:SetCanSelect(not isSelected)
  if isSelected then
    if self.maxCount_ == 0 then
      Z.TipsVM.ShowTips(150019)
      self.parent:UnSelectIndex(self.Index)
      return
    end
    if self.selectedCount_ == 0 then
      self.selectedCount_ = 1
      self:refreshNum()
    end
    self.uiView_:OnSelectedItem(self.data_, self.selectedCount_, self.selectedCount_ * self.rate_)
  else
    self.equipRefineData_.CurSelBlessingData[self.data_] = nil
    Z.EventMgr:Dispatch(Z.ConstValue.Equip.EquipRefreshSelBlessingData)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function EquipBlessingLoopListItem:refineRateChange()
  local expendCount = math.ceil((100 - self.equipRefineData_.CurrentSuccessRate) / self.rate_) + self.selectedCount_
  self.maxCount_ = math.min(expendCount, self.itemCount_, self.maxUseCount_)
  self.uiBinder.cont_num_module_tpl_new.slider_temp.maxValue = self.maxCount_
end

function EquipBlessingLoopListItem:OnUnInit()
  self.itemClass_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Equip.RefineRateChange, self.refineRateChange, self)
end

return EquipBlessingLoopListItem
