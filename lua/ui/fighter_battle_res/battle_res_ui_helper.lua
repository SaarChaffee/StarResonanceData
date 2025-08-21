local BattleResUIHelper = class("BattleResUIHelper")
local snow = require("ui.fighter_battle_res.fighter_battle_res_snow")
local guitar = require("ui.fighter_battle_res.fighter_battle_res_guitar")
local milk = require("ui.fighter_battle_res.fighter_battle_res_milk")
local rock = require("ui.fighter_battle_res.fighter_battle_res_rock")
local thunder = require("ui.fighter_battle_res.fighter_battle_res_thunder")
local lance = require("ui.fighter_battle_res.fighter_battle_res_lance")
local shooter = require("ui.fighter_battle_res.fighter_battle_res_shooter")
local sword = require("ui.fighter_battle_res.fighter_battle_res_sword")
E.ResUIType = {
  Dot = 1,
  Line = 2,
  Guitar = 3,
  SiderLine = 4
}

function BattleResUIHelper:ctor(rect, viewParent)
  self.rectRoot_ = rect
  self.viewParent_ = viewParent
  self.professionResShowCls_ = {
    [1] = thunder.new(self.rectRoot_, self.viewParent_),
    [2] = snow.new(self.rectRoot_, self.viewParent_),
    [5] = lance.new(self.rectRoot_, self.viewParent_),
    [9] = rock.new(self.rectRoot_, self.viewParent_),
    [11] = shooter.new(self.rectRoot_, self.viewParent_),
    [12] = sword.new(self.rectRoot_, self.viewParent_),
    [13] = milk.new(self.rectRoot_, self.viewParent_),
    [14] = guitar.new(self.rectRoot_, self.viewParent_)
  }
end

function BattleResUIHelper:Active()
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.resTempShow_ = nil
  self:OnPorfessionChange()
end

function BattleResUIHelper:Refresh()
  if self.resTempShow_ then
    self.resTempShow_:Refresh()
  end
end

function BattleResUIHelper:OnPorfessionChange()
  if self.resTempShow_ then
    self.resTempShow_:DeActive()
  end
  self.resTempShow_ = nil
  local professionId = self.professionVm_:GetContainerProfession()
  if professionId == 0 then
    return
  end
  local professionRow = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(professionId)
  if professionRow == nil then
    return
  end
  self.fightResTemplateRow_ = Z.TableMgr.GetTable("FightResAttrTemplateTableMgr").GetRow(professionRow.FightResTemplateId)
  if self.professionResShowCls_[self.fightResTemplateRow_.Id] then
    self.resTempShow_ = self.professionResShowCls_[self.fightResTemplateRow_.Id]
    self.resTempShow_:Active(self.fightResTemplateRow_)
  end
  self:OnBuffChange()
  self:Refresh()
end

function BattleResUIHelper:OnBuffChange()
  if self.resTempShow_ then
    self.resTempShow_:OnBuffChange()
  end
end

function BattleResUIHelper:OnBattleResCdChange(resId, fightResCd)
  if self.resTempShow_ then
    self.resTempShow_:OnBattleResCdChange(resId, fightResCd)
  end
end

function BattleResUIHelper:DeActive()
  if self.resTempShow_ then
    self.resTempShow_:DeActive()
    self.resTempShow_ = nil
  end
end

return BattleResUIHelper
