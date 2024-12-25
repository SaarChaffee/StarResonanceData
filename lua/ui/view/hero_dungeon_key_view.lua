local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_keyView = class("Hero_dungeon_keyView", super)
local rollViewPath = require("ui.view.hero_dungeon_tips_popup_view")
local TimeSliderColor = {
  [1] = Color.New(1, 1, 1, 1),
  [2] = Color.New(1, 0.7803921568627451, 0.4666666666666667, 1),
  [3] = Color.New(1, 0.592156862745098, 0.4666666666666667, 1)
}

function Hero_dungeon_keyView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_key")
  self.rollView_ = rollViewPath.new(self)
  self.heroData_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
end

function Hero_dungeon_keyView:initZWidget()
  self.nodeBtn_ = self.uiBinder.node_btn
  self.img_bar_ = self.uiBinder.img_bar
end

function Hero_dungeon_keyView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.rollViewList_ = {}
  self.subViewDic_ = {}
  self.timeDict_ = {}
  self:initZWidget()
  self:bindEvent()
  self.uiBinder.Ref:SetVisible(self.nodeBtn_, false)
  self.uiBinder.Ref:SetVisible(self.img_bar_, false)
  self:AddClick(self.nodeBtn_, function()
    self.uiBinder.Ref:SetVisible(self.nodeBtn_, false)
    self.rollView_:Show()
  end)
  local RollInfoEndTime = Z.Global.RollInfoEndTime
  self.timerMgr:StartTimer(function()
    Z.UIMgr:CloseView("hero_dungeon_key")
  end, RollInfoEndTime, 1)
end

function Hero_dungeon_keyView:loadRollView()
end

function Hero_dungeon_keyView:CloseRollView()
  self.rollView_:Hide()
  self.uiBinder.Ref:SetVisible(self.nodeBtn_, true)
end

function Hero_dungeon_keyView:OnDeActive()
  self.rollView_:DeActive()
end

function Hero_dungeon_keyView:refreshRollView()
end

function Hero_dungeon_keyView:bindEvent()
end

function Hero_dungeon_keyView:StopTime(index)
  self.timerMgr:StopFrameTimer(self.timeDict_[index])
  self.timeDict_[index] = nil
  self.uiBinder.Ref:SetVisible(self.img_bar_, false)
end

function Hero_dungeon_keyView:startTime(index)
  if not self.timeDict_[index] then
    self.img_bar_.fillAmount = 1
    local nowColorIndex = 0
    self.uiBinder.Ref:SetVisible(self.img_bar_, true)
    local duration = Z.Global.RollLimitTime
    local time = 0
    self.timeDict_[index] = self.timerMgr:StartFrameTimer(function()
      if time == 0 and nowColorIndex ~= 1 then
        nowColorIndex = 1
        self.img_bar_:SetColor(TimeSliderColor[1])
      elseif time >= duration / 2 and nowColorIndex ~= 2 and time < duration / 4 * 3 then
        nowColorIndex = 2
        self.img_bar_:SetColor(TimeSliderColor[2])
      elseif time >= duration / 4 * 3 and nowColorIndex ~= 3 then
        nowColorIndex = 3
        self.img_bar_:SetColor(TimeSliderColor[3])
      end
      self.img_bar_.fillAmount = 1 - time / duration
      time = time + Time.deltaTime
      if time >= duration then
        self.img_bar_.fillAmount = 0
        self.timeDict_[index] = nil
      end
    end, 1, -1)
  end
end

function Hero_dungeon_keyView:loadRollSubView()
  local keyDic = Z.ContainerMgr.DungeonSyncData.heroKey.keyInfo
  for index, value in pairs(keyDic) do
    if self.subViewDic_[index] then
      return
    end
    self.subViewDic_[index] = true
    self.idnex_ = index
    self.rollView_:Active(index, self.uiBinder.node_roll)
    if Z.ContainerMgr.CharSerialize.charBase.charId ~= Z.ContainerMgr.DungeonSyncData.heroKey.charId then
      self:startTime(index)
    end
    return
  end
end

function Hero_dungeon_keyView:OnRefresh()
  self:loadRollSubView()
end

return Hero_dungeon_keyView
