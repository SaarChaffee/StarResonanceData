local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local ParkourDropBtn = class("ParkourDropBtn", super)

function ParkourDropBtn:ctor(key, panel)
  super.ctor(self, key, panel)
  self.uiBinder = nil
  self.isDisable_ = false
end

function ParkourDropBtn:OnActive()
  local btnTrigger = self.uiBinder.event_trigger
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 8)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 8)
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

function ParkourDropBtn:BindLuaAttrWatchers()
end

function ParkourDropBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Parkour_Drop")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

return ParkourDropBtn
