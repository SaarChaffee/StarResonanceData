local UI = Z.UI
local super = require("ui.ui_view_base")
local Rolelevel_acquire_windowView = class("Rolelevel_acquire_windowView", super)
local roleLevelAttrTplPath = "ui/prefabs/rolelevel/rolelevel_acquire_lab_tiem_tpl"
E.RoleLevelAcquireStage = {
  None = 0,
  LevelUp = 1,
  AttrChange = 2,
  ItemGet = 3
}

function Rolelevel_acquire_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "rolelevel_acquire_window")
  self.curStage = E.RoleLevelAcquireStage.None
  self.rolelevelCfg_ = nil
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.roleLevelData_ = Z.DataMgr.Get("role_level_data")
  self.roleLevelVM_ = Z.VMMgr.GetVM("rolelevel_main")
  self.stageDurantionDict_ = {
    [E.RoleLevelAcquireStage.None] = 0,
    [E.RoleLevelAcquireStage.LevelUp] = 1.5,
    [E.RoleLevelAcquireStage.AttrChange] = 1.5,
    [E.RoleLevelAcquireStage.ItemGet] = 1.5
  }
end

function Rolelevel_acquire_windowView:resetData()
  self.curStage = E.RoleLevelAcquireStage.None
end

function Rolelevel_acquire_windowView:OnActive()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect_1)
end

function Rolelevel_acquire_windowView:OnDeActive()
  self.uiBinder.node_effect:ReleseEffGo()
  self.uiBinder.node_effect_1:ReleseEffGo()
  self.roleLevelVM_.CloseRoleLevelWindow()
end

function Rolelevel_acquire_windowView:OnRefresh()
  self:resetData()
  self.rolelevelCfg_ = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(self.roleLevelData_:GetRoleLevel())
  self:setStage(E.RoleLevelAcquireStage.LevelUp)
end

function Rolelevel_acquire_windowView:setStage(stage)
  if self.curStage ~= stage then
    self.curStage = stage
    if self.curStage == E.RoleLevelAcquireStage.LevelUp then
      self:showLvNode()
    elseif self.curStage == E.RoleLevelAcquireStage.AttrChange then
      Z.AudioMgr:Play("UI_Event_ShengTiYuanLevelUp")
      self:showAttrNode()
    elseif self.curStage == E.RoleLevelAcquireStage.ItemGet then
      self:showItemGetNode()
    end
  end
end

function Rolelevel_acquire_windowView:showLvNode()
  self:refreshNodeUI()
  self.uiBinder.node_lv.lab_lv.text = self.roleLevelData_:GetRoleLevel()
  self.uiBinder.node_lv.lab_tips.text = string.format(Lang("RoleLevelAcquireNodeLvTip"), self.roleLevelData_:GetRoleLevel())
  Z.AudioMgr:Play("UI_Event_Magic_B")
  self.uiBinder.node_effect_1:CreatEFFGO("ui/uieffect/prefab/ui_sfx_rolelevel/ui_sfx_group_rolelevel_acquire_window_fankui", Vector3.zero)
  self.uiBinder.node_effect_1:SetEffectGoVisible(true)
  self.uiBinder.anim:CoroPlayOnce(self.roleLevelData_.AnimName[Z.IsPCUI and "pc" or "mobile"][self.curStage].start, self.cancelSource:CreateToken(), function()
    self.timerMgr:StartTimer(function()
      self.uiBinder.anim:CoroPlayOnce(self.roleLevelData_.AnimName[Z.IsPCUI and "pc" or "mobile"][self.curStage]["end"], self.cancelSource:CreateToken(), function()
        self:setStage(E.RoleLevelAcquireStage.AttrChange)
      end, function(e)
        if e == ZUtil.ZCancelSource.CancelException then
          return
        end
        logError(e)
      end)
    end, self.stageDurantionDict_[E.RoleLevelAcquireStage.LevelUp])
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

function Rolelevel_acquire_windowView:showAttrNode()
  self.uiBinder.node_effect_1:SetEffectGoVisible(false)
  if self.rolelevelCfg_.LevelUpAttr and next(self.rolelevelCfg_.LevelUpAttr) then
    self:refreshNodeUI()
    self.uiBinder.node_nature.lab_title.text = string.format(Lang("RoleLevelAcquireNodeAttrTip"), self.roleLevelData_:GetRoleLevel())
    Z.CoroUtil.create_coro_xpcall(function()
      for k, v in pairs(self.rolelevelCfg_.LevelUpAttr) do
        local diffValue = self.fightAttrParseVm_.ParseFightAttrNumber(v[1], v[2], false)
        local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(v[1])
        local item = self:AsyncLoadUiUnit(roleLevelAttrTplPath, fightAttrData.Name, self.uiBinder.node_nature.layout_item)
        item.lab_name.text = fightAttrData.Name
        item.lab_number.text = diffValue
      end
      self.uiBinder.node_effect:CreatEFFGO("ui/uieffect/prefab/ui_sfx_rolelevel/ui_sfx_group_rolelevel_acquire_window_fankui_02", Vector3.zero)
      self.uiBinder.node_effect:SetEffectGoVisible(true)
      self.uiBinder.anim:CoroPlayOnce(self.roleLevelData_.AnimName[Z.IsPCUI and "pc" or "mobile"][self.curStage].start, self.cancelSource:CreateToken(), function()
        self.timerMgr:StartTimer(function()
          self.uiBinder.anim:CoroPlayOnce(self.roleLevelData_.AnimName[Z.IsPCUI and "pc" or "mobile"][self.curStage]["end"], self.cancelSource:CreateToken(), function()
            self:setStage(E.RoleLevelAcquireStage.ItemGet)
          end, function(e)
            if e == ZUtil.ZCancelSource.CancelException then
              return
            end
            logError(e)
          end)
        end, self.stageDurantionDict_[E.RoleLevelAcquireStage.AttrChange])
      end, function(err)
        if err == ZUtil.ZCancelSource.CancelException then
          return
        end
        logError(err)
      end)
    end)()
  else
    self:setStage(E.RoleLevelAcquireStage.ItemGet)
  end
end

function Rolelevel_acquire_windowView:showItemGetNode()
  self.uiBinder.node_effect:SetEffectGoVisible(false)
  if self.rolelevelCfg_.LevelAwardID ~= 0 then
    self:refreshNodeUI()
    Z.AudioMgr:Play("UI_Event_Magic_A")
    self.uiBinder.node_gift.lab_tips.text = string.format(Lang("RoleLevelAcquireNodeGiftTitle"), self.roleLevelData_:GetRoleLevel())
    self.uiBinder.node_effect_1:SetEffectGoVisible(true)
    self.uiBinder.anim:CoroPlayOnce(self.roleLevelData_.AnimName[Z.IsPCUI and "pc" or "mobile"][self.curStage].start, self.cancelSource:CreateToken(), function()
      self.timerMgr:StartTimer(function()
        self.uiBinder.anim:CoroPlayOnce(self.roleLevelData_.AnimName[Z.IsPCUI and "pc" or "mobile"][self.curStage]["end"], self.cancelSource:CreateToken(), function()
          self.roleLevelVM_.CloseRoleLevelWindow()
        end, function(e)
          if e == ZUtil.ZCancelSource.CancelException then
            return
          end
          logError(e)
        end)
      end, self.stageDurantionDict_[E.RoleLevelAcquireStage.ItemGet])
    end, function(err)
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      logError(err)
    end)
  else
    self.roleLevelVM_.CloseRoleLevelWindow()
  end
end

function Rolelevel_acquire_windowView:refreshNodeUI()
  self.uiBinder.node_lv.Ref.UIComp:SetVisible(self.curStage == E.RoleLevelAcquireStage.LevelUp)
  self.uiBinder.node_nature.Ref.UIComp:SetVisible(self.curStage == E.RoleLevelAcquireStage.AttrChange)
  self.uiBinder.node_gift.Ref.UIComp:SetVisible(self.curStage == E.RoleLevelAcquireStage.ItemGet)
end

return Rolelevel_acquire_windowView
