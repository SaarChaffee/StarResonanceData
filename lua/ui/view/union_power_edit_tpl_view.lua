local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_power_edit_tplView = class("Union_power_edit_tplView", super)
local powerEditItem = require("ui.component.union.union_power_edit_item")
local powerTog = require("ui.component.union.union_power_tog")
local powerEditItemName = "power_edit_item_"
local powerTogName = "power_tog_"

function Union_power_edit_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_power_edit_tpl", "union/union_power_edit_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_power_edit_tplView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.powerEditItemDict_ = nil
  self.powerTogItemDict_ = nil
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncLoadPowerItem()
  end)()
end

function Union_power_edit_tplView:OnDeActive()
  self:clearPowerItem()
end

function Union_power_edit_tplView:OnRefresh()
end

function Union_power_edit_tplView:asyncLoadPowerItem()
  self:clearPowerItem()
  local tableInfo = Z.TableMgr.GetTable("UnionManageTableMgr")
  local configList = {}
  for id, config in pairs(tableInfo.GetDatas()) do
    configList[#configList + 1] = config
  end
  local compFunc = function(l, r)
    return l.ShowSort < r.ShowSort
  end
  table.sort(configList, compFunc)
  for index, config in pairs(configList) do
    if #config.UnionManage > 0 then
      local positionName = self.unionVM_:GetOfficialName(config.Id)
      local itemName = powerEditItemName .. config.Id
      local itemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.UnionPowerEditItem)
      local binderItem = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.trans_content, self.cancelSource:CreateToken())
      local editItem = powerEditItem.new()
      editItem:Init(binderItem)
      editItem:SetData(positionName)
      self.powerEditItemDict_[itemName] = editItem
      local officialData = self.unionData_.UnionInfo.officials[config.Id]
      for _, vec3 in pairs(config.UnionManage) do
        local powerId = math.floor(vec3.X)
        local enableModify = vec3.Y == 1
        local defaultValue = vec3.Z == 1
        local togItemName = string.zconcat(powerTogName, config.Id, "_", powerId)
        local togItemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.UnionPowerTogItem)
        local subBinderItem = self:AsyncLoadUiUnit(togItemPath, togItemName, editItem:GetLayoutTrans(), self.cancelSource:CreateToken())
        local togItem = powerTog.new()
        togItem:Init(subBinderItem)
        if officialData ~= nil and officialData.power[powerId] ~= nil then
          togItem:SetData(config.Id, powerId, enableModify, officialData.power[powerId])
        else
          togItem:SetData(config.Id, powerId, enableModify, defaultValue)
        end
        self.powerEditItemDict_[itemName] = editItem
      end
    end
  end
end

function Union_power_edit_tplView:clearPowerItem()
  if self.powerEditItemDict_ then
    for itemName, item in pairs(self.powerEditItemDict_) do
      item:UnInit()
      self:RemoveUiUnit(itemName)
    end
  end
  self.powerEditItemDict_ = {}
  if self.powerTogItemDict_ then
    for itemName, item in pairs(self.powerTogItemDict_) do
      item:UnInit()
      self:RemoveUiUnit(itemName)
    end
  end
  self.powerTogItemDict_ = {}
end

return Union_power_edit_tplView
