local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local ClimbRushCtrlBtn = class("ClimbRushCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local IMG_PATH = "ui/atlas/mainui/skill/sprint"
local UI_PATH = "ui/prefabs/controller/controller_simple_ctrl_btn_tpl"

function ClimbRushCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
end

function ClimbRushCtrlBtn:GetUIUnitPath()
  return UI_PATH
end

function ClimbRushCtrlBtn:OnActive()
  self.uiBinder.img_icon:SetImage(IMG_PATH)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_icon, E.DynamicSteerType.KeyBoardId, 29)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 29)
  self.uiBinder.event_trigger.onDown:AddListener(function()
    if self.uiBinder == nil then
      return
    end
    self.uiBinder.effect_click:SetEffectGoVisible(false)
    self.uiBinder.effect_click:SetEffectGoVisible(true)
    Z.PlayerInputController:ClimbRush()
  end)
end

function ClimbRushCtrlBtn:OnDeActive()
  self.uiBinder.event_trigger.onDown:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

return ClimbRushCtrlBtn
