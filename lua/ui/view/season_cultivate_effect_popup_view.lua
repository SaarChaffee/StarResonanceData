local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_cultivate_effect_popupView = class("Season_cultivate_effect_popupView", super)
local TALENT_DEFINE = require("ui.model.talent_define")

function Season_cultivate_effect_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_cultivate_effect_popup")
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
end

function Season_cultivate_effect_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self:onStartAnimShow()
  self:initComps()
  self:OnAddListeners()
end

function Season_cultivate_effect_popupView:initComps()
  self.btn_close_ = self.uiBinder.btn_close
  self.node_echo_effect_items_ = {
    self.uiBinder.node_total_effect_item1,
    self.uiBinder.node_total_effect_item2,
    self.uiBinder.node_total_effect_item3,
    self.uiBinder.node_total_effect_item4,
    self.uiBinder.node_total_effect_item5,
    self.uiBinder.node_total_effect_item6
  }
  self.node_core_effect_items_ = {
    self.uiBinder.node_select_effect_item1,
    self.uiBinder.node_select_effect_item2,
    self.uiBinder.node_select_effect_item3
  }
  self.corelockLab_ = self.uiBinder.lab_lock_entry
end

function Season_cultivate_effect_popupView:OnAddListeners()
  self:AddClick(self.btn_close_, function()
    self.seasonCultivateVM_.CloseEffectPopupView()
  end)
end

function Season_cultivate_effect_popupView:OnDeActive()
  Z.CommonTipsVM.CloseRichText()
end

function Season_cultivate_effect_popupView:OnRefresh()
  self:showEchoEffects()
  self:showCoreSelectEffects()
end

function Season_cultivate_effect_popupView:showEchoEffects()
  local infos = self.seasonCultivateVM_:GetAllNormalNodeInfo()
  for index, value in ipairs(infos) do
    self:showEffect(self.node_echo_effect_items_[index], value)
  end
end

function Season_cultivate_effect_popupView:showEffect(uibinder, info)
  uibinder.img_icon:SetImage(info.attrConfig.NodeIcon)
  local type, name, num = self.seasonCultivateVM_.GetNodeEffectDes(info.attrConfig)
  if type == TALENT_DEFINE.TalentEffectType.Property then
    uibinder.lab_num.text = num
  else
    uibinder.lab_num.text = ""
  end
  uibinder.lab_level.text = string.zconcat(info.attrConfig.NodeName, " ", Lang("Grade", {
    val = info.nodeLevel
  }))
  Z.RichTextHelper.SetBinderTmpLabTextWithCommonLink(uibinder.lab_content, self.seasonCultivateVM_.GetAttributeDes(info.attrConfig.Id))
end

function Season_cultivate_effect_popupView:showCoreSelectEffects()
  self:hideAllSelectEffect()
  local infos = self.seasonCultivateVM_.GetCoreNodeInfo(true)
  local canSelectedCount = self.seasonCultivateVM_.GetNowCanSelectedCoreCount()
  if canSelectedCount == 0 then
    local limit = Z.Global.EffectiveNodeNum
    if limit and limit[1] then
      self.corelockLab_.text = Lang("SeasonCultivateLockCoreTips", {
        val = limit[1][2]
      })
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
    end
    return
  end
  local nowSelectedCount = #infos
  if nowSelectedCount == 0 then
    self.corelockLab_.text = Lang("SeasonCultivateNotSelectedEffect", {val = canSelectedCount})
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
    return
  elseif canSelectedCount > nowSelectedCount then
    self.corelockLab_.text = Lang("SeasonCultivateHaveNotSelectedEffect", {val1 = canSelectedCount, val2 = nowSelectedCount})
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, false)
  end
  if infos == nil or #infos < 1 then
    return
  end
  for index, value in ipairs(infos) do
    local binder = self.node_core_effect_items_[index]
    self.uiBinder.Ref:SetVisible(binder.Ref, true)
    self:showEffect(binder, value)
  end
end

function Season_cultivate_effect_popupView:hideAllSelectEffect()
  for _, value in ipairs(self.node_core_effect_items_) do
    self.uiBinder.Ref:SetVisible(value.Ref, false)
  end
end

function Season_cultivate_effect_popupView:onStartAnimShow()
  self.uiBinder.node:Restart(Z.DOTweenAnimType.Open)
end

return Season_cultivate_effect_popupView
