local UI = Z.UI
local super = require("ui.ui_view_base")
local unionAppointEditItem = require("ui.component.union.union_appoint_edit_item")
local itemPrefabPath = "ui/prefabs/union/union_appoint_edit_item_tpl"
local Union_appoint_edit_tipsView = class("Union_appoint_edit_tipsView", super)

function Union_appoint_edit_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_appoint_edit_tips")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function Union_appoint_edit_tipsView:GetEnableModifyOfficialDataSortList()
  local sortedList = {}
  local myOfficialId = self.unionVM_:GetPlayerOfficialId()
  local config = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(myOfficialId)
  for id, officialData in pairs(self.unionData_.UnionInfo.officials) do
    if officialData ~= nil then
      if officialData.officialId == E.UnionPositionDef.President then
        if self.unionVM_:IsPlayerUnionPresident() then
          sortedList[#sortedList + 1] = officialData
        end
      elseif table.zcontains(config.UnionAuthoritySit, officialData.officialId) then
        sortedList[#sortedList + 1] = officialData
      end
    end
  end
  table.sort(sortedList, function(left, right)
    local leftConfig = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(left.officialId)
    local rightConfig = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(right.officialId)
    return leftConfig.ShowSort < rightConfig.ShowSort
  end)
  return sortedList
end

function Union_appoint_edit_tipsView:OnActive()
  self:startAnimatedShow()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("union_appoint_edit_tips")
  end)
  local officialDataList = self:GetEnableModifyOfficialDataSortList()
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearEditItems()
    for index, officialData in pairs(officialDataList) do
      local editItem = unionAppointEditItem.new()
      local binderItem = self:AsyncLoadUiUnit(itemPrefabPath, "appointEditItem" .. officialData.officialId, self.uiBinder.trans_edit, self.cancelSource:CreateToken())
      editItem:Init(binderItem, self)
      editItem:SetData(officialData, self.viewData.memberData)
    end
  end)()
end

function Union_appoint_edit_tipsView:OnDeActive()
  self:clearEditItems()
end

function Union_appoint_edit_tipsView:OnRefresh()
  local worldPos = self.viewData.positionTrans.position
  self.uiBinder.trans_tips:SetPos(worldPos)
  local localPos = self.viewData.positionTrans.localPosition
  localPos.y = localPos.y - 15
  self.uiBinder.trans_tips:SetLocalPos(localPos)
end

function Union_appoint_edit_tipsView:clearEditItems()
  if self.allEditItemDict_ then
    for itemName, binderItem in pairs(self.allEditItemDict_) do
      binderItem:UnInit()
      self:RemoveUiUnit(itemName)
    end
  end
  self.allEditItemDict_ = {}
end

function Union_appoint_edit_tipsView:startAnimatedShow()
  self.uiBinder.tween_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_appoint_edit_tipsView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.tween_main.CoroPlay)
  coro(self.uiBinder.tween_main, Z.DOTweenAnimType.Close)
end

return Union_appoint_edit_tipsView
