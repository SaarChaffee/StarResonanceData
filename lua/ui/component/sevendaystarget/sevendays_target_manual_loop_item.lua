local super = require("ui.component.loop_list_view_item")
local SevenDaysTargetManualLoopItem = class("SevenDaysTargetManualLoopItem", super)
local sevendaysRed_ = require("rednode.sevendays_target_red")

function SevenDaysTargetManualLoopItem:ctor()
end

function SevenDaysTargetManualLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.redKey_ = nil
end

function SevenDaysTargetManualLoopItem:OnRefresh(data)
  self.data = data
  self:SetCanSelect(false)
  self:setAnchors(data.isVH)
  local leftBinder, rightBinder
  if data.isVH then
    leftBinder = self.uiBinder.sevendaystarget_figure_tpl_02
    rightBinder = self.uiBinder.sevendaystarget_figure_tpl_01
  else
    leftBinder = self.uiBinder.sevendaystarget_figure_tpl_01
    rightBinder = self.uiBinder.sevendaystarget_figure_tpl_02
  end
  if data.rightInfo then
    local rightPic_ = data.rightInfo.PicVer
    if data.isVH then
      rightPic_ = data.rightInfo.PicHor
    end
    rightBinder.Ref.UIComp:SetVisible(true)
    self:refreshBinderUI(rightBinder, data.rightInfo, data.rightComplete, rightPic_, data.rightProgress)
  else
    rightBinder.Ref.UIComp:SetVisible(false)
  end
  if data.leftInfo then
    local leftPic_ = data.leftInfo.PicHor
    if data.isVH then
      leftPic_ = data.leftInfo.PicVer
    end
    leftBinder.Ref.UIComp:SetVisible(true)
    self:refreshBinderUI(leftBinder, data.leftInfo, data.leftComplete, leftPic_, data.leftProgress)
  else
    leftBinder.Ref.UIComp:SetVisible(false)
  end
  if data.select == 1 then
    self:clickTarget(self.data.leftInfo)
    data.select = 0
  elseif data.select == 2 then
    self:clickTarget(self.data.rightInfo)
    data.select = 0
  end
end

function SevenDaysTargetManualLoopItem:setAnchors(isVH)
  if isVH then
    self.uiBinder.sevendaystarget_figure_tpl_01.Trans:SetAnchors(1, 1, 0.5, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_01.Trans:SetPivot(1, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_01.Trans:SetAnchorPosition(-30, 0)
    self.uiBinder.sevendaystarget_figure_tpl_02.Trans:SetAnchors(0, 0, 0.5, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_02.Trans:SetPivot(0, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_02.Trans:SetAnchorPosition(0, 0)
  else
    self.uiBinder.sevendaystarget_figure_tpl_01.Trans:SetAnchors(0, 0, 0.5, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_01.Trans:SetPivot(0, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_01.Trans:SetAnchorPosition(0, 0)
    self.uiBinder.sevendaystarget_figure_tpl_02.Trans:SetAnchors(1, 1, 0.5, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_02.Trans:SetPivot(1, 0.5)
    self.uiBinder.sevendaystarget_figure_tpl_02.Trans:SetAnchorPosition(-30, 0)
  end
end

function SevenDaysTargetManualLoopItem:refreshBinderUI(binder, cfg, award, pic, progress)
  local vm = Z.VMMgr.GetVM("season_quest_sub")
  local complete = award == vm.AwardState.hasGet
  local canGet_ = award == vm.AwardState.canGet
  if pic and string.len(pic) > 0 then
    binder.rimg_figure:SetImage(pic)
    binder.rimg_figure_grey:SetImage(pic)
  end
  binder.Ref:SetVisible(binder.img_complete, complete)
  binder.lab_complete.text = cfg.Title
  binder.Ref:SetVisible(binder.img_dot, canGet_)
  binder.Ref:SetVisible(binder.rimg_figure_grey, not complete)
  local isOn_ = self.parentUIView.selectManualCfg == cfg
  binder.Ref:SetVisible(binder.rimg_on, isOn_)
  binder.btn:RemoveAllListeners()
  self:AddAsyncListener(binder.btn, function()
    self:clickTarget(cfg, true)
  end)
  self.redKey_ = cfg.TargetId
  local hideProgress_ = progress <= 0 or 100 <= progress or canGet_ or complete
  binder.Ref:SetVisible(binder.lab_schedule, not hideProgress_)
  binder.lab_schedule.text = progress .. "%"
end

function SevenDaysTargetManualLoopItem:clickTarget(cfg, isClick)
  local showVertical_
  if cfg == self.data.leftInfo then
    showVertical_ = self.data.isVH
  else
    showVertical_ = not self.data.isVH
  end
  self.parentUIView:OnClickManualItem(cfg, showVertical_, isClick)
  self:RefreshSelect(true, cfg)
end

function SevenDaysTargetManualLoopItem:RefreshSelect(select, cfg)
  self.uiBinder.sevendaystarget_figure_tpl_02.Ref:SetVisible(self.uiBinder.sevendaystarget_figure_tpl_02.rimg_on, false)
  self.uiBinder.sevendaystarget_figure_tpl_01.Ref:SetVisible(self.uiBinder.sevendaystarget_figure_tpl_01.rimg_on, false)
  if select then
    local isLeft_ = cfg == self.data.leftInfo
    if isLeft_ and self.data.isVH or not isLeft_ and not self.data.isVH then
      self.uiBinder.sevendaystarget_figure_tpl_02.Ref:SetVisible(self.uiBinder.sevendaystarget_figure_tpl_02.rimg_on, true)
    else
      self.uiBinder.sevendaystarget_figure_tpl_01.Ref:SetVisible(self.uiBinder.sevendaystarget_figure_tpl_01.rimg_on, true)
    end
  end
end

function SevenDaysTargetManualLoopItem:OnUnInit()
end

return SevenDaysTargetManualLoopItem
