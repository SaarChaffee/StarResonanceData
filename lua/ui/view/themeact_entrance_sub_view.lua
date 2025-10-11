local UI = Z.UI
local super = require("ui.ui_subview_base")
local Themeact_entrance_subView = class("Themeact_entrance_subView", super)
local TITLE_RIMG_PATH = "ui/textures/themeact/themeact_lab/themeact_title_01"
local ACT_RIMG_PATH_1 = "ui/textures/themeact/themeact_rests/themeact_01"
local ACT_RIMG_PATH_2 = "ui/textures/themeact/themeact_rests/themeact_02"
local ACT_RIMG_PATH_3 = "ui/textures/themeact/themeact_rests/themeact_03"

function Themeact_entrance_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "themeact_entrance_sub", "themeact/themeact_entrance_sub", UI.ECacheLv.None)
end

function Themeact_entrance_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self:setRawImage()
  self:refreshActivityList()
end

function Themeact_entrance_subView:OnDeActive()
end

function Themeact_entrance_subView:OnRefresh()
end

function Themeact_entrance_subView:initData()
  self.themePlayVM_ = Z.VMMgr.GetVM("theme_play")
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
end

function Themeact_entrance_subView:initComponent()
end

function Themeact_entrance_subView:refreshActivityList()
  local activityIdList = self.viewData.childIdList
  table.sort(activityIdList, function(a, b)
    return a < b
  end)
  self:refreshActivityInfo(activityIdList[1], 1)
  self:refreshActivityInfo(activityIdList[2], 2)
  self:refreshActivityInfo(activityIdList[3], 3)
end

function Themeact_entrance_subView:refreshActivityInfo(activityId, index)
  local lab_time = self.uiBinder["lab_time_" .. index]
  local lab_title = self.uiBinder["lab_title_" .. index]
  local btn_go = self.uiBinder["btn_go_" .. index]
  if lab_time == nil or lab_title == nil or btn_go == nil then
    return
  end
  activityId = activityId or 0
  local config = Z.TableMgr.GetRow("SeasonActTableMgr", activityId)
  local serverData = self.recommendedPlayData_:GetServerData(E.SeasonActFuncType.Theme, activityId)
  if config == nil or serverData == nil then
    lab_time.text = ""
    lab_title.text = ""
    btn_go:RemoveAllListeners()
  else
    if config.TimeDecs ~= "" then
      lab_time.text = config.TimeDecs
    else
      local startTime, endTime = self.themePlayVM_:GetActivityTimeStamp(activityId)
      local startTimeDesc = Z.TimeFormatTools.TicksFormatTime(startTime * 1000, E.TimeFormatType.YMD, false, true)
      local endTimeDesc = Z.TimeFormatTools.TicksFormatTime(endTime * 1000, E.TimeFormatType.YMD, false, true)
      lab_time.text = startTimeDesc .. "-" .. endTimeDesc
    end
    lab_title.text = config.Name
    self:AddClick(btn_go, function()
      local quickJumpVM = Z.VMMgr.GetVM("quick_jump")
      quickJumpVM.DoJumpByConfigParam(config.QuickJumpType, config.QuickJumpParam)
    end)
  end
end

function Themeact_entrance_subView:setRawImage()
  self.uiBinder.rimg_title:SetImage(TITLE_RIMG_PATH)
  self.uiBinder.rimg_01:SetImage(ACT_RIMG_PATH_1)
  self.uiBinder.rimg_02:SetImage(ACT_RIMG_PATH_2)
  self.uiBinder.rimg_03:SetImage(ACT_RIMG_PATH_3)
end

return Themeact_entrance_subView
