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
  super.ctor(self, "season_activation_sub", "season_activation/season_activation_sub", UI.ECacheLv.None)
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
  self:bindEvents()
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
end

function Season_activation_subView:initParam()
  self.mainScrollViewListData_ = {}
  self.awardItem_ = {}
  self.awardData_ = {}
  self.seasonActivationVm_ = Z.VMMgr.GetVM("season_activation")
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassContainer_ = Z.ContainerMgr.CharSerialize.seasonCenter.battlePass
  self.battlePassCardData_ = self.battlePassVM_.AssemblyData()
  self.seasonGlobalTableMgr_ = Z.TableMgr.GetTable("SeasonGlobalTableMgr")
  self.seasonData_ = Z.DataMgr.Get("season_data")
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
  self.uiBinder.lab_season_name.text = seasonConfig.SeasonName
end

function Season_activation_subView:bindWatchers()
  function self.regRefreshData(container, dirty)
    self:refreshData(dirty)
  end
  
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:RegWatcher(self.regRefreshData)
  
  function self.battlePassDataUpDateFunc_(container, dirtys)
    if dirtys.curexp then
      self:initReferBattlePassLevelInfo()
    end
  end
  
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:RegWatcher(self.battlePassDataUpDateFunc_)
end

function Season_activation_subView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:UnregWatcher(self.regRefreshData)
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:UnregWatcher(self.battlePassDataUpDateFunc_)
  self.regRefreshData = nil
  self.battlePassDataUpDateFunc_ = nil
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
    if data.Type == 1 then
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
  local dataLists = self.seasonActivationVm_.GetActivationTargetData()
  self.loopListView_:Init(dataLists)
  self.isInitLoopListView_ = true
end

function Season_activation_subView:refreshMainLoopGridView()
  local dataLists = self.seasonActivationVm_.GetActivationTargetData()
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
  local level = self.battlePassContainer_.level + 1
  if level > #self.battlePassCardData_ then
    level = #self.battlePassCardData_
  end
  local bpCardData = self.battlePassVM_.GetBattlePassCardDataByLevel(level)
  local seasonExp = 0
  if bpCardData then
    seasonExp = bpCardData.SeasonExp
  end
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassContainer_.id)
  self.top_lab_grade_.text = self.battlePassContainer_.level
  self.top_progress_lab_.text = string.format("%s/%s", self.battlePassContainer_.curexp, seasonExp)
  self.top_slider_temp_.maxValue = seasonExp
  self.top_slider_temp_.value = self.battlePassContainer_.curexp
  self.top_week_lab_manage_.text = string.format("%s/%s", self.battlePassContainer_.weekExp, bpCardGlobalInfo.WeeklyExpLimit)
end

function Season_activation_subView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Season_activation_subView
