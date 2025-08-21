local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local MultActionCtrlBtn = class("MultActionCtrlBtn", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function MultActionCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function MultActionCtrlBtn:GetUIUnitPath()
  local path = "ui/prefabs/expression/expression_action_btn_double"
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function MultActionCtrlBtn:OnActive()
  self:AddListener()
  Z.EventMgr:Add("CancelMulAction", self.btnFuncCall, self)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 26)
  self.inputKeyDescComp_:Init(26, self.uiBinder.binder_key)
end

function MultActionCtrlBtn:OnDeActive()
  Z.EventMgr:Remove("CancelMulAction", self.btnFuncCall, self)
  self.inputKeyDescComp_:UnInit()
end

function MultActionCtrlBtn:AddListener()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    local multactionVM = Z.VMMgr.GetVM("multaction")
    multactionVM.AsyncCancelAction(self.cancelSource:CreateToken())
  end)
end

function MultActionCtrlBtn:btnFuncCall()
  Z.CoroUtil.create_coro_xpcall(function()
    local multactionVM = Z.VMMgr.GetVM("multaction")
    multactionVM.AsyncCancelAction(self.cancelSource:CreateToken())
  end)()
end

return MultActionCtrlBtn
