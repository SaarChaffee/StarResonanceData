local UI = Z.UI
local super = require("ui.ui_view_base")
local Weekly_hunt_rankings_windowView = class("Weekly_hunt_rankings_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local rankLoopItem = require("ui.component.week_hunt.week_hunt_rank_loop_item")

function Weekly_hunt_rankings_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weekly_hunt_rankings_window")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function Weekly_hunt_rankings_windowView:initUibinder()
  self.curRankingTog_ = self.uiBinder.tog_current_ranking
  self.allRankingTog_ = self.uiBinder.tog_server_ranking
  self.timeLab_ = self.uiBinder.lab_time
  self.askBtn_ = self.uiBinder.btn_ask
  self.closeBtn_ = self.uiBinder.btn_close
  self.titleLab_ = self.uiBinder.lab_title
  self.rankingLoopList_ = self.uiBinder.node_loop_ranking
  self.selfInfoNod_ = self.uiBinder.node_player_info
  self.nameLab_ = self.selfInfoNod_.lab_player_name
  self.passTimeLab_ = self.selfInfoNod_.lab_checkpoints_time
  self.passLayerLab_ = self.selfInfoNod_.lab_checkpoints_layer
  self.rankingLab_ = self.selfInfoNod_.lab_ranking
  self.rankingImg_ = self.selfInfoNod_.img_current_ranking
  self.headNode_ = self.selfInfoNod_.com_head_46_item
  self.rimgBg_ = self.selfInfoNod_.rimg_player_bg
end

function Weekly_hunt_rankings_windowView:initBtns()
  self:AddClick(self.askBtn_, function()
  end)
  self:AddClick(self.closeBtn_, function()
  end)
end

function Weekly_hunt_rankings_windowView:initDatas()
end

function Weekly_hunt_rankings_windowView:initUi()
  self.commonVM_.SetLabText(self.titleLab_, {100001})
  self.rankingListView_ = loopListView.new(self, self.rankingLoopList_, rankLoopItem, "weekly_hunt_rankings_item_tpl")
  self.rankingListView_:Init({})
  self.nameLab_.text = Z.ContainerMgr.CharSerialize.charBase.name
end

function Weekly_hunt_rankings_windowView:OnActive()
  self:initUibinder()
end

function Weekly_hunt_rankings_windowView:OnDeActive()
  if self.rankingListView_ then
    self.rankingListView_:UnInit()
    self.rankingListView_ = nil
  end
end

function Weekly_hunt_rankings_windowView:OnRefresh()
end

return Weekly_hunt_rankings_windowView
