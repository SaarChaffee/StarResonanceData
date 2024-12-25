local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_windowView = class("Season_windowView", super)

function Season_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_window")
  self.curPage_ = 1
  self.pageViewList_ = {}
  self.pageDotList_ = {}
  self.pageAnimList_ = {}
end

function Season_windowView:OnActive()
  self:startAnimShow()
  self:AddClick(self.uiBinder.btn_arrow_left, function()
    self:setPage(self.curPage_ - 1)
  end)
  self:AddClick(self.uiBinder.btn_arrow_right, function()
    self:setPage(self.curPage_ + 1)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self:DeActive()
  end)
  table.insert(self.pageViewList_, self.uiBinder.cont_info_appearance)
  table.insert(self.pageViewList_, self.uiBinder.cont_info_theme)
  table.insert(self.pageDotList_, self.uiBinder.img_dot_01)
  table.insert(self.pageDotList_, self.uiBinder.img_dot_02)
  table.insert(self.pageAnimList_, Z.DOTweenAnimType.Tween_2)
  table.insert(self.pageAnimList_, Z.DOTweenAnimType.Tween_1)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:setPage(self.curPage_)
end

function Season_windowView:setPage(page)
  self.curPage_ = page
  if self.curPage_ > #self.pageViewList_ then
    self.curPage_ = 1
  elseif self.curPage_ < 1 then
    self.curPage_ = #self.pageViewList_
  end
  for k, v in ipairs(self.pageViewList_) do
    self.uiBinder.Ref:SetVisible(v, k == self.curPage_)
  end
  for k, v in ipairs(self.pageDotList_) do
    self.uiBinder.Ref:SetVisible(v, k == self.curPage_)
  end
  self:onStartClickAnimShow(self.pageAnimList_[self.curPage_])
end

function Season_windowView:OnDeActive()
  self.pageViewList_ = {}
  self.pageDotList_ = {}
  self.pageAnimList_ = {}
end

function Season_windowView:OnRefresh()
end

function Season_windowView:startAnimShow()
  self.uiBinder.anim_season:Restart(Z.DOTweenAnimType.Open)
end

function Season_windowView:onStartClickAnimShow(page)
  self.uiBinder.anim_season:Restart(page)
end

return Season_windowView
