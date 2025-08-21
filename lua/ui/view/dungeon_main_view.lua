local UI = Z.UI
local super = require("ui.ui_view_base")
local Dungeon_mainView = class("Dungeon_mainView", super)
local dataMgr = require("ui.model.data_manager")
local data = Z.DataMgr.Get("dungeon_data")
local itemClass = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function Dungeon_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "dungeon_main")
end

function Dungeon_mainView:initWidgets()
  self.background_ = self.uiBinder.rimg_secene_bg
  self.btnDetail_ = self.uiBinder.btn_detail
  self.btnGo_ = self.uiBinder.btn_go
  self.btnClose_ = self.uiBinder.cont_base_bg.cont_map_title_top.cont_btn_return.btn
  self.btnAsk_ = self.uiBinder.btn_ask
  self.animMainCtrl_ = self.uiBinder.anim_main_ctrl
  self.loopProgress_ = self.uiBinder.loop_progress
  self.loopProgressLayout_ = self.uiBinder.loop_progress_layout
  self.loopProgressContent_ = self.uiBinder.loop_progress_content
  self.dungeonChestItems_ = {
    self.uiBinder.dungeon_chest_item_tpl1,
    self.uiBinder.dungeon_chest_item_tpl2,
    self.uiBinder.dungeon_chest_item_tpl3
  }
  self.labPercentages_ = {
    self.uiBinder.dungeon_chest_item_tpl1.lab_percentage,
    self.uiBinder.dungeon_chest_item_tpl2.lab_percentage,
    self.uiBinder.dungeon_chest_item_tpl3.lab_percentage
  }
  self.labProgress_ = self.uiBinder.lab_progress
  self.sliderProgress_ = self.uiBinder.slider
  self.groupAwards_ = self.uiBinder.group_awards
  self.groupAwardsContent_ = self.uiBinder.node_content_awards
  self.groupFinishStatus_ = self.uiBinder.group_finish_status
  self.labInfo_ = self.uiBinder.lab_info
  self.labTitle_ = self.uiBinder.cont_base_bg.cont_map_title_top.lab_title
  self.labDungeonType_ = self.uiBinder.lab_title
  self.tipsRelativeTo_ = self.uiBinder.rimg_bg
end

function Dungeon_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initWidgets()
  self.enterdungeonsceneVm_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
  self.rewardUnits_ = {}
  self.itemClassTab_ = {}
  self.dungeonId_ = tonumber(self.viewData)
  self.exploreValue_ = 0
  self:AddClick(self.btnClose_, function()
    self:playAnimations(Z.DOTweenAnimType.Close, function()
      Z.UIMgr:CloseView("dungeon_main")
    end)
  end)
  self:AddClick(self.btnAsk_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30010)
  end)
  self:AddClick(self.btnDetail_, function()
    local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if cfgData == nil then
      return
    end
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(cfgData.FirstPassAward)
    awardPreviewVm.OpenRewardDetailViewByListData(awardList)
  end)
  self:AddAsyncClick(self.btnGo_, function()
    self:enterDungeon()
  end, function()
    self.entering_ = false
  end)
  local dungeonScrollRect = self.loopProgress_
  self.dungeonLoopScrollRect = require("ui/component/loopscrollrect").new(dungeonScrollRect, self, require("ui.component.dungeon.dungeon_condition_item"))
  self.chestContainerEnd = self.dungeonChestItems_[#self.dungeonChestItems_].Trans.anchoredPosition.x
  self:activeWidgets()
  self:initBackground()
end

function Dungeon_mainView:activeWidgets()
  for _, item in ipairs(self.dungeonChestItems_) do
    local imgWidget
    imgWidget = item.img_on_dot
    if not imgWidget.gameObject.activeSelf then
      imgWidget.gameObject:SetActive(true)
      item.Ref:SetVisible(imgWidget, false)
    end
    imgWidget = item.img_on_treasure
    if not imgWidget.gameObject.activeSelf then
      imgWidget.gameObject:SetActive(true)
      item.Ref:SetVisible(imgWidget, false)
    end
    imgWidget = item.img_off_dot
    if not imgWidget.gameObject.activeSelf then
      imgWidget.gameObject:SetActive(true)
      item.Ref:SetVisible(imgWidget, false)
    end
    imgWidget = item.img_off_treasure
    if not imgWidget.gameObject.activeSelf then
      imgWidget.gameObject:SetActive(true)
      item.Ref:SetVisible(imgWidget, false)
    end
    imgWidget = item.img_light
    if not imgWidget.gameObject.activeSelf then
      imgWidget.gameObject:SetActive(true)
      item.Ref:SetVisible(imgWidget, false)
    end
  end
end

function Dungeon_mainView:initBackground()
  local cfg = Z.TableMgr.GetTable("MainPlotDungeonTableMgr").GetRow(self.dungeonId_)
  if cfg then
    self.background_:SetImage(cfg.Background)
  end
end

function Dungeon_mainView:playAnimations(animType, callback)
  if self.bDungeonPassed then
  end
  if callback ~= nil then
    self.animMainCtrl_:CoroPlay(animType, callback, function(err)
      if err ~= nil then
        logError("CoroPlay err={0}", err)
      end
      callback()
    end)
  else
    self.animMainCtrl_:Restart(animType)
  end
end

function Dungeon_mainView:enterDungeon()
  if self.enterdungeonsceneVm_.IsEnterDungeon(self.dungeonId_) then
    local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(tonumber(self.dungeonId_), true)
    if dungeonsTable == nil then
      return
    end
    if self.entering_ then
      Z.TipsVM.ShowTips(100000)
      return
    end
    self.entering_ = true
    self.enterdungeonsceneVm_.AsyncCreateLevel(dungeonsTable.FunctionID, self.dungeonId_, self.cancelSource:CreateToken())
    self.entering_ = false
  end
end

function Dungeon_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.entering_ = false
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.CommonTipsVM.CloseTitleContentItems()
  self:removeRewardItemUnits()
  self:ClearAllUnits()
  self.animMainCtrl_:ClearAll()
end

function Dungeon_mainView:refreshProBarAndChest()
  local cfgData = data:GetChestIntroductionById(self.dungeonId_)
  self.labProgress_.text = self.exploreValue_
  self.sliderProgress_.value = self.exploreValue_ * 0.01
  if cfgData and next(cfgData) then
    Z.CoroUtil.create_coro_xpcall(function()
      self:setChestItemData(cfgData)
    end)()
  end
end

function Dungeon_mainView:setChestItemData(itemList)
  if itemList and next(itemList) then
    Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(self.dungeonId_)
    local dungeonData = dataMgr.Get("dungeon_data")
    local pioneerInfo = dungeonData.PioneerInfos[self.dungeonId_]
    for index, data in ipairs(itemList) do
      local item = self.dungeonChestItems_[index]
      local posX = self.chestContainerEnd * data.preValue * 0.01
      item.Trans.anchoredPosition = Vector2.New(posX, 0)
      self.labPercentages_[index].text = string.format("%d%%", data.preValue)
      local chestStateTpe = E.ChestStateTpe.NotOpen
      if self.exploreValue_ >= data.preValue then
        chestStateTpe = E.ChestStateTpe.CanOpen
      end
      if pioneerInfo.awards[data.rewardId] then
        chestStateTpe = E.ChestStateTpe.AlreadyOpen
      end
      local imgOnDot = self.dungeonChestItems_[index].img_on_dot
      local imgOffDot = self.dungeonChestItems_[index].img_off_dot
      local imgOnTreasure = self.dungeonChestItems_[index].img_on_treasure
      local imgOffTreasure = self.dungeonChestItems_[index].img_off_treasure
      local isAlreadyOpen = E.ChestStateTpe.AlreadyOpen == chestStateTpe
      local isNotOpen = E.ChestStateTpe.NotOpen == chestStateTpe
      local isCanOpen = E.ChestStateTpe.CanOpen == chestStateTpe
      item.Ref:SetVisible(item.img_light, isCanOpen)
      item.Ref:SetVisible(item.img_red, isCanOpen)
      item.Ref:SetVisible(imgOffDot, isNotOpen)
      item.Ref:SetVisible(imgOnDot, not isNotOpen)
      item.Ref:SetVisible(imgOffTreasure, isAlreadyOpen)
      item.Ref:SetVisible(imgOnTreasure, not isAlreadyOpen)
      self.dungeonChestItems_[index].btn_treasure:AddListener(function()
        if chestStateTpe == E.ChestStateTpe.CanOpen then
          Z.CoroUtil.create_coro_xpcall(function()
            local dungeonInfo = {}
            dungeonInfo.dungeonID = self.dungeonId_
            local isOpen = Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncSendPioneerAward(dungeonInfo, data.rewardId, self.cancelSource)
            if isOpen then
              item.Ref:SetVisible(imgOffTreasure, true)
              item.Ref:SetVisible(imgOnTreasure, false)
              item.Ref:SetVisible(imgOffDot, false)
              item.Ref:SetVisible(imgOnDot, true)
              item.Ref:SetVisible(item.img_light, false)
              item.Ref:SetVisible(item.img_red, false)
              chestStateTpe = E.ChestStateTpe.AlreadyOpen
            end
          end)()
        elseif chestStateTpe == E.ChestStateTpe.NotOpen then
          local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(data.rewardId)
          self:chestItemShow(awardList, index)
        end
      end)
    end
  end
end

function Dungeon_mainView:removeRewardItemUnits()
  if not self.rewardUnits_ or not next(self.rewardUnits_) then
    return
  end
  for k, v in pairs(self.rewardUnits_) do
    self:RemoveUiUnit(k)
  end
  self.rewardUnits_ = {}
end

function Dungeon_mainView:refreshFirstPassReward()
  self.bDungeonPassed = Z.VMMgr.GetVM("ui_enterdungeonscene").IsPassDungeon(self.dungeonId_)
  if self.bDungeonPassed then
    self.uiBinder.Ref:SetVisible(self.groupFinishStatus_, true)
    self.uiBinder.Ref:SetVisible(self.btnDetail_, false)
    self.uiBinder.Ref:SetVisible(self.groupAwards_, false)
  else
    self.uiBinder.Ref:SetVisible(self.groupFinishStatus_, false)
    self.uiBinder.Ref:SetVisible(self.btnDetail_, true)
    self.uiBinder.Ref:SetVisible(self.groupAwards_, true)
    local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if cfgData == nil then
      return
    end
    local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(cfgData.FirstPassAward)
    self:removeRewardItemUnits()
    Z.CoroUtil.create_coro_xpcall(function()
      self:setFirstPassRewardItem(awardList)
    end)()
  end
end

function Dungeon_mainView:setFirstPassRewardItem(value)
  if value and next(value) then
    local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "item")
    if path ~= nil and path ~= "" then
      for k, v in pairs(value) do
        local name = string.format("firstPassRewardItem%s", k)
        local item = self:AsyncLoadUiUnit(path, name, self.groupAwardsContent_)
        local data = v
        self.rewardUnits_[name] = item
        self.itemClassTab_[name] = itemClass.new(self)
        local itemData = {
          uiBinder = item,
          configId = data.awardId,
          isSquareItem = true,
          PrevDropType = data.PrevDropType,
          dungeonId = self.dungonId_
        }
        itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
        self.itemClassTab_[name]:Init(itemData)
      end
    end
  end
end

function Dungeon_mainView:refreshWidthTask()
  Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(self.dungeonId_)
  local data = dataMgr.Get("dungeon_data")
  local pioneerInfo = data.PioneerInfos[self.dungeonId_]
  local pioneerData = pioneerInfo.pioneerData
  local tempDatas = {}
  for _, v in ipairs(pioneerData) do
    table.insert(tempDatas, v)
  end
  self.exploreValue_ = pioneerInfo.progress
  Z.VMMgr.GetVM("ui_enterdungeonscene").ShowPioneerTaskSort(tempDatas, self.dungeonId_)
  self.dungeonLoopScrollRect:SetData(tempDatas)
  self.loopProgressLayout_:ForceRebuildLayoutImmediate()
  self.loopProgressContent_:ForceRebuildLayoutImmediate()
end

function Dungeon_mainView:refreshDungeonIntroduction()
  local cfgData = data:GetDungeonIntroductionById(self.dungeonId_)
  self.labInfo_.text = cfgData.content
  self.labTitle_.text = cfgData.name
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  self.labDungeonType_.text = dungeonVm.GetDisplayNameOfType(cfgData.playType)
end

function Dungeon_mainView:chestItemShow(awardDataList, preValue)
  local name = string.zconcat(Lang("ExploreBox"), Lang("RomanNumeral" .. preValue))
  Z.CommonTipsVM.OpenTitleContentItems(self.tipsRelativeTo_, name, Lang("ExploreAwardTip"), awardDataList)
end

function Dungeon_mainView:OnRefresh()
  self:refreshWidthTask()
  self:refreshProBarAndChest()
  self:refreshFirstPassReward()
  self:refreshDungeonIntroduction()
  self:playAnimations(Z.DOTweenAnimType.Open)
end

return Dungeon_mainView
