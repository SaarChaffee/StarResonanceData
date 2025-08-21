local UI = Z.UI
local super = require("ui.ui_view_base")
local Trialroad_battle_failure_windowView = class("Trialroad_battle_failure_windowView", super)
local planetMemoryDeadTb = {
  {
    btnType = E.TrialRoadDeadViewBtnType.LeaveCopy
  },
  {
    btnType = E.TrialRoadDeadViewBtnType.Restart
  }
}

function Trialroad_battle_failure_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "trialroad_battle_failure_window")
  self.vm = Z.VMMgr.GetVM("dead")
end

function Trialroad_battle_failure_windowView:getBtnState()
  local trialroadVM = Z.VMMgr.GetVM("trialroad")
  local isTrialRoad = trialroadVM.IsTrialRoad()
  local herodungeonVm = Z.VMMgr.GetVM("hero_dungeon_main")
  local isHeroDungeon = herodungeonVm.IsHeroDungeonNormalScene()
  local isHeroChalleDungeon = herodungeonVm.IsHeroChallengeDungeonScene()
  local isUnionHuntDungeon = herodungeonVm.IsUnionHuntDungeonScene()
  local isTeamExceed_ = Z.VMMgr.GetVM("team").GetTeamMembersNum()
  self.hideRestart_ = false
  if isHeroChalleDungeon or isHeroDungeon then
    self.hideRestart_ = true
  end
  if not isTrialRoad and isTeamExceed_ then
    self.hideRestart_ = true
  end
  if isUnionHuntDungeon and not isTeamExceed_ then
    self.hideRestart_ = true
  end
end

function Trialroad_battle_failure_windowView:OnActive()
  Z.AudioMgr:Play("UI_Event_Dungeon_Fail")
  self:getBtnState()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local path = "ui/prefabs/dead/dead_resurrection_tpl"
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(planetMemoryDeadTb) do
      local item = self:AsyncLoadUiUnit(path, "reviveBtn" .. key, self.uiBinder.btn_parent)
      local lab = key == 1 and Lang("LeaveCopy") or Lang("Restart")
      if self.hideRestart_ and value.btnType == E.TrialRoadDeadViewBtnType.Restart then
        item.Ref.UIComp:SetVisible(false)
      end
      item.cont_btn_resurrection.interactable = true
      item.cont_btn_resurrection.IsDisabled = false
      item.lab_content_normal.text = lab
      self:AddAsyncClick(item.cont_btn_resurrection, function()
        local trialroadVM = Z.VMMgr.GetVM("trialroad")
        if value.btnType == E.TrialRoadDeadViewBtnType.LeaveCopy then
          local proxy = require("zproxy.world_proxy")
          proxy.LeaveScene(self.cancelSource:CreateToken())
          trialroadVM.CloseTrialRoadFailureView()
        else
          trialroadVM.ReChallengeLevel()
        end
      end)
    end
  end)()
  self:onAnimStart()
end

function Trialroad_battle_failure_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Trialroad_battle_failure_windowView:OnRefresh()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonsTable then
    return
  end
  self.uiBinder.lab_bottom.text = dungeonsTable.FailText
end

function Trialroad_battle_failure_windowView:onAnimStart()
  self.uiBinder.anim:PlayOnce("anim_trialroad_battle_failure_window_open")
end

return Trialroad_battle_failure_windowView
