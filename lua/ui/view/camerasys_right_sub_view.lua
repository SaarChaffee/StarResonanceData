local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camerasys_right_subView = class("Camerasys_right_subView", super)
local togPath = "ui/atlas/photograph/camera_menu_"
local TogsHeight = 108

function Camerasys_right_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  self.containerHeight_ = nil
  super.ctor(self, "camerasys_right_sub", "photograph/camerasys_right_sub", UI.ECacheLv.None)
  self:initPublicVariable()
end

function Camerasys_right_subView:OnActive()
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
  if self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera then
    self:initCameraData()
    self:initCameraView()
  elseif self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Expression then
    self:initExpressionData()
    self:initExpressionView()
  end
end

function Camerasys_right_subView:initPublicVariable()
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVm_ = Z.VMMgr.GetVM("camerasys")
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.multActionData_ = Z.DataMgr.Get("multaction_data")
  self.menuContainerAll_ = nil
  self.menuContainerAction_ = require("ui/view/camera_menu_container_action_view").new(self)
  self.menuContainerFilter_ = require("ui/view/camera_menu_container_filter_view").new(self)
  self.menuContainerFrame_ = require("ui/view/camera_menu_container_frame_view").new(self)
  self.menuContainerShotset_ = require("ui/view/camera_menu_container_shotset_view").new(self)
  self.menuContainerScheme_ = require("ui/view/camera_menu_container_scheme_view").new(self)
  self.menuContainerShow_ = require("ui/view/camera_menu_container_show_view").new(self)
  self.menuContainerSticker_ = require("ui/view/camera_menu_container_sticker_view").new(self)
  self.menuContainerMovieScreen_ = require("ui/view/camera_menu_container_moviescreen_view").new(self)
  self.menuContainerText_ = require("ui/view/camera_menu_container_text_view").new(self)
  self.menuContainerHistory_ = require("ui/view/camera_menu_container_history_sub_view").new(self)
  self.menuContainerGaze_ = require("ui/view/camera_menu_container_gaze_view").new(self)
  self.menuContainerUnionBg_ = require("ui/view/camera_menu_container_union_bg_view").new(self)
end

function Camerasys_right_subView:OnCloseView()
  if self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera then
    if self.parent_ then
      self.parent_:setRightPanelVisible(true)
      self.parent_:setRightFuncShow(true)
    end
    self:Hide()
  else
    self:DeActive()
  end
end

function Camerasys_right_subView:OnDeActive()
  self.containerHeight_ = nil
  self.uiBinder.tog_action:RemoveAllListeners()
  self.uiBinder.tog_decorate:RemoveAllListeners()
  self.uiBinder.tog_setting:RemoveAllListeners()
  self:ClearAllUnits()
  self:deActiveAllSubView()
  self:removeRedPoint()
  self.menuContainerAction_:DeActive()
  self.cameraData_:InitTagIndex()
  self.expressionData_:SetDisplayExpressionType(E.ExpressionType.None)
  self.expressionData_:SetLogicExpressionType(E.ExpressionType.None)
  if self.cameraActionSlider_ and self.cameraActionSlider_.IsActive then
    self.cameraActionSlider_:DeActive()
  end
  if self.expressionItemTable then
    self.expressionItemTable = nil
  end
  if self.menuContainerHistory_ and self.menuContainerHistory_.IsActive then
    self.menuContainerHistory_:DeActive()
  end
  self.expressionVm_.CloseExpressionView()
end

function Camerasys_right_subView:removeRedPoint()
  if self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Expression or self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera then
    Z.RedPointMgr.RemoveNodeItem(E.RedType.ExpressionAction)
  end
end

function Camerasys_right_subView:OnRefresh()
  if not self.viewData then
    return
  end
  if self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera then
    self:updateCameraTopBtnIsOn()
    self:updateContent(true)
  end
end

function Camerasys_right_subView:initCameraView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_togs_group, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, self.cameraData_.CameraPatternType ~= E.CameraState.UnrealScene)
  self.uiBinder.layout_element_scroll.minHeight = self.containerHeight_ - TogsHeight
  self:initCameraBtn()
end

function Camerasys_right_subView:initCameraData()
  self.cameraActionSlider_ = require("ui/view/camera_action_slider_view").new(self)
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
end

function Camerasys_right_subView:initCameraBtn()
  self:updateCameraTopBtnIsOn()
  self.uiBinder.tog_action:AddListener(function(isOn)
    if isOn then
      self.cameraVm_.SetTopTagIndex(E.CamerasysTopType.Action)
      self:updateContent(true)
    end
  end)
  self.uiBinder.tog_decorate:AddListener(function(isOn)
    if isOn then
      self.cameraVm_.SetTopTagIndex(E.CamerasysTopType.Decorate)
      self:updateContent(true)
    end
  end)
  self.uiBinder.tog_setting:AddListener(function(isOn)
    if isOn then
      self.cameraVm_.SetTopTagIndex(E.CamerasysTopType.Setting)
      self:updateContent(true)
    end
  end)
  self.cameraActionSlider_:Active(self.viewData, self.uiBinder.node_action_slider_container)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider_container, false)
end

function Camerasys_right_subView:updateCameraTopBtnIsOn()
  local topTag = self.cameraData_:GetTagIndex()
  if topTag.TopTagIndex == E.CamerasysTopType.Action then
    self.uiBinder.tog_action.isOn = true
  elseif topTag.TopTagIndex == E.CamerasysTopType.Decorate then
    self.uiBinder.tog_decorate.isOn = true
  else
    self.uiBinder.tog_setting.isOn = true
  end
end

function Camerasys_right_subView:updateContent(refreshTagList)
  self:updateSettingView()
  if refreshTagList then
    self:updateTagList()
  end
end

function Camerasys_right_subView:updateSettingView()
  local topTag = self.cameraData_:GetTagIndex()
  self:deActiveAllSubView()
  local functionLogicIndex = self.cameraVm_.CameraFuncTogIndexToLogicIndex()
  if topTag.TopTagIndex == E.CamerasysTopType.Action then
    if functionLogicIndex == E.CamerasysFuncType.LookAt then
      self.menuContainerGaze_:Active(nil, self.uiBinder.node_scroll_container)
    else
      if (functionLogicIndex == E.CamerasysFuncType.CommonAction or functionLogicIndex == E.CamerasysFuncType.LoopAction) and (self.cameraData_.CameraPatternType == E.CameraState.Default or self.cameraData_.CameraPatternType == E.CameraState.UnrealScene) then
        self.expressionData_:SetLogicExpressionType(E.ExpressionType.Action)
        self.expressionData_:SetDisplayExpressionType(topTag.NodeTagIndex)
      else
        self.expressionData_:SetLogicExpressionType(E.ExpressionType.Emote)
        self.expressionData_:SetDisplayExpressionType(E.DisplayExpressionType.Emote)
      end
      if self.menuContainerAction_.IsActive then
        self.menuContainerAction_:Show()
      end
      self.menuContainerAction_:Active(self.viewData, self.uiBinder.node_scroll_container)
    end
  elseif topTag.TopTagIndex == E.CamerasysTopType.Decorate then
    if functionLogicIndex == E.CamerasysFuncType.Frame then
      self.menuContainerFrame_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.Sticker then
      self.menuContainerSticker_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.Text then
      self.menuContainerText_:Active(nil, self.uiBinder.node_scroll_container)
    end
  elseif topTag.TopTagIndex == E.CamerasysTopType.Setting then
    if functionLogicIndex == E.CamerasysFuncType.Moviescreen then
      self.menuContainerMovieScreen_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.Filter then
      self.menuContainerFilter_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.Shotset then
      self.menuContainerShotset_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.Show then
      self.menuContainerShow_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.Scheme then
      self.menuContainerScheme_:Active(nil, self.uiBinder.node_scroll_container)
    elseif functionLogicIndex == E.CamerasysFuncType.UnionBg then
      self.menuContainerUnionBg_:Active(nil, self.uiBinder.node_scroll_container)
    end
  end
end

function Camerasys_right_subView:updateTagList()
  local topTag = self.cameraData_:GetTagIndex()
  local tagList = self.cameraData_.funcTbDefault[topTag.TopTagIndex]
  if topTag.TopTagIndex == -1 then
    return
  end
  if self.cameraData_.CameraPatternType == E.CameraState.Default then
    tagList = self.cameraData_.funcTbDefault[topTag.TopTagIndex]
  elseif self.cameraData_.CameraPatternType == E.CameraState.SelfPhoto then
    tagList = self.cameraData_.funcTbSelfPhoto[topTag.TopTagIndex]
  elseif self.cameraData_.CameraPatternType == E.CameraState.AR then
    tagList = self.cameraData_.funcTbAR[topTag.TopTagIndex]
  elseif self.cameraData_.CameraPatternType == E.CameraState.UnrealScene then
    tagList = self.cameraData_.funcTbUnrealScene[topTag.TopTagIndex]
  end
  local funList = {}
  local indexList = {}
  local index = 0
  for _, v in pairs(tagList) do
    index = index + 1
    local funcId = self.cameraData_.funcIdList_[v]
    if funcId then
      if not self.cameraData_.IsOfficialPhotoTask or funcId ~= E.CamerasysFuncIdType.Scheme and funcId ~= E.CamerasysFuncIdType.Moviescreen then
        local isSwitch = self.switchVM_.CheckFuncSwitch(funcId)
        if isSwitch then
          funList[index] = v
          table.insert(indexList, index)
        end
      end
    else
      funList[index] = v
      table.insert(indexList, index)
    end
  end
  if self.initTagIndex_[topTag.TopTagIndex] then
    self.cameraData_:SetNodeTagIndex(indexList[1])
    self.initTagIndex_[topTag.TopTagIndex] = false
  end
  self:removeUnitTogs()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setTogsData(funList, indexList)
  end)()
end

function Camerasys_right_subView:removeUnitTogs()
  for _, value in ipairs(self.TogUnitsName_) do
    self:RemoveUiUnit(value)
  end
end

function Camerasys_right_subView:setTogsData(tagList, indexList)
  local count = #indexList
  if indexList and next(indexList) then
    local unitPath = self.uiBinder.prefabCache:GetString("tag_tpl")
    for k, v in ipairs(indexList) do
      local name = string.format("tag%s", k)
      table.insert(self.TogUnitsName_, name)
      local item = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.node_tog)
      local togId = tagList[v]
      local path = string.format("%s%s", togPath, togId)
      item.img_icon_ash.Img:SetImage(path)
      item.img_icon.Img:SetImage(path)
      item.group_no_active:SetVisible(not item.tog_function.Tog.isOn)
      item.group_active:SetVisible(item.tog_function.Tog.isOn)
      item.tog_function.Tog.group = self.uiBinder.node_toggle
      local tagIndex = self.cameraData_:GetTagIndex().NodeTagIndex
      if tagIndex == v then
        item.tog_function.Tog.isOn = true
      end
      item.tog_function.Tog:AddListener(function(isOn)
        if isOn then
          self.cameraVm_.SetNodeTagIndex(v)
        end
        item.group_no_active:SetVisible(not item.tog_function.Tog.isOn)
        item.group_active:SetVisible(item.tog_function.Tog.isOn)
      end)
      if item.tog_function.Tog.isOn then
        item.group_active.TweenContainer:Restart(Z.DOTweenAnimType.Tween_1)
      end
    end
  end
  self.uiBinder.layout_tog:ForceRebuildLayoutImmediate()
end

function Camerasys_right_subView:deActiveAllSubView()
  if self.menuContainerAll_ then
    for _, v in pairs(self.menuContainerAll_) do
      v:DeActive()
    end
    if self.cameraActionSlider_ then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider_container, false)
      self.menuContainerAction_:Hide()
    end
  end
end

function Camerasys_right_subView:initExpressionView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_togs_group, false)
  self.uiBinder.layout_element_scroll.minHeight = self.containerHeight_
  self:initTog()
end

function Camerasys_right_subView:initExpressionData()
  self.expressionItemTable = nil
end

function Camerasys_right_subView:initTog()
  local togData = self.expressionData_:GetTabTableData()
  if not togData or not next(togData) then
    return
  end
  local imagePathPre = self.uiBinder.prefabCache:GetString("expressionTogPath")
  local unitPath = self.uiBinder.prefabCache:GetString("tag_tpl")
  local count = #togData
  self.expressionItemTable = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in pairs(togData) do
      local imagePath = string.format("%s%s", imagePathPre, v.icon)
      local name = string.format("expression_tog_%s", k)
      local item = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.node_tog, self.cancelSource:CreateToken())
      if item then
        Z.GuideMgr:SetSteerId(item.camera_setting_tag_tpl, E.DynamicSteerType.ExpressionTab, v.type)
      end
      table.insert(self.expressionItemTable, item)
      self:setItemTog(item, imagePath, count, k, v)
    end
    self.expressionData_:SetLogicExpressionType(E.ExpressionType.Action)
    local index = self.expressionVm_.CheckExpressionHistoryAndCommonData() and 1 or 2
    self.expressionItemTable[index].tog_function.Tog.isOn = true
  end)()
end

function Camerasys_right_subView:setItemTog(item, imagePath, count, currentIdx, togData)
  item.img_icon_ash.Img:SetImage(imagePath)
  item.img_icon.Img:SetImage(imagePath)
  item.tog_function.Tog.group = self.uiBinder.node_toggle
  if togData.type == E.DisplayExpressionType.CommonAction or togData.type == E.DisplayExpressionType.LoopAction then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.ExpressionMain .. E.ItemType.ActionExpression .. togData.type, self, item.Trans)
  end
  item.tog_function.Tog:AddListener(function(isOn)
    if isOn then
      item.group_active.TweenContainer:Restart(Z.DOTweenAnimType.Tween_1)
      self.expressionVm_.SetTabSelected(currentIdx)
      self.expressionData_:SetLogicExpressionType(self.expressionVm_.DisplayTypeToLogicType(currentIdx - 1))
      self.expressionData_:SetDisplayExpressionType(currentIdx - 1)
      if currentIdx == 1 then
        self.menuContainerAction_:DeActive()
        self.menuContainerHistory_:Active(self.viewData, self.uiBinder.node_scroll_container)
      else
        self.menuContainerHistory_:DeActive()
        self.menuContainerAction_:Active(self.viewData, self.uiBinder.node_scroll_container)
      end
    end
  end)
end

function Camerasys_right_subView:initAlbumSecondEditData()
  self.menuContainerAll_ = {
    self.menuContainerFrame_,
    self.menuContainerSticker_,
    self.menuContainerText_,
    self.menuContainerFilter_,
    self.menuContainerMovieScreen_
  }
  self.TogUnitsName_ = {}
end

function Camerasys_right_subView:initAlbumSecondEditView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_togs_group, false)
  self:updateSecondEditTagList()
  local pressIndex = self.cameraData_:GetSecondEditPressIndexByCamerasysFuncType()
  self:updateSecondSettingView(pressIndex)
end

function Camerasys_right_subView:updateSecondEditTagList()
  local tagList = self.cameraData_.funcTbSecondEdit
  local funList = {}
  local indexList = {}
  local index = 0
  for _, v in pairs(tagList) do
    index = index + 1
    local funcId = self.cameraData_.funcIdList_[v]
    if funcId then
      if not self.cameraData_.IsOfficialPhotoTask or funcId ~= E.CamerasysFuncIdType.Scheme and funcId ~= E.CamerasysFuncIdType.Moviescreen then
        local isSwitch = self.switchVM_.CheckFuncSwitch(funcId)
        if isSwitch then
          funList[index] = v
          table.insert(indexList, index)
        end
      end
    else
      funList[index] = v
      table.insert(indexList, index)
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:setTogsData(funList, indexList)
  end)()
end

function Camerasys_right_subView:updateSecondSettingView(index)
  self:deActiveAllSubView()
  if not index then
    return
  end
  local data = {}
  data.isToEditing = true
  for k, v in pairs(self.menuContainerAll_) do
    if k == index then
      v:Active(data, self.uiBinder.node_scroll_container)
    end
  end
end

return Camerasys_right_subView
