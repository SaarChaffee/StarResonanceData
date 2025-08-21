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
  self:AddClick(self.uiBinder.presscheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.uiBinder.presscheck:StopCheck()
      local dungeonVm_ = Z.VMMgr.GetVM("dungeon")
      dungeonVm_.CloseMonsterAndAffixTip()
    end
  end)
  self.uiBinder.presscheck:StartCheck()
  self.showMonster = false
  local itemPath = Z.IsPCUI and "trialroad_monster_tips_tpl_pc" or "trialroad_monster_tips_tpl"
  self.monsterListView_ = loopListView.new(self, self.uiBinder.loop_item, trialroad_monster_loop_item, itemPath)
  self.monsterListView_:Init({})
  if self.viewData.AutoClose then
    self.closeTimer_ = self.timerMgr:StartTimer(function()
      local dungeonVm_ = Z.VMMgr.GetVM("dungeon")
      dungeonVm_.CloseMonsterAndAffixTip()
    end, 5, 1)
  end
end

function Trialroad_monster_affix_tipsView:OnDeActive()
  self.monsterListView_:UnInit()
  self.monsterListView_ = nil
  self:ClearAllUnits()
  if self.closeTimer_ then
    self.closeTimer_:Stop()
    self.closeTimer_ = nil
  end
end

function Trialroad_monster_affix_tipsView:refreshMonster()
  if self.haveMonster_ then
    self.monsterListView_:RefreshListView(self.viewData.monsterList)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_normal, false)
  end
end

function Trialroad_monster_affix_tipsView:refreshAffix()
  if self.haveAffix_ then
    local path = Z.IsPCUI and GetLoadAssetPath("DungeonAffixTplPC") or GetLoadAssetPath("DungeonAffixTpl")
    Z.CoroUtil.create_coro_xpcall(function()
      for k, v in pairs(self.viewData.affixList) do
        local unit = self:AsyncLoadUiUnit(path, k, self.uiBinder.layout_content)
        unit.dungeon_affix_tpl.text = v
      end
    end)()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_important, false)
  end
end

function Trialroad_monster_affix_tipsView:OnRefresh()
  self.haveAffix_ = false
  self.haveMonster_ = false
  if self.viewData.affixList and next(self.viewData.affixList) then
    self.haveAffix_ = true
  end
  if self.viewData.monsterList and next(self.viewData.monsterList) then
    self.haveMonster_ = true
  end
  self:refreshMonster()
  self:refreshAffix()
  self.uiBinder.tog_important:SetIsOnWithoutCallBack(self.haveAffix_)
  self.uiBinder.tog_normal:SetIsOnWithoutCallBack(not self.haveAffix_)
  self:switchAffixOrMonster(not self.haveAffix_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_vertical, self.haveAffix_ and self.haveMonster_)
  local pivotX = self.viewData.extraParams.pivotX or 0.5
  local pivotY = self.viewData.extraParams.pivotY or 1
  self.uiBinder.img_bg:SetPivot(pivotX, pivotY)
  self.uiBinder.img_bg.position = self.viewData.extraParams.fixedPos
end

function Trialroad_monster_affix_tipsView:switchAffixOrMonster(showMonster)
  self.showMonster = showMonster
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, self.showMonster)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, not self.showMonster)
end

return Trialroad_monster_affix_tipsView
