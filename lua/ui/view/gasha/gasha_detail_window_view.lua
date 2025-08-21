local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_detail_windowView = class("Gasha_detail_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local awardItem = require("ui.component.gasha.gasha_details_loop_item")

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
  self:refreshIosDes()
  self.loopList_ = {}
end

function Gasha_detail_windowView:refreshIosDes()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_ios, false)
  if Z.SDKDevices.RuntimeOS == E.OS.iOS then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_ios, true)
    self.uiBinder.lab_ios.text = Lang("GashaDetailIosDescription")
  end
end

function Gasha_detail_windowView:initComp()
  self.btn_close_ = self.uiBinder.btn_close
  self.scenemask_ = self.uiBinder.scenemask
  self.lab_desc_ = self.uiBinder.lab_desc
  self.node_content_parent_ = self.uiBinder.award_content
end

function Gasha_detail_windowView:onAddListener()
  self:AddClick(self.btn_close_, function()
    self.gashaVm_.CloseGashaDetailView()
  end)
  self:AddClick(self.uiBinder.btn_details, function()
    self:onPageSelect(true)
  end)
  self:AddClick(self.uiBinder.btn_reward_list, function()
    self:onPageSelect(false)
  end)
end

function Gasha_detail_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for _, value in pairs(self.loopList_) do
    value:UnInit()
  end
  self.loopList_ = {}
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

function Gasha_detail_windowView:onPageSelect(showDetails)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select_reward_list, not showDetails)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_list, not showDetails)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_lab, showDetails)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select_details, showDetails)
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
  self.gashaPoolRow_ = Z.TableMgr.GetTable("GashaPoolTableMgr").GetRow(self.gashaId_)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.gashaPoolRow_.Cost[1])
  self.uiBinder.lab_prompt.text = Lang("GashaPrompt", {
    val = itemRow.Name
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, self.gashaPoolRow_.Bind[2] == 1)
  self:onPageSelect(true)
  self:refreshDetail()
  self:refreshAwardPackageGroups()
end

function Gasha_detail_windowView:refreshDetail()
  if self.detailData_ == nil then
    logError("Gasha_detail_windowView:OnRefresh() self.detailData_ is nil")
    return
  end
  self.lab_desc_.text = self.detailData_.gashaPoolDesc
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
  end)()
end

function Gasha_detail_windowView:refreshAwardPackageGroup(gashaAwardPackageGroup, index)
  if gashaAwardPackageGroup == nil then
    return
  end
  local path = self.uiBinder.prefab_cache:GetString("GashaDetailItem")
  local name = "group" .. index
  local iconPath = self.gashaPoolRow_.GashaIconPreview[index]
  local awardPackageGroupUIBinder = self:AsyncLoadUiUnit(path, name, self.node_content_parent_)
  if awardPackageGroupUIBinder == nil then
    return
  end
  awardPackageGroupUIBinder.lab_title.text = gashaAwardPackageGroup.name
  awardPackageGroupUIBinder.lab_info.text = gashaAwardPackageGroup.probabilityDesc
  awardPackageGroupUIBinder.rimg_icon:SetImage(iconPath)
  self:refreshAwardIds(gashaAwardPackageGroup.awards, awardPackageGroupUIBinder, index)
end

function Gasha_detail_windowView:refreshAwardIds(awardIds, uiBinder, index)
  if awardIds == nil then
    logError("Gasha_detail_windowView:refreshAwardIds() awardIds is nil")
    return
  end
  if index == 1 then
    uiBinder.Ref:SetVisible(uiBinder.layout_hight, true)
    uiBinder.Ref:SetVisible(uiBinder.scrollview_item_com, false)
    local path = self.uiBinder.prefab_cache:GetString("GashaDetailHightItem")
    local root = uiBinder.layout_hight
    for i, award in ipairs(awardIds) do
      local itemRow = Z.TableMgr.GetRow("ItemTableMgr", award.awardId)
      if itemRow then
        local name = "hight_item_" .. i
        local hightItem = self:AsyncLoadUiUnit(path, name, root)
        hightItem.rimg_icon:SetImage(itemRow.Icon)
        self:AddAsyncClick(hightItem.btn_show, function()
          if self.tipsId_ then
            Z.TipsVM.CloseItemTipsView(self.tipsId_)
          end
          self.tipsId_ = Z.TipsVM.ShowItemTipsView(hightItem.Trans, award.awardId)
        end)
      end
    end
  else
    uiBinder.Ref:SetVisible(uiBinder.layout_hight, false)
    uiBinder.Ref:SetVisible(uiBinder.scrollview_item_com, true)
    self.loopList_[index] = loopListView.new(self, uiBinder.scrollview_item_com, awardItem, "com_item_square_1_8_pc")
    self.loopList_[index]:Init(awardIds)
  end
end

return Gasha_detail_windowView
