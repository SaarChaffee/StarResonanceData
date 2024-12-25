local SlotInputMgr = {}
local KeyState = {Up = 1, Down = 2}

function SlotInputMgr.Input(slotID, keyState)
  local slotCfg = Z.TableMgr:GetTable(""):GetRow(slotID)
  if slotCfg == nil then
    logError("not find slot config")
  end
  if slotCfg.Type == E.SkillSlotType.Skill then
    SlotInputMgr.attack(slotID, keyState == KeyState.Down)
  end
end

function SlotInputMgr.attack(slotID, keyState)
  Z.PlayerInputController:Attack(slotID, keyState)
end

return SlotInputMgr
