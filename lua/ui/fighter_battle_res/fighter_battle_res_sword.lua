local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local dot = require("ui.fighter_battle_res.fighter_battle_res_dot")
local fighterBattleResSword = class("fighterBattleResSword", super)

function fighterBattleResSword:ctor(rect, viewParent)
  super.ctor(self, rect, viewParent)
  self.resDot_ = dot.new()
  self.uibinder_ = nil
end

function fighterBattleResSword:OnActive()
  for index, value in ipairs(self.fightResTemplateRow_.UIType) do
    if value == E.ResUIType.Dot then
      local resId = self.fightResTemplateRow_.ResIDs[index]
      local openBuff = self.fightResTemplateRow_.OpenBuff[index]
      self.resDot_:Active(self.uibinder_.dot, self.fightResTemplateRow_, resId, openBuff)
    end
  end
  self.displayComp_ = {
    [E.PlayerBattleResType.BarEffect] = {
      [E.PlayerBattleResType.BarEffect] = self.uibinder_.main_sword.ui_display_eff_1,
      [E.PlayerBattleResType.Bar] = self.uibinder_.main_sword.ui_display_eff_2
    },
    [E.PlayerBattleResType.Bar] = self.uibinder_.main_sword.img_sword_bottom_on,
    [E.PlayerBattleResType.DotEffect] = self.resDot_
  }
  self.uibinder_.main_sword.img_sword_bottom_on:Play(0, 0, 0, nil)
  self.lastEffectOpen_ = {}
  self:OnBuffChange()
end

function fighterBattleResSword:OnRefresh()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    if self.ResValue[value] then
      local maxNum = self.ResValue[value].maxNum
      local nowNum = self.ResValue[value].nowNum
      if self.fightResTemplateRow_.UIType[index] == E.ResUIType.Dot then
        if self.ResIdOpen[value] then
          self.resDot_:Refresh(nowNum, maxNum)
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.Line then
        if self.ResIdOpen[value] then
          self.uibinder_.main_sword.img_sword_bar:SetFilled(nowNum / maxNum, true)
          self.uibinder_.main_sword.lab_progress.text = nowNum .. "/" .. maxNum
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.SiderLine and self.ResIdOpen[value] then
        self.uibinder_.sider_line.img_bar:SetFilled(nowNum / maxNum, true)
        self.uibinder_.sider_line.lab_res_num.text = nowNum .. "/" .. maxNum
      end
    end
  end
end

function fighterBattleResSword:OnBuffChange()
  if self.IsLoaded then
    self.resDot_:OnBuffChange()
    super.OnBuffChange(self)
    self:refreshShowRes()
    self:refreshDisplayEffect()
  end
end

function fighterBattleResSword:refreshShowRes()
  self.uibinder_.dot.Ref.UIComp:SetVisible(self.TypeOpen[E.ResUIType.Dot])
  self.uibinder_.main_sword.Ref:SetVisible(self.uibinder_.main_sword.line_root, self.TypeOpen[E.ResUIType.Line])
  self.uibinder_.sider_line.Ref.UIComp:SetVisible(self.TypeOpen[E.ResUIType.SiderLine])
end

function fighterBattleResSword:refreshDisplayEffect()
  for index, value in ipairs(self.fightResTemplateRow_.EffectShowBuff) do
    local type = tonumber(value[1])
    local displayEffectParam = self.DisplayEffectType[type]
    local displayFunc = self.BattleResDisplay["OnDisPlayProcess_" .. type]
    if displayFunc then
      if type == E.PlayerBattleResType.Bar then
        local zuiEffect = self.displayComp_[E.PlayerBattleResType.BarEffect][type]
        displayEffectParam.effPath = "ui/uieffect/prefab/ui_sfx_battle_weapon_001/ui_sfx_group_jd_fankui_once"
        displayFunc(self, self.displayComp_[type], displayEffectParam, zuiEffect)
      elseif type == E.PlayerBattleResType.BarEffect then
        local zuiEffect = self.displayComp_[E.PlayerBattleResType.BarEffect][type]
        displayFunc(self, zuiEffect, displayEffectParam)
      else
        displayFunc(self, self.displayComp_[type], displayEffectParam)
      end
    end
    if self.lastEffectOpen_[type] == nil then
      self.lastEffectOpen_[type] = displayEffectParam.isOpen
    end
    if type == E.PlayerBattleResType.DotEffect and self.lastEffectOpen_[type] ~= displayEffectParam.isOpen then
      self.resDot_:HideUIDotCd(displayEffectParam.isOpen)
    end
    self.lastEffectOpen_[type] = displayEffectParam.isOpen
  end
end

function fighterBattleResSword:DisplayEffect_2(displayEffectParam)
  self.resDot_:DisplayEffect(displayEffectParam.isOpen, displayEffectParam.param)
end

function fighterBattleResSword:OnBattleResCdChange(resId, fightResCd)
  self.resDot_:OnBattleResCdChange(resId, fightResCd)
end

function fighterBattleResSword:OnDeActive()
  self.resDot_:DeActive()
end

return fighterBattleResSword
