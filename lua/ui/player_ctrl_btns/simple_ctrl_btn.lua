local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local SimpleCtrlBtn = class("SimpleCtrlBtn", super)

function SimpleCtrlBtn:ctor(key, panel, Img, pressCallFunc, upCallFunc)
  super.ctor(self, key, panel)
  self.pressCallFunc_ = pressCallFunc
  self.upCallFunc_ = upCallFunc
  self.Img_ = Img
end

local btnStateColor = {
  onTouchColor = Color.New(0.8222222222222222, 0.8222222222222222, 0.8222222222222222, 1),
  onDisable = Color.New(1, 1, 1, 0.2),
  onNormal = Color.New(1, 1, 1, 1)
}

function SimpleCtrlBtn:GetUIUnitPath()
  return "ui/prefabs/controller/controller_simple_ctrl_btn_tpl"
end

function SimpleCtrlBtn:OnActive()
  self.uiUnit_.icon.Img:SetImage(self.Img_)
  local btnTrigger = self.uiUnit_.touch_area.EventTrigger
  local LayerName = "Base Layer."
  local btnsAnim = self.uiUnit_.anim_comp.anim
  btnTrigger.onDown:AddListener(function()
    if self.uiUnit_ == nil then
      return
    end
    self.uiUnit_.icon.Img:SetColor(btnStateColor.onTouchColor)
    if self.pressCallFunc_ ~= nil then
      self.pressCallFunc_()
    end
    btnsAnim:PlayOnce(LayerName .. "skill_slot_narrow")
  end)
  btnTrigger.onUp:AddListener(function()
    if self.uiUnit_ == nil then
      return
    end
    if self.upCallFunc_ ~= nil then
      self.upCallFunc_()
    end
    self.uiUnit_.icon.Img:SetColor(btnStateColor.onNormal)
    btnsAnim:PlayOnce(LayerName .. "skill_slot_amplification")
  end)
end

return SimpleCtrlBtn
