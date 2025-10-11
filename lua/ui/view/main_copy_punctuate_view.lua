local UI = Z.UI
local super = require("ui.ui_view_base")
local Main_copy_punctuateView = class("Main_copy_punctuateView", super)
local OPERATE_MODE = {
  NORMAL = 1,
  PLACE = 2,
  DELETE = 3
}
local AXIS_TYPE = {Skill_Horizontal = 6, Skill_Vertical = 7}
local PLACE_ICON_PATH = "ui/atlas/mainui/punctuate/img_main_punctuate_punctuation"
local DELETE_ICON_PATH = "ui/atlas/new_com/com_btn_delete"
local SLOT_INDEX_OFFSET = 200

function Main_copy_punctuateView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_copy_punctuate")
end

function Main_copy_punctuateView:OnActive()
  self:initData()
  self:initComponent()
  self:initSceneMaskItem()
  self:bindEvents()
  self:bindLuaAttrWatchers()
  self.uiBinder.comp_anim:Restart(Z.DOTweenAnimType.Open)
end

function Main_copy_punctuateView:OnDeActive()
  self:unInitSceneMaskItem()
  self:resetInputController()
  self:unBindEvents()
  self:unBindLuaAttrWatchers()
  self.ViewConfig.ShowMouse = true
  self.uiBinder.comp_anim:Restart(Z.DOTweenAnimType.Close)
end

function Main_copy_punctuateView:OnRefresh()
end

function Main_copy_punctuateView:initData()
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.allSkillList_ = self.weaponSkillVM_:GetSceneMaskSkillList()
  self.curMode_ = OPERATE_MODE.NORMAL
  self.curSelectInfo_ = nil
end

function Main_copy_punctuateView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_del, function()
    if self.curMode_ == OPERATE_MODE.DELETE then
      self:enterMode(OPERATE_MODE.NORMAL)
    else
      self:enterMode(OPERATE_MODE.DELETE)
    end
  end)
end

function Main_copy_punctuateView:initSceneMaskItem()
  for i, v in ipairs(self.allSkillList_) do
    local binderItem = self.uiBinder["btn_punctuate" .. i]
    if binderItem ~= nil then
      if Z.IsPCUI then
        self:AddAsyncClick(binderItem.btn_item, function()
          self:onItemClick(v)
        end)
      end
      binderItem.Ref:SetVisible(binderItem.img_on, false)
      binderItem.Ref:SetVisible(binderItem.img_off, true)
      binderItem.Ref:SetVisible(binderItem.img_confirm, self:isSkillHadPlaced(v.id))
    end
    local binderRoulette = self.uiBinder["binder_roulette" .. i]
    if binderRoulette ~= nil then
      binderRoulette.node_roulette:SetSlotId(v.id)
      binderRoulette.node_roulette:SetCancelRect(self.uiBinder.node_skill_cancel)
      binderRoulette.node_roulette.onDown:AddListener(function()
        if self.uiBinder == nil then
          return
        end
        if self.curMode_ ~= OPERATE_MODE.NORMAL then
          return
        end
        self.curSelectInfo_ = v
        Z.PlayerInputController:FlagSkill(v.id, true)
      end)
      binderRoulette.node_roulette.onUp:AddListener(function()
        if self.uiBinder == nil then
          return
        end
        if self.curMode_ == OPERATE_MODE.DELETE then
          if self:isSkillHadPlaced(v.id) then
            Z.PlayerInputController:StopSkill(v.skillId)
          end
        elseif self.curMode_ == OPERATE_MODE.NORMAL then
          Z.PlayerInputController:FlagSkill(v.id, false)
        end
      end)
      binderRoulette.Ref:SetVisible(binderRoulette.node_roulette_bg, false)
    end
  end
  self:enterMode(OPERATE_MODE.NORMAL)
end

function Main_copy_punctuateView:unInitSceneMaskItem()
  for i, v in ipairs(self.allSkillList_) do
    local binderItem = self.uiBinder["btn_punctuate" .. i]
    if binderItem ~= nil and Z.IsPCUI then
      binderItem.btn_item:RemoveAllListeners()
    end
    local binderRoulette = self.uiBinder["binder_roulette" .. i]
    if binderRoulette ~= nil then
      binderRoulette.node_roulette:ClearAll()
    end
  end
end

function Main_copy_punctuateView:bindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt == nil then
    return
  end
  local attrIndexList = {
    Z.AttrCreator.ToIndex(Z.LocalAttr.FlagSkillState)
  }
  self.flagSkillStateWatcher_ = self:BindEntityLuaAttrWatcher(attrIndexList, Z.EntityMgr.PlayerEnt, self.onFlagSkillStateChange)
end

function Main_copy_punctuateView:unBindLuaAttrWatchers()
  if self.flagSkillStateWatcher_ ~= nil then
    self:UnBindEntityLuaAttrWatcher(self.flagSkillStateWatcher_)
    self.flagSkillStateWatcher_ = nil
  end
end

function Main_copy_punctuateView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.OpenSkillRoulette, self.onSkillRouletteChange, self)
  Z.EventMgr:Add(Z.ConstValue.Team.Refresh, self.onTeamRefresh, self)
end

function Main_copy_punctuateView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.OpenSkillRoulette, self.onSkillRouletteChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Team.Refresh, self.onTeamRefresh, self)
end

function Main_copy_punctuateView:onFlagSkillStateChange()
  if self.curMode_ == OPERATE_MODE.DELETE then
    self:enterMode(OPERATE_MODE.DELETE)
  else
    self:enterMode(OPERATE_MODE.NORMAL)
  end
end

function Main_copy_punctuateView:onSkillRouletteChange(slotId, state)
  if self.curSelectInfo_ == nil or self.curSelectInfo_.id ~= slotId then
    return
  end
  if state then
    self:enterMode(OPERATE_MODE.PLACE)
  else
    self:enterMode(OPERATE_MODE.NORMAL)
  end
end

function Main_copy_punctuateView:resetInputController()
  Z.TouchManager.TouchController:TrySetAxis(AXIS_TYPE.Skill_Horizontal, 0)
  Z.TouchManager.TouchController:TrySetAxis(AXIS_TYPE.Skill_Vertical, 0)
end

function Main_copy_punctuateView:isSkillHadPlaced(slotId)
  local value = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.FlagSkillState).Value
  local slotIndex = slotId % SLOT_INDEX_OFFSET
  return value & 1 << slotIndex > 0
end

function Main_copy_punctuateView:onItemClick(info)
  if self.curMode_ == OPERATE_MODE.DELETE then
    if self:isSkillHadPlaced(info.id) then
      Z.PlayerInputController:StopSkill(info.skillId)
    end
  elseif self.curMode_ == OPERATE_MODE.NORMAL then
    self.curSelectInfo_ = info
    Z.PlayerInputController:FlagSkill(info.id, true)
  end
end

function Main_copy_punctuateView:enterMode(mode)
  self.curMode_ = mode
  if self.curMode_ == OPERATE_MODE.NORMAL then
    self.curSelectInfo_ = nil
  end
  local isWillHide = self.curMode_ == OPERATE_MODE.PLACE
  if isWillHide then
    self.uiBinder.comp_dotween:DoCanvasGroup(0, 0.5)
    self.uiBinder.node_punctuate.interactable = false
    self.uiBinder.node_punctuate.blocksRaycasts = false
  else
    self.uiBinder.comp_dotween:DoCanvasGroup(1, 0.5)
    self.uiBinder.node_punctuate.interactable = true
    self.uiBinder.node_punctuate.blocksRaycasts = true
  end
  self.uiBinder.img_del:SetImage(self.curMode_ == OPERATE_MODE.DELETE and PLACE_ICON_PATH or DELETE_ICON_PATH)
  self:SetUIVisible(self.uiBinder.img_del_bg, self.curMode_ == OPERATE_MODE.DELETE)
  if not Z.IsPCUI then
    self:SetUIVisible(self.uiBinder.node_skill_cancel, self.curMode_ == OPERATE_MODE.PLACE)
  end
  for i, v in ipairs(self.allSkillList_) do
    local binderItem = self.uiBinder["btn_punctuate" .. i]
    if binderItem ~= nil then
      local isHadPlaced = self:isSkillHadPlaced(v.id)
      local isCanDelete = isHadPlaced and self.curMode_ == OPERATE_MODE.DELETE
      binderItem.Ref:SetVisible(binderItem.img_on, isCanDelete)
      binderItem.Ref:SetVisible(binderItem.img_off, not isCanDelete)
      binderItem.Ref:SetVisible(binderItem.img_confirm, isHadPlaced)
    end
    local binderRoulette = self.uiBinder["binder_roulette" .. i]
    if binderRoulette ~= nil then
      local isPlacing = self.curMode_ == OPERATE_MODE.PLACE and self.curSelectInfo_ ~= nil and self.curSelectInfo_.id == v.id
      binderRoulette.Ref:SetVisible(binderRoulette.node_roulette_bg, isPlacing)
    end
  end
  self.ViewConfig.ShowMouse = self.curMode_ ~= OPERATE_MODE.PLACE
  Z.UIMgr:UpdateMouseVisible()
end

function Main_copy_punctuateView:OnInputBack()
  if self.curMode_ == OPERATE_MODE.PLACE and self.curSelectInfo_ ~= nil then
    Z.PlayerInputController:FlagSkill(self.curSelectInfo_.id, false)
    self:enterMode(OPERATE_MODE.NORMAL)
  elseif self.curMode_ == OPERATE_MODE.DELETE then
    self:enterMode(OPERATE_MODE.NORMAL)
  else
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end
end

function Main_copy_punctuateView:onTeamRefresh()
  local leaderId = self.teamData_.TeamInfo.baseInfo.leaderId
  local isLeader = leaderId == Z.ContainerMgr.CharSerialize.charBase.charId
  if not Z.StageMgr.IsDungeonStage() or not isLeader then
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end
end

return Main_copy_punctuateView
