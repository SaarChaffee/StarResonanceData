local UI = Z.UI
local super = require("ui.ui_subview_base")
local Bpcard_windowView = class("Bpcard_windowView", super)
local season_activation_sub = require("ui/view/season_activation_sub_view")
local battle_pass_content_sub = require("ui/view/cont_bpcard_pass_award_view")

function Bpcard_windowView:ctor(parent)
  self.uiBinder = nil
  self.uiRootPanel_ = parent
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  super.ctor(self, "bpcard_window", "bpcard/bpcard_window", UI.ECacheLv.High, true)
  self.curChoosePage_ = 0
  self.curPageViewTab_ = {
    [1] = {
      funcId = E.FunctionID.None,
      view = season_activation_sub.new(self)
    },
    [2] = {
      funcId = E.FunctionID.SeasonPass,
      view = battle_pass_content_sub.new(self),
      checkFunc = function()
        return self.battlePassVM_.GetCurrentBattlePassContainer()
      end
    }
  }
  self.data_ = Z.DataMgr.Get("season_data")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Bpcard_windowView:OnActive()
  self.uiRootPanel_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.Ref.UIComp.UIDepth)
  local trans_ = self.uiBinder.Trans
  trans_.sizeDelta = Vector2.zero
  trans_.localPosition = Vector3.New(trans_.localPosition.x, trans_.localPosition.y, 0)
  self:initBinders()
  self.tog_List_ = {
    [1] = self.tog_task.tog_tab_select_anim,
    [2] = self.tog_battlepass.tog_tab_select_anim
  }
  local isBpUnlock = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.SeasonPass, true)
  self.tog_battlepass.Ref.UIComp:SetVisible(isBpUnlock)
  self:initParam()
  self:initBtnClick()
  self:initRedPoint()
  Z.EventMgr:Add(Z.ConstValue.BattlePassDataUpdate, self.setBpCardTogCanSwitch, self)
end

function Bpcard_windowView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.BattlePassDataUpdate, self.setBpCardTogCanSwitch, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.SeasonActivationTab, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.BpCardTab, self)
  self.curChoosePage_ = 0
  for _, v in pairs(self.curPageViewTab_) do
    if v then
      v.view:DeActive()
    end
  end
  self.battlePassCardData_ = nil
end

function Bpcard_windowView:OnRefresh()
  self:setBpCardTogCanSwitch()
  local funcId = self.data_:GetSubPageId()
  local index = 1
  if funcId == 1 then
    index = self.battlePassData_.BPCardPageIndex
  else
    self.data_:SetSubPageId(nil)
    index = self:getIndex(funcId)
  end
  if index == E.EBattlePassViewType.BattlePassCard and self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.SeasonPass, true) then
    self:onPageToggleIsOn(2)
    self.tog_battlepass.tog_tab.isOn = true
  else
    self:onPageToggleIsOn(1)
    self.tog_task.tog_tab.isOn = true
  end
end

function Bpcard_windowView:initRedPoint()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SeasonActivationTab, self, self.trans_activation)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.BpCardTab, self, self.trans_pass)
end

function Bpcard_windowView:playEff(index)
  self.tog_List_[index]:Restart(Z.DOTweenAnimType.Open)
  for i = 1, 2 do
    self.tog_task.eff_two_tog:SetEffectGoVisible(i ~= index)
    self.tog_battlepass.eff_two_tog:SetEffectGoVisible(i == index)
  end
end

function Bpcard_windowView:initBinders()
  self.left_node_root = self.uiBinder.node_content_pass_award
  self.trans_activation = self.uiBinder.tog_activation_trans
  self.trans_pass = self.uiBinder.tog_pass_trans
  self.tog_group_node = self.uiBinder.togs_tab_3
  self.tog_task = self.uiBinder.binder_task
  self.tog_battlepass = self.uiBinder.binder_pass
  self.tog_task.tog_tab.group = self.tog_group_node
  self.tog_battlepass.tog_tab.group = self.tog_group_node
end

function Bpcard_windowView:initBtnClick()
  self.tog_task.tog_tab:AddListener(function(isOn)
    if isOn then
      self:onPageToggleIsOn(1)
    end
  end)
  self.tog_battlepass.tog_tab:AddListener(function(isOn)
    if isOn then
      self:onPageToggleIsOn(2)
    end
  end)
end

function Bpcard_windowView:initParam()
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  self.battlePassContainer_ = self.battlePassVM_.GetCurrentBattlePassContainer()
  self.battlePassCardData_ = self.battlePassVM_.AssemblyData()
  self.battlePassData_.BattlePassLevel = self.battlePassContainer_ ~= nil and self.battlePassContainer_.level or 1
end

function Bpcard_windowView:getIndex(funcId)
  if funcId == 1 then
    return funcId
  end
  for index, view in ipairs(self.curPageViewTab_) do
    if view.funcId == funcId then
      return index
    end
  end
  return 1
end

function Bpcard_windowView:onPageToggleIsOn(index)
  if self.curChoosePage_ == index or self.curPageViewTab_[index].checkFunc ~= nil and self.curPageViewTab_[index].checkFunc() == nil then
    return
  end
  local curPageView = self.curPageViewTab_[self.curChoosePage_]
  if curPageView then
    curPageView.view:DeActive()
  end
  self.curChoosePage_ = index
  self:playEff(self.curChoosePage_)
  self.battlePassData_.BPCardPageIndex = index
  curPageView = self.curPageViewTab_[self.curChoosePage_]
  curPageView.view:Active(nil, self.left_node_root)
end

function Bpcard_windowView:setBpCardTogCanSwitch()
  local bpCardData = self.battlePassVM_.GetCurrentBattlePassContainer()
  self.tog_battlepass.tog_tab.IsToggleCanSwitch = bpCardData ~= nil
  self.tog_battlepass.tog_tab.IsDisabled = bpCardData == nil
end

return Bpcard_windowView
