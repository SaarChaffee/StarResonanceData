local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_lamplight_subView = class("Home_editor_lamplight_subView", super)
local loopListView = require("ui/component/loop_list_view")
local homeLightLoopItem = require("ui.component.home.home_light_loop_item")
local toggleGroup = require("ui/component/togglegroup")
local envGridItem = require("ui.component.home.home_env_grid_item")
local colorPalette = require("ui/component/color_palette/color_palette")
local colorItemHandler = require("ui/component/color_palette/face_color_item_handler")

function Home_editor_lamplight_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "home_editor_lamplight_sub", "home_editor/home_editor_lamplight_sub", UI.ECacheLv.None)
  self.homeEditorVm_ = Z.VMMgr.GetVM("home_editor")
  self.homeEditorData_ = Z.DataMgr.Get("home_editor_data")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.lightData_ = {}
  self.envData_ = {}
  self.levelSliderValue_ = 0
  self.selectEnvId_ = 0
  self.colorPalette_ = colorPalette.new(self, colorItemHandler.new(self))
end

function Home_editor_lamplight_subView:OnActive()
  self.uiBinder.view_rect:SetSizeDelta(0, 0)
  self.loopListLight_ = self.uiBinder.loop_list_light
  self.nodeEnvGrid_ = self.uiBinder.node_env_grid
  self.nodeColor_ = self.uiBinder.node_color
  self.nodeEnv_ = self.uiBinder.node_env
  self.nodePalette_ = self.uiBinder.node_palette
  self.nodeColorTop_ = self.uiBinder.node_color_top
  self.nodeColorInputTop_ = self.uiBinder.node_color_input_top
  self.nodeColorEmptyTop_ = self.uiBinder.node_color_empty_top
  self.imgColorTop_ = self.uiBinder.img_color_top
  self.toggleEnv_ = self.uiBinder.toggle_env
  self.toggleBinder_ = self.uiBinder.toggle_group
  self.lightSlider_ = self.uiBinder.slider_light
  self.btnCloseAll_ = self.uiBinder.btn_close_all
  self.btnOpenAll_ = self.uiBinder.btn_open_all
  self.btnPalettle_ = self.uiBinder.btn_palettle
  self.inputColorTop_ = self.uiBinder.input_color_top
  self.showPallatte_ = true
  self.lightLoopListView_ = loopListView.new(self, self.loopListLight_, homeLightLoopItem, "home_editor_home_lamplight_item_tpl")
  self.lightLoopListView_:Init({})
  self.lightSlider_:AddDragEndListener(function()
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    if self.levelSliderValue_ ~= self.lightSlider_.value then
      self.levelSliderValue_ = self.lightSlider_.value
      logGreen("self.lightSlider_.value = {0}", self.lightSlider_.value)
      Z.CoroUtil.create_coro_xpcall(function()
        local value = math.floor(self.lightSlider_.value * 1000)
        self.homeEditorVm_.AsyncSetLamplightLevel(value)
      end)()
    end
  end)
  self.lightSlider_:AddListener(function(value)
    if not self.houseData_:CheckPlayerFurnitureEditLimit() then
      return
    end
    local envMode = self.houseData_:GetHouseLightMode()
    if envMode == E.HomeEnvMode.EnvColor then
      Z.DIServiceMgr.HomeService:PreviewLampLightLevel(value)
    end
  end)
  self:AddAsyncClick(self.btnCloseAll_, function()
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    self.homeEditorVm_.AsyncSwitchAllLamplight(E.HomelandLamplightState.HomelandLamplightStateOff)
  end)
  self:AddAsyncClick(self.btnOpenAll_, function()
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    self.homeEditorVm_.AsyncSwitchAllLamplight(E.HomelandLamplightState.HomelandLamplightStateOn)
  end)
  self:AddAsyncClick(self.toggleEnv_, function(isOn)
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    if isOn then
      self.homeEditorVm_.AsyncSetLamplightModel(E.HomeEnvMode.EnvColor)
    else
      self.homeEditorVm_.AsyncSetLamplightModel(E.HomeEnvMode.EnvPrefab)
    end
  end)
  self:AddClick(self.btnPalettle_, function()
    self.showPallatte_ = not self.showPallatte_
    self.nodePalette_.gameObject:SetActive(self.showPallatte_)
    self.uiBinder.Ref:SetVisible(self.nodeColorTop_, not self.showPallatte_)
  end)
  self.colorPalette_:Init(self.uiBinder.cont_palette, Z.IsPCUI)
  self.colorPalette_:SetColorEndChangeCB(function(hsv)
    if not self.houseData_:CheckPlayerFurnitureEditLimit(true) then
      return
    end
    if self.colorPaletteColor_ then
      Z.CoroUtil.create_coro_xpcall(function()
        local vec3 = {
          x = self.colorPaletteColor_.h,
          y = self.colorPaletteColor_.s,
          z = self.colorPaletteColor_.v
        }
        self.homeEditorVm_.AsyncSetLamplightColor(vec3)
      end)()
    end
  end)
  self.colorPaletteColor_ = nil
  self.colorPalette_:SetColorChangeCB(function(hsv)
    if not self.houseData_:CheckPlayerFurnitureEditLimit() then
      return
    end
    self.colorPaletteColor_ = hsv
    Z.DIServiceMgr.HomeService:PreviewLampLightColor(hsv.h, hsv.s, hsv.v)
  end)
  Z.EventMgr:Add(Z.ConstValue.Home.DecorationInfoUpdate, self.OnDecorationInfoUpdate, self)
  Z.EventMgr:Add(Z.ConstValue.Home.HomeEntityStructureUpdate, self.OnStructureUpdate, self)
end

function Home_editor_lamplight_subView:OnDeActive()
  self.lightSlider_:RemoveAllListeners()
  if self.lightLoopListView_ then
    self.lightLoopListView_:UnInit()
    self.lightLoopListView_ = nil
  end
  if self.toggleGroup_ then
    self.toggleGroup_:UnInit()
    self.toggleGroup_ = nil
  end
  self.colorPalette_:UnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function Home_editor_lamplight_subView:OnDecorationInfoUpdate()
  self:refreshEnvUI()
  self:refreshEnvColorUI()
end

function Home_editor_lamplight_subView:OnStructureUpdate()
  self:refreshLightUI()
end

function Home_editor_lamplight_subView:OnRefresh()
  self:refreshLightUI()
  self:refreshEnvUI()
  self:refreshEnvColorUI()
end

function Home_editor_lamplight_subView:OnSelectEnvItem(data)
  if self.selectEnvId_ == data.id then
    return
  end
  self.selectEnvId_ = data.id
  Z.CoroUtil.create_coro_xpcall(function()
    self.homeEditorVm_.AsyncSetEvnId(data.id)
  end)()
end

function Home_editor_lamplight_subView:refreshEnvUI()
  local lightTable = Z.TableMgr.GetTable("HomeEnvironmentLightTableMgr").GetDatas()
  local curId = self.houseData_:GetHouseEnvId()
  self.selectEnvId_ = curId
  local isOnIndex = 0
  local index = 0
  self.envData_ = {}
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  local isInner = currentStageType == Z.EStageType.HomelandDungeon
  local envType = isInner and E.HomeEnvLightType.Static or E.HomeEnvLightType.Dynamic
  for id, row in pairs(lightTable) do
    if row.Type == envType then
      index = index + 1
      local isOn = id == curId
      if isOn then
        isOnIndex = index
        self.lightSlider_.minValue = row.Parameter[2]
        self.lightSlider_.maxValue = row.Parameter[3]
        local lightLevel = self.houseData_:GetHouseLightLevel()
        if lightLevel == 0 then
          lightLevel = row.Parameter[1]
        end
        self.lightSlider_.value = lightLevel
      end
      local data = {
        id = id,
        name = row.Name,
        isOn = isOn
      }
      table.insert(self.envData_, data)
    end
  end
  local envMode = self.houseData_:GetHouseLightMode()
  local showPrefab = envMode == E.HomeEnvMode.EnvPrefab
  if showPrefab then
    self.uiBinder.img_type_bg:SetImage(GetLoadAssetPath("TitleBg1"))
    if 0 < #self.envData_ then
      self:clearToggleGroup()
      self.toggleGroup_ = toggleGroup.new(self.toggleBinder_, envGridItem, self.envData_, self)
      self.toggleGroup_:Init(isOnIndex, function(index)
        local envMode = self.houseData_:GetHouseLightMode()
        if envMode == E.HomeEnvMode.EnvPrefab then
          self:OnSelectEnvItem(self.envData_[index])
        end
      end)
    end
  else
    self.uiBinder.img_type_bg:SetImage(GetLoadAssetPath("TitleBg2"))
    self:clearToggleGroup()
  end
end

function Home_editor_lamplight_subView:clearToggleGroup()
  if self.toggleGroup_ then
    self.toggleGroup_:UnInit()
    self.toggleGroup_ = nil
  end
end

function Home_editor_lamplight_subView:refreshEnvColorUI()
  self.uiBinder.Ref:SetVisible(self.nodeColorTop_, not self.showPallatte_)
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  local isInner = currentStageType == Z.EStageType.HomelandDungeon
  self.nodeEnv_.gameObject:SetActive(isInner)
  if isInner then
    local envMode = self.houseData_:GetHouseLightMode()
    local showColor = envMode == E.HomeEnvMode.EnvColor
    if showColor then
      self.uiBinder.img_env_bg:SetImage(GetLoadAssetPath("TitleBg1"))
    else
      self.uiBinder.img_env_bg:SetImage(GetLoadAssetPath("TitleBg2"))
    end
    self.toggleEnv_:SetIsOnWithoutCallBack(showColor)
    self.toggleEnv_.IsDisabled = not self.houseData_:CheckPlayerFurnitureEditLimit()
    self.nodeColor_.gameObject:SetActive(showColor)
    if showColor then
      self.colorPalette_:RefreshPaletteByColorGroupId(Z.GlobalHome.HomeEnvironmentColorGroupId)
      local serverColor = self.houseData_:GetHouseEnvColor()
      local row = self.colorPalette_:GetColorConfigRow()
      local defaultColor = self:getDefaultColor(row)
      self.colorPalette_:SetDefaultColor(defaultColor, true)
      if serverColor then
        self.colorPalette_:SetServerColor(serverColor, true)
        self.colorPalette_:SelectItemByHSVWithoutNotify(serverColor)
      else
        self.colorPalette_:SelectItemByHSVWithoutNotify(defaultColor)
      end
      self.inputColorTop_.text = self.colorPalette_.uiBinder.input_color.text
      local rgbColor = self.colorPalette_:GetRGBColor()
      self.imgColorTop_:SetColor(rgbColor)
    end
  end
end

function Home_editor_lamplight_subView:getDefaultColor(row)
  local h = 0
  local s = 0
  local v = 0
  if row.Hue[1] ~= nil then
    h = row.Hue[1][1]
  end
  if row.Saturation[1] ~= nil then
    s = row.Saturation[1][1]
  end
  if row.Value[1] ~= nil then
    v = row.Value[1][1]
  end
  return {
    h = h,
    s = s,
    v = v
  }
end

function Home_editor_lamplight_subView:refreshLightUI()
  self.lightData_ = {}
  local houseItemMap = self.homeEditorData_:GetHouseItemList()
  for itemId, uIds in pairs(houseItemMap) do
    local typeGroupId = self.homeEditorVm_.GetItemGroupType(itemId)
    if typeGroupId == tonumber(E.HousingItemGroupType.HousingItemGroupTypeLampLight) then
      for _, uid in ipairs(uIds) do
        local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
        local structure = Z.DIServiceMgr.HomeService:GetHouseItemStructure(uid)
        local lightState
        if structure.lamplightInfo then
          lightState = structure.lamplightInfo.state
        end
        local data = {
          uuid = uid,
          name = structure.name ~= "" and structure.name or itemCfg.Name,
          icon = itemCfg.Icon,
          state = lightState
        }
        table.insert(self.lightData_, data)
      end
    end
  end
  logGreen(table.ztostring(self.lightData_))
  self.lightLoopListView_:RefreshListView(self.lightData_)
end

return Home_editor_lamplight_subView
