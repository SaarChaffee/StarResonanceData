local UI = Z.UI
local super = require("ui.ui_view_base")
local Master_dungeon_failure_windowView = class("Master_dungeon_failure_windowView", super)

function Master_dungeon_failure_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "trialroad_battle_failure_window")
end

function Master_dungeon_failure_windowView:OnActive()
  Z.AudioMgr:Play("UI_Event_Dungeon_Fail")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local path = "ui/prefabs/dead/dead_resurrection_tpl"
  Z.CoroUtil.create_coro_xpcall(function()
    local item = self:AsyncLoadUiUnit(path, "reviveBtn", self.uiBinder.btn_parent)
    local lab = Lang("LeaveCopy")
    item.cont_btn_resurrection.interactable = true
    item.cont_btn_resurrection.IsDisabled = false
    item.lab_content_normal.text = lab
    self:AddAsyncClick(item.cont_btn_resurrection, function()
      local proxy = require("zproxy.world_proxy")
      proxy.LeaveScene(self.cancelSource:CreateToken())
    end)
  end)()
end

function Master_dungeon_failure_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Master_dungeon_failure_windowView:OnRefresh()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonsTable then
    return
  end
  self.uiBinder.lab_bottom.text = dungeonsTable.FailText
end

return Master_dungeon_failure_windowView
