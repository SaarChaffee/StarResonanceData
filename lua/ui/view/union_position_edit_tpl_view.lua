local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_position_edit_tplView = class("Union_position_edit_tplView", super)
local positionEditItem = require("ui.component.union.union_position_edit_item")
local positionEditItemName = "position_edit_item_"

function Union_position_edit_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_position_edit_tpl", "union/union_position_edit_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_position_edit_tplView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.positionEditItemDict_ = nil
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncLoadPositionEditItem()
  end)()
end

function Union_position_edit_tplView:OnDeActive()
  self:clearPositionEditItem()
end

function Union_position_edit_tplView:OnRefresh()
end

function Union_position_edit_tplView:asyncLoadPositionEditItem()
  self:clearPositionEditItem()
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
    local parentTrans
    if self.unionVM_:IsCustomPosition(config.Id) == false then
      parentTrans = self.uiBinder.trans_fixed_list
    else
      parentTrans = self.uiBinder.trans_custom_list
    end
    local itemName = positionEditItemName .. config.Id
    local itemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.UnionPositionEditItem)
    local binderItem = self:AsyncLoadUiUnit(itemPath, itemName, parentTrans, self.cancelSource:CreateToken())
    local editItem = positionEditItem.new()
    editItem:Init(binderItem)
    self.positionEditItemDict_[itemName] = editItem
  end
  self:refreshPositionEditUI()
end

function Union_position_edit_tplView:clearPositionEditItem()
  if self.positionEditItemDict_ then
    for itemName, editItem in pairs(self.positionEditItemDict_) do
      editItem:UnInit()
      self:RemoveUiUnit(itemName)
    end
  end
  self.positionEditItemDict_ = {}
end

function Union_position_edit_tplView:refreshPositionEditUI()
  local officialDataDict = self.unionData_.UnionInfo.officials
  for id, officialData in pairs(officialDataDict) do
    local itemName = positionEditItemName .. id
    local editItem = self.positionEditItemDict_[itemName]
    if editItem then
      editItem:SetData(officialData.officialId, officialData.Name)
    end
  end
end

return Union_position_edit_tplView
