local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_activation_subView = class("Season_activation_subView", super)
local loopListView = require("ui.component.loop_list_view")
local season_activation_list_item = require("ui.component.season_activation.season_activation_list_item")
local season_activation_recommend_list_item = require("ui.component.season_activation.season_activation_recommend_list_item")
local season_activation_title_item = require("ui.component.season_activation.season_activation_title_item")
local Item_Default_Size = 88
local Item_Small_Size = 72

function Season_activation_subView:ctor(parent)
  self.parentView_ = parent
  self.uiBinder = nil
  super.ctor(self, "season_activation_sub", "season_activation/season_activation_sub", UI.ECacheLv.None, true)
end

function Season_activation_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initBinders()
  self:startAnimatedShow()
  self:initParam()
  self:initBtnClick()
  self:bindWatchers()
  self:initRefreshNum()
  self:initSeasonName()
  self:initReferBattlePassLevelInfo()
  self:refreshCompensateShopBtn()
  self:bindEvents()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initPrivilegesTips()
  end)()
end

function Season_activation_subView:OnDeActive()
  for k, v in pairs(self.awardData_) do
    local redNodeId = E.RedType.SeasonActivationAward .. v.Id
    Z.RedPointMgr.RemoveNodeItem(redNodeId, self)
  end
  Z.EventMgr:Remove(Z.ConstValue.SeasonActivation.RefreshData, self.refreshView, self)
  for k, v in pairs(self.awardItem_) do
    self:RemoveUiUnit(k)
  end
  self.awardItem_ = nil
  self.awardData_ = nil
  self:unInitMainLoopGridView()
  self:unBindWatchers()
  Z.UIMgr:CloseView("tips_item_reward_popup")
end

function Season_activation_subView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self.seasonActivationVm_.AsyncGetActivationTargetRequest(self.cancelSource:CreateToken())
  end)()
  self:setBpPrivileges()
end

function Season_activation_subView:initBinders()
  self.scrollView_content_ = self.uiBinder.scrollView_content
  self.lab_level_ = self.uiBinder.lab_level
  self.top_btn_buy_ = self.uiBinder.btn_buy_level
  self.top_lab_grade_ = self.uiBinder.lab_grade
  self.top_slider_temp_ = self.uiBinder.slider_temp
  self.top_week_lab_manage_ = self.uiBinder.lab_manage
  self.top_progress_lab_ = self.uiBinder.lab_num
  self.node_box_ = self.uiBinder.node_box
  self.node_final_reward_ = self.uiBinder.node_final_reward
  self.slider_content_ = self.uiBinder.slider_content
  self.img_activation_progress_ = self.uiBinder.img_activation_progress
  self.img_final_progress_ = self.uiBinder.img_final_progress
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.lab_refersh_num_ = self.uiBinder.lab_refersh_num
  self.btn_refersh_ = self.uiBinder.btn_refersh
  self.eff_activation_progress_ = self.uiBinder.eff_activation_progress
  self.eff_final_progress_ = self.uiBinder.eff_final_progress
  self.node_activation_progress_ = self.uiBinder.node_eff_activation_progress
  self.node_final_progress_ = self.uiBinder.node_eff_final_progress
  self.node_slider_extra_ = self.uiBinder.node_slider_extra
  self.btn_shop_ = self.uiBinder.btn_shop
  self.lab_shop_ = self.uiBinder.lab_shop
  self.btn_compensate_shop_ = self.uiBinder.btn_compensate
end

function Season_activation_subView:initParam()
  self.mainScrollViewListData_ = {}
  self.awardItem_ = {}
  self.awardData_ = {}
  self.seasonActivationVm_ = Z.VMMgr.GetVM("season_activation")
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassCardData_ = self.battlePassVM_.AssemblyData()
  self.seasonGlobalTableMgr_ = Z.TableMgr.GetTable("SeasonGlobalTableMgr")
  self.seasonData_ = Z.DataMgr.Get("season_data")
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  self.isInitLoopListView_ = false
end

function Season_activation_subView:initBtnClick()
  self:AddAsyncClick(self.btn_refersh_, function()
    self:onConfirmBtnClick()
  end)
  self:AddAsyncClick(self.top_btn_buy_, function()
    self.battlePassVM_.OpenBattlePassPurchaseView()
  end)
  self:AddClick(self.btn_shop_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.SeasonPassShop)
  end)
  self:AddClick(self.uiBinder.btn_goto, function()
    self.battlePassVM_.OpenBattlePassBuyView()
  end)
  self:AddClick(self.uiBinder.btn_privilege, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, false)
  end)
  self:AddClick(self.uiBinder.btn_find, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, true)
  end)
  self:AddClick(self.btn_compensate_shop_, function()
    local shopVm = Z.VMMgr.GetVM("shop")
    shopVm.OpenCompensatenShopView()
  end)
end

function Season_activation_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.SeasonActivation.RefreshData, self.refreshView, self)
end

function Season_activation_subView:refreshView(SeasonId, isRefresh)
  if isRefresh or self.isInitLoopListView_ then
    self:refreshMainLoopGridView()
  else
    self:initMainLoopListView()
  end
  self:initRefreshNum()
  self:initReferBattlePassLevelInfo()
  self:initSlider()
  self:initSeasonName()
  self:initActivationPoint()
  local functionTableMgr = Z.TableMgr.GetTable("FunctionTableMgr")
  local functionTableRow = functionTableMgr.GetRow(E.FunctionID.SeasonPassShop)
  if functionTableRow ~= nil then
    self.lab_shop_.text = functionTableRow.Name
  end
end

function Season_activation_subView:initSeasonName()
  local seasonConfig = self.seasonGlobalTableMgr_.GetRow(self.seasonData_.CurSeasonId)
  if seasonConfig then
    self.uiBinder.lab_season_name.text = seasonConfig.SeasonName
  end
end

function Season_activation_subView:bindWatchers()
  function self.regRefreshData(container, dirty)
    self:refreshData(dirty)
  end
  
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:RegWatcher(self.regRefreshData)
  Z.EventMgr:Add(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
end

function Season_activation_subView:onBattlePassDataUpDateFunc(dirtyTable)
  if dirtyTable.curexp or dirtyTable.level then
    self:initReferBattlePassLevelInfo()
  end
  if dirtyTable.buyPrimePass then
    self:setBpPrivileges()
  end
end

function Season_activation_subView:unBindWatchers()
  Z.EventMgr:Remove(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:UnregWatcher(self.regRefreshData)
  self.regRefreshData = nil
end

function Season_activation_subView:refreshData(dirty)
  if not dirty then
    return
  end
  if dirty.activationTargets then
    self:refreshMainLoopGridView()
  end
  if dirty.stageRewardStatus then
    self:initSlider()
  end
  if dirty.activationPoint then
    self:initActivationPoint()
  end
end

function Season_activation_subView:initMainLoopListView()
  self.loopListView_ = loopListView.new(self, self.scrollView_content_)
  self.loopListView_:SetGetPrefabNameFunc(function(data)
    if Z.IsPCUI then
      if data.Type == 1 then
        return "season_activation_title_tpl_pc"
      elseif data[1] and data[1].rewardRate and data[1].rewardRate > 100 then
        return "season_activation_recommend_item_list_tpl_pc"
      else
        return "season_activation_item_list_tpl_pc"
      end
    elseif data.Type == 1 then
      return "season_activation_title_tpl"
    elseif data[1] and data[1].rewardRate and data[1].rewardRate > 100 then
      return "season_activation_recommend_item_list_tpl"
    else
      return "season_activation_item_list_tpl"
    end
  end)
  self.loopListView_:SetGetItemClassFunc(function(data)
    if data.Type == 1 then
      return season_activation_title_item
    elseif data[1] and data[1].rewardRate and data[1].rewardRate > 100 then
      return season_activation_recommend_list_item
    else
      return season_activation_list_item
    end
  end)
  local dataLists = self.seasonActivationVm_.GetActivationTargetData(Z.IsPCUI)
  self.loopListView_:Init(dataLists)
  self.isInitLoopListView_ = true
end

function Season_activation_subView:refreshMainLoopGridView()
  local dataLists = self.seasonActivationVm_.GetActivationTargetData(Z.IsPCUI)
  if self.loopListView_ then
    self.loopListView_:RefreshListView(dataLists)
  end
end

function Season_activation_subView:unInitMainLoopGridView()
  if self.loopListView_ then
    self.loopListView_:UnInit()
  end
  self.loopListView_ = nil
  self.isInitLoopListView_ = false
end

function Season_activation_subView:setFillAmountNum()
  local awardData = self.seasonActivationVm_.GetActivationAwards()
  local secondLastValue = awardData[#awardData - 1].Activation
  local maxValue = awardData[#awardData].Activation
  local currentActivation = Z.ContainerMgr.CharSerialize.seasonActivation.activationPoint
  self.size_node_slider_extra_ = {}
  self.size_node_slider_extra_.x, self.size_node_slider_extra_.y = self.node_slider_extra_:GetSize(self.size_node_slider_extra_.x, self.size_node_slider_extra_.y)
  if secondLastValue >= currentActivation then
    local oneProgressValue = currentActivation / secondLastValue
    self.img_activation_progress_.fillAmount = oneProgressValue
    self.img_final_progress_.fillAmount = 0
    self.node_activation_progress_:SetAnchorPosition(self.size_.x * oneProgressValue, 0)
    self.eff_activation_progress_:SetEffectGoVisible(0 < oneProgressValue)
    self.eff_final_progress_:SetEffectGoVisible(false)
  else
    self.img_activation_progress_.fillAmount = 1
    local twoProgressValue = (currentActivation - secondLastValue) / (maxValue - secondLastValue)
    self.img_final_progress_.fillAmount = twoProgressValue
    self.eff_activation_progress_:SetEffectGoVisible(false)
    self.eff_final_progress_:SetEffectGoVisible(0 < twoProgressValue)
    self.node_final_progress_:SetAnchorPosition(self.size_node_slider_extra_.x * twoProgressValue, 0)
  end
end

function Season_activation_subView:initSlider()
  self:initActivationPoint()
  local awardData = self.seasonActivationVm_.GetActivationAwards()
  if not awardData or not next(awardData) then
    return
  end
  self.size_ = {}
  self.size_final_reward_ = {}
  self.size_.x, self.size_.y = self.node_box_:GetSize(self.size_.x, self.size_.y)
  self.size_final_reward_.x, self.size_final_reward_.y = self.node_final_reward_:GetSize(self.size_final_reward_.x, self.size_final_reward_.y)
  self:setFillAmountNum()
  local path = self.prefab_cache_:GetString("activation_award")
  if self.awardItem_ and next(self.awardItem_) then
    for k, v in pairs(self.awardItem_) do
      self:RemoveUiUnit(k)
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local maxProgress = 0
    if next(awardData) then
      maxProgress = awardData[#awardData - 1]
    end
    for k, v in pairs(awardData) do
      local name = "slider_award_" .. v.Id
      local pathToLoad = k == #awardData and self.node_final_reward_ or self.node_box_
      local item = self:AsyncLoadUiUnit(path, name, pathToLoad, self.cancelSource:CreateToken())
      self.awardData_[k] = v
      self.awardItem_[name] = item
      if k == #awardData then
        ZUtil.ZExtensions.SetLocalPos(item.Trans, 0, 0, 0)
      else
        local curPosX = self.size_.x * (v.Activation / maxProgress.Activation)
        ZUtil.ZExtensions.SetLocalPos(item.Trans, curPosX, 0, 0)
      end
      self:setAwardItemInfo(item, v, k)
      local bounds = Item_Default_Size
      if k ~= #awardData - 1 then
        bounds = Item_Small_Size
      end
      item.node_box:SetHeight(bounds)
      item.node_box:SetWidth(bounds)
    end
  end)()
end

function Season_activation_subView:setAwardItemInfo(item, awardData, index)
  local redNodeId = E.RedType.SeasonActivationAward .. awardData.Id
  Z.RedPointMgr.LoadRedDotItem(redNodeId, self, item.Trans)
  item.lab_num.text = awardData.Activation
  local awardGetState = self.seasonActivationVm_.CheckAwardIsGet(awardData.Id)
  local getPath = awardData.ImagePath .. "_get"
  item.img_unselect_box:SetImage(awardData.ImagePath)
  item.img_select_box:SetImage(getPath)
  item.Ref:SetVisible(item.img_box_select_bg, false)
  item.Ref:SetVisible(item.img_box_unselect_bg, true)
  item.eff_root:SetEffectGoVisible(false)
  item.btn_box.interactable = true
  item.btn_box.IsDisabled = false
  if awardGetState == E.DrawState.CanDraw then
    item.Ref:SetVisible(item.img_box_select_bg, true)
    item.Ref:SetVisible(item.img_box_unselect_bg, false)
    item.Ref:SetVisible(item.img_already_received, false)
    self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(item.eff_root)
    item.eff_root:SetEffectGoVisible(true)
    item.img_select_box:SetColor(Color.New(1, 1, 1, 1))
    item.btn_box.interactable = true
    item.btn_box.IsDisabled = false
  elseif awardGetState == E.DrawState.AlreadyDraw then
    item.Ref:SetVisible(item.img_box_select_bg, true)
    item.Ref:SetVisible(item.img_box_unselect_bg, false)
    item.Ref:SetVisible(item.img_already_received, true)
    item.eff_root:SetEffectGoVisible(false)
    item.img_select_box:SetColor(Color.New(1, 1, 1, 0.2))
    item.btn_box.interactable = false
    item.btn_box.IsDisabled = true
  end
  self:AddAsyncClick(item.btn_box, function()
    if awardGetState == E.DrawState.CanDraw then
      self.seasonActivationVm_.AsyncReceiveActivationAwardRequest(awardData.Id, self.cancelSource:CreateToken())
    else
      local viewData = {
        AwardId = awardData.LevelAwardID,
        ParentTrans = item.btn_box.transform
      }
      Z.UIMgr:OpenView("tips_item_reward_popup", viewData)
    end
  end)
end

function Season_activation_subView:onConfirmBtnClick()
  local activationPoint = self.seasonActivationVm_.GetRefreshCount()
  if activationPoint <= 0 then
    Z.TipsVM.ShowTips(6207)
    return
  end
  local refreshCount = self.seasonActivationVm_.GetRefreshCount()
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(string.format(Lang("ActiveRefresh"), refreshCount), function()
    self.seasonActivationVm_.AsyncRefreshCountRequest(self.cancelSource:CreateToken())
  end, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.SeasonActivationRefer)
end

function Season_activation_subView:initActivationPoint()
  self.lab_level_.text = Z.ContainerMgr.CharSerialize.seasonActivation.activationPoint
end

function Season_activation_subView:initRefreshNum()
  local refreshCount, limmitCount = self.seasonActivationVm_.GetRefreshCount()
  self.lab_refersh_num_.text = refreshCount .. "/" .. limmitCount
end

function Season_activation_subView:initReferBattlePassLevelInfo()
  local curBattlePassData = self.battlePassVM_.GetCurrentBattlePassContainer()
  if not curBattlePassData or not next(curBattlePassData) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_bpcard, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_bpcard_slider, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bpcard, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bpcard_slider, true)
  local level = curBattlePassData.level + 1
  if level > #self.battlePassCardData_ then
    level = #self.battlePassCardData_
  end
  local bpCardData = self.battlePassVM_.GetBattlePassCardDataByLevel(level)
  local seasonExp = 0
  if bpCardData then
    seasonExp = bpCardData.SeasonExp
  end
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(curBattlePassData.id)
  self.top_lab_grade_.text = curBattlePassData.level
  self.top_progress_lab_.text = string.format("%s/%s", curBattlePassData.curexp, seasonExp)
  self.top_slider_temp_.maxValue = seasonExp
  local curSliderVal = curBattlePassData.curexp
  if level > #self.battlePassCardData_ then
    curSliderVal = seasonExp
  end
  self.top_slider_temp_.value = curSliderVal
  self.top_progress_lab_.text = string.format("%s/%s", curSliderVal, seasonExp)
  self.top_week_lab_manage_.text = string.format("%s/%s", curBattlePassData.weekExp, bpCardGlobalInfo.WeeklyExpLimit)
  self.uiBinder.img_bpcard:SetImage(bpCardGlobalInfo.PassPicture[3])
end

function Season_activation_subView:startAnimatedShow()
  if Z.IsPCUI then
    return
  end
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Season_activation_subView:setBpPrivileges()
  local battlePassContainer_ = self.battlePassVM_.GetCurrentBattlePassContainer()
  local isPrimePass = battlePassContainer_ and battlePassContainer_.buyPrimePass
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, not isPrimePass)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_privileges, isPrimePass)
end

function Season_activation_subView:initPrivilegesTips()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, false)
  local privilegesData = self.battlePassVM_.GetBpCardPrivilegesData(self.battlePassData_.CurBattlePassData.id)
  if table.zcount(privilegesData) <= 0 then
    return
  end
  local path = self.prefab_cache_:GetString("privileges_tips")
  for k, v in pairs(privilegesData) do
    local name = string.format("privileges_tips_%s", k)
    local item = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_privilege_tips)
    self:setPrivilegesTipsItemInfo(item, v)
  end
end

function Season_activation_subView:setPrivilegesTipsItemInfo(item, data)
  item.img_icon:SetImage(data.PrivilegeIcon)
  item.lab_title.text = self.battlePassVM_.AssembledBpCardPrivilegesContent(data)
  item.Ref:SetVisible(item.lab_time, data.IsShowAccelerated)
  if data.IsShowAccelerated then
    local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassData_.CurBattlePassData.id)
    if not bpCardGlobalInfo or not bpCardGlobalInfo.Timer then
      item.Ref:SetVisible(item.lab_time, false)
      return
    end
    local time = Z.TimeTools.GetLeftTimeByTimerId(bpCardGlobalInfo.Timer)
    if 0 < time then
      time = math.floor(time / 86400)
    else
      item.Ref:SetVisible(item.lab_time, false)
      return
    end
    item.lab_time.text = Lang("Day", {val = time})
  end
end

function Season_activation_subView:refreshCompensateShopBtn()
  self.uiBinder.Ref:SetVisible(self.btn_compensate_shop_, false)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  local funcOpen = funcVm.FuncIsOn(E.FunctionID.CompensatenShop, true)
  if not funcOpen then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local shopVM = Z.VMMgr.GetVM("shop")
    local shopItemData = shopVM.AsyncGetShopDataByShopType(E.EShopType.CompensateShop, self.cancelSource:CreateToken())
    if table.zcount(shopItemData) == 0 then
      return
    end
    self.uiBinder.Ref:SetVisible(self.btn_compensate_shop_, true)
  end)()
end

return Season_activation_subView
