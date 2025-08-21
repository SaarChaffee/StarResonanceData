local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_windowView = class("Gasha_windowView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local gashaActItem = require("ui.component.gasha.gasha_activity_loop_item")
local gashaBannerTpl = require("ui.component.gasha.gasha_banner_tpl")
local currency_item_list = require("ui.component.currency.currency_item_list")
local gashaBannerMap = {}
local windowOpenEffect = "ui/uieffect/prefab/ui_sfx_niudan_background_001"

function Gasha_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  
  function self.onGashChangeHandler_(container, dirtyKeys)
  end
  
  function self.onItemPackageChangeHandler_(container, dirtyKeys)
    self:refreshAttempt()
    self:refreshCost()
  end
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
  
  self.gashaData_ = Z.DataMgr.Get("gasha_data")
end

function Gasha_windowView:OnActive()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initComp()
  self.uiBinder.ui_depth:AddChildDepth(self.uiBinder.effect)
  self.uiBinder.effect:CreatEFFGO(windowOpenEffect, Vector3.zero)
  self.uiBinder.effect:SetEffectGoVisible(true)
  self.uiBinder.ui_depth:AddChildDepth(self.uiBinder.effect_btn_one)
  self.uiBinder.ui_depth:AddChildDepth(self.uiBinder.effect_btn_ten)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onUIClose, self)
  Z.ContainerMgr.CharSerialize.itemPackage.packages[1].Watcher:RegWatcher(self.onItemPackageChangeHandler_)
  Z.ContainerMgr.CharSerialize.gashaData.Watcher:RegWatcher(self.onGashChangeHandler_)
  self:onAddListener()
  self.toggleScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_toggle, gashaActItem, "gasha_tab_tpl")
  local d = {}
  self.toggleScrollRect_:Init(d)
  self:preLoadResultView()
end

function Gasha_windowView:initComp()
  self.btn_draw_one_ = self.uiBinder.btn_draw_one
  self.btn_draw_ten_ = self.uiBinder.btn_draw_ten
  self.btn_record_ = self.uiBinder.btn_record
  self.btn_detail_ = self.uiBinder.btn_detail
  self.lab_today_attempt_ = self.uiBinder.lab_today_attempt
  self.rimg_drawone_consumable_ = self.uiBinder.rimg_drawone_consumable
  self.rimg_drawten_consumable_ = self.uiBinder.rimg_drawten_consumable
  self.lab_drawone_count_ = self.uiBinder.lab_drawone_count
  self.lab_drawten_count_ = self.uiBinder.lab_drawten_count
  self.btn_close_ = self.uiBinder.btn_close
  self.lab_title_ = self.uiBinder.lab_title
  self.btn_help_ = self.uiBinder.btn_help
  self.lab_residueTimeY_ = self.uiBinder.lab_residueTimeX
  self.lab_residueTimeX_ = self.uiBinder.lab_residueTimeY
  self.btn_goto_shop_ = self.uiBinder.btn_goto_shop
  self.lab_goto_shop_ = self.uiBinder.lab_goto_shop
  self.img_goto_shop_ = self.uiBinder.img_shop_icon
  self.lab_time = self.uiBinder.lab_time
  self.bg_ = self.uiBinder.rimg_bg
  self.togUseBindItem_ = self.uiBinder.tog_use
end

function Gasha_windowView:refreshToggles()
  local type = 0
  if self.viewData then
    type = self.viewData.type
  end
  self.showOpenGashas_ = self.gashaVm_.GetShowOpenGashas(type)
  self.toggleScrollRect_:RefreshListView(self.showOpenGashas_)
  if self.gashaId_ == nil and self.viewData ~= nil and self.viewData.gashaId ~= nil then
    self.gashaId_ = self.viewData.gashaId
  elseif self.showOpenGashas_ and 0 < #self.showOpenGashas_ then
    self.gashaId_ = self.showOpenGashas_[1].Id
  end
  local index = 1
  for k, v in pairs(self.showOpenGashas_) do
    if v.Id == self.gashaId_ then
      index = k
    end
  end
  self.toggleScrollRect_:SetSelected(index)
end

function Gasha_windowView:onAddListener()
  self:AddAsyncClick(self.btn_draw_one_, function()
    self:draw(1, self.gashaPoolTableRow_.Cost[1], self.gashaPoolTableRow_.Cost[2])
  end)
  self:AddAsyncClick(self.btn_draw_ten_, function()
    self:draw(10, self.gashaPoolTableRow_.CostSecond[1], self.gashaPoolTableRow_.CostSecond[2])
  end)
  self:AddClick(self.btn_record_, function()
    self.gashaVm_.OpenGashaRecordView(self.gashaId_, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.btn_detail_, function()
    self.gashaVm_.OpenGashaDetailView(self.gashaId_)
  end)
  self:AddClick(self.btn_close_, function()
    self.gashaVm_.CloseGashaView(self.gashaId_)
  end)
  local helpIds = {
    [0] = 30029,
    [1] = 30035
  }
  self:AddClick(self.btn_help_, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    local helpId = helpIds[self.gashaPoolTableRow_.openType] or helpIds[0]
    helpsysVM.OpenFullScreenTipsView(helpId)
  end)
  self:AddClick(self.btn_goto_shop_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(self.gashaPoolTableRow_.ShopFunc)
  end)
end

function Gasha_windowView:OnDeActive()
  Z.TipsVM.CloseItemTipsView(self.tipsId_)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if Z.ContainerMgr.CharSerialize ~= nil and Z.ContainerMgr.CharSerialize.gashaData ~= nil and Z.ContainerMgr.CharSerialize.gashaData.Watcher ~= nil then
    Z.ContainerMgr.CharSerialize.gashaData.Watcher:UnregWatcher(self.onGashChangeHandler_)
  end
  if Z.ContainerMgr.CharSerialize ~= nil and Z.ContainerMgr.CharSerialize.itemPackage ~= nil and Z.ContainerMgr.CharSerialize.itemPackage.packages[1] ~= nil then
    Z.ContainerMgr.CharSerialize.itemPackage.packages[1].Watcher:UnregWatcher(self.onItemPackageChangeHandler_)
  end
  self.toggleScrollRect_:ClearAllSelect()
  self.toggleScrollRect_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.onUIClose, self)
  for id, banner in pairs(gashaBannerMap) do
    banner:Dispose()
  end
  gashaBannerMap = {}
  self.uiBinder.effect:ReleseEffGo()
  self.uiBinder.ui_depth:RemoveChildDepth(self.uiBinder.effect)
  self.uiBinder.ui_depth:RemoveChildDepth(self.uiBinder.effect_btn_one)
  self.uiBinder.ui_depth:RemoveChildDepth(self.uiBinder.effect_btn_ten)
  self:ResetIgnore()
  self.gashaData_:SetIsDrawing(false)
  self:releaseResultView()
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function Gasha_windowView:onUIClose(viewConfigKey)
  if viewConfigKey and viewConfigKey == "gasha_result_window" then
    self:refreshResidue()
  end
  if viewConfigKey and viewConfigKey == "gasha_video_window" then
    self.curBanner:OnVideoWindowClose()
  end
end

function Gasha_windowView:OnRefresh()
  self:refreshToggles()
end

function Gasha_windowView:refreshUI()
  self:refreshShopBtn()
  self:refreshAttempt()
  self:refreshResidue()
  self:refreshCost()
  self:refreshTimer()
  self:refreshBG()
  self:refreshBanner()
end

function Gasha_windowView:refreshBG()
  local faceData = Z.DataMgr.Get("face_data")
  local playerGender = faceData:GetPlayerGender()
  self.bg_:SetImage(self.gashaPoolTableRow_.Banner[playerGender][1])
end

function Gasha_windowView:refreshShopBtn()
  if self.gashaPoolTableRow_.ShopFunc == 0 then
    self.uiBinder.Ref:SetVisible(self.btn_goto_shop_, false)
    return
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isFuncOn = gotoFuncVM.CheckFuncCanUse(self.gashaPoolTableRow_.ShopFunc, true)
  if not isFuncOn then
    self.uiBinder.Ref:SetVisible(self.btn_goto_shop_, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.btn_goto_shop_, true)
  local functionTableMgr = Z.TableMgr.GetTable("FunctionTableMgr")
  local functionTableRow = functionTableMgr.GetRow(self.gashaPoolTableRow_.ShopFunc)
  if functionTableRow ~= nil then
    if self.gashaPoolTableRow_.ShopFunc == E.FunctionID.TokenShop then
      self.lab_goto_shop_.text = Lang("VipShopShortName")
    else
      self.lab_goto_shop_.text = functionTableRow.Name
    end
  end
  self.img_goto_shop_:SetImage(self.gashaPoolTableRow_.ShopIcon)
end

function Gasha_windowView:refreshCost()
  self.currencyItemList_:Init(self.uiBinder.currency_info, self.gashaPoolTableRow_.Currency)
  local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", self.gashaPoolTableRow_.Cost[1])
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemTableRow ~= nil then
    self.rimg_drawone_consumable_:SetImage(itemsVM.GetItemIcon(self.gashaPoolTableRow_.Cost[1]))
  end
  itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", self.gashaPoolTableRow_.CostSecond[1])
  if itemTableRow ~= nil then
    self.rimg_drawten_consumable_:SetImage(itemsVM.GetItemIcon(self.gashaPoolTableRow_.CostSecond[1]))
  end
  self:setDrawBtnLabColor(self.lab_drawone_count_, 1, self.gashaPoolTableRow_.Cost[2])
  self:setDrawBtnLabColor(self.lab_drawten_count_, 10, self.gashaPoolTableRow_.CostSecond[2])
end

function Gasha_windowView:refreshTimer()
  local timerId = self.gashaPoolTableRow_.TimerId
  local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(timerId)
  if timerConfigItem == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_time, false)
    return
  end
  if timerConfigItem.EndTime == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_time, false)
    return
  end
  local time = Z.TimeTools.GetLeftTimeByTimerId(timerId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_time, true)
  if time <= 0 then
    self.lab_time.text = Lang("ActivityHasEnd")
  end
  self.lab_time.text = Lang("RemainingTime:") .. Z.TimeFormatTools.FormatToDHMS(time)
  if self.timer == nil then
    self.timer = self.timerMgr:StartTimer(function()
      time = time - 1
      if time <= 0 then
        time = Z.TimeTools.GetLeftTimeByTimerId(timerId)
      end
      if time <= 0 then
        self.lab_time.text = Lang("ActivityHasEnd")
        self.timerMgr:StopTimer(self.timer)
        self.timer = nil
        return
      end
      self.lab_time.text = Lang("RemainingTime:") .. Z.TimeFormatTools.FormatToDHMS(time)
    end, 1, -1)
  end
end

function Gasha_windowView:refreshAttempt()
  local todayAttempt = self.gashaVm_.GetGashaTodayAttempt(self.gashaId_)
  local param = {
    val1 = self.gashaPoolTableRow_.Limit - todayAttempt,
    val2 = self.gashaPoolTableRow_.Limit
  }
  self.lab_today_attempt_.text = Lang("DailyRemainingAttempts", param)
end

function Gasha_windowView:refreshResidue()
  local residueTimeX, residueTimeY = self.gashaVm_.GetGashaResidueGuaranteeCount(self.gashaId_)
  self.lab_residueTimeX_.text = Lang("Frequencys", {val = residueTimeX})
  self.lab_residueTimeY_.text = Lang("Frequencys", {val = residueTimeY})
  local funcId = self.gashaPoolTableRow_.FunctionId
  local functionTableRow = Z.TableMgr.GetRow("FunctionTableMgr", funcId)
  if functionTableRow ~= nil then
    self.lab_title_.text = functionTableRow.Name
  end
end

function Gasha_windowView:refreshTogUse()
  self.uiBinder.Ref:SetVisible(self.togUseBindItem_, self.canUseBindGashPool_)
  if not self.canUseBindGashPool_ then
    return
  end
  local costItem = self.gashaPoolTableRow_.Cost[1]
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItem)
  if not itemRow then
    return
  end
  self.uiBinder.lab_tog_title.text = Lang("useBindItemGasha")
  self.togUseBindItem_:RemoveAllListeners()
  local key = string.zconcat("BKL_GASHA_USE_BINDITEM", self.gashaPoolTableRow_.Bind[1])
  local useBindItem = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key, false)
  self.togUseBindItem_.isOn = useBindItem
  self.togUseBindItem_:AddListener(function(isOn)
    self.PlayingVideo = false
    if isOn then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("gashaUseBindingTips"), function()
        local bindGashaPoolRow = self.gashaVm_.GetBindGashaPool(self.gashaPoolTableRow_.Bind[1], true)
        self.gashaPoolTableRow_ = bindGashaPoolRow
        self.gashaId_ = bindGashaPoolRow.Id
        self:refreshUI()
        Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, true)
      end, function()
        self.togUseBindItem_.isOn = false
      end, E.DlgPreferencesType.Day, E.DlgPreferencesKeyType.GashaUseBinding)
    else
      local unBindGashaPoolRow = self.gashaVm_.GetBindGashaPool(self.gashaPoolTableRow_.Bind[1], false)
      self.gashaPoolTableRow_ = unBindGashaPoolRow
      self.gashaId_ = unBindGashaPoolRow.Id
      self:refreshUI()
      Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, false)
    end
  end)
end

function Gasha_windowView:setDrawBtnLabColor(lab, drawCount, itemCount)
  if self.gashaVm_.CheckGashaCost(self.gashaId_, drawCount) then
    lab.text = Z.RichTextHelper.ApplyStyleTag("X" .. itemCount, "GashConsumableEnough")
  else
    lab.text = Z.RichTextHelper.ApplyStyleTag("X" .. itemCount, "GashConsumableNotEnough")
  end
end

function Gasha_windowView:draw(count, itemConfigId, itemCount)
  if self.gashaData_:IsDrawing() then
    return
  end
  local gashaPoolTableRow = Z.TableMgr.GetRow("GashaPoolTableMgr", self.gashaId_)
  if not self.gashaVm_.CheckGashaOpen(gashaPoolTableRow) then
    Z.TipsVM.ShowTips(1382002)
    return
  end
  local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", itemConfigId)
  if itemTableRow == nil then
    return
  end
  local costItemCount = self.itemsVm_.GetItemTotalCount(itemConfigId)
  if itemCount > costItemCount then
    if gashaPoolTableRow.MallItemId and gashaPoolTableRow.MallItemId ~= 0 then
      local mallItemId = gashaPoolTableRow.MallItemId
      local mallItemRow = Z.TableMgr.GetRow("MallItemTableMgr", mallItemId)
      for itemId, count in pairs(mallItemRow.Cost) do
        local buyCostItem = Z.TableMgr.GetRow("ItemTableMgr", itemId)
        local buyCostItemCount = (itemCount - costItemCount) * count
        local buyCostItemTotalCount = self.itemsVm_.GetItemTotalCount(itemId)
        local param = {
          val1 = itemCount - costItemCount,
          str1 = itemTableRow.Name,
          val2 = buyCostItemCount,
          str2 = buyCostItem.Name
        }
        if self.tipsId_ then
          Z.TipsVM.CloseItemTipsView(self.tipsId_)
        end
        Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationBuyGashaCost", param), function()
          if buyCostItemTotalCount < buyCostItemCount then
            Z.TipsVM.ShowTips(100108)
            self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.tips_root, itemId)
            return
          end
          local shopVm = Z.VMMgr.GetVM("shop")
          shopVm.AsyncShopBuyItemList({
            [mallItemId] = {
              buyNum = itemCount - costItemCount
            }
          }, self.cancelSource:CreateToken())
        end)
      end
    else
      if self.tipsId_ then
        Z.TipsVM.CloseItemTipsView(self.tipsId_)
      end
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.tips_root, itemConfigId)
    end
    return
  end
  self:realDraw(count)
end

function Gasha_windowView:realDraw(count)
  self.gashaData_:SetIsDrawing(true)
  Z.CoroUtil.create_coro_xpcall(function()
    local ret = self.gashaVm_.AsyncGashaRequest(self.gashaId_, count, self.cancelSource:CreateToken())
    if ret ~= nil then
      if ret.errCode ~= 0 then
        self:ResetIgnore()
        self.gashaVm_.HandleError(ret.errCode)
      else
        local quality = 1
        for k, v in pairs(ret.items) do
          if quality < v.quality then
            quality = v.quality
          end
        end
        self:showDrawResult(ret.items, ret.replaceItems, quality, #ret.items == 1)
      end
    end
  end)()
end

function Gasha_windowView:OnToggleSelected(Id)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  self.gashaId_ = Id
  self.gashaPoolTableRow_ = Z.TableMgr.GetRow("GashaPoolTableMgr", self.gashaId_)
  if self.gashaPoolTableRow_ == nil then
    return
  end
  local key = string.zconcat("BKL_GASHA_USE_BINDITEM", self.gashaPoolTableRow_.Bind[1])
  local useBindItem = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key, self.gashaPoolTableRow_.Bind[2] == 1)
  local otherGashaPoolRow = self.gashaVm_.GetBindGashaPool(self.gashaPoolTableRow_.Bind[1], useBindItem)
  self.canUseBindGashPool_ = self.gashaVm_.GetBindGashaPool(self.gashaPoolTableRow_.Bind[1], not useBindItem) ~= nil
  if self.canUseBindGashPool_ and useBindItem ~= (self.gashaPoolTableRow_.Bind[2] == 1) then
    self.gashaId_ = otherGashaPoolRow.Id
    self.gashaPoolTableRow_ = otherGashaPoolRow
  end
  self.PlayingVideo = true
  self:refreshTogUse()
  self:refreshUI()
end

function Gasha_windowView:refreshBanner()
  for k, v in pairs(gashaBannerMap) do
    v:SetSelfActive(k == self.gashaId_, self.gashaPoolTableRow_)
    if k == self.gashaId_ then
      self.curBanner = v
    end
  end
  if not table.zcontainsKey(gashaBannerMap, self.gashaId_) then
    Z.CoroUtil.create_coro_xpcall(function()
      local banner = self:AsyncLoadUiUnit(self.gashaPoolTableRow_.Banner[3][1], tostring(self.gashaId_), self.uiBinder.node_banner)
      local bannerTpl = gashaBannerTpl.new(banner, self)
      gashaBannerMap[self.gashaId_] = bannerTpl
      bannerTpl:SetSelfActive(true, self.gashaPoolTableRow_)
      self.curBanner = bannerTpl
    end)()
  end
end

function Gasha_windowView:showDrawResult(items, replaceItems, bestResultQuality, isSingleDraw)
  if items == nil or #items < 1 then
    self:ResetIgnore()
    self.gashaData_:SetIsDrawing(false)
    logError("items is nil")
    return
  end
  Z.UIMgr:FadeIn({
    IsInstant = true,
    TimeOut = 1.5,
    EndCallback = function()
      self:Hide()
    end
  })
  self.gashaVm_.PlayGashaCutScene(self.gashaId_, items, bestResultQuality, isSingleDraw, nil, function()
    self:ResetIgnore()
    self.gashaVm_.OpenGashaResultView(self.gashaId_, items, replaceItems)
    self.gashaData_:SetIsDrawing(false)
  end, function()
  end)
end

function Gasha_windowView:ResetIgnore()
  local itemsData = Z.DataMgr.Get("items_data")
  itemsData:SetIgnoreItemTips(false)
  local personalzoneData = Z.DataMgr.Get("personal_zone_data")
  personalzoneData:SetIgnorePopup(false)
  self.gashaData_:SetIsDrawing(false)
end

function Gasha_windowView:preLoadResultView()
  self.resultGo_ = nil
  local viewConfigKey = "gasha_result_window"
  local prefabPath = Z.UIConfig[viewConfigKey].PrefabPath
  local loadPath = "ui/prefabs/" .. prefabPath
  Z.UIMgr:PreloadObject(loadPath)
end

function Gasha_windowView:releaseResultView()
  local viewConfigKey = "gasha_result_window"
  if self.resultGo_ then
    Z.LuaBridge.ReleaseInstance(self.resultGo_)
    self.resultGo_ = nil
  end
  local viewConfigKey = "gasha_result_window"
  local prefabPath = Z.UIConfig[viewConfigKey].PrefabPath
  local loadPath = "ui/prefabs/" .. prefabPath
  Z.UIMgr:ReleasePreloadObject(loadPath)
end

function Gasha_windowView:OnShow()
  if self.curBanner == nil then
    return
  end
  self.curBanner:RevertBannerVideo()
end

function Gasha_windowView:OnHide()
  if self.curBanner == nil then
    return
  end
  self.curBanner:PauseBannerVideo()
end

return Gasha_windowView
