local UI = Z.UI
local super = require("ui.ui_subview_base")
local Life_profession_specialization_right_subView = class("Life_profession_specialization_right_subView", super)
local currency_item_list = require("ui.component.currency.currency_item_list")
local COLOR_NORMAL = Color.New(1, 1, 1, 1)
local COLOR_LOCK = Color.New(1, 1, 1, 0.2)

function Life_profession_specialization_right_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "life_profession_specialization_right_sub", "life_profession/life_profession_specialization_right_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "life_profession_specialization_right_sub", "life_profession/life_profession_specialization_right_sub", UI.ECacheLv.None)
  end
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
end

function Life_profession_specialization_right_subView:OnActive()
  self.uiBinder.Trans.sizeDelta = Vector2.zero
  self.proID = self.viewData.proID
  self.specID = self.viewData.specID
  self:initBtnClick()
  self:refreshView()
  self:bindEvents()
end

function Life_profession_specialization_right_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionPointChanged, self.lifeProfessionPointChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, self.lifeProfessionSpecChanged, self)
end

function Life_profession_specialization_right_subView:lifeProfessionLevelChanged(proID)
  if proID == self.proID then
    self:refreshView()
  end
end

function Life_profession_specialization_right_subView:lifeProfessionPointChanged()
  self:refreshView()
end

function Life_profession_specialization_right_subView:lifeProfessionSpecChanged(proID)
  if proID == self.proID then
    local curLevel = self.lifeProfessionVM.GetSpecializationLv(proID, self.curSpeConfig.Id)
    curLevel = curLevel == 0 and 1 or curLevel
    local specRow = self.lifeProfessionData_:GetSpecializationRow(self.curSpeConfig.GroupId, curLevel)
    self.specID = specRow.Id
    local maxLevel = self.lifeProfessionData_:GetSpecializationMaxLevel(self.proID, self.curSpeConfig.GroupId)
    if curLevel < maxLevel then
      local nextSpecRow = self.lifeProfessionData_:GetSpecializationRow(self.curSpeConfig.GroupId, curLevel + 1)
      self.specID = nextSpecRow.Id
    end
    self:refreshView()
  end
end

function Life_profession_specialization_right_subView:initBtnClick()
  self:AddAsyncClick(self.uiBinder.btn_square_new, function()
    self:OnLevelUpBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.viewData.closeFunc()
  end)
end

function Life_profession_specialization_right_subView:OnLevelUpBtnClick()
  self.lifeProfessionVM.AsyncRequestActivateSpecialization(self.proID, self.specID)
end

function Life_profession_specialization_right_subView:refreshView()
  local lifeFormulaTableRow = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetRow(self.specID)
  self.curSpeConfig = self.lifeProfessionVM.GetCurSpecialization(self.proID, self.specID, lifeFormulaTableRow.GroupId)
  if self.curSpeConfig == nil then
    return
  end
  self.uiBinder.img_icon:SetImage(self.curSpeConfig.Icon)
  self.uiBinder.lab_name.text = self.curSpeConfig.Name
  local curLevel = self.lifeProfessionVM.GetSpecializationLv(self.proID, self.specID)
  local maxLevel = self.lifeProfessionData_:GetSpecializationMaxLevel(self.proID, lifeFormulaTableRow.GroupId)
  self.uiBinder.lab_level.text = string.zconcat(curLevel, "/", maxLevel)
  self.uiBinder.lab_info.text = self.curSpeConfig.Des
  local isActive = self.lifeProfessionVM.IsSpecializationUnlocked(self.proID, self.specID)
  local meetCondition = Z.ConditionHelper.CheckCondition(self.curSpeConfig.UnlockCondition, false)
  local hasCondition = table.zcount(self.curSpeConfig.UnlockCondition) > 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_locked, not isActive and hasCondition)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_cost, not isActive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
  self.uiBinder.img_icon.color = isActive and COLOR_NORMAL or COLOR_LOCK
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unlock, not isActive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_maxLevel, isActive and curLevel == maxLevel)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_active, isActive and curLevel ~= maxLevel)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_locked, not isActive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_study, not isActive and meetCondition)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_cannot_study, not isActive and not meetCondition)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_learned, isActive)
  if not isActive then
    self:refreshConditions()
    self:refreshCost()
  end
  if not self.currencyItemList_ then
    self.currencyItemList_ = currency_item_list.new()
  end
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    Z.SystemItem.VigourItemId,
    self.lifeProfessionVM.GetSpcItemIDByProId(self.proID)
  })
end

function Life_profession_specialization_right_subView:refreshCost()
  local costItemID = self.lifeProfessionVM.GetSpcItemIDByProId()
  local itemVm_ = Z.VMMgr.GetVM("items")
  self.uiBinder.rimg_cost:SetImage(itemVm_.GetItemIcon(costItemID))
  local curHaveCount = self.lifeProfessionVM.GetSpcItemCnt(self.proID)
  local curNeed = self.curSpeConfig.NeedPoint
  if curHaveCount >= curNeed then
    self.uiBinder.lab_cost.text = Z.RichTextHelper.ApplyStyleTag("X" .. curNeed, "Normal")
  else
    self.uiBinder.lab_cost.text = Z.RichTextHelper.ApplyStyleTag("X" .. curNeed, "GashConsumableNotEnough")
  end
end

function Life_profession_specialization_right_subView:refreshConditions()
  if self.conditionDict ~= nil then
    for _, v in pairs(self.conditionDict) do
      self:RemoveUiUnit(v)
    end
  end
  local conditionDatas = Z.ConditionHelper.GetConditionDescList(self.curSpeConfig.UnlockCondition)
  self.conditionDict = {}
  for k, v in pairs(conditionDatas) do
    self.conditionDict[k] = "cond_" .. k
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local path_ = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "condition_tpl")
    for k, v in pairs(conditionDatas) do
      local name_ = self.conditionDict[k]
      local condition = self:AsyncLoadUiUnit(path_, name_, self.uiBinder.node_conditions)
      condition.lab_unlock_conditions.text = v.showPurview
      condition.Ref:SetVisible(condition.img_off, not v.IsUnlock)
      condition.Ref:SetVisible(condition.img_on, v.IsUnlock)
    end
  end)()
end

function Life_profession_specialization_right_subView:OnDeActive()
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
  Z.EventMgr:RemoveObjAll(self)
end

function Life_profession_specialization_right_subView:OnRefresh()
end

return Life_profession_specialization_right_subView
