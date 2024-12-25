local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_detail_windowView = class("Gasha_detail_windowView", super)

function Gasha_detail_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_detail_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
end

function Gasha_detail_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initComp()
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self:onAddListener()
end

function Gasha_detail_windowView:initComp()
  self.btn_close_ = self.uiBinder.btn_close
  self.scenemask_ = self.uiBinder.scenemask
  self.lab_desc_ = self.uiBinder.lab_desc
  self.node_content_parent_ = self.uiBinder.node_content_parent
  self.layoutrebuilder1_ = self.uiBinder.layoutrebuilder
  self.layoutrebuilder2_ = self.uiBinder.layoutrebuilder2
  self.layoutrebuilder3_ = self.uiBinder.layoutrebuilder3
end

function Gasha_detail_windowView:onAddListener()
  self:AddClick(self.btn_close_, function()
    self.gashaVm_.CloseGashaDetailView()
  end)
end

function Gasha_detail_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Gasha_detail_windowView:OnRefresh()
  if self.viewData == nil then
    logError("Gasha_detail_windowView:OnRefresh() self.viewData is nil")
    return
  end
  self.gashaId_ = self.viewData.gashaId
  if self.gashaId_ == nil then
    logError("Gasha_detail_windowView:OnRefresh() self.viewData.gashaId is nil")
  end
  self.detailData_ = self.gashaVm_.GetGashaDetail(self.gashaId_)
  self:refreshDetail()
end

function Gasha_detail_windowView:refreshDetail()
  if self.detailData_ == nil then
    logError("Gasha_detail_windowView:OnRefresh() self.detailData_ is nil")
    return
  end
  self.lab_desc_.text = self.detailData_.gashaPoolDesc
  self:refreshAwardPackageGroups()
end

function Gasha_detail_windowView:refreshAwardPackageGroups()
  local awardPackageGroups = self.detailData_.awardPackageGroup
  if awardPackageGroups == nil then
    logError("Gasha_detail_windowView:refreshAwardPackageGroups() awardPackageGroups is nil")
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for i, awardPackageGroup in ipairs(awardPackageGroups) do
      self:refreshAwardPackageGroup(awardPackageGroup, i)
    end
    self.layoutrebuilder3_:ForceRebuildLayoutImmediate()
    self.layoutrebuilder3_:MarkLayoutForRebuild()
    self.layoutrebuilder2_:ForceRebuildLayoutImmediate()
    self.layoutrebuilder2_:MarkLayoutForRebuild()
    self.layoutrebuilder1_:ForceRebuildLayoutImmediate()
    self.layoutrebuilder1_:MarkLayoutForRebuild()
  end)()
end

function Gasha_detail_windowView:refreshAwardPackageGroup(gashaAwardPackageGroup, index)
  if gashaAwardPackageGroup == nil then
    return
  end
  local path = GetLoadAssetPath("GashaDetailItem")
  local name = "group" .. index
  local awardPackageGroupUIBinder = self:AsyncLoadUiUnit(path, name, self.node_content_parent_)
  if awardPackageGroupUIBinder == nil then
    return
  end
  awardPackageGroupUIBinder.lab_title.text = gashaAwardPackageGroup.name
  self:refreshAwardIds(gashaAwardPackageGroup.awards, name, awardPackageGroupUIBinder.node_parent)
  awardPackageGroupUIBinder.layoutrebuilder:ForceRebuildLayoutImmediate()
end

function Gasha_detail_windowView:refreshAwardIds(awardIds, parentName, parent)
  if awardIds == nil then
    logError("Gasha_detail_windowView:refreshAwardIds() awardIds is nil")
    return
  end
  for i, awardId in ipairs(awardIds) do
    self:refreshAwardId(awardId, parentName, parent, i)
  end
end

function Gasha_detail_windowView:refreshAwardId(award, parentName, parent, index)
  local path = GetLoadAssetPath("GashaDetailLabItem")
  local awardUIBinder = self:AsyncLoadUiUnit(path, parentName .. "award" .. index, parent)
  if awardUIBinder == nil then
    return
  end
  local item = Z.TableMgr.GetRow("ItemTableMgr", award.awardId)
  if item == nil then
    return
  end
  local colorTag = "ItemQuality_" .. item.Quality
  awardUIBinder.lab.text = Z.RichTextHelper.ApplyStyleTag(item.Name, colorTag)
end

return Gasha_detail_windowView
