local super = require("ui.component.loop_list_view_item")
local UnionBuildItem = class("UnionBuildItem", super)
local unionRed_ = require("rednode.union_red")

function UnionBuildItem:OnInit()
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function UnionBuildItem:OnRefresh(data)
  local curLv = self.unionVM_:GetUnionBuildLv(data.Id)
  local isUpgrading = self.unionVM_:CheckBuildIsUpgrading(data.Id)
  local buildName = data.BuildingName
  self.uiBinder.lab_content_normal.text = buildName
  self.uiBinder.lab_content_select.text = buildName
  self.uiBinder.lab_content_lock.text = buildName
  local buildLv = Lang("Lv") .. curLv
  self.uiBinder.lab_grade_normal.text = buildLv
  self.uiBinder.lab_grade_select.text = buildLv
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow, isUpgrading)
  self:refreshState(data)
  unionRed_.LoadUnionBuildItem(data.Id, self.parent.UIView, self.uiBinder.Trans)
end

function UnionBuildItem:OnUnInit()
end

function UnionBuildItem:refreshState(data)
  local isUnlock = self.unionVM_:IsUnionBuildUnlock(data.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_normal, isUnlock and not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_select, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_lock, not isUnlock)
end

function UnionBuildItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self:refreshState(curData)
  if isSelected then
    self.parent.UIView:RefreshSelectBuildInfo(curData.Id)
  end
end

return UnionBuildItem
