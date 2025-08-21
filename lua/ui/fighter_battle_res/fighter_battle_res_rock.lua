local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local dot = require("ui.fighter_battle_res.fighter_battle_res_dot")
local fighterBattleResRock = class("fighterBattleResRock", super)

function fighterBattleResRock:ctor(rect, viewParent)
  super.ctor(self, rect, viewParent)
  self.resDot_ = dot.new()
  self.uibinder_ = nil
end

function fighterBattleResRock:OnActive()
  for index, value in ipairs(self.fightResTemplateRow_.UIType) do
    if value == E.ResUIType.Dot then
      local resId = self.fightResTemplateRow_.ResIDs[index]
      local openBuff = self.fightResTemplateRow_.OpenBuff[index]
      self.resDot_:Active(self.uibinder_.dot, self.fightResTemplateRow_, resId, openBuff)
    end
  end
  self.displayComp_ = {
    [E.PlayerBattleResType.BarEffect] = {
      [E.PlayerBattleResType.BarEffect] = self.uibinder_.main_rock.ui_display_eff_1,
      [E.PlayerBattleResType.Bar] = self.uibinder_.main_rock.ui_display_eff_2
    },
    [E.PlayerBattleResType.Bar] = self.uibinder_.main_rock.img_rock_bottom_on
  }
  self.uibinder_.main_rock.img_rock_bottom_on:Play(0, 0, 0, nil)
  self:OnBuffChange()
end

function fighterBattleResRock:OnRefresh()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    if self.ResValue[value] then
      local maxNum = self.ResValue[value].maxNum
      local nowNum = self.ResValue[value].nowNum
      if self.fightResTemplateRow_.UIType[index] == E.ResUIType.Dot then
        if self.ResIdOpen[value] then
          self.resDot_:Refresh(nowNum, maxNum)
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.Line and self.ResIdOpen[value] then
        self.uibinder_.main_rock.img_rock_bar:SetFilled(nowNum / maxNum, true)
        self.uibinder_.main_rock.lab_progress.text = nowNum .. "/" .. maxNum
      end
    end
  end
end

function fighterBattleResRock:OnBuffChange()
  if self.IsLoaded then
    self.resDot_:OnBuffChange()
    super.OnBuffChange(self)
    self:refreshShowRes()
    self:refreshDisplayEffect()
  end
end

function fighterBattleResRock:refreshDisplayEffect()
  for index, value in ipairs(self.fightResTemplateRow_.EffectShowBuff) do
    local type = tonumber(value[1])
    local displayEffectParam = self.DisplayEffectType[type]
    local displayFunc = self.BattleResDisplay["OnDisPlayProcess_" .. type]
    if displayFunc then
      if type == E.PlayerBattleResType.Bar then
        local zuiEffect = self.displayComp_[E.PlayerBattleResType.BarEffect][type]
        displayEffectParam.effPath = "ui/uieffect/prefab/ui_sfx_battle_weapon_001/ui_sfx_group_wr_fankui_once"
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

function fighterBattleResRock:refreshShowRes()
  self.uibinder_.dot.Ref.UIComp:SetVisible(self.TypeOpen[E.ResUIType.Dot])
  self.uibinder_.main_rock.Ref:SetVisible(self.uibinder_.main_rock.line_root, self.TypeOpen[E.ResUIType.Line])
end

function fighterBattleResRock:OnBattleResCdChange(resId, fightResCd)
  self.resDot_:OnBattleResCdChange(resId, fightResCd)
end

function fighterBattleResRock:OnDeActive()
  self.resDot_:DeActive()
end

return fighterBattleResRock
