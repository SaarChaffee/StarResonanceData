local super = require("ui.component.loopscrollrectitem")
local UnionListItem = class("UnionListItem", super)
local unionLogoItem = require("ui.component.union.union_logo_item")
local unionTagItem = require("ui.component.union.union_tag_item")
local reportDefine = require("ui.model.report_define")

function UnionListItem:OnInit()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.reportVm_ = Z.VMMgr.GetVM("report")
  self:AddAsyncClick(self.uiBinder.btn_apply, function()
    self:onApplyBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_panel, function()
    local viewData = {
      ViewType = E.UnionRecruitViewType.List,
      UnionDataList = self.parent.uiView.curUnionListData_,
      UnionIndex = self.component.Index + 1
    }
    self.unionVM_:OpenUnionRecruitDetailView(viewData)
  end)
  self:AddAsyncClick(self.uiBinder.btn_panel.OnLongPressEvent, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, self.reportVm_.IsReportOpen(true))
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.btn_report, function()
    if self.data_ then
      self.reportVm_.OpenReportPop(reportDefine.ReportScene.UnionInfo, self.data_.baseInfo.Name, self.data_.baseInfo.Id)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, false)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, false)
  end)
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Normal, self.parent.uiView, self.uiBinder.trans_time_tag, self.uiBinder.trans_activity_tag)
  self.Logo_ = unionLogoItem.new()
  self.Logo_:Init(self.uiBinder.binder_logo.Go)
end

function UnionListItem:OnUnInit()
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
  self.Logo_:UnInit()
  self.Logo_ = nil
end

function UnionListItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  local logoData = self.unionVM_:GetLogoData(self.data_.baseInfo.Icon)
  self.Logo_:SetLogo(logoData)
  self.uiBinder.lab_name.text = self.data_.baseInfo.Name
  self.uiBinder.lab_grade.text = self.data_.baseInfo.level
  self.uiBinder.lab_active.text = self.data_.baseInfo.num .. "/" .. self.data_.baseInfo.maxNum
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.data_.presidentInfo.basicData.isNewbie))
  self.uiBinder.lab_president.text = self.data_.presidentInfo.basicData.name
  if self.data_.baseInfo.slogan == nil or self.data_.baseInfo.slogan == "" then
    self.uiBinder.lab_content.text = Lang("Notset")
  else
    self.uiBinder.lab_content.text = self.data_.baseInfo.slogan
  end
  local isHadUnion = self.unionVM_:GetPlayerUnionId() ~= 0
  local isHadApply = self.data_.isReq
  local isCurUnion = self.unionVM_:GetPlayerUnionId() == self.data_.baseInfo.Id
  self.uiBinder.btn_apply.IsDisabled = isHadUnion
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_apply, not isHadUnion and not isHadApply)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_had_apply, not isHadUnion and isHadApply)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_cur_union, isCurUnion)
  self:refreshTagUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, false)
end

function UnionListItem:refreshTagUI()
  local tagIdList = self.data_.baseInfo.tags
  self.unionTagItem_:SetCommonTagUI(tagIdList, self.uiBinder, "listTag_" .. self.component.Index + 1)
end

function UnionListItem:onApplyBtnClick()
  if self.unionVM_:GetPlayerUnionId() ~= 0 then
    return
  end
  self.parent.uiView:onRequestJoinBtnClick(self.data_.baseInfo.Id)
end

return UnionListItem
