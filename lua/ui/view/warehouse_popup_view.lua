local UI = Z.UI
local super = require("ui.ui_view_base")
local Warehouse_popupView = class("Warehouse_popupView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Warehouse_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "warehouse_popup")
  self.vm_ = Z.VMMgr.GetVM("warehouse")
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self.data_ = Z.DataMgr.Get("warehouse_data")
end

function Warehouse_popupView:initBinders()
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.sceneMask_ = self.uiBinder.scenemask
  self.itemParent = self.uiBinder.item_parent
  self.memberNumLab_ = self.uiBinder.lab_notice
  self.dissolveBtn_ = self.uiBinder.btn_dissolve
  self.affirmBtn_ = self.uiBinder.btn_affirm
  self.quitBtn_ = self.uiBinder.btn_quit
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Warehouse_popupView:initBtns()
  if self.data_.WarehouseInfo then
    local isLeader = self.data_.WarehouseInfo.presidentId == Z.ContainerMgr.CharSerialize.charBase.charId
    self.uiBinder.Ref:SetVisible(self.dissolveBtn_, isLeader)
    self.uiBinder.Ref:SetVisible(self.quitBtn_, not isLeader)
  end
  self:AddAsyncClick(self.dissolveBtn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("WarehouseDissolveDialogTips"), function()
      Z.DialogViewDataMgr:CloseDialogView()
      self.vm_.AsyncDisbandWarehouse(self.cancelSource:CreateToken())
    end)
  end)
  self:AddAsyncClick(self.quitBtn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("WarehouseQuitDialogTips"), function()
      Z.DialogViewDataMgr:CloseDialogView()
      self.vm_.AsyncExitWarehouse(self.cancelSource:CreateToken())
    end)
  end)
  self:AddClick(self.affirmBtn_, function()
    self.vm_.CloseWareMmberPopupView()
  end)
end

function Warehouse_popupView:OnActive()
  self:initBinders()
  self:bindEvent()
  self:initBtns()
  self.allUnits_ = {}
  self.unitTokenDict_ = {}
  self:loadMemberItem()
end

function Warehouse_popupView:loadMemberItem()
  for unitName, unitToken in pairs(self.unitTokenDict_) do
    Z.CancelSource.ReleaseToken(unitToken)
  end
  self.unitTokenDict_ = {}
  for unitName, unit in pairs(self.allUnits_) do
    self:RemoveUiUnit(unitName)
  end
  self.allUnits_ = {}
  local warehouseInfo = self.data_:GetWarehouseInfo()
  local leaderIsSelf = false
  leaderIsSelf = warehouseInfo.presidentId == Z.ContainerMgr.CharSerialize.charBase.charId
  if not warehouseInfo then
    return
  end
  local itemPath = self.prefabCache_:GetString("memberItem")
  if itemPath == "" or itemPath == nil then
    return
  end
  local maxMemberCount = Z.Global.WarehousePopulation
  self.memberNumLab_.text = Lang("WarehouseMemberNumber", {
    val1 = #warehouseInfo.memIdList,
    val2 = maxMemberCount
  })
  local itemCount = #warehouseInfo.memIdList == maxMemberCount and maxMemberCount or #warehouseInfo.memIdList + 1
  Z.CoroUtil.create_coro_xpcall(function()
    local emptyCount = 0
    for i = 1, itemCount do
      local itemName = "member" .. i
      local unitToken = self.cancelSource:CreateToken()
      self.unitTokenDict_[itemName] = unitToken
      local item = self:AsyncLoadUiUnit(itemPath, itemName, self.itemParent.transform, unitToken)
      if item then
        self.allUnits_[itemName] = item
        item.Ref.UIComp:SetVisible(false)
        local memId
        local isLeader = false
        if warehouseInfo.memIdList then
          memId = warehouseInfo.memIdList[i]
          isLeader = warehouseInfo.presidentId == memId
        end
        if memId == nil then
          emptyCount = emptyCount + 1
        end
        item.Ref:SetVisible(item.node_empty, memId == nil and leaderIsSelf and emptyCount == 1)
        item.Ref:SetVisible(item.node_item, memId ~= nil)
        local isSelf = memId == Z.ContainerMgr.CharSerialize.charBase.charId
        item.Ref:SetVisible(item.btn_dialogue, memId ~= nil and not isSelf)
        item.Ref:SetVisible(item.btn_kick_out, leaderIsSelf and not isSelf)
        if memId then
          do
            local socialData = self.socialVM_.AsyncGetSocialData(0, memId, self.cancelSource:CreateToken())
            if socialData then
              item.lab_name.text = socialData.basicData.name
              item.Ref:SetVisible(item.img_leader, isLeader)
              self:AddClick(item.btn_kick_out, function()
                local player = {
                  name = socialData.basicData.name
                }
                Z.DialogViewDataMgr:OpenNormalDialog(Lang("WarehouseKickOutDialogTips", {player = player}), function()
                  Z.DialogViewDataMgr:CloseDialogView()
                  self.vm_.AsyncKickOutWarehouse(memId, self.cancelSource:CreateToken())
                end)
              end)
              self:AddClick(item.btn_dialogue, function()
                Z.VMMgr.GetVM("friends_main").OpenPrivateChat(memId)
              end)
              playerPortraitHgr.InsertNewPortraitBySocialData(item.head, socialData, function()
                Z.VMMgr.GetVM("idcard").AsyncGetCardData(memId, self.cancelSource:CreateToken())
              end)
            end
          end
        end
      end
    end
    for unitName, unit in pairs(self.allUnits_) do
      unit.Ref.UIComp:SetVisible(true)
    end
  end)()
end

function Warehouse_popupView:quitWarehouse()
  self.vm_.CloseWareMmberPopupView()
end

function Warehouse_popupView:refreshWarehouse()
  self:loadMemberItem()
end

function Warehouse_popupView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Warehouse.WarehouseExistDisband, self.quitWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Warehouse.WarehouseExistBeKickOut, self.quitWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.quitWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Warehouse.RefreshWarehouse, self.refreshWarehouse, self)
end

function Warehouse_popupView:OnDeActive()
end

function Warehouse_popupView:OnRefresh()
end

return Warehouse_popupView
