local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_mark_subView = class("Map_mark_subView", super)

function Map_mark_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_mark_sub", "map/map_mark_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function Map_mark_subView:OnActive()
  self:initData()
  self:initComp()
end

function Map_mark_subView:initData()
  self.totalMarkDict_ = {}
  self.groupInfoDict_ = {}
end

function Map_mark_subView:initComp()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.switch_main:AddListener(function(isOn)
    self:onSwitchMainChanged(isOn)
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearMarkItem()
    self:createMarkItem()
    self:refreshMainSwitchIsOnWithoutNotify()
  end)()
end

function Map_mark_subView:OnDeActive()
  self:clearMarkItem()
  self.totalMarkDict_ = nil
end

function Map_mark_subView:onSwitchMainChanged(isOn)
  for groupId, idList in pairs(self.totalMarkDict_) do
    if groupId == E.SceneTagGroupId.Custom then
      for index, typeId in ipairs(idList) do
        self.mapData_:SetMapFlagVisibleSettingByTypeId(typeId, isOn)
        Z.EventMgr:Dispatch(Z.ConstValue.MapSettingChange, typeId)
        local unitName = string.zconcat("custom_item_", typeId)
        local unitItem = self.units[unitName]
        if unitItem then
          unitItem.node_tog:SetIsOnWithoutCallBack(isOn)
        end
      end
    else
      local idList = self.totalMarkDict_[groupId] or {}
      for index, typeId in ipairs(idList) do
        self.mapData_:SetMapFlagVisibleSettingByTypeId(typeId, isOn)
        Z.EventMgr:Dispatch(Z.ConstValue.MapSettingChange, typeId)
      end
      local unitName = string.zconcat("group_item_", groupId)
      local unitItem = self.units[unitName]
      if unitItem then
        unitItem.node_tog:SetIsOnWithoutCallBack(isOn)
      end
    end
  end
end

function Map_mark_subView:refreshMainSwitchIsOnWithoutNotify()
  local totalCount = 0
  local count = 0
  for groupId, idList in pairs(self.totalMarkDict_) do
    for index, typeId in ipairs(idList) do
      local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId)
      if isShow then
        count = count + 1
      end
      totalCount = totalCount + 1
    end
  end
  local isAllShow = count == totalCount
  self.uiBinder.switch_main:SetIsOnWithoutNotify(isAllShow)
end

function Map_mark_subView:createMarkItem()
  local showTagIdDict = self.getCurrentMapTagIdDict()
  local configList = Z.TableMgr.GetTable("SceneTagTableMgr").GetDatas()
  local markGroupList = {}
  local markGroupDict = {}
  for typeId, row in pairs(configList) do
    if row.Show > 0 then
      if self.groupInfoDict_[row.Show] == nil then
        self.groupInfoDict_[row.Show] = {}
      end
      if row.ShowGroupName ~= "" and (self.groupInfoDict_[row.Show].Name == nil or self.groupInfoDict_[row.Show].Name == "") then
        self.groupInfoDict_[row.Show].Name = row.ShowGroupName
      end
      if row.ShowGroupIcon ~= "" and (self.groupInfoDict_[row.Show].Icon == nil or self.groupInfoDict_[row.Show].Icon == "") then
        self.groupInfoDict_[row.Show].Icon = row.ShowGroupIcon
      end
      if self.totalMarkDict_[row.Show] == nil then
        self.totalMarkDict_[row.Show] = {}
      end
      table.insert(self.totalMarkDict_[row.Show], row.Id)
      if row.Show == E.SceneTagGroupId.Custom then
        self:createCustomMarkItem(row)
      elseif markGroupDict[row.Show] == nil and showTagIdDict[row.Id] then
        markGroupDict[row.Show] = true
        table.insert(markGroupList, row.Show)
      end
    end
  end
  table.sort(markGroupList, function(a, b)
    return a < b
  end)
  for i, groupId in ipairs(markGroupList) do
    self:createGroupMarkItem(groupId)
  end
  self.uiBinder.comp_layout_rebuilder:ForceRebuildLayoutImmediate()
end

function Map_mark_subView:getCurrentMapTagIdDict()
  local tagIdDict = {}
  local mapView = Z.UIMgr:GetView("map_main")
  if mapView == nil then
    return tagIdDict
  end
  local allFlagDataList = mapView:GetCurrentAllFlagList()
  for i, flagData in ipairs(allFlagDataList) do
    tagIdDict[flagData.TypeId] = true
  end
  return tagIdDict
end

function Map_mark_subView:createGroupMarkItem(groupId)
  local info = self.groupInfoDict_[groupId]
  local unitPath = self.uiBinder.comp_prefab_cache:GetString("default_item")
  local unitParent = self.uiBinder.trans_default_tag
  local unitName = string.zconcat("group_item_", groupId)
  local unitToken = self.cancelSource:CreateToken()
  self.markUnitTokenDict_[unitName] = unitToken
  local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
  self.markUnitDict_[unitName] = unitItem
  unitItem.img_icon:SetImage(info.Icon)
  local isShow = true
  local idList = self.totalMarkDict_[groupId] or {}
  for i, typeId in ipairs(idList) do
    if not self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId) then
      isShow = false
      break
    end
  end
  unitItem.node_tog:SetIsOnWithoutCallBack(isShow)
  unitItem.node_tog:AddListener(function(isOn)
    for i, typeId in ipairs(idList) do
      self.mapData_:SetMapFlagVisibleSettingByTypeId(typeId, isOn)
      Z.EventMgr:Dispatch(Z.ConstValue.MapSettingChange, typeId)
    end
    self:refreshMainSwitchIsOnWithoutNotify()
  end)
  unitItem.lab_sys_name_on.text = info.Name
  unitItem.lab_sys_name_off.text = info.Name
end

function Map_mark_subView:createCustomMarkItem(tagRow)
  local typeId = tagRow.Id
  local unitPath = self.uiBinder.comp_prefab_cache:GetString("custom_item")
  local unitParent = self.uiBinder.trans_custom_tag
  local unitName = string.zconcat("custom_item_", typeId)
  local unitToken = self.cancelSource:CreateToken()
  self.markUnitTokenDict_[unitName] = unitToken
  local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
  self.markUnitDict_[unitName] = unitItem
  unitItem.img_icon:SetImage(tagRow.Icon1)
  local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId)
  unitItem.node_tog:SetIsOnWithoutCallBack(isShow)
  unitItem.node_tog:AddListener(function(isOn)
    self.mapData_:SetMapFlagVisibleSettingByTypeId(typeId, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.MapSettingChange, typeId)
    self:refreshMainSwitchIsOnWithoutNotify()
  end)
end

function Map_mark_subView:clearMarkItem()
  if self.markUnitTokenDict_ then
    for unitName, unitToken in pairs(self.markUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.markUnitTokenDict_ = {}
  if self.markUnitDict_ then
    for unitName, unitItem in pairs(self.markUnitDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.markUnitDict_ = {}
end

return Map_mark_subView
