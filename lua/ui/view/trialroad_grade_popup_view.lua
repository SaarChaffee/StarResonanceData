local UI = Z.UI
local super = require("ui.ui_view_base")
local Trialroad_grade_popupView = class("Trialroad_grade_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local trialroad_grade_loop_item = require("ui.component.trialroad.trialroad_grade_loop_item")

function Trialroad_grade_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "trialroad_grade_popup")
end

function Trialroad_grade_popupView:OnActive()
  self.gradeListView_ = loopListView.new(self, self.uiBinder.scrollview_award, trialroad_grade_loop_item, "trialroad_grade_list_tpl")
  self.gradeListView_:Init({})
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.trialRoadVM_ = Z.VMMgr.GetVM("trialroad")
  self:AddClick(self.uiBinder.btn_close, function()
    self.trialRoadVM_.CloseGradePopup()
  end)
  Z.EventMgr:Add(Z.ConstValue.TrialRoad.RefreshTrialRoadTarget, self.OnRefresh, self)
end

function Trialroad_grade_popupView:RequestGetTrialTargetReward(targetId)
  self.trialRoadVM_.ReqestGetTrialTargetReward(targetId, self.cancelSource:CreateToken())
end

function Trialroad_grade_popupView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.TrialRoad.RefreshTrialRoadTarget, self.OnRefresh, self)
  self.gradeListView_:UnInit()
  self.gradeListView_ = nil
end

function Trialroad_grade_popupView:OnRefresh()
  local dataList_ = {}
  for _, v in ipairs(Z.TrialRoadConfig.TrialRoadAward) do
    table.insert(dataList_, v)
  end
  self.gradeListView_:RefreshListView(dataList_)
  self.gradeListView_:ClearAllSelect()
end

return Trialroad_grade_popupView
