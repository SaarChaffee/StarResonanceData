local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local StaticObjCtrlBtn = class("StaticObjCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function StaticObjCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
end

function StaticObjCtrlBtn:GetUIUnitPath()
  local path = "ui/prefabs/expression/expression_action_btn_double"
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function StaticObjCtrlBtn:OnActive()
  local isShow = false
  local id = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EStaticInteractionObjId).Value
  local idCfg = Z.TableMgr.GetTable("StaticInteractiveObjectTableMgr").GetRow(id)
  if idCfg ~= nil then
    local classCfg = Z.TableMgr.GetTable("StaticInteractiveClassMgr").GetRow(idCfg.ClassId)
    if classCfg ~= nil then
      isShow = classCfg.ExitType == 2
    end
  end
  self.uiBinder.Ref.UIComp:SetVisible(isShow)
  if isShow == false then
    return
  end
  self:AddListener()
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 26)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 26)
end

function StaticObjCtrlBtn:OnDeActive()
end

function StaticObjCtrlBtn:AddListener()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    Z.InteractionMgr:StaticObjInput(false, false)
  end)
end

function StaticObjCtrlBtn:btnFuncCall()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.InteractionMgr:StaticObjInput(false, false)
  end)()
end

return StaticObjCtrlBtn
