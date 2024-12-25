local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_Illustrate_subView = class("Fishing_Illustrate_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local fishingillustratedItem = require("ui.component.fishing.fishing_illustrated_loop_item")
local fishingRed = require("rednode.fishing_red")

function Fishing_Illustrate_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fishing_illustrated_sub", "fishing/fishing_illustrated_sub", UI.ECacheLv.None)
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
end

function Fishing_Illustrate_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.selectArea_ = self.viewData.areaId
  self.initTypeTab_ = false
  self.parentView_ = self.viewData.parentView
  self.fishTypeTabList_ = {}
  self:initLoopGridView()
  self:initFishTypeTab()
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingDataChange, self.refreshUI, self)
end

function Fishing_Illustrate_subView:OnDeActive()
  for _, v in pairs(self.fishTypeTabList_) do
    v.tog_item.group = nil
  end
  self.fishTypeTabList_ = {}
  self:unInitLoopGridView()
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishingDataChange, self.refreshUI, self)
end

function Fishing_Illustrate_subView:OnRefresh()
  self:refreshUI()
end

function Fishing_Illustrate_subView:refreshUI()
  if not self.initTypeTab_ then
    return
  end
  local isKun_ = self.selectFishType_ == 99
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_kun, isKun_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, not isKun_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_panel, not isKun_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_panel_kun, isKun_)
  if not isKun_ then
    self:refreshLoopGridView()
    for k, v in pairs(self.fishTypeTabList_) do
      fishingRed.LoadIllustratedTypeRedItem(self.selectArea_, k, self, v.Trans)
    end
  else
    local fishCfg_ = Z.TableMgr.GetTable("FishingTableMgr").GetRow(Z.Global.FishingWhaleId)
    if fishCfg_ then
      self.uiBinder.lab_kun_des.text = fishCfg_.LockedWords
      self.uiBinder.lab_kuncontent.text = fishCfg_.SpecialWords
    end
  end
end

function Fishing_Illustrate_subView:initLoopGridView()
  self.loopGridView_ = loopGridView.new(self, self.uiBinder.loop_item, fishingillustratedItem, "fishing_illustrated_item_tpl")
  self.loopGridView_:Init({})
end

function Fishing_Illustrate_subView:refreshLoopGridView()
  local dataList_ = {}
  local fishingAreaCfg_ = Z.TableMgr.GetTable("FishingAreaTableMgr").GetRow(self.selectArea_)
  for _, v in ipairs(fishingAreaCfg_.FishGroup) do
    local fishCfg_ = self.fishingData_.FishRecordDict[v].FishCfg
    if self.selectFishType_ and fishCfg_.Type == self.selectFishType_ then
      table.insert(dataList_, v)
    end
  end
  table.sort(dataList_, function(a, b)
    local cfgA_ = self.fishingData_.FishRecordDict[a].FishCfg
    local cfgB_ = self.fishingData_.FishRecordDict[b].FishCfg
    if cfgA_.Sort == cfgB_.Sort then
      return a < b
    else
      return cfgA_.Sort > cfgB_.Sort
    end
  end)
  local startSelect_ = 1
  for k, v in ipairs(dataList_) do
    if self.selectFish_ and v == self.selectFish_ then
      startSelect_ = k
      break
    end
  end
  self.loopGridView_:RefreshListView(dataList_)
  self.loopGridView_:ClearAllSelect()
  self.loopGridView_:SetSelected(startSelect_)
end

function Fishing_Illustrate_subView:unInitLoopGridView()
  self.loopGridView_:UnInit()
  self.loopGridView_ = nil
end

function Fishing_Illustrate_subView:refreshRightUI()
  local fishCfg_ = self.fishingData_.FishRecordDict[self.selectFish_].FishCfg
  local typeCfg_ = Z.TableMgr.GetTable("FishingTypeTableMgr").GetRow(fishCfg_.Type)
  local isUnLock_ = self.fishingData_.FishRecordDict[self.selectFish_].FishRecord ~= nil
  local showUnLock_ = isUnLock_ and self.fishingData_.FishRecordDict[self.selectFish_].FishRecord.firstFlag
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, showUnLock_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_mark, showUnLock_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_shadow, not showUnLock_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_size, showUnLock_ and typeCfg_.Infoshow == 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unit, showUnLock_ and typeCfg_.Infoshow == 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_rarity, showUnLock_)
  self.uiBinder.node_star.Ref.UIComp:SetVisible(showUnLock_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name, showUnLock_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_range, showUnLock_ and typeCfg_.Infoshow == 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, not showUnLock_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_jump_tips, not showUnLock_)
  self.uiBinder.fishing_study_item_tpl.Ref.UIComp:SetVisible(showUnLock_ and typeCfg_.Infoshow == 1)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local canUseChat = gotoFuncVM.CheckFuncCanUse(E.FunctionID.MainChat, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, showUnLock_ and canUseChat)
  if showUnLock_ then
    self.uiBinder.rimg_icon:SetImage(fishCfg_.FishingIcon)
    self.uiBinder.rimg_mark:SetImage(fishCfg_.FishingIcon)
    self.uiBinder.lab_name.text = fishCfg_.Name
    local maxSize_ = self.fishingData_.FishRecordDict[self.selectFish_].MaxSize
    local minSize_ = self.fishingData_.FishRecordDict[self.selectFish_].MinSize
    local size_ = self.fishingData_.FishRecordDict[self.selectFish_].FishRecord.size / 100
    local showRange_ = 0 < maxSize_ or 0 < minSize_
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_range, showRange_ and typeCfg_.Infoshow == 1)
    if showRange_ then
      self.uiBinder.lab_range.text = string.format(Lang("FishingSettlementLengthUnit"), minSize_) .. "-" .. string.format(Lang("FishingSettlementLengthUnit"), maxSize_)
    end
    self.uiBinder.lab_size.text = size_
    if fishCfg_.Quality == E.FishingQuality.Normal then
      self.uiBinder.lab_rarity.text = Lang("FishingIllustratedNormal")
    elseif fishCfg_.Quality == E.FishingQuality.Rare then
      self.uiBinder.lab_rarity.text = Lang("FishingIllustratedRare")
    elseif fishCfg_.Quality == E.FishingQuality.Myth then
      self.uiBinder.lab_rarity.text = Lang("FishingIllustratedMyth")
    end
    self.uiBinder.img_quality:SetImage(self.fishingData_.IllQualityPathDict_[fishCfg_.Quality])
    self:updateStarUI(typeCfg_.Infoshow == 1, self.fishingData_.FishRecordDict[self.selectFish_].Star)
    self:updateStudyUI(fishCfg_)
    self.uiBinder.btn_share:RemoveAllListeners()
    self:AddClick(self.uiBinder.btn_share, function()
      self.fishingVM_.ShareIllustrateToChat(self.selectFish_, size_)
    end)
  else
    self.uiBinder.rimg_shadow:SetImage(fishCfg_.FishingIcon)
    self.uiBinder.lab_jump_tips.text = fishCfg_.LockedWords
    self.uiBinder.btn_jump:RemoveAllListeners()
    self:AddClick(self.uiBinder.btn_jump, function()
      self.quickJumpVM_.DoJumpByConfigParam(fishCfg_.QuickJumpType, fishCfg_.QuickJumpParam)
    end)
  end
end

function Fishing_Illustrate_subView:updateStarUI(show, star)
  self.uiBinder.node_star.Ref.UIComp:SetVisible(show)
  if show then
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_01, 1 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_02, 2 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_03, 3 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_04, 4 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_05, 5 <= star)
  end
end

function Fishing_Illustrate_subView:updateStudyUI(cfg)
  self.uiBinder.fishing_study_item_tpl.rimg_icon:SetImage(cfg.FishingIcon)
  self.uiBinder.fishing_study_item_tpl.img_ing.fillAmount = self.fishingData_.FishRecordDict[self.selectFish_].ResearchProgress[1]
  self.uiBinder.fishing_study_item_tpl.lab_research.text = self.fishingData_.FishRecordDict[self.selectFish_].ResearchLevel
  self.uiBinder.fishing_study_item_tpl.btn_self:RemoveAllListeners()
  self:AddClick(self.uiBinder.fishing_study_item_tpl.btn_self, function()
    self.parentView_:SwitchTab(E.FishingMainFunc.Research, cfg.FishId)
  end)
end

function Fishing_Illustrate_subView:OnClickIllustratedItem(fishId)
  self.selectFish_ = fishId
  self:refreshRightUI()
end

function Fishing_Illustrate_subView:OnClickIllustratedItemUnLock(fishId)
  Z.CoroUtil.create_coro_xpcall(function()
    self.fishingVM_.UpdateFishFirstUnLockFlag(fishId, self.cancelSource:CreateToken())
    self:refreshRightUI()
    self.parentView_:RefreshAreaTab()
  end)()
end

function Fishing_Illustrate_subView:initFishTypeTab()
  Z.CoroUtil.create_coro_xpcall(function()
    local path_ = self:GetPrefabCacheDataNew(self.uiBinder.pcb, "fishTypeTab")
    local typeKeys_ = {}
    local firstTab
    local fishingAreaCfg_ = Z.TableMgr.GetTable("FishingAreaTableMgr").GetRow(self.selectArea_)
    local fishTypeCfgs_ = Z.TableMgr.GetTable("FishingTypeTableMgr").GetDatas()
    local types_ = {}
    for _, v in pairs(fishingAreaCfg_.FishGroup) do
      local fishCfg_ = self.fishingData_.FishRecordDict[v].FishCfg
      if types_[fishCfg_.Type] == nil then
        types_[fishCfg_.Type] = fishCfg_.Type
      end
    end
    for k, _ in pairs(types_) do
      table.insert(typeKeys_, k)
    end
    table.sort(typeKeys_)
    for index, type in pairs(typeKeys_) do
      local v = fishTypeCfgs_[type]
      local tabBinder_ = self:AsyncLoadUiUnit(path_, "fishTypeTab_" .. v.Type, self.uiBinder.layout_trans)
      tabBinder_.tog_item.isOn = false
      tabBinder_.tog_item.group = self.uiBinder.layout_group
      tabBinder_.lab_name_1.text = v.Title
      tabBinder_.lab_name_2.text = v.Title
      tabBinder_.img_icon:SetImage(v.FishingTypeIcon)
      tabBinder_.img_icon2:SetImage(v.FishingTypeIcon)
      tabBinder_.tog_item:AddListener(function(ison)
        if ison then
          self.selectFishType_ = v.Type
          self:refreshUI()
        end
      end)
      self.fishTypeTabList_[v.Type] = tabBinder_
      if index == 1 then
        firstTab = tabBinder_.tog_item
      end
    end
    self.initTypeTab_ = true
    if firstTab then
      firstTab.isOn = true
    end
  end)()
end

return Fishing_Illustrate_subView
