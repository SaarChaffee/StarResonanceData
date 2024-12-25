local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_active_hot_popupView = class("Union_active_hot_popupView", super)
local loopGridView = require("ui.component.loop_list_view")
local huntRewardItem = require("ui.component.union.union_hunt_rank_loop_item")

function Union_active_hot_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_active_hot_popup")
end

function Union_active_hot_popupView:OnActive()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self:initBaseData()
  self:initBinders()
  self:initLoopView()
  self:initBtnFunc()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  Z.CoroUtil.create_coro_xpcall(function()
    self:AsyncGetRankInfo()
  end)()
end

function Union_active_hot_popupView:OnDeActive()
  self.loopRewardView_:UnInit()
  self.loopRewardView_ = nil
  self.color1 = nil
  self.color2 = nil
  self.color3 = nil
end

function Union_active_hot_popupView:OnRefresh()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Union_active_hot_popupView:initBaseData()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.activityId_ = self.viewData
  self.rankType = Z.PbEnum("EUnionActivityRankType", "UnionActivityRankTypeScore")
  self.color1 = {
    Color.New(1.0, 0.5764705882352941, 0.13333333333333333, 0.8),
    Color.New(0.792156862745098, 0.40784313725490196, 0.16470588235294117, 0.8),
    Color.New(0.6666666666666666, 0.20784313725490197, 0.10980392156862745, 0.8),
    Color.New(0 / 255, 0 / 255, 0 / 255, 0.48)
  }
  self.color2 = {
    Color.New(1.0, 0.9647058823529412, 0 / 255, 0.54),
    Color.New(1.0, 0.9176470588235294, 0 / 255, 0.36),
    Color.New(1.0, 0.9176470588235294, 0 / 255, 0.14),
    Color.New(1.0, 0.9176470588235294, 0 / 255, 0.14)
  }
  self.color3 = {
    Color.New(0.48627450980392156, 0.13333333333333333, 0 / 255, 1),
    Color.New(0.20784313725490197, 0.20784313725490197, 0.20784313725490197, 1),
    Color.New(0.23137254901960785, 0.050980392156862744, 0.050980392156862744, 1),
    Color.New(0.9333333333333333, 9.168627450980392, 0.9333333333333333, 1)
  }
end

function Union_active_hot_popupView:initBinders()
  self.btn_close_ = self.uiBinder.btn_close
  self.btn_ask_ = self.uiBinder.btn_info
  self.loopscroll_award_ = self.uiBinder.loopscroll_item
end

function Union_active_hot_popupView:initBtnFunc()
  self:AddClick(self.btn_close_, function()
    self.unionVM_:CloseHuntRankView()
  end)
  self:AddClick(self.btn_ask_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30061)
  end)
end

function Union_active_hot_popupView:initLoopView()
  self.loopRewardView_ = loopGridView.new(self, self.loopscroll_award_, huntRewardItem, "union_active_ranking_item_tpl")
  local dataList_ = {}
  self.loopRewardView_:Init(dataList_)
end

function Union_active_hot_popupView:AsyncGetRankInfo()
  local cancelToken_ = self.cancelSource:CreateToken()
  local reply = self.unionVM_:AsyncGetUnionHuntRankData(self.activityId_, self.rankType, cancelToken_)
  self.rankList = self.unionData_:GetUnionHuntRankInfo()
  local hasResult_ = #self.rankList > 0
  if hasResult_ then
    self.loopRewardView_:RefreshListView(self.rankList)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, hasResult_ == false)
  self.uiBinder.Ref:SetVisible(self.loopscroll_award_, hasResult_ == true)
end

function Union_active_hot_popupView:GetItemColorByIndex(rankIndex)
  local r = math.min(4, rankIndex)
  local c1 = self.color1[r]
  local c2 = self.color2[r]
  local c3 = self.color3[r]
  return c1, c2, c3
end

return Union_active_hot_popupView
