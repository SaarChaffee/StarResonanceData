local super = require("ui.component.loop_list_view_item")
local unionDeviceMainItem = class("unionDeviceMainItem", super)

function unionDeviceMainItem:ctor()
end

function unionDeviceMainItem:OnInit()
  self.unionVm_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  Z.EventMgr:Add(Z.ConstValue.Union.UnionDeviceBattleBuffSelect, self.OnSelectDungeonBoss, self)
  self.notFirstSelect_ = false
end

function unionDeviceMainItem:OnRefresh(data)
  self.dungeonBossRow_ = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(data.bossId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.dungeonId_ = data.dungeonId
  local unionBossBuffRow = Z.TableMgr.GetTable("UnionBossBuffTableMgr").GetRow(data.bossId)
  local killCnt = self.unionData_:GetUnionAllRiadBossData(data.bossId)
  local isUnlock = killCnt >= unionBossBuffRow.ConditionValue
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isUnlock)
  self.uiBinder.rimg_icon_on:SetImage(self.dungeonBossRow_.BossIcon)
  self.uiBinder.rimg_icon_off:SetImage(self.dungeonBossRow_.BossIcon)
  if self.parent.UIView:CheckIsInitSelect(self.dungeonId_, data.bossId) and not self.notFirstSelect_ then
    self.notFirstSelect_ = true
    self:OnSelected(true)
  end
end

function unionDeviceMainItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Union.UnionDeviceBattleBuffSelect, self.OnSelectDungeonBoss, self)
end

function unionDeviceMainItem:OnSelectDungeonBoss(dungeonId, BossId)
  self.IsSelected = self.dungeonId_ == dungeonId and self.dungeonBossRow_.BossId == BossId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function unionDeviceMainItem:OnSelected(isSelected)
  if isSelected then
    Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionDeviceBattleBuffSelect, self.dungeonId_, self.dungeonBossRow_.BossId)
    self.parent.UIView:OnSelectDungeonBoss(self.dungeonId_, self.dungeonBossRow_.BossId)
  end
end

function unionDeviceMainItem:OnPointerClick()
end

return unionDeviceMainItem
