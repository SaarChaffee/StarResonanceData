local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_operation_subView = class("Home_editor_operation_subView", super)
local EOperationType = {
  None = 0,
  MoveXZ = 1,
  MoveY = 2,
  Rotate = 3,
  RotateX = 4,
  RotateY = 5,
  RotateZ = 6
}
local operationLabShowType = {
  [EOperationType.RotateX] = "x",
  [EOperationType.RotateY] = "y",
  [EOperationType.RotateZ] = "z"
}

function Home_editor_operation_subView:ctor(parent)
  self.uiBinder = nil
  self.parent = parent
  super.ctor(self, "home_editor_operation_sub", "home_editor/home_editor_operation_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home")
  self.data_ = Z.DataMgr.Get("home_data")
end

function Home_editor_operation_subView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_reture
  self.node_btn_operation_ = self.uiBinder.node_btn_operation
  self.operationNode_ = self.uiBinder.node_operation
  self.operationEvent_ = self.uiBinder.event_operation
  self.operationIconImg_ = self.uiBinder.img_operation_icon
  self.operationLab_ = self.uiBinder.lab_operation_num
  self.operationTogs_ = {}
  self.operationTogs_[EOperationType.MoveXZ] = self.uiBinder.tog_move
  self.operationTogs_[EOperationType.MoveY] = self.uiBinder.tog_upanddown
  self.operationTogs_[EOperationType.Rotate] = self.uiBinder.tog_rotate
  self.operationRotateNode_ = self.uiBinder.img_operation_rotate_bg
  self.operationRotateTogs_ = {}
  self.operationRotateTogs_[EOperationType.RotateX] = self.uiBinder.tog_rotate_x
  self.operationRotateTogs_[EOperationType.RotateY] = self.uiBinder.tog_rotate_y
  self.operationRotateTogs_[EOperationType.RotateZ] = self.uiBinder.tog_rotate_z
  self.saveBtn_ = self.uiBinder.btn_save
  self.takebackBtn_ = self.uiBinder.btn_takeback
  self.cancelBtn_ = self.uiBinder.btn_cancel
  self.uiBinder.Trans:SetSizeDelta(0, 0)
end

function Home_editor_operation_subView:close()
  Z.DIServiceMgr.HomeService:CancelEdit(self.selectedEntityId_)
  if not self.isLangEntity_ then
    Z.DIServiceMgr.HomeService:DestroyEntity(self.selectedEntityId_)
  end
  self.parent:exitOperationState()
end

function Home_editor_operation_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Home.SaveSelectedEntity, self.saveSelectedEntity, self)
end

function Home_editor_operation_subView:initBtn()
  self:AddClick(self.closeBtn_, function()
    self:close()
  end)
  self:AddClick(self.saveBtn_, function()
    self:saveSelectedEntity()
  end)
  self:AddClick(self.takebackBtn_, function()
    if self.isLangEntity_ then
      Z.DIServiceMgr.HomeService:DestroyEntity(self.selectedEntityId_)
      Z.DIServiceMgr.HomeService:SaveEditingData(self.selectedEntityId_)
    end
    self.parent:exitOperationState()
  end)
  self:AddClick(self.cancelBtn_, function()
    self:close()
  end)
  for eOperationKey, tog in pairs(self.operationTogs_) do
    self:AddClick(tog, function(isOn)
      if isOn then
        self:setOperationState(eOperationKey)
      end
    end)
  end
  for eOperationKey, rotateTog in pairs(self.operationRotateTogs_) do
    self:AddClick(rotateTog, function(isOn)
      if isOn then
        self:setOperationIcon(eOperationKey)
      end
    end)
  end
  self.operationEvent_.onDrag:AddListener(function(go, pointerData)
    self.data_.IsDrag = true
    if self.selectedEntityId_ then
      self:dragOperationIcon(pointerData)
    end
  end)
  self.operationEvent_.onEndDrag:AddListener(function(go, pointerData)
    self.data_.IsDrag = false
    if self.selectedEntityId_ then
      Z.DIServiceMgr.HomeService:SetModelDrag(self.selectedEntityId_, false)
      Z.DIServiceMgr.HomeService:PreviewRotateEntity(self.selectedEntityId_, self.entityrotation_.x, self.entityrotation_.y, self.entityrotation_.z)
      Z.DIServiceMgr.HomeService:PreviewMoveEntity(self.selectedEntityId_, self.entitypos_.x, self.entitypos_.y, self.entitypos_.z)
    end
  end)
  self.operationEvent_.onDown:AddListener(function(go, pointerData)
    self.pos_ = pointerData.position
    if self.selectedEntityId_ then
      Z.DIServiceMgr.HomeService:SetModelDrag(self.selectedEntityId_, true)
      self.isAlign_ = self.data_:GetAlignState()
      self.moveValue_ = self.isAlign_ and self.data_.AlignMoveValue / 10 or Time.deltaTime * 10
      self.rotateXValue_ = self.isAlign_ and self.data_.AlignRotateValue or Time.deltaTime * self.rotateSpeedValue_[1]
      self.rotateYValue_ = self.isAlign_ and self.data_.AlignRotateValue or Time.deltaTime * self.rotateSpeedValue_[2]
      self.rotateZValue_ = self.isAlign_ and self.data_.AlignRotateValue or Time.deltaTime * self.rotateSpeedValue_[3]
      self.hightValue_ = self.isAlign_ and self.data_.AlignHightValue / 10 or Time.deltaTime * 10
      self:getEntityPos()
    end
  end)
end

function Home_editor_operation_subView:OnActive()
  self:initBinders()
  self:initBtn()
  self:initItemPath()
  self:bindEvents()
  local residentialAreaParameterRow = Z.TableMgr.GetTable("ResidentialAreaParameterMgr").GetRow(E.EHomeAlignType.RotateSpeedValue)
  if residentialAreaParameterRow then
    self.rotateSpeedValue_ = residentialAreaParameterRow.Value
  else
    self.rotateSpeedValue_ = {
      [1] = 10,
      [2] = 10,
      [3] = 10
    }
  end
  self.data_.IsOperationState = true
  self.iconPosi_ = Vector3.zero
  self.timerMgr:StartFrameTimer(function()
    self:refreshIconPos()
  end, 1, -1)
end

function Home_editor_operation_subView:refreshData()
  self:getEntityPos()
  self.isLangEntity_ = self.data_:GetLangData(self.selectedEntityId_) ~= nil
  self.uiBinder.Ref:SetVisible(self.takebackBtn_, self.isLangEntity_)
  self.operationTogs_[EOperationType.MoveXZ].isOn = true
  self:setOperationState(EOperationType.MoveXZ)
end

function Home_editor_operation_subView:OnDeActive()
  self.selectedEntityId_ = nil
  self.entitypos_ = nil
  self.data_.IsOperationState = false
end

function Home_editor_operation_subView:OnRefresh()
  if self.selectedEntityId_ and self.selectedEntityId_ ~= self.viewData.entityId then
    Z.DIServiceMgr.HomeService:SaveEditingData(self.selectedEntityId_)
  end
  self.selectedEntityId_ = self.viewData.entityId
  Z.DIServiceMgr.HomeService:SelectEntity(self.selectedEntityId_, false)
  self.homeId_ = self.data_:GetomeLoadId()
  self:refreshData()
end

function Home_editor_operation_subView:screenToWorldPoint(pos, entityPos)
  local newScreenPos1 = Vector3.New(pos.x, pos.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, entityPos))
  return Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos1)
end

function Home_editor_operation_subView:dragOperationIcon(pointerData)
  local newpos = pointerData.position - self.pos_
  local isMove = false
  local entityPos = {
    x = self.entitypos_.x,
    y = self.entitypos_.y,
    z = self.entitypos_.z
  }
  if self.state == EOperationType.MoveXZ then
    isMove = true
    local worldPosition = self:screenToWorldPoint(pointerData.position, entityPos)
    if self.isAlign_ then
      local worldPosition1 = self:screenToWorldPoint(pointerData.position, entityPos)
      local worldPosition2 = self:screenToWorldPoint(self.pos_, entityPos)
      worldPosition.x = worldPosition.x - worldPosition.x % 0.1
      worldPosition.z = worldPosition.z - worldPosition.z % 0.1
      local pos = worldPosition1 - worldPosition2
      if pos.x > self.moveValue_ then
        self.pos_ = pointerData.position
        entityPos.x = worldPosition.x + self.moveValue_
      elseif pos.x < -self.moveValue_ then
        self.pos_ = pointerData.position
        entityPos.x = worldPosition.x - self.moveValue_
      end
      if pos.z > self.moveValue_ then
        self.pos_ = pointerData.position
        entityPos.z = worldPosition.z + self.moveValue_
      elseif pos.z < -self.moveValue_ then
        self.pos_ = pointerData.position
        entityPos.z = worldPosition.z - self.moveValue_
      end
    else
      self.pos_ = pointerData.position
      entityPos.x = worldPosition.x
      entityPos.z = worldPosition.z
    end
  elseif self.state == EOperationType.MoveY then
    local worldPosition = self:screenToWorldPoint(pointerData.position, entityPos)
    isMove = true
    if self.isAlign_ then
      local worldPosition1 = self:screenToWorldPoint(pointerData.position, entityPos)
      local worldPosition2 = self:screenToWorldPoint(self.pos_, entityPos)
      local pos = worldPosition1 - worldPosition2
      worldPosition.y = worldPosition.y - worldPosition.y % 0.1
      if pos.y > self.hightValue_ then
        self.pos_ = pointerData.position
        entityPos.y = worldPosition.y + self.hightValue_
      elseif pos.y < -self.hightValue_ then
        self.pos_ = pointerData.position
        entityPos.y = worldPosition.y - self.hightValue_
      end
    else
      self.pos_ = pointerData.position
      entityPos.y = worldPosition.y
    end
  elseif self.state == EOperationType.RotateX then
    if newpos.y > 0 then
      self.entityrotation_ = self.entityrotation_ + Vector3.right * self.rotateXValue_
    elseif newpos.y < 0 then
      self.entityrotation_ = self.entityrotation_ - Vector3.right * self.rotateXValue_
    end
    self.operationLab_.text = math.floor(self.entityrotation_.x % 360) .. "\194\176"
  elseif self.state == EOperationType.RotateY then
    if newpos.y > 0 then
      self.entityrotation_ = self.entityrotation_ + Vector3.up * self.rotateYValue_
    elseif newpos.y < 0 then
      self.entityrotation_ = self.entityrotation_ - Vector3.up * self.rotateYValue_
    end
    self.operationLab_.text = math.floor(self.entityrotation_.y % 360) .. "\194\176"
  elseif self.state == EOperationType.RotateZ then
    if newpos.x > 0 then
      self.entityrotation_ = self.entityrotation_ - Vector3.forward * self.rotateZValue_
    elseif newpos.x < 0 then
      self.entityrotation_ = self.entityrotation_ + Vector3.forward * self.rotateZValue_
    end
    self.operationLab_.text = math.floor(self.entityrotation_.z % 360) .. "\194\176"
  end
  if not isMove then
    Z.DIServiceMgr.HomeService:SetModelDragRotation(self.selectedEntityId_, self.entityrotation_.x, self.entityrotation_.y, self.entityrotation_.z)
  elseif self.vm_.CheckPos(entityPos, self.homeId_) then
    Z.DIServiceMgr.HomeService:SetModelDragPosition(self.selectedEntityId_, entityPos.x, entityPos.y, entityPos.z)
    self.entitypos_.x = entityPos.x
    self.entitypos_.y = entityPos.y
    self.entitypos_.z = entityPos.z
  end
end

function Home_editor_operation_subView:initItemPath()
  self.operationPath_ = {}
  for typeName, type in pairs(EOperationType) do
    self.operationPath_[type] = self.uiBinder.cache_data:GetString(typeName)
  end
end

function Home_editor_operation_subView:setOperationState(state)
  local isRotate = state == EOperationType.Rotate
  self.uiBinder.Ref:SetVisible(self.operationRotateNode_, isRotate)
  self.uiBinder.Ref:SetVisible(self.operationLab_, isRotate)
  if isRotate then
    self.operationRotateTogs_[EOperationType.RotateX].isOn = true
    self:setOperationIcon(EOperationType.RotateX)
  else
    self:setOperationIcon(state)
  end
end

function Home_editor_operation_subView:setOperationIcon(state)
  if self.operationPath_[state] then
    self.state = state
    self.operationIconImg_:SetImage(self.operationPath_[state])
    if operationLabShowType[state] and self.entityrotation_[operationLabShowType[state]] then
      self.operationLab_.text = math.floor(self.entityrotation_[operationLabShowType[state]]) .. "\194\176"
    end
  end
end

function Home_editor_operation_subView:getEntityPos()
  self.entitypos_ = Vector3.zero
  self.entityrotation_ = Vector3.zero
  if self.selectedEntityId_ then
    self.entitypos_.x, self.entitypos_.y, self.entitypos_.z = Z.DIServiceMgr.HomeService:GetSelectEntityPreviewPosition(self.entitypos_.x, self.entitypos_.y, self.entitypos_.z)
    self.entityrotation_.x, self.entityrotation_.y, self.entityrotation_.z = Z.DIServiceMgr.HomeService:GetSelectEntityPreviewRotation(self.entityrotation_.x, self.entityrotation_.y, self.entityrotation_.z)
    self.entitypos_.x = self.entitypos_.x + 0
    self.entitypos_.y = self.entitypos_.y + 0
    self.entitypos_.z = self.entitypos_.z + 0
    self.entityrotation_.x = self.entityrotation_.x + 0
    self.entityrotation_.y = self.entityrotation_.y + 0
    self.entityrotation_.z = self.entityrotation_.z + 0
  end
end

function Home_editor_operation_subView:refreshIconPos()
  if self.entitypos_ then
    local v2 = ZTransformUtility.WorldToScreenPoint(self.entitypos_, false, Z.CameraMgr.MainCamera)
    local pos = Z.UIRoot.UICam:ScreenToWorldPoint(Vector3.New(v2.x, v2.y, 0))
    self.iconPosi_.x = pos.x
    self.iconPosi_.y = pos.y
    self.operationNode_.transform.position = self.iconPosi_
  end
end

function Home_editor_operation_subView:saveSelectedEntity()
  Z.DIServiceMgr.HomeService:SaveEditingData(self.selectedEntityId_)
  self.data_:RemoveHomeFurniture(self.viewData.configId)
  self.parent:exitOperationState()
end

return Home_editor_operation_subView
