local UI = Z.UI
local super = require("ui.ui_view_base")
local PersonalzoneLabelPopupView = class("PersonalzoneLabelPopupView", super)
local DEFINE = require("ui.model.personalzone_define")

function PersonalzoneLabelPopupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "personalzone_label_popup")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
end

function PersonalzoneLabelPopupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("personalzone_label_popup")
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    local times = {}
    for _, v in pairs(self.timeTags_) do
      table.insert(times, v)
    end
    local tags = {}
    for _, v in pairs(self.selectTags_) do
      table.insert(tags, v)
    end
    self.personalzoneVm_.AsyncSavePersonalTags(0, times, tags, self.cancelSource:CreateToken())
    Z.UIMgr:CloseView("personalzone_label_popup")
    Z.TipsVM.ShowTipsLang(1002103)
  end)
  self.timeTags_ = {}
  self.timeTagsCount_ = 0
  local timeTags = Z.ContainerMgr.CharSerialize.personalZone.onlinePeriods
  for _, v in ipairs(timeTags) do
    self.timeTags_[v] = v
    self.timeTagsCount_ = self.timeTagsCount_ + 1
  end
  self.selectTags_ = {}
  self.selectTagsCount_ = 0
  local tags = Z.ContainerMgr.CharSerialize.personalZone.tags
  for _, v in ipairs(tags) do
    self.selectTags_[v] = v
    self.selectTagsCount_ = self.selectTagsCount_ + 1
  end
  self:asyncLoadItems()
end

function PersonalzoneLabelPopupView:OnDeActive()
end

function PersonalzoneLabelPopupView:OnRefresh()
end

function PersonalzoneLabelPopupView:AddSeletTimeItems(id)
  if self.timeTags_[id] then
    self.timeTags_[id] = nil
    self.timeTagsCount_ = self.timeTagsCount_ - 1
  elseif self.timeTagsCount_ < Z.Global.PersonalOnlinePeriodLimit then
    self.timeTags_[id] = id
    self.timeTagsCount_ = self.timeTagsCount_ + 1
  else
    Z.TipsVM.ShowTipsLang(1002106)
  end
  self:refreshTimeItems()
end

function PersonalzoneLabelPopupView:AddSelectTags(id)
  if self.selectTags_[id] then
    self.selectTags_[id] = nil
    self.selectTagsCount_ = self.selectTagsCount_ - 1
  elseif self.selectTagsCount_ < Z.Global.PersonalTagLimit then
    self.selectTags_[id] = id
    self.selectTagsCount_ = self.selectTagsCount_ + 1
  else
    Z.TipsVM.ShowTipsLang(1002106)
  end
  self:refreshTagsList()
end

function PersonalzoneLabelPopupView:asyncLoadItems()
  local onlineDayConfigs = self.personalzoneData_:GetTagsByType(DEFINE.PersonalTagType.OnlineDayTime)
  local onlineDayCount = #onlineDayConfigs
  self.onlineDayUnits_ = {}
  local onlineTimeConfigs = self.personalzoneData_:GetTagsByType(DEFINE.PersonalTagType.OnlineActivity)
  local onlineTimeCount = #onlineTimeConfigs
  self.onlineTimeUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = self.uiBinder.uiprefab_cache:GetString("tog")
    for index = 1, onlineDayCount do
      local config = onlineDayConfigs[index]
      local unitName = "onlineDayItem_" .. index
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.layout_time)
      if unit then
        unit.tog_item:AddListener(function()
          self:AddSeletTimeItems(config.Id)
        end)
        unit.img_icon:SetImage(config.ShowTagRoute)
        unit.lab_title.text = config.Description
        self.onlineDayUnits_[config.Id] = {unit = unit, name = unitName}
      end
    end
    for index = 1, onlineTimeCount do
      local config = onlineTimeConfigs[index]
      local unitName = "onlineTimeItem_" .. index
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.layout_activity)
      if unit then
        unit.tog_item:AddListener(function()
          self:AddSelectTags(config.Id)
        end)
        unit.img_icon:SetImage(config.ShowTagRoute)
        unit.lab_title.text = config.Description
        self.onlineTimeUnits_[config.Id] = {unit = unit, name = unitName}
      end
    end
    self:refreshTimeItems()
    self:refreshTagsList()
  end)()
end

function PersonalzoneLabelPopupView:refreshTimeItems()
  for key, unit in pairs(self.onlineDayUnits_) do
    unit.unit.tog_item:SetIsOnWithoutNotify(self.timeTags_[key] ~= nil)
  end
end

function PersonalzoneLabelPopupView:refreshTagsList()
  for key, unit in pairs(self.onlineTimeUnits_) do
    unit.unit.tog_item:SetIsOnWithoutNotify(self.selectTags_[key] ~= nil)
  end
end

return PersonalzoneLabelPopupView
