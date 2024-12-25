local super = require("ui.component.loopscrollrectitem")
local ExploreMonsterLoopItem = class("ExploreMonsterLoopItem", super)

function ExploreMonsterLoopItem:ctor()
  self.vm = Z.VMMgr.GetVM("explore_monster")
end

function ExploreMonsterLoopItem:OnInit()
  if self.initTag_ then
    return
  end
  self.initTag_ = true
  self.click_btn_ = self.unit.btn.Btn
  self.select_go_ = self.unit.cont.img_select
  self.mark_go_ = self.unit.cont.img_mark
  self.node_finish_ = self.unit.cont.node_finish
  self.node_ash_ = self.unit.cont.node_ash
  self.node_not_ = self.unit.cont.node_not
  self.node_red_ = self.unit.cont.img_reddot
  self.img_icons_ = self.unit.cont.img_icon
end

function ExploreMonsterLoopItem:Refresh()
  self:AddAsyncClick(self.click_btn_, function()
    self.parent.uiView:ChangeMonster(self.component.Index + 1)
  end)
  self:showIcon()
  self:showStatus()
  self:UpdateData({mark = true})
end

function ExploreMonsterLoopItem:OnUnInit()
end

function ExploreMonsterLoopItem:Selected(isSelected)
  self.select_go_:SetVisible(isSelected)
end

function ExploreMonsterLoopItem:UpdateData(data)
  if data then
    if data.mark then
      local cfg = self.parent:GetDataByIndex(self.component.Index + 1)
      self.mark_go_:SetVisible(Z.DataMgr.Get("explore_monster_data"):GetMarkByID(cfg.Scene, cfg.MonsterId))
    end
    if data.status then
      self:showStatus()
    end
  end
end

function ExploreMonsterLoopItem:showIcon()
  local cfg = self.parent:GetDataByIndex(self.component.Index + 1)
  local monsterCfg = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(cfg.MonsterId)
  if monsterCfg then
    local modelCfg = Z.TableMgr.GetTable("ModelTableMgr").GetRow(monsterCfg.ModelID)
    if modelCfg then
      for i = 1, #self.img_icons_ do
        self.img_icons_[i].Img:SetImage(modelCfg.Image)
      end
    end
  end
end

function ExploreMonsterLoopItem:showStatus()
  local cfg = self.parent:GetDataByIndex(self.component.Index + 1)
  local exploreCfgs = Z.TableMgr.GetTable("MonsterHuntTargetTableMgr")
  local data = Z.VMMgr.GetVM("explore_monster").GetExploreMonsterDataById(cfg.MonsterId)
  if data and data.isUnlock then
    self.node_not_:SetVisible(false)
    if data.awardFlag == 1 then
      self.node_ash_:SetVisible(false)
      self.node_finish_:SetVisible(true)
      self.node_red_:SetVisible(false)
    else
      for i = 1, #cfg.Target do
        local exploreCfg = exploreCfgs.GetRow(cfg.Target[i][2])
        if exploreCfg and data.targetNum[cfg.Target[i][2]] and data.targetNum[cfg.Target[i][2]] < exploreCfg.Num then
          self.node_ash_:SetVisible(true)
          self.node_finish_:SetVisible(false)
          return
        end
      end
      self.node_ash_:SetVisible(false)
      self.node_finish_:SetVisible(true)
      self.node_red_:SetVisible(true)
    end
  else
    self.node_not_:SetVisible(true)
    self.node_ash_:SetVisible(false)
    self.node_finish_:SetVisible(false)
  end
end

return ExploreMonsterLoopItem
