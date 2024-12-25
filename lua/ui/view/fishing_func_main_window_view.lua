local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_func_main_windowView = class("Fishing_func_main_windowView", super)

function Fishing_func_main_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_func_main_window")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.funcViewDict_ = {
    [E.FishingMainFunc.Illustrated] = nil,
    [E.FishingMainFunc.Research] = nil,
    [E.FishingMainFunc.Shop] = nil,
    [E.FishingMainFunc.RankList] = nil,
    [E.FishingMainFunc.Archives] = nil
  }
  self.funcIconPathDict_ = {
    [E.FishingMainFunc.Illustrated] = "ui/atlas/item/c_tab_icon/com_icon_tab_176",
    [E.FishingMainFunc.Research] = "ui/atlas/item/c_tab_icon/com_icon_tab_175",
    [E.FishingMainFunc.Shop] = "ui/atlas/item/c_tab_icon/com_icon_tab_178",
    [E.FishingMainFunc.RankList] = "ui/atlas/item/c_tab_icon/com_icon_tab_177",
    [E.FishingMainFunc.Archives] = "ui/atlas/item/c_tab_icon/com_icon_tab_177"
  }
  self.handlersFunc_ = {
    [E.FishingMainFunc.Illustrated] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.com_tab_codex.anim_tog, cancelSource)
    end,
    [E.FishingMainFunc.Research] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.cont_tab_study.anim_tog, cancelSource)
    end,
    [E.FishingMainFunc.Shop] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.cont_tab_shop.anim_tog, cancelSource)
    end,
    [E.FishingMainFunc.RankList] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.com_tab_ranking.anim_tog, cancelSource)
    end,
    [E.FishingMainFunc.Archives] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.com_tab_archives.anim_tog, cancelSource)
    end
  }
  self.areaTabList_ = {}
end

function Fishing_func_main_windowView:OnActive()
  self.initAreaTab_ = false
  self.curFunc_ = 0
  self.fishingArea_ = 0
  self.showAreaSelect_ = false
  self.startFunc_ = E.FishingMainFunc.Illustrated
  if self.viewData and self.viewData.startFunc_ then
    self.startFunc_ = self.viewData.startFunc_
  end
  self.funcTabDict_ = {
    [E.FishingMainFunc.Illustrated] = self.uiBinder.com_tab_codex,
    [E.FishingMainFunc.Research] = self.uiBinder.cont_tab_study,
    [E.FishingMainFunc.Shop] = self.uiBinder.cont_tab_shop,
    [E.FishingMainFunc.RankList] = self.uiBinder.com_tab_ranking,
    [E.FishingMainFunc.Archives] = self.uiBinder.com_tab_archives
  }
  self:bindClickEvent()
  self:initAreaSelectUI()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
end

function Fishing_func_main_windowView:bindClickEvent()
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onAskBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.fishingVM_.CloseMainFuncWindow()
  end)
  self.uiBinder.com_tab_codex.tog_tab_select:AddListener(function(ison)
    if ison then
      self:setFunc(E.FishingMainFunc.Illustrated)
    end
  end)
  self.uiBinder.cont_tab_study.tog_tab_select:AddListener(function(ison)
    if ison then
      self:setFunc(E.FishingMainFunc.Research)
    end
  end)
  self.uiBinder.cont_tab_shop.tog_tab_select:AddListener(function(ison)
    if ison then
      self:setFunc(E.FishingMainFunc.Shop)
    end
  end)
  self.uiBinder.com_tab_ranking.tog_tab_select:AddListener(function(ison)
    if ison then
      self:setFunc(E.FishingMainFunc.RankList)
    end
  end)
  self.uiBinder.com_tab_archives.tog_tab_select:AddListener(function(ison)
    if ison then
      self:setFunc(E.FishingMainFunc.Archives)
    end
  end)
  self:AddClick(self.uiBinder.node_schedule.btn_level, function()
    self.fishingVM_.OpenFishingLevelPopup()
  end)
end

function Fishing_func_main_windowView:setFunc(func, force)
  if func == self.curFunc_ and not force then
    return
  end
  local curShowView_ = self.funcViewDict_[self.curFunc_]
  if curShowView_ then
    curShowView_:DeActive()
  end
  local isSame = self.curFunc_ == func
  self.curFunc_ = func
  if not isSame then
    self:onTogSelectedAnim(self.curFunc_)
  end
  self.showAreaSelect_ = func ~= E.FishingMainFunc.Shop and func ~= E.FishingMainFunc.Archives
  self:refreshUI()
end

function Fishing_func_main_windowView:onTogSelectedAnim(containerType)
  local cancelSource = self.cancelSource:CreateToken()
  local handler = self.handlersFunc_[containerType]
  if handler then
    handler(cancelSource)
  end
end

function Fishing_func_main_windowView:refreshUI()
  if not self.initAreaTab_ then
    return
  end
  self:setTitle()
  self.uiBinder.Ref:SetVisible(self.uiBinder.togs_tab2, self.showAreaSelect_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_adorn, self.curFunc_ ~= E.FishingMainFunc.RankList)
  local curShowView_ = self.funcViewDict_[self.curFunc_]
  if curShowView_ == nil then
    local luaCode = self.fishingData_.MainFuncLuaViewPath[self.curFunc_]
    if luaCode == nil then
      return
    end
    curShowView_ = require(luaCode).new(self)
    self.funcViewDict_[self.curFunc_] = curShowView_
  end
  local viewData
  if self.curFunc_ == E.FishingMainFunc.Archives then
    viewData = {
      DataList = self.fishingData_.PeripheralData.ArchivesData,
      ShowInChat = false,
      CharId = Z.ContainerMgr.CharSerialize.charId,
      titleData = self.fishingData_.GetArchivesTitleData()
    }
  else
    viewData = {
      areaId = self.fishingArea_,
      parentView = self,
      fishParam = self.fishParam_
    }
  end
  curShowView_:Active(viewData, self.uiBinder.func_view_holder)
  self.uiBinder.img_icon:SetImage(self.funcIconPathDict_[self.curFunc_])
  self:RefreshAreaTab()
  self.uiBinder.node_schedule.lab_lv.text = self.fishingData_.FishingLevel
  self.uiBinder.node_schedule.img_progress.fillAmount = self.fishingData_.PeripheralData.FishingLevelProgress[1]
  self.uiBinder.node_schedule.lab_exp.text = self.fishingData_.PeripheralData.FishingLevelProgress[2] .. "/" .. self.fishingData_.PeripheralData.FishingLevelProgress[3]
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FishingShopLevel, self, self.uiBinder.node_schedule.red_holder)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FishingIllustratedTab, self, self.uiBinder.com_tab_codex.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FishingShopTab, self, self.uiBinder.cont_tab_shop.Trans)
end

function Fishing_func_main_windowView:RefreshAreaTab()
  for areaId, tab in pairs(self.areaTabList_) do
    tab.Ref:SetVisible(tab.img_tips_off, false)
    tab.Ref:SetVisible(tab.img_tips_on, false)
    if self.curFunc_ == E.FishingMainFunc.Illustrated then
      local areaCfg_ = Z.TableMgr.GetTable("FishingAreaTableMgr").GetRow(areaId)
      for _, v in pairs(areaCfg_.FishGroup) do
        local record_ = self.fishingData_.FishRecordDict[v].FishRecord
        if record_ and not record_.firstFlag then
          tab.Ref:SetVisible(tab.img_tips_off, true)
          tab.Ref:SetVisible(tab.img_tips_on, true)
          break
        end
      end
    end
  end
end

function Fishing_func_main_windowView:setTitle()
  if self.curFunc_ ~= 0 then
    self.commonVM_.SetLabText(self.uiBinder.lab_title, {
      E.FunctionID.Fishing,
      self.curFunc_
    })
  end
end

function Fishing_func_main_windowView:initAreaSelectUI()
  Z.CoroUtil.create_coro_xpcall(function()
    local fishAreaTableRows = Z.TableMgr.GetTable("FishingAreaTableMgr").GetDatas()
    local areaPath_ = self:GetPrefabCacheDataNew(self.uiBinder.pcb, "fishing_areaselect_tpl")
    local startTog_
    local areaKeys_ = {}
    for k, _ in pairs(fishAreaTableRows) do
      table.insert(areaKeys_, k)
    end
    table.sort(areaKeys_)
    for index, key in pairs(areaKeys_) do
      local area = fishAreaTableRows[key]
      local areaTab_ = self:AsyncLoadUiUnit(areaPath_, "areaTab_" .. area.SceneObjectId, self.uiBinder.layout_tab)
      areaTab_.lab_name_off.text = area.AreaName
      areaTab_.lab_name_on.text = area.AreaName
      areaTab_.tog_item.isOn = false
      areaTab_.tog_item.group = self.uiBinder.togs_tab2
      areaTab_.tog_item:AddListener(function(ison)
        if ison then
          self:setFishingArea(area.SceneObjectId)
        end
      end)
      if index == 1 then
        startTog_ = areaTab_.tog_item
      end
      self.areaTabList_[area.SceneObjectId] = areaTab_
    end
    self.initAreaTab_ = true
    if startTog_ then
      startTog_.isOn = true
    end
  end)()
end

function Fishing_func_main_windowView:setFishingArea(area)
  self.fishingArea_ = area
  self:setFunc(self.curFunc_, true)
end

function Fishing_func_main_windowView:OnDeActive()
  for _, v in pairs(self.areaTabList_) do
    v.tog_item.group = nil
  end
  self.handlersFunc_ = {}
  local curShowView_ = self.funcViewDict_[self.curFunc_]
  if curShowView_ then
    curShowView_:DeActive()
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Fishing_func_main_windowView:OnRefresh()
  self:refreshFuncTab()
end

function Fishing_func_main_windowView:onAskBtnClick()
  local helpsysVM = Z.VMMgr.GetVM("helpsys")
  if self.curFunc_ == E.FishingMainFunc.Illustrated then
    helpsysVM.CheckAndShowView(300001)
  elseif self.curFunc_ == E.FishingMainFunc.Research then
    helpsysVM.CheckAndShowView(300002)
  elseif self.curFunc_ == E.FishingMainFunc.Shop then
    helpsysVM.CheckAndShowView(300003)
  elseif self.curFunc_ == E.FishingMainFunc.RankList then
    helpsysVM.CheckAndShowView(300004)
  elseif self.curFunc_ == E.FishingMainFunc.Archives then
    helpsysVM.CheckAndShowView(300005)
  else
    logError("\230\156\170\231\159\165\231\177\187\229\136\171, func: " .. self.curFunc_)
  end
end

function Fishing_func_main_windowView:refreshFuncTab()
  local group_
  for _, v in pairs(self.funcTabDict_) do
    if group_ == nil then
      group_ = v.tog_tab_select.group
    end
    v.tog_tab_select.group = nil
    v.tog_tab_select:SetIsOnWithoutCallBack(false)
  end
  self.funcTabDict_[self.startFunc_].tog_tab_select.isOn = true
  for _, v in pairs(self.funcTabDict_) do
    v.tog_tab_select.group = group_
  end
end

function Fishing_func_main_windowView:SwitchTab(tab, fishId)
  self.fishParam_ = fishId
  self.funcTabDict_[tab].tog_tab_select.isOn = true
  self.commonVM_.CommonPlayTogAnim(self.funcTabDict_[tab].anim_tog, self.cancelSource:CreateToken())
  self.fishParam_ = nil
end

function Fishing_func_main_windowView:GetCacheData()
  local viewData = self.viewData or {}
  viewData.startFunc_ = self.curFunc_
  return viewData
end

return Fishing_func_main_windowView
