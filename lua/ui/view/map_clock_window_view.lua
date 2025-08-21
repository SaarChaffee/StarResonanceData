local UI = Z.UI
local super = require("ui.ui_view_base")
local Map_clock_windowView = class("Map_clock_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local StickItem = require("ui.component.map.map_stick_comp")
local item = require("common.item_binder")

function Map_clock_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "map_clock_window")
  self.itemClass_ = item.new(self)
end

function Map_clock_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:startAnimatedShow()
  self.uiBinder.eff:SetEffectGoVisible(true)
  self:AddAsyncClick(self.uiBinder.btn_return, function()
    Z.VMMgr.GetVM("map_clock").CloseMapClockMapView()
  end)
  self.itemClassTab_ = {}
  Z.UnrealSceneMgr:InitSceneCamera()
  self.mapClockVm_ = Z.VMMgr.GetVM("map_clock")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(6009)
  end)
  self:AddAsyncClick(self.uiBinder.btn_icon_box, function()
    local config = Z.TableMgr.GetTable("MapBookTableMgr").GetRow(self.selectMapId_)
    if config == nil then
      return
    end
    local received = self.mapClockVm_.CheckGetMapRewawrd(self.selectMapId_)
    local itemList = {}
    for _, value in pairs(self.awardPreviewVm_.GetAllAwardPreListByIds(config.AwardId)) do
      local item = {
        ItemId = value.awardId,
        ItemNum = value.awardNum,
        received = received
      }
      table.insert(itemList, item)
    end
    local canReceive = self.mapClockVm_.CheckMapAllStickerUnlock(self.selectMapId_) and not received
    local onConfirm = function()
      if canReceive then
        self.mapClockVm_.AsyncGetMapReward(self.selectMapId_, self.cancelSource:CreateToken())
      end
    end
    local labOK
    if canReceive then
      labOK = Lang("Receive")
    end
    if received then
      labOK = Lang("Received")
    end
    local dialogViewData = {
      dlgType = E.DlgType.OK,
      labTitle = Lang("RewardPreview"),
      labDesc = Lang("MapAllClockReward"),
      onConfirm = onConfirm,
      labOK = labOK,
      itemList = itemList
    }
    Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
  end)
  self:AddAsyncClick(self.uiBinder.btn_unlock, function()
    self.mapClockVm_.AsyncGetStickerReward(self.selectMapId_, self.selectStickerId_, self.cancelSource:CreateToken())
  end)
  Z.EventMgr:Add(Z.ConstValue.MapBook.GetStickerReward, self.onGetStickerReward, self)
  Z.EventMgr:Add(Z.ConstValue.MapBook.GetMapBookReward, self.onGetMapBookReward, self)
  self.selectMapId_ = self.viewData.bookId or 701
  self.selectStickerId_ = nil
  self.selectStickUnit_ = nil
  self.mapScale_ = true
  self.initLoop_ = false
  self.conditionNames_ = {}
  self.rewardUnitNames_ = {}
  self:changeMap(self.selectMapId_)
end

function Map_clock_windowView:CustomClose()
end

function Map_clock_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("map_clock_window")
end

function Map_clock_windowView:onGetMapBookReward()
  self:refreshBoxIcon()
end

function Map_clock_windowView:onGetStickerReward()
  self:refreshStickLoop()
  self:refreshBtn()
  self:refreshBoxIcon()
  self:strickerUnlockAnim()
end

function Map_clock_windowView:strickerUnlockAnim()
  local config = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(self.selectStickerId_)
  if config == nil then
    return
  end
  self.mapBookModelComp_:SetUnlockAnim(config.Number - 1, 1, 1)
  Z.Delay(1.2, self.cancelSource:CreateToken())
  self.mapBookModelComp_:SetModelGray(config.Number - 1, false)
  self.mapBookModelComp_:SetUnlockAnim(config.Number - 1, 0, 1)
  self.mapBookModelComp_:PlayAnim(config.Number - 1, "unlock")
  Z.Delay(0.5, self.cancelSource:CreateToken())
  self.mapClockVm_.ShowAward(self.selectStickerId_)
end

function Map_clock_windowView:refreshBoxIcon()
  if self.mapClockVm_.CheckMapAllStickerUnlock(self.selectMapId_) then
    if self.mapClockVm_.CheckGetMapRewawrd(self.selectMapId_) then
      self.uiBinder.btn_icon_box.IsDisabled = true
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, false)
    else
      self.uiBinder.btn_icon_box.IsDisabled = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, true)
    end
  else
    self.uiBinder.btn_icon_box.IsDisabled = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, false)
  end
end

function Map_clock_windowView:changeMap(mapId)
  self.selectMapId_ = mapId
  self.mapConfig_ = Z.TableMgr.GetTable("MapBookTableMgr").GetRow(self.selectMapId_)
  if self.mapConfig_ == nil then
    return
  end
  local sceneConfig = Z.TableMgr.GetTable("SceneTableMgr").GetRow(self.mapConfig_.SceneId)
  if sceneConfig == nil then
    return
  end
  self.uiBinder.lab_map_name.text = sceneConfig.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_rightinfo, false)
  self:loadMap()
  self:refreshBoxIcon()
  self.uiBinder.btn_box_rect:SetAnchorPosition(-30, self.uiBinder.btn_box_rect.anchoredPosition.y)
end

function Map_clock_windowView:loadMap()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.mapGo_ then
      Z.UnrealSceneMgr:ClearLoadPrefab(self.mapGo_)
      self.mapGo_ = nil
    end
    self.mapGo_ = Z.UnrealSceneMgr:LoadScenePrefab(self.mapConfig_.Model, nil, Vector3.New(-0.1, 0.35, -3.8), self.cancelSource:CreateToken())
    Z.UnrealSceneMgr:DoCameraAnim("mapBookEnter")
    self.mapBookModelComp_ = Panda.ZUi.ZUnrealMapBookModel.GetZUnrealMapBookModelComp(self.mapGo_)
    self.mapBookModelComp_:SetModelRotAnim(Vector3.New(0, 180, 0), 0.01)
    self:refreshStickLoop()
    if self.effUid_ then
      Z.UnrealSceneMgr:ClearEffect(self.effUid_)
    end
    self.effUid_ = Z.UnrealSceneMgr:CreatEffect("env/p_fx_env_fld001_spot_prop_001", "env_effect")
    Z.UnrealSceneMgr:SetEffectParent(self.effUid_, self.mapGo_.transform)
  end)()
end

function Map_clock_windowView:refreshStickLoop()
  local stickerMaps = {}
  for _, value in ipairs(self.mapConfig_.StickerId) do
    local data = {}
    data.Id = value
    data.finish = 0
    if self.mapClockVm_.CheckStickAllTaskFinish(self.selectMapId_, value) then
      data.finish = 1
    end
    data.unlock = 0
    if self.mapClockVm_.CheckStickUnlock(self.selectMapId_, value) then
      data.unlock = 1
    end
    data.congfig = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(value)
    data.mapId = self.selectMapId_
    table.insert(stickerMaps, data)
    self:refreshStickUnit(value)
  end
  table.sort(stickerMaps, function(a, b)
    if a.unlock == b.unlock then
      if a.finish == b.finish then
        return a.congfig.SortId < b.congfig.SortId
      else
        return a.finish > b.finish
      end
    else
      return a.unlock < b.unlock
    end
  end)
  if self.initLoop_ then
    self.loopListView_:ClearAllSelect()
    self.loopListView_:RefreshListView(stickerMaps)
  else
    self.loopListView_ = loopListView.new(self, self.uiBinder.loop_list, StickItem, "map_item_tpl")
    self.loopListView_:Init(stickerMaps)
    self.initLoop_ = true
  end
end

function Map_clock_windowView:refreshStickUnit(stickerId)
  local config = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(stickerId)
  if config == nil then
    return
  end
  local finishTasks = self.mapClockVm_.CheckStickAllTaskFinish(self.selectMapId_, stickerId)
  local unlock = self.mapClockVm_.CheckStickUnlock(self.selectMapId_, stickerId)
  self.mapBookModelComp_:SetModelGray(config.Number - 1, not finishTasks or not unlock)
  self.mapBookModelComp_:SetModelSelect(config.Number - 1, false)
  self.mapBookModelComp_:SetModelVisible(config.Number - 1, unlock)
  if unlock and (config.Number - 1 == 8 or config.Number - 1 == 10) then
    self.mapBookModelComp_:PlayAnim(config.Number - 1, "idle")
  end
end

function Map_clock_windowView:onStickerSelected(stickerId)
  if stickerId == nil then
    return
  end
  self.uiBinder.btn_box_rect:SetAnchorPosition(-530, self.uiBinder.btn_box_rect.anchoredPosition.y)
  if self.mapScale_ then
    self.mapBookModelComp_:SetModelPosAnim(Vector3.New(-0.22, 0.39, -3.8), 1)
    self.mapBookModelComp_:SetModelScaleAnim(Vector3.New(0.85, 0.85, 0.85), 1)
    self.mapScale_ = false
  end
  self:startPlaySelectAnim()
  if self.selectStickerId_ then
    local lastStickerConfig = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(self.selectStickerId_)
    if lastStickerConfig then
      local unlock = self.mapClockVm_.CheckStickUnlock(self.selectMapId_, self.selectStickerId_)
      self.mapBookModelComp_:SetModelSelect(lastStickerConfig.Number - 1, false)
      self.mapBookModelComp_:SetModelVisible(lastStickerConfig.Number - 1, unlock)
    end
  end
  self.selectStickerId_ = stickerId
  local stickerConfig = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(self.selectStickerId_)
  if stickerConfig == nil then
    return
  end
  self.mapBookModelComp_:SetModelSelect(stickerConfig.Number - 1, true)
  self.mapBookModelComp_:SetModelVisible(stickerConfig.Number - 1, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_rightinfo, true)
  self.uiBinder.lab_sticker_name.text = stickerConfig.Name
  self.uiBinder.lab_quest_desc.text = Z.TableMgr.DecodeLineBreak(stickerConfig.Des)
  for _, value in ipairs(self.conditionNames_) do
    self:RemoveUiUnit(value)
  end
  for _, value in ipairs(self.rewardUnitNames_) do
    self:RemoveUiUnit(value)
  end
  self.conditionNames_ = {}
  self.rewardUnitNames_ = {}
  local conditionRoot = self.uiBinder.layout_node_content
  local rewardItemRoot = self.uiBinder.layout_item_content
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(stickerConfig.TaskId) do
      local name = string.format("condition_%s", index)
      local unit = self:AsyncLoadUiUnit(self.uiBinder.prefab_cache:GetString("conditionUnit"), name, conditionRoot)
      self:refreshConditionUnit(unit, value)
      table.insert(self.conditionNames_, name)
    end
    local rewardIds = self.awardPreviewVm_.GetAllAwardPreListByIds(stickerConfig.AwardId)
    for index, value in ipairs(rewardIds) do
      local name = string.format("reward_%s", index)
      if self.itemClassTab_[index] then
        self.itemClassTab_[index]:UnInit()
      else
        self.itemClassTab_[index] = item.new(self)
      end
      local unit = self:AsyncLoadUiUnit(self.uiBinder.prefab_cache:GetString("rewardItemUnit"), name, rewardItemRoot)
      local itemData = {
        uiBinder = unit,
        configId = value.awardId,
        isShowZero = false,
        isShowOne = true,
        isSquareItem = true,
        PrevDropType = value.PrevDropType
      }
      itemData.labType, itemData.lab = self.awardPreviewVm_.GetPreviewShowNum(value)
      self.itemClassTab_[index]:Init(itemData)
    end
    self:refreshBtn()
  end)()
end

function Map_clock_windowView:refreshBtn()
  local finishTasks = self.mapClockVm_.CheckStickAllTaskFinish(self.selectMapId_, self.selectStickerId_)
  local getStickerAward = self.mapClockVm_.CheckStickUnlock(self.selectMapId_, self.selectStickerId_)
  if finishTasks then
    if getStickerAward then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, true)
      self.uiBinder.btn_unlock.IsDisabled = false
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, true)
    self.uiBinder.btn_unlock.IsDisabled = true
  end
end

function Map_clock_windowView:refreshConditionUnit(unit, taskId)
  local taskConfig = Z.TableMgr.GetTable("MapStickerTaskTableMgr").GetRow(taskId)
  if taskConfig then
    local finish = self.mapClockVm_.CheckTaskFinish(self.selectMapId_, self.selectStickerId_, taskId)
    unit.Ref:SetVisible(unit.img_target_photo_completed, finish)
    unit.group_target_photo:SetParent(unit.Trans)
    local finishNum = 0
    local totalNum = 1
    local targetId = taskConfig.TargetId[1]
    if taskConfig.TargetNum and taskConfig.TargetNum ~= 0 then
      targetId = taskConfig.TargetNum
    end
    local targetConfig = Z.TableMgr.GetTable("MapStickerTargetTableMgr").GetRow(targetId)
    if targetConfig then
      totalNum = targetConfig.Num
    end
    if finish then
      finishNum = totalNum
    else
      finishNum = self.mapClockVm_.GetTaskFinishTargetNum(self.selectMapId_, self.selectStickerId_, taskId, targetId)
    end
    local colorTag = E.TextStyleTag.White
    if finish then
      colorTag = E.TextStyleTag.MapTextFinish
    end
    unit.lab_num.text = Z.RichTextHelper.ApplyStyleTag(finishNum .. "/" .. totalNum, colorTag)
    unit.lab_target_desc.text = Z.RichTextHelper.ApplyStyleTag(taskConfig.Des, colorTag)
  end
end

function Map_clock_windowView:OnDeActive()
  self.itemClass_:UnInit()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.selectStickUnit_ then
    self.selectStickUnit_.Trans:SetScale(1, 1)
    self.selectStickUnit_.Trans:SetSizeDelta(self.size_.x, self.size_.y)
    self.selectStickUnit_ = nil
  end
  if self.mapGo_ then
    Z.UnrealSceneMgr:ClearLoadPrefab(self.mapGo_)
    self.mapGo_ = nil
  end
  if self.effUid_ then
    Z.UnrealSceneMgr:ClearEffect(self.effUid_)
    self.effUid_ = nil
  end
  for _, itemClass in ipairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
end

function Map_clock_windowView:OnRefresh()
  if not self.mapScale_ then
    self.mapBookModelComp_:SetModelScaleAnim(Vector3.New(1, 1, 1), 0.01)
  end
end

function Map_clock_windowView:startPlaySelectAnim()
  self.uiBinder.anim_clock:Restart(Z.DOTweenAnimType.Tween_0)
end

function Map_clock_windowView:startAnimatedShow()
  self.uiBinder.anim_clock:Restart(Z.DOTweenAnimType.Open)
end

return Map_clock_windowView
