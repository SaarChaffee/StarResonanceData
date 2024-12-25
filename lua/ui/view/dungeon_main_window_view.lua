local UI = Z.UI
local super = require("ui.ui_view_base")
local Dungeon_main_windowView = class("Dungeon_main_windowView", super)
local dataMgr = require("ui.model.data_manager")
local data = Z.DataMgr.Get("dungeon_data")

function Dungeon_main_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "dungeon_main_window")
end

local initWidgets = function(self)
  self.background_ = self.uiBinder.rimg_secene_bg
  self.cont_left_title_ = self.uiBinder.cont_left_title
  self.group_introduce_ = self.uiBinder.group_introduce
  self.btnGo_ = self.uiBinder.btn_go
  self.btnClose_ = self.uiBinder.cont_base_bg.cont_map_title_top.cont_btn_return.btn
  self.loopProgress_ = self.uiBinder.loop_progress
  self.loopProgress_Layout_ = self.uiBinder.loop_progress_layout
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
  self.labInfo_ = self.uiBinder.lab_info
  self.labTitle_ = self.uiBinder.cont_base_bg.cont_map_title_top.lab_title
  self.labDungeonType_ = self.uiBinder.lab_title
  self.tipsRelativeTo_ = self.uiBinder.rimg_bg
end

function Dungeon_main_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  initWidgets(self)
  self.uiBinder.Ref:SetVisible(self.cont_left_title_, false)
  self.uiBinder.Ref:SetVisible(self.group_introduce_, false)
  self.uiBinder.Ref:SetVisible(self.btnGo_, false)
  self.enterdungeonsceneVm_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
  self.itemClassTab_ = {}
  self.dungeonId_ = tonumber(self.viewData)
  self.exploreValue_ = 0
  self:AddClick(self.btnClose_, function()
    Z.UIMgr:CloseView("dungeon_main_window")
  end)
  local dungeonScrollRect = self.loopProgress_
  self.dungeonLoopScrollRect = require("ui/component/loopscrollrect").new(dungeonScrollRect, self, require("ui.component.dungeon.dungeon_condition_item"))
  self.chestContainerEnd = self.dungeonChestItems_[#self.dungeonChestItems_].Trans.anchoredPosition.x
  self:activeWidgets()
  self:initBackground()
end

function Dungeon_main_windowView:activeWidgets()
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

function Dungeon_main_windowView:initBackground()
  local cfg = Z.TableMgr.GetTable("MainPlotDungeonTableMgr").GetRow(self.dungeonId_)
  if cfg then
    self.background_:SetImage(cfg.Background)
  end
end

function Dungeon_main_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.entering_ = false
  Z.CommonTipsVM.CloseTitleContentItems()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self:ClearAllUnits()
end

function Dungeon_main_windowView:refreshProBarAndChest()
  local cfgData = data:GetChestIntroductionById(self.dungeonId_)
  self.labProgress_.text = self.exploreValue_
  self.sliderProgress_.value = self.exploreValue_ * 0.01
  if cfgData and next(cfgData) then
    Z.CoroUtil.create_coro_xpcall(function()
      self:setChestItemData(cfgData)
    end)()
  end
end

function Dungeon_main_windowView:setChestItemData(itemList)
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
      if E.ChestStateTpe.NotOpen == chestStateTpe then
        item.Ref:SetVisible(imgOffTreasure, false)
        item.Ref:SetVisible(imgOnTreasure, true)
        item.Ref:SetVisible(imgOffDot, true)
        item.Ref:SetVisible(imgOnDot, false)
        item.Ref:SetVisible(item.img_light, false)
      elseif E.ChestStateTpe.AlreadyOpen == chestStateTpe then
        item.Ref:SetVisible(imgOffTreasure, true)
        item.Ref:SetVisible(imgOnTreasure, false)
        item.Ref:SetVisible(imgOffDot, false)
        item.Ref:SetVisible(imgOnDot, true)
        item.Ref:SetVisible(item.img_light, false)
      elseif E.ChestStateTpe.CanOpen == chestStateTpe then
        item.Ref:SetVisible(imgOffTreasure, false)
        item.Ref:SetVisible(imgOnTreasure, true)
        item.Ref:SetVisible(imgOffDot, false)
        item.Ref:SetVisible(imgOnDot, true)
        item.Ref:SetVisible(item.img_light, true)
      end
      self.dungeonChestItems_[index].btn_treasure:AddListener(function()
        if chestStateTpe == E.ChestStateTpe.CanOpen then
          Z.CoroUtil.create_coro_xpcall(function()
            local dungeonInfo = {}
            dungeonInfo.dungeonID = self.dungeonId_
            Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncSendPioneerAward(dungeonInfo, data.rewardId, self.cancelSource)
            item.Ref:SetVisible(imgOffTreasure, true)
            item.Ref:SetVisible(imgOnTreasure, false)
            item.Ref:SetVisible(imgOffDot, false)
            item.Ref:SetVisible(imgOnDot, true)
            item.Ref:SetVisible(item.img_light, false)
            chestStateTpe = E.ChestStateTpe.AlreadyOpen
          end)()
        elseif chestStateTpe == E.ChestStateTpe.NotOpen then
          local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(data.rewardId)
          self:chestItemShow(awardList, index)
        end
      end)
    end
  end
end

function Dungeon_main_windowView:refreshWidthTask()
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
  self.loopProgress_Layout_:ForceRebuildLayoutImmediate()
  self.loopProgressContent_:ForceRebuildLayoutImmediate()
end

function Dungeon_main_windowView:refreshDungeonIntroduction()
  local cfgData = data:GetDungeonIntroductionById(self.dungeonId_)
  self.labInfo_.text = cfgData.content
  self.labTitle_.text = cfgData.name
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  self.labDungeonType_.text = dungeonVm.GetDisplayNameOfType(cfgData.playType)
end

function Dungeon_main_windowView:chestItemShow(awardDataList, preValue)
  local name = string.zconcat(Lang("ExploreBox"), Lang("RomanNumeral" .. preValue))
  Z.CommonTipsVM.OpenTitleContentItems(self.tipsRelativeTo_, name, Lang("ExploreAwardTip"), awardDataList)
end

function Dungeon_main_windowView:OnRefresh()
  self:refreshWidthTask()
  self:refreshProBarAndChest()
  self:refreshDungeonIntroduction()
end

return Dungeon_main_windowView
