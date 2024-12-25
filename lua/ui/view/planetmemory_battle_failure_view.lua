local UI = Z.UI
local super = require("ui.ui_view_base")
local Planetmemory_battle_failureView = class("Planetmemory_battle_failureView", super)
local planetMemoryDeadTb = {
  {
    btnType = E.PlanetMemoryDeadViewBtnType.LeaveCopy
  },
  {
    btnType = E.PlanetMemoryDeadViewBtnType.Restart
  }
}

function Planetmemory_battle_failureView:ctor()
  self.uiBinder = nil
  super.ctor(self, "planetmemory_battle_failure")
  self.vm = Z.VMMgr.GetVM("dead")
end

function Planetmemory_battle_failureView:getBtnState()
  self.isTeamExceed_ = Z.VMMgr.GetVM("team").GetTeamMembersNum()
end

function Planetmemory_battle_failureView:OnActive()
  self:getBtnState()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local path = "ui/prefabs/dead/dead_resurrection_tpl"
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(planetMemoryDeadTb) do
      local item = self:AsyncLoadUiUnit(path, "reviveBtn" .. key, self.uiBinder.btn_parent)
      local lab = key == 1 and Lang("LeaveCopy") or Lang("Restart")
      if self.isTeamExceed_ and value.btnType == E.PlanetMemoryDeadViewBtnType.Restart then
        item.Ref:SetVisible(item.Trans, false)
      end
      item.cont_btn_resurrection.interactable = true
      item.cont_btn_resurrection.IsDisabled = false
      item.lab_content_normal.text = lab
      self:AddAsyncClick(item.cont_btn_resurrection, function()
        if value.btnType == E.PlanetMemoryDeadViewBtnType.LeaveCopy then
          local proxy = require("zproxy.world_proxy")
          proxy.LeaveScene(self.cancelSource:CreateToken())
          Z.VMMgr.GetVM("planetmemory").ClosePlanememoryFailureView()
        else
          Z.VMMgr.GetVM("planetmemory").AsyncRestartPlanetMemory(self.cancelSource:CreateToken())
        end
      end)
    end
  end)()
end

function Planetmemory_battle_failureView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Planetmemory_battle_failureView:OnRefresh()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonsTable then
    return
  end
  self.uiBinder.lab_bottom.text = dungeonsTable.FailText
end

return Planetmemory_battle_failureView
