local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_operation_subView = class("Home_editor_operation_subView", super)
local selectedItem = require("ui.component.home.home_selected_loop_item")
local wareMatLoopItem = require("ui.component.home.home_mat_loop_list")
local listView = require("ui.component.loop_list_view")
local gridView = require("ui.component.loop_grid_view")

function Home_editor_operation_subView:ctor(parent)
  self.uiBinder = nil
  self.parent = parent
  super.ctor(self, "home_editor_operation_sub", "home_editor/home_editor_operation_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home_editor")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.data_ = Z.DataMgr.Get("home_editor_data")
  self.quaternion_ = Quaternion.New(0, 0, 0, 0)
  self.setQuaternion_ = Quaternion.New(0, 0, 0, 0)
end

function Home_editor_operation_subView:close()
  Z.DIServiceMgr.HomeService:CancelEdit()
  self.data_:InitCopyTab()
  self.parent:exitOperationState()
end

function Home_editor_operation_subView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_reture
  self.operationNode_ = self.uiBinder.event_operation_node
  self.matBtn_ = self.uiBinder.btn_wallpaper
  self.matLoopList_ = self.uiBinder.scrollview_play
  self.bottomNode_ = self.uiBinder.node_bottom
  self.copyBtn_ = self.uiBinder.btn_copy
  self.tweakTog_ = self.uiBinder.tog_tweak
  self.tweakOperateNode_ = self.uiBinder.node_tweak_operate
  self.downBtn_ = self.uiBinder.btn_down
  self.upBtn_ = self.uiBinder.btn_up
  self.leftBtn_ = self.uiBinder.btn_left
  self.rightBtn_ = self.uiBinder.btn_right
  self.leftNode_ = self.uiBinder.node_left
  self.hightSlider_ = self.leftNode_.slider_zoom
  self.hightAddBtn_ = self.leftNode_.btn_zoom_in
  self.hightDownBtn_ = self.leftNode_.btn_zoom_out
  self.hightValueLab_ = self.leftNode_.lab_hight_num
  self.hightResetBtn_ = self.leftNode_.btn_reset
  self.selectedLoopList_ = self.leftNode_.scrollview_item
  self.clearAllBtn_ = self.leftNode_.btn_all_clear
  self.rotateNode_ = self.uiBinder.node_rotate
  self.rotateXNode_ = self.rotateNode_.img_operation_x_bg
  self.rotateYNode_ = self.rotateNode_.img_operation_y_bg
  self.rotateZNode_ = self.rotateNode_.img_operation_z_bg
  self.rotateXAddBtn_ = self.rotateNode_.btn_add_x
  self.rotateYAddBtn_ = self.rotateNode_.btn_add_y
  self.rotateZAddBtn_ = self.rotateNode_.btn_add_z
  self.rotateXLab_ = self.rotateNode_.lab_num_right_x
  self.rotateYLab_ = self.rotateNode_.lab_num_right_y
  self.rotateZLab_ = self.rotateNode_.lab_num_right_z
  self.rotateXMinusBtn_ = self.rotateNode_.btn_minus_x
  self.rotateYMinusBtn_ = self.rotateNode_.btn_minus_y
  self.rotateZMinusBtn_ = self.rotateNode_.btn_minus_z
  self.rotateXSlider_ = self.rotateNode_.slider_x
  self.rotateYSlider_ = self.rotateNode_.slider_y
  self.rotateZSlider_ = self.rotateNode_.slider_z
  self.rightNode_ = self.uiBinder.node_right
  self.saveBtn_ = self.rightNode_.btn_confirm
  self.retrieveBtn_ = self.rightNode_.btn_retrieve
  self.cancelBtn_ = self.rightNode_.btn_cancel
  self.exitEditorBtn_ = self.uiBinder.btn_exit_editor
  self.exitBtnNode_ = self.uiBinder.img_exit
  self.createGroupBtn_ = self.rightNode_.btn_new_combination
  self.exitGroupBtn_ = self.rightNode_.btn_move_combination
  self.editorGroupBtn_ = self.rightNode_.btn_edit_combination
  self.removeGroupBtn_ = self.rightNode_.btn_lifted_combination
end

function Home_editor_operation_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Home.SaveSelectedEntity, self.saveSelectedEntity, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RemoveStructureGroup, self.refreshGroupStateUi, self)
  Z.EventMgr:Add(Z.ConstValue.Home.HomeDragControllerUpdate, self.updatePos, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshSelectedSwitchState, self.refreshMultiSelected, self)
end

function Home_editor_operation_subView:refreshGroupStateUi()
  local isHide = self.data_.IsGroupEditorState and self.data_.CurEditorGroupEntityId == nil
  self.uiBinder.Ref:SetVisible(self.operationNode_, not isHide)
  self.leftNode_.Ref.UIComp:SetVisible(not isHide)
  if self.data_.IsGroupEditorState and isHide then
    Z.DIServiceMgr.HomeService:CancelSelectEntities()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshGroupState)
end

function Home_editor_operation_subView:initBtn()
  self:AddClick(self.closeBtn_, function()
    self:close()
  end)
  self:AddClick(self.hightResetBtn_, function()
    self.hightSlider_.value = math.floor((self.resetPosYValue_ - self.minHight_) * 100)
  end)
  self:AddClick(self.exitEditorBtn_, function()
    self.data_.IsGroupEditorState = false
    self:refreshGroupStateUi()
    self:OnRefresh()
  end)
  self:AddClick(self.copyBtn_, function()
    if Z.DIServiceMgr.HomeService:SaveEditingData() and self.selectedEntityIds_ then
      local copyIds = {}
      local copyConfigInfo = {}
      for index, uuid in ipairs(self.selectedEntityIds_) do
        local configId = self.data_:GetItemIdByUid(uuid)
        copyIds[index] = uuid
        if configId then
          if copyConfigInfo[configId] == nil then
            copyConfigInfo[configId] = 1
          else
            copyConfigInfo[configId] = copyConfigInfo[configId] + 1
          end
        end
      end
      for id, count in pairs(copyConfigInfo) do
        local curCount = self.data_:GetFurnitureWarehouseItemCount(id)
        curCount = curCount - (self.data_.LocalCreateHomeFurnitureDic[count] or 0)
        if count > curCount then
          Z.TipsVM.ShowTips(1044022)
          return
        end
      end
      self.parent:exitOperationState()
      local clientUuidZList = Z.DIServiceMgr.HomeService:CopyEntity(copyIds)
      if clientUuidZList then
        for i = 0, clientUuidZList.count - 1 do
          local uid = copyIds[i + 1]
          self.data_.CopyClientUidList[clientUuidZList[i]] = uid
          self.data_.CopyUUidList[uid] = clientUuidZList[i]
        end
        clientUuidZList:Recycle()
      end
    end
  end)
  self:AddClick(self.clearAllBtn_, function()
    self:close()
  end)
  self:AddClick(self.matBtn_, function()
    self.isShowMatList_ = not self.isShowMatList_
    self.uiBinder.Ref:SetVisible(self.matLoopList_, self.isShowMatList_)
    self.uiBinder.Ref:SetVisible(self.bottomNode_, self.isShowMatList_)
    self:refreshMatList()
  end)
  self:AddClick(self.downBtn_, function()
    local pos = Z.CameraMgr.MainCamera.transform.forward
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local entityPos = {
      x = self.entityPos_.x - pos.x / 100,
      y = self.hightValue_ / 100 + self.minHight_,
      z = self.entityPos_.z - pos.z / 100
    }
    self.entityPos_ = entityPos
    Z.DIServiceMgr.HomeService:SetDragControllerPosition(entityPos.x, entityPos.y, entityPos.z)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self:AddClick(self.upBtn_, function()
    local pos = Z.CameraMgr.MainCamera.transform.forward
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local entityPos = {
      x = self.entityPos_.x + pos.x / 100,
      y = self.hightValue_ / 100 + self.minHight_,
      z = self.entityPos_.z + pos.z / 100
    }
    self.entityPos_ = entityPos
    Z.DIServiceMgr.HomeService:SetDragControllerPosition(entityPos.x, entityPos.y, entityPos.z)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self:AddClick(self.leftBtn_, function()
    local pos = Z.CameraMgr.MainCamera.transform.right
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local entityPos = {
      x = self.entityPos_.x - pos.x / 100,
      y = self.hightValue_ / 100 + self.minHight_,
      z = self.entityPos_.z - pos.z / 100
    }
    self.entityPos_ = entityPos
    Z.DIServiceMgr.HomeService:SetDragControllerPosition(entityPos.x, entityPos.y, entityPos.z)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self:AddClick(self.rightBtn_, function()
    local pos = Z.CameraMgr.MainCamera.transform.right
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local entityPos = {
      x = self.entityPos_.x + pos.x / 100,
      y = self.hightValue_ / 100 + self.minHight_,
      z = self.entityPos_.z + pos.z / 100
    }
    self.entityPos_ = entityPos
    Z.DIServiceMgr.HomeService:SetDragControllerPosition(entityPos.x, entityPos.y, entityPos.z)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self:AddClick(self.tweakTog_, function(isOn)
    self.uiBinder.Ref:SetVisible(self.tweakOperateNode_, isOn)
  end)
  self:AddAsyncClick(self.createGroupBtn_, function()
    if not self.houseData_:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureEdit, Z.ContainerMgr.CharSerialize.charId) then
      Z.TipsVM.ShowTips(1044016)
      return
    end
    local data = {
      title = Lang("HomeEditGrupNameTitle"),
      inputContent = Lang("HomeEditGrupName"),
      stringLengthLimitNum = Z.GlobalHome.MaxStructureGroupNameLength,
      onConfirm = function(text)
        Z.CoroUtil.create_coro_xpcall(function()
          if self.data_.CurMultiSelectedGroupIds[1] then
            if #self.data_.CurMultiSelectedGroupIds > 1 then
              for i = 2, #self.data_.CurMultiSelectedGroupIds do
                self.vm_.AsyncDissolveStructureGroup(self.data_.CurMultiSelectedGroupIds[i], self.cancelSource:CreateToken(), true)
              end
            end
            self.vm_.AsyncAddToStructureGroup(self.data_.CurMultiSelectedGroupIds[1], self.selectedEntityIds_, self.cancelSource:CreateToken())
          else
            self.vm_.AsyncCreateStructureGroup(text, self.selectedEntityIds_, self.cancelSource:CreateToken())
          end
        end)()
      end
    }
    Z.TipsVM.OpenCommonPopupInput(data)
  end)
  self:AddAsyncClick(self.exitGroupBtn_, function()
    self.vm_.AsyncRemoveStructureGroup(self.data_.CurEditorGroupId, {
      self.data_.CurEditorGroupEntityId
    }, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.editorGroupBtn_, function()
    self.data_.IsGroupEditorState = true
    self.data_.CurEditorGroupId = self.data_.FurnitureGroupInfoDic[self.selectedEntityIds_[1]]
    self:refreshGroupStateUi()
    self.uiBinder.Ref:SetVisible(self.exitBtnNode_, true)
  end)
  self:AddAsyncClick(self.removeGroupBtn_, function()
    if not self.houseData_:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureEdit, Z.ContainerMgr.CharSerialize.charId) then
      Z.TipsVM.ShowTips(1044016)
      return
    end
    self.vm_.AsyncDissolveStructureGroup(self.data_.CurMultiSelectedGroupIds[1], self.cancelSource:CreateToken())
  end)
  self:AddClick(self.saveBtn_, function()
    if not self.houseData_:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureEdit, Z.ContainerMgr.CharSerialize.charId) then
      Z.TipsVM.ShowTips(1044016)
      return
    end
    self:saveSelectedEntity()
  end)
  self:AddClick(self.retrieveBtn_, function()
    if not self.houseData_:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureEdit, Z.ContainerMgr.CharSerialize.charId) then
      Z.TipsVM.ShowTips(1044016)
      return
    end
    local isShowFlowerTips = false
    for index, entityId in ipairs(self.selectedEntityIds_) do
      local structure = Z.DIServiceMgr.HomeService:GetHouseItemStructure(entityId)
      if structure and structure.farmlandInfo then
        local farmState = structure.farmlandInfo.farmlandState:ToInt()
        if farmState ~= E.HomeEFarmlandState.EFarmlandStateEmpty then
          isShowFlowerTips = true
          break
        end
      end
    end
    local func = function()
      Z.DIServiceMgr.HomeService:DestroyEntity()
      Z.DIServiceMgr.HomeService:SaveEditingData()
      if self.data_.IsMultiSelected then
        for key, groupId in pairs(self.data_.CurMultiSelectedGroupIds) do
          self.data_.FurnitureGroupInfo[groupId] = nil
        end
        self.parent:exitOperationState()
      else
        local entityId = self.selectedEntityIds_[1]
        local groupId = self.data_.FurnitureGroupInfoDic[entityId]
        if groupId then
          if self.data_.IsGroupEditorState then
            local groupInfo = self.data_.FurnitureGroupInfo[groupId]
            if groupInfo then
              table.zremoveOneByValue(groupInfo.structureIds, entityId)
              if 1 >= #groupInfo.structureIds then
                self.data_.FurnitureGroupInfoDic[groupId] = nil
                self.data_.FurnitureGroupInfo[groupId] = nil
                self.parent:exitOperationState()
              else
                self:refreshGroupStateUi()
              end
            end
          else
            self.data_.FurnitureGroupInfo[groupId] = nil
            self.parent:exitOperationState()
          end
        else
          self.parent:exitOperationState()
        end
      end
    end
    if isShowFlowerTips then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("LandRecycle"), function()
        func()
      end)
    else
      func()
    end
  end)
  self:AddClick(self.cancelBtn_, function()
    self:close()
  end)
  self:AddClick(self.rotateXAddBtn_, function()
    self.rotateXSlider_.value = self.rotateXValue_ + 1
  end)
  self:AddClick(self.rotateXMinusBtn_, function()
    self.rotateXSlider_.value = self.rotateXValue_ - 1
  end)
  self:AddClick(self.rotateYAddBtn_, function()
    self.rotateYSlider_.value = self.rotateYValue_ + 1
  end)
  self:AddClick(self.rotateYMinusBtn_, function()
    self.rotateYSlider_.value = self.rotateYValue_ - 1
  end)
  self:AddClick(self.rotateZAddBtn_, function()
    self.rotateZSlider_.value = self.rotateZValue_ + 1
  end)
  self:AddClick(self.rotateZMinusBtn_, function()
    self.rotateZSlider_.value = self.rotateZValue_ - 1
  end)
  self:AddClick(self.hightAddBtn_, function()
    self.hightSlider_.value = self.hightValue_ + 1
  end)
  self:AddClick(self.hightDownBtn_, function()
    self.hightSlider_.value = self.hightValue_ - 1
  end)
  self:AddClick(self.rotateYSlider_, function(value)
    local newValue = math.floor(value)
    if self.rotateYValue_ == newValue then
      return
    end
    if self.data_:GetAlignState() then
      if math.abs(newValue - self.rotateYValue_) < self.data_.AlignRotateValue then
        return
      else
        local rate = newValue / self.data_.AlignRotateValue
        newValue = math.floor(rate * self.data_.AlignRotateValue)
      end
    end
    Z.AudioMgr:Play(Z.GlobalHome.HomeFurnitureRotateDragAudio)
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local number = math.floor(newValue - self.rotateYValue_)
    self.rotateYValue_ = newValue
    self.rotateYLab_.text = newValue
    self:rotateGo(Vector3.up * number)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self:AddClick(self.rotateXSlider_, function(value)
    local newValue = math.floor(value)
    if self.rotateXValue_ == newValue then
      return
    end
    if self.data_:GetAlignState() then
      if math.abs(newValue - self.rotateXValue_) < self.data_.AlignRotateValue then
        return
      else
        local rate = newValue / self.data_.AlignRotateValue
        newValue = math.floor(rate * self.data_.AlignRotateValue)
      end
    end
    Z.AudioMgr:Play(Z.GlobalHome.HomeFurnitureRotateDragAudio)
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local number = math.floor(newValue - self.rotateXValue_)
    self.rotateXValue_ = newValue
    self.rotateXLab_.text = newValue
    self:rotateGo(Vector3.right * number)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self:AddClick(self.rotateZSlider_, function(value)
    local newValue = math.floor(value)
    if self.rotateZValue_ == newValue then
      return
    end
    if self.data_:GetAlignState() then
      if math.abs(newValue - self.rotateZValue_) < self.data_.AlignRotateValue then
        return
      else
        local rate = newValue / self.data_.AlignRotateValue
        newValue = math.floor(rate * self.data_.AlignRotateValue)
      end
    end
    Z.AudioMgr:Play(Z.GlobalHome.HomeFurnitureRotateDragAudio)
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    local number = math.floor(newValue - self.rotateZValue_)
    self.rotateZValue_ = newValue
    self.rotateZLab_.text = newValue
    self:rotateGo(Vector3.forward * number)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
  self.hightSlider_.minValue = 0
  self.hightSlider_.maxValue = math.floor((self.maxHight_ - self.minHight_) * 100)
  self:AddClick(self.hightSlider_, function(value)
    local newValue = math.floor(value)
    if self.hightValue_ == newValue then
      return
    end
    if self.data_:GetAlignState() then
      if math.abs(newValue - self.hightValue_) < self.data_.AlignHightValue then
        return
      else
        local rate = newValue / self.data_.AlignHightValue
        newValue = math.floor(rate * self.data_.AlignHightValue)
      end
    end
    Z.AudioMgr:Play(Z.GlobalHome.HomeFurnitureRotateDragAudio)
    Z.DIServiceMgr.HomeService:SetIsDrag(true)
    self.hightValue_ = newValue
    self.hightValueLab_.text = newValue
    local entityPos = {
      x = self.entityPos_.x,
      y = self.hightValue_ / 100 + self.minHight_,
      z = self.entityPos_.z
    }
    self.entityPos_.y = entityPos.y
    Z.DIServiceMgr.HomeService:SetDragControllerPosition(entityPos.x, entityPos.y, entityPos.z)
    Z.DIServiceMgr.HomeService:SetIsDrag(false)
  end)
end

function Home_editor_operation_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initBinders()
  self.homeLandId_ = self.data_:GetHomeLandId()
  self.minHight_, self.maxHight_ = self.vm_.GetOperationHight(self.homeLandId_)
  self:initBtn()
  self:bindEvents()
  self.selectedListView_ = gridView.new(self, self.selectedLoopList_, selectedItem, "home_editor_frame_selection_item")
  self.selectedListView_:Init({})
  self.matListView_ = listView.new(self, self.matLoopList_, wareMatLoopItem, "house_play_farm_item_tpl")
  self.matListView_:Init({})
  self.isShowMatList_ = false
  self.uiBinder.Ref:SetVisible(self.bottomNode_, self.isShowMatList_)
  self.uiBinder.Ref:SetVisible(self.matLoopList_, self.isShowMatList_)
  self.iconPos_ = Vector3.zero
  self:refreshMultiSelected()
  self.leftNode_.Ref:SetVisible(self.selectedLoopList_, self.data_.IsMultiSelected)
  self.leftNode_.Ref:SetVisible(self.clearAllBtn_, self.data_.IsMultiSelected)
  self.timerMgr:StartFrameTimer(function()
    self:refreshIconPos()
  end, 1, -1)
  self.tweakTog_.isOn = false
  self.uiBinder.Ref:SetVisible(self.tweakOperateNode_, false)
  self.isCloseView_ = false
end

function Home_editor_operation_subView:GetSelectedMatUuid()
  return self.selectedEntityIds_[1]
end

function Home_editor_operation_subView:refreshMatList()
  local data = {}
  local typeIds = self.data_.HousingGroupTypeMap[E.HousingItemGroupType.HousingItemGroupTypePartitionWallMat] or {}
  for index, typeId in ipairs(typeIds) do
    data = table.zmerge(data, self.vm_.GetWareHouseDataByTypeId(typeId))
  end
  self.matListView_:RefreshListView(data)
end

function Home_editor_operation_subView:refreshMultiSelected()
  self.leftNode_.Ref:SetVisible(self.selectedLoopList_, self.data_.IsMultiSelected)
  self.leftNode_.Ref:SetVisible(self.clearAllBtn_, self.data_.IsMultiSelected)
end

function Home_editor_operation_subView:refreshSelectedList()
  if self.isCloseView_ == true then
    return
  end
  local items = {}
  for index, value in ipairs(self.data_.CurMultiSelectedGroupIds) do
    items[index] = {IsGroup = true, GroupId = value}
  end
  local count = #items
  for index, value in ipairs(self.data_.CurMultiSelectedEntIds) do
    items[count + index] = {IsGroup = false, EntityUid = value}
  end
  self.selectedListView_:RefreshListView(items)
end

function Home_editor_operation_subView:refreshData()
  self:getEntityPos()
  self.isLangEntity_ = Z.DIServiceMgr.HomeService:GetHouseItemStructure(self.selectedEntityIds_[1]) ~= nil
  self.rightNode_.Ref:SetVisible(self.retrieveBtn_, self.isLangEntity_)
  self.uiBinder.Ref:SetVisible(self.matBtn_, self:checkCanEditingItemMat())
  local isNeedSave = not self:checkCanCopy()
  self.uiBinder.Ref:SetVisible(self.copyBtn_, true)
  self.isCloseView_ = false
  if isNeedSave and table.zcount(self.data_.CopyClientUidList) > 0 then
    self.isCloseView_ = true
    Z.DIServiceMgr.HomeService:SaveEditingData()
  end
end

function Home_editor_operation_subView:checkCanCopy()
  for index, uuid in ipairs(self.selectedEntityIds_) do
    if self.data_:GetItemIdByUid(uuid) == nil then
      return false
    end
  end
  return true
end

function Home_editor_operation_subView:checkCanEditingItemMat()
  if self.selectedEntityIds_ and #self.selectedEntityIds_ == 1 then
    local itemId = self.viewData.configId
    if not itemId then
      itemId = self.data_:GetItemIdByUid(self.selectedEntityIds_[1])
      if itemId == nil then
        return false
      end
    end
    if Z.DIServiceMgr.HomeService:IsSelectEntityNeedSave() then
      return false
    end
    local groupId = self.vm_.GetItemGroupType(itemId)
    return groupId == E.HousingItemGroupType.HousingItemGroupTypePartitionWall
  end
  return false
end

function Home_editor_operation_subView:OnDeActive()
  self.selectedEntityIds_ = nil
  self.entityPos_ = nil
  self.data_.IsOperationState = false
  self.data_.IsEditingItemMat = false
  if self.selectedListView_ then
    self.selectedListView_:UnInit()
    self.selectedListView_ = nil
  end
  if self.matListView_ then
    self.matListView_:UnInit()
    self.matListView_ = nil
  end
end

function Home_editor_operation_subView:OnRefresh()
  Z.DIServiceMgr.HomeService:CancelSelectEntities()
  if self.selectedEntityIds_ and #self.selectedEntityIds_ > 0 then
    Z.DIServiceMgr.HomeService:SaveEditingData()
  end
  self.selectedEntityIds_ = self.viewData.entityIds
  self.data_.CurSelectedList = self.viewData.entityIds
  Z.DIServiceMgr.HomeService:SelectEntities(self.selectedEntityIds_)
  self:refreshGroupStateUi()
  self:refreshGroupState()
  self:refreshData()
  self:refreshSelectedList()
end

function Home_editor_operation_subView:rotateGo(rotate)
  if not rotate then
    return
  end
  local euler = Quaternion.Euler(rotate.x, rotate.y, rotate.z)
  local inverse = self.quaternion_:Inverse()
  local rotation = self.quaternion_ * (inverse * euler * self.quaternion_)
  self.quaternion_:Set(rotation.x, rotation.y, rotation.z, rotation.w)
  self.quaternion_:SetNormalize()
  local angles = self.quaternion_:ToEulerAngles()
  Z.DIServiceMgr.HomeService:SetDragControllerRotation(angles.x, angles.y, angles.z)
end

function Home_editor_operation_subView:setRotation()
  local x = math.floor(self.entityRotation_.x)
  if 180 < x then
    x = x - 360
  end
  self.rotateXValue_ = x
  self.rotateXLab_.text = x
  self.rotateXSlider_.value = x
  local y = math.floor(self.entityRotation_.y)
  if 180 < y then
    y = y - 360
  end
  self.rotateYLab_.text = y
  self.rotateYValue_ = y
  self.rotateYSlider_.value = y
  local z = math.floor(self.entityRotation_.z)
  if 180 < z then
    z = z - 360
  end
  self.rotateZValue_ = z
  self.rotateZLab_.text = z
  self.rotateZSlider_.value = z
end

function Home_editor_operation_subView:getEntityPos()
  self.entityPos_ = Vector3.zero
  self.entityRotation_ = Vector3.zero
  if self.selectedEntityIds_ then
    self.entityPos_.x, self.entityPos_.y, self.entityPos_.z = Z.DIServiceMgr.HomeService:GetDragControllerPosition(self.entityPos_.x, self.entityPos_.y, self.entityPos_.z)
    self.entityRotation_.x, self.entityRotation_.y, self.entityRotation_.z = Z.DIServiceMgr.HomeService:GetDragControllerRotation(self.entityRotation_.x, self.entityRotation_.y, self.entityRotation_.z)
    self.entityPos_.x = self.entityPos_.x + 0
    self.entityPos_.y = self.entityPos_.y + 0
    self.resetPosYValue_ = self.entityPos_.y
    self.entityPos_.z = self.entityPos_.z + 0
    self.entityRotation_.x = self.entityRotation_.x + 0
    self.entityRotation_.y = self.entityRotation_.y + 0
    self.entityRotation_.z = self.entityRotation_.z + 0
    local rotation = Quaternion.Euler(self.entityRotation_.x, self.entityRotation_.y, self.entityRotation_.z)
    self.quaternion_:Set(rotation.x, rotation.y, rotation.z, rotation.w)
    self.hightValue_ = math.max(math.floor((self.entityPos_.y - self.minHight_) * 100), 0)
    self.hightSlider_.value = self.hightValue_
    self.hightValueLab_.text = self.hightValue_
    self:setRotation()
  end
end

function Home_editor_operation_subView:updatePos(pos, rot)
  if self.entityPos_ == nil then
    self.entityPos_ = Vector3.zero
  end
  self.entityPos_.x = pos.x + 0
  self.entityPos_.y = pos.y + 0
  self.entityPos_.z = pos.z + 0
end

function Home_editor_operation_subView:refreshIconPos()
  if self.entityPos_ then
    local v2 = ZTransformUtility.WorldToScreenPoint(self.entityPos_, false, Z.CameraMgr.MainCamera)
    local pos = Z.UIRoot.UICam:ScreenToWorldPoint(Vector3.New(v2.x, v2.y, 0))
    self.iconPos_.x = pos.x
    self.iconPos_.y = pos.y
    self.operationNode_.transform.position = self.iconPos_
  end
end

function Home_editor_operation_subView:saveSelectedEntity()
  if Z.DIServiceMgr.HomeService:SaveEditingData() then
    self.parent:exitOperationState()
  end
end

function Home_editor_operation_subView:refreshGroupState()
  local isShowRemoveBtn = self.data_.IsMultiSelected and #self.data_.CurMultiSelectedGroupIds == 1 and #self.data_.CurMultiSelectedEntIds == 0
  local isShowCreateBtn = self.data_.IsMultiSelected and (#self.data_.CurMultiSelectedGroupIds > 1 or 1 < #self.data_.CurMultiSelectedEntIds or #self.data_.CurMultiSelectedGroupIds == 1 and #self.data_.CurMultiSelectedEntIds == 1)
  local isShowEditorBtn = not self.data_.IsMultiSelected and self.data_.FurnitureGroupInfoDic[self.selectedEntityIds_[1]] ~= nil and not self.data_.IsGroupEditorState
  local isShowExitGroupBtn = self.data_.IsGroupEditorState and self.data_.CurEditorGroupEntityId ~= nil
  self.rightNode_.Ref:SetVisible(self.removeGroupBtn_, isShowRemoveBtn)
  self.rightNode_.Ref:SetVisible(self.createGroupBtn_, isShowCreateBtn)
  self.rightNode_.Ref:SetVisible(self.exitGroupBtn_, isShowExitGroupBtn)
  self.rightNode_.Ref:SetVisible(self.editorGroupBtn_, isShowEditorBtn)
  self.isSelectSingle_ = not isShowCreateBtn and not isShowRemoveBtn and not isShowEditorBtn
  self.rotateNode_.Ref:SetVisible(self.rotateXNode_, self.isSelectSingle_)
  self.rotateNode_.Ref:SetVisible(self.rotateZNode_, self.isSelectSingle_)
  self.uiBinder.Ref:SetVisible(self.exitBtnNode_, self.data_.IsGroupEditorState and not self.data_.CurEditorGroupEntityId)
end

return Home_editor_operation_subView
