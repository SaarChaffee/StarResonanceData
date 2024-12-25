local BattleResUIHelper = class("BattleResUIHelper")
local normalIconPath = {
  on = "ui/atlas/mainui/new_else/main_beans_on",
  off = "ui/atlas/mainui/new_else/main_beans_off"
}
local UIType = {Dot = 1, Line = 2}
local RES_MAX_ID_OFFSET = 6

function BattleResUIHelper:ctor(container, viewParent)
  self.container_ = container
  self.viewParent_ = viewParent
  self.ResTemplate_ = {
    [UIType.Dot] = self.container_.layout_beans,
    [UIType.Line] = self.container_.bloodbg
  }
  self.ResBeans_ = {}
  self.beanEffTimer_ = {}
end

function BattleResUIHelper:loadMaxNumBean()
  local fightResTemplateData = Z.TableMgr.GetTable("FightResAttrTemplateTableMgr").GetDatas()
  local maxBeanNum = 0
  for _, resRow in pairs(fightResTemplateData) do
    for __, value in ipairs(resRow.UIType) do
      if maxBeanNum < value[2] then
        maxBeanNum = value[2]
      end
    end
  end
  local root = self.container_.layout_beans.Trans
  Z.CoroUtil.create_coro_xpcall(function()
    self.loadBeanFinish_ = false
    local beanPath = self.viewParent_:GetPrefabCacheData(Z.IsPCUI and "beanPathPC" or "beanPathMobile")
    for i = 1, maxBeanNum do
      local unit = self.viewParent_:AsyncLoadUiUnit(beanPath, "battle_bean_" .. i, root)
      self.ResBeans_[i] = unit
      unit.Ref.ZUIDepth:AddChildDepth(unit.ui_eff.ZEff)
      unit.Ref:SetVisible(true)
    end
    self.container_.lab_res_num.Trans:SetAsLastSibling()
    self.loadBeanFinish_ = true
    if self.needRefresh_ then
      self:refreshBeanStyle()
      self:Refresh()
    end
  end)()
end

function BattleResUIHelper:Active()
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.fightVm_ = Z.VMMgr.GetVM("fighterbtns")
  self.unLockBuffs_ = {}
  self.needInitData_ = true
  self:loadMaxNumBean()
end

function BattleResUIHelper:initData()
  local professionId = self.professionVm_:GetCurProfession()
  if professionId == 0 then
    return
  end
  local professionRow = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(professionId)
  if professionRow == nil then
    return
  end
  self.fightResTemplateRow_ = Z.TableMgr.GetTable("FightResAttrTemplateTableMgr").GetRow(professionRow.FightResTemplateId)
  if self.fightResTemplateRow_ == nil then
    return
  end
  self.beforeBeanNum_ = 0
  self.maxBeanNum_ = 0
  self.canPlaySliderEff_ = false
  self.needRefresh_ = false
  self.resTypes = {}
  self.needInitData_ = false
  self.container_:SetVisible(true)
  self:refreshResStyle()
end

function BattleResUIHelper:refreshBeanStyle()
  for i = 1, #self.ResBeans_ do
    if self.ResBeans_[i] then
      self.ResBeans_[i].ui_eff.ZEff:ReleseEffGo()
      self.ResBeans_[i].Ref:SetVisible(false)
    end
  end
  local color = "#ffffff"
  for _, value in ipairs(self.fightResTemplateRow_.BindElemental) do
    if tonumber(value[1]) == UIType.Dot then
      color = value[2]
    end
  end
  for i = 1, self.maxBeanNum_ do
    local unit = self.ResBeans_[i]
    unit.Ref:SetVisible(true)
    if string.zisEmpty(self.fightResTemplateRow_.ResIcon) then
      unit.img_on.Img:SetImage(normalIconPath.on)
      unit.img_off.Img:SetImage(normalIconPath.off)
      unit.img_on.Img:SetColorByHex(color)
    else
      local path = self.fightResTemplateRow_.ResIcon .. "on"
      unit.img_on.Img:SetImage(path)
      unit.img_off.Img:SetImage(self.fightResTemplateRow_.ResIcon .. "off")
      unit.img_on.Img:SetColorByHex(E.ColorHexValues.White)
    end
    unit.ui_eff.ZEff:CreatEFFGO(self.fightResTemplateRow_.ResEffect, Vector3.zero, false)
  end
end

function BattleResUIHelper:refreshResStyle()
  for _, value in pairs(self.ResTemplate_) do
    value:SetVisible(false)
  end
  for index, _ in ipairs(self.fightResTemplateRow_.ResIDs) do
    local resUIType = self.fightResTemplateRow_.UIType[index][1]
    self.maxBeanNum_ = self.fightResTemplateRow_.UIType[index][2] or 5
    local checkBuffId
    for _, buffTable in ipairs(self.fightResTemplateRow_.OpenBuff) do
      if buffTable[1] == resUIType then
        checkBuffId = buffTable[2]
      end
    end
    if resUIType and self.ResTemplate_[resUIType] and self:checkUnlock(checkBuffId) then
      self.ResTemplate_[resUIType]:SetVisible(true)
    else
      self.ResTemplate_[resUIType]:SetVisible(false)
    end
  end
  for _, value in ipairs(self.fightResTemplateRow_.UIType) do
    if tonumber(value[1]) == UIType.Dot then
      self.resTypes[UIType.Dot] = true
      if self.loadBeanFinish_ == false then
        self.needRefresh_ = true
        return
      end
      self:refreshBeanStyle()
    elseif tonumber(value[1]) == UIType.Line then
      self.container_.img_frame.Img:SetColorByHex(value[2])
      self.container_.img_bar.Img:SetColorByHex(value[2])
      self.resTypes[UIType.Line] = true
    end
  end
end

function BattleResUIHelper:Refresh()
  if self.needInitData_ then
    self:initData()
  end
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    local resId = value
    local maxResId = value + RES_MAX_ID_OFFSET
    local progressNow = self.fightVm_:GetBattleResValue(resId)
    local progressMax = self.fightVm_:GetBattleResValue(maxResId)
    local resUIType = self.fightResTemplateRow_.UIType[index][1]
    if resUIType then
      if resUIType == UIType.Dot then
        self:refreshUIDot(progressNow, progressMax)
      elseif resUIType == UIType.Line then
        self:refreshUILine(progressNow, progressMax)
      end
    end
  end
end

function BattleResUIHelper:OnBuffChange()
  local change = false
  local temp = table.zclone(self.unLockBuffs_)
  for checkBuffId, open in pairs(self.unLockBuffs_) do
    local curOpenState = self:checkUnlock(checkBuffId)
    if temp[checkBuffId] ~= curOpenState then
      change = true
    end
  end
  if change then
    self:initData()
    self:Refresh()
  end
end

function BattleResUIHelper:checkUnlock(checkBuffId)
  if checkBuffId == nil or checkBuffId == 0 then
    return true
  end
  local buffDataList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  if buffDataList then
    buffDataList = buffDataList.Value
    for i = 0, buffDataList.count - 1 do
      if buffDataList[i].BuffBaseId == checkBuffId then
        self.unLockBuffs_[checkBuffId] = true
        return true
      end
    end
  end
  self.unLockBuffs_[checkBuffId] = false
  return false
end

function BattleResUIHelper:refreshUIDot(nowNum, maxNum)
  if not self.loadBeanFinish_ then
    return
  end
  self.container_.lab_num:SetVisible(self.resTypes[UIType.Line])
  if maxNum > self.maxBeanNum_ then
    for _, value in ipairs(self.ResBeans_) do
      value:SetVisible(false)
    end
    self.ResBeans_[1]:SetVisible(true)
    self.ResBeans_[1].img_on:SetVisible(nowNum ~= 0)
    self.container_.lab_res_num:SetVisible(true)
    self.container_.lab_res_num.TMPLab.text = "x" .. string.format("%02d", nowNum)
    if nowNum > self.beforeBeanNum_ then
      self.ResBeans_[1].ui_eff.ZEff:SetEffectGoVisible(false)
      self.ResBeans_[1].ui_eff.ZEff:SetEffectGoVisible(true)
      if self.beanEffTimer_[1] then
        self.viewParent_.timerMgr:StopTimer(self.beanEffTimer_[1])
        self.beanEffTimer_[1] = nil
      end
      self.beanEffTimer_[1] = self.viewParent_.timerMgr:StartTimer(function()
        if self.ResBeans_[1] then
          self.ResBeans_[1].ui_eff.ZEff:SetEffectGoVisible(false)
        end
      end, 1, 1)
    end
  else
    self.container_.lab_res_num:SetVisible(false)
    for index, value in ipairs(self.ResBeans_) do
      value:SetVisible(maxNum >= index)
      value.img_on:SetVisible(nowNum >= index)
      if nowNum >= index and index > self.beforeBeanNum_ then
        value.ui_eff.ZEff:SetEffectGoVisible(false)
        value.ui_eff.ZEff:SetEffectGoVisible(true)
        if self.beanEffTimer_[index] then
          self.viewParent_.timerMgr:StopTimer(self.beanEffTimer_[index])
          self.beanEffTimer_[index] = nil
        end
        self.beanEffTimer_[index] = self.viewParent_.timerMgr:StartTimer(function()
          if self.ResBeans_[index] then
            self.ResBeans_[index].ui_eff.ZEff:SetEffectGoVisible(false)
          end
        end, 1, 1)
      end
    end
  end
  self.beforeBeanNum_ = nowNum
end

function BattleResUIHelper:refreshUILine(nowNum, maxNum)
  self.container_.lab_num:SetVisible(self.resTypes[UIType.Line])
  self.container_.node_slider_energy_bar.Slider.maxValue = maxNum
  self.container_.node_slider_energy_bar.Slider.value = nowNum
  self.container_.lab_num.TMPLab.text = nowNum .. "/" .. maxNum
  if maxNum <= nowNum and self.canPlaySliderEff_ then
    self.canPlaySliderEff_ = false
    self.container_.slider_eff.ZEff:SetEffectGoVisible(false)
    if self.lineEffectTimer then
      self.viewParent_.timerMgr:StopTimer(self.lineEffectTimer)
      self.lineEffectTimer = nil
    end
    self.lineEffectTimer = self.viewParent_.timerMgr:StartTimer(function()
      self.container_.slider_eff.ZEff:SetEffectGoVisible(false)
    end, 0.5, 1)
  end
  if nowNum < maxNum then
    self.canPlaySliderEff_ = true
  end
end

function BattleResUIHelper:DeActive()
  self.container_:SetVisible(false)
  for i = 1, #self.ResBeans_ do
    if self.ResBeans_[i] then
      self.ResBeans_[i].ui_eff.ZEff:ReleseEffGo()
      self.ResBeans_[i].Ref:SetVisible(false)
    end
  end
  for _, value in ipairs(self.beanEffTimer_) do
    if value then
      self.viewParent_.timerMgr:StopTimer(value)
    end
  end
  self.beanEffTimer_ = {}
  if self.lineEffectTimer then
    self.viewParent_.timerMgr:StopTimer(self.lineEffectTimer)
    self.lineEffectTimer = nil
  end
  self.maxBeanNum_ = 0
  self.canPlaySliderEff_ = false
  self.resTypes = {}
  self.needInitData_ = true
  self.beforeBeanNum_ = -1
end

function BattleResUIHelper:SetVisible(flag)
  self.container_:SetVisible(flag)
end

return BattleResUIHelper
