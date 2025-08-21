local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_edit_setting_subView = class("Personalzone_edit_setting_subView", super)
local UnionTagTableMap = require("table.UnionTagTableMap")
local PersonalZoneDefine = require("ui.model.personalzone_define")

function Personalzone_edit_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_edit_setting_sub", "personalzone/personalzone_edit_setting_sub", UI.ECacheLv.None)
  self.parentView_ = parent
end

function Personalzone_edit_setting_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.tog_badge:AddListener(function(isOn)
    self.parentView_:ChangeShowSubFunc(E.FunctionID.PersonalzoneMedal, isOn)
  end)
  self.uiBinder.tog_photo:AddListener(function(isOn)
    self.parentView_:ChangeShowSubFunc(E.FunctionID.PersonalzonePhoto, isOn)
  end)
  local isMedalOn, _ = self.parentView_:IsSubViewOn(E.FunctionID.PersonalzoneMedal)
  self.uiBinder.tog_badge:SetIsOnWithoutNotify(isMedalOn)
  local isPhotoOn, _ = self.parentView_:IsSubViewOn(E.FunctionID.PersonalzonePhoto)
  self.uiBinder.tog_photo:SetIsOnWithoutNotify(isPhotoOn)
  local mgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  local onlineTimes = UnionTagTableMap.Dictionary[PersonalZoneDefine.PersonalTagType.OnlineDayTime]
  table.sort(onlineTimes, function(a, b)
    local aConfig = mgr.GetRow(a)
    local bConfig = mgr.GetRow(b)
    if aConfig and bConfig then
      if aConfig.ShowSort == bConfig.ShowSort then
        return a < b
      else
        return aConfig.ShowSort < bConfig.ShowSort
      end
    else
      return a < b
    end
  end)
  local activeLabels = UnionTagTableMap.Dictionary[PersonalZoneDefine.PersonalTagType.OnlineActivity]
  table.sort(activeLabels, function(a, b)
    local aConfig = mgr.GetRow(a)
    local bConfig = mgr.GetRow(b)
    if aConfig and bConfig then
      if aConfig.ShowSort == bConfig.ShowSort then
        return a < b
      else
        return aConfig.ShowSort < bConfig.ShowSort
      end
    else
      return a < b
    end
  end)
  local unitPath = self.uiBinder.uiprefab_cache:GetString("item")
  self.timeUnits_ = {}
  self.activeUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for _, id in ipairs(onlineTimes) do
      local name = "online_" .. id
      local unit = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.layout_time)
      if unit then
        self.timeUnits_[id] = unit
        unit.tog_item:AddListener(function(isOn)
          local success = self.parentView_:ChangeOnlinePeriods(id, isOn)
          if not success then
            unit.tog_item.isOn = false
          end
        end)
        do
          local isOn, _ = self.parentView_:IsOnlinePeriodsOn(id)
          unit.tog_item:SetIsOnWithoutCallBack(isOn)
          local config = mgr.GetRow(id)
          if config then
            unit.img_icon:SetImage(config.ShowTagRoute)
            unit.lab_title.text = config.Description
          end
        end
      end
    end
    for _, id in ipairs(activeLabels) do
      local name = "active_" .. id
      local unit = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.layout_active_label)
      if unit then
        self.activeUnits_[id] = unit
        unit.tog_item:AddListener(function(isOn)
          local success = self.parentView_:ChangeTags(id, isOn)
          if not success then
            unit.tog_item.isOn = false
          end
        end)
        do
          local isOn, _ = self.parentView_:IsTagsOn(id)
          unit.tog_item:SetIsOnWithoutCallBack(isOn)
          local config = mgr.GetRow(id)
          if config then
            unit.img_icon:SetImage(config.ShowTagRoute)
            unit.lab_title.text = config.Description
          end
        end
      end
    end
  end)()
end

function Personalzone_edit_setting_subView:OnDeActive()
  self.timeUnits_ = {}
  self.activeUnits_ = {}
end

function Personalzone_edit_setting_subView:OnRefresh()
end

return Personalzone_edit_setting_subView
