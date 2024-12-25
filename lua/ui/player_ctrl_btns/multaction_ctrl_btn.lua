local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local MultActionCtrlBtn = class("MultActionCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function MultActionCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
end

function MultActionCtrlBtn:GetUIUnitPath()
  local path = "ui/prefabs/expression/expression_action_btn_double"
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function MultActionCtrlBtn:OnActive()
  self:AddListener()
  Z.EventMgr:Add("CancelMulAction", self.btnFuncCall, self)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 26)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 26)
end

function MultActionCtrlBtn:OnDeActive()
  Z.EventMgr:Remove("CancelMulAction", self.btnFuncCall, self)
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
