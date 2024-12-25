local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local SceneLayerBtnUnit = class("SceneLayerBtnUnit", super)
local keyIconHelper = require("ui.component.mainui.key_icon_helper")

function SceneLayerBtnUnit:ctor(key, panel)
  super.ctor(self, key, panel)
  self.sceneLayerVm = Z.VMMgr.GetVM("scene_layer")
  self.imgaddress_ = "ui/atlas/mainui/dimension/handoff_dimension_icon_"
  self.cdkey_ = "scene_layer_changed"
end

function SceneLayerBtnUnit:GetUIUnitPath()
  if Z.IsPCUI then
    return "ui/prefabs/extrafunc/extrafunc_dimension_tpl_pc"
  else
    return "ui/prefabs/extrafunc/extrafunc_dimension_tpl"
  end
end

function SceneLayerBtnUnit:OnActive()
  if Z.IsPCUI then
    self.uiUnit_.cont_key_icon:SetVisible(true)
    Z.GuideMgr:SetSteerId(self.uiUnit_.img_dimension, E.DynamicSteerType.KeyBoardId, 25)
    keyIconHelper.InitKeyIcon(self, self.uiUnit_.cont_key_icon, 25)
  end
  self.uiUnit_.cd_num:SetVisible(false)
  local nowBuffList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  if nowBuffList then
    self:updateSceneLayerBuffList(nowBuffList.Value, true)
  end
  local cdHandler = self.uiUnit_.scene_layer_cd.cd_ctrl_handler.cdHandler
  cdHandler:ChangeCdKey(self.cdkey_)
  self:AddAsyncClick(self.uiUnit_.click.Btn, function()
    self:sceneLayerFunc()
  end)
end

function SceneLayerBtnUnit:RegisterEvent()
  Z.EventMgr:Add("InputChangeDimension", self.sceneLayerFunc, self)
  Z.EventMgr:Add("OnCDLayerChanged", self.OnCDLayerChanged, self)
end

function SceneLayerBtnUnit:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function SceneLayerBtnUnit:OnCDLayerChanged(key)
  if self.cdkey_ == key then
    self.isInCd_ = false
  end
end

function SceneLayerBtnUnit:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EChangedBuffList
  }, Z.EntityMgr.PlayerEnt, function()
    local buffListChange_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EChangedBuffList).Value
    if buffListChange_.count > 0 then
      self:updateSceneLayerBuffList(buffListChange_)
    end
  end, true)
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EDelBuffList
  }, Z.EntityMgr.PlayerEnt, function()
    local buffListDelete_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EDelBuffList).Value
    if buffListDelete_.count > 0 then
      self:deleteSceneLayerBuffList(buffListDelete_)
    end
  end, true)
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrCanSwitchLayer")
  }, Z.EntityMgr.PlayerEnt, self.UpdateSceneLayerBtnVisible)
end

function SceneLayerBtnUnit:UpdateSceneLayerBtnVisible()
  self.canSwitchLayer_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCanSwitchLayer")).Value
  if self.canSwitchLayer_ == 1 then
    self.uiUnit_:SetVisible(true)
  else
    self.uiUnit_:SetVisible(false)
  end
end

function SceneLayerBtnUnit:sceneLayerFunc()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.isInCd_ then
      Z.TipsVM.ShowTipsLang(600003)
      return
    end
    local sceneLayerData_ = Z.DataMgr.Get("scene_layer_data")
    local nowLayerCount_ = sceneLayerData_:GetSceneLayerCount()
    if nowLayerCount_ == 0 then
      Z.TipsVM.ShowTipsLang(600001)
      return
    end
    local canSwitchStateList = {
      Z.PbEnum("EActorState", "ActorStateDefault"),
      Z.PbEnum("EActorState", "ActorStateRush"),
      Z.PbEnum("EActorState", "ActorStateClimb"),
      Z.PbEnum("EActorState", "ActorStateJump"),
      Z.PbEnum("EActorState", "ActorStateBlow"),
      Z.PbEnum("EActorState", "ActorStateSkill")
    }
    local cantSwitch = false
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
    for i = 1, #canSwitchStateList do
      if canSwitchStateList[i] == stateId then
        cantSwitch = true
        break
      end
    end
    if not cantSwitch then
      Z.TipsVM.ShowTipsLang(600002)
    else
      local worldProxy = require("zproxy.world_proxy")
      local nowLayer_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrLayer")).Value
      worldProxy.SwitchSceneLayer(1 - nowLayer_, self.cancelSource:CreateToken())
    end
  end)()
end

function SceneLayerBtnUnit:updateSceneLayerBuffList(buffList, isInit)
  if not self.uiUnit_ then
    return
  end
  local isEmpety_ = isInit and true or false
  local padList_ = {
    59,
    41,
    23,
    0
  }
  for i = 0, buffList.count - 1 do
    if buffList[i].BuffBaseId == E.BuffId.SceneLayerSwitchCd then
      self.isInCd_ = true
      local cdHandler = self.uiUnit_.scene_layer_cd.cd_ctrl_handler.cdHandler
      cdHandler:CreateCD()
    elseif buffList[i].BuffBaseId == E.BuffId.SceneLayerEnergy then
      if buffList[i].Layer == 0 then
        isEmpety_ = true
      else
        isEmpety_ = false
        self.uiUnit_.img_icon.Img:SetImage(self.imgaddress_ .. "on")
        self.sceneLayerVm.SetSceneLayerCount(buffList[i].Layer)
        self.uiUnit_.mask.RMask2D.padding = Vector4.New(0, 0, 0, padList_[buffList[i].Layer])
      end
    end
  end
  if isEmpety_ then
    self:showEmptySceneLayerUnit()
  end
end

function SceneLayerBtnUnit:showEmptySceneLayerUnit()
  if not self.uiUnit_ then
    return
  end
  self.sceneLayerVm.SetSceneLayerCount(0)
  self.uiUnit_.img_icon.Img:SetImage(self.imgaddress_ .. "off")
  self.uiUnit_.mask.RMask2D.padding = Vector4.New(0, 0, 0, 80)
end

function SceneLayerBtnUnit:deleteSceneLayerBuffList(buffList)
  for i = 0, buffList.count - 1 do
    if buffList[i].BuffBaseId == E.BuffId.SceneLayerEnergy then
      self:showEmptySceneLayerUnit()
    end
  end
end

return SceneLayerBtnUnit
