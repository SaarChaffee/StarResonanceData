local UI = Z.UI
local super = require("ui.ui_view_base")
local Friends_add_popupView = class("Friends_add_popupView", super)
local loop_grid_view = require("ui.component.loop_grid_view")
local friend_suggestion_item_pc = require("ui.component.friends_pc.friend_suggestion_item_pc")

function Friends_add_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friends_add_popup")
end

function Friends_add_popupView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self:initVMData()
  self:initFunc()
  self:refreshUuid()
end

function Friends_add_popupView:OnDeActive()
  self.suggestionList_:UnInit()
end

function Friends_add_popupView:initVMData()
  self.friendMainVM_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
end

function Friends_add_popupView:initFunc()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("friends_add_popup")
  end)
  self:AddAsyncClick(self.uiBinder.btn_find, function()
    self:onClickSearch()
  end)
  self:AddAsyncClick(self.uiBinder.btn_refresh, function()
    self:asyncRefreshSuggestionList()
  end)
  self.uiBinder.input_search:AddListener(function(searchContext)
    if searchContext ~= "" then
      return
    end
    self:refreshSuggestionList()
  end)
  self.suggestionList_ = loop_grid_view.new(self, self.uiBinder.loop_list, friend_suggestion_item_pc, "friend_suggestion_item_tpl_pc")
  self.suggestionList_:Init({})
  local lastGetSuggestionTime = self.friendMainData_:GetLastGetSuggestionTime()
  local charList = self.friendMainData_:GetSuggestionList()
  if lastGetSuggestionTime < Time.time or #charList == 0 then
    Z.CoroUtil.create_coro_xpcall(function()
      self:refreshSuggestionList()
      self:asyncRefreshSuggestionList()
    end)()
  else
    self:refreshSuggestionList()
  end
end

function Friends_add_popupView:asyncRefreshSuggestionList()
  local lastGetSuggestionTime = self.friendMainData_:GetLastGetSuggestionTime()
  if lastGetSuggestionTime < Time.time then
    self.friendMainData_:SetLastGetSuggestionTime(Time.time + Z.Global.Chat_RECFriendsListRefreshCD)
    self.friendMainVM_.AsyncGetSuggestionList(self.cancelSource)
    self:refreshSuggestionList()
  else
    local param = {
      time = {
        cd = math.ceil(lastGetSuggestionTime - Time.time)
      }
    }
    Z.TipsVM.ShowTipsLang(130100, param)
  end
end

function Friends_add_popupView:onClickSearch()
  local searchContent = self.uiBinder.input_search.text
  if searchContent == "" then
    Z.TipsVM.ShowTipsLang(100004)
    return
  end
  local lastTime = self.friendMainData_:GetLastSearchTime()
  if lastTime < Time.time then
    self.friendMainData_:SetLastSearchTime(Time.time + Z.Global.Chat_RECFriendsListRefreshCD)
    local ret = self.friendMainVM_.SearchFriend(searchContent, self.cancelSource:CreateToken())
    if ret.errCode == 0 then
      local datas = {}
      if ret.data then
        for _, value in ipairs(ret.data) do
          if value.charId ~= 0 then
            local data = {}
            data.charId = value.charId
            data.friendShowInfo = value.info
            data.socialData = value.socialData
            data.source = E.FriendAddSource.ESearch
            table.insert(datas, data)
          end
        end
        table.sort(datas, function(a, b)
          return a.socialData.basicData.showId < b.socialData.basicData.showId
        end)
      end
      self.suggestionList_:RefreshListView(datas, false)
    end
  else
    local param = {
      time = {
        cd = math.ceil(lastTime - Time.time)
      }
    }
    Z.TipsVM.ShowTipsLang(130100, param)
  end
end

function Friends_add_popupView:refreshSuggestionList()
  local charList = self.friendMainData_:GetSuggestionList()
  local showCharList = {}
  for i = 1, #charList do
    if not self.friendMainData_:IsFriendByCharId(charList[i].charId) and not self.chatMainData_:IsInBlack(charList[i].charId) then
      showCharList[#showCharList + 1] = charList[i]
    end
  end
  self.suggestionList_:RefreshListView(showCharList, false)
end

function Friends_add_popupView:refreshUuid()
  if Z.EntityMgr.PlayerEnt then
    self.uiBinder.lab_uuid.text = string.format("%s:%s", Lang("friendUid"), Z.EntityMgr.PlayerEnt.EntId)
  else
    self.uiBinder.lab_uuid.text = ""
    logError("PlayerEnt is nil")
  end
end

return Friends_add_popupView
