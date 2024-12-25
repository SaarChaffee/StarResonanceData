local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_windowView = class("Gasha_windowView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local gashaActItem = require("ui.component.gasha.gasha_activity_loop_item")
local gashaBannerTpl = require("ui.component.gasha.gasha_banner_tpl")
local gashaBannerMap = {}
local gashaType2Banner = {
  [1] = "ui/prefabs/gasha/gasha_fashion_banner_tpl",
  [2] = "ui/prefabs/gasha/gasha_vehicle_banner_tpl"
}
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
  
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.gashaData_ = Z.DataMgr.Get("gasha_data")
end

function Gasha_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initComp()
  self:RegisterInputActions()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect)
  self.uiBinder.effect:CreatEFFGO(windowOpenEffect, Vector3.zero)
  self.uiBinder.effect:SetEffectGoVisible(true)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_btn_one)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_btn_ten)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onUIClose, self)
  Z.ContainerMgr.CharSerialize.itemPackage.packages[1].Watcher:RegWatcher(self.onItemPackageChangeHandler_)
  Z.ContainerMgr.CharSerialize.gashaData.Watcher:RegWatcher(self.onGashChangeHandler_)
  self:onAddListener()
  self.toggleScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_toggle, gashaActItem, "gasha_tab_tpl")
  local d = {}
  self.toggleScrollRect_:Init(d)
  self:refreshToggles()
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
  self.currencyParent_ = self.uiBinder.layout_content_currency
  self.bg_ = self.uiBinder.rimg_bg
end

function Gasha_windowView:refreshToggles()
  if not self.openGashas_ then
    self.openGashas_ = self.gashaVm_.GetOpenGashas()
  end
  self.toggleScrollRect_:RefreshListView(self.openGashas_)
  if self.gashaId_ == nil and self.viewData ~= nil and self.viewData.gashaId ~= nil then
    self.gashaId_ = self.viewData.gashaId
  end
  local index = 1
  for k, v in pairs(self.openGashas_) do
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
  self:AddClick(self.btn_help_, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.OpenFullScreenTipsView(30029)
  end)
  self:AddClick(self.btn_goto_shop_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(self.gashaPoolTableRow_.ShopFunc)
  end)
end

function Gasha_windowView:OnDeActive()
  self:UnRegisterInputActions()
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
  gashaBannerMap = {}
  self.currencyVm_.CloseCurrencyView(self)
  self.uiBinder.effect:ReleseEffGo()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_btn_one)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_btn_ten)
  self:ResetIgnore()
  self.gashaData_:SetIsDrawing(false)
  self:releaseResultView()
end

function Gasha_windowView:onUIClose(viewConfigKey)
  if viewConfigKey and viewConfigKey == "gasha_result_window" then
    self:refreshResidue()
  end
end

function Gasha_windowView:OnRefresh()
  if self.gashaId_ == nil then
    if self.viewData == nil then
      self.openGashas_ = self.gashaVm_.GetOpenGashas()
      if self.openGashas_ and #self.openGashas_ > 0 then
        self.gashaId_ = self.openGashas_[1].Id
      end
    else
      self.gashaId_ = self.viewData.gashaId
    end
  end
  self.gashaPoolTableRow_ = Z.TableMgr.GetRow("GashaPoolTableMgr", self.gashaId_)
  if self.gashaPoolTableRow_ == nil then
    return
  end
  self:refreshUI()
end

function Gasha_windowView:refreshUI()
  self:refreshShopBtn()
  self:refreshAttempt()
  self:refreshResidue()
  self:refreshCost()
  self:refreshTimer()
  self:refreshBG()
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
  self.uiBinder.Ref:SetVisible(self.btn_goto_shop_, true)
  local functionTableMgr = Z.TableMgr.GetTable("FunctionTableMgr")
  local functionTableRow = functionTableMgr.GetRow(self.gashaPoolTableRow_.ShopFunc)
  if functionTableRow ~= nil then
    self.lab_goto_shop_.text = functionTableRow.Name
  end
  self.img_goto_shop_:SetImage(self.gashaPoolTableRow_.ShopIcon)
end

function Gasha_windowView:refreshCost()
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
  self.currencyVm_.OpenCurrencyView({
    self.gashaPoolTableRow_.Cost[1]
  }, self.currencyParent_, self)
end

function Gasha_windowView:refreshTimer()
  local timerId = self.gashaPoolTableRow_.TimerId
  local timerConfig = Z.TableMgr.GetTable("TimerTableMgr").GetRow(timerId)
  if timerConfig == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_time, false)
    return
  end
  if timerConfig.endtime == "" then
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_time, false)
    return
  end
  local time = Z.TimeTools.GetTimeLeftInSpecifiedTime(timerId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_time, false)
  if time <= 0 then
    self.lab_time.text = Lang("ActivityHasEnd")
  end
  self.lab_time.text = Lang("RemainTime") .. Z.TimeTools.FormatToDHMSStr(time)
  if self.timer == nil then
    self.timer = self.timerMgr:StartTimer(function()
      time = time - 1
      if time <= 0 then
        time = Z.TimeTools.GetTimeLeftInSpecifiedTime(timerId)
      end
      if time <= 0 then
        self.lab_time.text = Lang("ActivityHasEnd")
        self.timerMgr:StopTimer(self.timer)
        self.timer = nil
        return
      end
      self.lab_time.text = Lang("RemainTime") .. Z.TimeTools.FormatToDHMSStr(time)
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
  local isValid = self.gashaVm_.ValidateDrawConditions(self.gashaId_, count)
  if not isValid then
    return
  end
  local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", itemConfigId)
  if itemTableRow == nil then
    return
  end
  self:realDraw(count)
end

function Gasha_windowView:realDraw(count)
  self.gashaData_:SetIsDrawing(true)
  Z.CoroUtil.create_coro_xpcall(function()
    local ret = self.gashaVm_.AsyncGashaRequest(self.gashaId_, count, self.cancelSource:CreateToken())
    if ret ~= nil then
      if ret.errorCode ~= 0 then
        self:ResetIgnore()
        self.gashaVm_.HandleError(ret.errorCode)
      else
        local quality = 1
        for k, v in pairs(ret.items) do
          if quality < v.quality then
            quality = v.quality
          end
        end
        self:showDrawResult(ret.items, quality, #ret.items == 1)
      end
    end
  end)()
end

function Gasha_windowView:OnToggleSelected(Id, index)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  self.gashaId_ = Id
  self.gashaPoolTableRow_ = Z.TableMgr.GetRow("GashaPoolTableMgr", self.gashaId_)
  if self.gashaPoolTableRow_ == nil then
    return
  end
  self:refreshUI()
  for k, v in pairs(gashaBannerMap) do
    v:SetSelfActive(k == Id, self.gashaPoolTableRow_)
  end
  if not table.zcontainsKey(gashaBannerMap, Id) then
    Z.CoroUtil.create_coro_xpcall(function()
      local banner = self:AsyncLoadUiUnit(gashaType2Banner[self.gashaPoolTableRow_.GashaType], tostring(Id), self.uiBinder.node_banner)
      local bannerTpl = gashaBannerTpl.new(banner)
      gashaBannerMap[Id] = bannerTpl
      bannerTpl:SetSelfActive(true, self.gashaPoolTableRow_)
    end)()
  end
end

function Gasha_windowView:showDrawResult(items, bestResultQuality, isSingleDraw)
  if items == nil or #items < 1 then
    self:ResetIgnore()
    self.gashaData_:SetIsDrawing(false)
    logError("items is nil")
    return
  end
  self.gashaVm_.PlayGashaCutScene(self.gashaId_, items, bestResultQuality, isSingleDraw, nil, function()
    self:ResetIgnore()
    self.gashaVm_.OpenGashaResultView(self.gashaId_, items)
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

function Gasha_windowView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Gasha)
end

function Gasha_windowView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Gasha)
end

function Gasha_windowView:preLoadResultView()
  self.resultGo_ = nil
  local viewConfigKey = "gasha_result_window"
  local prefabPath = Z.UIConfig[viewConfigKey].PrefabPath
  Z.UIMgr:LoadView(viewConfigKey, prefabPath, self.cancelSource:CreateToken(), function(go)
    Z.UIRoot:CacheUI(viewConfigKey, go)
    self.resultGo_ = go
  end)
end

function Gasha_windowView:releaseResultView()
  local viewConfigKey = "gasha_result_window"
  if self.resultGo_ then
    Z.UIRoot:GetCacheUI(viewConfigKey)
    Z.LuaBridge.ReleaseInstance(self.resultGo_)
    self.resultGo_ = nil
  end
end

return Gasha_windowView
