local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_label_tipsView = class("Union_label_tipsView", super)
local unionTagItem = require("ui.component.union.union_tag_item")
local ViewType = {Union = 1, Personalzone = 2}

function Union_label_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_label_tips")
end

function Union_label_tipsView:OnActive()
  self.uiBinder.adapt_pos_tips:UpdatePosition(self.viewData.trans, true)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.unionTagTableMgr_ = Z.TableMgr.GetTable("UnionTagTableMgr")
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Label, self, self.uiBinder.trans_time_icon, self.uiBinder.trans_activity_icon)
  self.unionTagItem_:SetTag(self.viewData.tagList)
  if self.viewData.type == ViewType.Union then
    self.uiBinder.lab_name_1.text = Lang("UnionResidencyTime")
    self.uiBinder.lab_name_2.text = Lang("Associationmemberactivitytag")
  elseif self.viewData.type == ViewType.Personalzone then
    self.uiBinder.lab_name_1.text = Lang("PersonalzoneResidencyTime")
    self.uiBinder.lab_name_2.text = Lang("PersonalzoneActivityLabel")
  end
  local isHaveTimeTag, isHaveActivityTag = self:getUnionTagShowState(self.viewData.tagList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_time_title, isHaveTimeTag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_time_icon, isHaveTimeTag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_activity_title, isHaveActivityTag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_activity_icon, isHaveActivityTag)
end

function Union_label_tipsView:OnDeActive()
  self.uiBinder.presscheck.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.presscheck:StopCheck()
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
end

function Union_label_tipsView:OnRefresh()
end

function Union_label_tipsView:getUnionTagShowState(tagConfigList)
  local isHaveTimeTag = false
  local isHaveActivityTag = false
  for i, config in ipairs(tagConfigList) do
    if config.Type == E.UnionTagType.Time then
      isHaveTimeTag = true
    elseif config.Type == E.UnionTagType.Activity then
      isHaveActivityTag = true
    end
  end
  return isHaveTimeTag, isHaveActivityTag
end

return Union_label_tipsView
