local UI = Z.UI
local super = require("ui.ui_view_base")
local Trialroad_monster_affix_tipsView = class("Trialroad_monster_affix_tipsView", super)
local loopListView = require("ui.component.loop_grid_view")
local trialroad_monster_loop_item = require("ui.component.trialroad.trialroad_monster_loop_grid_item")

function Trialroad_monster_affix_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "dungeon_monster_affix_tips")
end

function Trialroad_monster_affix_tipsView:OnActive()
  self.uiBinder.tog_important:AddListener(function(isOn)
    if isOn then
      self:switchAffixOrMonster(false)
    end
  end)
  self.uiBinder.tog_normal:AddListener(function(isOn)
    if isOn then
      self:switchAffixOrMonster(true)
    end
  end)
  self.showMonster = false
  self.monsterListView_ = loopListView.new(self, self.uiBinder.group_monster.loop_item, trialroad_monster_loop_item, "trialroad_monster_btn_tpl")
  self.monsterListView_:Init({})
end

function Trialroad_monster_affix_tipsView:OnDeActive()
  self.monsterListView_:UnInit()
  self.monsterListView_ = nil
  self:ClearAllUnits()
end

function Trialroad_monster_affix_tipsView:refreshMonster()
  if self.viewData.monsterList and next(self.viewData.monsterList) then
    self.monsterListView_:RefreshListView(self.viewData.monsterList)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_normal, false)
  end
end

function Trialroad_monster_affix_tipsView:refreshAffix()
  if self.viewData.affixList and next(self.viewData.affixList) then
    local path = Z.IsPCUI and GetLoadAssetPath("DungeonAffixTplPC") or GetLoadAssetPath("DungeonAffixTpl")
    for k, v in pairs(self.viewData.affixList) do
      local unit = self:AsyncLoadUiUnit(path, k, self.uiBinder.layout_content)
      unit.uiBinder.dungeon_affix_tpl.text = v
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_important, false)
  end
end

function Trialroad_monster_affix_tipsView:OnRefresh()
  self:refreshMonster()
  self:refreshAffix()
  self:switchAffixOrMonster(false)
end

function Trialroad_monster_affix_tipsView:switchAffixOrMonster(showMonster)
  self.showMonster = showMonster
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, self.showMonster)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, not self.showMonster)
end

return Trialroad_monster_affix_tipsView
