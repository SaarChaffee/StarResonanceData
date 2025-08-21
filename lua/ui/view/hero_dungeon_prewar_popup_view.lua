local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_prewar_popupView = class("Hero_dungeon_prewar_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local loopItem = require("ui.component.dungeon_prepare.prepare_item_loop")
local buffLoopItem = require("ui.component.dungeon_prepare.prepare_buff_loop_item")

function Hero_dungeon_prewar_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_prewar_popup")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  
  function self.buffChangeFunc_()
    self:refreshBuffInfo()
  end
  
  self.prepareVm_ = Z.VMMgr.GetVM("dungeon_prepare")
end

function Hero_dungeon_prewar_popupView:initBinders()
  self.cancelBtn_ = self.uiBinder.btn_cancel.btn
  self.confirmBtn_ = self.uiBinder.btn_confirm.btn
  self.reviveLoopList_ = self.uiBinder.loop_revive
  self.revertLoopList_ = self.uiBinder.loop_revert
  self.gainLoopList_ = self.uiBinder.loop_gain
  self.slicedFilled_ = self.uiBinder.img_ing
end

function Hero_dungeon_prewar_popupView:initBtns()
  self:AddAsyncClick(self.cancelBtn_, function()
    if not self.teamVM_.GetYouIsLeader() then
      self.prepareVm_.AsyncCancelPrepare(self.cancelSource:CreateToken())
    end
    self.prepareVm_:CloseView()
  end)
  self:AddAsyncClick(self.confirmBtn_, function()
    if not self.teamVM_.GetYouIsLeader() then
      self.prepareVm_.AsyncConfirmPrepare(self.prepareInfo_, self.cancelSource:CreateToken())
    end
    self.prepareVm_:CloseView()
  end)
end

function Hero_dungeon_prewar_popupView:initUI()
  Z.BuffMgr:CreateEntityBuffData(Z.EntityMgr.PlayerUuid, "DungeonPrewar")
  self.gainLoopGridView_ = loopListView.new(self, self.gainLoopList_, buffLoopItem, "hero_dungeon_prewar_item_tpl")
  self.reviveLoopGridView_ = loopListView.new(self, self.reviveLoopList_, loopItem, "hero_dungeon_prewar_item_tpl")
  self.revertLoopGridView_ = loopListView.new(self, self.revertLoopList_, loopItem, "hero_dungeon_prewar_item_tpl")
  self.gainLoopGridView_:Init({})
  self.reviveLoopGridView_:Init({})
  self.revertLoopGridView_:Init({})
  self.prepareInfo_ = self.prepareVm_.GetDungeonPrepareInfo()
  self:refreshBuffInfo()
  self:refreshRevertItemInfo()
  self:refreshReviveItemInfo()
  self:beginTime()
end

function Hero_dungeon_prewar_popupView:beginTime()
  local prepareTime = Z.Global.DungeonPrepareTime
  local sliderValue = prepareTime
  self.timer_ = self.timerMgr:StartFrameTimer(function()
    sliderValue = sliderValue - Time.deltaTime
    self.slicedFilled_.fillAmount = 1 / Z.Global.DungeonPrepareTime * sliderValue
    if sliderValue <= 0 then
      self.timerMgr:StopFrameTimer(self.timer_)
      self.timer_ = nil
      if not self.teamVM_.GetYouIsLeader() then
        Z.CoroUtil.create_coro_xpcall(function()
          self.prepareVm_.AsyncCancelPrepare(self.cancelSource:CreateToken())
          self.prepareVm_:CloseView()
        end)()
      else
        self.prepareVm_:CloseView()
      end
    end
  end, 1, -1)
end

function Hero_dungeon_prewar_popupView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initUI()
  self:bindEvents()
end

function Hero_dungeon_prewar_popupView:refreshBuffInfo()
  self.prepareInfo_.buffInfo = self.prepareVm_.GetPrepareBuffInfo()
  self.gainLoopGridView_:RefreshListView(self.prepareInfo_.buffInfo or {})
end

function Hero_dungeon_prewar_popupView:refreshReviveItemInfo()
  self.reviveLoopGridView_:RefreshListView(self.prepareInfo_.reviveInfo or {})
end

function Hero_dungeon_prewar_popupView:refreshRevertItemInfo()
  self.revertLoopGridView_:RefreshListView(self.prepareInfo_.revertInfo or {})
end

function Hero_dungeon_prewar_popupView:bindEvents()
  Z.BuffMgr:BindBuffChangeCallBack(Z.EntityMgr.PlayerUuid, self.buffChangeFunc_)
end

function Hero_dungeon_prewar_popupView:OnDeActive()
  if self.gainLoopGridView_ then
    self.gainLoopGridView_:UnInit()
  end
  if self.reviveLoopGridView_ then
    self.reviveLoopGridView_:UnInit()
  end
  if self.revertLoopGridView_ then
    self.revertLoopGridView_:UnInit()
  end
  Z.BuffMgr:UnBindBuffChangeCallBack(Z.EntityMgr.PlayerUuid, self.buffChangeFunc_)
  Z.BuffMgr:RemoveBuffData(Z.EntityMgr.PlayerUuid, "DungeonPrewar")
  if self.timer_ then
    self.timerMgr:StopFrameTimer(self.timer_)
    self.timer_ = nil
  end
end

function Hero_dungeon_prewar_popupView:OnRefresh()
end

return Hero_dungeon_prewar_popupView
