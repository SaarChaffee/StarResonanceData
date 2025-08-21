local UI = Z.UI
local super = require("ui.ui_view_base")
local Vehicle_mainView = class("Vehicle_mainView", super)
local loopListView = require("ui/component/loop_list_view")
local loopGridView = require("ui/component/loop_grid_view")
local vehicleArticleItemTplItem = require("ui/component/vehicle/vehicle_article_item_tpl_item")
local vehicleMainItemTplItem = require("ui/component/vehicle/vehicle_main_item_tpl_item")
local vehicleMainSkinItemTplItem = require("ui/component/vehicle/vehicle_main_skin_item_tpl_item")
local vehicleMainUnlockItem = require("ui/component/vehicle/vehicle_main_unlock_item")
local vehicleDefine = require("ui.model.vehicle_define")

function Vehicle_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "vehicle_main")
  self.allVehicles_ = nil
  self.selectConfig_ = nil
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
  self.vehicleData_ = Z.DataMgr.Get("vehicle_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  
  function self.vehicleSortFunc_(a, b)
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
  end
end

function Vehicle_mainView:OnActive()
  self:onStartAnimShow()
  self:AddAsyncClick(self.uiBinder.btn_unequip.btn, function()
    local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
    if count == 0 then
      Z.TipsVM.ShowTipsLang(1000903)
      return
    end
    local isEquip, type = self.vehicleVM_.IsEquip(self.selectConfig_.Id)
    local vehicleId = self.selectConfig_.Id
    if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
      vehicleId = self.selectConfig_.ParentId
    end
    if isEquip then
      self.vehicleVM_.AsyncTakeOffRide(vehicleId, self.cancelSource:CreateToken())
    else
      self.vehicleVM_.AsyncTakeOnRide(self.selectConfig_.PropertyId[2], vehicleId, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    if self.isShowSkin_ then
      self.isShowSkin_ = false
      self:refreshRightInfo(true)
    else
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(7050)
  end)
  self:AddAsyncClick(self.uiBinder.btn_info, function()
    if self.functionSearchData_ then
      self.itemSourceVm_.JumpToSource(self.functionSearchData_)
    end
  end)
  self:AddAsyncClick(self.uiBinder.node_skin.btn_info, function()
    if self.functionSearchData_ then
      self.itemSourceVm_.JumpToSource(self.functionSearchData_)
    end
  end)
  self:AddAsyncClick(self.uiBinder.node_skin.btn_skin.btn, function()
    local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
    if count == 0 then
      if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
        local originalCount = self.itemsVM_.GetItemTotalCount(self.selectConfig_.ParentId)
        if originalCount == 0 then
          Z.TipsVM.ShowTips(1000912)
          return
        end
      end
      if self.selectConfig_.UnlockCostItem ~= nil and #self.selectConfig_.UnlockCostItem == 2 then
        local itemCount = self.itemsVM_.GetItemTotalCount(self.selectConfig_.UnlockCostItem[1])
        if itemCount >= self.selectConfig_.UnlockCostItem[2] then
          self.vehicleVM_.AsyncTakeOnActivateRideSkin(self.selectConfig_.Id, self.cancelSource:CreateToken())
        else
          Z.TipsVM.ShowTips(100002)
        end
      end
    elseif self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
      local originalCount = self.itemsVM_.GetItemTotalCount(self.selectConfig_.ParentId)
      if 0 < originalCount then
        local equipSkinId = self.vehicleVM_.GetEquipSkinId(self.selectConfig_.ParentId)
        if equipSkinId ~= self.selectConfig_.Id then
          self.vehicleVM_.AsyncTakeOnSetRideSkin(self.selectConfig_.Id, self.cancelSource:CreateToken())
        end
      else
        Z.TipsVM.ShowTips(1000913)
      end
    else
      local equipSkinId = self.vehicleVM_.GetEquipSkinId(self.selectConfig_.Id)
      if equipSkinId ~= self.selectConfig_.Id then
        self.vehicleVM_.AsyncTakeOnSetRideSkin(self.selectConfig_.Id, self.cancelSource:CreateToken())
      end
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
  self:AddClick(self.uiBinder.btn_custom, function()
    self.isShowSkin_ = true
    self:refreshRightInfo(true)
  end)
  self:AddAsyncClick(self.uiBinder.btn_member, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.CollectionVipLevel)
  end)
  local functionRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.Vehicle)
  if functionRow then
    self.uiBinder.lab_title.text = functionRow.Name
  else
    self.uiBinder.lab_title.text = ""
  end
  if Z.IsPCUI then
    self.listItem_ = loopListView.new(self, self.uiBinder.loop_item_article, vehicleArticleItemTplItem, "vehicle_article_item_tpl_pc")
    self.listItem_:Init({})
    self.gridVehicle_ = loopGridView.new(self, self.uiBinder.loop_item, vehicleMainItemTplItem, "vehicle_main_item_tpl_pc")
    self.gridVehicle_:Init({})
    self.listSkinItem_ = loopListView.new(self, self.uiBinder.node_skin.loop_item_skin, vehicleMainSkinItemTplItem, "vehicle_skin_item_tpl_pc")
    self.listSkinItem_:Init({})
    self.unlockItem_ = loopListView.new(self, self.uiBinder.node_skin.loop_item, vehicleMainUnlockItem, "com_item_square_3_8_pc")
    self.unlockItem_:Init({})
  else
    self.listItem_ = loopListView.new(self, self.uiBinder.loop_item_article, vehicleArticleItemTplItem, "vehicle_article_item_tpl")
    self.listItem_:Init({})
    self.gridVehicle_ = loopGridView.new(self, self.uiBinder.loop_item, vehicleMainItemTplItem, "vehicle_main_item_tpl")
    self.gridVehicle_:Init({})
    self.listSkinItem_ = loopListView.new(self, self.uiBinder.node_skin.loop_item_skin, vehicleMainSkinItemTplItem, "vehicle_skin_item_tpl")
    self.listSkinItem_:Init({})
    self.unlockItem_ = loopListView.new(self, self.uiBinder.node_skin.loop_item, vehicleMainUnlockItem, "com_item_square_3_8")
    self.unlockItem_:Init({})
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isFuncOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.CollectionVipLevel, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_member, isFuncOn)
  isFuncOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.CollectionReward, true)
  self.uiBinder.collection_top_schedule.Ref.UIComp:SetVisible(isFuncOn)
  self.propertyUnits_ = {}
  self.skillUnits_ = {}
  self.curShowModel_ = nil
  self.allVehicles_ = {}
  self.isShowPlayModel_ = false
  self.isShowSkin_ = false
  self.selectConfig_ = nil
  self.functionSearchData_ = nil
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self.modelPosition_ = Z.UnrealSceneMgr:GetTransPos("pos")
  Z.EventMgr:Add(Z.ConstValue.Vehicle.EquipVehicle, self.refreshInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UnEquipVehicle, self.refreshInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.OnActiveRideSkin, self.refreshSkinInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.SetRideSkin, self.refreshSkinInfo, self)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionCollectionScoreRewardRed, self, self.uiBinder.collection_top_schedule.node_red)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionCollectionWindowRed, self, self.uiBinder.btn_member.transform)
  Z.UnrealSceneMgr:SetCacheTextureName("sky", 0, "_MainTex", Z.ConstValue.UnrealSceneBgPath.VehicleDefaultBg)
end

function Vehicle_mainView:OnDeActive()
  Z.UIMgr:CloseView("vehicle_tips")
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionCollectionScoreRewardRed)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionCollectionWindowRed)
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.EquipVehicle, self.refreshInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.UnEquipVehicle, self.refreshInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.OnActiveRideSkin, self.refreshSkinInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.SetRideSkin, self.refreshSkinInfo, self)
  self.selectConfig_ = nil
  if self.listItem_ then
    self.listItem_:UnInit()
    self.listItem_ = nil
  end
  if self.gridVehicle_ then
    self.gridVehicle_:UnInit()
    self.gridVehicle_ = nil
  end
  if self.listSkinItem_ then
    self.listSkinItem_:UnInit()
    self.listSkinItem_ = nil
  end
  if self.unlockItem_ then
    self.unlockItem_:UnInit()
    self.unlockItem_ = nil
  end
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  self:clearPropertyUnits()
  self:clearSkillUnits()
end

function Vehicle_mainView:OnRefresh()
  Z.CollectionScoreHelper.RefreshCollectionScore(self.uiBinder.collection_top_schedule)
  self.allVehicles_ = self.vehicleData_:GetVehicleConfigs()
  table.sort(self.allVehicles_, self.vehicleSortFunc_)
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
  local viewData = {
    vehicleId = self.selectConfig_.Id
  }
  return viewData
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
          do
            local config = mgr.GetRow(property)
            if config then
              unit.img_icon:SetImage(config.Icon)
            end
            self.propertyUnits_[property] = name
            unit.btn_icon:RemoveAllListeners()
            unit.btn_icon:AddListener(function()
              self.vehicleVM_.OpenPopView(self.selectConfig_.Id, vehicleDefine.PopType.Property, unit.Trans)
            end)
          end
        end
      end
    end)()
  end
end

function Vehicle_mainView:clearSkillUnits()
  for _, unitName in pairs(self.skillUnits_) do
    self:RemoveUiUnit(unitName)
  end
  self.skillUnits_ = {}
end

function Vehicle_mainView:refreshSkill()
  self:clearSkillUnits()
  if self.selectConfig_ then
    Z.CoroUtil.create_coro_xpcall(function()
      local mgr = Z.TableMgr.GetTable("SkillTableMgr")
      local path = self.uiBinder.prefab_cache:GetString("skill_item")
      local skills = {}
      local skillsCount = 0
      for _, skill in ipairs(self.selectConfig_.VehSkillIds) do
        if skill[2] then
          skillsCount = skillsCount + 1
          skills[skillsCount] = skill[2]
        end
      end
      for _, skill in ipairs(self.selectConfig_.PassiveSkillId) do
        skillsCount = skillsCount + 1
        skills[skillsCount] = skill
      end
      if skillsCount == 0 then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill, false)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill, true)
        for _, skill in ipairs(skills) do
          local name = "skill" .. skill
          local unit = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_skill)
          if unit then
            local config = mgr.GetRow(skill)
            if config then
              unit.img_icon:SetImage(config.Icon)
            end
            self.skillUnits_[skill] = name
            unit.btn_icon:RemoveAllListeners()
            unit.btn_icon:AddListener(function()
              self.vehicleVM_.OpenPopView(self.selectConfig_.Id, vehicleDefine.PopType.Skill, self.uiBinder.Trans)
            end)
          end
        end
      end
    end)()
  end
end

function Vehicle_mainView:refreshLeftInfo()
  if self.selectConfig_ then
    self.uiBinder.lab_name.text = self.selectConfig_.Name
    self.uiBinder.lab_score.text = self.selectConfig_.Score
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

function Vehicle_mainView:SetSelectId(id, isRefreshLoop)
  if self.selectConfig_ ~= nil and (self.selectConfig_.Id == id or self.selectConfig_.ParentId == id) then
    return
  end
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.btn_custom.transform, self)
  id = self.vehicleVM_.GetEquipSkinId(id)
  self.selectConfig_ = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(id)
  if self.selectConfig_ == nil then
    return
  end
  self.functionSearchData_ = self.itemSourceVm_.GetItemSource(self.selectConfig_.Id)[1]
  if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
    Z.RedPointMgr.LoadRedDotItem(self.vehicleVM_.GetRedNodeId(self.selectConfig_.ParentId), self, self.uiBinder.btn_custom.transform)
  else
    Z.RedPointMgr.LoadRedDotItem(self.vehicleVM_.GetRedNodeId(self.selectConfig_.Id), self, self.uiBinder.btn_custom.transform)
  end
  self:refreshModels()
  self:refreshLeftInfo()
  self:refreshRightInfo(isRefreshLoop)
end

function Vehicle_mainView:SetSelectSkinId(id, isRefreshLoop)
  if self.selectConfig_.Id == id then
    return
  end
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.node_skin.btn_skin.Trans, self)
  self.selectConfig_ = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(id)
  if self.selectConfig_ == nil then
    return
  end
  self.functionSearchData_ = self.itemSourceVm_.GetItemSource(self.selectConfig_.Id)[1]
  if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
    Z.RedPointMgr.LoadRedDotItem(self.vehicleVM_.GetRedNodeId(self.selectConfig_.Id), self, self.uiBinder.node_skin.btn_skin.Trans)
  end
  self:refreshModels()
  self:refreshLeftInfo()
  self:refreshRightInfo(isRefreshLoop)
end

function Vehicle_mainView:refreshRightInfo(isRefreshLoop)
  if self.isShowSkin_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
    self.uiBinder.node_skin.Ref.UIComp:SetVisible(true)
    self:refreshRightVehicleSkinLoop(isRefreshLoop)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, true)
    self.uiBinder.node_skin.Ref.UIComp:SetVisible(false)
    self:refreshRightVehicleLoop(isRefreshLoop)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_custom, not self.isShowSkin_)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function Vehicle_mainView:refreshLoopList()
  local index = 1
  local selectVehicleId = self.selectConfig_.Id
  if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
    selectVehicleId = self.selectConfig_.ParentId
  end
  for k, v in ipairs(self.allVehicles_) do
    if v.Id == selectVehicleId then
      index = k
      break
    end
  end
  self.gridVehicle_:RefreshListView(self.allVehicles_)
  self.gridVehicle_:SetSelected(index)
end

function Vehicle_mainView:refreshBtnState()
  if self.selectConfig_ then
    local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
    if count == 0 then
      self.uiBinder.btn_unequip.lab_normal.text = Lang("NotObtained")
    elseif self.vehicleVM_.IsEquip(self.selectConfig_.Id) then
      self.uiBinder.btn_unequip.lab_normal.text = Lang("Remove")
    else
      self.uiBinder.btn_unequip.lab_normal.text = Lang("Assemble")
    end
  end
end

function Vehicle_mainView:refreshRightVehicleLoop(isRefreshLoop)
  if isRefreshLoop then
    self:refreshLoopList()
  end
  self:refreshBtnState()
  if self.functionSearchData_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, true)
    self.uiBinder.lab_info.text = string.format(Lang("FashionSource"), self.functionSearchData_.name)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, self.selectConfig_.ParentId == nil or self.selectConfig_.ParentId == 0)
  end
end

function Vehicle_mainView:refreshSkillLoopList()
  local baseVehicleId = self.selectConfig_.Id
  if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
    baseVehicleId = self.selectConfig_.ParentId
  end
  local allSkinsConfig = self.vehicleData_:GetVehicleSkins(baseVehicleId)
  table.sort(allSkinsConfig, function(a, b)
    if a.SortId == b.SortId then
      return a.Id < b.Id
    else
      return a.SortId < b.SortId
    end
  end)
  local index = 1
  for k, v in ipairs(allSkinsConfig) do
    if v.Id == self.selectConfig_.Id then
      index = k
      break
    end
  end
  self.listSkinItem_:RefreshListView(allSkinsConfig)
  self.listSkinItem_:SetSelected(index)
end

function Vehicle_mainView:refreshUnlockItems()
  local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
  if count == 0 and self.selectConfig_.UnlockCostItem ~= nil and #self.selectConfig_.UnlockCostItem == 2 then
    self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.node_unlock, true)
    if Z.IsPCUI then
      self.uiBinder.node_skin.rect_item_skin:SetSizeDelta(372, -256)
    else
      self.uiBinder.node_skin.rect_item_skin:SetSizeDelta(452, -176)
    end
    local datas = {
      [1] = {
        configId = self.selectConfig_.UnlockCostItem[1],
        count = self.selectConfig_.UnlockCostItem[2]
      }
    }
    self.unlockItem_:RefreshListView(datas)
  else
    self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.node_unlock, false)
    if Z.IsPCUI then
      self.uiBinder.node_skin.rect_item_skin:SetSizeDelta(372, 0)
    else
      self.uiBinder.node_skin.rect_item_skin:SetSizeDelta(452, 0)
    end
  end
end

function Vehicle_mainView:refreshSkillBtnState()
  if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 and self.itemsVM_.GetItemTotalCount(self.selectConfig_.ParentId) == 0 then
    self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.btn_info, false)
    self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.img_bg, false)
    self.uiBinder.node_skin.btn_skin.Ref.UIComp:SetVisible(true)
    self.uiBinder.node_skin.btn_skin.btn.IsDisabled = true
    self.uiBinder.node_skin.btn_skin.lab_normal.text = Lang("UnlockBaseVehicle")
  else
    local count = self.itemsVM_.GetItemTotalCount(self.selectConfig_.Id)
    if count == 0 then
      if self.selectConfig_.UnlockCostItem ~= nil and #self.selectConfig_.UnlockCostItem == 2 then
        self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.btn_info, false)
        self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.img_bg, false)
        self.uiBinder.node_skin.btn_skin.Ref.UIComp:SetVisible(true)
        local itemCount = self.itemsVM_.GetItemTotalCount(self.selectConfig_.UnlockCostItem[1])
        self.uiBinder.node_skin.btn_skin.lab_normal.text = Lang("FashionLook")
        if itemCount >= self.selectConfig_.UnlockCostItem[2] then
          self.uiBinder.node_skin.btn_skin.btn.IsDisabled = false
        else
          self.uiBinder.node_skin.btn_skin.btn.IsDisabled = true
        end
      else
        self.uiBinder.node_skin.btn_skin.Ref.UIComp:SetVisible(false)
        if self.functionSearchData_ then
          self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.btn_info, true)
          self.uiBinder.node_skin.lab_info.text = string.format(Lang("FashionSource"), self.functionSearchData_.name)
          self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.img_bg, false)
        else
          self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.btn_info, false)
          self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.img_bg, true)
        end
      end
    else
      self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.btn_info, false)
      self.uiBinder.node_skin.Ref:SetVisible(self.uiBinder.node_skin.img_bg, false)
      self.uiBinder.node_skin.btn_skin.Ref.UIComp:SetVisible(true)
      local baseVehicleId = self.selectConfig_.Id
      if self.selectConfig_.ParentId and self.selectConfig_.ParentId ~= 0 then
        baseVehicleId = self.selectConfig_.ParentId
      end
      local equipSkinId = self.vehicleVM_.GetEquipSkinId(baseVehicleId)
      if equipSkinId == self.selectConfig_.Id then
        self.uiBinder.node_skin.btn_skin.btn.IsDisabled = true
        self.uiBinder.node_skin.btn_skin.lab_normal.text = Lang("InUse")
      else
        self.uiBinder.node_skin.btn_skin.btn.IsDisabled = false
        self.uiBinder.node_skin.btn_skin.lab_normal.text = Lang("Use")
      end
    end
  end
end

function Vehicle_mainView:refreshRightVehicleSkinLoop(isRefreshLoop)
  if isRefreshLoop then
    self:refreshSkillLoopList()
  end
  self:refreshUnlockItems()
  self:refreshSkillBtnState()
end

function Vehicle_mainView:refreshModels()
  local vehicleActionPreviewConfig = Z.TableMgr.GetTable("VehicleActionPreviewTableMgr").GetRow(self.selectConfig_.Id)
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  if vehicleActionPreviewConfig == nil then
    return
  end
  self.curShowModel_ = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_, self.selectConfig_.ModelID, function(model)
    local posOffsetAdd = Vector3.New(0, vehicleActionPreviewConfig.UIModelPositionY, 0)
    model:SetAttrGoPosition(self.modelPosition_ + posOffsetAdd)
    local rotation = Quaternion.Euler(Vector3.New(0, vehicleActionPreviewConfig.UIModelRotationY, 0))
    model:SetAttrGoRotation(rotation)
    model:SetLuaAttrGoScale(vehicleActionPreviewConfig.UIModelScale)
    if self.isShowPlayModel_ then
      model:SetLuaAttrModelPreloadClip(vehicleActionPreviewConfig.RunAction)
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(vehicleActionPreviewConfig.RunAction))
    else
      model:SetLuaAttrModelPreloadClip(vehicleActionPreviewConfig.IdleAction)
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(vehicleActionPreviewConfig.IdleAction))
    end
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    local path = self.selectConfig_.UnrealSceneBg
    if string.zisEmpty(path) then
      path = Z.ConstValue.UnrealSceneBgPath.VehicleDefaultBg
    end
    Z.UnrealSceneMgr:ChangeBinderGOTexture("sky", 0, "_MainTex", path, self.cancelSource:CreateToken())
  end)()
end

function Vehicle_mainView:refreshInfo()
  table.sort(self.allVehicles_, self.vehicleSortFunc_)
  self:refreshRightVehicleLoop(true)
end

function Vehicle_mainView:refreshSkinInfo()
  Z.CollectionScoreHelper.RefreshCollectionScore(self.uiBinder.collection_top_schedule)
  self:refreshRightVehicleSkinLoop(true)
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

function Vehicle_mainView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Vehicle_mainView
