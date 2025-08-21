local UI = Z.UI
local super = require("ui.ui_view_base")
local Fashion_systemView = class("Fashion_systemView", super)
E.EFashionFirstTab = {
  EClothes = 1,
  EOrnament = 2,
  EWeaponSkin = 3
}
local regionDataDict = {
  [E.EFashionFirstTab.EClothes] = {
    [1] = {
      region = E.FashionRegion.Suit,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_241",
      IsFocus = false
    },
    [2] = {
      region = E.FashionRegion.UpperClothes,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_242",
      IsFocus = false
    },
    [3] = {
      region = E.FashionRegion.Pants,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_232",
      IsFocus = false
    },
    [4] = {
      region = E.FashionRegion.Gloves,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_233",
      IsFocus = false
    },
    [5] = {
      region = E.FashionRegion.Shoes,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_234",
      IsFocus = false
    }
  },
  [E.EFashionFirstTab.EOrnament] = {
    [1] = {
      region = E.FashionRegion.Headwear,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_235",
      IsFocus = true
    },
    [2] = {
      region = E.FashionRegion.FaceMask,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_236",
      IsFocus = true
    },
    [3] = {
      region = E.FashionRegion.MouthMask,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_237",
      IsFocus = true
    },
    [4] = {
      region = E.FashionRegion.Back,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_30",
      IsFocus = false
    },
    [5] = {
      region = E.FashionRegion.Earrings,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_243",
      IsFocus = true
    },
    [6] = {
      region = E.FashionRegion.Necklace,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_240",
      IsFocus = true
    },
    [7] = {
      region = E.FashionRegion.Ring,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_238",
      IsFocus = true
    }
  },
  [E.EFashionFirstTab.EWeaponSkin] = {
    [1] = {
      region = E.FashionRegion.WeapoonSkin,
      icon = "ui/atlas/item/c_tab_icon/com_icon_tab_208",
      IsFocus = false
    }
  }
}
local loopListView = require("ui.component.loop_list_view")
local second_Item = require("ui.component.fashion.fashion_second_item")

function Fashion_systemView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fashion_system")
end

function Fashion_systemView:OnActive()
  Z.AudioMgr:Play("sys_player_wardrobe_in")
  if self.uiBinder.cont_tail_tab then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_tail_tab.Ref, false)
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967293, true)
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:initVM()
  self:initSubView()
  self:preLoadTimeline()
  self:refreshUIClick(true)
  self:initFashionCamera()
  self:initViewData()
  self:initFashionData()
  self:initPlayerModel()
  self:initLoopTab()
  self:initFirstTab()
  self:initPlayerAction()
  self:initFunc()
  self:onInitRed()
  self:refreshCollectPoint()
  self:refreshMemberCenter()
  self:refreshOptionBtnState()
  self:startAnimatedShow()
  self:BindEvents()
end

function Fashion_systemView:OnDeActive()
  self:refreshUIClick(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967293, false)
  Z.UnrealSceneMgr:SetAutoChangeLook(false)
  Z.UnrealSceneMgr:RestUnrealSceneCameraZoomRange()
  self:clearFirstTab()
  self:clearLoopTab()
  self:clearTimeLine()
  self:showOrHideEffect(self.currentSelect_, false)
  self.curRegion_ = nil
  self.curProfessionId_ = nil
  self:clearFirstTab()
  self:clearModel()
  self.fashionData_:Clear()
  self.fashionData_:ClearWearDict()
  self.fashionData_:ClearOptionList()
  Z.UIMgr:CloseView("wardrobe_collection_tips")
  self.firstShowIdle_ = false
  self:clearRed()
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.settingView_:DeActive()
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

function Fashion_systemView:SetScrollContent(trans)
  self.uiBinder.scrollview_menu:ClearAll()
  self.uiBinder.scrollview_menu.content = trans
  self.uiBinder.scrollview_menu:RefreshContentEvent()
  self.uiBinder.scrollview_menu:Init()
end

function Fashion_systemView:initSubView()
  self.styleView_ = require("ui/view/fashion_style_select_view").new(self)
  self.dyeingView_ = require("ui/view/fashion_dyeing_view").new(self)
  self.customizedView_ = require("ui/view/fashion_customized_sub_view").new(self)
  self.weaponSkinStyleView_ = require("ui/view/fashion_weapon_skin_select_view").new(self)
  self.settingView_ = require("ui/view/fashion_setting_sub_view").new(self)
end

function Fashion_systemView:initVM()
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.switchVM_ = Z.VMMgr.GetVM("switch")
end

function Fashion_systemView:refreshUIClick(openClick)
  if openClick then
    Z.PlayerInputController.InputTouchCheckOverUICount = 1
    Z.PlayerInputController:SetCameraStretchIgnoreCheckUI(true)
    Z.PlayerInputController.IsCheckZoomClickingUI = false
  else
    Z.PlayerInputController.InputTouchCheckOverUICount = 0
    Z.PlayerInputController:SetCameraStretchIgnoreCheckUI(false)
    Z.PlayerInputController.IsCheckZoomClickingUI = true
  end
end

function Fashion_systemView:initFashionCamera()
  Z.UnrealSceneMgr:InitSceneCamera(true)
  Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(0.25, 0.88)
  Z.UnrealSceneMgr:SetZoomAutoChangeLookAtZoomRange(0.88, 0.25)
  Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.4, 0.5))
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self.offset_ = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(self.faceData_:GetPlayerModelId())
  self:refreshCameraFocus(0, true)
  Z.UnrealSceneMgr:SetAutoChangeLook(true)
end

function Fashion_systemView:initViewData()
  self.fashionData_:ClearOptionList()
  self.fashionData_:ClearWearDict()
  self.fashionData_:ClearAdvanceSelectData()
  self.playerModel_ = nil
  self.currentSelect_ = 1
  self.firstShowIdle_ = Z.StageMgr.GetIsInSelectCharScene()
  self.curSubView_ = nil
end

function Fashion_systemView:initFunc()
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    if Z.TouchManager.TouchCount > 1 then
      return
    end
    self:onModelDrag(eventData)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self:OnInputBack()
  end)
  if self.uiBinder.btn_member_center then
    self:AddClick(self.uiBinder.btn_member_center, function()
      Z.UIMgr:OpenView("collection_window")
    end)
  end
  self:AddClick(self.uiBinder.btn_move, function()
    self.fashionVM_.MoveEditorOperation()
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    self.fashionVM_.ReturnEditorOperation()
  end)
  self.uiBinder.tog_setting.isOn = false
  self.uiBinder.tog_setting:AddListener(function(isOn)
    if isOn then
      self.settingView_:Active(nil, self.uiBinder.node_setting)
    else
      self.settingView_:DeActive()
    end
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_setting, not Z.StageMgr.GetIsInLogin())
  self:AddClick(self.uiBinder.btn_reset, function()
    self.fashionVM_.RevertAllFashionWear()
    self:OpenStyleView()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30040)
  end)
  self:AddAsyncClick(self.uiBinder.btn_custom, function()
    if not self.customFunc_ then
      return
    end
    self.customFunc_(self.customView_)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_ask, true)
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncCheckPersonalZone()
  end)()
end

function Fashion_systemView:showSubView(subView, viewData, isOpenStyle)
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self:refreshCustomBtn(false)
  self.isOpenStyle_ = isOpenStyle
  self.curSubView_ = subView
  self.curSubView_:Active(viewData, self.uiBinder.node_viewport)
end

function Fashion_systemView:OpenStyleView(isPreview)
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  if self.curFirstTab_ == E.EFashionFirstTab.EWeaponSkin then
    self:showSubView(self.weaponSkinStyleView_, {
      region = self.curRegion_,
      professionId = self.curProfessionId_
    }, true)
  else
    self:showSubView(self.styleView_, {
      region = self.curRegion_,
      isPreview = isPreview
    }, true)
  end
end

function Fashion_systemView:OpenDyeingView(fashionId, area)
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  self:showSubView(self.dyeingView_, {
    fashionId = fashionId,
    area = area,
    isPreview = false
  }, false)
end

function Fashion_systemView:OpenCustomizedView(fashionId)
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  self:showSubView(self.customizedView_, {
    fashionId = fashionId,
    region = self.curRegion_,
    parentView = self
  }, false)
end

function Fashion_systemView:refreshDpd()
  if not self.uiBinder.node_dpd_screen_narrow then
    return
  end
  if self.curFirstTab_ ~= E.EFashionFirstTab.EWeaponSkin then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_dpd_screen_narrow, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_dpd_screen_narrow, true)
  local options_ = {}
  local optionToProfessionId_ = {}
  local index = 1
  local professionData = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local dpdIndex = 1
  if not self.curProfessionId_ then
    self.curProfessionId_ = weaponVm.GetCurWeapon()
  end
  for _, value in pairs(professionData) do
    if weaponVm.CheckWeaponUnlock(value.Id) and value.IsOpen then
      if self.curProfessionId_ == value.Id then
        dpdIndex = index
        options_[index] = value.Name .. Lang("FilterCurrent")
      else
        options_[index] = value.Name
      end
      optionToProfessionId_[index] = value.Id
      index = index + 1
    end
  end
  self.uiBinder.dpd_screen_narrow:ClearAll()
  self.uiBinder.dpd_screen_narrow:AddListener(function(index)
    self.curProfessionId_ = optionToProfessionId_[index + 1]
    self:showSubView(self.weaponSkinStyleView_, {
      region = self.curRegion_,
      professionId = self.curProfessionId_
    })
  end, true)
  self.uiBinder.dpd_screen_narrow:AddOptions(options_)
  self.uiBinder.dpd_screen_narrow.value = dpdIndex - 1
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
  else
    fashionConfig = Z.Global.FashionShowActionF
  end
  for _, timelineInfo in ipairs(fashionConfig) do
    local region = timelineInfo[1]
    local timelineId = timelineInfo[2]
    self.timelineInfoList_[region] = timelineId
  end
  self.playerIdleId_ = Z.ConstValue.FaceGenderTimelineId[self.faceData_:GetPlayerGender()]
  if Z.StageMgr.GetIsInGameScene() then
    self.curRotation_ = 180
  else
    self.curRotation_ = Z.ConstValue.FaceGenderRotation[self.faceData_:GetPlayerGender()]
  end
  Z.UITimelineDisplay:AsyncPreLoadTimeline(self.playerIdleId_, self.cancelSource:CreateToken())
end

function Fashion_systemView:refreshCollectPoint()
  if not self.uiBinder.node_schedule then
    return
  end
  if self.switchVM_.CheckFuncSwitch(E.FunctionID.CollectionReward) then
    Z.CollectionScoreHelper.RefreshCollectionScore(self.uiBinder.node_schedule, function()
      if not self.uiBinder then
        return
      end
      self:onClickFashionCollectionScoreRewardRed()
    end)
    self.uiBinder.node_schedule.Ref.UIComp:SetVisible(true)
  else
    self.uiBinder.node_schedule.Ref.UIComp:SetVisible(false)
  end
end

function Fashion_systemView:refreshMemberCenter()
  if not self.uiBinder.btn_member_center then
    return
  end
  if not Z.StageMgr.GetIsInLogin() and self.switchVM_.CheckFuncSwitch(E.FunctionID.CollectionVipLevel) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_member_center, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_member_center, false)
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

function Fashion_systemView:initLoopTab()
  self.secondLoopListView_ = loopListView.new(self, self.uiBinder.loop_tab, second_Item, "fashion_item_tab", true)
  self.secondLoopListView_:Init({})
end

function Fashion_systemView:clearLoopTab()
  self.secondLoopListView_:UnInit()
end

function Fashion_systemView:clearTimeLine()
  self.timelineInfoList_ = nil
  if self.curTimelineId_ then
    self.curRotation_ = Z.ConstValue.FaceGenderRotation[self.faceData_:GetPlayerGender()]
    local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
    Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.curTimelineId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
  end
  self.curTimelineId_ = nil
  Z.UITimelineDisplay:ClearTimeLine()
end

function Fashion_systemView:initFirstTab()
  self.uiBinder.tog_clothes.tog_tab_select.group = self.uiBinder.toggle_group
  self.uiBinder.tog_ornament.tog_tab_select.group = self.uiBinder.toggle_group
  self.uiBinder.tog_weapon.tog_tab_select.group = self.uiBinder.toggle_group
  self.uiBinder.tog_clothes.tog_tab_select:AddListener(function(isOn)
    if not isOn then
      return
    end
    self.curFirstTab_ = E.EFashionFirstTab.EClothes
    self.curProfessionId_ = nil
    self:refreshSecondList()
    self:refreshSecondListSelect(self.curRegion_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tab, true)
    self:onClickClothesRed()
  end)
  self.uiBinder.tog_ornament.tog_tab_select:AddListener(function(isOn)
    if not isOn then
      return
    end
    self.curFirstTab_ = E.EFashionFirstTab.EOrnament
    self.curProfessionId_ = nil
    self:refreshSecondList()
    self:refreshSecondListSelect(self.curRegion_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tab, true)
    self:onClickOrnamentRed()
  end)
  self.uiBinder.tog_weapon.tog_tab_select:AddListener(function(isOn)
    if not isOn then
      return
    end
    self.curFirstTab_ = E.EFashionFirstTab.EWeaponSkin
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tab, false)
    self:OnSwitchRegion(E.FashionRegion.WeapoonSkin)
  end)
  self.curFirstTab_ = E.EFashionFirstTab.EClothes
  if self.viewData and self.viewData.firstTab then
    self.curFirstTab_ = self.viewData.firstTab
  end
  local curRegion
  if self.viewData and self.viewData.region then
    curRegion = self.viewData.region
  elseif self.curFirstTab_ == E.EFashionFirstTab.EClothes then
    curRegion = E.FashionRegion.Suit
  elseif self.curFirstTab_ == E.EFashionFirstTab.EOrnament then
    curRegion = E.FashionRegion.Headwear
  end
  if self.curFirstTab_ == E.EFashionFirstTab.EClothes then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tab, true)
    self.uiBinder.tog_clothes.tog_tab_select:SetIsOnWithoutCallBack(true)
    self:refreshSecondList()
    self:refreshSecondListSelect(curRegion)
  elseif self.curFirstTab_ == E.EFashionFirstTab.EOrnament then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tab, true)
    self.uiBinder.tog_ornament.tog_tab_select:SetIsOnWithoutCallBack(true)
    self:refreshSecondList()
    self:refreshSecondListSelect(curRegion)
  elseif self.curFirstTab_ == E.EFashionFirstTab.EWeaponSkin then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tab, false)
    self.uiBinder.tog_weapon.tog_tab_select:SetIsOnWithoutCallBack(true)
  end
  self.uiBinder.tog_weapon.Ref.UIComp:SetVisible(not Z.StageMgr.GetIsInLogin())
  self:OnSwitchRegion(curRegion)
end

function Fashion_systemView:refreshSecondListSelect(curRegion)
  local index = self:getRegionIndex(regionDataDict[self.curFirstTab_], curRegion)
  self.secondLoopListView_:ClearAllSelect()
  self.secondLoopListView_:SetSelected(index)
end

function Fashion_systemView:refreshSecondList()
  self.fashionVM_.RefreshFashionHideRegion()
  self.secondLoopListView_:RefreshListView(regionDataDict[self.curFirstTab_], false)
end

function Fashion_systemView:refreshCustomBtn(isShowCustom, customlab, func, isDisable, view)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_custom, isShowCustom)
  if isShowCustom then
    self.uiBinder.lab_custom.text = Lang(customlab)
    self.customFunc_ = func
    self.customView_ = view
    self.uiBinder.btn_custom.IsDisabled = isDisable
    self.uiBinder.btn_custom.interactable = not isDisable
  else
    self.customFunc_ = nil
    self.customView_ = nil
  end
end

function Fashion_systemView:GetBtnCustomRef()
  return self.uiBinder.node_custom_ref
end

function Fashion_systemView:getRegionIndex(list, region)
  local index = 1
  if region then
    for i = 1, #list do
      if list[i].region == region then
        index = i
        break
      end
    end
  end
  return index
end

function Fashion_systemView:clearFirstTab()
  self.uiBinder.tog_clothes.tog_tab_select:RemoveAllListeners()
  self.uiBinder.tog_ornament.tog_tab_select:RemoveAllListeners()
  self.uiBinder.tog_weapon.tog_tab_select:RemoveAllListeners()
  self.uiBinder.tog_clothes.tog_tab_select.group = nil
  self.uiBinder.tog_ornament.tog_tab_select.group = nil
  self.uiBinder.tog_weapon.tog_tab_select.group = nil
  self.uiBinder.tog_clothes.tog_tab_select.isOn = false
  self.uiBinder.tog_ornament.tog_tab_select.isOn = false
  self.uiBinder.tog_weapon.tog_tab_select.isOn = false
end

function Fashion_systemView:initPlayerAction()
  if not self.firstShowIdle_ then
    return
  end
  self:playModelIdleAction()
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.playerIdleId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
end

function Fashion_systemView:OnSwitchRegion(region)
  self.curRegion_ = region
  self:refreshDpd()
  self:OpenStyleView()
  self:refreshViewTitle()
  self:refreshModelAction()
  self:changeCameraFocus()
  self:refreshImgActionNarrow()
end

function Fashion_systemView:refreshImgActionNarrow()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_action, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_dpd_screen_narrow, self.curFirstTab_ == E.EFashionFirstTab.EWeaponSkin)
end

function Fashion_systemView:refreshViewTitle()
  local regionName = self.fashionVM_.GetRegionName(self.curRegion_)
  local commonVM = Z.VMMgr.GetVM("common")
  local funcName = commonVM.GetTitleByConfig(E.FunctionID.Fashion)
  local titleStr = funcName .. "/" .. regionName
  self.uiBinder.lab_title.text = titleStr
end

function Fashion_systemView:initFashionData()
  if self.viewData and self.viewData.gotoData and self.viewData.gotoData.FashionId then
    local region = self.fashionVM_.GetFashionRegion(self.viewData.gotoData.FashionId)
    self.fashionData_:SetWear(region, {
      fashionId = self.viewData.gotoData.FashionId
    })
    if region == E.FashionRegion.WeapoonSkin then
      local row = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(self.viewData.gotoData.FashionId, true)
      if row then
        self.curProfessionId_ = row.ProfessionId
      end
    end
  end
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
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
    model:SetLuaAttrLookAtEnable(true)
    if self.curFirstTab_ ~= E.EFashionFirstTab.EWeaponSkin then
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    end
  end, function(model)
    Z.UIMgr:FadeOut()
    local fashionVm = Z.VMMgr.GetVM("fashion")
    fashionVm.SetModelAutoLookatCamera(model)
  end)
end

function Fashion_systemView:ShowSaveBtn()
  self:refreshCustomBtn(true, "Save", self.onClickSaveAll, false, self)
end

function Fashion_systemView:refreshModelAction()
  if self.firstShowIdle_ then
    self.firstShowIdle_ = false
    return
  end
  local timelineId = self.timelineInfoList_[self.curRegion_]
  if not timelineId then
    return
  end
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
  if not self.playerModel_ then
    return
  end
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.playerIdleId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
  Z.UITimelineDisplay:BindModel(0, self.playerModel_)
  Z.UITimelineDisplay:Play(self.playerIdleId_)
  self.curTimelineId_ = self.playerIdleId_
end

function Fashion_systemView:changeCameraFocus()
  local isOnHead = false
  for i = 1, #regionDataDict[self.curFirstTab_] do
    if regionDataDict[self.curFirstTab_][i].region == self.curRegion_ then
      isOnHead = regionDataDict[self.curFirstTab_][i].IsFocus
      break
    end
  end
  if isOnHead then
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusHead", Vector3.New(0, self.offset_.x, 0))
  else
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusBody", Vector3.New(0, self.offset_.y, 0))
  end
end

function Fashion_systemView:OnInputBack()
  if self.isOpenStyle_ then
    local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
    if saveVM.IsFashionWearChange() then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("UnSaveFashionColor"), function()
        self.fashionVM_.CloseFashionSystemView()
      end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.UnSaveFashionColor)
    else
      self.fashionVM_.CloseFashionSystemView()
    end
  else
    self:OpenStyleView()
  end
end

function Fashion_systemView:onClickSaveAll()
  local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
  local dataList = saveVM.GetFashionConfirmDataList()
  if 0 < #dataList then
    saveVM.OpenSaveTipsView()
  elseif self.curFirstTab_ == E.EFashionFirstTab.EWeaponSkin then
    local weaponSkillSkinVm = Z.VMMgr.GetVM("weapon_skill_skin")
    local styleData = self.fashionData_:GetWear(self.curRegion_)
    if styleData == nil then
      return
    end
    weaponSkillSkinVm:AsyncUseProfessionSkin(self.curProfessionId_, styleData.fashionId, self.cancelSource:CreateToken())
  else
    self.fashionVM_.AsyncSaveAllFashion(self.cancelSource)
  end
end

function Fashion_systemView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
  Z.EventMgr:Add(Z.ConstValue.FashionSaveConfirmItemClick, self.onFashionSaveConfirmItemClick, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.ModelMatRaiseHeight, self.refreshCameraFocus, self)
  Z.EventMgr:Add(Z.ConstValue.Collection.FashionCollectionPointChange, self.refreshCollectPoint, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionOptionStateChange, self.refreshOptionBtnState, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionWearChange, self.refreshSecondList, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionSettingChange, self.refreshSecondList, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, self.refreshCustomBtn, self)
end

function Fashion_systemView:onInitRed()
  if self.uiBinder.node_schedule then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionCollectionScoreRewardRed, self, self.uiBinder.node_schedule.node_red)
  end
  if self.uiBinder.btn_member_center_trans then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionCollectionWindowRed, self, self.uiBinder.btn_member_center_trans)
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionClothes, self, self.uiBinder.tog_clothes.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionOrnament, self, self.uiBinder.tog_ornament.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionWeapon, self, self.uiBinder.tog_weapon.Trans)
end

function Fashion_systemView:onClickClothesRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FashionClothes)
end

function Fashion_systemView:onClickOrnamentRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FashionOrnament)
end

function Fashion_systemView:onClickFashionCollectionScoreRewardRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FashionCollectionScoreRewardRed)
end

function Fashion_systemView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionCollectionScoreRewardRed)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionCollectionWindowRed)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionClothes)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionOrnament)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionWeapon)
end

function Fashion_systemView:refreshCameraFocus(value, init)
  if not init then
    return
  end
  local EModelPinchHeight = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchHeight)
  local heightSliderValue = math.floor(EModelPinchHeight * 10 + 0.5)
  local scale = self.faceVM_.GetLookAtOffsetScale(E.ELookAtScaleType.BodyHeight)
  Z.UnrealSceneMgr:SetZoomAutoChangeLookAtByOffset(self.offset_.x + heightSliderValue / scale, self.offset_.y)
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

function Fashion_systemView:SetLuaIntModelAttr(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  self.playerModel_:SetLuaIntAttr(attrType, table.unpack(arg))
end

function Fashion_systemView:onFashionSaveConfirmItemClick(confirmData)
  local fashionId = confirmData.FashionId
  if confirmData.FashionIdList and #confirmData.FashionIdList > 0 then
    for i = 1, #confirmData.FashionIdList do
      local itemId = confirmData.FashionIdList[i]
      if self.fashionVM_.CheckIsFashion(itemId) then
        self.fashionVM_.SetFashionWearByFashionId(itemId)
      end
    end
  end
  if fashionId then
    self.curRegion_ = self.fashionVM_.GetFashionRegion(fashionId)
  elseif confirmData.Region then
    self.curRegion_ = confirmData.Region
  else
    self.curRegion_ = E.FashionRegion.Suit
  end
  if self:isListHaveRegion(regionDataDict[E.EFashionFirstTab.EClothes], self.curRegion_) then
    if self.uiBinder.tog_clothes.tog_tab_select.isOn then
      self:refreshSecondListSelect(self.curRegion_)
    else
      self.uiBinder.tog_clothes.tog_tab_select.isOn = true
    end
  elseif self:isListHaveRegion(regionDataDict[E.EFashionFirstTab.EOrnament], self.curRegion_) then
    if self.uiBinder.tog_ornament.tog_tab_select.isOn then
      self:refreshSecondListSelect(self.curRegion_)
    else
      self.uiBinder.tog_ornament.tog_tab_select.isOn = true
    end
  elseif self.curRegion_ == E.FashionRegion.WeapoonSkin then
    self.uiBinder.tog_weapon.tog_tab_select.isOn = true
  end
  local reason = confirmData.Reason
  if reason == E.FashionTipsReason.UnlockedColor and fashionId then
    self:OpenDyeingView(fashionId, confirmData.AreaList[1])
  end
end

function Fashion_systemView:isListHaveRegion(list, region)
  for i = 1, #list do
    if list[i].region == region then
      return true
    end
  end
  return false
end

function Fashion_systemView:refreshOptionBtnState()
  local optionCount = #self.fashionData_:GetOptionList()
  self.uiBinder.btn_move.IsDisabled = optionCount <= self.fashionData_.OptionIndex
  self.uiBinder.btn_return.IsDisabled = self.fashionData_.OptionIndex <= 0
end

function Fashion_systemView:startPlaySelectAnim()
end

function Fashion_systemView:startPlaySelect2Anim()
end

function Fashion_systemView:startTabPlaySelectAnim()
end

function Fashion_systemView:startAnimatedShow()
end

function Fashion_systemView:startAnimatedHide()
end

function Fashion_systemView:CustomClose()
end

return Fashion_systemView
