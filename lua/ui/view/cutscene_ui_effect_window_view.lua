local UI = Z.UI
local super = require("ui.ui_view_base")
local Cutscene_ui_effect_windowView = class("Cutscene_ui_effect_windowView", super)

function Cutscene_ui_effect_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cutscene_ui_effect_window")
end

function Cutscene_ui_effect_windowView:OnActive()
  self.effRoots_ = {
    [1] = {
      effRoot = self.uiBinder.effect_1,
      effectInfo = nil
    },
    [2] = {
      effRoot = self.uiBinder.effect_2,
      effectInfo = nil
    },
    [3] = {
      effRoot = self.uiBinder.effect_3,
      effectInfo = nil
    },
    [4] = {
      effRoot = self.uiBinder.effect_4,
      effectInfo = nil
    },
    [5] = {
      effRoot = self.uiBinder.effect_5,
      effectInfo = nil
    },
    [6] = {
      effRoot = self.uiBinder.effect_6,
      effectInfo = nil
    },
    [7] = {
      effRoot = self.uiBinder.effect_7,
      effectInfo = nil
    },
    [8] = {
      effRoot = self.uiBinder.effect_9,
      effectInfo = nil
    },
    [9] = {
      effRoot = self.uiBinder.effect_9,
      effectInfo = nil
    },
    [10] = {
      effRoot = self.uiBinder.effect_10,
      effectInfo = nil
    }
  }
  Z.EventMgr:Add(Z.ConstValue.UIEffectDestory, self.destoryEffect, self)
end

function Cutscene_ui_effect_windowView:OnRefresh()
  for _, value in ipairs(self.effRoots_) do
    if value.effectInfo == nil then
      local stringTab = string.split(self.viewData.effectData, "|")
      local path = stringTab[2]
      value.effRoot:CreatEFFGO(path, Vector3.zero)
      value.effectInfo = self.viewData.effectData
      break
    end
  end
end

function Cutscene_ui_effect_windowView:destoryEffect(UIEffectData)
  local closeView = true
  for _, value in ipairs(self.effRoots_) do
    if value.effectInfo == UIEffectData then
      value.effRoot:ReleseEffGo()
      value.effectInfo = nil
    end
    if value.effectInfo ~= nil then
      closeView = false
    end
  end
  if closeView then
    Z.UIMgr:CloseView("cutscene_ui_effect_window")
  end
end

function Cutscene_ui_effect_windowView:OnDeActive()
end

return Cutscene_ui_effect_windowView
