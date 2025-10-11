local super = require("ui.component.loop_grid_view_item")
local ExploreMonsterMonsterItem = class("ExploreMonsterMonsterItem", super)

function ExploreMonsterMonsterItem:OnInit()
  self.vm_ = Z.VMMgr.GetVM("explore_monster")
  self.modelTableMgr_ = Z.TableMgr.GetTable("ModelTableMgr")
  self.targetTableMgr_ = Z.TableMgr.GetTable("MonsterHuntTargetTableMgr")
  self.monsterData_ = Z.DataMgr.Get("explore_monster_data")
  self.parentUIView_ = self.parent.UIView
end

function ExploreMonsterMonsterItem:OnRefresh(data)
  local monsterCfg = data.MonsterData
  if monsterCfg then
    local modelCfg = self.modelTableMgr_.GetRow(monsterCfg.ModelID)
    if modelCfg then
      self.uiBinder.img_finish_icon:SetImage(modelCfg.Image)
      self.uiBinder.img_ash_icon:SetImage(modelCfg.Image)
    end
  end
  self:refreshSelectState(self.IsSelected)
  self:updateMonsterItemStatus()
end

function ExploreMonsterMonsterItem:OnUnInit()
end

function ExploreMonsterMonsterItem:OnSelected(isSelected, isClick)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    local data = self:GetCurData()
    self.parentUIView_:ChangeMonster(data, isClick)
  end
  self:refreshSelectState(isSelected)
end

function ExploreMonsterMonsterItem:refreshSelectState(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, isSelect)
end

function ExploreMonsterMonsterItem:updateMonsterItemStatus()
  local d_ = self:GetCurData()
  local cfg = d_.ExploreData
  local finishNum_ = self.vm_.GetExploreMonsterTargetFinishNumById(cfg.MonsterId)
  local data = self.vm_.GetExploreMonsterTargetInfoList(cfg.MonsterId)
  local targetCount_ = #cfg.Target
  local isUnlock_ = 0 < finishNum_
  local allFinish_ = finishNum_ >= targetCount_
  local ashVisivble_, finishVisible_, reddotVisible_
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_grade, 1 <= finishNum_)
  if isUnlock_ then
    self.uiBinder.lab_grade.text = finishNum_
    ashVisivble_ = false
    finishVisible_ = true
  else
    ashVisivble_ = true
    finishVisible_ = false
  end
  local targetId = 0
  for i = 1, #cfg.Target do
    targetId = cfg.Target[i][2]
    if data and data[i] then
      local targetData_ = data[i]
      local targetNum_ = targetData_.targetNum
      local exploreCfg = self.targetTableMgr_.GetRow(targetId)
      if exploreCfg and targetNum_ >= exploreCfg.Num and targetData_.awardFlag == E.MonsterHuntTargetAwardState.Get then
        reddotVisible_ = true
        break
      end
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_not, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ash, ashVisivble_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_finish, finishVisible_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, reddotVisible_)
end

return ExploreMonsterMonsterItem
