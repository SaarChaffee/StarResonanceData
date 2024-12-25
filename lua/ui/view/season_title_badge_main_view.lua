local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_title_badge_mainView = class("Season_title_badge_mainView", super)

function Season_title_badge_mainView:ctor(parent)
  self.uiRootPanel_ = parent
  self.uiBinder = nil
  super.ctor(self, "season_title_badge_main", "season_title/season_title_badge_main", UI.ECacheLv.None)
  self.subView_ = {
    [1] = {
      funcId = E.FunctionID.SeasonTitle,
      view = require("ui/view/season_title_sub_view").new()
    },
    [2] = {
      funcId = E.FunctionID.SeasonCultivate,
      view = require("ui/view/season_cultivate/season_cultivate_sub_view").new(self)
    }
  }
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.data_ = Z.DataMgr.Get("season_data")
  self.goToFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Season_title_badge_mainView:OnActive()
  self.uiRootPanel_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.Ref.UIComp.UIDepth)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initComp()
  Z.UnrealSceneMgr:AsyncSetBackGround(E.SeasonUnRealBgPath.Scene)
end

function Season_title_badge_mainView:initComp()
  self.togs_ = {
    [1] = self.uiBinder.binder_title,
    [2] = self.uiBinder.binder_badge
  }
  Z.RedPointMgr.LoadRedDotItem(E.FunctionID.SeasonTitle, self, self.uiBinder.binder_title.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.FunctionID.SeasonCultivate, self, self.uiBinder.binder_badge.Trans)
  for index, value in ipairs(self.togs_) do
    value.tog_tab:AddListener(function(isOn)
      if isOn then
        self:onTogOn(index)
      end
    end)
    value.tog_tab.OnPointClickEvent:AddListener(function()
      local isFuncOpen = self.goToFuncVM_.CheckFuncCanUse(self.subView_[index].funcId)
      value.tog_tab.IsToggleCanSwitch = isFuncOpen
    end)
  end
end

function Season_title_badge_mainView:onTogOn(index)
  for i, _ in ipairs(self.togs_) do
    if i == index then
      local funcId = self.subView_[i].funcId
      if not self.switchVm_.CheckFuncSwitch(funcId) then
        return
      end
      self.subView_[i].view:Active(nil, self.uiBinder.node_sub)
      self.togs_[i].tog_tab_select_anim:Restart(Z.DOTweenAnimType.Open)
      self.togs_[i].eff_two_tog:SetEffectGoVisible(true)
    else
      self.subView_[i].view:DeActive()
      self.togs_[i].eff_two_tog:SetEffectGoVisible(false)
    end
  end
end

function Season_title_badge_mainView:OnDeActive()
  for _, view in pairs(self.subView_) do
    view.view:DeActive()
  end
end

function Season_title_badge_mainView:getIndex(funcId)
  if funcId == 1 then
    return funcId
  end
  for index, view in ipairs(self.subView_) do
    if view.funcId == funcId then
      return index
    end
  end
  return 1
end

function Season_title_badge_mainView:OnRefresh()
  local funcId = self.data_:GetSubPageId()
  local index = self:getIndex(funcId)
  local isFuncOpen = self.goToFuncVM_.CheckFuncCanUse(self.subView_[index].funcId)
  if not isFuncOpen then
    index = 1
  end
  if self.togs_[index].tog_tab.isOn then
    self:onTogOn(index)
  else
    self.togs_[index].tog_tab.isOn = true
  end
end

return Season_title_badge_mainView
