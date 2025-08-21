local ProfessionBuffShowHelper = class("ProfessionBuffShowHelper")
local UIShowType = {
  Normal = 1,
  Special = 2,
  SpecialNum = 3,
  FlowerLayer = 4
}

function ProfessionBuffShowHelper:ctor(parentView, parent)
  self.parentView = parentView
  self.parent = parent
  self.buffData_ = Z.DataMgr.Get("buff_data")
end

function ProfessionBuffShowHelper:Init()
  self:initWidget()
  self:RefreshProfessionBuffTips()
  Z.EventMgr:Add("OnUIPlayProfessionBuffEffect", self.PlayDynamicEffect, self)
end

function ProfessionBuffShowHelper:UnInit()
  if self.effectTimer_ then
    self.parentView.timerMgr:StopTimer(self.effectTimer_)
    self.effectTimer_ = nil
  end
  for _, value in ipairs(self.UIShowContainers) do
    if value.effect then
      value.effect:ReleseEffGo()
    end
  end
  if self.nextStageTimer_ then
    self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
    self.nextStageTimer_ = nil
  end
  Z.EventMgr:Remove("OnUIPlayProfessionBuffEffect", self.PlayDynamicEffect, self)
end

function ProfessionBuffShowHelper:initWidget()
  self.UIShowContainers = {
    [UIShowType.Normal] = self.parent.img_profession_buff_1,
    [UIShowType.Special] = self.parent.img_profession_buff_2,
    [UIShowType.SpecialNum] = self.parent.img_profession_buff_3,
    [UIShowType.FlowerLayer] = self.parent.img_profession_buff_4
  }
  self.UIShowBgs_ = {
    [UIShowType.Normal] = {
      [1] = self.parent.img_profession_buff_1.img_num_006,
      [2] = self.parent.img_profession_buff_1.img_num_005,
      [3] = self.parent.img_profession_buff_1.img_num_004,
      [4] = self.parent.img_profession_buff_1.img_num_003,
      [5] = self.parent.img_profession_buff_1.img_num_002,
      [6] = self.parent.img_profession_buff_1.img_num_001,
      [7] = self.parent.img_profession_buff_1.img_num_000
    }
  }
end

function ProfessionBuffShowHelper:RefreshProfessionBuffTips()
  if self.parent == nil then
    return
  end
  local buffId, buffLayer, cacheResIconId = self.buffData_:GetProfessionBuff()
  if (not (buffId and buffLayer) or buffLayer <= 0) and #cacheResIconId <= 0 then
    self.curShowBuffId = nil
    for type, value in ipairs(self.UIShowContainers) do
      value.Ref.UIComp:SetVisible(false)
    end
    return
  end
  local fightResIconTableRow = Z.TableMgr.GetTable("FightResIconTableMgr").GetRow(buffId)
  if not fightResIconTableRow then
    for type, value in ipairs(self.UIShowContainers) do
      value.Ref.UIComp:SetVisible(false)
    end
    return
  end
  local uiShowType = fightResIconTableRow.UIShowType
  if uiShowType == nil then
    for type, value in ipairs(self.UIShowContainers) do
      value.Ref.UIComp:SetVisible(false)
    end
    return
  end
  for type, value in ipairs(self.UIShowContainers) do
    value.Ref.UIComp:SetVisible(uiShowType == type)
  end
  local subType = fightResIconTableRow.UIType[1]
  local layerMax = fightResIconTableRow.UIType[2]
  buffLayer = math.min(buffLayer, layerMax)
  if uiShowType == UIShowType.Normal then
    self:setNum(buffLayer, fightResIconTableRow.ResIcon, self.parent.img_profession_buff_1.img_num_1, self.parent.img_profession_buff_1.img_num_2, self.parent.img_profession_buff_1)
    if not string.zisEmpty(fightResIconTableRow.StyleColor) then
      for index, value in ipairs(self.UIShowBgs_[uiShowType]) do
        value:SetColorByHex(fightResIconTableRow.StyleColor)
      end
    end
    if self.curShowBuffId ~= buffId then
      self.parent.img_profession_buff_1.anim:PlayOnce("anim_img_profession_buff_open")
      local path = fightResIconTableRow.EffectResPath .. "open"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.parent.img_profession_buff_1.effect:CreatEFFGO(path, Vector3.zero)
    else
      self.parent.img_profession_buff_1.anim:PlayOnce("anim_img_profession_buff_once")
      local path = fightResIconTableRow.EffectResPath .. "once"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.parent.img_profession_buff_1.effect:CreatEFFGO(path, Vector3.zero)
    end
    if self.nextStageTimer_ then
      self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
      self.nextStageTimer_ = nil
    end
    self.nextStageTimer_ = self.parentView.timerMgr:StartTimer(function()
      self.parent.img_profession_buff_1.anim:PlayLoop("anim_img_profession_buff_loop")
    end, 0.5, 1)
  elseif uiShowType == UIShowType.SpecialNum then
    self:setNum(buffLayer, fightResIconTableRow.ResIcon, self.parent.img_profession_buff_3.img_num_1, self.parent.img_profession_buff_3.img_num_2, self.parent.img_profession_buff_3)
    if self.curShowBuffId ~= buffId then
      self.parent.img_profession_buff_3.anim:PlayOnce("anim_img_profession_buff_2_open_lightning")
      local path = fightResIconTableRow.EffectResPath .. "open"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.parent.img_profession_buff_3.effect:CreatEFFGO(path, Vector3.zero)
    else
      self.parent.img_profession_buff_3.anim:PlayOnce("anim_img_profession_buff_2_once_lightning")
      local path = fightResIconTableRow.EffectResPath .. "once"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.parent.img_profession_buff_3.effect:CreatEFFGO(path, Vector3.zero)
    end
    if self.nextStageTimer_ then
      self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
      self.nextStageTimer_ = nil
    end
    self.nextStageTimer_ = self.parentView.timerMgr:StartTimer(function()
      self.parent.img_profession_buff_3.anim:PlayLoop("anim_img_profession_buff_2_loop_lightning")
      local path = fightResIconTableRow.EffectResPath .. "loop"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.parent.img_profession_buff_3.effect:CreatEFFGO(path, Vector3.zero)
    end, 0.5, 1)
  elseif uiShowType == UIShowType.Special then
    if buffLayer == 1 then
      self.parent.img_profession_buff_2.Ref:SetVisible(self.parent.img_profession_buff_2.img_profession_buff_2_50, true)
      self.parent.img_profession_buff_2.Ref:SetVisible(self.parent.img_profession_buff_2.img_profession_buff_2_100, false)
    else
      self.parent.img_profession_buff_2.Ref:SetVisible(self.parent.img_profession_buff_2.img_profession_buff_2_50, false)
      self.parent.img_profession_buff_2.Ref:SetVisible(self.parent.img_profession_buff_2.img_profession_buff_2_100, true)
    end
    self.parent.img_profession_buff_2.anim:PlayOnce("anim_img_profession_buff_2_" .. buffLayer .. "_open")
    local path = fightResIconTableRow.EffectResPath .. "open_" .. buffLayer
    if Z.IsPCUI then
      path = path .. "_pc"
    end
    self.parent.img_profession_buff_2.effect:CreatEFFGO(path, Vector3.zero)
    if self.nextStageTimer_ then
      self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
      self.nextStageTimer_ = nil
    end
    self.nextStageTimer_ = self.parentView.timerMgr:StartTimer(function()
      self.parent.img_profession_buff_2.anim:PlayLoop("anim_img_profession_buff_2_" .. buffLayer .. "_loop")
      local path = fightResIconTableRow.EffectResPath .. "loop_" .. buffLayer
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.parent.img_profession_buff_2.effect:CreatEFFGO(path, Vector3.zero)
    end, 0.5, 1)
  elseif uiShowType == UIShowType.FlowerLayer then
    local allSubType = {}
    local showBg = false
    for _, value in ipairs(cacheResIconId) do
      local fightResIconRow = Z.TableMgr.GetTable("FightResIconTableMgr").GetRow(value)
      if fightResIconRow and fightResIconRow.UIShowType == UIShowType.FlowerLayer then
        table.insert(allSubType, fightResIconRow.UIType[1])
        showBg = true
      end
    end
    self.parent.img_profession_buff_4.Ref:SetVisible(self.parent.img_profession_buff_4.img_bg, showBg)
    for index = 1, 3 do
      local img_icon = self.parent.img_profession_buff_4["img_icon_" .. index]
      img_icon:SetImage(fightResIconTableRow.ResIcon .. index)
      self.parent.img_profession_buff_4.Ref:SetVisible(img_icon, table.zcontains(allSubType, index))
    end
  end
  self.curShowBuffId = buffId
end

function ProfessionBuffShowHelper:setNum(buffLayer, icon, imgNum1, imgNum2, parentUIBinder)
  if 9 < buffLayer then
    imgNum1.transform.localPosition = self.buffData_:GetProfessionBuffPosition1()
    imgNum1:SetImage(string.zconcat(icon, "0", math.floor(buffLayer / 10) % 10))
    imgNum2:SetImage(string.zconcat(icon, "0", math.floor(buffLayer % 10)))
    parentUIBinder.Ref:SetVisible(imgNum2, true)
  else
    imgNum1.transform.localPosition = self.buffData_:GetProfessionBuffPosition2()
    local icon = string.zconcat(icon, "0", buffLayer)
    imgNum1:SetImage(icon)
    parentUIBinder.Ref:SetVisible(imgNum2, false)
  end
end

function ProfessionBuffShowHelper:stopEffect(effect, time)
  if self.effectTimer_ then
    self.parentView.timerMgr:StopTimer(self.effectTimer_)
    self.effectTimer_ = nil
  end
  self.effectTimer_ = self.parentView.timerMgr:StartTimer(function()
    effect:Stop()
  end, time, 1)
end

function ProfessionBuffShowHelper:PlayDynamicEffect(path, play)
  if play then
    if Z.IsPCUI then
      path = path .. "_pc"
    end
    self.parent.dynamic_effect:CreatEFFGO(path, Vector3.zero)
  else
    self.parent.dynamic_effect:ReleseEffGo()
  end
end

return ProfessionBuffShowHelper
