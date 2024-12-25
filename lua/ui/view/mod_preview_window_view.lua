local UI = Z.UI
local super = require("ui.ui_view_base")
local mod_preview_window_view = class("mod_preview_window_view", super)
local TalentSkillDefine = require("ui.model.talent_skill_define")
local loopListView = require("ui.component.loop_list_view")
local modPreviewListTplItem = require("ui.component.mod.mod_preview_list_tpl_item")
local modFantasyListTplItem = require("ui.component.mod.mod_fantasy_list_tpl_item")

function mod_preview_window_view:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_preview_window")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function mod_preview_window_view:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.btn_ask, function()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("mod_preview_window")
  end)
  self.effectList = loopListView.new(self, self.uiBinder.loop_item, modPreviewListTplItem, "mod_preview_list_tpl")
  self.effectLevelList = loopListView.new(self, self.uiBinder.loop_effect_level, modFantasyListTplItem, "mod_fantasy_list_tpl")
end

function mod_preview_window_view:OnDeActive()
  self.effectList:UnInit()
  self.effectList = nil
  self.effectLevelList:UnInit()
  self.effectLevelList = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function mod_preview_window_view:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function mod_preview_window_view:OnRefresh()
  self.effectListDatas_ = {}
  local index = 1
  self.effectLevelListDatas_ = {}
  local allEffects = self.modData_:GetAllEffectList()
  for _, effects in pairs(allEffects) do
    local effectId = effects[1].EffectID
    local maxLevel = #effects - 1
    local lv = self.modVM_.GetEquipEffectLevel(effectId)
    if lv == nil then
      lv = 0
    end
    local modPreviewListTplItemData = {
      id = effectId,
      lv = lv,
      maxLv = maxLevel,
      isSelect = false
    }
    self.effectListDatas_[index] = modPreviewListTplItemData
    index = index + 1
  end
  table.sort(self.effectListDatas_, function(a, b)
    if a.lv == b.lv then
      return a.id < b.id
    else
      return a.lv >= b.lv
    end
  end)
  self.effectListDatas_[1].isSelect = true
  self.selectEffectId_ = self.effectListDatas_[1].id
  self:refreshEffectLevelList(true)
end

function mod_preview_window_view:refreshEffectLevelList(isInit)
  self.effectLevelListDatas_ = {}
  local levelIndex = 1
  self.curEffectLevel = self.modVM_.GetEquipEffectLevel(self.selectEffectId_)
  local configs = self.modData_:GetEffectTableConfigList(self.selectEffectId_)
  local maxLv = #configs - 1
  for _, config in ipairs(configs) do
    local modFantasyListTplItem = {
      id = config.EffectID,
      lv = config.Level,
      maxLv = maxLv,
      curLv = self.curEffectLevel
    }
    self.effectLevelListDatas_[levelIndex] = modFantasyListTplItem
    levelIndex = levelIndex + 1
  end
  if isInit then
    self.effectList:Init(self.effectListDatas_)
    self.effectLevelList:Init(self.effectLevelListDatas_)
  else
    self.effectList:RefreshListView(self.effectListDatas_, false)
    self.effectLevelList:RefreshListView(self.effectLevelListDatas_, true)
  end
end

function mod_preview_window_view:OnSelectEffect(effectId)
  for _, data in ipairs(self.effectListDatas_) do
    data.isSelect = data.id == effectId
  end
  self.selectEffectId_ = effectId
  self:refreshEffectLevelList()
end

return mod_preview_window_view
