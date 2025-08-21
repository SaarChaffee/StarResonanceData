local UI = Z.UI
local super = require("ui.ui_view_base")
local House_bulletin_board_popupView = class("House_bulletin_board_popupView", super)
E.HouseBoardEventType = {Quite = 1, Transfer = 2}
local loopListView = require("ui.component.loop_list_view")
local boardEventItem = require("ui.component.house.house_board_event_loop_item")
local boardLogItem = require("ui.component.house.house_board_log_loop_item")

function House_bulletin_board_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_bulletin_board_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function House_bulletin_board_popupView:initUiBinders()
  self.eventTog_ = self.uiBinder.bingder_house_event.node_item
  self.logTog_ = self.uiBinder.bingder_house_log.node_item
  self.closeBtn_ = self.uiBinder.close_btn
  self.itemLoopList_ = self.uiBinder.scrollview_item
  self.togGroup_ = self.uiBinder.node_tab
  self.sceneMask_ = self.uiBinder.scenemask
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function House_bulletin_board_popupView:initBtns()
  self:AddClick(self.eventTog_, function(isOn)
    self.IsEventTog = isOn
    if isOn then
      self:refreshList()
    end
  end)
  self:AddClick(self.logTog_, function(isOn)
    self.IsEventTog = not isOn
    if isOn then
      self:refreshList()
    end
  end)
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseBulletinBoardView()
  end)
end

function House_bulletin_board_popupView:initData()
  self.IsEventTog = false
  self.eventList_ = {}
end

function House_bulletin_board_popupView:initUi()
  self.boardLisView_ = loopListView.new(self, self.itemLoopList_)
  self.boardLisView_:SetGetPrefabNameFunc(function()
    if self.IsEventTog then
      return "house_bulletin_board_item_tpl2"
    else
      return "house_bulletin_board_item_tpl1"
    end
  end)
  self.boardLisView_:SetGetItemClassFunc(function()
    if self.IsEventTog then
      return boardEventItem
    else
      return boardLogItem
    end
  end)
  self.boardLisView_:Init({})
  self.eventTog_.group = self.togGroup_
  self.logTog_.group = self.togGroup_
  self.logTog_.isOn = true
  self:refreshList()
end

function House_bulletin_board_popupView:OnActive()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initUiBinders()
    self:initBtns()
    self.boardInfo_ = self.houseVm_.AsyncGetHomelandBulletinBoards(self.cancelSource:CreateToken()) or {}
    self:initData()
    self:initUi()
  end)()
end

function House_bulletin_board_popupView:OnDeActive()
  if self.boardLisView_ then
    self.boardLisView_:UnInit()
    self.boardLisView_ = nil
  end
end

function House_bulletin_board_popupView:OnRefresh()
end

function House_bulletin_board_popupView:refreshList()
  if self.boardInfo_ == nil then
    return
  end
  local isOwnerHouse = self.houseData_:GetHomeOwnerCharId() == Z.ContainerMgr.CharSerialize.charBase.charId
  if self.IsEventTog then
    self.eventList_ = {}
    local CommunityTransfer = self.houseData_:GetHomeTransferData()
    if CommunityTransfer and CommunityTransfer.charId ~= 0 and (CommunityTransfer.charId == Z.ContainerMgr.CharSerialize.charBase.charId or isOwnerHouse) then
      self.eventList_[1] = {
        type = E.HouseBoardEventType.Transfer,
        time = CommunityTransfer.time,
        communityTransfer = CommunityTransfer
      }
    end
    local CommunityPlayerInfos = self.houseData_:GetHomeCohabitantInfo()
    if CommunityPlayerInfos then
      for charId, communityPlayerInfo in pairs(CommunityPlayerInfos) do
        if (charId == Z.ContainerMgr.CharSerialize.charBase.charId or isOwnerHouse) and communityPlayerInfo.quitCohabitant and communityPlayerInfo.quitCohabitant.time ~= 0 then
          self.eventList_[#self.eventList_ + 1] = {
            type = E.HouseBoardEventType.Quite,
            time = communityPlayerInfo.quitCohabitant.time,
            communityPlayerInfo = {
              charId = charId,
              isInitiativeQuit = communityPlayerInfo.quitCohabitant.isInitiativeQuit
            }
          }
        end
      end
    end
    if #self.eventList_ >= 2 then
      table.sort(self.eventList_, function(left, right)
        return left.time < right.time
      end)
    end
    self.boardLisView_:RefreshListView(self.eventList_)
  else
    local bulletinBoards = self.boardInfo_.bulletinBoards or {}
    local list = table.zreverse(bulletinBoards)
    self.boardLisView_:RefreshListView(list)
  end
end

return House_bulletin_board_popupView
