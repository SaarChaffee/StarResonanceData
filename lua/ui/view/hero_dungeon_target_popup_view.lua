local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_target_popupView = class("Hero_dungeon_target_popupView", super)
local itemClass = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function Hero_dungeon_target_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_target_popup")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.herdDungeonData_ = Z.DataMgr.Get("hero_dungeon_main_data")
  
  function self.weekTargetFunc_(container, dirtyKeys)
    self:loadTargetItem()
  end
end

function Hero_dungeon_target_popupView:initBinders()
  self.sceneMask_ = self.uiBinder.scenemask
  self.closeBtn_ = self.uiBinder.btn_close
  self.scrollView_ = self.uiBinder.scrollview_award
  self.prefabCache_ = self.uiBinder.prefab_cache
end

function Hero_dungeon_target_popupView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.vm_.CloseTargetPopupView()
  end)
end

function Hero_dungeon_target_popupView:OnActive()
  self.dungeonId_ = self.viewData.dungeonId
  self.itemClassTab_ = {}
  self:initBinders()
  self:initBtns()
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
  self:loadTargetItem()
  self:refreshResetTime()
end

function Hero_dungeon_target_popupView:loadTargetItem()
  Z.CoroUtil.create_coro_xpcall(function()
    local targetList, groupId = self.vm_.GetChallengeHeroDungeonTarget(self.dungeonId_)
    local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[groupId]
    local targetItemPath = self:GetPrefabCacheDataNew(self.prefabCache_, "target_item")
    for k, v in ipairs(targetList) do
      local item = self:AsyncLoadUiUnit(targetItemPath, "target_item" .. v.targetId, self.scrollView_.content.transform)
      if item then
        local targetTableRow = Z.TableMgr.GetTable("HeroDungeonTargetTableMgr").GetRow(v.targetId)
        if targetTableRow then
          item.lab_content.text = targetTableRow.TargetDes
          local finishCount = 0
          local dungeonTargetProgress
          if dungeonInfo and dungeonInfo.dungeonTargetProgress[targetTableRow.Id] then
            dungeonTargetProgress = dungeonInfo.dungeonTargetProgress[targetTableRow.Id]
          else
            dungeonTargetProgress = {targetProgress = 0, awardState = 0}
          end
          if dungeonTargetProgress then
            finishCount = dungeonTargetProgress.targetProgress
            self:setTargetItemState(item, dungeonTargetProgress.awardState)
          else
            self:setTargetItemState(item, E.DrawState.NoDraw)
          end
          self:loadAward(item.loop_item.content.transform, v.targetId, v.awardId, dungeonTargetProgress.awardState == E.DrawState.AlreadyDraw)
          item.lab_completeness_num.text = finishCount
          item.lab_num.text = targetTableRow.Num
          item.btn_get:RemoveAllListeners()
          self:AddAsyncClick(item.btn_get, function()
            local ret = self.vm_.AsyncGetAward(groupId, v.targetId, self.cancelSource:CreateToken())
            if ret == 0 then
              self:loadTargetItem()
              self.vm_.RefreshRed(self.dungeonId_)
              Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonProbailityChange, self.dungeonId_)
            end
          end)
        end
      end
    end
  end)()
end

function Hero_dungeon_target_popupView:setTargetItemState(item, state)
  item.Ref:SetVisible(item.lab_underway, state == E.DrawState.NoDraw)
  item.Ref:SetVisible(item.btn_get, state == E.DrawState.CanDraw)
  item.Ref:SetVisible(item.img_completed, state == E.DrawState.AlreadyDraw)
end

function Hero_dungeon_target_popupView:getAward(targetId)
  local awardTab = Z.Global.NormalDungeonWeekTarget
  for index, value in ipairs(awardTab) do
    if value[1] == targetId then
      return value
    end
  end
  return nil
end

function Hero_dungeon_target_popupView:loadAward(parent, targetId, awardId, haveGet)
  if awardId == nil or parent == nil then
    return
  end
  local awardItemPath = self.prefabCache_:GetString("award_item")
  if awardItemPath == "" or not awardItemPath then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(awardId)
    if awardList and awardItemPath and awardItemPath ~= "" then
      Z.CoroUtil.create_coro_xpcall(function()
        for key, value in pairs(awardList) do
          local itemName = targetId .. "award" .. key
          local item = self:AsyncLoadUiUnit(awardItemPath, itemName, parent)
          self.itemClassTab_[itemName] = itemClass.new(self)
          local itemData = {
            uiBinder = item,
            configId = value.awardId,
            isSquareItem = true,
            PrevDropType = value.PrevDropType,
            dungeonId = self.dungonId_,
            isShowReceive = haveGet ~= nil and haveGet or false
          }
          itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
          self.itemClassTab_[itemName]:Init(itemData)
        end
      end)()
    end
  end)()
end

function Hero_dungeon_target_popupView:OnDeActive()
  for _, v in pairs(self.itemClassTab_) do
    v:UnInit()
  end
  self.itemClassTab_ = nil
end

function Hero_dungeon_target_popupView:OnRefresh()
end

function Hero_dungeon_target_popupView:refreshResetTime()
  local restSecond, starTime = Z.TimeTools.GetLeftTimeByTimerId(Z.Global.ChallengeHeroDungeonFreshTimer)
  local restTime = Z.TimeFormatTools.FormatToDHMS(starTime)
  self.uiBinder.lab_time.text = Lang("HeroTargetPopupTime", {val = restTime})
end

return Hero_dungeon_target_popupView
