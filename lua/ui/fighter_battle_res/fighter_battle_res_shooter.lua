local super = require("ui.fighter_battle_res.fighter_battle_res_base")
local dot = require("ui.fighter_battle_res.fighter_battle_res_dot")
local fighterBattleResShooter = class("fighterBattleResShooter", super)
local buffToBdType = {wolf = 2203040, hawk = 2203290}
local bdTypeResBgPath = {
  [buffToBdType.wolf] = "ui/atlas/battle_weapon_shooter/main_shooter_wolf_",
  [buffToBdType.hawk] = "ui/atlas/battle_weapon_shooter/main_shooter_hawk_"
}

function fighterBattleResShooter:ctor(rect, viewParent)
  super.ctor(self, rect, viewParent)
  self.resDot_ = dot.new()
  self.uibinder_ = nil
end

function fighterBattleResShooter:OnActive()
  for index, value in ipairs(self.fightResTemplateRow_.UIType) do
    if value == E.ResUIType.Dot then
      local resId = self.fightResTemplateRow_.ResIDs[index]
      local openBuff = self.fightResTemplateRow_.OpenBuff[index]
      self.resDot_:Active(self.uibinder_.dot, self.fightResTemplateRow_, resId, openBuff)
    end
  end
  self.displayComp_ = {
    [E.PlayerBattleResType.BarEffect] = {
      [E.PlayerBattleResType.BarEffect] = self.uibinder_.main_shooter.ui_display_eff_1,
      [E.PlayerBattleResType.Bar] = self.uibinder_.main_shooter.ui_display_eff_2
    },
    [E.PlayerBattleResType.Bar] = self.uibinder_.main_shooter.img_bar_shooter_bottom_nor_on
  }
  self.uibinder_.main_shooter.img_bar_shooter_bottom_nor_on:Play(0, 0, 0, nil)
  self.uibinder_.main_shooter.img_bar_shooter_bottom_bd_on:Play(0, 0, 0, nil)
  self:OnBuffChange()
end

function fighterBattleResShooter:OnRefresh()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    if self.ResValue[value] then
      local maxNum = self.ResValue[value].maxNum
      local nowNum = self.ResValue[value].nowNum
      if self.fightResTemplateRow_.UIType[index] == E.ResUIType.Dot then
        if self.ResIdOpen[value] then
          self.resDot_:Refresh(nowNum, maxNum)
        end
      elseif self.fightResTemplateRow_.UIType[index] == E.ResUIType.Line and self.ResIdOpen[value] then
        self.uibinder_.main_shooter.img_clip_anim_shooter_bar:SetFilled(nowNum / maxNum, true)
        self.uibinder_.main_shooter.lab_progress.text = nowNum .. "/" .. maxNum
      end
    end
  end
end

function fighterBattleResShooter:OnBuffChange()
  if self.IsLoaded then
    self.resDot_:OnBuffChange()
    super.OnBuffChange(self)
    self:refreshBdTypeResBg()
    self:refreshShowRes()
    self:refreshDisplayEffect()
  end
end

function fighterBattleResShooter:refreshDisplayEffect()
  for index, value in ipairs(self.fightResTemplateRow_.EffectShowBuff) do
    local type = tonumber(value[1])
    local displayEffectParam = self.DisplayEffectType[type]
    local displayFunc = self.BattleResDisplay["OnDisPlayProcess_" .. type]
    if displayFunc then
      if type == E.PlayerBattleResType.Bar then
        if self.ENowBuffList[buffToBdType.wolf] then
          displayEffectParam.effPath = "ui/uieffect/prefab/ui_sfx_battle_weapon_001/ui_sfx_group_gj_fankui_once_wolf"
          self.displayComp_[type] = self.uibinder_.main_shooter.img_bar_shooter_bottom_bd_on
        elseif self.ENowBuffList[buffToBdType.hawk] then
          displayEffectParam.effPath = "ui/uieffect/prefab/ui_sfx_battle_weapon_001/ui_sfx_group_gj_fankui_once_hawk"
          self.displayComp_[type] = self.uibinder_.main_shooter.img_bar_shooter_bottom_bd_on
        else
          displayEffectParam.effPath = "ui/uieffect/prefab/ui_sfx_battle_weapon_001/ui_sfx_group_gj_fankui_once_normal"
          self.displayComp_[type] = self.uibinder_.main_shooter.img_bar_shooter_bottom_nor_on
        end
        local zuiEffect = self.displayComp_[E.PlayerBattleResType.BarEffect][type]
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

function fighterBattleResShooter:refreshBdTypeResBg()
  local talenSkillVm = Z.VMMgr.GetVM("talent_skill")
  local talentStageId = talenSkillVm.GetCurProfessionTalentStage()
  local talenStageRow = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(talentStageId)
  local nowTalentStage = 0
  if talenStageRow then
    nowTalentStage = talenStageRow.TalentStage
  end
  if self.ENowBuffList[buffToBdType.wolf] == nil and self.ENowBuffList[buffToBdType.hawk] == nil then
    self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_bd_on, false)
    self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_bd_off, false)
    self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_nor_on, true)
    self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_nor_off, true)
    self.displayComp_[1] = self.uibinder_.main_shooter.img_bar_shooter_bottom_nor_on
    return
  end
  self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_bd_on, true)
  self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_bd_off, true)
  self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_nor_on, false)
  self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.img_shooter_bottom_nor_off, false)
  for index, value in pairs(bdTypeResBgPath) do
    if self.ENowBuffList[index] then
      self.uibinder_.main_shooter.img_shooter_bottom_bd_on:SetImage(value .. "on")
      self.uibinder_.main_shooter.img_shooter_bottom_bd_off:SetImage(value .. "off")
      return
    end
  end
  self.displayComp_[1] = self.uibinder_.main_shooter.img_bar_shooter_bottom_bd_on
end

function fighterBattleResShooter:refreshShowRes()
  self.uibinder_.dot.Ref.UIComp:SetVisible(self.TypeOpen[E.ResUIType.Dot])
  self.uibinder_.main_shooter.Ref:SetVisible(self.uibinder_.main_shooter.line_root, self.TypeOpen[E.ResUIType.Line])
end

function fighterBattleResShooter:OnBattleResCdChange(resId, fightResCd)
  self.resDot_:OnBattleResCdChange(resId, fightResCd)
end

function fighterBattleResShooter:OnDeActive()
  self.resDot_:DeActive()
end

return fighterBattleResShooter
