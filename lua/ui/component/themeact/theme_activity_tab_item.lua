local super = require("ui.component.loop_list_view_item")
local ThemeActivityTabItem = class("ThemeActivityTabItem", super)

function ThemeActivityTabItem:OnInit()
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
  self.themePlayVM_ = Z.VMMgr.GetVM("theme_play")
end

function ThemeActivityTabItem:OnRefresh(data)
  local config = data.config
  self.uiBinder.lab_name.text = config.Name
  self.uiBinder.rimg_activity:SetImage(config.TabPic)
  local timeStage = self.themePlayVM_:GetActivityTimeStage(config.Id)
  if timeStage == E.SeasonActivityTimeStage.NotOpen then
    self.uiBinder.lab_not_open.text = Lang("AboutToOpen")
  elseif timeStage == E.SeasonActivityTimeStage.Over then
    self.uiBinder.lab_not_open.text = Lang("HadOver")
  elseif timeStage == E.SeasonActivityTimeStage.Open then
    local startTime, endTime = self.themePlayVM_:GetActivityTimeStamp(config.Id)
    local startTimeDesc = Z.TimeFormatTools.TicksFormatTime(startTime * 1000, E.TimeFormatType.YMD, false, true)
    local endTimeDesc = Z.TimeFormatTools.TicksFormatTime(endTime * 1000, E.TimeFormatType.YMD, false, true)
    self.uiBinder.lab_time.text = startTimeDesc .. "-" .. endTimeDesc
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_time, timeStage == E.SeasonActivityTimeStage.Open)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_not_open, timeStage ~= E.SeasonActivityTimeStage.Open)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.isNew_ = self.themePlayVM_:CheckIsNew(config)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, self.isNew_)
  local funcRedDotId = E.ThemeActivityRedDot[config.FunctionId]
  if funcRedDotId ~= nil then
    Z.RedPointMgr.LoadRedDotItem(funcRedDotId, self.parent.UIView, self.uiBinder.Trans)
  end
  local newRedDotId = config.ShowNewRed
  if newRedDotId ~= 0 then
    Z.RedPointMgr.LoadRedDotItem(newRedDotId, self.parent.UIView, self.uiBinder.Trans)
  end
  for j, childId in ipairs(data.childIdList) do
    local childConfig = Z.TableMgr.GetRow("SeasonActTableMgr", childId)
    local childRedDotId = childConfig.ShowNewRed
    if childRedDotId ~= 0 then
      local resultId = data.config.Id .. "_" .. childRedDotId
      Z.RedPointMgr.LoadRedDotItem(resultId, self.parent.UIView, self.uiBinder.Trans)
    end
  end
end

function ThemeActivityTabItem:OnUnInit()
  self.recommendedPlayData_ = nil
  Z.RedPointMgr:RemoveChildernNodeItem(self.uiBinder.Trans, self.parent.UIView)
end

function ThemeActivityTabItem:OnRecycle()
  Z.RedPointMgr:RemoveChildernNodeItem(self.uiBinder.Trans, self.parent.UIView)
end

function ThemeActivityTabItem:OnSelected()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  if self.IsSelected then
    local data = self:GetCurData()
    if data == nil then
      return
    end
    if self.parent.UIView.OnTabItemSelected then
      self.parent.UIView:OnTabItemSelected(data)
    end
    if self.isNew_ then
      self.themePlayVM_:SetNewDirty(data.config)
      self.isNew_ = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, self.isNew_)
    end
    local redDotId = data.config.ShowNewRed
    if redDotId ~= 0 then
      Z.RedPointMgr.UpdateNodeCount(redDotId, 0)
      Z.RedPointMgr.OnClickRedDot(redDotId)
    end
    self.uiBinder.comp_dotween:Restart(Z.DOTweenAnimType.Open)
  end
end

return ThemeActivityTabItem
