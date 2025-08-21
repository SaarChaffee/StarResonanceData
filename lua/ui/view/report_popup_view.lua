local UI = Z.UI
local super = require("ui.ui_view_base")
local Report_popupView = class("Report_popupView", super)
local reportDefine = require("ui.model.report_define")

function Report_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "report_popup")
  self.reportVM_ = Z.VMMgr.GetVM("report")
  self.units_ = {}
end

function Report_popupView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.toggleBinder_ = {
    [1] = self.uiBinder.tog_type_01,
    [2] = self.uiBinder.tog_type_02,
    [3] = self.uiBinder.tog_type_03
  }
  self.uiBinder.input_announce:AddListener(function(str)
    self.content_ = str
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_forget, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_report, function()
    local isNeedContent = false
    local messageParam
    local mgr = Z.TableMgr.GetTable("ReportReasonTableMgr")
    local reasons = {}
    local reasonsCount = 0
    for reason, value in pairs(self.selectReasons_) do
      if value then
        reasonsCount = reasonsCount + 1
        reasons[reasonsCount] = reason
        local config = mgr.GetRow(reason)
        if config and config.Iffill then
          isNeedContent = true
          messageParam = config.Reason
        end
      end
    end
    if reasonsCount == 0 then
      Z.TipsVM.ShowTipsLang(1006041)
      return
    end
    if isNeedContent and self.content_ == "" then
      Z.TipsVM.ShowTipsLang(1006043, {val = messageParam})
      return
    end
    if string.zlenNormalize(self.content_) > reportDefine.ReportContentMaxLength then
      Z.TipsVM.ShowTipsLang(1006044)
      return
    end
    local categoryType = self.reportConfig_.ReportCategoryId[self.selectCategoryIndex_]
    local reportType = self.viewData.reportType
    if categoryType == nil then
      return
    end
    local reportInfo = {
      sceneType = self.reportConfig_.SceneId,
      categoryType = categoryType,
      reasonType = reasons,
      reportDesc = self.content_
    }
    if categoryType == reportDefine.ReportCategory.Chat then
      reportInfo.reportChat = {
        chatChannelType = self.viewData.param.chatChannelType,
        channelId = tostring(self.viewData.charId),
        chatID = self.viewData.param.chatID
      }
    elseif categoryType == reportDefine.ReportCategory.PersonalInfo then
      reportInfo.reportBaseInfo = {
        charId = self.viewData.charId
      }
    elseif categoryType == reportDefine.ReportCategory.Photo and reportType == reportDefine.ReportScene.Photo then
      reportInfo.reportPicture = {
        pictureId = tostring(self.viewData.param.photoId),
        targetUuid = self.viewData.charId,
        union = self.viewData.param.isUnion
      }
    elseif categoryType == reportDefine.ReportCategory.UnionInfo then
      reportInfo.reportUnion = {
        unionId = tostring(self.viewData.charId)
      }
    elseif reportType == reportDefine.ReportScene.Home then
      reportInfo.reportHome = {
        homeId = tostring(self.viewData.param.homeId)
      }
    end
    local ret = self.reportVM_.AsyncReport(reportInfo, self.cancelSource:CreateToken())
    if ret then
      Z.TipsVM.ShowTipsLang(1006040)
    end
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.lab_playername.text = self.viewData.name
  self.reportConfig_ = Z.TableMgr.GetTable("ReportTableMgr").GetRow(self.viewData.reportType)
  self.selectCategoryIndex_ = 0
  self.selectReasons_ = {}
  self.selectReasonsCount_ = 0
  self.content_ = ""
  if self.reportConfig_ == nil then
    return
  end
  for i = 1, 3 do
    if self.reportConfig_.ReportCategoryId[i] ~= nil then
      self.toggleBinder_[i].Ref.UIComp:SetVisible(true)
      self.toggleBinder_[i].toggle.isOn = false
      self.toggleBinder_[i].toggle:AddListener(function()
        self:selectCategoryIndex(i)
      end)
      self.toggleBinder_[i].lab_common_1.text = self.reportConfig_.ReportCategoryDes[i]
      self.toggleBinder_[i].lab_common_2.text = self.reportConfig_.ReportCategoryDes[i]
    else
      self.toggleBinder_[i].Ref.UIComp:SetVisible(false)
    end
  end
  if self.toggleBinder_[1].toggle.isOn then
    self:selectCategoryIndex(1)
  else
    self.toggleBinder_[1].toggle.isOn = true
  end
end

function Report_popupView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:removeReasonUnits()
end

function Report_popupView:OnRefresh()
end

function Report_popupView:selectCategoryIndex(index)
  if self.selectCategoryIndex_ == index then
    return
  end
  self.selectCategoryIndex_ = index
  self.selectReasons_ = {}
  self.selectReasonsCount_ = 0
  self.content_ = ""
  self.uiBinder.input_announce.text = ""
  self.uiBinder.input_announce:ActivateInputField()
  self:createReasonUnits()
end

function Report_popupView:removeReasonUnits()
  for _, unit in ipairs(self.units_) do
    self:RemoveUiUnit(unit)
  end
  self.units_ = {}
end

function Report_popupView:createReasonUnits()
  self:removeReasonUnits()
  if self.reportConfig_ == nil then
    return
  end
  local reasons = self.reportConfig_.ReportReason[self.selectCategoryIndex_]
  if reasons == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = self.uiBinder.uiprefab_cache:GetString("item")
    local mgr = Z.TableMgr.GetTable("ReportReasonTableMgr")
    for _, reason in ipairs(reasons) do
      local reasonConfig = mgr.GetRow(reason)
      if reasonConfig then
        local unit = self:AsyncLoadUiUnit(unitPath, reason, self.uiBinder.layout_time)
        if unit then
          unit.lab_title.text = reasonConfig.Reason
          unit.tog_item:SetIsOnWithoutCallBack(false)
          unit.tog_item:AddListener(function(isOn)
            if isOn then
              if self.selectReasonsCount_ >= reportDefine.ReportMaxReason then
                unit.tog_item.isOn = false
                Z.TipsVM.ShowTipsLang(1006042)
                return
              end
              if self.selectReasons_[reason] == nil then
                self.selectReasonsCount_ = self.selectReasonsCount_ + 1
              end
              self.selectReasons_[reason] = true
            else
              if self.selectReasons_[reason] ~= nil then
                self.selectReasonsCount_ = self.selectReasonsCount_ - 1
              end
              self.selectReasons_[reason] = nil
            end
          end)
        end
        table.insert(self.units_, reason)
      end
    end
  end)()
end

return Report_popupView
