local UI = Z.UI
local super = require("ui.ui_view_base")
local Cutscene_qte_mainView = class("Cutscene_qte_mainView", super)

function Cutscene_qte_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cutscene_qte_main")
end

function Cutscene_qte_mainView:OnActive()
  self:BindEvents()
end

function Cutscene_qte_mainView:OnRefresh()
  if self.viewData == nil then
    return
  end
  self.timerMgr:StopTimer(self.closeTimer_)
  self.closeTimer_ = self.timerMgr:StartTimer(function()
    if table.zcount(self.units) == 0 then
      Z.UIMgr:CloseView("cutscene_qte_main")
    end
  end, 20, -1)
  local qteType = self.viewData.Type
  local qteId = self.viewData.Id
  local x = self.viewData.X
  local y = self.viewData.Y
  local icon = self.viewData.icon
  self.duringTime = self.viewData.duration
  self.uiBtnType = self.viewData.uiType
  self.bNilIcon = icon == "0"
  Z.CoroUtil.create_coro_xpcall(function()
    if qteType == E.CutsceneQteType.ClickOnce then
      local unit = self:createBtnUnit(qteId, x, y, icon)
      self:setClickBtn(unit, icon)
      self:addClickOnceCallback(unit, qteId)
    elseif qteType == E.CutsceneQteType.ClickMulti then
      local unit = self:createBtnUnit(qteId, x, y)
      self:setClickBtn(unit, icon)
      self:addClickMultiCallback(unit, qteId, self.viewData.ClickNum)
    elseif qteType == E.CutsceneQteType.LongPress then
      local unit = self:createBtnUnit(qteId, x, y)
      self:addLongPressCallback(unit, qteId, self.viewData.PressTime)
    elseif qteType == E.CutsceneQteType.Slide then
      self:createSliderUnit(qteId, x, y)
    end
  end)()
end

function Cutscene_qte_mainView:OnDeActive()
end

function Cutscene_qte_mainView:createBtnUnit(qteId, percentX, percentY)
  local preStr = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "qteBtn")
  local unit = self:AsyncLoadUiUnit(preStr, qteId, self.uiBinder.Trans)
  if unit then
    unit.IsEnd = false
    local posTmp = self:getUIPosByScreenPercent(percentX, percentY)
    unit.Trans:SetAnchorPosition(posTmp.x, posTmp.y)
  end
  return unit
end

function Cutscene_qte_mainView:setClickBtn(unit, icon)
  if icon == nil or icon == "" then
    icon = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "defalutIcon")
  end
  if icon == "0" then
    unit.Ref:SetVisible(unit.img_hand_hand, false)
    return
  end
  unit.main_icon_key.lab_key.text = "Q"
  unit.main_icon_key.Ref.UIComp:SetVisible(Z.IsPCUI)
  unit.img_hand_hand:SetImage(icon)
end

function Cutscene_qte_mainView:refreshBtnUIByPress(unit, isPress)
  local size = isPress and 0.7 or 1
  unit.Trans:SetScale(size, size)
  if isPress then
    unit.anim:Restart(Z.DOTweenAnimType.Tween_0)
  end
end

function Cutscene_qte_mainView:getUIPosByScreenPercent(percentX, percentY)
  local screenSize = Z.UIRoot.CurScreenSize
  local _, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.Trans, Vector2.New(percentX * screenSize.x, percentY * screenSize.y), nil)
  return uiPos
end

function Cutscene_qte_mainView:addClickOnceCallback(unit, qteId)
  if unit then
    local clickFunc = function()
      if not unit.IsEnd then
        unit.IsEnd = true
        Z.EPFlowBridge.OnQteClickOnce(qteId)
        unit.Ref:SetVisible(unit.rayimg_touch_area, false)
        self.timerMgr:StartTimer(function()
          unit.Ref:SetVisible(unit.rayimg_touch_area, true)
          self:RemoveUiUnit(qteId)
        end, 2, 1)
      end
    end
    unit.rayimg_touch_area.onClick:AddListener(function()
      clickFunc()
    end)
    unit.rayimg_touch_area.onDown:AddListener(function()
      if not unit.IsEnd then
        self:refreshBtnUIByPress(unit, true)
      end
    end)
    unit.rayimg_touch_area.onUp:AddListener(function()
      self:refreshBtnUIByPress(unit, false)
    end)
    
    function self.qteKeyOnPress_(inputActionEventData)
      clickFunc()
      if not unit.IsEnd then
        unit.rayimg_touch_area_audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.onEventTrigger)
        self:refreshBtnUIByPress(unit, true)
      end
    end
    
    function self.qteKeyOnRelese_(inputActionEventData)
      self:refreshBtnUIByPress(unit, false)
    end
  end
end

function Cutscene_qte_mainView:addClickMultiCallback(unit, qteId, clickNum)
  if unit then
    unit.CurClickNum = 0
    local clickFunc = function()
      unit.CurClickNum = unit.CurClickNum + 1
      if unit.CurClickNum == clickNum and not unit.IsEnd then
        unit.IsEnd = true
        Z.EPFlowBridge.OnQteClickMulti(qteId)
        self.timerMgr:StartTimer(function()
          self:RemoveUiUnit(qteId)
        end, 2, 1)
      end
    end
    unit.rayimg_touch_area.onClick:AddListener(function()
      clickFunc()
    end)
    unit.rayimg_touch_area.onDown:AddListener(function()
      if not unit.IsEnd then
        self:refreshBtnUIByPress(unit, true)
      end
    end)
    unit.rayimg_touch_area.onUp:AddListener(function()
      self:refreshBtnUIByPress(unit, false)
    end)
    
    function self.qteKeyOnPress_(inputActionEventData)
      clickFunc()
      if not unit.IsEnd then
        unit.rayimg_touch_area_audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.onEventTrigger)
        self:refreshBtnUIByPress(unit, true)
      end
    end
    
    function self.qteKeyOnRelese_(inputActionEventData)
      self:refreshBtnUIByPress(unit, false)
    end
  end
end

function Cutscene_qte_mainView:addLongPressCallback(unit, qteId, pressTime)
  if unit then
    local clickFunc = function()
      if not unit.IsEnd then
        self:refreshBtnUIByPress(unit, true)
        unit.PressTimer = self.timerMgr:StartTimer(function()
          unit.IsEnd = true
          Z.EPFlowBridge.OnQteLongPress(qteId)
          self.timerMgr:StartTimer(function()
            self:RemoveUiUnit(qteId)
          end, 2, 1)
        end, pressTime, 1)
      end
    end
    unit.rayimg_touch_area.onDown:AddListener(function()
      clickFunc()
    end)
    local releaseFunc = function()
      self:refreshBtnUIByPress(unit, false)
      if unit.PressTimer then
        self.timerMgr:StopTimer(unit.PressTimer)
        unit.PressTimer = nil
      end
    end
    unit.rayimg_touch_area.onUp:AddListener(function()
      releaseFunc()
    end)
    
    function self.qteKeyOnPress_(inputActionEventData)
      unit.rayimg_touch_area_audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.onEventTrigger)
      clickFunc()
    end
    
    function self.qteKeyOnRelese_(inputActionEventData)
      self:refreshBtnUIByPress(unit, false)
    end
  end
end

function Cutscene_qte_mainView:createSliderUnit(qteId, percentX, percentY)
  local unit = self:AsyncLoadUiUnit("ui/prefabs/cutscene/cutscene_qte_slider_tpl", qteId, self.uiBinder.Trans)
  if unit then
    unit.IsEnd = false
    local posTmp = self:getUIPosByScreenPercent(percentX, percentY)
    unit.Trans:SetAnchorPosition(posTmp.x, posTmp.y)
    unit.Ref:SetVisible(unit.img_success, false)
    unit.Ref:SetVisible(unit.img_fail, false)
    unit.Ref:SetVisible(unit.img_icon, true)
    unit.slider_qte.value = 0
    unit.slider_qte:AddListener(function(value)
      if tonumber(value) == 100 and not unit.IsEnd then
        unit.IsEnd = true
        unit.Ref:SetVisible(unit.img_success, true)
        unit.Ref:SetVisible(unit.img_icon, false)
        unit.slider_qte.interactable = false
        Z.EPFlowBridge.OnQteSlide(qteId)
        self.timerMgr:StartTimer(function()
          self:RemoveUiUnit(qteId)
        end, 2, 1)
      end
    end)
  end
  return unit
end

function Cutscene_qte_mainView:BindEvents()
  Z.EventMgr:Add("CutsceneQteFail", self.onCutsceneQteFail, self)
end

function Cutscene_qte_mainView:onCutsceneQteFail(qteId)
  local unit = self.units[qteId]
  if unit then
    unit.IsEnd = true
    if unit.slider_qte then
      unit.Ref:SetVisible(unit.img_fail, true)
      unit.Ref:SetVisible(unit.img_icon, false)
      unit.slider_qte.interactable = false
    end
    if not unit.isPlayingLoop then
      self.timerMgr:StartTimer(function()
        self:RemoveUiUnit(qteId)
      end, 0.5, 1)
    end
  end
end

function Cutscene_qte_mainView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.CutsceneQTE then
    if inputActionEventData.EventType == Z.InputActionEventType.ButtonJustPressed and self.qteKeyOnPress_ then
      self.qteKeyOnPress_(inputActionEventData)
    end
    if inputActionEventData.EventType == Z.InputActionEventType.ButtonJustReleased and self.qteKeyOnRelese_ then
      self.qteKeyOnRelese_(inputActionEventData)
    end
  end
end

return Cutscene_qte_mainView
