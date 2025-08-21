local UI = Z.UI
local super = require("ui.ui_subview_base")
local Seasonact_activity_tplView = class("Seasonact_activity_tplView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local seasonActItem = require("ui.component.season.seasaon_activity_loop_item")
local seasonAwardItem = require("ui.component.season.seasaon_activity_award_loop_item")
local itemClass = require("common.item")

function Seasonact_activity_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "seasonact_activity_tpl", "seasonact/seasonact_activity_tpl", UI.ECacheLv.None)
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.seasonData_ = Z.DataMgr.Get("season_data")
end

function Seasonact_activity_tplView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self.itemClassTab_ = {}
  Z.UnrealSceneMgr:AsyncSetBackGround(E.SeasonUnRealBgPath.Scene)
  self.seasonActScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loopscroll_item, seasonActItem, "seasonact_list_left_tpl")
  self.seasonAwardScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_award_item, seasonAwardItem, "com_item_square_8")
  local d = {}
  self.subItemUnitNames_ = {}
  self.selectSubItem_ = nil
  self.subActDict_ = {}
  self.seasonActScrollRect_:Init(d)
  self.seasonAwardScrollRect_:Init(d)
  self:refreshLoop()
end

function Seasonact_activity_tplView:OnDeActive()
  self.subItemUnitNames_ = {}
  self.selectSubItem_ = nil
  self.seasonActScrollRect_:UnInit()
  self.seasonActScrollRect_ = nil
  self.seasonAwardScrollRect_:UnInit()
  self.seasonAwardScrollRect_ = nil
end

function Seasonact_activity_tplView:refreshLoop()
  local seasonActTable = Z.TableMgr.GetTable("SeasonActTableMgr").GetDatas()
  local data = {}
  for _, value in ipairs(seasonActTable) do
    if value.FunctionType == E.SeasonActFuncType.Recommend then
      if value.ParentId == 0 then
        table.insert(data, value)
      else
        if self.subActDict_[value.ParentId] == nil then
          self.subActDict_[value.ParentId] = {}
        end
        if value.RelatedDungeonId ~= 0 then
          if self:checkDungeonOpen(value) then
            table.insert(self.subActDict_[value.ParentId], value)
          end
        else
          table.insert(self.subActDict_[value.ParentId], value)
        end
      end
    end
  end
  table.sort(data, function(a, b)
    if a.Sort == b.Sort then
      return a.Id > b.Id
    else
      return a.Sort < b.Sort
    end
  end)
  for _, value in pairs(self.subActDict_) do
    table.sort(value, function(a, b)
      if a.Sort == b.Sort then
        return a.Id > b.Id
      else
        return a.Sort < b.Sort
      end
    end)
  end
  local index = self.seasonData_:GetSeasonActFuncId()
  if index == 0 then
    index = 1
  end
  self.seasonActScrollRect_:RefreshListView(data)
  self.seasonActScrollRect_:SetSelected(index)
  self.seasonActScrollRect_:MovePanelToItemIndex(index)
end

function Seasonact_activity_tplView:checkDungeonOpen(seasonActRow)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local dungeonList = dungeonData:GetDungeonList()
  for _, v in ipairs(dungeonList) do
    if v == seasonActRow.RelatedDungeonId then
      return true
    end
  end
  return false
end

function Seasonact_activity_tplView:onActSelect(Id, index)
  self.seasonData_:SetSeasonActFuncId(index)
  if self.subActDict_[Id] then
    self:showSubTog(Id)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
    Id = self.subActDict_[Id][1].Id
  else
    self:hideSubTog()
  end
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_2)
  self:onActChange(Id)
end

function Seasonact_activity_tplView:onActChange(Id)
  local actConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(Id)
  if actConfig == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_gored, Z.RedPointMgr.GetRedState(actConfig.FunctionId))
  self.uiBinder.rimg_secene_bg:SetImage(actConfig.BackGroundPic)
  self.uiBinder.lab_title.text = actConfig.Name
  self.uiBinder.lab_desc_content.text = actConfig.ActDes
  local labTitle_ = self.uiBinder.lab_desc_title
  local canShow_ = actConfig.OtherDes and actConfig.OtherDes ~= ""
  if canShow_ then
    labTitle_.text = actConfig.OtherDes
  end
  self.uiBinder.Ref:SetVisible(labTitle_, canShow_)
  local functionOpen = true
  local reason = {}
  if actConfig.FunctionId and actConfig.FunctionId ~= 0 then
    functionOpen, reason = self.switchVm_.CheckFuncSwitch(actConfig.FunctionId)
  end
  if functionOpen then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_go, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock_root, false)
  else
    if reason and reason[1] then
      self.uiBinder.node_lock.lab_lock.text = Lang("Function" .. reason[1].error, reason[1].params)
    else
      self.uiBinder.node_lock.lab_lock.text = Lang("ErrorInfo")
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_go, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock_root, true)
  end
  self:AddAsyncClick(self.uiBinder.btn_go, function()
    self:btnClickJump(actConfig)
  end)
  self:refreshItem(actConfig.PreviewAward)
end

function Seasonact_activity_tplView:showSubTog(id)
  local path = self.uiBinder.prefab_cache:GetString("list_sub_item")
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_content2, true)
  local root = self.uiBinder.layout_content2
  for _, value in ipairs(self.subItemUnitNames_) do
    self:RemoveUiUnit(value)
  end
  self.subItemUnitNames_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(self.subActDict_[id]) do
      local unit = self:AsyncLoadUiUnit(path, "sub_act_item" .. index, root)
      table.insert(self.subItemUnitNames_, "sub_act_item" .. index)
      unit.lab_name_on.text = value.Name
      unit.lab_name_off.text = value.Name
      unit.img_activity_on:SetImage(value.LabelPic)
      unit.img_activity_off:SetImage(value.LabelPic)
      unit.Ref:SetVisible(unit.node_on, false)
      unit.Ref:SetVisible(unit.node_off, true)
      self:AddAsyncClick(unit.btn, function()
        if self.selectSubItem_ then
          self.selectSubItem_.Ref:SetVisible(self.selectSubItem_.node_on, false)
          self.selectSubItem_.Ref:SetVisible(self.selectSubItem_.node_off, true)
        end
        unit.Ref:SetVisible(unit.node_on, true)
        unit.anim_group:Restart(Z.DOTweenAnimType.Tween_1)
        unit.Ref:SetVisible(unit.node_off, false)
        self.selectSubItem_ = unit
        self:onActChange(value.Id)
      end)
      if index == 1 then
        self.selectSubItem_ = unit
        unit.Ref:SetVisible(unit.node_on, true)
        unit.Ref:SetVisible(unit.node_off, false)
      end
    end
  end)()
end

function Seasonact_activity_tplView:hideSubTog()
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_content2, false)
end

function Seasonact_activity_tplView:refreshItem(awardId)
  local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardId)
  self.seasonAwardScrollRect_:RefreshListView(awardList, true)
end

function Seasonact_activity_tplView:btnClickJump(actconfig)
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  quickJumpVm.DoJumpByConfigParam(actconfig.QuickJumpType, actconfig.QuickJumpParam, {
    DynamicFlagName = actconfig.Name
  })
end

function Seasonact_activity_tplView:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root_ == nil then
    return nil
  end
  return self.uiBinder.prefabcache_root_:GetString(key)
end

function Seasonact_activity_tplView:OnRefresh()
end

function Seasonact_activity_tplView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Seasonact_activity_tplView
