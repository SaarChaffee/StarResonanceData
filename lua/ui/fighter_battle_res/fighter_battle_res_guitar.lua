local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local dot = require("ui.fighter_battle_res.fighter_battle_res_dot")
local fighterBattleResGuitar = class("fighterBattleResGuitar", super)

function fighterBattleResGuitar:ctor(rect, viewParent)
  super.ctor(self, rect, viewParent)
  self.resDot_ = dot.new()
  self.uibinder_ = nil
end

function fighterBattleResGuitar:OnActive()
  for index, value in ipairs(self.fightResTemplateRow_.UIType) do
    if value == E.ResUIType.Dot then
      local resId = self.fightResTemplateRow_.ResIDs[index]
      local openBuff = self.fightResTemplateRow_.OpenBuff[index]
      self.resDot_:Active(self.uibinder_.dot, self.fightResTemplateRow_, resId, openBuff)
    end
  end
  self:OnBuffChange()
end

function fighterBattleResGuitar:OnRefresh()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    if self.ResValue[value] then
      local maxNum = self.ResValue[value].maxNum
      local nowNum = self.ResValue[value].nowNum
      if self.fightResTemplateRow_.UIType[index] == E.ResUIType.Dot then
        if self.ResIdOpen[value] then
          self.resDot_:Refresh(nowNum, maxNum)
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.Guitar then
        if self.ResIdOpen[value] then
          self.uibinder_.main_guitar.lab_progress.text = nowNum .. "/" .. maxNum
          local lineWidth = self.uibinder_.main_guitar.line_root.rect.width
          self.uibinder_.main_guitar.Ref:SetVisible(self.uibinder_.main_guitar.line_root, true)
          local nowFillAmount = self.uibinder_.main_guitar.img_guitar_bar.fillAmount
          local lastTarget = 1 - nowFillAmount
          local target = nowNum / maxNum
          local loop = 10
          local perAdd = (target - lastTarget) / loop
          if self.moveTimer then
            self.moveTimer:Stop()
            self.moveTimer = nil
          end
          self.moveTimer = self.timerMgr:StartTimer(function()
            local nowTarget = lastTarget + perAdd
            self.uibinder_.main_guitar.img_guitar_bar.fillAmount = 1 - nowTarget
            self.uibinder_.main_guitar.img_line_rect:SetAnchorPosition(lineWidth * nowTarget, 0)
            lastTarget = nowTarget
          end, 1 / loop, loop)
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.Line and self.ResIdOpen[value] then
        self.uibinder_.main_guitar.img_bar:SetFilled(nowNum / maxNum, true)
      end
    end
  end
end

function fighterBattleResGuitar:OnBuffChange()
  if self.IsLoaded then
    super.OnBuffChange(self)
    self.resDot_:OnBuffChange()
    self:refreshShowRes()
  end
end

function fighterBattleResGuitar:refreshShowRes()
  self.uibinder_.dot.Ref.UIComp:SetVisible(self.TypeOpen[E.ResUIType.Dot])
  self.uibinder_.main_guitar.Ref:SetVisible(self.uibinder_.main_guitar.line_root, self.TypeOpen[E.ResUIType.Guitar])
  self.uibinder_.main_guitar.Ref:SetVisible(self.uibinder_.main_guitar.img_bar, self.TypeOpen[E.ResUIType.Line])
end

function fighterBattleResGuitar:OnBattleResCdChange(resId, fightResCd)
  if self.IsLoaded then
    self.resDot_:OnBattleResCdChange(resId, fightResCd)
  end
end

function fighterBattleResGuitar:OnDeActive()
  self.resDot_:DeActive()
end

return fighterBattleResGuitar
