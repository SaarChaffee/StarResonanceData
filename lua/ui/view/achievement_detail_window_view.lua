local UI = Z.UI
local super = require("ui.ui_view_base")
local Achievement_detail_windowView = class("Achievement_detail_windowView", super)
local AchievementDefine = require("ui.model.achievement_define")
local LoopScrollRect_ = require("ui.component.loop_list_view")
local AchievementFirstLoopItem = require("ui.component.achievement.achievement_first_tpl_item")
local AchievementSecondLoopItem = require("ui.component.achievement.achievement_second_tpl_item")
local AchievementListTplItem = require("ui.component.achievement.achievement_list_tpl_item")
local AchievementDataTableMap = require("table.AchievementDateTableMap")

function Achievement_detail_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "achievement_detail_window")
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function Achievement_detail_windowView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpSysVM = Z.VMMgr.GetVM("helpsys")
    helpSysVM.OpenFullScreenTipsView(400010)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_search, function()
    self.IsInSearch = true
    self:refreshSearchBtn()
    self.searchAchievements_ = self.achievementVM_.GetSearchAchievements(AchievementDefine.PermanentAchievementType, self.searchStr_)
    self:refreshUI()
  end)
  self:AddAsyncClick(self.uiBinder.btn_clear, function()
    self.IsInSearch = false
    self.searchStr_ = nil
    self.uiBinder.input_search.text = ""
    self:refreshSearchBtn()
    self:refreshUI()
  end)
  self.uiBinder.input_search:AddListener(function(str)
    self.searchStr_ = str
  end)
  self.leftLoopListView_ = LoopScrollRect_.new(self, self.uiBinder.loop_left_item)
  self.leftLoopListView_:SetGetItemClassFunc(function(data)
    if data.ParentId == nil then
      return AchievementFirstLoopItem
    else
      return AchievementSecondLoopItem
    end
  end)
  self.leftLoopListView_:SetGetPrefabNameFunc(function(data)
    if Z.IsPCUI then
      if data.ParentId == nil then
        return "season_achievement_first_tpl_pc"
      else
        return "season_achievement_second_tpl_pc"
      end
    elseif data.ParentId == nil then
      return "season_achievement_first_tpl"
    else
      return "season_achievement_second_tpl"
    end
  end)
  self.leftLoopListView_:Init({})
  self.rightLoopListView_ = LoopScrollRect_.new(self, self.uiBinder.loop_right_item, AchievementListTplItem, "achievement_list_tpl", true)
  self.rightLoopListView_:Init({})
  self.allAchievements_ = self.achievementVM_.GetSearchAchievements(AchievementDefine.PermanentAchievementType)
  self.searchAchievements_ = {}
  self.searchStr_ = nil
  self.IsInSearch = false
  self.uiBinder.input_search.text = ""
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.Achievement)
  if functionConfig then
    self.uiBinder.lab_view_title.text = functionConfig.Name
  end
  self:refreshSearchBtn()
  if self.viewData then
    self:SelectAchievementClass(self.viewData)
  else
    self:refreshUI()
  end
  Z.EventMgr:Add(Z.ConstValue.Achievement.OnAchievementDataChange, self.refreshList, self)
end

function Achievement_detail_windowView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Achievement.OnAchievementDataChange, self.refreshList, self)
  self.selectAchievementClass_ = nil
  self.selectAchievementId_ = nil
  self.leftLoopListView_:UnInit()
  self.leftLoopListView_ = nil
  self.rightLoopListView_:UnInit()
  self.rightLoopListView_ = nil
end

function Achievement_detail_windowView:OnRefresh()
end

function Achievement_detail_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("season_achievement_detail")
end

function Achievement_detail_windowView:GetClassesCount(class)
  local datas = {}
  if self.IsInSearch then
    datas = self.searchAchievements_[class]
  else
    datas = self.allAchievements_[class]
  end
  local count = 0
  if datas then
    for k, _ in pairs(datas) do
      count = count + self:GetAchievementIdCount(class, k)
    end
  end
  return count
end

function Achievement_detail_windowView:GetAchievementIdCount(class, id)
  local count = 0
  if class then
    local datas = {}
    if self.IsInSearch then
      datas = self.searchAchievements_[class][id]
    else
      datas = self.allAchievements_[class][id]
    end
    count = #datas
  else
    local datas = {}
    if self.IsInSearch then
      datas = self.searchAchievements_
    else
      datas = self.allAchievements_
    end
    for _, v in pairs(datas) do
      if v[id] ~= nil then
        count = #v[id]
        break
      end
    end
  end
  return count
end

function Achievement_detail_windowView:GetSelectAchievementClass()
  return self.selectAchievementClass_
end

function Achievement_detail_windowView:ResetAchievementId()
  if self.selectAchievementId_ == nil then
    return
  end
  local loopData = {}
  if self.IsInSearch then
    loopData = self.searchAchievements_[self.selectAchievementClass_]
  else
    loopData = self.allAchievements_[self.selectAchievementClass_]
  end
  if loopData and next(loopData) then
    local temps = self:getSortClasses()
    local dataCount = 0
    local selectAchievementIndex = 1
    for _, temp in ipairs(temps) do
      dataCount = dataCount + 1
      if temp == self.selectAchievementClass_ then
        local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(temp)
        if config and config.EntryList and 0 < #config.EntryList then
          for _, entry in ipairs(config.EntryList) do
            if loopData[entry] then
              dataCount = dataCount + 1
              if entry == self.selectAchievementId_ then
                selectAchievementIndex = dataCount
                break
              end
            end
          end
        end
      end
    end
    self.leftLoopListView_:SetSelected(selectAchievementIndex)
  end
end

function Achievement_detail_windowView:SelectAchievementClass(id)
  if self.selectAchievementClass_ and self.selectAchievementClass_ == id then
    return
  end
  self.selectAchievementClass_ = id
  local datas = {}
  if self.IsInSearch then
    datas = self.searchAchievements_[id]
  else
    datas = self.allAchievements_[id]
  end
  local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(id)
  if config and config.EntryList then
    local tempAchievementId
    for _, entry in ipairs(config.EntryList) do
      if datas[entry] ~= nil and 0 < #datas[entry] then
        if tempAchievementId == nil then
          tempAchievementId = entry
        end
        local redDot = self.achievementVM_.GetRedNodeId(entry)
        if Z.RedPointMgr.GetRedState(redDot) then
          self:SelectAchievementId(entry, true)
          return
        end
      end
    end
    if tempAchievementId then
      self:SelectAchievementId(tempAchievementId, true)
    end
  end
end

function Achievement_detail_windowView:SelectAchievementId(id, needRefreshLoop)
  if self.selectAchievementId_ and self.selectAchievementId_ == id then
    return
  end
  self.selectAchievementId_ = id
  if needRefreshLoop then
    self:refreshLoopList()
  end
  self:refreshRightLoopList()
end

function Achievement_detail_windowView:refreshList()
  self.leftLoopListView_:RefreshAllShownItem()
  self.rightLoopListView_:RefreshAllShownItem()
end

function Achievement_detail_windowView:refreshLoopList()
  local loopData = {}
  if self.selectAchievementClass_ then
    if self.IsInSearch then
      loopData = self.searchAchievements_[self.selectAchievementClass_]
    else
      loopData = self.allAchievements_[self.selectAchievementClass_]
    end
  end
  if loopData and next(loopData) then
    local temps = self:getSortClasses()
    local datas = {}
    local dataCount = 0
    local selectAchievementIndex = 1
    for _, temp in ipairs(temps) do
      dataCount = dataCount + 1
      datas[dataCount] = {Id = temp}
      if temp == self.selectAchievementClass_ then
        local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(temp)
        if config and config.EntryList and 0 < #config.EntryList then
          for _, entry in ipairs(config.EntryList) do
            if loopData[entry] then
              dataCount = dataCount + 1
              datas[dataCount] = {Id = entry, ParentId = temp}
              if entry == self.selectAchievementId_ then
                selectAchievementIndex = dataCount
              end
            end
          end
        end
      end
    end
    self.leftLoopListView_:RefreshListView(datas)
    self.leftLoopListView_:SetSelected(selectAchievementIndex)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, false)
  else
    self.leftLoopListView_:ClearAllSelect()
    self.leftLoopListView_:RefreshListView({})
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, true)
    self.rightLoopListView_:RefreshListView({})
  end
end

function Achievement_detail_windowView:refreshSearchBtn()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_clear, self.IsInSearch)
end

function Achievement_detail_windowView:getSortClasses()
  local datas = {}
  if self.IsInSearch then
    datas = self.searchAchievements_
  else
    datas = self.allAchievements_
  end
  local classes = {}
  for k, v in pairs(datas) do
    table.insert(classes, k)
  end
  local mgr = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr")
  table.sort(classes, function(a, b)
    local aConfig = mgr.GetRow(a)
    local bConfig = mgr.GetRow(b)
    if aConfig and bConfig then
      return aConfig.SortID < bConfig.SortID
    else
      return a < b
    end
  end)
  return classes
end

function Achievement_detail_windowView:refreshUI()
  self.selectAchievementClass_ = nil
  self.selectAchievementId_ = nil
  local classes = self:getSortClasses()
  if classes[1] then
    self:SelectAchievementClass(classes[1])
  else
    self:refreshLoopList()
    self:refreshRightLoopList()
  end
end

function Achievement_detail_windowView:refreshRightLoopList()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bottom, false)
  local achievements = {}
  if self.selectAchievementClass_ and self.selectAchievementId_ then
    if self.IsInSearch then
      achievements = self.searchAchievements_[self.selectAchievementClass_][self.selectAchievementId_]
    else
      achievements = self.allAchievements_[self.selectAchievementClass_][self.selectAchievementId_]
    end
    if achievements then
      table.sort(achievements, function(a, b)
        local aState = self.achievementVM_.GetAchievementState(a.Id)
        local bState = self.achievementVM_.GetAchievementState(b.Id)
        if aState == bState then
          return a.AchievementLevel < b.AchievementLevel
        else
          return aState < bState
        end
      end)
      self.rightLoopListView_:RefreshListView(achievements, true)
    end
    local achievementId = AchievementDataTableMap.Dates[self.selectAchievementId_] ~= nil and AchievementDataTableMap.Dates[self.selectAchievementId_][1] or nil
    if achievementId then
      local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(achievementId)
      if config then
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_bottom, true)
        local classConfig = self.achievementVM_.GetAchievementInClassConfig(achievementId)
        if classConfig then
          self.uiBinder.lab_title.text = classConfig.ClassName
          self.uiBinder.img_bottom:SetImage(classConfig.ClassPeopleBg)
          self.uiBinder.img_bottom_icon:SetImage(classConfig.ClassBackground)
        end
      end
    end
  else
    self.rightLoopListView_:RefreshListView({})
  end
end

return Achievement_detail_windowView
