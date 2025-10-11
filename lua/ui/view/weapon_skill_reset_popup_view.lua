local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_skill_reset_popupView = class("Weapon_skill_reset_popupView", super)
local itemBinder = require("common.item_binder")

function Weapon_skill_reset_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_skill_reset_popup")
end

function Weapon_skill_reset_popupView:OnActive()
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self:initData()
  self:initBtn()
  self:initUI()
end

function Weapon_skill_reset_popupView:initData()
  self.curProfessionId_ = self.professionVm_:GetContainerProfession()
  self.professionSysRow_ = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.curProfessionId_)
  if not self.professionSysRow_ then
    return
  end
  self.allSkill_ = {}
  for _, value in ipairs(self.professionSysRow_.NormalAttackSkill) do
    table.insert(self.allSkill_, value)
  end
  for _, value in ipairs(self.professionSysRow_.SpecialSkill) do
    table.insert(self.allSkill_, value)
  end
  for _, value in ipairs(self.professionSysRow_.UltimateSkill) do
    table.insert(self.allSkill_, value)
  end
  for _, value in ipairs(self.professionSysRow_.NormalSkill) do
    table.insert(self.allSkill_, value)
  end
  self.itemClass_ = {}
  self.notEnoughItem_ = 0
  self.costItem_ = {}
  self.levelCostItem_ = {}
  self.remodelCostItem_ = {}
  for _, value in ipairs(self.allSkill_) do
    local costItem, levelUpCostItemId, remodelLevelCostItemId = self.weaponSkillVm_:CalSkillCostItem(value)
    for itemId, itemCount in pairs(costItem) do
      if self.costItem_[itemId] == nil then
        self.costItem_[itemId] = 0
      end
      self.costItem_[itemId] = self.costItem_[itemId] + itemCount
    end
    for __, itemId in ipairs(levelUpCostItemId) do
      if not table.zcontains(self.levelCostItem_, itemId) then
        table.insert(self.levelCostItem_, itemId)
      end
    end
    for __, itemId in ipairs(remodelLevelCostItemId) do
      if not table.zcontains(self.remodelCostItem_, itemId) then
        table.insert(self.remodelCostItem_, itemId)
      end
    end
  end
  self.resetCount_ = 0
end

function Weapon_skill_reset_popupView:initBtn()
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.weaponSkillVm_:CloseSkillResetView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    self.weaponSkillVm_:CloseSkillResetView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    if table.zcount(self.costItem_) == 0 then
      Z.TipsVM.ShowTips(150043)
      return
    end
    if self.viewData.isActivity then
      if self.resetCount_ == 0 then
        Z.TipsVM.ShowTips(150039)
        return
      end
      if self.uiBinder.node_reset_activity.input_announce.text == Lang(Z.Global.SkillResetActivityTxt) then
        local success = self.weaponSkillVm_:AsyncProfessionSkillResetSpecial(self.curProfessionId_, self.cancelSource:CreateToken())
        if success then
          self.weaponSkillVm_:CloseSkillResetView()
        end
      else
        Z.TipsVM.ShowTips(150040)
      end
    else
      if self.notEnoughItem_ ~= 0 then
        if self.sourceTipId_ then
          Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
        end
        local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
        if itemConfig then
          Z.TipsVM.ShowTipsLang(1045006, {
            val = itemConfig.Name
          })
          self.sourceTipId_ = Z.TipsVM.ShowItemTipsView(self.returnItemRoot_, self.notEnoughItem_)
        end
        return
      end
      local success = self.weaponSkillVm_:AsyncProfessionSkillReset(self.curProfessionId_, self.cancelSource:CreateToken())
      if success then
        self.weaponSkillVm_:CloseSkillResetView()
      end
    end
  end)
end

function Weapon_skill_reset_popupView:initUI()
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.labTitle_ = self.uiBinder.lab_title
  if self.viewData.isActivity then
    self.labName_ = self.uiBinder.node_reset_activity.lab_name
    self.labContent_ = self.uiBinder.node_reset_activity.lab_content
    self.labCount_ = self.uiBinder.node_reset_activity.lab_num
    self.labTime_ = self.uiBinder.node_reset_activity.lab_time
    self.labTips_ = self.uiBinder.node_reset_activity.lab_tips_02
    self.returnItemRoot_ = self.uiBinder.node_reset_activity.layout_item
    self.lab_item_return_tips_ = self.uiBinder.node_reset_activity.lab_item_return_tips
  else
    self.labName_ = self.uiBinder.node_reset.lab_name
    self.labContent_ = self.uiBinder.node_reset.lab_content
    self.returnItemRoot_ = self.uiBinder.node_reset.item_return_root
    self.costItemRoot_ = self.uiBinder.node_reset.item_cost_root
    self.lab_item_return_tips_ = self.uiBinder.node_reset.lab_item_return_tips
  end
end

function Weapon_skill_reset_popupView:OnRefresh()
  self.labName_.text = Lang("CurProfession", {
    str = self.professionSysRow_.Name
  })
  if self.viewData.isActivity then
    self:refreshActivityUI()
  else
    self:refreshNormalUI()
  end
  if table.zcount(self.costItem_) == 0 then
    self.lab_item_return_tips_.text = Lang("NoReturnItemTips")
    self.labContent_.text = Lang("NoReturnItemTips")
  else
    self.lab_item_return_tips_.text = Lang("WillReturnItemAfterReset")
  end
end

function Weapon_skill_reset_popupView:refreshNormalUI()
  self.uiBinder.node_reset.Ref.UIComp:SetVisible(true)
  self.uiBinder.node_reset_activity.Ref.UIComp:SetVisible(false)
  self.labTitle_.text = Lang("SkillReset")
  self:refreshReturnLabTips(self.levelCostItem_, self.remodelCostItem_)
  self:refreshReturnItem(self.costItem_)
  self:refreshCostItem()
end

function Weapon_skill_reset_popupView:refreshActivityUI()
  self.uiBinder.node_reset.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_reset_activity.Ref.UIComp:SetVisible(true)
  local countId = Z.Global.SkillResetActivityReturnCounterId
  local finishCount = Z.CounterHelper.GetOwnCount(countId)
  local totalCount = Z.CounterHelper.GetCounterLimitCount(countId)
  self.resetCount_ = totalCount - finishCount
  self.labCount_.text = Lang("RemainingCount", {
    val1 = self.resetCount_,
    val2 = totalCount
  })
  self.labTips_.text = Lang("SkillResetActivityTips", {
    val1 = totalCount,
    val2 = Lang(Z.Global.SkillResetActivityTxt)
  })
  self.labTitle_.text = Lang("SkillResetActivity")
  self.uiBinder.node_reset_activity.input_announce.text = ""
  local timerId = Z.CounterHelper.GetCounterTimerId(countId)
  local endLeftTime_, startLeftTime_ = Z.TimeTools.GetLeftTimeByTimerId(timerId)
  self.labTime_.text = Lang("FunctionCloseTime", {
    str = Z.TimeFormatTools.FormatToDHMS(endLeftTime_)
  })
  local returnItem = {}
  local levelCostReturnItem = {}
  local remodelCostReturnItem = {}
  for itemId, itemCount in pairs(self.costItem_) do
    local returnItemId = 0
    for _, value in ipairs(Z.Global.SkillResetActivityReturnItemId) do
      if itemId == value[1] then
        returnItemId = value[2]
      end
    end
    if returnItemId == 0 then
      returnItemId = itemId
      table.insert(levelCostReturnItem, itemId)
    else
      table.insert(remodelCostReturnItem, returnItemId)
    end
    returnItem[returnItemId] = itemCount
  end
  self:refreshReturnLabTips(levelCostReturnItem, remodelCostReturnItem)
  self:refreshReturnItem(returnItem)
end

function Weapon_skill_reset_popupView:refreshReturnLabTips(levelCostReturnItem, remodelCostReturnItem)
  local skillLevelCostStr = ""
  local tipsType = 0
  for index, itemId in ipairs(levelCostReturnItem) do
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
    if itemRow then
      skillLevelCostStr = skillLevelCostStr .. itemRow.Name
    end
    if index < #levelCostReturnItem then
      skillLevelCostStr = skillLevelCostStr .. Lang("Comma")
    end
    tipsType = tipsType + 1
  end
  local skillRemodelCostStr = ""
  for index, itemId in ipairs(remodelCostReturnItem) do
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
    if itemRow then
      skillRemodelCostStr = skillRemodelCostStr .. itemRow.Name
    end
    if index < #remodelCostReturnItem then
      skillRemodelCostStr = skillRemodelCostStr .. Lang("Comma")
    end
    tipsType = tipsType + 2
  end
  self.labContent_.text = Lang("SkillResetTips_" .. tipsType, {
    val1 = self.professionSysRow_.Name,
    val2 = skillLevelCostStr,
    val3 = skillRemodelCostStr
  })
end

function Weapon_skill_reset_popupView:refreshReturnItem(returnItem)
  local itemPath = self.prefabCache_:GetString("skill_reset_return_item")
  local root = self.returnItemRoot_
  Z.CoroUtil.create_coro_xpcall(function()
    for itemId, itemCount in pairs(returnItem) do
      local itemName = "reset_return_item_" .. itemId
      local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, root)
      itemUnit.lab_num.text = itemCount
      self.itemClass_[itemId] = itemBinder.new(self)
      local itemData = {
        uiBinder = itemUnit.item,
        configId = itemId,
        labType = E.ItemLabType.Str,
        lab = ""
      }
      self.itemClass_[itemId]:Init(itemData)
    end
  end)()
end

function Weapon_skill_reset_popupView:refreshCostItem()
  local itemPath = self.prefabCache_:GetString("skill_reset_cost_item")
  local root = self.costItemRoot_
  Z.CoroUtil.create_coro_xpcall(function()
    for _, value in pairs(Z.Global.SkillResetConsumeItemId) do
      local itemId = value[1]
      local itemCount = value[2]
      local itemName = "reset_cost_item_" .. itemId
      local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, root)
      self.itemClass_[itemId] = itemBinder.new(self)
      local totalCount = self.itemsVM_.GetItemTotalCount(itemId)
      local itemData = {
        uiBinder = itemUnit,
        configId = itemId,
        labType = E.ItemLabType.Expend,
        expendCount = itemCount,
        lab = totalCount
      }
      if itemCount > totalCount then
        self.notEnoughItem_ = itemId
      end
      self.itemClass_[itemId]:Init(itemData)
    end
  end)()
end

function Weapon_skill_reset_popupView:OnDeActive()
  for index, value in pairs(self.itemClass_) do
    value:UnInit()
  end
  self.itemClass_ = {}
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
  end
end

return Weapon_skill_reset_popupView
