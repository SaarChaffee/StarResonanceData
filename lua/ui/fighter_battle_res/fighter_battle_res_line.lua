local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local fighterBattleResLine = class("fighterBattleResDot", super)

function fighterBattleResLine:ctor()
  super.ctor(self)
end

function fighterBattleResLine:Active(uibinder, fightResTemplateRow_, resId, openBuff)
  super.Active(self, uibinder, fightResTemplateRow_, resId, openBuff)
  self.uibinder_.slider_eff:SetEffectGoVisible(false)
end

function fighterBattleResLine:Refresh(nowNum, maxNum, resId)
  if self.uibinder_ == nil then
    return
  end
  self.uibinder_.img_bar:SetFilled(nowNum / maxNum, true)
  if self.uibinder_.lab_res_num then
    self.uibinder_.lab_res_num.text = nowNum .. "/" .. maxNum
  end
end

return fighterBattleResLine
