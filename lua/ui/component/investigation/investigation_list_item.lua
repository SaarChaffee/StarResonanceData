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
    self:updateItemState(investigationsTableRow.InvestigationTheme, true, true, false, false)
  elseif self.data_.State == E.InvestigationState.EFinish then
    self:updateItemState(investigationsTableRow.InvestigationTheme, true, true, true, false)
  elseif self.data_.State == E.InvestigationState.ELock then
    self:updateItemState("", false, false, false, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function InvestigationListItem:updateItemState(labName, isShowNameLab, isShowImgOn, isShowImgRight, isShowImgOff)
  self.uiBinder.lab_name.text = labName
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name, isShowNameLab)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isShowImgOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_right, isShowImgRight)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, isShowImgOff)
end

function InvestigationListItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if true == isSelected and self.data_ then
    self.parent.UIView:OnSelectInvestigation(self.data_.InvestigationId)
  end
end

return InvestigationListItem
