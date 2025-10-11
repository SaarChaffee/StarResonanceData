local UI = Z.UI
local super = require("ui.ui_view_base")
local Home_editor_mainView = class("Home_editor_mainView", super)
local rightSubView = require("ui.view.home_editor_right_sub_view")
local operationSubView = require("ui.view.home_editor_operation_sub_view")
E.EHomeRightSubType = {
  Warehouse = 1,
  Furniture = 2,
  Setting = 3,
  Light = 4
}

function Home_editor_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "home_editor_main")
  self.vm_ = Z.VMMgr.GetVM("home_editor")
  self.data_ = Z.DataMgr.Get("home_editor_data")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.rightSubView_ = rightSubView.new(self)
  self.operationSubView_ = operationSubView.new(self)
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.joystickView_ = require("ui/view/zjoystick_view").new()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
end

function Home_editor_mainView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_reture
  self.titleLab_ = self.uiBinder.lab_title
  self.numLab_ = self.uiBinder.lab_num
  self.rightBtnsNode_ = self.uiBinder.node_top_right_btn
  self.setBtn_ = self.uiBinder.btn_setting
  self.warehouseBtn_ = self.uiBinder.btn_warehouse
  self.furnitureBtn_ = self.uiBinder.btn_furniture
  self.lightBtn_ = self.uiBinder.btn_light
  self.adsorbTog_ = self.uiBinder.tog_adsorb
  self.griddingbTog_ = self.uiBinder.tog_gridding
  self.alignTog_ = self.uiBinder.tog_aligning
  self.multiSelectedTog_ = self.uiBinder.tog_multiple_choice
  self.anim_do_ = self.uiBinder.anim_do
  self.opearCameraNode_ = self.uiBinder.node_down_left_btn
  self.upCameraBtn_ = self.uiBinder.btn_up
  self.downCameraBtn_ = self.uiBinder.btn_down
  self.rightSubNode_ = self.uiBinder.node_right_sub
  self.operationSubNode_ = self.uiBinder.node_operation_sub
  self.joystickNode_ = self.uiBinder.node_joystick
  self.eventNode_ = self.uiBinder.event
  self.frameImg_ = self.uiBinder.img_frame
  self.frameTog_ = self.uiBinder.tog_frame_select
  self.frameNode_ = self.uiBinder.node_frame
end

function Home_editor_mainView:initBtn()
  local beginPos_, endPos_
  self.eventNode_.onDrag:AddListener(function(go, pointerData)
    local dis = pointerData.position - beginPos_
    local pivotx = dis.x > 0 and 0 or 1
    local pivoty = 0 < dis.y and 0 or 1
    self.frameImg_.transform:SetPivot(pivotx, pivoty)
    local x = math.abs(dis.x)
    local y = math.abs(dis.y)
    self.frameImg_.transform:SetWidthAndHeight(x, y)
  end)
  self.eventNode_.onDown:AddListener(function(go, pointerData)
    beginPos_ = pointerData.position
    self.frameImg_.transform:SetWidthAndHeight(0, 0)
    local pos = Z.UIRoot.UICam:ScreenToWorldPoint(Vector3.New(beginPos_.x, beginPos_.y, 0))
    self.frameImg_.position = pos
  end)
  self.eventNode_.onUp:AddListener(function(go, pointerData)
    self.frameTog_.isOn = false
    endPos_ = pointerData.position
    Z.DIServiceMgr.HomeService:TrySelectByStartEnd(beginPos_, endPos_)
  end)
  self:AddClick(self.closeBtn_, function()
    if Z.DIServiceMgr.HomeService:IsSelectEntityNeedSave() then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("HomeSwicthSelected"), function()
        self.vm_.CloseHomeMain()
      end)
    else
      self.vm_.CloseHomeMain()
    end
  end)
  self:AddClick(self.setBtn_, function()
    self:OnActiveRigtSubView(E.EHomeRightSubType.Setting)
  end)
  self:AddClick(self.warehouseBtn_, function()
    self:OnActiveRigtSubView(E.EHomeRightSubType.Warehouse)
  end)
  self:AddClick(self.furnitureBtn_, function()
    self:OnActiveRigtSubView(E.EHomeRightSubType.Furniture)
  end)
  self:AddClick(self.lightBtn_, function()
    self:OnActiveRigtSubView(E.EHomeRightSubType.Light)
  end)
  self:AddClick(self.adsorbTog_, function(isOn)
    if not self.isInit_ then
      return
    end
    if isOn then
      Z.TipsVM.ShowTips(1044007)
    else
      Z.TipsVM.ShowTips(1044008)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshAbsorbSwitchState, isOn)
  end)
  self:AddAsyncClick(self.griddingbTog_, function(isOn)
    if isOn then
      self:loadGrid()
    else
      self:removeGrid()
    end
  end)
  self:AddClick(self.alignTog_, function(isOn)
    if not self.isInit_ then
      return
    end
    if isOn then
      Z.TipsVM.ShowTips(1044005)
    else
      Z.TipsVM.ShowTips(1044006)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshAlignSwitchState, isOn)
  end)
  self:AddClick(self.multiSelectedTog_, function(isOn)
    self.uiBinder.Ref:SetVisible(self.frameNode_, isOn)
    if not self.isInit_ then
      return
    end
    if isOn then
      Z.TipsVM.ShowTips(1044009)
    else
      Z.TipsVM.ShowTips(1044010)
    end
    self.data_.IsMultiSelected = isOn
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshSelectedSwitchState, isOn)
  end)
  self:AddClick(self.frameTog_, function(isOn)
    self.frameImg_.transform:SetWidthAndHeight(0, 0)
    self.uiBinder.Ref:SetVisible(self.eventNode_, isOn)
    self.uiBinder.Ref:SetVisible(self.frameImg_, isOn)
  end)
  self:EventAddAsyncListener(self.upCameraBtn_.OnPointDownEvent, function()
    Z.LuaBridge.UpdatePlayerCameraSpeed(Z.PGame.EContextMember.CameraYDelta, 0.1)
  end)
  self:EventAddAsyncListener(self.downCameraBtn_.OnPointDownEvent, function()
    Z.LuaBridge.UpdatePlayerCameraSpeed(Z.PGame.EContextMember.CameraYDelta, -0.1)
  end)
  self:EventAddAsyncListener(self.upCameraBtn_.OnPointUpEvent, function()
    Z.LuaBridge.UpdatePlayerCameraSpeed(Z.PGame.EContextMember.CameraYDelta, 0)
  end)
  self:EventAddAsyncListener(self.downCameraBtn_.OnPointUpEvent, function()
    Z.LuaBridge.UpdatePlayerCameraSpeed(Z.PGame.EContextMember.CameraYDelta, 0)
  end)
end

function Home_editor_mainView:OnActive()
  self.isInit_ = false
  self.vm_.InitAlignNum()
  self:bindEvent()
  self:initBinders()
  self:onStartAnimShow()
  self:initBtn()
  self.data_:InitTab()
  self.data_:InitCopyTab()
  self.data_:ResetHomeItemMap()
  self.data_.IsMultiSelected = false
  self.multiSelectedTog_.isOn = false
  self.frameTog_.isOn = false
  self.alignTog_.isOn = self.vm_.GetAlignState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_aligning_select, self.vm_.GetAlignState())
  self.adsorbTog_.isOn = self.vm_.GetAbsorbState()
  self.uiBinder.Ref:SetVisible(self.frameNode_, false)
  self.chatMainData_:SetBlockChat(E.BlockChatType.HomeEditor, true)
  self.chatMainVm_.CloseMainChatView()
  self.uiBinder.Ref:SetVisible(self.eventNode_, false)
  self.uiBinder.Ref:SetVisible(self.frameImg_, false)
  if not Z.IsPCUI then
    self.joystickView_:Active(nil, self.joystickNode_.transform)
  end
  self.opearCameraNode_:SetAnchorPosition(-100, 100)
  self.homeLandId_ = self.data_:GetHomeLandId()
  self.griddingbTog_.isOn = true
  Z.CoroUtil.create_coro_xpcall(function()
    self.vm_.AsyncGetStructureGroupInfo()
    self:loadGrid()
  end)()
  self.isInit_ = true
end

function Home_editor_mainView:OnActiveRigtSubView(type)
  if self.data_.IsOperationState then
    return
  end
  self.anim_do_:Restart(Z.DOTweenAnimType.Tween_1)
  self.uiBinder.Ref:SetVisible(self.rightBtnsNode_, false)
  self.rightSubView_:Active(type, self.rightSubNode_)
  self.opearCameraNode_:SetAnchorPosition(-650, 100)
end

function Home_editor_mainView:OnDeActiveRigtSubView()
  self.rightSubView_:DeActive()
  self.uiBinder.Ref:SetVisible(self.rightBtnsNode_, true)
  self.opearCameraNode_:SetAnchorPosition(-100, 100)
end

function Home_editor_mainView:OnDeActive()
  self:OnDeActiveRigtSubView()
  self.operationSubView_:DeActive()
  self:removeGrid()
  self.joystickView_:DeActive()
  self:exitOperationState()
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  self.chatMainData_:SetBlockChat(E.BlockChatType.HomeEditor, false)
  self.chatMainVm_.OpenMainChatView()
  Z.CoroUtil.create_coro_xpcall(function()
    self.vm_.AsyncExitEditState()
  end)()
end

function Home_editor_mainView:OnRefresh()
end

function Home_editor_mainView:refreshAlignSwitchState(state)
  self.vm_.SetAlignState(state)
  self.alignTog_.isOn = state
end

function Home_editor_mainView:refreshAbsorbSwitchState(state)
  self.vm_.SetAbsorbState(state)
  self.adsorbTog_.isOn = state
end

function Home_editor_mainView:onSelected(entityId, configId)
  if Z.DIServiceMgr.HomeService:IsSelectEntityNeedSave() then
    return
  end
  self.data_.IsOperationState = true
  if self.data_.IsMultiSelected then
    local groupId = self.data_.FurnitureGroupInfoDic[entityId]
    if groupId then
      if table.zcontains(self.data_.CurMultiSelectedGroupIds, groupId) then
        table.zremoveOneByValue(self.data_.CurMultiSelectedGroupIds, groupId)
      else
        table.insert(self.data_.CurMultiSelectedGroupIds, groupId)
      end
    elseif table.zcontains(self.data_.CurMultiSelectedEntIds, entityId) then
      table.zremoveOneByValue(self.data_.CurMultiSelectedEntIds, entityId)
    else
      table.insert(self.data_.CurMultiSelectedEntIds, entityId)
    end
    if #self.data_.CurMultiSelectedGroupIds == 0 and #self.data_.CurMultiSelectedEntIds == 0 then
      self:exitOperationState()
    else
      self.selectedEntityIds_ = {}
      for index, groupId in ipairs(self.data_.CurMultiSelectedGroupIds) do
        local data = self.data_.FurnitureGroupInfo[groupId]
        if data then
          self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, data.structureIds)
        end
      end
      self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, self.data_.CurMultiSelectedEntIds)
      self:enterOperationState(self.selectedEntityIds_, configId)
    end
  else
    local fun = function()
      if entityId then
        local groupId = self.data_.FurnitureGroupInfoDic[entityId]
        if groupId then
          local data = self.data_.FurnitureGroupInfo[groupId]
          if data then
            self.selectedEntityIds_ = data.structureIds
          end
        else
          self.selectedEntityIds_ = {entityId}
        end
        self.selectEntityId_ = entityId
        self:enterOperationState(self.selectedEntityIds_, configId)
      end
    end
    local groupId = self.data_.FurnitureGroupInfoDic[entityId]
    if self.data_.IsGroupEditorState then
      if groupId and groupId == self.data_.CurEditorGroupId and self.data_.CurEditorGroupEntityId ~= entityId then
        self.data_.CurEditorGroupEntityId = entityId
        self:enterOperationState({entityId}, configId)
      elseif self.data_.CurEditorGroupEntityId ~= entityId then
        self.data_.IsGroupEditorState = false
        fun()
      end
    elseif groupId then
      if not self.selectEntityId_ or groupId ~= self.data_.FurnitureGroupInfoDic[self.selectEntityId_] then
        fun()
      end
    elseif self.selectEntityId_ == nil then
      fun()
    elseif self.selectEntityId_ ~= entityId then
      fun()
    end
  end
end

function Home_editor_mainView:selectedEntitys(entityIds)
  for index, entityId in ipairs(entityIds) do
    local groupId = self.data_.FurnitureGroupInfoDic[entityId]
    if groupId then
      if not table.zcontains(self.data_.CurMultiSelectedGroupIds, groupId) then
        table.insert(self.data_.CurMultiSelectedGroupIds, groupId)
      end
    elseif not table.zcontains(self.data_.CurMultiSelectedEntIds, entityId) then
      table.insert(self.data_.CurMultiSelectedEntIds, entityId)
    end
    if #self.data_.CurMultiSelectedGroupIds == 0 and #self.data_.CurMultiSelectedEntIds == 0 then
      self:exitOperationState()
    else
      self.selectedEntityIds_ = {}
      for index, groupId in ipairs(self.data_.CurMultiSelectedGroupIds) do
        local data = self.data_.FurnitureGroupInfo[groupId]
        if data then
          self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, data.structureIds)
        end
      end
      self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, self.data_.CurMultiSelectedEntIds)
    end
  end
  self:enterOperationState(self.selectedEntityIds_, nil)
end

function Home_editor_mainView:cancelSelectedItem(data)
  if data.IsGroup then
    if table.zcontains(self.data_.CurMultiSelectedGroupIds, data.GroupId) then
      table.zremoveOneByValue(self.data_.CurMultiSelectedGroupIds, data.GroupId)
    end
  elseif table.zcontains(self.data_.CurMultiSelectedEntIds, data.EntityUid) then
    table.zremoveOneByValue(self.data_.CurMultiSelectedEntIds, data.EntityUid)
  end
  if #self.data_.CurMultiSelectedGroupIds == 0 and #self.data_.CurMultiSelectedEntIds == 0 then
    self:exitOperationState()
  else
    self.selectedEntityIds_ = {}
    for index, groupId in ipairs(self.data_.CurMultiSelectedGroupIds) do
      local data = self.data_.FurnitureGroupInfo[groupId]
      if data then
        self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, data.structureIds)
      end
    end
    self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, self.data_.CurMultiSelectedEntIds)
    self:enterOperationState(self.selectedEntityIds_)
  end
end

function Home_editor_mainView:cancelSelectedUids(ids)
  for index, id in ipairs(ids) do
    if table.zcontains(self.data_.CurMultiSelectedEntIds, id) then
      table.zremoveOneByValue(self.data_.CurMultiSelectedEntIds, id)
    end
  end
  if #self.data_.CurMultiSelectedGroupIds == 0 and #self.data_.CurMultiSelectedEntIds == 0 then
    self:exitOperationState()
  else
    self.selectedEntityIds_ = {}
    for index, groupId in ipairs(self.data_.CurMultiSelectedGroupIds) do
      local data = self.data_.FurnitureGroupInfo[groupId]
      if data then
        self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, data.structureIds)
      end
    end
    self.selectedEntityIds_ = table.zmerge(self.selectedEntityIds_, self.data_.CurMultiSelectedEntIds)
    self:enterOperationState(self.selectedEntityIds_)
  end
end

function Home_editor_mainView:selectedEntity(entityId, configId)
  if not self.houseData_:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureEdit, Z.ContainerMgr.CharSerialize.charId) then
    Z.TipsVM.ShowTips(1044016)
    return
  end
  self:onSelected(entityId, configId)
end

function Home_editor_mainView:onSelectedGroup(groupId)
  self.data_.CurMultiSelectedEntIds = {}
  local data = self.data_.FurnitureGroupInfo[groupId]
  self.selectedEntityIds_ = {}
  if data then
    self.data_.CurMultiSelectedGroupIds = {}
    self.selectedEntityIds_ = data.structureIds
    self.data_.CurMultiSelectedGroupIds[1] = groupId
    self:enterOperationState(self.selectedEntityIds_)
  end
end

function Home_editor_mainView:refreshGroupState()
  self.uiBinder.Ref:SetVisible(self.multiSelectedTog_, not self.data_.IsGroupEditorState)
end

function Home_editor_mainView:dissolveStructureGroup()
  self:exitOperationState()
end

function Home_editor_mainView:updateState()
  if Z.EntityMgr.PlayerEnt then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
    local homelandEditId = Z.PbEnum("EActorState", "ActorStateHomelandEdit")
    if homelandEditId ~= stateId then
      self.vm_.CloseHomeMain()
    end
  end
end

function Home_editor_mainView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshAlignSwitchState, self.refreshAlignSwitchState, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshAbsorbSwitchState, self.refreshAbsorbSwitchState, self)
  Z.EventMgr:Add(Z.ConstValue.Home.HomeEntitySelectingSingle, self.selectedEntity, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshGroupState, self.refreshGroupState, self)
  Z.EventMgr:Add(Z.ConstValue.Home.DissolveStructureGroup, self.dissolveStructureGroup, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshEditorOperation, self.onSelectedGroup, self)
  Z.EventMgr:Add(Z.ConstValue.Home.HomeEntitySelecting, self.selectedEntitys, self)
  Z.EventMgr:Add(Z.ConstValue.Home.CancelSelectedItem, self.cancelSelectedItem, self)
  Z.EventMgr:Add(Z.ConstValue.Home.CancelSelectedUids, self.cancelSelectedUids, self)
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    self:updateState()
  end)
end

function Home_editor_mainView:isShowOperation(isShow)
  self.uiBinder.Ref:SetVisible(self.rightBtnsNode_, not isShow)
end

function Home_editor_mainView:enterOperationState(entityIds, configId)
  self.anim_do_:Restart(Z.DOTweenAnimType.Tween_0)
  self.operationSubView_:Active({entityIds = entityIds, configId = configId}, self.operationSubNode_)
end

function Home_editor_mainView:exitOperationState()
  Z.DIServiceMgr.HomeService:CancelSelectEntities()
  self.selectEntityId_ = nil
  self.data_.IsOperationState = false
  self.operationSubView_:DeActive()
  self.data_:InitTab()
end

function Home_editor_mainView:eventtrigger()
end

function Home_editor_mainView:setOperationIconPos()
end

function Home_editor_mainView:removeGrid()
  if self.gridGo_ then
    self.isLoading_ = false
    Z.LuaBridge.ReleaseInstance(self.gridGo_)
    self.gridGo_ = nil
  end
end

function Home_editor_mainView:loadGrid()
  if self.isLoading_ then
    return
  end
  self.isLoading_ = true
  self.homeLandId_ = self.data_:GetHomeLandId()
  local position, size, path
  local stageType = Z.StageMgr.GetCurrentStageType()
  if stageType == Z.EStageType.CommunityDungeon then
    local id = self.homeLandId_
    if id ~= 0 then
      local residentialDistrictsRow = Z.TableMgr.GetTable("ResidentialDistrictsMgr").GetRow(id)
      if residentialDistrictsRow then
        local plotTypeRow = Z.TableMgr.GetTable("PlotTypeMgr").GetRow(residentialDistrictsRow.PlotType)
        if plotTypeRow then
          position = {
            X = residentialDistrictsRow.PlotPosition.X,
            Z = residentialDistrictsRow.PlotPosition.Z
          }
          position.Y = residentialDistrictsRow.HousingPosition.Y
          size = plotTypeRow.Size
          path = plotTypeRow.Grid
        end
      end
    end
  elseif stageType == Z.EStageType.HomelandDungeon then
    local housingTypeRow = Z.TableMgr.GetTable("HousingTypeMgr").GetRow(1)
    if housingTypeRow then
      position = {
        X = 0,
        Y = 2.11,
        Z = 0
      }
      size = housingTypeRow.HousingSize
      path = housingTypeRow.Grid
    end
  end
  if path and self.gridGo_ == nil then
    local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.CreateInstanceAsync)
    self.gridGo_ = asyncCall(path, self.cancelSource:CreateToken())
  end
  if self.gridGo_ then
    self.gridGo_.transform:SetParent(nil)
    ZUtil.ZExtensions.SetPos(self.gridGo_.transform, position.X, position.Y, position.Z)
    ZUtil.ZExtensions.SetScale(self.gridGo_.transform, size.X / 10, size.Z / 10, size.Y / 10)
  end
end

function Home_editor_mainView:onStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Open)
end

return Home_editor_mainView
