local super = require("ui.component.loop_list_view_item")
local SeasonActivationListItem = class("SeasonActivationListItem", super)

function SeasonActivationListItem:OnInit()
  if Z.IsPCUI then
    self.itemList_ = {
      self.uiBinder.node_item_1,
      self.uiBinder.node_item_2,
      self.uiBinder.node_item_3,
      self.uiBinder.node_item_4
    }
  else
    self.itemList_ = {
      self.uiBinder.node_item_1,
      self.uiBinder.node_item_2,
      self.uiBinder.node_item_3
    }
  end
  self.quickJumpVm_ = Z.VMMgr.GetVM("quick_jump")
  self.privilegesData_ = Z.DataMgr.Get("privileges_data")
end

function SeasonActivationListItem:OnRefresh(data)
  self.itemData_ = data
  self:refreshItemList()
end

function SeasonActivationListItem:refreshItemList()
  for k, v in pairs(self.itemList_) do
    if k > #self.itemData_ then
      self.uiBinder.Ref:SetVisible(v.Trans, false)
    else
      self.uiBinder.Ref:SetVisible(v.Trans, true)
      self:setItemData(self.itemData_[k], v)
    end
  end
end

function SeasonActivationListItem:setItemData(data, item)
  local tableData = Z.TableMgr.GetTable("ActivationTableMgr").GetRow(data.id)
  item.btn_jump:RemoveAllListeners()
  item.btn_jump:AddListener(function()
    self:onItemClick(tableData)
  end)
  local progress = Lang("season_achievement_progress", {
    val1 = data.progress,
    val2 = tableData.Num
  })
  item.lab_info.text = Z.Placeholder.Placeholder(tableData.TargetDes, {
    val = tableData.Num,
    val2 = progress
  })
  self:resetItemState(item)
  local activation = tableData.Activation
  local privilegesRate = self.privilegesData_:GetPrivilegesDataByFunction(E.PrivilegeSourceType.BattlePass, E.PrivilegeEffectType.DailyActivityBonus)
  if privilegesRate then
    activation = math.floor(activation * (1 + privilegesRate.value / 10000))
  end
  item.lab_num.text = activation
  if 1 <= tableData.Cycle then
    item.Ref:SetVisible(item.img_update, true)
  else
    item.Ref:SetVisible(item.img_finish, data.progress == tableData.Num)
  end
end

function SeasonActivationListItem:resetItemState(item)
  item.Ref:SetVisible(item.img_update, false)
  item.Ref:SetVisible(item.img_finish, false)
end

function SeasonActivationListItem:onItemClick(tableData)
  if not tableData or not next(tableData) then
    return
  end
  if tableData.QuickJumpType == 0 or not next(tableData.QuickJump) then
    Z.TipsVM.ShowTips(1400003)
    return
  end
  local quickjumpVm = Z.VMMgr.GetVM("quick_jump")
  quickjumpVm.DoJumpByConfigParam(tableData.QuickJumpType, tableData.QuickJump)
end

function SeasonActivationListItem:OnUnInit()
  self.itemList_ = {}
end

return SeasonActivationListItem
