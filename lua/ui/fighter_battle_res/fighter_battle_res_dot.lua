local fighterBattleResDot = class("fighterBattleResDot")
local normalIconPath = {
  on = "ui/atlas/mainui/new_else/main_beans_on",
  off = "ui/atlas/mainui/new_else/main_beans_off"
}

function fighterBattleResDot:ctor()
  self.timerMgr = Z.TimerMgr.new()
  self.resDots_ = {}
  self.resCds_ = {}
  self.maxBeanNum_ = 6
end

function fighterBattleResDot:Active(uibinder, fightResTemplateRow_, resId, openBuff)
  self.uibinder_ = uibinder
  self.resId_ = resId
  self.fightResTemplateRow_ = fightResTemplateRow_
  self.openBuff_ = openBuff
  self.isHideDotCd_ = false
  self.beforeBeanNum_ = 0
  self.beanEffTimer_ = {}
  for i = 1, self.maxBeanNum_ do
    self.resDots_[i] = self.uibinder_["battle_res_bean_" .. i]
  end
  self:refreshStyle()
end

function fighterBattleResDot:refreshStyle()
  if self.fightResTemplateRow_ == nil then
    return
  end
  for i = 1, #self.resDots_ do
    if self.resDots_[i] then
      self.resDots_[i].ui_eff:ReleseEffGo()
      self.resDots_[i].Ref.UIComp:SetVisible(false)
    end
  end
  local color = "#ffffff"
  for _, value in ipairs(self.fightResTemplateRow_.BindElemental) do
    if tonumber(value[1]) == E.ResUIType.Dot then
      color = value[2]
      break
    end
  end
  for i = 1, self.maxBeanNum_ do
    local unit = self.resDots_[i]
    unit.Ref.UIComp:SetVisible(true)
    if string.zisEmpty(self.fightResTemplateRow_.ResIcon) then
      unit.img_on:SetImage(normalIconPath.on)
      unit.img_off:SetImage(normalIconPath.off)
      unit.img_mask:SetImage(normalIconPath.off)
      unit.img_on:SetColorByHex(color)
    else
      local path = self.fightResTemplateRow_.ResIcon .. "on"
      unit.img_on:SetImage(path)
      unit.img_off:SetImage(self.fightResTemplateRow_.ResIcon .. "off")
      unit.img_mask:SetImage(self.fightResTemplateRow_.ResIcon .. "off")
      unit.img_mask.fillAmount = 0
      unit.img_on:SetColorByHex(E.ColorHexValues.White)
    end
    unit.ui_eff:CreatEFFGO(self.fightResTemplateRow_.ResEffect, Vector3.zero, false)
  end
  self.beforeBeanNum_ = self.maxBeanNum_
end

function fighterBattleResDot:Refresh(nowNum, maxNum)
  if self.uibinder_ == nil then
    return
  end
  if self.beanSizeX_ == nil then
    self.beanSizeX_ = self.resDots_[1].Trans:GetSize(nil, nil)
  end
  if maxNum > self.maxBeanNum_ then
    for index, value in ipairs(self.resDots_) do
      if index ~= 1 then
        value.Ref.UIComp:SetVisible(false)
      else
        value.Ref.UIComp:SetVisible(true)
      end
    end
    self.resDots_[1].Ref:SetVisible(self.resDots_[1].img_on, 0 < nowNum)
    self.uibinder_.lab_res_num.text = "x" .. nowNum
    if nowNum > self.beforeBeanNum_ and not self.isHideDotCd_ then
      self.resDots_[1].ui_eff:SetEffectGoVisible(false)
      self.resDots_[1].ui_eff:SetEffectGoVisible(true)
      if self.beanEffTimer_[1] then
        self.timerMgr:StopTimer(self.beanEffTimer_[1])
        self.beanEffTimer_[1] = nil
      end
      self.beanEffTimer_[1] = self.timerMgr:StartTimer(function()
        if self.resDots_[1] then
          self.resDots_[1].ui_eff:SetEffectGoVisible(false)
        end
      end, 1, 1)
    end
  else
    self.uibinder_.lab_res_num.text = ""
    for index, value in ipairs(self.resDots_) do
      value.Ref.UIComp:SetVisible(maxNum >= index)
      value.Ref:SetVisible(value.img_on, nowNum >= index)
      if nowNum >= index and index > self.beforeBeanNum_ and not self.isHideDotCd_ then
        value.ui_eff:SetEffectGoVisible(false)
        value.ui_eff:SetEffectGoVisible(true)
        if self.beanEffTimer_[index] then
          self.timerMgr:StopTimer(self.beanEffTimer_[index])
          self.beanEffTimer_[index] = nil
        end
        self.beanEffTimer_[index] = self.timerMgr:StartTimer(function()
          if self.resDots_[index] then
            self.resDots_[index].ui_eff:SetEffectGoVisible(false)
          end
        end, 1, 1)
      end
    end
  end
  self.nowMaxNum_ = maxNum
  self.beforeBeanNum_ = nowNum
  if nowNum == maxNum then
    self.resCds_[self.resId_] = {}
  end
  self:refreshUIDotCd(self.resCds_[self.resId_])
end

function fighterBattleResDot:OnBuffChange()
  if self.uibinder_ == nil then
    return
  end
  if self.openBuff_ == nil then
    self.uibinder_.Ref.UIComp:SetVisible(true)
    return
  end
  local show = self:checkUnlock(self.openBuff_)
  self.uibinder_.Ref.UIComp:SetVisible(show)
end

function fighterBattleResDot:checkUnlock(checkBuffId)
  if checkBuffId == nil or checkBuffId == 0 then
    return true
  end
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local buffDataList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  if buffDataList then
    buffDataList = buffDataList.Value
    for i = 0, buffDataList.count - 1 do
      if buffDataList[i].BuffBaseId == checkBuffId then
        return true
      end
    end
  end
  return false
end

function fighterBattleResDot:OnBattleResCdChange(resId, fightResCd)
  if self.resId_ == resId then
    self.resCds_[resId] = {}
    for i = 0, fightResCd.count - 1 do
      table.insert(self.resCds_[resId], 1, fightResCd[i])
    end
    self:refreshUIDotCd(self.resCds_[resId])
  end
end

function fighterBattleResDot:refreshUIDotCd(fightResCd)
  if fightResCd == nil then
    return
  end
  if self.beforeBeanNum_ >= self.maxBeanNum_ then
    return
  end
  for _, value in ipairs(self.resDots_) do
    value.mask_time_count_down:StopCountDownTime()
    value.img_mask.fillAmount = 0
    value.lab_cd.text = ""
  end
  if self.isHideDotCd_ then
    for _, value in ipairs(self.resDots_) do
      value.Ref:SetVisible(value.img_on, true)
    end
    return
  end
  local i = 0
  for _, value in ipairs(fightResCd) do
    local now = Z.TimeTools:Now()
    if value >= now then
      self.resDots_[self.nowMaxNum_ - i].mask_time_count_down:StartMSCountDownTime(now, value, "", nil, function()
        self:refreshUIDotCd(fightResCd)
      end)
      i = i + 1
    end
  end
end

function fighterBattleResDot:HideUIDotCd(hide)
  self.isHideDotCd_ = hide
  self:refreshUIDotCd(self.resCds_[self.resId_])
end

function fighterBattleResDot:DisplayEffect(isOpen, param)
  for index, unit in ipairs(self.resDots_) do
    unit.ui_display_eff:ReleseEffGo()
    if isOpen then
      unit.ui_display_eff:CreatEFFGOWithCallBack(param[4], true, Vector3.zero, function()
        if tonumber(param[3]) == 1 then
          unit.ui_display_eff:UpdateDepth(1, true)
        else
          unit.ui_display_eff:UpdateDepth(-300, true)
        end
      end)
    end
  end
end

function fighterBattleResDot:DeActive()
  for i = 1, #self.resDots_ do
    if self.resDots_[i] then
      self.resDots_[i].ui_eff:ReleseEffGo()
      self.resDots_[i].Ref.UIComp:SetVisible(false)
    end
  end
  for _, value in ipairs(self.beanEffTimer_) do
    if value then
      self.timerMgr:StopTimer(value)
    end
  end
  self.isHideDotCd_ = false
  self.beanEffTimer_ = {}
  self.beforeBeanNum_ = 0
  self.timerMgr:Clear()
end

return fighterBattleResDot
