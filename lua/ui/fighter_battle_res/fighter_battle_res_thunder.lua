local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local dot = require("ui.fighter_battle_res.fighter_battle_res_dot")
local fighterBattleResThunder = class("fighterBattleResThunder", super)

function fighterBattleResThunder:ctor(rect, viewParent)
  super.ctor(self, rect, viewParent)
  self.resDot_ = dot.new()
  self.uibinder_ = nil
end

function fighterBattleResThunder:OnActive()
  for index, value in ipairs(self.fightResTemplateRow_.UIType) do
    if value == E.ResUIType.Dot then
      local resId = self.fightResTemplateRow_.ResIDs[index]
      local openBuff = self.fightResTemplateRow_.OpenBuff[index]
      self.resDot_:Active(self.uibinder_.dot, self.fightResTemplateRow_, resId, openBuff)
    end
  end
  self.displayComp_ = {
    [E.PlayerBattleResType.BarEffect] = {
      [E.PlayerBattleResType.BarEffect] = self.uibinder_.main_thunder.ui_display_eff_1,
      [E.PlayerBattleResType.Bar] = self.uibinder_.main_thunder.ui_display_eff_2
    },
    [E.PlayerBattleResType.Bar] = self.uibinder_.main_thunder.img_thunder_bottom_on,
    [E.PlayerBattleResType.DotEffect] = self.resDot_
  }
  self.uibinder_.main_thunder.img_thunder_bottom_on:Play(0, 0, 0, nil)
  self:OnBuffChange()
end

function fighterBattleResThunder:OnRefresh()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    if self.ResValue[value] then
      local maxNum = self.ResValue[value].maxNum
      local nowNum = self.ResValue[value].nowNum
      if self.fightResTemplateRow_.UIType[index] == E.ResUIType.Dot then
        if self.ResIdOpen[value] then
          self.resDot_:Refresh(nowNum, maxNum)
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.Line and self.ResIdOpen[value] then
        self.uibinder_.main_thunder.img_thunder_bar:SetFilled(nowNum / maxNum, true)
        self.uibinder_.main_thunder.lab_progress.text = nowNum .. "/" .. maxNum
      end
    end
  end
end

function fighterBattleResThunder:OnBuffChange()
  if self.IsLoaded then
    self.resDot_:OnBuffChange()
    super.OnBuffChange(self)
    self:refreshShowRes()
    self:refreshDisplayEffect()
  end
end

function fighterBattleResThunder:refreshShowRes()
  self.uibinder_.dot.Ref.UIComp:SetVisible(self.TypeOpen[E.ResUIType.Dot])
  self.uibinder_.main_thunder.Ref:SetVisible(self.uibinder_.main_thunder.line_root, self.TypeOpen[E.ResUIType.Line])
end

function fighterBattleResThunder:refreshDisplayEffect()
  for index, value in ipairs(self.fightResTemplateRow_.EffectShowBuff) do
    local type = tonumber(value[1])
    local displayEffectParam = self.DisplayEffectType[type]
    local displayFunc = self.BattleResDisplay["OnDisPlayProcess_" .. type]
    if displayFunc then
      if type == E.PlayerBattleResType.Bar then
        local zuiEffect = self.displayComp_[E.PlayerBattleResType.BarEffect][type]
        displayEffectParam.effPath = "ui/uieffect/prefab/ui_sfx_battle_weapon_001/ui_sfx_group_tdl_fankui_once"
        displayFunc(self, self.displayComp_[type], displayEffectParam, zuiEffect)
      elseif type == E.PlayerBattleResType.BarEffect then
        local zuiEffect = self.displayComp_[E.PlayerBattleResType.BarEffect][type]
        displayFunc(self, zuiEffect, displayEffectParam)
      else
        displayFunc(self, self.displayComp_[type], displayEffectParam)
      end
    end
  end
end

function fighterBattleResThunder:OnBattleResCdChange(resId, fightResCd)
  self.resDot_:OnBattleResCdChange(resId, fightResCd)
end

function fighterBattleResThunder:OnDeActive()
  self.resDot_:DeActive()
end

return fighterBattleResThunder
