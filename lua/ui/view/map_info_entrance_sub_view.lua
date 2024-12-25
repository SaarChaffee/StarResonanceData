local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_Info_Entrance_Sub_View = class("Map_Info_Entrance_Sub_View", super)
local itemClass = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function Map_Info_Entrance_Sub_View:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_info_entrance_sub", "map/map_info_entrance_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.enterdungeonsceneVm_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
end

function Map_Info_Entrance_Sub_View:initWidght()
  local cont_base_bg = self.uiBinder.cont_base_bg
  self.title_label_ = cont_base_bg.cont_map_title_top.lab_title
  self.dungeonChestItems_ = {
    cont_base_bg.group_dungeon_chest_item1,
    cont_base_bg.group_dungeon_chest_item2,
    cont_base_bg.group_dungeon_chest_item3
  }
  self.labPercentages_ = {
    cont_base_bg.group_dungeon_chest_item1.lab_percentage,
    cont_base_bg.group_dungeon_chest_item2.lab_percentage,
    cont_base_bg.group_dungeon_chest_item3.lab_percentage
  }
  self.imgOffs_ = {
    cont_base_bg.group_dungeon_chest_item1.img_off_dot,
    cont_base_bg.group_dungeon_chest_item1.img_off_treasure,
    cont_base_bg.group_dungeon_chest_item2.img_off_dot,
    cont_base_bg.group_dungeon_chest_item2.img_off_treasure,
    cont_base_bg.group_dungeon_chest_item3.img_off_dot,
    cont_base_bg.group_dungeon_chest_item3.img_off_treasure
  }
  self.imgOns_ = {
    cont_base_bg.group_dungeon_chest_item1.img_on_dot,
    cont_base_bg.group_dungeon_chest_item1.img_on_treasure,
    cont_base_bg.group_dungeon_chest_item2.img_on_dot,
    cont_base_bg.group_dungeon_chest_item2.img_on_treasure,
    cont_base_bg.group_dungeon_chest_item3.img_on_dot,
    cont_base_bg.group_dungeon_chest_item3.img_on_treasure
  }
  self.imgLights_ = {
    cont_base_bg.group_dungeon_chest_item1.img_light,
    cont_base_bg.group_dungeon_chest_item2.img_light,
    cont_base_bg.group_dungeon_chest_item3.img_light
  }
  self.btnTreasures_ = {
    cont_base_bg.group_dungeon_chest_item1.btn_treasure,
    cont_base_bg.group_dungeon_chest_item2.btn_treasure,
    cont_base_bg.group_dungeon_chest_item3.btn_treasure
  }
  self.labProgress_ = cont_base_bg.lab_progress
  self.sliderProgress_ = cont_base_bg.silder
  local endNode = self.dungeonChestItems_[#self.dungeonChestItems_]
  local x, _ = endNode.Trans:GetAnchorPosition(nil, nil)
  self.chestContainerEnd_ = x
  self.tipsRelativeTo_ = cont_base_bg.rimg_bg
  self.scene_bg_ = cont_base_bg.rimg_scene
  self.describe_ = cont_base_bg.lab_info
  self.award_group_search_ = cont_base_bg.group_awards.group_search
  self.award_content_ = cont_base_bg.group_awards.node_content
  self.award_none_tips_ = cont_base_bg.group_awards.lab_task_completion
  self:AddClick(cont_base_bg.cont_map_title_top.cont_btn_return.btn, function()
    self.parent_:CloseRightSubview()
  end)
  self:AddClick(cont_base_bg.btn_go, function()
    if self.tracedTag_ then
      local guideVM = Z.VMMgr.GetVM("goal_guide")
      guideVM.SetGuideGoals(E.GoalGuideSource.DungeonEntrance, nil)
      self.parent_:CloseRightSubview()
    else
      local zoneEntityGlobalTableMgr = Z.TableMgr.GetTable("ZoneEntityGlobalTableMgr")
      local sceneId = self.parent_:GetCurSceneId()
      local config = zoneEntityGlobalTableMgr.GetRow(sceneId * Z.ConstValue.GlobalLevelIdOffset + self.viewData.data.Uid)
      if config then
        local pos = Vector3.New(config.Position[1], config.Position[2], config.Position[3])
        local info = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.DungeonEntrance, sceneId, self.viewData.data.Uid, Z.GoalPosType.Zone, pos)
        local guideVM = Z.VMMgr.GetVM("goal_guide")
        guideVM.SetGuideGoals(E.GoalGuideSource.DungeonEntrance, {info})
      end
      self.parent_:CloseRightSubview()
    end
  end)
  self:AddClick(cont_base_bg.group_awards.btn_bg, function()
    local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if cfg == nil then
      return
    end
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(cfg.FirstPassAward)
    awardPreviewVm.OpenRewardDetailViewByListData(awardList)
  end)
end

function Map_Info_Entrance_Sub_View:OnActive()
  self:startAnimatedShow()
  self:initWidght()
  self.itemClassTab_ = {}
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.rewardUnits_ = {}
  self:initData()
end

function Map_Info_Entrance_Sub_View:initData()
  self.dungeonId_ = self.viewData.param
  local cfg = Z.TableMgr.GetTable("MainPlotDungeonTableMgr").GetRow(self.dungeonId_)
  if cfg then
    self.scene_bg_:SetImage(cfg.Background)
  end
  local data = Z.DataMgr.Get("dungeon_data")
  Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(self.dungeonId_)
  local pioneerInfo = data.PioneerInfos[self.dungeonId_]
  local cfgData = data:GetChestIntroductionById(self.dungeonId_)
  self:initProBarAndChest(pioneerInfo.progress, cfgData)
  local cfg = data:GetDungeonIntroductionById(self.dungeonId_)
  self:initTitleAndDesc(cfg)
  local dungeonPassed = Z.VMMgr.GetVM("ui_enterdungeonscene").IsPassDungeon(self.dungeonId_)
  local awardList
  if not dungeonPassed then
    local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if dungeonCfg ~= nil then
      awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(dungeonCfg.FirstPassAward)
    end
  end
  self:initAward(awardList)
  local mapVM = Z.VMMgr.GetVM("map")
  self.tracedTag_ = mapVM.CheckIsTracingFlagBySrcAndFlagData(E.GoalGuideSource.DungeonEntrance, self.parent_:GetCurSceneId(), self.viewData.data)
  self:initGoBtn()
end

function Map_Info_Entrance_Sub_View:initTitleAndDesc(cfg)
  self.title_label_.text = cfg.name
  self.describe_.text = cfg.content
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  if dungeonCfg ~= nil then
    if dungeonCfg.RecommendFightValue == 0 then
      self.uiBinder.cont_base_bg.lab_gs.text = Lang("GSSuggestNoLimit")
    else
      local param = {
        val = dungeonCfg.RecommendFightValue
      }
      self.uiBinder.cont_base_bg.lab_gs.text = Lang("GSSuggest", param)
    end
  end
end

function Map_Info_Entrance_Sub_View:initProBarAndChest(progress, cfgData)
  local dataMgr = require("ui.model.data_manager")
  self.labProgress_.text = progress
  self.sliderProgress_.value = progress * 0.01
  if cfgData and next(cfgData) then
    Z.CoroUtil.create_coro_xpcall(function()
      local itemList = cfgData
      if itemList and next(itemList) then
        Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(self.dungeonId_)
        local dungeonData = dataMgr.Get("dungeon_data")
        local pioneerInfo = dungeonData.PioneerInfos[self.dungeonId_]
        for index, data in ipairs(itemList) do
          local item = self.dungeonChestItems_[index]
          local posX = self.chestContainerEnd_ * data.preValue * 0.01
          item.Trans:SetAnchorPosition(posX, 0)
          self.labPercentages_[index].text = string.format("%d%%", data.preValue)
          local chestStateTpe = E.ChestStateTpe.NotOpen
          if progress >= data.preValue then
            chestStateTpe = E.ChestStateTpe.CanOpen
          end
          if pioneerInfo.awards[data.rewardId] then
            chestStateTpe = E.ChestStateTpe.AlreadyOpen
          end
          local imgOffsetStart = (index - 1) * 2 + 1
          local imgOffsetyEnd = imgOffsetStart + 1
          local bool1, bool2, bool3, bool4, bool5
          if E.ChestStateTpe.NotOpen == chestStateTpe then
            bool1 = false
            bool2 = true
            bool3 = true
            bool4 = false
            bool5 = false
          elseif E.ChestStateTpe.AlreadyOpen == chestStateTpe then
            bool1 = true
            bool2 = false
            bool3 = false
            bool4 = true
            bool5 = false
          elseif E.ChestStateTpe.CanOpen == chestStateTpe then
            bool1 = false
            bool2 = true
            bool3 = false
            bool4 = true
            bool5 = true
          end
          self.dungeonChestItems_[index].Ref:SetVisible(self.imgOffs_[imgOffsetyEnd], bool1)
          self.dungeonChestItems_[index].Ref:SetVisible(self.imgOns_[imgOffsetyEnd], bool2)
          self.dungeonChestItems_[index].Ref:SetVisible(self.imgOffs_[imgOffsetStart], bool3)
          self.dungeonChestItems_[index].Ref:SetVisible(self.imgOns_[imgOffsetStart], bool4)
          self.dungeonChestItems_[index].Ref:SetVisible(self.imgLights_[index], bool5)
          if self.chestSfxs_ then
            self.chestSfxs_[index].Go:SetActive(bool5)
          end
          self.btnTreasures_[index]:AddListener(function()
            if chestStateTpe == E.ChestStateTpe.CanOpen then
              Z.CoroUtil.create_coro_xpcall(function()
                local dungeonInfo = {}
                dungeonInfo.dungeonID = self.dungeonId_
                Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncSendPioneerAward(dungeonInfo, data.rewardId, self.cancelSource)
                self.dungeonChestItems_[imgOffsetStart].Ref:SetVisible(self.imgOffs_[imgOffsetStart], false)
                self.dungeonChestItems_[imgOffsetStart + 1].Ref:SetVisible(self.imgOns_[imgOffsetStart + 1], true)
                self.dungeonChestItems_[imgOffsetStart].Ref:SetVisible(self.imgOffs_[imgOffsetStart], true)
                self.dungeonChestItems_[imgOffsetStart + 1].Ref:SetVisible(self.imgOns_[imgOffsetStart + 1], false)
                self.dungeonChestItems_[index].Ref:SetVisible(self.imgLights_[index], false)
                if self.chestSfxs_ then
                  self.chestSfxs_[index].Go:SetActive(false)
                end
                chestStateTpe = E.ChestStateTpe.AlreadyOpen
              end)()
            elseif chestStateTpe == E.ChestStateTpe.NotOpen then
              local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(data.rewardId)
              self:chestItemShow(awardList, index)
            end
          end)
        end
      end
    end)()
  end
end

function Map_Info_Entrance_Sub_View:initAward(award)
  local root = self.uiBinder.cont_base_bg.group_awards
  if not award then
    root.Ref:SetVisible(self.award_group_search_, false)
    root.Ref:SetVisible(self.award_none_tips_, true)
  else
    root.Ref:SetVisible(self.award_group_search_, true)
    root.Ref:SetVisible(self.award_none_tips_, false)
    Z.CoroUtil.create_coro_xpcall(function()
      for k, v in pairs(award) do
        local name = string.format("firstPassRewardItem%s", k)
        local item = self:AsyncLoadUiUnit(self:GetPrefabCacheData("item"), name, self.award_content_)
        local data = v
        self.rewardUnits_[name] = item
        self.itemClassTab_[name] = itemClass.new(self)
        local itemData = {
          uiBinder = item,
          configId = data.awardId,
          isSquareItem = true,
          PrevDropType = data.PrevDropType
        }
        itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
        self.itemClassTab_[name]:Init(itemData)
      end
    end)()
  end
end

function Map_Info_Entrance_Sub_View:chestItemShow(awardDataList, index)
  local title = string.zconcat(Lang("ExploreBox"), Lang("RomanNumeral" .. index))
  Z.CommonTipsVM.OpenTitleContentItems(self.tipsRelativeTo_.transform, title, Lang("ExploreAwardTip"), awardDataList)
end

function Map_Info_Entrance_Sub_View:initGoBtn()
  if self.tracedTag_ then
    self.uiBinder.cont_base_bg.normal_lab_content.text = Lang("cancleTrace")
  else
    self.uiBinder.cont_base_bg.normal_lab_content.text = Lang("trace")
  end
end

function Map_Info_Entrance_Sub_View:OnDeActive()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.CommonTipsVM.CloseTitleContentItems()
  if self.rewardUnits_ and next(self.rewardUnits_) then
    for k, _ in pairs(self.rewardUnits_) do
      self:RemoveUiUnit(k)
    end
  end
  self.rewardUnits_ = nil
end

function Map_Info_Entrance_Sub_View:startAnimatedShow()
  self.uiBinder.anim_main_ctrl:Restart(Z.DOTweenAnimType.Open)
end

function Map_Info_Entrance_Sub_View:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim_main_ctrl.CoroPlay)
  coro(self.uiBinder.anim_main_ctrl, Z.DOTweenAnimType.Close)
end

function Map_Info_Entrance_Sub_View:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root == nil then
    return nil
  end
  return self.uiBinder.prefabcache_root:GetString(key)
end

return Map_Info_Entrance_Sub_View
