local UI = Z.UI
local super = require("ui.ui_view_base")
local Main_line_windowView = class("Main_line_windowView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local loopListView = require("ui.component.loop_list_view")
local sceneline_loop_item = require("ui.component.sceneline.sceneline_loop_item")

function Main_line_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_line_window")
  self.searchLineId = nil
  self.playerLineId = nil
end

function Main_line_windowView:OnActive()
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.scenelineVM_ = Z.VMMgr.GetVM("sceneline")
  self.scenelineData = Z.DataMgr.Get("sceneline_data")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
  self.searchLineLimit = Z.Global.LineSearchLimit
  self:initBinder()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
  self:bindEvents()
  self:setPlayerUI()
  self:AddClick(self.btnCloseView_, function()
    self.scenelineVM_.CloseSceneLineView()
  end)
  self:AddClick(self.btnGoto_, function()
    if self.selectLineId then
      if self.scenelineData.playerSceneLine and self.selectLineId == self.scenelineData.playerSceneLine.sceneLineInfo.lineId then
        Z.TipsVM.ShowTips(2951)
      else
        self.scenelineVM_.EnterSceneLine(self.selectLineId)
      end
    end
  end)
  self:AddClick(self.btnRefresh_, function()
    self.searchLineId = nil
    self.inputSearch_.text = ""
    self.scenelineVM_.RefreshSceneLineDataList()
  end)
  self:AddClick(self.inputSearchClose_, function()
    self.searchLineId = nil
    self.inputSearch_.text = ""
    self:refreshLoopListView()
  end)
  self:AddClick(self.btn_search_, function()
    self.searchLineId = tonumber(self.inputSearch_.text)
    self:refreshLoopListView()
  end)
  self.inputSearch_:AddListener(function(value)
    if #value > self.searchLineLimit then
      self.inputSearch_.text = string.sub(value, 0, self.searchLineLimit)
    end
  end)
  self:initLoopListView()
  if Z.UIMgr:IsActive("mainui_funcs_list") then
    local mainUIFuncsListVM = Z.VMMgr.GetVM("mainui_funcs_list")
    mainUIFuncsListVM.CloseView()
  end
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
end

function Main_line_windowView:OnDeActive()
  self:unBindEvents()
  self:unInitLoopListView()
  self.selectLineId = nil
  self.searchLineId = nil
  self.inputSearch_.text = ""
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
end

function Main_line_windowView:initBinder()
  self.node_head_ = self.uiBinder.node_head
  self.labSceneName_ = self.uiBinder.lab_scene_name
  self.labLineNum_ = self.uiBinder.lab_line_num
  self.btnCloseView_ = self.uiBinder.node_close.btn
  self.btnRefresh_ = self.uiBinder.img_refresh
  self.btnGoto_ = self.uiBinder.btn_goto
  self.inputSearch_ = self.uiBinder.img_base_input.input_search
  self.inputSearchClose_ = self.uiBinder.img_base_input.btn_close
  self.btn_search_ = self.uiBinder.img_base_input.btn_search
end

function Main_line_windowView:OnRefresh()
  self:refreshLoopListView()
end

function Main_line_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.SceneLine.RefreshSceneLineList, self.refreshLoopListView, self)
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
end

function Main_line_windowView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.SceneLine.RefreshSceneLineList, self.refreshLoopListView, self)
  Z.EventMgr:Remove(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
end

function Main_line_windowView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, sceneline_loop_item, "main_line_list_tpl")
  self.selectLineItem = nil
  local dataList_ = self.scenelineData:GetSceneLineDataList(self.searchLineId)
  self.loopListView_:Init(dataList_)
  self.loopListView_:SetSelected(1)
end

function Main_line_windowView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    self.scenelineVM_.CloseSceneLineView()
  end
end

function Main_line_windowView:refreshLoopListView()
  local dataList_ = self.scenelineData:GetSceneLineDataList(self.searchLineId)
  if next(dataList_) == nil and self.searchLineId then
    Z.TipsVM.ShowTips(1000739, {
      val = self.searchLineId
    })
    return
  end
  self.loopListView_:ClearAllSelect()
  self.loopListView_:RefreshListView(dataList_)
  self.loopListView_:SetSelected(1)
end

function Main_line_windowView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Main_line_windowView:setPlayerUI()
  Z.CoroUtil.create_coro_xpcall(function()
    self.socialData_ = self.socialVm_.AsyncGetSocialData(0, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    local sceneRow_ = Z.TableMgr.GetTable("SceneTableMgr").GetRow(self.socialData_.basicData.sceneId)
    self.labSceneName_.text = sceneRow_.Name
    self.labLineNum_.text = self.scenelineData.playerSceneLine.lineName
    playerPortraitHgr.InsertNewPortraitBySocialData(self.node_head_, self.socialData_)
  end)()
end

function Main_line_windowView:OnSceneLineSelect(selectLineId)
  self.selectLineId = selectLineId
  self.btnGoto_.IsDisabled = selectLineId == self.scenelineData.playerSceneLine.sceneLineInfo.lineId
end

return Main_line_windowView
