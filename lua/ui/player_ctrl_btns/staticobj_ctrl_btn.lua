local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local StaticObjCtrlBtn = class("StaticObjCtrlBtn", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function StaticObjCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function StaticObjCtrlBtn:GetUIUnitPath()
  local path = "ui/prefabs/controller/controller_staticobj_btn_tpl"
  return path
end

function StaticObjCtrlBtn:OnActive()
  self.isEndInteraction_ = false
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  self.uiBinder.Ref.UIComp:SetVisible(false)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 26)
  self.inputKeyDescComp_:Init(26, self.uiBinder.binder_key)
  self:AddListener()
end

function StaticObjCtrlBtn:RegisterEvent()
  Z.EventMgr:Add("SHOW_INTERACTION_END_ACTION_BTN", self.showEndActionBtn, self)
end

function StaticObjCtrlBtn:showEndActionBtn(isShow)
  self.uiBinder.Ref.UIComp:SetVisible(isShow)
end

function StaticObjCtrlBtn:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function StaticObjCtrlBtn:OnDeActive()
  self.isEndInteraction_ = false
  self.inputKeyDescComp_:UnInit()
end

function StaticObjCtrlBtn:AddListener()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    Z.PlayerInputController:EndInteractionAction()
  end)
end

return StaticObjCtrlBtn
