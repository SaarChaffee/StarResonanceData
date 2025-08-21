local UI = Z.UI
local super = require("ui.ui_view_base")
local Mod_term_recommend_popupView = class("Mod_term_recommend_popupView", super)
local loopGridView = require("ui/component/loop_grid_view")
local modRecommendTplItem = require("ui.component.mod.mod_recommend_tpl_item")
local TalentSkillDefine = require("ui.model.talent_skill_define")

function Mod_term_recommend_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_term_recommend_popup")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.talentSkillData_ = Z.DataMgr.Get("talent_skill_data")
  self.talentSkillVM_ = Z.VMMgr.GetVM("talent_skill")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.professionConfigs_ = {}
  local index = 0
  local tempConfigs = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  for _, config in pairs(tempConfigs) do
    if config.IsOpen then
      index = index + 1
      self.professionConfigs_[index] = config.Id
    end
  end
end

function Mod_term_recommend_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_recommend, function()
    if self.showTalentStage_ then
      for _, recommendModEffect in ipairs(self.showTalentStage_.RecommendModEffectId) do
        self.SelectEffectId[recommendModEffect] = recommendModEffect
      end
    end
    self.itemsModGridView_:RefreshListView(self.effects_, true)
  end)
  self:AddClick(self.uiBinder.btn_certain, function()
    if self.viewData and self.viewData.func then
      self.viewData.func(self.SelectEffectId)
    end
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.tog_1:AddListener(function()
    self:changeTalentBdType(0)
  end, true)
  self.uiBinder.tog_2:AddListener(function()
    self:changeTalentBdType(1)
  end, true)
  self.uiBinder.dpd:AddListener(function(index)
    if #self.modTermPoolIds_ > 0 and index + 1 <= #self.modTermPoolIds_ then
      local professionId = self.modTermPoolIds_[index + 1]
      self:changeProfessionId(professionId)
    end
  end, true)
  self.itemsModGridView_ = loopGridView.new(self, self.uiBinder.loop_item, modRecommendTplItem, "mod_recommend_tpl")
  self.itemsModGridView_:Init({})
  self.SelectEffectId = {}
  self.modTermPoolNames_ = {}
  self.modTermPoolIds_ = {}
  self.professionId_ = nil
  self.showTalentStage_ = nil
  self.effects_ = {}
  local allEffects = self.modData_:GetAllEffectList()
  for effectId, configs in pairs(allEffects) do
    if configs[1] ~= nil and not configs[1].IsShowShield then
      table.insert(self.effects_, {Id = effectId, recommend = false})
    end
  end
  self:onGetAllName()
  self:changeProfessionId(self.weaponVM_.GetCurWeapon())
end

function Mod_term_recommend_popupView:onGetAllName()
  local mgr = Z.TableMgr.GetTable("ProfessionSystemTableMgr")
  for i = 1, #self.professionConfigs_ do
    local professionId = self.professionConfigs_[i]
    local config = mgr.GetRow(professionId)
    if config then
      table.insert(self.modTermPoolNames_, config.Name)
      table.insert(self.modTermPoolIds_, professionId)
    end
  end
end

function Mod_term_recommend_popupView:OnDeActive()
  if self.itemsModGridView_ then
    self.itemsModGridView_:UnInit()
    self.itemsModGridView_ = nil
  end
  if Z.UIMgr:IsActive("mod_item_popup") then
    Z.UIMgr:CloseView("mod_item_popup")
  end
end

function Mod_term_recommend_popupView:OnRefresh()
  if #self.modTermPoolIds_ > 0 then
    local curIndex = self:getCurrentIndex()
    self:refreshDropDown(curIndex)
  end
end

function Mod_term_recommend_popupView:refreshDropDown(indexKey)
  self.uiBinder.dpd:ClearOptions()
  self.uiBinder.dpd:AddOptions(self.modTermPoolNames_)
  self.uiBinder.dpd.value = indexKey
end

function Mod_term_recommend_popupView:getCurrentIndex()
  for k, v in pairs(self.modTermPoolIds_) do
    if v == self.professionId_ then
      return k - 1
    end
  end
end

function Mod_term_recommend_popupView:changeProfessionId(id)
  if self.professionId_ and self.professionId_ == id then
    return
  end
  self.professionId_ = id
  self.talentStageConfigs_ = self.talentSkillData_:GetTalentStageConfigs(id, TalentSkillDefine.TalentTreeMaxStage - 1)
  local name = ""
  local nameConnect
  local professionConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(id)
  if professionConfig then
    name = professionConfig.Name
  end
  if id == self.weaponVM_.GetCurWeapon() then
    local talentStageId = self.talentSkillVM_.GetCurProfessionTalentStage()
    local talentStageConfig = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(talentStageId)
    if talentStageConfig and talentStageConfig.TalentStage == self.talentStageConfigs_[0].TalentStage then
      if talentStageConfig.BdType == 0 then
        self.uiBinder.lab_tog_title_1.text = self.talentStageConfigs_[0].Name[2] .. Lang("FilterCurrent")
        self.uiBinder.lab_tog_title_2.text = self.talentStageConfigs_[1].Name[2]
      else
        self.uiBinder.lab_tog_title_1.text = self.talentStageConfigs_[0].Name[2]
        self.uiBinder.lab_tog_title_2.text = self.talentStageConfigs_[1].Name[2] .. Lang("FilterCurrent")
      end
      self:changeTalentBdType(talentStageConfig.BdType)
    else
      self.uiBinder.lab_tog_title_1.text = self.talentStageConfigs_[0].Name[2]
      self.uiBinder.lab_tog_title_2.text = self.talentStageConfigs_[1].Name[2]
      self:changeTalentBdType(0)
    end
    nameConnect = Lang("FilterCurrent")
  else
    self.uiBinder.lab_tog_title_1.text = self.talentStageConfigs_[0].Name[2]
    self.uiBinder.lab_tog_title_2.text = self.talentStageConfigs_[1].Name[2]
    self:changeTalentBdType(0)
    nameConnect = Lang("FilterNotCurProfression")
  end
  self.uiBinder.lab_name.text = name .. nameConnect
end

function Mod_term_recommend_popupView:changeTalentBdType(bdType)
  self.SelectEffectId = {}
  self.uiBinder.tog_1:SetIsOnWithoutCallBack(bdType == 0)
  self.uiBinder.tog_2:SetIsOnWithoutCallBack(bdType == 1)
  self:changeTalentStageId(self.talentStageConfigs_[bdType])
end

function Mod_term_recommend_popupView:changeTalentStageId(talentStageConfig)
  if talentStageConfig == nil then
    return
  end
  if self.showTalentStage_ and self.showTalentStage_Id == talentStageConfig.Id then
    return
  end
  self.showTalentStage_ = talentStageConfig
  local tempRecommendEffect = {}
  if talentStageConfig then
    for _, recommendModEffect in ipairs(talentStageConfig.RecommendModEffectId) do
      tempRecommendEffect[recommendModEffect] = recommendModEffect
    end
  end
  for _, value in ipairs(self.effects_) do
    value.recommend = tempRecommendEffect[value.Id] ~= nil
  end
  table.sort(self.effects_, function(a, b)
    local aState = a.recommend and 0 or 1
    local bState = b.recommend and 0 or 1
    if aState == bState then
      return a.Id < b.Id
    else
      return aState < bState
    end
  end)
  self.itemsModGridView_:RefreshListView(self.effects_, true)
end

return Mod_term_recommend_popupView
