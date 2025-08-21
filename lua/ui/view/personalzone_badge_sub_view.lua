local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_badge_subView = class("Personalzone_badge_subView", super)
local DEFINE = require("ui.model.personalzone_define")
local loopGridView = require("ui.component.loop_grid_view")
local MedalLoopItem = require("ui.view.personal_zone.medal_main_view.medal_loopitem")

function Personalzone_badge_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_badge_sub", "personalzone/personalzone_badge_sub", UI.ECacheLv.None)
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Personalzone_badge_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.selectMedalClassify_ = 0
  self.selectMedalId_ = 0
  self.medalClassifyToggles_ = {
    self.uiBinder.node_medal_season,
    self.uiBinder.node_medal_collect,
    self.uiBinder.node_medal_history
  }
  self.medalSeasonLoopRect_ = loopGridView.new(self, self.uiBinder.loopscroll_season, MedalLoopItem, "personalzone_medal_01_tpl")
  self.medalHistoryLoopRect_ = loopGridView.new(self, self.uiBinder.loopscroll_history, MedalLoopItem, "personalzone_medal_03_tpl")
  local data = {}
  self.medalSeasonLoopRect_:Init(data)
  self.medalHistoryLoopRect_:Init(data)
  self:AddAsyncClick(self.uiBinder.btn_editor, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isPersonalzoneMedal = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone)
    if not isPersonalzoneMedal then
      return
    end
    self.personalZoneVM_.OpenPersonalZoneEditor(DEFINE.IdCardEditorType.Badge)
  end)
  self:AddAsyncClick(self.uiBinder.btn_use.btn, function()
    if not self.personalZoneVM_.HasMedal(self.selectMedalId_) then
      local config = self.personalZoneData_:GetProfileImageTarget(self.selectMedalId_)
      if config and config.profileImageTargetConfig then
        if config.currentNum >= config.profileImageTargetConfig.Num then
          local success = self.personalZoneVM_.AsyncGetPersonalZoneTargetAward(self.selectMedalId_, self.cancelSource:CreateToken())
          if success then
            self:onSelectItem(self.selectMedalId_)
          end
        elseif config.profileImageTargetConfig.JumpType and config.profileImageTargetConfig.JumpType > 0 then
          local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
          quickJumpVm.DoJumpByConfigParam(config.profileImageTargetConfig.JumpType, config.profileImageTargetConfig.JumpParam)
          return
        end
      end
    end
    self:refreshSecondReddot()
  end)
  for i, toggle in ipairs(self.medalClassifyToggles_) do
    local index = i
    toggle:AddListener(function(isOn)
      if isOn and self.selectMedalClassify_ ~= index then
        self.selectMedalClassify_ = index
        self:refreshMedalClassify()
      end
    end)
  end
  self:refreshSecondReddot()
end

function Personalzone_badge_subView:OnDeActive()
  for _, toggle in pairs(self.medalClassifyToggles_) do
    toggle:RemoveAllListeners()
  end
  self.medalClassifyToggles_ = nil
  self.medalSeasonLoopRect_:UnInit()
  self.medalSeasonLoopRect_ = nil
  self.medalHistoryLoopRect_:UnInit()
  self.medalHistoryLoopRect_ = nil
end

function Personalzone_badge_subView:OnRefresh()
  if self.medalClassifyToggles_[1].isOn then
    self.medalClassifyToggles_[1].isOn = false
  end
  self.medalClassifyToggles_[1].isOn = true
end

function Personalzone_badge_subView:refreshMedalClassify()
  self.uiBinder.Ref:SetVisible(self.uiBinder.loopscroll_season, self.selectMedalClassify_ == E.PersonalZoneMedalShowType.Season)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loopscroll_history, self.selectMedalClassify_ == E.PersonalZoneMedalShowType.History)
  local configs = self.personalZoneVM_.GetMedalConfig(self.selectMedalClassify_, true)
  if configs then
    self.configs_ = {}
    for _, v in ipairs(configs) do
      if v.NotUnlock and v.NotUnlock == 1 then
        local itemsCount = self.itemsVM_.GetItemTotalCount(v.Id)
        if itemsCount and 0 < itemsCount then
          table.insert(self.configs_, v)
        end
      else
        table.insert(self.configs_, v)
      end
    end
    table.sort(self.configs_, function(a, b)
      local hasA = self.personalZoneVM_.HasMedal(a.Id) and 0 or 1
      local hasB = self.personalZoneVM_.HasMedal(b.Id) and 0 or 1
      if hasA == hasB then
        if a.Sort == b.Sort then
          return a.Id < b.Id
        else
          return a.Sort < b.Sort
        end
      else
        return hasA < hasB
      end
    end)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, true)
    self.selectMedalId_ = self.configs_[1].Id
    self.personalZoneData_:RemovePersonalzoneItem(self.configs_[1].Id)
    self.personalZoneVM_.CheckRed()
    self:refreshInfo()
    if self.selectMedalClassify_ == DEFINE.ModelAnimTags.CommonAction then
      self.medalSeasonLoopRect_:RefreshListView(self.configs_)
    elseif self.selectMedalClassify_ == DEFINE.ModelAnimTags.Emote then
      self.medalHistoryLoopRect_:RefreshListView(self.configs_)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
  end
end

function Personalzone_badge_subView:onSelectItem(id)
  self.personalZoneData_:RemovePersonalzoneItem(id)
  self.personalZoneVM_.CheckRed()
  self:refreshSecondReddot()
  self.selectMedalId_ = id
  self:refreshInfo()
  if self.selectMedalClassify_ == DEFINE.ModelAnimTags.CommonAction then
    self.medalSeasonLoopRect_:RefreshListView(self.configs_)
  elseif self.selectMedalClassify_ == DEFINE.ModelAnimTags.Emote then
    self.medalHistoryLoopRect_:RefreshListView(self.configs_)
  end
end

function Personalzone_badge_subView:refreshInfo()
  local config = Z.TableMgr.GetTable("MedalTableMgr").GetRow(self.selectMedalId_)
  if not config then
    logError("MedalTable\230\156\137\232\191\153\228\184\170\233\133\141\231\189\174\229\144\151\239\188\159{0}", self.selectMedalId_)
    return
  end
  local targetConfig = self.personalZoneData_:GetProfileImageTarget(self.selectMedalId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon01, config.Type == E.PersonalZoneMedalShowType.Season)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon03, config.Type == E.PersonalZoneMedalShowType.History)
  self.uiBinder.img_icon01:SetImage(config.Image)
  self.uiBinder.img_icon03:SetImage(config.Image)
  self.uiBinder.lab_title.text = config.Name
  if self.personalZoneVM_.HasMedal(self.selectMedalId_) then
    self.uiBinder.lab_time.text = ""
    self.uiBinder.btn_use.Ref.UIComp:SetVisible(false)
  else
    self.uiBinder.btn_use.Ref.UIComp:SetVisible(true)
    self.uiBinder.lab_time.text = ""
    if targetConfig and targetConfig.profileImageTargetConfig then
      if targetConfig.currentNum < targetConfig.profileImageTargetConfig.Num then
        if targetConfig.profileImageTargetConfig.JumpType and targetConfig.profileImageTargetConfig.JumpType > 0 then
          self.uiBinder.btn_use.btn.IsDisabled = false
          self.uiBinder.btn_use.lab_normal.text = Lang("GotoObtain")
        else
          self.uiBinder.btn_use.btn.IsDisabled = true
          self.uiBinder.btn_use.lab_normal.text = Lang("InvestigationSelectNotComplete")
        end
      else
        self.uiBinder.btn_use.btn.IsDisabled = false
        self.uiBinder.btn_use.lab_normal.text = Lang("UnLock")
      end
    else
      self.uiBinder.btn_use.btn.IsDisabled = true
      self.uiBinder.btn_use.lab_normal.text = Lang("InvestigationSelectNotComplete")
    end
  end
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.selectMedalId_)
  if itemConfig then
    self.uiBinder.lab_info.text = itemConfig.Description
  end
  local text = config.UnlockDes
  if targetConfig and targetConfig.profileImageTargetConfig then
    text = Z.Placeholder.Placeholder(targetConfig.profileImageTargetConfig.Describe, {
      val = targetConfig.profileImageTargetConfig.Num
    })
    text = text .. string.format("(%s/%s)", targetConfig.currentNum, targetConfig.profileImageTargetConfig.Num)
  end
  self.uiBinder.lab_get_info.text = text
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.selectMedalId_))
  self:refreshExpireTime()
end

function Personalzone_badge_subView:refreshSecondReddot()
  local red = {}
  local allConfigs = self.personalZoneData_:GetAllMedalConfig()
  for type, configs in pairs(allConfigs) do
    for _, config in pairs(configs) do
      if self.personalZoneVM_.CheckSingleRedDot(config.Id) then
        red[type] = true
      end
    end
  end
  for i = 1, 3 do
    if red[i] then
      self.uiBinder.Ref:SetVisible(self.uiBinder["node_reddot" .. i], true)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder["node_reddot" .. i], false)
    end
  end
end

function Personalzone_badge_subView:refreshExpireTime()
  self.personalZoneVM_.RefreshViewExpireTime(self.selectMedalId_, self.uiBinder, self.uiBinder.lab_expiretime)
end

return Personalzone_badge_subView
