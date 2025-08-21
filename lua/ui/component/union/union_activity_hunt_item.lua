local super = require("ui.component.loop_list_view_item")
local UnionActivityHuntItem = class("UnionActivityHuntItem", super)
local imgPath_ = {
  "ui/atlas/union/union_icon_one",
  "ui/atlas/union/union_icon_three"
}

function UnionActivityHuntItem:ctor()
  self.timerMgr = Z.TimerMgr.new()
end

function UnionActivityHuntItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function UnionActivityHuntItem:OnRefresh(data)
  self.data = data
  if data.Id == E.UnionActivityType.UnionHunt then
    self:loadUnionHuntRedDotItem()
  end
  if data.Id == E.UnionActivityType.UnionDance then
    self:loadUnionDanceRedDotItem()
  end
  self.uiBinder.img_bg:SetImage(self.data.LabelPic)
  local img_ = self.uiBinder.img_weather
  self.uiBinder.Ref:SetVisible(img_, true)
  local type = data.Label
  img_:SetImage(imgPath_[type])
  local functionOpen = true
  local reason = {}
  if self.data.FunctionId and self.data.FunctionId ~= 0 then
    functionOpen, reason = Z.VMMgr.GetVM("switch").CheckFuncSwitch(self.data.FunctionId)
  end
  self:StopTimer()
  local str = ""
  local isUnlock = false
  if functionOpen then
    local conditionIds = self.data.Condition
    local check = Z.ConditionHelper.CheckCondition(conditionIds)
    if check == false then
      local r = Z.ConditionHelper.GetConditionDescList(conditionIds)
      for _, value in ipairs(r) do
        if value.IsUnlock == false then
          str = value.Desc
          break
        end
      end
    else
      str = self.data.Time
      isUnlock = true
      local timeId = self.data.TimerId
      local _, beforeLeftTime_ = Z.TimeTools.GetLeftTimeByTimerId(timeId)
      local func = function()
        beforeLeftTime_ = beforeLeftTime_ - 1
        if beforeLeftTime_ <= 0 then
          local data_ = self:GetCurData()
          self:OnRefresh(data_)
        end
      end
      if 0 < beforeLeftTime_ then
        func()
        self.timer = self.timerMgr:StartTimer(func, 1, beforeLeftTime_ + 1)
      end
    end
  elseif reason and reason[1] then
    str = Lang("Function" .. reason[1].error, reason[1].params)
  end
  self.uiBinder.lab_unlock.text = str
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_time, isUnlock)
  self.isUnlock_ = isUnlock
  self.tipsStr_ = str
  local colorTag = E.TextStyleTag.TipsTitle
  self.uiBinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(self.data.Name, colorTag)
  self:SelectState()
end

function UnionActivityHuntItem:Selected(isSelected)
  if isSelected == true and self.isUnlock_ == false then
    Z.TipsVM.OpenMessageViewByContext(self.tipsStr_, E.TipsType.MiddleTips)
  end
  self.IsSelected = isSelected
  if isSelected then
    self.parentUIView:RefreshRightInfo(self.data, self.isUnlock_)
  end
  self:SelectState()
end

function UnionActivityHuntItem:SelectState()
  local isSelected = self.IsSelected
  local colorTag = E.TextStyleTag.TipsTitle
  self.uiBinder.node_dot.Ref:SetVisible(self.uiBinder.node_dot.img_frame, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    colorTag = E.TextStyleTag.White
  end
  self.uiBinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(self.data.Name, colorTag)
end

function UnionActivityHuntItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function UnionActivityHuntItem:StopTimer()
  if self.timer then
    self.timer:Stop()
    self.timer = nil
  end
end

function UnionActivityHuntItem:OnUnInit()
  self:StopTimer()
  if self.data.Id == E.UnionActivityType.UnionHunt then
    Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionHuntTab)
  end
  if self.data.Id == E.UnionActivityType.UnionDance then
    Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionDanceTab)
  end
end

function UnionActivityHuntItem:loadUnionHuntRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionHuntTab, self.parentUIView, self.uiBinder.root)
end

function UnionActivityHuntItem:loadUnionDanceRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionDanceTab, self.parentUIView, self.uiBinder.root)
end

return UnionActivityHuntItem
