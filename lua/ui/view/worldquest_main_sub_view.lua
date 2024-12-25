local UI = Z.UI
local super = require("ui.ui_subview_base")
local Worldquest_main_subView = class("Worldquest_main_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local common_reward_loop_list_item = require("ui.component.common_reward_grid_list_item")

function Worldquest_main_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "worldquest_main_sub", "worldquest/worldquest_main_sub", UI.ECacheLv.None)
  self.worldQuestVM_ = Z.VMMgr.GetVM("worldquest")
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.parentView_ = parent
end

function Worldquest_main_subView:closeView()
  self.closeByBtn_ = true
  if self.viewData.showInMap_ then
    self.parentView_:CloseRightSubview()
  else
    Z.UIMgr:CloseView("worldquest_main_window")
  end
  self:DeActive()
end

function Worldquest_main_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.closeByBtn_ = false
  self.entering_ = false
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
  self:AddClick(self.uiBinder.btn_close, function()
    self:closeView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_transfer, function()
    local success = self.worldQuestVM_.WorldQuestTransfer(self.viewData.dailyEventId_, self.cancelSource:CreateToken())
    if success then
      self.parentView_:CloseRightSubview()
    end
  end)
  self:AddClick(self.uiBinder.btn_team, function()
    local teamMainVM = Z.VMMgr.GetVM("team_main")
    local dailyEventRow = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(self.viewData.dailyEventId_)
    if dailyEventRow then
      local targetId = teamMainVM.GetTargetIdByDungeonId(dailyEventRow.DungeonId)
      teamMainVM.OpenTeamMainView(targetId)
    else
      logError("DailyWorldEventTableMgr\230\156\170\230\137\190\229\136\176id\228\184\186" .. self.viewData.dailyEventId_ .. "\231\154\132\230\149\176\230\141\174")
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_enter, function()
    local dailyEventRow = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(self.viewData.dailyEventId_)
    if dailyEventRow then
      local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dailyEventRow.DungeonId)
      if dungeonsTable == nil then
        return
      end
      if self.entering_ then
        Z.TipsVM.ShowTips(100000)
        return
      end
      self.entering_ = true
      local enterdungeonsceneVm_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
      enterdungeonsceneVm_.AsyncCreateLevel(dungeonsTable.FusanctionID, dailyEventRow.DungeonId, self.cancelSource:CreateToken())
      self:closeView()
      self.entering_ = false
    else
      logError("DailyWorldEventTableMgr\230\156\170\230\137\190\229\136\176id\228\184\186" .. self.viewData.dailyEventId_ .. "\231\154\132\230\149\176\230\141\174")
    end
  end)
  self.loopGridView_ = loopGridView.new(self, self.uiBinder.scrollview, common_reward_loop_list_item, "com_item_square_8")
  self.loopGridView_:Init({})
  self:startAnimatedShow()
  if Z.UIMgr:IsActive("mainui_funcs_list") then
    local mainUIFuncsListVM = Z.VMMgr.GetVM("mainui_funcs_list")
    mainUIFuncsListVM.CloseView()
  end
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
  self:bindEvent()
end

function Worldquest_main_subView:OnDeActive()
  self:unInitLoopListView()
  self:unBindEvent()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
end

function Worldquest_main_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
end

function Worldquest_main_subView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
end

function Worldquest_main_subView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    self:closeView()
  end
end

function Worldquest_main_subView:OnRefresh()
  local dailyEventRow = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(self.viewData.dailyEventId_)
  self.uiBinder.lab_info.text = dailyEventRow.Desc
  self.uiBinder.lab_title.text = dailyEventRow.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_title_2, dailyEventRow.Scene > 0)
  if dailyEventRow.Scene > 0 then
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(dailyEventRow.Scene)
    local sceneName = sceneRow and sceneRow.Name or ""
    self.uiBinder.lab_title_2.text = sceneName
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_group, self.viewData.showInMap_ == false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_transfer, self.viewData.showInMap_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, self.worldQuestVM_.CheckWorldEventComplete(self.viewData.dailyEventId_))
  if self.worldQuestVM_.CheckWorldEventComplete(self.viewData.dailyEventId_) then
    self.uiBinder.cont_content.alpha = 0.9
  else
    self.uiBinder.cont_content.alpha = 1
  end
  self:refreshLoopListView()
end

function Worldquest_main_subView:refreshLoopListView()
  local dailyEventRow = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(self.viewData.dailyEventId_)
  local dataList_ = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(dailyEventRow.Award)
  self.loopGridView_:RefreshListView(dataList_)
  self.loopGridView_:ClearAllSelect()
end

function Worldquest_main_subView:unInitLoopListView()
  self.loopGridView_:UnInit()
  self.loopGridView_ = nil
end

function Worldquest_main_subView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Worldquest_main_subView:startAnimatedHide()
  if self.closeByBtn_ then
    local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
    coro(self.uiBinder.anim, Z.DOTweenAnimType.Close)
  end
end

return Worldquest_main_subView
