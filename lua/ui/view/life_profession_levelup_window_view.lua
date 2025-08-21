local UI = Z.UI
local super = require("ui.ui_view_base")
local Life_profession_levelup_windowView = class("Life_profession_levelup_windowView", super)

function Life_profession_levelup_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "life_profession_levelup_window")
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
end

function Life_profession_levelup_windowView:OnActive()
  if not self.viewData then
    self.lifeProfessionVM.CloseLevelUpView()
    return
  end
  local proID = self.viewData.professionID
  local level = self.viewData.level
  local lifeProfessionTableRow = Z.TableMgr.GetRow("LifeProfessionTableMgr", proID)
  if not lifeProfessionTableRow then
    self.lifeProfessionVM.CloseLevelUpView()
    return
  end
  self.uiBinder.img_gift:SetImage(lifeProfessionTableRow.LevelUpIcon)
  if level == 1 then
    self.uiBinder.lab_tips.text = Lang("LifeProfessionUnlock", {
      name = lifeProfessionTableRow.Name
    })
  else
    self.uiBinder.lab_tips.text = Lang("LifeProfessionLevelUp", {
      name = lifeProfessionTableRow.Name,
      uplevel = level
    })
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(3, self.cancelSource:CreateToken())
    self.lifeProfessionVM.CloseLevelUpView()
  end)()
end

function Life_profession_levelup_windowView:OnDeActive()
end

function Life_profession_levelup_windowView:OnRefresh()
end

return Life_profession_levelup_windowView
