local UI = Z.UI
local super = require("ui.ui_view_base")
local Pub_mixology_mainView = class("Pub_mixology_mainView", super)
local loopItem = require("ui.component.pub.burdening_loop_item")
local loopGridView_ = require("ui/component/loop_grid_view")

function Pub_mixology_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "pub_mixology_main")
  self.vm_ = Z.VMMgr.GetVM("pub_mixology")
  self.pubData_ = Z.DataMgr.Get("pub_mixology_data")
end

function Pub_mixology_mainView:initWidgets()
  self.dotween_ = self.uiBinder.anim
  self.makeBtn_ = self.uiBinder.btn_reconcile
  self.closeBtn_ = self.uiBinder.btn_close
  self.recipeBtn_ = self.uiBinder.btn_recipe
  self.skipBtn_ = self.uiBinder.btn_skip
  self.refreshBtn_ = self.uiBinder.btn_refresh
  self.especiallyBtn_ = self.uiBinder.btn_hint
  self.node_quest_ = self.uiBinder.node_root
  self.node_mask_ = self.uiBinder.node_mask
  self.questTran_ = self.uiBinder.node_quest.transform
  self.helpBtn_ = self.uiBinder.btn_ask
  self.topHloop_ = self.uiBinder.up_loop_item
  self.downHloop_ = self.uiBinder.down_loop_item
end

function Pub_mixology_mainView:OnActive()
  self.questTrackBarView = require("ui/view/track_bar_view").new()
  self:initWidgets()
  self.dotween_:Restart(Z.DOTweenAnimType.Open)
  self.mixologyFlowId_ = self.pubData_.FlowId
  self.loopscroll_item_1_ = loopGridView_.new(self, self.topHloop_, loopItem, "com_item_square_2_8")
  self.loopscroll_item_2_ = loopGridView_.new(self, self.downHloop_, loopItem, "com_item_square_2_8")
  self.burdeningFlowNodeIsPlay_ = true
  self.isBeginMake_ = false
  self:AddClick(self.helpBtn_, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30015)
  end)
  self:AddClick(self.closeBtn_, function()
    self.pubData_:QuitMixology()
    self.pubData_.FailCount = 0
    self.vm_.PlayFlowNode(self.mixologyFlowId_, Z.EPFlowEventType.Mixology, "exitmixology")
    self.vm_.CloseMixolopyView()
  end)
  self:AddClick(self.recipeBtn_, function()
    self.vm_.OpenRecipeView()
  end)
  self:AddClick(self.skipBtn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("IsSkipPubMixology"), function()
      local ids = self.vm_.GetCurRecipeIds()
      if 0 < #ids then
        self.uiBinder.Ref.UIComp:SetVisible(false)
        self.isBeginMake_ = true
        self:playSuccessEpflow(ids[#ids])
        self.vm_.CloseMixolopyView()
      end
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  end)
  self:AddClick(self.refreshBtn_, function()
    self.dotween_:Restart(Z.DOTweenAnimType.Open)
    self:refreshLoop()
  end)
  self:AddClick(self.makeBtn_, function()
    if self.pubData_:GetSelectIngeredientCount() > 0 then
      self:updateCheckBtnState()
      self.isBeginMake_ = true
      self.uiBinder.Ref.UIComp:SetVisible(false)
      self:beginMake()
    else
      Z.TipsVM.ShowTipsLang(130040)
    end
  end)
  self:AddClick(self.especiallyBtn_, function()
    self.vm_.OpenRecipeTips()
    self:updateCheckBtnState()
  end)
  self.questTrackBarView:Active(nil, self.questTran_)
  local tb1, tb2 = self.vm_.GetRecipeData()
  self.loopscroll_item_1_:Init(tb1)
  self.loopscroll_item_2_:Init(tb2)
  self.pubData_:InitSelectCount()
  self:changeBtnState(false)
  self:updateCheckBtnState()
  self.vm_.SetCurShowQuestId()
  self:BindEvents()
  self:SetBtnState()
  Z.UICameraHelper.SetCameraFocus(true, Z.Global.CameraFocusMixologyView[1], Z.Global.CameraFocusMixologyView[2])
end

function Pub_mixology_mainView:refreshLoop()
  self.loopscroll_item_1_:RefreshAllShownItem()
  self.loopscroll_item_2_:RefreshAllShownItem()
  self.pubData_:InitSelectCount()
  self.burdeningFlowNodeIsPlay_ = true
  self:changeBtnState(false)
  self.vm_.PlayFlowNode(self.mixologyFlowId_, Z.EPFlowEventType.Mixology, "ResetEvent")
end

function Pub_mixology_mainView:playSuccessEpflow(id)
  self.vm_.PlayFlowNode(self.mixologyFlowId_, Z.EPFlowEventType.Mixology, "cocktail" .. id .. "success")
  self.pubData_.FailCount = 0
  self.vm_.AsyncBartending(id, self.cancelSource:CreateToken())
end

function Pub_mixology_mainView:beginMake()
  if not self.isBeginMake_ or not self.burdeningFlowNodeIsPlay_ then
    return
  end
  self.isBeginMake_ = false
  self.recipeData_ = self.vm_.CheckPubRecipe()
  if self.recipeData_ then
    if self.vm_.CheckCurRecipeID(self.recipeData_.Id) then
      self:playSuccessEpflow(self.recipeData_.Id)
    else
      self.vm_.PlayFlowNode(self.mixologyFlowId_, Z.EPFlowEventType.Mixology, "cocktail" .. self.recipeData_.Id)
      self.pubData_.FailCount = self.pubData_.FailCount + 1
      self.vm_.AddFailEvent()
    end
  else
    self.vm_.PlayFlowNode(self.mixologyFlowId_, Z.EPFlowEventType.Mixology, "cocktail5001")
    self.pubData_.FailCount = self.pubData_.FailCount + 1
    self.vm_.AddFailEvent()
  end
  self.vm_.CloseMixolopyView()
end

function Pub_mixology_mainView:changeBtnState(state)
  self.makeBtn_.IsDisabled = not state
end

function Pub_mixology_mainView:updateCheckBtnState()
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  local isShow = false
  if quest then
    local id = quest.stepId
    isShow = id == Z.Global.MixologyTipsTriggerStepId
  end
  self.uiBinder.Ref:SetVisible(self.especiallyBtn_, isShow)
  local show = isShow and self.vm_.CheckEspeciallyOpen()
  self.uiBinder.Ref:SetVisible(self.node_mask_, show)
end

function Pub_mixology_mainView:SetBtnState()
  local count = self.pubData_:GetSelectIngeredientCount()
  self.makeBtn_.IsDisabled = count == 0
end

function Pub_mixology_mainView:SelectLoopItem(itemData)
  self.makeBtn_.IsDisabled = false
  self:changeBtnState(true)
  local result = self.pubData_:SelectBurdening(itemData)
  self:playBurdeningFlowNode("recipe")
  return result
end

function Pub_mixology_mainView:OnDeActive()
  self.dotween_:Restart(Z.DOTweenAnimType.Close)
  self.questTrackBarView:DeActive()
  if self.loopscroll_item_1_ then
    self.loopscroll_item_1_:UnInit()
  end
  if self.loopscroll_item_2_ then
    self.loopscroll_item_2_:UnInit()
  end
  Z.UICameraHelper.SetCameraFocus(false)
end

function Pub_mixology_mainView:playBurdeningFlowNode(flowName)
  if self.burdeningFlowNodeIsPlay_ then
    local burdeningData = self.pubData_.SelectPubuDataQueue[1]
    table.remove(self.pubData_.SelectPubuDataQueue, 1)
    if burdeningData then
      self.burdeningFlowNodeIsPlay_ = false
      self.vm_.PlayFlowNode(self.mixologyFlowId_, Z.EPFlowEventType.Mixology, flowName .. burdeningData.Id)
    else
      self:beginMake()
    end
  end
end

function Pub_mixology_mainView:playNextBurdeningFlow()
  self.burdeningFlowNodeIsPlay_ = true
  self:playBurdeningFlowNode("recipe")
end

function Pub_mixology_mainView:playAddBurdeningFlow()
  self.burdeningFlowNodeIsPlay_ = true
  self:playBurdeningFlowNode("AddBurdening")
end

function Pub_mixology_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Mixology.MixologyEvent, self.playNextBurdeningFlow, self)
  Z.EventMgr:Add(Z.ConstValue.Mixology.AddBurdeningEvent, self.playAddBurdeningFlow, self)
end

function Pub_mixology_mainView:OnRefresh()
end

return Pub_mixology_mainView
