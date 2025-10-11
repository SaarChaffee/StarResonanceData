local UI = Z.UI
local super = require("ui.ui_view_base")
local Handbook_character_windowView = class("Handbook_character_windowView", super)
local loop_list_view = require("ui.component.loop_list_view")
local handbookCharacterLoopListItem = require("ui.component.handbook.handbook_character_loop_list_item")
local handbookDefine = require("ui.model.handbook_define")
local handbookImportantRoleTableMap = require("table.HandbookImportantRoleTableMap")
local rotation = Quaternion.Euler(Vector3.New(0, 160, 0))

function Handbook_character_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "handbook_character_window")
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
  self.handbookData_ = Z.DataMgr.Get("handbook_data")
end

function Handbook_character_windowView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(false)
  self.selectId_ = nil
  self.characterLoop_ = loop_list_view.new(self, self.uiBinder.loop_left, handbookCharacterLoopListItem, "handbook_character_list_item_tpl")
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2091)
  end)
  self:AddClick(self.uiBinder.rayimg_unrealscene_drag.onBeginDrag, function(go, eventData)
    self:onUnrealsceneBeginDrag(eventData)
  end)
  self:AddClick(self.uiBinder.rayimg_unrealscene_drag.onDrag, function(go, eventData)
    self:onUnrealsceneDrag(eventData)
  end)
  self:AddClick(self.uiBinder.rayimg_unrealscene_drag.onEndDrag, function(go, eventData)
    self:onUnrealsceneEndDrag(eventData)
  end)
  local mgr = Z.TableMgr.GetTable("NoteImportantRoleTableMgr")
  local datas = handbookImportantRoleTableMap.ImportantRole
  table.sort(datas, function(a, b)
    local aState = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Character, a)
    local bState = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Character, b)
    if aState == bState then
      local aConfig = mgr.GetRow(a)
      local bConfig = mgr.GetRow(b)
      if aConfig and bConfig then
        return aConfig.Episode < bConfig.Episode
      else
        return false
      end
    else
      return aState < bState
    end
  end)
  self.characterLoop_:Init(datas)
  self.characterLoop_:SetSelected(1)
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.HandbookCharater)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Handbook_character_windowView:OnDeActive()
  self.characterLoop_:UnInit()
  self.characterLoop_ = nil
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
end

function Handbook_character_windowView:OnRefresh()
end

function Handbook_character_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("handbook_character_window")
end

function Handbook_character_windowView:SelectId(id, isClick)
  if id == self.selectId_ then
    return
  end
  self.selectId_ = id
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Character, self.selectId_)
  if isUnlock then
    local config = Z.TableMgr.GetTable("NoteImportantRoleTableMgr").GetRow(self.selectId_)
    if config then
      self.uiBinder.lab_name.text = config.RoleName
      self.uiBinder.lab_gender.text = config.RoleSex
      self.uiBinder.lab_standing.text = config.RoleIdentity
      self.uiBinder.lab_weap.text = config.RoleWeapon
      self.uiBinder.lab_character.text = config.RoleCharacter
      self.uiBinder.lab_content.text = config.BgIntroduction
      self:createModel(config.ModelId, config.ModelRatio, config.RoleCharacterAnim)
    end
  else
    self.uiBinder.lab_name.text = Lang("HandbookLockContent")
    self.uiBinder.lab_gender.text = Lang("HandbookLockContent")
    self.uiBinder.lab_standing.text = Lang("HandbookLockContent")
    self.uiBinder.lab_weap.text = Lang("HandbookLockContent")
    self.uiBinder.lab_character.text = Lang("HandbookLockContent")
    self.uiBinder.lab_content.text = Lang("HandbookLockContent")
  end
  if isClick then
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  end
end

function Handbook_character_windowView:createModel(modelId, scale, anim)
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  if modelId == nil or modelId == 0 then
    return
  end
  self.modelPos_ = Z.UnrealSceneMgr:GetTransPos("pos")
  self.modelQuaternion_ = Quaternion.Euler(Vector3.New(0, 165, 0))
  self.curShowModel_ = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_, modelId, function(model)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    model:SetAttrGoRotation(rotation)
    model:SetLuaAttrGoScale(scale)
    if anim ~= "" then
      model:SetLuaAttrModelPreloadClip(anim)
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(anim))
    else
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
    end
  end, nil, nil)
end

function Handbook_character_windowView:onUnrealsceneBeginDrag(eventData)
  if self.curShowModel_ then
    self.curShowModelRotation_ = self.curShowModel_:GetAttrGoRotation().eulerAngles
  end
end

function Handbook_character_windowView:onUnrealsceneDrag(eventData)
  if self.curShowModel_ then
    self.curShowModelRotation_.y = self.curShowModelRotation_.y - eventData.delta.x
    self.curShowModel_:SetAttrGoRotation(Quaternion.Euler(self.curShowModelRotation_))
  end
end

function Handbook_character_windowView:onUnrealsceneEndDrag(eventData)
end

return Handbook_character_windowView
