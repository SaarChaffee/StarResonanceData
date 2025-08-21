local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local fighterBattleResSilderLine = class("fighterBattleResDot", super)

function fighterBattleResSilderLine:ctor()
  super.ctor(self)
end

function fighterBattleResSilderLine:Active(uibinder, fightResTemplateRow_, resId, openBuff)
  super.Active(self, uibinder, fightResTemplateRow_, resId, openBuff)
end

function fighterBattleResSilderLine:Refresh(nowNum, maxNum, resId)
  if self.uibinder_ == nil then
    return
  end
  self.uibinder_.img_bar:SetFilled(nowNum / maxNum, true)
  self.uibinder_.lab_res_num.text = nowNum .. "/" .. maxNum
end

return fighterBattleResSilderLine
