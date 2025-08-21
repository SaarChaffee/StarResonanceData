local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_skill_upgrades_popupView = class("Weapon_skill_upgrades_popupView", super)
local itemClass = require("common.item_binder")

function Weapon_skill_upgrades_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_skill_upgrades_popup")
end

function Weapon_skill_upgrades_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.skillVm_ = Z.VMMgr.GetVM("skill")
  self.itemClassTab_ = {}
  self.itemUnits_ = {}
  self:AddClick(self.uiBinder.btn_close, function()
    self.weaponSkillVm_:CloseSkillLevelUpView()
  end)
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.replaceSkillId_ = self.weaponSkillVm_:GetReplaceSkillId(self.viewData.skillId)
  self.maxLevel_ = self.weaponSkillVm_:GetSkillCanLevelMax(self.replaceSkillId_, self.viewData.skillLevel, true)
  self.targetLevel_ = self.viewData.skillLevel + 1
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:checkItemEnought(self.targetLevel_)
    if self.notEnoughItem_ then
      if self.sourceTipId_ then
        Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
      end
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
      if itemConfig then
        Z.TipsVM.ShowTipsLang(1045006, {
          val = itemConfig.Name
        })
        self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.notEnoughItem_, self.uiBinder.tips_root)
      end
      return
    end
    self.weaponSkillVm_:AsyncProfessionSkillLevelUp(self.viewData.professionId, self.viewData.skillId, self.targetLevel_, self.viewData.skillType, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.uiBinder.btn_add, function()
    self:checkItemEnought(self.targetLevel_ + 1)
    if self.notEnoughItem_ then
      if self.sourceTipId_ then
        Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
      end
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
      if itemConfig then
        Z.TipsVM.ShowTipsLang(1045006, {
          val = itemConfig.Name
        })
        self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.notEnoughItem_, self.uiBinder.tips_root)
      end
      return
    end
    if self.targetLevel_ >= self.weaponSkillVm_:GetSkillMaxlevel(self.replaceSkillId_) then
      Z.TipsVM.ShowTipsLang(1042003)
      return
    end
    if self.targetLevel_ >= self.maxLevel_ then
      Z.TipsVM.ShowTipsLang(130034)
      return
    end
    self:refreshAllInfo(self.targetLevel_ + 1)
    self.uiBinder.slider_level.value = self.targetLevel_ - self.viewData.skillLevel
  end)
  self:AddAsyncClick(self.uiBinder.btn_reduce, function()
    if self.targetLevel_ <= self.viewData.skillLevel + 1 then
      return
    end
    self:refreshAllInfo(self.targetLevel_ - 1)
    self.uiBinder.slider_level.value = self.targetLevel_ - self.viewData.skillLevel
  end)
  self:AddAsyncClick(self.uiBinder.btn_max, function()
    self:checkItemEnought(self.targetLevel_ + 1)
    if self.notEnoughItem_ then
      if self.sourceTipId_ then
        Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
      end
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
      if itemConfig then
        Z.TipsVM.ShowTipsLang(1045006, {
          val = itemConfig.Name
        })
        self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.notEnoughItem_, self.uiBinder.tips_root)
      end
      return
    end
    if self.targetLevel_ >= self.maxLevel_ then
      return
    end
    self:refreshAllInfo(self.maxLevel_)
    self.uiBinder.slider_level.value = self.maxLevel_ - self.viewData.skillLevel
  end)
  self.uiBinder.slider_level.minValue = 1
  self.uiBinder.slider_level.maxValue = self.maxLevel_ - self.viewData.skillLevel
  self.uiBinder.slider_level.value = self.targetLevel_ - self.viewData.skillLevel
  self.uiBinder.slider_level:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local detlaLevel = math.floor(self.uiBinder.slider_level.value + self.viewData.skillLevel)
      self:refreshAllInfo(detlaLevel)
      self.uiBinder.slider_level.value = self.targetLevel_ - self.viewData.skillLevel
    end)()
  end)
  self:SetVisible(false)
  self:BindLuaAttrWatchers()
  self:BindEvents()
end

function Weapon_skill_upgrades_popupView:OnDeActive()
  self.notEnoughItem_ = nil
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
  self:UnBindLuaAttrWatchers()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.uiBinder.slider_level:RemoveAllListeners()
end

function Weapon_skill_upgrades_popupView:BindEvents()
  local closeView = function()
    local viewData = {
      viewType = E.UpgradeType.WeaponHeroSkillLevel,
      preLevel = self.viewData.skillLevel,
      level = self.targetLevel_,
      skillId = self.replaceSkillId_
    }
    self.weaponVm_.OpenUpgradeView(viewData)
    self.weaponSkillVm_:CloseSkillLevelUpView()
  end
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkillLevelUpSuccess, closeView, self)
end

function Weapon_skill_upgrades_popupView:BindLuaAttrWatchers()
end

function Weapon_skill_upgrades_popupView:UnBindLuaAttrWatchers()
end

function Weapon_skill_upgrades_popupView:refreshAllInfo(level)
  self.targetLevel_ = level
  self:RefreshSkillInfo(level)
  self:refreshCostInfo(level)
end

function Weapon_skill_upgrades_popupView:OnRefresh()
  self.notEnoughItem_ = nil
  self.cancelSource:CancelAll()
  self:ClearAllUnits()
  local redNodeName = self.weaponSkillVm_:GetSkillUpRedId(self.viewData.skillId)
  Z.RedPointMgr.LoadRedDotItem(redNodeName, self, self.uiBinder.btn_ok_trans)
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshAllInfo(self.targetLevel_)
    self:SetVisible(true)
  end)()
end

function Weapon_skill_upgrades_popupView:RefreshSkillInfo(level)
  local levelLabNow = Lang("Level", {
    val = self.viewData.skillLevel
  })
  local levelLabNext = Lang("Level", {val = level})
  self.uiBinder.lab_digit.text = level - self.viewData.skillLevel
  self.uiBinder.node_skill_info_pre.lab_lv.text = levelLabNow
  self.uiBinder.node_skill_info_cur.lab_lv.text = levelLabNext
  local skillTabData = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.replaceSkillId_)
  if skillTabData == nil then
    return
  end
  local skillFightData = self.weaponSkillVm_:GetSkillFightDataById(self.replaceSkillId_)
  local nowSkillFightLvTblData = skillFightData[level]
  local preSkillFightLvTblData = skillFightData[self.viewData.skillLevel]
  if nowSkillFightLvTblData == nil or preSkillFightLvTblData == nil then
    return
  end
  local remodelLevel = self.weaponSkillVm_:GetSkillRemodelLevel(self.replaceSkillId_)
  local nowSkillAttrDescList = self.skillVm_.GetSkillDecs(nowSkillFightLvTblData.Id, remodelLevel) or {}
  local preSkillAttrDescList = self.skillVm_.GetSkillDecs(preSkillFightLvTblData.Id, remodelLevel) or {}
  preSkillAttrDescList = self.skillVm_.GetSkillDecsWithColor(preSkillAttrDescList)
  nowSkillAttrDescList = self.skillVm_.ContrastSkillDecs(preSkillAttrDescList, nowSkillAttrDescList)
  local preSkillDesc = ""
  for _, value in ipairs(preSkillAttrDescList) do
    local content = value.Dec .. Lang(":") .. value.Num .. "\n"
    preSkillDesc = preSkillDesc .. content
  end
  local nowSkillDesc = ""
  for _, value in ipairs(nowSkillAttrDescList) do
    local content = value.Dec .. Lang(":") .. value.Num .. "\n"
    nowSkillDesc = nowSkillDesc .. content
  end
  self.uiBinder.node_skill_info_pre.lab_content.text = preSkillDesc
  self.uiBinder.node_skill_info_cur.lab_content.text = nowSkillDesc
end

function Weapon_skill_upgrades_popupView:checkItemEnought(level)
  self.notEnoughItem_ = nil
  local cost = {}
  local costRecord = {}
  local upgradeId = self.weaponSkillVm_:GetSkillUpgradeId(self.viewData.skillId)
  local skillConfig = Z.TableMgr.GetTable("SkillUpgradeTableMgr").GetDatas()
  for _, skillConfig in ipairs(skillConfig) do
    if skillConfig.UpgradeId == upgradeId and skillConfig.SkillLevel > self.viewData.skillLevel and level >= skillConfig.SkillLevel then
      for _, value in ipairs(skillConfig.Cost) do
        local temp = {}
        local itemId = value[1]
        if costRecord[itemId] then
          costRecord[itemId].itemCount = costRecord[itemId].itemCount + value[2]
        else
          temp.itemID = itemId
          temp.itemCount = value[2]
          table.insert(cost, temp)
          costRecord[itemId] = cost[#cost]
        end
      end
    end
  end
  for _, value in ipairs(cost) do
    local totalCount = self.itemVm_.GetItemTotalCount(value.itemID)
    if totalCount < value.itemCount and not self.notEnoughItem_ then
      self.notEnoughItem_ = value.itemID
    end
  end
  return cost
end

function Weapon_skill_upgrades_popupView:refreshCostInfo(level)
  local cost = self:checkItemEnought(level)
  for _, value in ipairs(self.itemUnits_) do
    self:RemoveUiUnit(value)
  end
  local btnDisabled = false
  local parent = self.uiBinder.item_root_content
  for _, value in ipairs(cost) do
    local totalCount = self.itemVm_.GetItemTotalCount(value.itemID)
    local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Backpack.BackPack_Item_Unit_Addr1_8_New), value.itemID, parent)
    table.insert(self.itemUnits_, value.itemID)
    self.itemClassTab_[value.itemID] = itemClass.new(self)
    self.itemClassTab_[value.itemID]:Init({
      uiBinder = unit,
      configId = value.itemID,
      labType = E.ItemLabType.Expend,
      lab = totalCount,
      expendCount = value.itemCount,
      isSquareItem = true
    })
    if totalCount < value.itemCount then
      btnDisabled = true
    end
  end
  self.uiBinder.btn_ok.IsDisabled = btnDisabled
end

return Weapon_skill_upgrades_popupView
