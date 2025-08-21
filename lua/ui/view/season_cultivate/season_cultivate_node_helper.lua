local cls = class("SeasonCultivateNodeHelper")
local BackGroundPath = {
  [1] = GetLoadAssetPath("SeasonCultivateNodeUnActive"),
  [2] = GetLoadAssetPath("SeasonCultivateNodeActive"),
  [3] = GetLoadAssetPath("SeasonCultivateNodeSelect")
}
local IconColor = {
  [1] = Color.New(0.6549019, 0.6745098, 0.6352941, 1),
  [2] = Color.New(0.6549019, 0.6745098, 0.6352941, 1),
  [3] = Color.New(0, 0, 0, 1)
}
local FrameVisible = {
  [1] = false,
  [2] = true,
  [3] = false
}

function cls:ctor(view, uiBinder)
  self.view_ = view
  self.uiBinder_ = uiBinder
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
end

function cls:OnActive()
  self.uiBinder_.node_eff_level_up:SetEffectGoVisible(false)
  self.nodeInfo_ = {}
  self.uiBinder_.btn_click:AddListener(function()
    if self.seasonCultivateVM_.TryClick() and self.nodeInfo_ then
      Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnSelectNode, self.nodeInfo_.holeConfig.HoleId)
    end
  end)
  Z.EventMgr:Add(Z.ConstValue.SeasonCultivate.OnSelectNode, self.onSelectNode, self)
end

function cls:OnRefresh(nodeInfo, select)
  self.nodeInfo_ = nodeInfo
  self.uiBinder_.lab_level.text = Lang("AchievementLevel", {
    val = self.nodeInfo_.holeConfig.HoleLevel
  })
  local state = self.nodeInfo_.holeConfig.HoleLevel <= 0 and 1 or 2
  if select then
    state = 3
  end
  self:setState(state)
end

function cls:OnDeActive()
  self.nodeInfo_ = nil
  Z.EventMgr:RemoveObjAll(self)
end

function cls:setState(state)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_select, state == 3)
  self:onStartAnimClickShow(state == 3)
  if FrameVisible[state] ~= nil then
  end
end

function cls:onSelectNode(holeId)
  local state = 0
  if holeId == self.nodeInfo_.holeConfig.HoleId then
    state = 3
  else
    state = self.nodeInfo_.holeConfig.HoleLevel < 1 and 1 or 2
  end
  self:setState(state)
end

function cls:OnLevelUpNodeEffShow()
  Z.AudioMgr:Play("UI_Event_Magic_C")
  local parentUIDepth = self.view_:GetParentUIDepth()
  if parentUIDepth then
    parentUIDepth:AddChildDepth(self.uiBinder_.node_eff_level_up)
  end
  self.uiBinder_.node_eff_level_up:SetEffectGoVisible(true)
end

function cls:onStartAnimClickShow(isClick)
  if isClick then
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Open)
  end
end

return cls
