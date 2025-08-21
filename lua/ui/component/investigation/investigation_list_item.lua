local super = require("ui.component.loop_list_view_item")
local InvestigationListItem = class("InvestigationListItem", super)

function InvestigationListItem:OnInit()
  self.investigationClueVm_ = Z.VMMgr.GetVM("investigationclue")
  self.investigationMainData_ = Z.DataMgr.Get("investigationclue_data")
end

function InvestigationListItem:OnRefresh(data)
  self.data_ = data
  if not self.data_ then
    return
  end
  local investigationsTableRow = self.investigationMainData_:GetInvestigationTable(self.data_.InvestigationId)
  if not investigationsTableRow then
    return
  end
  if self.data_.State == E.InvestigationState.EComplete or self.data_.State == E.InvestigationState.EUnLock then
    self:updateItemState(investigationsTableRow.InvestigationTheme, true, self.IsSelected, false, not self.IsSelected, false)
  elseif self.data_.State == E.InvestigationState.EFinish then
    self:updateItemState(investigationsTableRow.InvestigationTheme, true, self.IsSelected, true, not self.IsSelected, false)
  elseif self.data_.State == E.InvestigationState.ELock then
    self:updateItemState("", false, false, false, true, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function InvestigationListItem:updateItemState(labName, isShowNameLab, isShowImgOn, isShowImgRight, isShowImgOff, isLock)
  self.uiBinder.lab_name_on.text = labName
  self.uiBinder.lab_name_off.text = labName
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name_on, isShowNameLab)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name_off, isShowNameLab)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isShowImgOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_right, isShowImgRight)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, isShowImgOff)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_ask, isLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, isLock)
end

function InvestigationListItem:OnSelected(isSelected)
  if true == isSelected and self.data_ then
    self.parent.UIView:OnSelectInvestigation(self.data_.InvestigationId)
  end
  if self.data_.State == E.InvestigationState.ELock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

return InvestigationListItem
