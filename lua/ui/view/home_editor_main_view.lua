local UI = Z.UI
local super = require("ui.ui_view_base")
local Home_editor_mainView = class("Home_editor_mainView", super)
local rightSubView = require("ui.view.home_editor_right_sub_view")
local operationSubView = require("ui.view.home_editor_operation_sub_view")
E.EHomeRightSubType = {
  Warehouse = 1,
  Furniture = 2,
  Setting = 3
}

function Home_editor_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "home_editor_main")
  self.vm_ = Z.VMMgr.GetVM("home")
  self.data_ = Z.DataMgr.Get("home_data")
  self.rightSubView_ = rightSubView.new(self)
  self.operationSubView_ = operationSubView.new(self)
  self.joystickView_ = require("ui/view/zjoystick_view").new()
end

function Home_editor_mainView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_reture
  self.titleLab_ = self.uiBinder.lab_title
  self.numLab_ = self.uiBinder.lab_num
  self.rightBtnsNode_ = self.uiBinder.node_top_right_btn
  self.setBtn_ = self.uiBinder.btn_setting
  self.warehouseBtn_ = self.uiBinder.btn_warehouse
  self.furnitureBtn_ = self.uiBinder.btn_furniture
  self.adsorbTog_ = self.uiBinder.tog_adsorb
  self.griddingbTog_ = self.uiBinder.tog_gridding
  self.alignTog_ = self.uiBinder.tog_aligning
  self.opearCameraNode_ = self.uiBinder.node_down_left_btn
  self.upCameraBtn_ = self.uiBinder.btn_up
  self.downCameraBtn_ = self.uiBinder.btn_down
  self.rightSubNode_ = self.uiBinder.node_right_sub
  self.operationSubNode_ = self.uiBinder.node_operation_sub
  self.joystickNode_ = self.uiBinder.node_joystick
end

function Home_editor_mainView:initBtn()
  self:AddClick(self.closeBtn_, function()
    self.vm_.CloseHomeMain()
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
  self:AddClick(self.adsorbTog_, function(isOn)
  end)
  self:AddAsyncClick(self.griddingbTog_, function(isOn)
    if isOn then
      self:loadGrid()
    else
      self:removeGrid()
    end
  end)
  self:AddClick(self.alignTog_, function(isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshGridSwitchState, isOn)
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
  self.vm_.InitAlignNum()
  self:bindEvent()
  self:initBinders()
  self:initBtn()
  if not Z.IsPCUI then
    self.joystickView_:Active(nil, self.joystickNode_.transform)
  end
  self.opearCameraNode_:SetAnchorPosition(-100, 100)
  self.griddingbTog_.isOn = false
  self.homeId_ = self.data_:GetomeLoadId()
  Z.DIServiceMgr.HomeService:EnterEditState(self.homeId_)
  local state = self.vm_.GetAlignState()
  self:refreshGridSwitchState(state)
end

function Home_editor_mainView:OnActiveRigtSubView(type)
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
  Z.DIServiceMgr.HomeService:ExitEditState()
end

function Home_editor_mainView:OnRefresh()
end

function Home_editor_mainView:refreshGridSwitchState(state)
  self.vm_.SetAlignState(state)
  self.isAlign_ = state
  self.alignTog_.isOn = state
end

function Home_editor_mainView:selectedEnitity(entityId, configId)
  local fun = function()
    if entityId then
      self.selectEntityId_ = entityId
      self:enterOperationState(entityId, configId)
    end
  end
  if self.selectEntityId_ == nil then
    fun()
  elseif self.selectEntityId_ ~= entityId then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("HomeSwicthSelected"), function()
      fun()
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  end
end

function Home_editor_mainView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshGridSwitchState, self.refreshGridSwitchState, self)
  Z.EventMgr:Add(Z.ConstValue.Home.HomeEntitySelectingSingle, self.selectedEnitity, self)
end

function Home_editor_mainView:isShowOperation(isShow)
  self.uiBinder.Ref:SetVisible(self.rightBtnsNode_, not isShow)
end

function Home_editor_mainView:enterOperationState(entityId, configId)
  self.selectedEntityId_ = entityId
  self.operationSubView_:Active({entityId = entityId, configId = configId}, self.operationSubNode_)
end

function Home_editor_mainView:exitOperationState()
  self.selectEntityId_ = nil
  Z.DIServiceMgr.HomeService:CancelSelectEntity()
  self.operationSubView_:DeActive()
end

function Home_editor_mainView:eventtrigger()
end

function Home_editor_mainView:setOperationIconPos()
end

function Home_editor_mainView:removeGrid()
  if self.gridGo_ then
    Z.LuaBridge.ReleaseInstance(self.gridGo_)
    self.gridGo_ = nil
  end
end

function Home_editor_mainView:loadGrid()
  local position, size, path
  local stageType = Z.StageMgr.GetCurrentStageType()
  if stageType == Z.EStageType.CommunityDungeon then
    local id = self.homeId_
    if id ~= 0 then
      local residentialDistrictsRow = Z.TableMgr.GetTable("ResidentialDistrictsMgr").GetRow(id)
      if residentialDistrictsRow then
        local plotTypeRow = Z.TableMgr.GetTable("PlotTypeMgr").GetRow(residentialDistrictsRow.PlotType)
        if plotTypeRow then
          position = residentialDistrictsRow.PlotPosition
          position.Y = position.Y + 0.3
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
        Y = 0.5,
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

return Home_editor_mainView
