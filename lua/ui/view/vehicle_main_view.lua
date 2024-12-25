local UI = Z.UI
local super = require("ui.ui_view_base")
local Vehicle_mainView = class("Vehicle_mainView", super)
local loopListView = require("ui/component/loop_list_view")
local loopGridView = require("ui/component/loop_grid_view")
local vehicleArticleItemTplItem = require("ui/component/vehicle/vehicle_article_item_tpl_item")
local vehicleMainItemTplItem = require("ui/component/vehicle/vehicle_main_item_tpl_item")
local vehicleDefine = require("ui.model.vehicle_define")
local rotation = Quaternion.Euler(Vector3.New(0, 160, 0))

function Vehicle_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "vehicle_main")
  self.allVehicles_ = nil
  self.selectVehicleId = nil
  self.selectConfig_ = nil
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
  self.vehicleData_ = Z.DataMgr.Get("vehicle_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Vehicle_mainView:OnActive()
  self:AddAsyncClick(self.uiBinder.btn_unequip.btn, function()
    local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
    if count == 0 then
      Z.TipsVM.ShowTipsLang(1000903)
      return
    end
    local isEquip, type = self.vehicleVM_.IsEquip(self.selectConfig_.Id)
    if isEquip then
      self.vehicleVM_.TakeOffRide(self.selectConfig_.Id, self.cancelSource:CreateToken())
    else
      self.vehicleVM_.TakeOnRide(self.selectConfig_.PropertyId[2], self.selectConfig_.Id, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_adorn, function()
  end)
  self:AddAsyncClick(self.uiBinder.btn_cultivation, function()
  end)
  self:AddAsyncClick(self.uiBinder.btn_position, function()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(7050)
  end)
  self:AddAsyncClick(self.uiBinder.btn_info, function()
    if self.functionSearchData_ then
      self.itemSourceVm_.JumpToSource(self.functionSearchData_)
    end
  end)
  self.uiBinder.tog_mount:RemoveAllListeners()
  self.uiBinder.tog_mount.isOn = false
  self.uiBinder.tog_mount:AddListener(function()
    self.isShowPlayModel_ = self.uiBinder.tog_mount.isOn
    self:refreshModels()
  end)
  self:AddClick(self.uiBinder.rayimg_unrealscene_drag.onBeginDrag, function(go, eventData)
    self:onUnrealsceneBeginDrag(eventData)
  end)
  self:AddClick(self.uiBinder.rayimg_unrealscene_drag.onDrag, function(go, eventData)
    self:onUnrealsceneDrag(eventData)
  end)
  self:AddClick(self.uiBinder.rayimg_unrealscene_drag.onEndDrag, function(go, eventData)
    self:onUnrealsceneEndDrag(eventData)
  end)
  local functionRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.Vehicle)
  if functionRow then
    self.uiBinder.lab_title.text = functionRow.Name
  else
    self.uiBinder.lab_title.text = ""
  end
  self.listItem_ = loopListView.new(self, self.uiBinder.loop_item_article, vehicleArticleItemTplItem, "vehicle_article_item_tpl")
  self.listItem_:Init({})
  self.gridVehicle_ = loopGridView.new(self, self.uiBinder.loop_item, vehicleMainItemTplItem, "vehicle_main_item_tpl")
  self.gridVehicle_:Init({})
  self.propertyUnits_ = {}
  self.allVehicles_ = {}
  self.isShowPlayModel_ = false
  self.curShowModel_ = nil
  self.functionSearchData_ = nil
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self.modelPosition_ = Z.UnrealSceneMgr:GetTransPos("pos")
  Z.EventMgr:Add(Z.ConstValue.Vehicle.EquipVehicle, self.refreshInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UnEquipVehicle, self.refreshInfo, self)
end

function Vehicle_mainView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.EquipVehicle, self.refreshInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.UnEquipVehicle, self.refreshInfo, self)
  self.selectVehicleId = nil
  self.selectConfig_ = nil
  if self.listItem_ then
    self.listItem_:UnInit()
    self.listItem_ = nil
  end
  if self.gridVehicle_ then
    self.gridVehicle_:UnInit()
    self.gridVehicle_ = nil
  end
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  self:clearPropertyUnits()
end

function Vehicle_mainView:OnRefresh()
  self.allVehicles_ = self.vehicleData_:GetVehicleConfigs()
  table.sort(self.allVehicles_, function(a, b)
    local aState = self.vehicleVM_.IsEquip(a.Id) and 0 or 1
    local bState = self.vehicleVM_.IsEquip(b.Id) and 0 or 1
    if aState == bState then
      local aCount = self.itemsVM_.GetItemTotalCount(a.Id)
      local bCount = self.itemsVM_.GetItemTotalCount(b.Id)
      if aCount == bCount then
        if a.SortId == b.SortId then
          return a.Id < b.Id
        else
          return a.SortId < b.SortId
        end
      else
        return aCount > bCount
      end
    else
      return aState < bState
    end
  end)
  if self.viewData and self.viewData.vehicleId then
    self:SetSelectId(self.viewData.vehicleId, true)
  else
    self:SetSelectId(self.allVehicles_[1].Id, true)
  end
end

function Vehicle_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Vehicle_mainView:GetCacheData()
  local viewData = {vehicleId = nil}
  return viewData
end

function Vehicle_mainView:refreshLoopList()
  local index = 1
  for k, v in ipairs(self.allVehicles_) do
    if v.Id == self.selectVehicleId then
      index = k
      break
    end
  end
  self.gridVehicle_:RefreshListView(self.allVehicles_)
  self.gridVehicle_:SetSelected(index)
end

function Vehicle_mainView:clearPropertyUnits()
  for _, unitName in pairs(self.propertyUnits_) do
    self:RemoveUiUnit(unitName)
  end
  self.propertyUnits_ = {}
end

function Vehicle_mainView:refreshProperty()
  self:clearPropertyUnits()
  if self.selectConfig_ then
    Z.CoroUtil.create_coro_xpcall(function()
      local mgr = Z.TableMgr.GetTable("VehiclePropertyTableMgr")
      local path = self.uiBinder.prefab_cache:GetString("item")
      for _, property in ipairs(self.selectConfig_.PropertyId) do
        local name = "property" .. property
        local unit = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_icon)
        if unit then
          local config = mgr.GetRow(property)
          if config then
            unit.img_icon:SetImage(config.Icon)
          end
          self.propertyUnits_[property] = name
          unit.btn_icon:RemoveAllListeners()
          unit.btn_icon:AddListener(function()
            self.vehicleVM_.OpenPopView(self.selectConfig_.Id, vehicleDefine.PopType.Property)
          end)
        end
      end
    end)()
  end
end

function Vehicle_mainView:refreshSkill()
  if self.selectConfig_ then
    if self.selectConfig_.SkillId and self.selectConfig_.SkillId ~= 0 then
      self.uiBinder.skill_item.Ref.UIComp:SetVisible(true)
      local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.selectConfig_.SkillId)
      if config then
        self.uiBinder.skill_item.img_icon:SetImage(config.Icon)
        self.uiBinder.skill_item.lab_title.text = config.Name
        self.uiBinder.skill_item.lab_content.text = config.Desc
      end
    else
      self.uiBinder.skill_item.Ref.UIComp:SetVisible(false)
    end
  end
end

function Vehicle_mainView:refreshLeftInfo()
  if self.selectConfig_ then
    self.uiBinder.lab_name.text = self.selectConfig_.Name
    self.uiBinder.lab_lv.text = self.selectConfig_.Score
  end
  self:refreshProperty()
  self.listItem_:RefreshListView({
    [1] = {
      name = Lang("VehicleRunSpeedPersent"),
      num = self.selectConfig_.RunSpeedRate / 100 .. "%"
    },
    [2] = {
      name = Lang("VehicleSprintSpeedPersent"),
      num = self.selectConfig_.DashSpeedRate * 1.5 / 100 .. "%"
    }
  })
  self:refreshSkill()
end

function Vehicle_mainView:btnState()
  if self.selectConfig_ then
    local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_adorn, 0 < count)
    if count == 0 then
      self.uiBinder.btn_unequip.lab_normal.text = Lang("NotObtained")
    elseif self.vehicleVM_.IsEquip(self.selectConfig_.Id) then
      self.uiBinder.btn_unequip.lab_normal.text = Lang("Remove")
    else
      self.uiBinder.btn_unequip.lab_normal.text = Lang("Assemble")
    end
  end
end

function Vehicle_mainView:SetSelectId(id, isRefreshLoop)
  if self.selectVehicleId == id then
    return
  end
  self.selectVehicleId = id
  self.selectConfig_ = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(self.selectVehicleId)
  self:refreshModels()
  if isRefreshLoop then
    self:refreshLoopList()
  end
  self:refreshLeftInfo()
  self:btnState()
  self.functionSearchData_ = self.itemSourceVm_.GetItemSource(self.selectVehicleId)[1]
  if self.functionSearchData_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, true)
    self.uiBinder.lab_info.text = string.format(Lang("FashionSource"), self.functionSearchData_.name)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_mount, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_mount, false)
  end
end

function Vehicle_mainView:refreshModels()
  local vehicleActionPreviewConfig = Z.TableMgr.GetTable("VehicleActionPreviewTableMgr").GetRow(self.selectVehicleId)
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  self.curShowModel_ = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_, self.selectConfig_.ModelID, function(model)
    model:SetAttrGoPosition(self.modelPosition_)
    model:SetAttrGoRotation(rotation)
    model:SetLuaAttrGoScale(self.selectConfig_.UIModelScale)
    if self.isShowPlayModel_ then
      model:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(vehicleActionPreviewConfig.RunAction))
    else
      model:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(vehicleActionPreviewConfig.IdleAction))
    end
  end)
end

function Vehicle_mainView:refreshInfo()
  table.sort(self.allVehicles_, function(a, b)
    local aCount = self.itemsVM_.GetItemTotalCount(a.Id)
    local bCount = self.itemsVM_.GetItemTotalCount(b.Id)
    if aCount == bCount then
      local aState = self.vehicleVM_.IsEquip(a.Id) and 0 or 1
      local bState = self.vehicleVM_.IsEquip(b.Id) and 0 or 1
      if aState == bState then
        if a.SortId == b.SortId then
          return a.Id < b.Id
        else
          return a.SortId < b.SortId
        end
      else
        return aState < bState
      end
    else
      return aCount > bCount
    end
  end)
  self:refreshLoopList()
  self:refreshLeftInfo()
  self:btnState()
end

function Vehicle_mainView:onUnrealsceneBeginDrag(eventData)
  self.curShowModelRotation_ = self.curShowModel_:GetAttrGoRotation().eulerAngles
end

function Vehicle_mainView:onUnrealsceneDrag(eventData)
  self.curShowModelRotation_.y = self.curShowModelRotation_.y - eventData.delta.x
  self.curShowModel_:SetAttrGoRotation(Quaternion.Euler(self.curShowModelRotation_))
end

function Vehicle_mainView:onUnrealsceneEndDrag(eventData)
end

return Vehicle_mainView
