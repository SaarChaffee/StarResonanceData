local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_set_label_tplView = class("Union_set_label_tplView", super)
local unionTagItem = require("ui.component.union.union_tag_item")

function Union_set_label_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_set_label_tpl", "union/union_set_label_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.parentView_ = parent
end

function Union_set_label_tplView:OnActive()
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Selection, self, self.uiBinder.trans_time, self.uiBinder.trans_activity)
  self:refreshTagList()
end

function Union_set_label_tplView:OnDeActive()
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
end

function Union_set_label_tplView:OnRefresh()
end

function Union_set_label_tplView:refreshTagList()
  local unionTagTableMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  local allTagList = unionTagTableMgr.GetDatas()
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  local tagList = unionInfo.baseInfo.tags
  self.tagOnDict_ = {}
  self.tagOnServerDict_ = {}
  for i, id in ipairs(tagList) do
    self.tagOnDict_[id] = true
    self.tagOnServerDict_[id] = true
  end
  self.unionTagItem_:SetTag(allTagList, nil, self.tagOnDict_, function(config, item, isOn)
    local isModify = self.tagOnDict_[config.Id] ~= isOn
    self.parentView_:EnableOrDisableByModify(isModify)
    self.tagOnDict_[config.Id] = isOn
    self:checkModify()
  end)
  self.parentView_:EnableOrDisableByModify(false)
end

function Union_set_label_tplView:checkModify()
  local isModify = not table.zdeepCompare(self.tagOnDict_, self.tagOnServerDict_)
  self.parentView_:EnableOrDisableByModify(isModify)
end

function Union_set_label_tplView:onClickConfirm()
  local tagList = {}
  for id, isOn in pairs(self.tagOnDict_) do
    if isOn then
      table.insert(tagList, id)
    end
  end
  local reply = self.unionVM_:AsyncSetUnionTag(self.unionVM_:GetPlayerUnionId(), tagList, self.cancelSource:CreateToken())
  if reply.errCode and reply.errCode == 0 then
    Z.TipsVM.ShowTips(1000549)
    if self.parentView_ then
      self.parentView_:EnableOrDisableByModify(false)
    end
  end
end

return Union_set_label_tplView
