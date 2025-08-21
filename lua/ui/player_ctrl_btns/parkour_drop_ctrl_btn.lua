local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local inputKeyDescComp = require("input.input_key_desc_comp")
local ParkourDropBtn = class("ParkourDropBtn", super)

function ParkourDropBtn:ctor(key, panel)
  super.ctor(self, key, panel)
  self.uiBinder = nil
  self.isDisable_ = false
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function ParkourDropBtn:OnActive()
  local btnTrigger = self.uiBinder.event_trigger
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 8)
  self.inputKeyDescComp_:Init(8, self.uiBinder.binder_key)
  btnTrigger.onDown:AddListener(function()
    if self.uiBinder == nil or self.isDisable_ then
      return
    end
    Z.PlayerInputController:Drop()
  end)
end

function ParkourDropBtn:RegisterEvent()
end

function ParkourDropBtn:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function ParkourDropBtn:OnDeActive()
  self.inputKeyDescComp_:UnInit()
  self:UnregisterEvent()
end

function ParkourDropBtn:BindLuaAttrWatchers()
end

function ParkourDropBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Parkour_Drop")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

return ParkourDropBtn
