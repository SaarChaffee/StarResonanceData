local super = require("ui.ui_view_base")
local Main_line_windowView = class("Main_line_windowView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local loopListView = require("ui.component.loop_list_view")
local sceneline_loop_item = require("ui.component.sceneline.sceneline_loop_item")

function Main_line_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_line_window")
  self.playerLineId = nil
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.sceneLineVM_ = Z.VMMgr.GetVM("sceneline")
  self.sceneLineData_ = Z.DataMgr.Get("sceneline_data")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
end

function Main_line_windowView:OnActive()
  self:initData()
  self:initBinder()
  self:initComponent()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
  self:bindEvents()
  self:refreshPlayerUI()
  if Z.UIMgr:IsActive("mainui_funcs_list") then
    local mainUIFuncsListVM = Z.VMMgr.GetVM("mainui_funcs_list")
    mainUIFuncsListVM.CloseView()
  end
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
end

function Main_line_windowView:OnDeActive()
  self:unBindEvents()
  self:unInitLoopListView()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
end

function Main_line_windowView:OnRefresh()
  self.inputSearch_.text = ""
  self:refreshLineList(false, true)
end

function Main_line_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  Z.EventMgr:Add(Z.ConstValue.SceneLine.RequestSceneLineInfoBack, self.onRequestSceneLineBack, self)
end

function Main_line_windowView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  Z.EventMgr:Remove(Z.ConstValue.SceneLine.RequestSceneLineInfoBack, self.onRequestSceneLineBack, self)
end

function Main_line_windowView:initBinder()
  self.node_head_ = self.uiBinder.node_head
  self.labSceneName_ = self.uiBinder.lab_scene_name
  self.labLineNum_ = self.uiBinder.lab_line_num
  self.btnCloseView_ = self.uiBinder.btn_close
  self.btnRefresh_ = self.uiBinder.img_refresh
  self.btnGoto_ = self.uiBinder.btn_goto
  self.labGoto_ = self.uiBinder.lab_goto
  self.inputSearch_ = self.uiBinder.img_base_input.input_search
  self.node_list_loading = self.uiBinder.node_list_loading
  self.node_list_normal = self.uiBinder.node_list_normal
end

function Main_line_windowView:initComponent()
  self:AddClick(self.btnCloseView_, function()
    self.sceneLineVM_.CloseSceneLineView()
  end)
  self:AddAsyncClick(self.btnGoto_, function()
    self:switchSceneLine()
  end)
  self:AddAsyncClick(self.btnRefresh_, function()
    self.inputSearch_.text = ""
    self:refreshLineList(true, true)
  end)
  self.inputSearch_:AddListener(function(value)
    if #value > Z.Global.LineSearchLimit then
      self.inputSearch_.text = string.sub(value, 0, Z.Global.LineSearchLimit)
    end
    if self.loopListView_ ~= nil then
      self.loopListView_:ClearAllSelect()
      self.selectedLineData = nil
      self:refreshLabel()
    end
  end)
  self.inputSearch_:AddSubmitListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self:switchSceneLine()
    end)()
  end)
  self:initLoopListView()
end

function Main_line_windowView:initData()
  self.selectedLineData = nil
  self.searchLineId = nil
end

function Main_line_windowView:refreshPlayerUI()
  self.labLineNum_.text = ""
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local sceneRow_ = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
    self.labSceneName_.text = sceneRow_.Name
    playerPortraitHgr.InsertNewPortraitBySocialData(self.node_head_, socialData, nil, self.cancelSource:CreateToken())
  end)()
end

function Main_line_windowView:refreshPlayerLineDataUI()
  local lineId = self.sceneLineData_.PlayerLineId
  local lineData = self.sceneLineData_:GetPlayerSceneLineDataFromList()
  local param = {val = lineId}
  if lineData and lineData.status == E.SceneLineState.SceneLineStatusRecycle then
    self.labLineNum_.text = Lang("LineRecycleNote", param)
  else
    self.labLineNum_.text = Lang("Line", param)
  end
end

function Main_line_windowView:refreshLoopListView()
  local dataList = self.sceneLineData_:GetLineInfoDataList()
  self.loopListView_:ClearAllSelect()
  self.loopListView_:RefreshListView(dataList)
  local isEmpty = #dataList == 0
  self:SetUIVisible(self.node_list_loading, isEmpty)
  self:SetUIVisible(self.node_list_normal, not isEmpty)
end

function Main_line_windowView:refreshLineList(showCdTips, needRequest)
  if self.sceneLineData_:IsValidData() then
    local interval = os.time() - self.sceneLineData_.LastRequestTime
    if interval < Z.Global.LineChangeCD then
      if showCdTips then
        Z.TipsVM.ShowTips(1000741, {
          val = math.floor(Z.Global.LineChangeCD - interval)
        })
      end
      self:refreshSceneLineUI()
      return
    end
  end
  if needRequest then
    Z.CoroUtil.create_coro_xpcall(function()
      self:SetUIVisible(self.node_list_loading, true)
      self:SetUIVisible(self.node_list_normal, false)
      self.sceneLineVM_.AsyncReqSceneLineInfo()
    end)()
  else
    self:refreshSceneLineUI()
  end
end

function Main_line_windowView:refreshSceneLineUI()
  self:refreshPlayerLineDataUI()
  self:refreshLoopListView()
end

function Main_line_windowView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, sceneline_loop_item, "main_line_list_tpl")
  self.loopListView_:Init(self.sceneLineData_:GetLineInfoDataList())
end

function Main_line_windowView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Main_line_windowView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    self.sceneLineVM_.CloseSceneLineView()
  end
end

function Main_line_windowView:OnSceneLineSelect(selectedLineData)
  self.selectedLineData = selectedLineData
  self:refreshLabel()
  self.inputSearch_:SetTextWithoutNotify("")
end

function Main_line_windowView:refreshLabel()
  if self.selectedLineData ~= nil then
    if self.selectedLineData.sceneGuid == self.sceneLineData_.PlayerSceneGuid then
      self.btnGoto_.IsDisabled = true
      self.labGoto_.text = Lang("Current")
    elseif self.selectedLineData.status == E.SceneLineState.SceneLineStatusFull then
      self.btnGoto_.IsDisabled = true
      self.labGoto_.text = Lang("LineFull")
    elseif self.selectedLineData.status == E.SceneLineState.SceneLineStatusRecycle then
      self.btnGoto_.IsDisabled = true
      self.labGoto_.text = Lang("LineRecycle")
    else
      self.btnGoto_.IsDisabled = false
      self.labGoto_.text = Lang("Goto")
    end
  else
    self.btnGoto_.IsDisabled = false
    self.labGoto_.text = Lang("Goto")
  end
end

function Main_line_windowView:onRequestSceneLineBack()
  self:refreshSceneLineUI()
end

function Main_line_windowView:switchSceneLine()
  local selectedLineData
  if self.inputSearch_.text ~= "" then
    local searchLineId = tonumber(self.inputSearch_.text)
    if searchLineId and 0 < searchLineId then
      local dataList = self.loopListView_:GetData()
      for i, v in ipairs(dataList) do
        if v.lineId == searchLineId then
          selectedLineData = v
          break
        end
      end
    end
    if selectedLineData == nil then
      Z.TipsVM.ShowTips(1000754)
      return
    end
  else
    selectedLineData = self.selectedLineData
  end
  if selectedLineData ~= nil then
    if selectedLineData.sceneGuid == self.sceneLineData_.PlayerSceneGuid then
      Z.TipsVM.ShowTips(6354)
    elseif selectedLineData.status == E.SceneLineState.SceneLineStatusFull then
      Z.TipsVM.ShowTips(1000738)
    elseif selectedLineData.status == E.SceneLineState.SceneLineStatusRecycle then
      Z.TipsVM.ShowTips(6359)
    else
      self.sceneLineVM_.AsyncReqSwitchSceneLineByLineId(selectedLineData.lineId)
    end
  else
    Z.TipsVM.ShowTips(1000755)
  end
end

return Main_line_windowView
