local super = require("ui.component.loop_list_view_item")
local BattlePassPrivilegesItem = class("BattlePassPrivilegesItem", super)

function BattlePassPrivilegesItem:ctor()
  super:ctor()
end

function BattlePassPrivilegesItem:OnInit()
  self:initParam()
end

function BattlePassPrivilegesItem:initParam()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.itemClassTab_ = {}
  self.privilegeTable_ = Z.TableMgr.GetTable("PrivilegeTableMgr")
end

function BattlePassPrivilegesItem:OnRefresh(data)
  self.data_ = data
  self:setViewInfo()
end

function BattlePassPrivilegesItem:setViewInfo()
  self.uiBinder.img_icon:SetImage(self.data_.PrivilegeIcon)
  self.uiBinder.lab_title.text = self.battlePassVM_.AssembledBpCardPrivilegesContent(self.data_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, self.data_.IsShowAccelerated)
  if self.data_.IsShowAccelerated then
    self:setTime()
  end
end

function BattlePassPrivilegesItem:setTime()
  local battlePassContainer = self.battlePassVM_.GetCurrentBattlePassContainer()
  if not battlePassContainer or next(battlePassContainer) == nil then
    return
  end
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(battlePassContainer.id)
  if not bpCardGlobalInfo or not bpCardGlobalInfo.Timer then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, true)
  local time = Z.TimeTools.GetLeftTimeByTimerId(bpCardGlobalInfo.Timer)
  if 0 < time then
    time = math.floor(time / 86400)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
    return
  end
  self.uiBinder.lab_time.text = Lang("Day", {val = time})
end

return BattlePassPrivilegesItem
