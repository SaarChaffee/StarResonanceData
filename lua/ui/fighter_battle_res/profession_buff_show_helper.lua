local ProfessionBuffShowHelper = class("ProfessionBuffShowHelper")
local UIShowType = {
  Normal = 1,
  Special = 2,
  SpecialNum = 3
}

function ProfessionBuffShowHelper:ctor(parentView, parent)
  self.parentView = parentView
  self.parent = parent
  self.buffData_ = Z.DataMgr.Get("buff_data")
end

function ProfessionBuffShowHelper:Init()
  self:initWidget()
  self:RefreshProfessionBuffTips()
end

function ProfessionBuffShowHelper:UnInit()
  for _, value in ipairs(self.UIShowContainers) do
    value.effect.ZEff:ReleseEffGo()
  end
  if self.nextStageTimer_ then
    self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
    self.nextStageTimer_ = nil
  end
end

function ProfessionBuffShowHelper:initWidget()
  self.UIShowContainers = {
    [UIShowType.Normal] = self.parent.img_profession_buff_1,
    [UIShowType.Special] = self.parent.img_profession_buff_2,
    [UIShowType.SpecialNum] = self.parent.img_profession_buff_3
  }
  self.UIShowBgs_ = {
    [UIShowType.Normal] = {
      [1] = self.parent.img_profession_buff_1.img_num_006,
      [2] = self.parent.img_profession_buff_1.img_num_005,
      [3] = self.parent.img_profession_buff_1.img_num_004,
      [4] = self.parent.img_profession_buff_1.img_num_003,
      [5] = self.parent.img_profession_buff_1.img_num_002,
      [6] = self.parent.img_profession_buff_1.img_num_001,
      [7] = self.parent.img_profession_buff_1.img_num_0,
      [8] = self.parent.img_profession_buff_1.img_num_00
    }
  }
end

function ProfessionBuffShowHelper:RefreshProfessionBuffTips()
  if self.parent == nil then
    return
  end
  local buffId, buffLayer = self.buffData_:GetProfessionBuff()
  if not (buffId and buffLayer) or buffLayer <= 0 then
    self.curShowBuffId = nil
    self.parent:SetVisible(false)
    return
  end
  local fightResIconTableRow = Z.TableMgr.GetTable("FightResIconTableMgr").GetRow(buffId)
  if not fightResIconTableRow then
    self.parent:SetVisible(false)
    return
  end
  local uiShowType = fightResIconTableRow.UIShowType
  if uiShowType == nil then
    self.parent:SetVisible(false)
    return
  end
  self.parent:SetVisible(true)
  for type, value in ipairs(self.UIShowContainers) do
    value:SetVisible(uiShowType == type)
  end
  local layerMax = fightResIconTableRow.UIType[2]
  buffLayer = math.min(buffLayer, layerMax)
  if uiShowType == UIShowType.Normal then
    self:setNum(buffLayer, fightResIconTableRow.ResIcon, self.parent.img_profession_buff_1.img_num_1, self.parent.img_profession_buff_1.img_num_2)
    for index, value in ipairs(self.UIShowBgs_[uiShowType]) do
      value.Img:SetImage(fightResIconTableRow.ResBg .. "_" .. index)
    end
    if self.curShowBuffId ~= buffId then
      self.parent.img_profession_buff_1.anim.anim:PlayOnce("anim_img_profession_buff_open")
      self.parent.img_profession_buff_1.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "open", Vector3.zero)
    else
      self.parent.img_profession_buff_1.anim.anim:PlayOnce("anim_img_profession_buff_once")
      self.parent.img_profession_buff_1.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "once", Vector3.zero)
    end
    if self.nextStageTimer_ then
      self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
      self.nextStageTimer_ = nil
    end
    self.nextStageTimer_ = self.parentView.timerMgr:StartTimer(function()
      self.parent.img_profession_buff_1.anim.anim:PlayLoop("anim_img_profession_buff_loop")
    end, 0.5, 1)
  elseif uiShowType == UIShowType.SpecialNum then
    self:setNum(buffLayer, fightResIconTableRow.ResIcon, self.parent.img_profession_buff_3.img_num_1, self.parent.img_profession_buff_3.img_num_2)
    if self.curShowBuffId ~= buffId then
      self.parent.img_profession_buff_3.anim.anim:PlayOnce("anim_img_profession_buff_2_open_lightning")
      self.parent.img_profession_buff_3.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "open", Vector3.zero)
    else
      self.parent.img_profession_buff_3.anim.anim:PlayOnce("anim_img_profession_buff_2_once_lightning")
      self.parent.img_profession_buff_3.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "once", Vector3.zero)
    end
    if self.nextStageTimer_ then
      self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
      self.nextStageTimer_ = nil
    end
    self.nextStageTimer_ = self.parentView.timerMgr:StartTimer(function()
      self.parent.img_profession_buff_3.anim.anim:PlayLoop("anim_img_profession_buff_2_loop_lightning")
      self.parent.img_profession_buff_3.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "loop", Vector3.zero)
    end, 0.5, 1)
  elseif uiShowType == UIShowType.Special then
    if buffLayer == 1 then
      self.parent.img_profession_buff_2.img_profession_buff_2_50:SetVisible(true)
      self.parent.img_profession_buff_2.img_profession_buff_2_100:SetVisible(false)
    else
      self.parent.img_profession_buff_2.img_profession_buff_2_50:SetVisible(false)
      self.parent.img_profession_buff_2.img_profession_buff_2_100:SetVisible(true)
    end
    self.parent.img_profession_buff_2.anim.anim:PlayOnce("anim_img_profession_buff_2_" .. buffLayer .. "_open")
    self.parent.img_profession_buff_2.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "open_" .. buffLayer, Vector3.zero)
    if self.nextStageTimer_ then
      self.parentView.timerMgr:StopTimer(self.nextStageTimer_)
      self.nextStageTimer_ = nil
    end
    self.nextStageTimer_ = self.parentView.timerMgr:StartTimer(function()
      self.parent.img_profession_buff_2.anim.anim:PlayLoop("anim_img_profession_buff_2_" .. buffLayer .. "_loop")
      self.parent.img_profession_buff_2.effect.ZEff:CreatEFFGO(fightResIconTableRow.EffectResPath .. "loop_" .. buffLayer, Vector3.zero)
    end, 0.5, 1)
  end
  self.curShowBuffId = buffId
end

function ProfessionBuffShowHelper:setNum(buffLayer, icon, imgNum1, imgNum2)
  if 9 < buffLayer then
    imgNum1.Trans.localPosition = self.buffData_:GetProfessionBuffPosition1()
    imgNum1.Img:SetImage(string.zconcat(icon, "0", string.format("%d", buffLayer / 10)))
    imgNum2.Img:SetImage(string.zconcat(icon, "0", buffLayer % 10))
    imgNum2:SetVisible(true)
  else
    imgNum1.Trans.localPosition = self.buffData_:GetProfessionBuffPosition2()
    local icon = string.zconcat(icon, "0", buffLayer)
    imgNum1.Img:SetImage(icon)
    imgNum2:SetVisible(false)
  end
end

return ProfessionBuffShowHelper
