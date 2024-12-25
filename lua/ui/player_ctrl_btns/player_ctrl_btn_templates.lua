local PlayerCtrlTmpMgr = class("PlayerCtrlTmpMgr")
local skillSlot = require("ui.player_ctrl_btns.skill_slot_obj")
local jumpCtrlBtn = require("ui.player_ctrl_btns.jump_ctrl_btn")
local flowCtrlBtn = require("ui.player_ctrl_btns.flow_ctrl_btn")
local flowSwitchBtn = require("ui.player_ctrl_btns.flow_switch_ctrl_btn")
local dashBtn = require("ui.player_ctrl_btns.dash_ctrl_btn")
local multActionBtn = require("ui.player_ctrl_btns.multaction_ctrl_btn")
local staticObjBtn = require("ui.player_ctrl_btns.staticobj_ctrl_btn")
local ClimbRushCtrlBtn = require("ui.player_ctrl_btns.climb_rush_ctrl_btn")
local swimCtrlBtn = require("ui.player_ctrl_btns.swim_ctrl_btn")
local lockTarget = require("ui.player_ctrl_btns.lock_target_btn")
local parkourDrop = require("ui.player_ctrl_btns.parkour_drop_ctrl_btn")

function PlayerCtrlTmpMgr:ctor(view)
  self.view_ = view
  self.slotReplaceCache_ = {}
  self.slotUIUnitCache_ = {}
  self.currentTmpType_ = nil
  self:InitTemplates()
end

function PlayerCtrlTmpMgr:InitTemplates()
  self.PCUILayoutMap = {
    ctrl_layout = {
      E.SlotName.SkillSlot_1,
      E.SlotName.SkillSlot_2,
      E.SlotName.SkillSlot_3,
      E.SlotName.SkillSlot_4,
      E.SlotName.SkillSlot_9,
      E.SlotName.ExtraSlot_4
    },
    common_layout = {
      E.SlotName.ExtraSlot_1,
      E.SlotName.ExtraSlot_2,
      E.SlotName.ResonanceSkillSlot_left,
      E.SlotName.ResonanceSkillSlot_right,
      E.SlotName.Interactive
    }
  }
  self.PlayerCtrlBtnTemplates = {
    [E.PlayerCtrlBtnTmpType.Default] = {
      [E.SlotName.SkillSlot_1] = skillSlot,
      [E.SlotName.SkillSlot_2] = skillSlot,
      [E.SlotName.SkillSlot_3] = skillSlot,
      [E.SlotName.SkillSlot_4] = skillSlot,
      [E.SlotName.SkillSlot_5] = skillSlot,
      [E.SlotName.SkillSlot_6] = skillSlot,
      [E.SlotName.SkillSlot_7] = skillSlot,
      [E.SlotName.SkillSlot_8] = skillSlot,
      [E.SlotName.SkillSlot_9] = skillSlot,
      [E.SlotName.SkillSlot_10] = skillSlot,
      [E.SlotName.ExtraSlot_4] = lockTarget,
      [E.SlotName.ExtraSlot_1] = dashBtn,
      [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
      [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_right] = skillSlot
    },
    [E.PlayerCtrlBtnTmpType.Climb] = {
      [E.SlotName.SkillSlot_1] = ClimbRushCtrlBtn,
      [E.SlotName.ExtraSlot_1] = jumpCtrlBtn,
      [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_right] = skillSlot
    },
    [E.PlayerCtrlBtnTmpType.FlowGlide] = {
      [E.SlotName.SkillSlot_1] = flowSwitchBtn,
      [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
      [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_right] = skillSlot
    },
    [E.PlayerCtrlBtnTmpType.MulAction] = {
      [E.SlotName.CancelMulAction] = multActionBtn
    },
    [E.PlayerCtrlBtnTmpType.Swim] = {
      [E.SlotName.ExtraSlot_1] = swimCtrlBtn,
      [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
      [E.SlotName.SkillSlot_1] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_right] = skillSlot
    },
    [E.PlayerCtrlBtnTmpType.Interactive] = {
      [E.SlotName.Interactive] = staticObjBtn
    },
    [E.PlayerCtrlBtnTmpType.ClimbRun] = {
      [E.SlotName.SkillSlot_1] = skillSlot,
      [E.SlotName.SkillSlot_3] = skillSlot,
      [E.SlotName.SkillSlot_4] = skillSlot,
      [E.SlotName.SkillSlot_5] = skillSlot,
      [E.SlotName.SkillSlot_9] = skillSlot,
      [E.SlotName.ExtraSlot_1] = parkourDrop,
      [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
      [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_right] = skillSlot
    },
    [E.PlayerCtrlBtnTmpType.Vehicles] = {
      [E.SlotName.SkillSlot_1] = skillSlot,
      [E.SlotName.SkillSlot_2] = skillSlot,
      [E.SlotName.SkillSlot_3] = skillSlot,
      [E.SlotName.SkillSlot_4] = skillSlot,
      [E.SlotName.SkillSlot_5] = skillSlot,
      [E.SlotName.SkillSlot_6] = skillSlot,
      [E.SlotName.SkillSlot_7] = skillSlot,
      [E.SlotName.SkillSlot_8] = skillSlot,
      [E.SlotName.SkillSlot_9] = skillSlot,
      [E.SlotName.SkillSlot_10] = skillSlot,
      [E.SlotName.ExtraSlot_4] = lockTarget,
      [E.SlotName.ExtraSlot_1] = dashBtn,
      [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
      [E.SlotName.VehicleSkillsSlot_1] = skillSlot
    },
    [E.PlayerCtrlBtnTmpType.VehiclePassenger] = {},
    [E.PlayerCtrlBtnTmpType.TunnelFly] = {
      [E.SlotName.SkillSlot_1] = skillSlot,
      [E.SlotName.ResonanceSkillSlot_left] = flowCtrlBtn,
      [E.SlotName.ResonanceSkillSlot_right] = flowCtrlBtn
    }
  }
  if Z.IsPCUI then
    self.PlayerCtrlBtnTemplates = {
      [E.PlayerCtrlBtnTmpType.Default] = {
        [E.SlotName.SkillSlot_1] = skillSlot,
        [E.SlotName.SkillSlot_2] = skillSlot,
        [E.SlotName.SkillSlot_3] = skillSlot,
        [E.SlotName.SkillSlot_4] = skillSlot,
        [E.SlotName.SkillSlot_5] = skillSlot,
        [E.SlotName.SkillSlot_6] = skillSlot,
        [E.SlotName.SkillSlot_7] = skillSlot,
        [E.SlotName.SkillSlot_8] = skillSlot,
        [E.SlotName.SkillSlot_9] = skillSlot,
        [E.SlotName.SkillSlot_10] = skillSlot,
        [E.SlotName.ExtraSlot_1] = dashBtn,
        [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
        [E.SlotName.ResonanceSkillSlot_left] = flowCtrlBtn,
        [E.SlotName.ResonanceSkillSlot_right] = flowCtrlBtn
      },
      [E.PlayerCtrlBtnTmpType.Climb] = {
        [E.SlotName.SkillSlot_1] = ClimbRushCtrlBtn,
        [E.SlotName.ExtraSlot_2] = jumpCtrlBtn
      },
      [E.PlayerCtrlBtnTmpType.FlowGlide] = {
        [E.SlotName.SkillSlot_1] = flowSwitchBtn,
        [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
        [E.SlotName.ResonanceSkillSlot_right] = skillSlot
      },
      [E.PlayerCtrlBtnTmpType.MulAction] = {
        [E.SlotName.CancelMulAction] = multActionBtn
      },
      [E.PlayerCtrlBtnTmpType.Swim] = {
        [E.SlotName.SkillSlot_1] = skillSlot,
        [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
        [E.SlotName.ResonanceSkillSlot_right] = skillSlot
      },
      [E.PlayerCtrlBtnTmpType.Interactive] = {
        [E.SlotName.Interactive] = staticObjBtn
      },
      [E.PlayerCtrlBtnTmpType.ClimbRun] = {
        [E.SlotName.SkillSlot_1] = skillSlot,
        [E.SlotName.ResonanceSkillSlot_left] = skillSlot,
        [E.SlotName.ResonanceSkillSlot_right] = skillSlot
      },
      [E.PlayerCtrlBtnTmpType.TunnelFly] = {
        [E.SlotName.SkillSlot_1] = skillSlot,
        [E.SlotName.ResonanceSkillSlot_left] = flowCtrlBtn,
        [E.SlotName.ResonanceSkillSlot_right] = flowCtrlBtn
      },
      [E.PlayerCtrlBtnTmpType.Vehicles] = {
        [E.SlotName.SkillSlot_1] = skillSlot,
        [E.SlotName.SkillSlot_2] = skillSlot,
        [E.SlotName.SkillSlot_3] = skillSlot,
        [E.SlotName.SkillSlot_4] = skillSlot,
        [E.SlotName.SkillSlot_5] = skillSlot,
        [E.SlotName.SkillSlot_6] = skillSlot,
        [E.SlotName.SkillSlot_7] = skillSlot,
        [E.SlotName.SkillSlot_8] = skillSlot,
        [E.SlotName.SkillSlot_9] = skillSlot,
        [E.SlotName.SkillSlot_10] = skillSlot,
        [E.SlotName.VehicleSkillsSlot_1] = skillSlot,
        [E.SlotName.ExtraSlot_1] = dashBtn,
        [E.SlotName.ExtraSlot_2] = jumpCtrlBtn
      },
      [E.PlayerCtrlBtnTmpType.VehiclePassenger] = {
        [E.SlotName.SkillSlot_1] = skillSlot,
        [E.SlotName.SkillSlot_2] = skillSlot,
        [E.SlotName.SkillSlot_3] = skillSlot,
        [E.SlotName.SkillSlot_4] = skillSlot,
        [E.SlotName.SkillSlot_5] = skillSlot,
        [E.SlotName.SkillSlot_6] = skillSlot,
        [E.SlotName.SkillSlot_7] = skillSlot,
        [E.SlotName.SkillSlot_8] = skillSlot,
        [E.SlotName.SkillSlot_9] = skillSlot,
        [E.SlotName.SkillSlot_10] = skillSlot,
        [E.SlotName.ExtraSlot_1] = dashBtn,
        [E.SlotName.ExtraSlot_2] = jumpCtrlBtn,
        [E.SlotName.ResonanceSkillSlot_left] = flowCtrlBtn,
        [E.SlotName.ResonanceSkillSlot_right] = flowCtrlBtn
      }
    }
  end
end

function PlayerCtrlTmpMgr:SetAllSlotIgnoreFlag(flag)
  for k, v in pairs(E.SlotName) do
    self:SetLayoutElementIgnore(v, flag)
  end
end

function PlayerCtrlTmpMgr:CreateTmpCtrlBtns(tmpType)
  if not self.view_ then
    return
  end
  if not self.PlayerCtrlBtnTemplates or not self.PlayerCtrlBtnTemplates[tmpType] then
    return
  end
  self.currentTmpType_ = tmpType
  for slotName, factor in pairs(self.PlayerCtrlBtnTemplates[tmpType]) do
    if not self.slotUIUnitCache_[slotName] then
      self.slotUIUnitCache_[slotName] = factor.new(slotName, self.view_, self)
      self.slotUIUnitCache_[slotName]:Create(self.view_.panel[slotName])
    end
  end
end

function PlayerCtrlTmpMgr:ClearCurTmpCtrlBtns()
  if self.slotUIUnitCache_ then
    for k, v in pairs(self.slotUIUnitCache_) do
      v:Reset()
    end
  end
  self.currentTmpType_ = nil
  self.slotUIUnitCache_ = {}
end

function PlayerCtrlTmpMgr:GetCurrentTmpTable()
  if self.currentTmpType_ then
    return self.PlayerCtrlBtnTemplates[self.currentTmpType_]
  end
end

function PlayerCtrlTmpMgr:GetCurrentTmpValue()
  return self.currentTmpType_
end

function PlayerCtrlTmpMgr:GetPCUIMap(key)
  return self.PCUILayoutMap[key]
end

function PlayerCtrlTmpMgr:GetSlotBtnByType(slotType)
  if E.PlayerCtrlBtnType.ESkillSlotBtn == slotType then
    return skillSlot
  elseif E.PlayerCtrlBtnType.EFlowBtn == slotType then
    return flowCtrlBtn
  elseif E.PlayerCtrlBtnType.EJumpBtn == slotType then
    return jumpCtrlBtn
  elseif E.PlayerCtrlBtnType.ERushBtn == slotType then
    return dashBtn
  end
end

function PlayerCtrlTmpMgr:AddSlotToTmp(bitValue, slotType, slotId, isSaveCache)
  local btnClass = self:GetSlotBtnByType(slotType)
  if not btnClass then
    return
  end
  if isSaveCache == nil then
    isSaveCache = true
  end
  local slotKey = tostring(slotId)
  if self.slotUIUnitCache_[slotKey] ~= nil then
    self.slotUIUnitCache_[slotKey]:Reset()
    self.slotUIUnitCache_[slotKey] = nil
  end
  self.slotUIUnitCache_[slotKey] = btnClass.new(slotKey, self.view_)
  self.slotUIUnitCache_[slotKey]:Create(self.view_.panel[slotKey])
  for _, index in pairs(E.PlayerCtrlBtnTmpType) do
    if Z.BitAND(tonumber(bitValue), tonumber(index)) > 0 then
      if self.slotReplaceCache_[index] == nil then
        self.slotReplaceCache_[index] = {}
      end
      if isSaveCache then
        self.slotReplaceCache_[index][slotKey] = self.PlayerCtrlBtnTemplates[index][slotKey]
      end
      self.PlayerCtrlBtnTemplates[index][slotKey] = btnClass
    end
  end
end

function PlayerCtrlTmpMgr:RemoveSlotToTmp(bitValue, slotId, isGetCache)
  local slotKey = tostring(slotId)
  if isGetCache == nil then
    isGetCache = true
  end
  if self.slotUIUnitCache_[slotKey] ~= nil then
    self.slotUIUnitCache_[slotKey]:Reset()
    self.slotUIUnitCache_[slotKey] = nil
  end
  if isGetCache and self.slotReplaceCache_[self.currentTmpType_] and self.slotReplaceCache_[self.currentTmpType_][slotKey] then
    self.slotUIUnitCache_[slotKey] = self.slotReplaceCache_[self.currentTmpType_][slotKey].new(slotKey, self.view_)
    self.slotUIUnitCache_[slotKey]:Create(self.view_.panel[slotKey])
  end
  for _, index in pairs(E.PlayerCtrlBtnTmpType) do
    if Z.BitAND(tonumber(bitValue), tonumber(index)) > 0 then
      if self.slotReplaceCache_[index] ~= nil and isGetCache then
        self.PlayerCtrlBtnTemplates[index][slotKey] = self.slotReplaceCache_[index][slotKey]
        self.slotReplaceCache_[index][slotKey] = nil
      else
        self.PlayerCtrlBtnTemplates[index][slotKey] = nil
      end
    end
  end
end

function PlayerCtrlTmpMgr:SetLayoutElementIgnore(slotId, flag)
  if self.view_.panel[slotId] then
    local le = self.view_.panel[slotId].layoutElement
    if le then
      le:SetIgnoreLayout(flag)
    end
  end
end

return PlayerCtrlTmpMgr
