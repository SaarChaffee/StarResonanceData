local UI = Z.UI
local super = require("ui.ui_view_base")
local Fashion_systemView = class("Fashion_systemView", super)
local EFashionFirstTab = {Clothes = 1, Ornament = 2}
local firstTabDefaultSelectDict = {
  [EFashionFirstTab.Clothes] = E.FashionRegion.Suit,
  [EFashionFirstTab.Ornament] = E.FashionRegion.Headwear
}
local firstTab2Name = {
  [EFashionFirstTab.Clothes] = "clothes",
  [EFashionFirstTab.Ornament] = "ornament"
}
local regionTabDict = {
  [E.FashionRegion.Suit] = {
    Name = "suit",
    Parent = EFashionFirstTab.Clothes,
    IsFocus = false
  },
  [E.FashionRegion.UpperClothes] = {
    Name = "upper_clothes",
    Parent = EFashionFirstTab.Clothes,
    IsFocus = false
  },
  [E.FashionRegion.Pants] = {
    Name = "pants",
    Parent = EFashionFirstTab.Clothes,
    IsFocus = false
  },
  [E.FashionRegion.Gloves] = {
    Name = "gloves",
    Parent = EFashionFirstTab.Clothes,
    IsFocus = false
  },
  [E.FashionRegion.Shoes] = {
    Name = "shoes",
    Parent = EFashionFirstTab.Clothes,
    IsFocus = false
  },
  [E.FashionRegion.Tail] = {
    Name = "tail",
    Parent = EFashionFirstTab.Clothes,
    IsFocus = false
  },
  [E.FashionRegion.Headwear] = {
    Name = "headwear",
    Parent = EFashionFirstTab.Ornament,
    IsFocus = true
  },
  [E.FashionRegion.FaceMask] = {
    Name = "face_mask",
    Parent = EFashionFirstTab.Ornament,
    IsFocus = true
  },
  [E.FashionRegion.MouthMask] = {
    Name = "mouth_mask",
    Parent = EFashionFirstTab.Ornament,
    IsFocus = true
  },
  [E.FashionRegion.Earrings] = {
    Name = "earrings",
    Parent = EFashionFirstTab.Ornament,
    IsFocus = true
  },
  [E.FashionRegion.Necklace] = {
    Name = "necklace",
    Parent = EFashionFirstTab.Ornament,
    IsFocus = true
  },
  [E.FashionRegion.Ring] = {
    Name = "ring",
    Parent = EFashionFirstTab.Ornament,
    IsFocus = true
  }
}

function Fashion_systemView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fashion_system")
  self.styleView_ = require("ui/view/fashion_style_select_view").new(self)
  self.dyeingView_ = require("ui/view/fashion_dyeing_view").new(self)
  self.settingView_ = require("ui/view/fashion_setting_sub_view").new(self)
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.faceVM_ = Z.VMMgr.GetVM("face")
end

function Fashion_systemView:SetScrollContent(trans)
  self.uiBinder.scrollview_menu:ClearAll()
  self.uiBinder.scrollview_menu.content = trans
  self.uiBinder.scrollview_menu:RefreshContentEvent()
  self.uiBinder.scrollview_menu:Init()
end

function Fashion_systemView:OpenDyeingView(fashionId, area)
  if self.uiBinder.btn_save then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, false)
  end
  if self.uiBinder.node_dyeing_btn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_dyeing_btn, true)
  end
  self:updateSaveBtnState(fashionId)
  self.styleView_:DeActive()
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  self.dyeingView_:Active({
    fashionId = fashionId,
    area = area,
    isPreview = false
  }, self.uiBinder.node_viewport)
end

function Fashion_systemView:OpenStyleView()
  if self.uiBinder.btn_save then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, true)
  end
  if self.uiBinder.node_dyeing_btn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_dyeing_btn, false)
  end
  self.dyeingView_:DeActive()
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  self.styleView_:Active({
    region = self.curRegion_
  }, self.uiBinder.node_viewport)
  self:onOpenStyleView()
end

function Fashion_systemView:updateSaveBtnState(fashionId)
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if not fashionRow then
    return
  end
  local colorConfigRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
  if colorConfigRow and colorConfigRow.Type == E.EHueModifiedMode.Board then
    if self.uiBinder.btn_save_dyeing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save_dyeing, false)
    end
    if self.uiBinder.btn_confirm_dyeing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_confirm_dyeing, true)
    end
  else
    if self.uiBinder.btn_save_dyeing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save_dyeing, true)
    end
    if self.uiBinder.btn_confirm_dyeing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_confirm_dyeing, false)
    end
  end
end

function Fashion_systemView:onOpenStyleView()
end

function Fashion_systemView:OnActive()
  Z.AudioMgr:Play("sys_player_wardrobe_in")
  if self.uiBinder.cont_tail_tab then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_tail_tab.Ref, false)
  end
  if self.viewData and self.viewData.gotoData then
    self.fashionData_:SetWear(self.fashionVM_.GetFashionRegion(self.viewData.gotoData.FashionId), {
      fashionId = self.viewData.gotoData.FashionId
    })
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967293, true)
  Z.PlayerInputController.InputTouchCheckOverUICount = 1
  Z.PlayerInputController:SetCameraStretchIgnoreCheckUI(true)
  Z.UnrealSceneMgr:InitSceneCamera(true)
  Z.PlayerInputController.IsCheckZoomClickingUI = false
  Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(0.25, 0.88)
  Z.UnrealSceneMgr:SetZoomAutoChangeLookAtZoomRange(0.88, 0.25)
  self.offset_ = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(self.faceData_:GetPlayerModelId())
  Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.4, 0.5))
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:preLoadTimeline()
  self:refreshCameraFocus(0, true)
  Z.UnrealSceneMgr:SetAutoChangeLook(true)
  self.curSecondTabGroup_ = nil
  self.isSwitchSecond_ = true
  self.curRegion_ = nil
  self.tabSelectDict_ = {}
  self.playerModel_ = nil
  self.curRotation_ = 180
  self.curRegionActionId_ = 0
  self.currentSelect_ = 1
  self:initFashionData()
  self:initPlayerModel()
  self:initTab()
  self:AddClick(self.uiBinder.btn_return, function()
    self:OnInputBack()
  end)
  if self.uiBinder.btn_return_main then
    self:AddClick(self.uiBinder.btn_return_main, function()
      self:OpenStyleView()
    end)
  end
  self.uiBinder.tog_setting.isOn = false
  self.uiBinder.tog_setting:AddListener(function(isOn)
    if isOn then
      self.settingView_:Active(nil, self.uiBinder.node_setting)
    else
      self.settingView_:DeActive()
    end
  end)
  self:AddClick(self.uiBinder.btn_reset, function()
    self.fashionVM_.RevertAllFashionWear()
    self:OpenStyleView()
  end)
  if self.uiBinder.btn_save then
    self:AddAsyncClick(self.uiBinder.btn_save, function()
      self:onClickSaveAll()
    end)
  end
  if self.uiBinder.btn_save_dyeing then
    self:AddAsyncClick(self.uiBinder.btn_save_dyeing, function()
      self.dyeingView_:Save()
    end)
  end
  if self.uiBinder.btn_confirm_dyeing then
    self:AddAsyncClick(self.uiBinder.btn_confirm_dyeing, function()
      self.dyeingView_:ConfirmSaveWithCost()
    end)
  end
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30040)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_ask, true)
  if self.uiBinder.btn_collect then
    self:AddClick(self.uiBinder.btn_collect, function()
      local WardrobeData = {}
      WardrobeData.parent = self.uiBinder.node_collect
      WardrobeData.personalZone = Z.ContainerMgr.CharSerialize.personalZone
      Z.UIMgr:OpenView("wardrobe_collection_tips", WardrobeData)
    end)
  end
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    if Z.TouchManager.TouchCount > 1 then
      return
    end
    self:onModelDrag(eventData)
  end)
  self:refreshCollectPoint()
  self:startAnimatedShow()
  self:BindEvents()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncCheckPersonalZone()
  end)()
  
  function self.onContainerDataChange_(container, dirtyKeys)
    self:refreshCollectPoint()
  end
  
  Z.ContainerMgr.CharSerialize.personalZone.Watcher:RegWatcher(self.onContainerDataChange_)
end

function Fashion_systemView:onModelDrag(eventData)
  if not self.playerModel_ or not self.curTimelineId_ then
    return
  end
  self.curRotation_ = self.curRotation_ - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.curTimelineId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
end

function Fashion_systemView:preLoadTimeline()
  Z.UITimelineDisplay:ClearTimeLine()
  self.timelineInfoList_ = {}
  self.curTimelineId_ = nil
  local fashionConfig
  if self.faceData_:GetPlayerGender() == Z.PbEnum("EGender", "GenderMale") then
    fashionConfig = Z.Global.FashionShowActionM
    self.playerIdleId_ = 50000035
  else
    fashionConfig = Z.Global.FashionShowActionF
    self.playerIdleId_ = 50000034
  end
  for _, timelineInfo in ipairs(fashionConfig) do
    local region = timelineInfo[1]
    local timelineId = timelineInfo[2]
    self.timelineInfoList_[region] = timelineId
  end
  Z.UITimelineDisplay:AsyncPreLoadTimeline(self.playerIdleId_, self.cancelSource:CreateToken())
end

function Fashion_systemView:refreshCollectPoint()
  if self.uiBinder.lab_num then
    self.uiBinder.lab_num.text = Z.ContainerMgr.CharSerialize.personalZone.fashionCollectPoint
  end
end

function Fashion_systemView:asyncCheckPersonalZone()
  if not Z.StageMgr.GetIsInLogin() then
    return
  end
  if not Z.ContainerMgr.CharSerialize.personalZone.fashionRefreshFlag then
    return
  end
  self.fashionVM_.AsyncRefreshPersonalZoneFashionScore()
end

function Fashion_systemView:OnRefresh()
  if self.viewData then
    if self.viewData.gotoData then
      self:onFashionSaveConfirmItemClick(self.viewData.gotoData)
    else
      self.fashionVM_.RefreshWearAttr()
    end
  end
end

function Fashion_systemView:OnDeActive()
  Z.PlayerInputController.InputTouchCheckOverUICount = 0
  Z.PlayerInputController:SetCameraStretchIgnoreCheckUI(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967293, false)
  Z.PlayerInputController.IsCheckZoomClickingUI = true
  Z.UnrealSceneMgr:SetAutoChangeLook(false)
  Z.UnrealSceneMgr:RestUnrealSceneCameraZoomRange()
  self.styleView_:DeActive()
  self.dyeingView_:DeActive()
  self.settingView_:DeActive()
  self:showOrHideEffect(self.currentSelect_, false)
  self.isSwitchSecond_ = true
  self.curSecondTabGroup_ = nil
  self.curRegion_ = nil
  self.tabSelectDict_ = nil
  self.timelineInfoList_ = nil
  if self.curTimelineId_ then
    local quaternion = Quaternion.Euler(Vector3.New(0, 180, 0))
    Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.curTimelineId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
  end
  self.curTimelineId_ = nil
  Z.UITimelineDisplay:ClearTimeLine()
  self:clearTab()
  self:clearModel()
  self.fashionData_:Clear()
  self.fashionData_:ClearWearDict()
  Z.UIMgr:CloseView("wardrobe_collection_tips")
  Z.ContainerMgr.CharSerialize.personalZone.Watcher:UnregWatcher(self.onContainerDataChange_)
end

function Fashion_systemView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("fashion_system")
end

function Fashion_systemView:GetCacheData()
  local viewData = {
    firstTab = self.curFirstTab_,
    region = self.curRegion_,
    wear = table.zclone(self.fashionData_:GetWears()),
    color = table.zclone(self.fashionData_:GetColors())
  }
  return viewData
end

function Fashion_systemView:clearModel()
  Z.UnrealSceneMgr:ClearModel(self.playerModel_)
  self.playerModel_ = nil
end

function Fashion_systemView:showOrHideEffect(tabIndex, isShow)
  local effect = self.uiBinder[string.zconcat("eff_root", tabIndex)]
  if effect then
    effect:SetEffectGoVisible(isShow)
  end
end

function Fashion_systemView:initTab()
  local firstTab = EFashionFirstTab.Clothes
  if self.viewData and self.viewData.firstTab then
    firstTab = self.viewData.firstTab
  end
  local region
  if self.viewData and self.viewData.region then
    region = self.viewData.region
  elseif firstTab == EFashionFirstTab.Clothes then
    region = E.FashionRegion.Suit
  else
    region = E.FashionRegion.Headwear
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_tab2_clothes, firstTab == EFashionFirstTab.Clothes)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_tab2_ornament, firstTab == EFashionFirstTab.Ornament)
  local firstTabTog
  for _, firstTabType in pairs(EFashionFirstTab) do
    local widget = self:getFirstTabNode(firstTabType)
    widget.tog_tab_select:RemoveAllListeners()
    widget.tog_tab_select:SetIsOnWithoutCallBack(false)
    widget.tog_tab_select.group = self.uiBinder.togs_tab1
    widget.tog_tab_select:AddListener(function(isOn)
      if not self.uiBinder then
        return
      end
      self:showOrHideEffect(firstTabType, isOn)
      if isOn then
        local commonVM_ = Z.VMMgr.GetVM("common")
        commonVM_.CommonPlayTogAnim(widget.anim_tog, self.cancelSource:CreateToken())
        if self.curFirstTab_ and self.curRegion_ then
          self.tabSelectDict_[self.curFirstTab_] = self.curRegion_
        end
        self:switchSecondTabGroupByFirstTab(firstTabType)
      end
    end)
    if firstTab == firstTabType then
      firstTabTog = widget
    end
  end
  local secondTabTog
  for _, regionType in pairs(E.FashionRegion) do
    local widget = self:getSecondTabNodeByRegion(regionType)
    widget.tog_tab:RemoveAllListeners()
    widget.tog_tab:SetIsOnWithoutCallBack(false)
    widget.tog_tab.group = self.uiBinder.togs_tab2
    widget.eff_two_tog:SetEffectGoVisible(widget.isOn)
    widget.tog_tab:AddListener(function(isOn)
      widget.tog_tab_select_anim:Restart(Z.DOTweenAnimType.Open)
      widget.eff_two_tog:SetEffectGoVisible(isOn)
      if not self.uiBinder then
        return
      end
      if isOn then
        self:switchRegion(regionType)
      end
    end)
    if region == regionType then
      secondTabTog = widget
    end
  end
  if firstTabTog then
    firstTabTog.tog_tab_select.isOn = true
  end
end

function Fashion_systemView:clearTab()
  for _, firstTabType in pairs(EFashionFirstTab) do
    local widget = self:getFirstTabNode(firstTabType)
    widget.tog_tab_select:RemoveAllListeners()
    widget.tog_tab_select.group = nil
    widget.tog_tab_select:SetIsOnWithoutNotify(false)
  end
  for _, regionType in pairs(E.FashionRegion) do
    local widget = self:getSecondTabNodeByRegion(regionType)
    widget.tog_tab:RemoveAllListeners()
    widget.tog_tab.group = nil
    widget.tog_tab:SetIsOnWithoutNotify(false)
  end
end

function Fashion_systemView:switchSecondTabGroupByFirstTab(firstTab)
  self.curFirstTab_ = firstTab
  local tabGroup = self.uiBinder["cont_tab2_" .. firstTab2Name[firstTab]]
  if self.curSecondTabGroup_ then
    self.uiBinder.Ref:SetVisible(self.curSecondTabGroup_, false)
  end
  self.curSecondTabGroup_ = tabGroup
  if self.curSecondTabGroup_ then
    self.uiBinder.Ref:SetVisible(self.curSecondTabGroup_, true)
  end
  local region = self.tabSelectDict_[firstTab] or firstTabDefaultSelectDict[firstTab]
  if self.viewData and self.viewData.region then
    region = self.viewData.region
    self.viewData.region = nil
  end
  local widget = self:getSecondTabNodeByRegion(region)
  self.currentSelect_ = region
  if not self.isSwitchSecond_ then
    return
  end
  if widget.tog_tab.isOn then
    if widget.eff_two_tog then
      widget.eff_two_tog:SetEffectGoVisible(true)
    end
    if not self.uiBinder then
      return
    end
    self:switchRegion(region)
  else
    widget.tog_tab.isOn = true
  end
  if firstTab == 2 then
    self:startPlaySelectAnim()
  else
    self:startPlaySelect2Anim()
  end
  self:startTabPlaySelectAnim()
end

function Fashion_systemView:getFirstTabNode(firstTab)
  return self.uiBinder["group_tog_" .. firstTab2Name[firstTab]]
end

function Fashion_systemView:getSecondTabNodeByRegion(region)
  local name = "cont_" .. regionTabDict[region].Name .. "_tab"
  local cont = self.uiBinder[name]
  return cont
end

function Fashion_systemView:switchRegion(region)
  self.curRegion_ = region
  self:OpenStyleView()
  self:refreshViewTitle()
  self:refreshModelAction()
  self:changeCameraFocus()
end

function Fashion_systemView:refreshViewTitle()
  local regionName = self.fashionVM_.GetRegionName(self.curRegion_)
  local commonVM = Z.VMMgr.GetVM("common")
  local funcName = commonVM.GetTitleByConfig(E.FunctionID.Fashion)
  local titleStr = funcName .. "/" .. regionName
  self.uiBinder.lab_title.text = titleStr
end

function Fashion_systemView:initFashionData()
  self.fashionData_:InitFashionData()
  if self.viewData and self.viewData.wear then
    self.fashionData_:SetAllWear(self.viewData.wear)
  end
  if self.viewData and self.viewData.color then
    self.fashionData_:SetAllColor(self.viewData.color)
  end
end

function Fashion_systemView:initPlayerModel()
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    Z.UnrealSceneMgr:SetModelCustomShadow(model, false)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
  end, function()
    Z.UIMgr:FadeOut()
  end)
end

function Fashion_systemView:refreshModelAction()
  local timelineId = self.timelineInfoList_[self.curRegion_]
  Z.UITimelineDisplay:RemoveGoQuaternionByCutsceneId(timelineId)
  if self.curTimelineId_ ~= timelineId then
    Z.UITimelineDisplay:Stop()
    if timelineId then
      Z.UITimelineDisplay:BindModel(0, self.playerModel_)
      Z.UITimelineDisplay:Play(timelineId, nil, function()
        self:playModelIdleAction()
      end)
    end
    self.curTimelineId_ = timelineId
  end
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(timelineId, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
end

function Fashion_systemView:playModelIdleAction()
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.playerIdleId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
  Z.UITimelineDisplay:BindModel(0, self.playerModel_)
  Z.UITimelineDisplay:Play(self.playerIdleId_)
  self.curTimelineId_ = self.playerIdleId_
end

function Fashion_systemView:changeCameraFocus()
  local isOnHead = regionTabDict[self.curRegion_].IsFocus
  if isOnHead then
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusHead", Vector3.New(0, self.offset_.x, 0))
  else
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusBody", Vector3.New(0, self.offset_.y, 0))
  end
end

function Fashion_systemView:OnInputBack()
  self.dyeingView_:ClearTips()
  local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
  if saveVM.IsFashionWearChange() then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("UnSaveFashionColor"), function()
      self.fashionVM_.CloseFashionSystemView()
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.UnSaveFashionColor)
  else
    self.fashionVM_.CloseFashionSystemView()
  end
end

function Fashion_systemView:onClickSaveAll()
  local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
  local dataList = saveVM.GetFashionConfirmDataList()
  if 0 < #dataList then
    saveVM.OpenSaveTipsView()
  else
    self.fashionVM_.AsyncSaveAllFashion(self.cancelSource)
  end
end

function Fashion_systemView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
  Z.EventMgr:Add(Z.ConstValue.FashionSaveConfirmItemClick, self.onFashionSaveConfirmItemClick, self)
  Z.EventMgr:Add("ModelMatRaiseHeight", self.refreshCameraFocus, self)
end

function Fashion_systemView:refreshCameraFocus(value, init)
  if init then
    local EModelPinchHeight = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchHeight)
    local heightSliderValue = math.floor(EModelPinchHeight * 10 + 0.5)
    local scale = self.faceVM_.GetLookAtOffsetScale(E.ELookAtScaleType.BodyHeight)
    Z.UnrealSceneMgr:SetZoomAutoChangeLookAtByOffset(self.offset_.x + heightSliderValue / scale, self.offset_.y)
    return
  end
end

function Fashion_systemView:onFashionAttrChange(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  self:setAllModelAttr("SetLuaAttr", attrType, table.unpack(arg))
end

function Fashion_systemView:setAllModelAttr(funcName, ...)
  local arg = {
    ...
  }
  self.playerModel_[funcName](self.playerModel_, table.unpack(arg))
end

function Fashion_systemView:onFashionSaveConfirmItemClick(confirmData)
  local fashionId = confirmData.FashionId
  local region = self.fashionVM_.GetFashionRegion(fashionId)
  self.isSwitchSecond_ = false
  local firstTabNode = self:getFirstTabNode(regionTabDict[region].Parent)
  firstTabNode.tog_tab_select.isOn = true
  local secondTabNode = self:getSecondTabNodeByRegion(region)
  secondTabNode.tog_tab.isOn = true
  self.isSwitchSecond_ = true
  local reason = confirmData.Reason
  if reason == E.FashionTipsReason.UnlockedColor then
    self:OpenDyeingView(fashionId, confirmData.AreaList[1])
  end
end

function Fashion_systemView:startPlaySelectAnim()
  self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_1)
end

function Fashion_systemView:startPlaySelect2Anim()
  self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_3)
end

function Fashion_systemView:startTabPlaySelectAnim()
  self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_2)
end

function Fashion_systemView:startAnimatedShow()
  self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Open)
end

function Fashion_systemView:startAnimatedHide()
  self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Close)
end

function Fashion_systemView:CustomClose()
end

return Fashion_systemView
