local UI = Z.UI
local super = require("ui.ui_subview_base")
local Themeact_subView = class("Themeact_subView", super)
local loopListView = require("ui.component.loop_list_view")
local loopTabItem = require("ui/component/themeact/theme_activity_tab_item")

function Themeact_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "themeact_sub", "themeact/themeact_sub", UI.ECacheLv.None)
  self.parent_ = parent
end

function Themeact_subView:OnActive()
  Z.AudioMgr:Play("UI_Menu_Recommend_Open")
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  local activityId = self.viewData and self.viewData.ActivityId or nil
  self:refreshAllTabItem(activityId)
end

function Themeact_subView:OnDeActive()
  self:unInitLoopComp()
  if self.curSubView_ ~= nil then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curConfig_ = nil
  self.commonSubActivityView_ = nil
  self.subActivityViewPathDict_ = nil
  self.subActivityViewDict_ = nil
end

function Themeact_subView:OnRefresh()
end

function Themeact_subView:initData()
  self.themePlayVM_ = Z.VMMgr.GetVM("theme_play")
  self.commonSubActivityView_ = require("ui.view.themeact_common_sub_view").new(self)
  self.subActivityViewPathDict_ = {
    [E.ThemeActivityFunctionId.Sign1] = "ui.view.themeact_sign_sub_view",
    [E.ThemeActivityFunctionId.Sign2] = "ui.view.themeact_sign_summer_sub_view",
    [E.ThemeActivityFunctionId.Entrance] = "ui.view.themeact_entrance_sub_view",
    [E.ThemeActivityFunctionId.Celebration] = "ui.view.themeact_celebration_sub_view"
  }
  self.subActivityViewDict_ = {}
end

function Themeact_subView:initComponent()
  self:initLoopComp()
  self.uiBinder.comp_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Themeact_subView:initLoopComp()
  self.loopTabListView_ = loopListView.new(self, self.uiBinder.loop_item, loopTabItem, "themeact_main_tab_tpl")
  self.loopTabListView_:Init({})
end

function Themeact_subView:unInitLoopComp()
  self.loopTabListView_:UnInit()
  self.loopTabListView_ = nil
end

function Themeact_subView:refreshAllTabItem(selectActivityId)
  local dataList = self.themePlayVM_:GetMainActivityList()
  self.loopTabListView_:ClearAllSelect()
  self.loopTabListView_:RefreshListView(dataList)
  local selectIndex = 1
  if selectActivityId then
    for i, v in ipairs(dataList) do
      if v.config.Id == selectActivityId then
        selectIndex = i
        break
      end
    end
  end
  self.loopTabListView_:SetSelected(selectIndex)
  self:SetUIVisible(self.uiBinder.node_empty, #dataList == 0)
end

function Themeact_subView:OnTabItemSelected(data)
  local config = data.config
  local subFunctionId = config.FunctionId
  local timeStage = self.themePlayVM_:GetActivityTimeStage(config.Id)
  if config.UiMode or timeStage == E.SeasonActivityTimeStage.NotOpen then
    self:switchSubView(self.commonSubActivityView_, data)
  else
    if self.subActivityViewDict_[subFunctionId] == nil then
      local subViewPath = self.subActivityViewPathDict_[subFunctionId]
      if subViewPath then
        self.subActivityViewDict_[subFunctionId] = require(subViewPath).new(self)
      else
        logError("[Themeact_subView:OnTabItemSelected] missing config, function id = " .. subFunctionId)
      end
    end
    self:switchSubView(self.subActivityViewDict_[subFunctionId], data)
  end
end

function Themeact_subView:switchSubView(subView, data, isPreview)
  if self.curSubView_ ~= nil then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
    self.curConfig_ = nil
    self.parent_:ShowOrHideAskBtn(false)
  end
  if subView == nil then
    return
  end
  self.curSubView_ = subView
  self.curConfig_ = data.config
  self.uiBinder.rimg_bg:SetImage(isPreview and self.curConfig_.PreBackGroundPic or self.curConfig_.BackGroundPic)
  self.curSubView_:Active(data, self.uiBinder.node_activity_sub)
  if self.curConfig_ and self.curConfig_.HelpTipsId > 0 then
    self.parent_:ShowOrHideAskBtn(true)
  end
end

function Themeact_subView:OnAskBtnClick()
  if self.curConfig_ ~= nil and self.curConfig_.HelpTipsId > 0 then
    Z.VMMgr.GetVM("helpsys").CheckAndShowView(self.curConfig_.HelpTipsId)
  end
end

function Themeact_subView:GetActivityId()
  if self.curConfig_ then
    return self.curConfig_.Id
  end
end

return Themeact_subView
