local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_right_mobile_subView = class("Camera_right_mobile_subView", super)
local togPath = "ui/atlas/photograph/camera_menu_"
local TogsHeight = 108

function Camera_right_mobile_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  self.containerHeight_ = nil
  super.ctor(self, "camerasys_right_sub_mobile", "photograph/camerasys_right_sub", UI.ECacheLv.None)
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.cameraSystemFunctionType_ = E.CameraSystemFunctionType.Action
  self.cameraSystemSecondaryFunctionType_ = E.CameraSystemSubFunctionType.None
  self:initPublicVariable()
end

function Camera_right_mobile_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:AddClick(self.uiBinder.btn_return, function()
    self:OnCloseView()
  end)
  if not self.containerHeight_ then
    local lineWidth_ = 0
    self.containerHeight_ = 0
    lineWidth_, self.containerHeight_ = self.uiBinder.node_container:GetSize(lineWidth_, self.containerHeight_)
  end
  self:initCameraData()
  self:initCameraView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wheel_setting, false)
  self.uiBinder.img_tog_bg_ref:SetOffsetMin(15, 15)
  self:bindEvents()
end

function Camera_right_mobile_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.onMemberChanged, self)
end

function Camera_right_mobile_subView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.onMemberChanged, self)
end

function Camera_right_mobile_subView:initPublicVariable()
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVm_ = Z.VMMgr.GetVM("camerasys")
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.menuContainerAll_ = nil
  self.curActiveSubView_ = nil
  self.cameraFunctionUnit_ = {}
  self.menuContainerAction_ = require("ui/view/camera_menu_container_action_view").new(self)
  self.menuContainerFilter_ = require("ui/view/camera_menu_container_filter_view").new(self)
  self.menuContainerFrame_ = require("ui/view/camera_menu_container_frame_view").new(self)
  self.menuContainerShotset_ = require("ui/view/camera_menu_container_shotset_view").new(self)
  self.menuContainerScheme_ = require("ui/view/camera_menu_container_scheme_view").new(self)
  self.menuContainerShow_ = require("ui/view/camera_menu_container_show_view").new(self)
  self.menuContainerSticker_ = require("ui/view/camera_menu_container_sticker_view").new(self)
  self.menuContainerMovieScreen_ = require("ui/view/camera_menu_container_moviescreen_view").new(self)
  self.menuContainerText_ = require("ui/view/camera_menu_container_text_view").new(self)
  self.menuContainerGaze_ = require("ui/view/camera_menu_container_gaze_view").new(self)
  self.menuContainerUnionBg_ = require("ui/view/camera_menu_container_union_bg_view").new(self)
  self.menuContainerFishing_ = require("ui/view/camera_menu_container_fishing_sub_view").new(self)
  self.subFuncViewList_ = {
    [E.CameraSystemSubFunctionType.CommonAction] = self.menuContainerAction_,
    [E.CameraSystemSubFunctionType.LoopAction] = self.menuContainerAction_,
    [E.CameraSystemSubFunctionType.Emote] = self.menuContainerAction_,
    [E.CameraSystemSubFunctionType.LookAt] = self.menuContainerGaze_,
    [E.CameraSystemSubFunctionType.Frame] = self.menuContainerFrame_,
    [E.CameraSystemSubFunctionType.Sticker] = self.menuContainerSticker_,
    [E.CameraSystemSubFunctionType.Text] = self.menuContainerText_,
    [E.CameraSystemSubFunctionType.Camera] = self.menuContainerShotset_,
    [E.CameraSystemSubFunctionType.ShotSet] = self.menuContainerMovieScreen_,
    [E.CameraSystemSubFunctionType.Filter] = self.menuContainerFilter_,
    [E.CameraSystemSubFunctionType.Show] = self.menuContainerShow_,
    [E.CameraSystemSubFunctionType.Scheme] = self.menuContainerScheme_,
    [E.CameraSystemSubFunctionType.UnionBg] = self.menuContainerUnionBg_,
    [E.CameraSystemSubFunctionType.Fishing] = self.menuContainerFishing_
  }
end

function Camera_right_mobile_subView:OnCloseView()
  self:Hide()
  if self.parent_ then
    self.parent_:setRightPanelVisible(true)
    self.parent_:setRightFuncShow(true)
  end
end

function Camera_right_mobile_subView:OnDeActive()
  for k, v in pairs(self.subFuncViewList_) do
    if v.IsActive then
      v:DeActive()
    end
  end
  self.cameraSystemSecondaryFunctionType_ = E.CameraSystemSubFunctionType.None
  self:unBindEvents()
  self.containerHeight_ = nil
  self.uiBinder.tog_action:RemoveAllListeners()
  self.uiBinder.tog_decorate:RemoveAllListeners()
  self.uiBinder.tog_setting:RemoveAllListeners()
  self:ClearAllUnits()
  self.menuContainerAction_:DeActive()
  self.cameraData_:InitTagIndex()
  self.expressionData_:SetDisplayExpressionType(E.ExpressionType.None)
  self.expressionData_:SetLogicExpressionType(E.ExpressionType.None)
  self.expressionVm_.CloseExpressionView()
end

function Camera_right_mobile_subView:OnRefresh()
  if not self.viewData then
    return
  end
  self:refreshTopFunctionBtn()
  self:updateCameraTopBtnIsOn()
end

function Camera_right_mobile_subView:initCameraView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_togs_group, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto)
  self.uiBinder.layout_element_scroll.minHeight = self.containerHeight_ - TogsHeight
  self:initCameraBtn()
end

function Camera_right_mobile_subView:initCameraData()
  self.menuContainerAll_ = {
    self.menuContainerFilter_,
    self.menuContainerFrame_,
    self.menuContainerShotset_,
    self.menuContainerScheme_,
    self.menuContainerShow_,
    self.menuContainerSticker_,
    self.menuContainerMovieScreen_,
    self.menuContainerText_,
    self.menuContainerGaze_,
    self.menuContainerUnionBg_
  }
  self.funcTb_ = {}
  self.TogUnitsName_ = {}
  self.initTagIndex_ = {
    true,
    true,
    true
  }
  self.expressionData_.OpenSourceType = E.ExpressionOpenSourceType.Camera
end

function Camera_right_mobile_subView:initCameraBtn()
  self.uiBinder.tog_action:AddListener(function(isOn)
    if isOn then
      self.cameraData_:SetSettingViewSecondaryLogicIndex(-1)
      self:loadRightFunctionBtn(E.CameraSystemFunctionType.Action)
    end
  end)
  self.uiBinder.tog_decorate:AddListener(function(isOn)
    if isOn then
      self.cameraData_:SetSettingViewSecondaryLogicIndex(-1)
      self:loadRightFunctionBtn(E.CameraSystemFunctionType.Decorations)
    end
  end)
  self.uiBinder.tog_setting:AddListener(function(isOn)
    if isOn then
      self.cameraData_:SetSettingViewSecondaryLogicIndex(-1)
      self:loadRightFunctionBtn(E.CameraSystemFunctionType.Setting)
    end
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider_container, false)
end

function Camera_right_mobile_subView:updateCameraTopBtnIsOn()
  local topTag = self.cameraData_:GetTagIndex()
  if topTag.TopTagIndex == E.CamerasysTopType.Action then
    self:loadRightFunctionBtn(E.CameraSystemFunctionType.Action)
    self.uiBinder.tog_action:SetIsOnWithoutCallBack(true)
    self.uiBinder.tog_decorate:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_setting:SetIsOnWithoutCallBack(false)
  elseif topTag.TopTagIndex == E.CamerasysTopType.Decorate then
    self:loadRightFunctionBtn(E.CameraSystemFunctionType.Decorations)
    self.uiBinder.tog_action:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_decorate:SetIsOnWithoutCallBack(true)
    self.uiBinder.tog_setting:SetIsOnWithoutCallBack(false)
  else
    self:loadRightFunctionBtn(E.CameraSystemFunctionType.Setting)
    self.uiBinder.tog_action:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_decorate:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_setting:SetIsOnWithoutCallBack(true)
  end
end

function Camera_right_mobile_subView:onMemberChanged(isSelf)
  self.cameraData_:SetNodeTagIndex(1)
  self:updateContent()
end

function Camera_right_mobile_subView:updateContent()
  self:loadRightFunctionBtn(self.cameraSystemFunctionType_)
end

function Camera_right_mobile_subView:refreshTopFunctionBtn()
  self.uiBinder.tog_action.interactable = self.cameraVm_.CheckMobileUiShowState(E.CameraSystemFunctionType.Action)
  self.uiBinder.tog_decorate.interactable = self.cameraVm_.CheckMobileUiShowState(E.CameraSystemFunctionType.Decorations)
  self.uiBinder.tog_setting.interactable = self.cameraVm_.CheckMobileUiShowState(E.CameraSystemFunctionType.Setting)
end

function Camera_right_mobile_subView:loadRightFunctionBtn(cameraFunctionType)
  Z.CoroUtil.create_coro_xpcall(function()
    self:removeUnitTogs()
    self.cameraSystemFunctionType_ = cameraFunctionType
    local tabData = self.cameraVm_.GetMobileFunctionData(cameraFunctionType)
    if not tabData or table.zcount(tabData) == 0 then
      return
    end
    local path = self.uiBinder.prefabCache:GetString("tag_tpl")
    if string.zisEmpty(path) then
      return
    end
    for k, v in ipairs(tabData) do
      local name = "tag_tpl_" .. k
      local togTabTplBinder = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_tog, self.cancelSource:CreateToken())
      self:initTabTog(togTabTplBinder, v)
      table.insert(self.cameraFunctionUnit_, {
        name = name,
        item = togTabTplBinder,
        data = v
      })
    end
    local logicIndex = self.cameraData_:GetSettingViewSecondaryLogicIndex()
    if logicIndex == -1 then
      self.cameraFunctionUnit_[1].item.tog_function:SetIsOnWithoutCallBack(true)
      self:initSettingSubView(self.cameraFunctionUnit_[1].data.Id)
    else
      for k, v in pairs(self.cameraFunctionUnit_) do
        if v.data.Id == logicIndex then
          v.item.tog_function:SetIsOnWithoutCallBack(true)
          break
        end
      end
      self:initSettingSubView(logicIndex)
    end
  end)()
end

function Camera_right_mobile_subView:initTabTog(item, data)
  if not item or not data then
    return
  end
  item.tog_function.group = self.uiBinder.node_toggle
  item.img_icon:SetImage(data.Icon)
  item.img_icon_ash:SetImage(data.Icon)
  item.tog_function:SetIsOnWithoutCallBack(false)
  item.tog_function:RemoveAllListeners()
  item.tog_function:AddListener(function(isOn)
    if isOn then
      self:initSettingSubView(data.Id)
    end
  end)
end

function Camera_right_mobile_subView:initSettingSubView(subFuncType)
  if self.subFuncViewList_[subFuncType] then
    if self.curActiveSubView_ then
      if self.curActiveSubView_ == self.menuContainerAction_ then
        self.curActiveSubView_:Hide()
      else
        self.curActiveSubView_:DeActive()
      end
    end
    self.cameraSystemSecondaryFunctionType_ = subFuncType
    self.cameraData_:SetSettingViewSecondaryLogicIndex(subFuncType)
    self.cameraVm_.SetCameraActionDisplayExpressionType(subFuncType)
    if self.subFuncViewList_[subFuncType] == self.menuContainerAction_ then
      self.menuContainerAction_:Show()
    end
    self.subFuncViewList_[subFuncType]:Active(self.viewData, self.uiBinder.node_scroll_container)
    self.curActiveSubView_ = self.subFuncViewList_[subFuncType]
  end
end

function Camera_right_mobile_subView:removeUnitTogs()
  if self.cameraFunctionUnit_ then
    for k, v in pairs(self.cameraFunctionUnit_) do
      self:RemoveUiUnit(v.name)
    end
    self.cameraFunctionUnit_ = {}
  end
end

function Camera_right_mobile_subView:SetActionSliderIsShow(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider_container, isShow)
end

return Camera_right_mobile_subView
