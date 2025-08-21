local UI = Z.UI
local super = require("ui.ui_subview_base")
local Life_profession_screening_right_subView = class("Life_profession_screening_right_subView", super)
local keyPad = require("ui.view.cont_num_keyboard_view")

function Life_profession_screening_right_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "life_profession_screening_right_sub", "life_profession/life_profession_screening_right_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "life_profession_screening_right_sub", "life_profession/life_profession_screening_right_sub", UI.ECacheLv.None)
  end
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
end

function Life_profession_screening_right_subView:OnActive()
  self.uiBinder.Trans.sizeDelta = Vector2.zero
  self.proID = self.viewData.proID
  self.closeFunc = self.viewData.closeFunc
  self:initBtnClick()
  self:InitLevelFilter()
  self:RefreshLevelFilter()
  self:refreshSlider()
  self.sceneFilterDatas = self.lifeProfessionData_:GetFilterSceneDatas(self.proID)
  self:refreshSceneNode()
  self.filterTypeDatas = self.lifeProfessionData_:GetFilterTypeDatas(self.proID)
  self:refreshTypeNode()
  self.filterConsume_, self.filterNoConsume_ = self.lifeProfessionData_:GetFilterConsume(self.proID)
  self:refreshConsumeNode()
  self.levelCondition, self.speCondition, self.otherCondition = self.lifeProfessionData_:GetFilterConditionDatas(self.proID)
  self:refreshConditionNode()
  self.keypad_ = keyPad.new(self)
  self.uiBinder.lab_level.text = Lang("LifeProfessionScreenLevel")
end

function Life_profession_screening_right_subView:InitLevelFilter()
  self.minLevel = 1
  self.maxLevel = self.lifeProfessionData_:GetProfessionMaxLevel(self.proID)
  self.curFilterMinLevel, self.curFilterMaxLevel = self.lifeProfessionData_:GetFilterLevel(self.proID)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_num_min, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_num_max, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_min, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_max, false)
  self:AddClick(self.uiBinder.btn_num_min, function()
    self.keypad_:Active({
      max = self.curFilterMaxLevel,
      min = self.minLevel
    }, self.uiBinder.group_keypadroot_min)
    self.curIsMin = true
    self.curIsMax = false
  end)
  self:AddClick(self.uiBinder.btn_num_max, function()
    self.keypad_:Active({
      max = self.maxLevel,
      min = self.curFilterMinLevel
    }, self.uiBinder.group_keypadroot_max)
    self.curIsMin = false
    self.curIsMax = true
  end)
  self.uiBinder.node_silder:AddListener(function(maxProgress, minProgress)
    self:refreshSliderProgress(maxProgress, minProgress)
  end)
end

function Life_profession_screening_right_subView:RefreshLevelFilter()
  self.uiBinder.input_min.text = self.curFilterMinLevel
  self.uiBinder.input_max.text = self.curFilterMaxLevel
  self.uiBinder.lab_num_min.text = self.curFilterMinLevel
  self.uiBinder.lab_num_max.text = self.curFilterMaxLevel
end

function Life_profession_screening_right_subView:initBtnClick()
  self:AddClick(self.uiBinder.btn_confirm, function()
    self:OnConfirmBtnClick()
    if self.closeFunc then
      self.closeFunc()
    end
  end)
  self:AddClick(self.uiBinder.btn_reset, function()
    self:OnResetBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    if self.closeFunc then
      self.closeFunc()
    end
  end)
end

function Life_profession_screening_right_subView:OnConfirmBtnClick()
  self.lifeProfessionData_:SetFilterSceneDatas(self.proID, self.sceneFilterDatas)
  self.lifeProfessionData_:SetFilterLevel(self.proID, self.curFilterMinLevel, self.curFilterMaxLevel)
  self.lifeProfessionData_:SetFilterTypeDatas(self.proID, self.filterTypeDatas)
  self.lifeProfessionData_:SetFilterConditionDatas(self.proID, self.levelCondition, self.speCondition, self.otherCondition)
  self.lifeProfessionData_:SetFilterConsume(self.proID, self.filterConsume_, self.filterNoConsume_)
  self.baseViewBinder:RefreshInfo()
end

function Life_profession_screening_right_subView:OnResetBtnClick()
  for k, v in pairs(self.sceneFilterDatas) do
    v.isOn = true
  end
  for k, v in pairs(self.filterTypeDatas) do
    v.isOn = true
  end
  self.curFilterMinLevel = self.minLevel
  self.curFilterMaxLevel = self.maxLevel
  self:RefreshLevelFilter()
  self:refreshSlider()
  for k, v in pairs(self.sceneToggles) do
    v.isOn = true
  end
  for k, v in pairs(self.typeToggles) do
    v.isOn = true
  end
  self.uiBinder.tog_condition_level.isOn = true
  self.uiBinder.tog_condition_spe.isOn = true
  self.uiBinder.tog_condition_other.isOn = true
  self.uiBinder.tog_has_consume.isOn = true
  self.uiBinder.tog_has_noconsume.isOn = true
end

function Life_profession_screening_right_subView:refreshSceneNode()
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "toggle_tpl")
  self.sceneToggles = {}
  if path ~= nil and path ~= "" then
    for k, v in pairs(self.sceneFilterDatas) do
      Z.CoroUtil.create_coro_xpcall(function()
        local data = v
        local item = self:AsyncLoadUiUnit(path, data.sceneID, self.uiBinder.layout_scene)
        if not item then
          return
        end
        local sceneID = data.sceneID
        local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneID)
        if sceneRow ~= nil then
          item.lab_title.text = sceneRow.Name
        end
        item.tog_show_has:RemoveAllListeners()
        item.tog_show_has:AddListener(function(isOn)
          self:SetSceneFiltered(sceneID, isOn)
        end)
        item.tog_show_has:SetIsOnWithoutCallBack(data.isOn)
        table.insert(self.sceneToggles, item.tog_show_has)
      end)()
    end
  end
  self.uiBinder.node_scene.gameObject:SetActive(table.zcount(self.sceneFilterDatas) > 0)
end

function Life_profession_screening_right_subView:refreshTypeNode()
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "toggle_tpl")
  self.typeToggles = {}
  if path ~= nil and path ~= "" then
    for k, v in pairs(self.filterTypeDatas) do
      Z.CoroUtil.create_coro_xpcall(function()
        local data = v
        local item = self:AsyncLoadUiUnit(path, data.type, self.uiBinder.layout_type)
        if not item then
          return
        end
        local type = data.type
        item.lab_title.text = Lang("LifeProductionTypeName" .. data.type)
        item.tog_show_has:RemoveAllListeners()
        item.tog_show_has:AddListener(function(isOn)
          self:SetTypeFiltered(type, isOn)
        end)
        item.tog_show_has:SetIsOnWithoutCallBack(data.isOn)
        table.insert(self.typeToggles, item.tog_show_has)
      end)()
    end
  end
  self.uiBinder.node_type.gameObject:SetActive(table.zcount(self.filterTypeDatas) > 0)
end

function Life_profession_screening_right_subView:refreshConsumeNode()
  self.uiBinder.tog_has_consume:RemoveAllListeners()
  self.uiBinder.tog_has_consume:AddListener(function(isOn)
    self.filterConsume_ = isOn
  end)
  self.uiBinder.tog_has_noconsume:RemoveAllListeners()
  self.uiBinder.tog_has_noconsume:AddListener(function(isOn)
    self.filterNoConsume_ = isOn
  end)
  local filterConsume, filterNoConsume = self.lifeProfessionData_:GetFilterConsume(self.proID)
  self.uiBinder.tog_has_consume:SetIsOnWithoutCallBack(filterConsume)
  self.uiBinder.tog_has_noconsume:SetIsOnWithoutCallBack(filterNoConsume)
end

function Life_profession_screening_right_subView:refreshConditionNode()
  self.uiBinder.tog_condition_level:RemoveAllListeners()
  self.uiBinder.tog_condition_level:AddListener(function(isOn)
    self.levelCondition = isOn
  end)
  self.uiBinder.tog_condition_spe:RemoveAllListeners()
  self.uiBinder.tog_condition_spe:AddListener(function(isOn)
    self.speCondition = isOn
  end)
  self.uiBinder.tog_condition_other:RemoveAllListeners()
  self.uiBinder.tog_condition_other:AddListener(function(isOn)
    self.otherCondition = isOn
  end)
  local levelCondition, speCondition, otherCondition = self.lifeProfessionData_:GetFilterConditionDatas(self.proID)
  self.uiBinder.tog_condition_level:SetIsOnWithoutCallBack(levelCondition)
  self.uiBinder.tog_condition_spe:SetIsOnWithoutCallBack(speCondition)
  self.uiBinder.tog_condition_other:SetIsOnWithoutCallBack(otherCondition)
end

function Life_profession_screening_right_subView:SetSceneFiltered(sceneID, isOn)
  for i = 1, #self.sceneFilterDatas do
    if self.sceneFilterDatas[i].sceneID == sceneID then
      self.sceneFilterDatas[i].isOn = isOn
      return
    end
  end
end

function Life_profession_screening_right_subView:SetTypeFiltered(type, isOn)
  for i = 1, #self.filterTypeDatas do
    if self.filterTypeDatas[i].type == type then
      self.filterTypeDatas[i].isOn = isOn
      return
    end
  end
end

function Life_profession_screening_right_subView:OnDeActive()
  self.keypad_:DeActive()
end

function Life_profession_screening_right_subView:OnRefresh()
end

function Life_profession_screening_right_subView:InputNum(num)
  if num == 0 then
    num = 1
  end
  if self.curIsMin then
    if num < self.minLevel then
      num = self.minLevel
    end
    if num > self.curFilterMaxLevel then
      num = self.curFilterMaxLevel
    end
    self.curFilterMinLevel = num
  end
  if self.curIsMax then
    if num > self.maxLevel then
      num = self.maxLevel
    end
    if num < self.curFilterMinLevel then
      num = self.curFilterMinLevel
    end
    self.curFilterMaxLevel = num
  end
  self:refreshSlider()
  self:RefreshLevelFilter()
end

function Life_profession_screening_right_subView:refreshSlider()
  local minProgress, maxProgress = self:getCurProgress()
  self.uiBinder.node_silder:SetData(minProgress, maxProgress)
end

function Life_profession_screening_right_subView:getCurProgress()
  if self.maxLevel - self.minLevel <= 0 then
    return 0, 1
  end
  local minProgress = (self.curFilterMinLevel - self.minLevel) / (self.maxLevel - self.minLevel)
  local maxProgress = (self.curFilterMaxLevel - self.minLevel) / (self.maxLevel - self.minLevel)
  return minProgress, maxProgress
end

function Life_profession_screening_right_subView:refreshSliderProgress(minProgress, maxProgress)
  self.curFilterMinLevel = math.ceil(minProgress * (self.maxLevel - self.minLevel) + self.minLevel)
  self.curFilterMaxLevel = math.ceil(maxProgress * (self.maxLevel - self.minLevel) + self.minLevel)
  self:RefreshLevelFilter()
end

return Life_profession_screening_right_subView
