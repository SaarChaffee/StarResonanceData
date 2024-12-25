local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_add_subView = class("Friends_add_subView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local friend_add_item = require("ui.component.friends.friend_add_item")
E.FriendAddSubShowType = {ESuggestion = 1, ESearch = 2}

function Friends_add_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_add_sub", "friends/friends_add_sub", UI.ECacheLv.None)
  self.searchType_ = E.FriendAddSource.ESearch
end

function Friends_add_subView:OnActive()
  self:onInitData()
  self:updateSubViewShow(E.FriendAddSubShowType.ESuggestion)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetWidth(766)
  self:BindLuaAttrWatchers()
  self:BindEvents()
end

function Friends_add_subView:OnDeActive()
  self.friendScrollRect_:ClearCells()
end

function Friends_add_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendSuggestionRefresh, self.refreshSuggestionList, self)
end

function Friends_add_subView:BindLuaAttrWatchers()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendSuggestionRefresh, self.refreshSuggestionList, self)
end

function Friends_add_subView:onInitData()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.friendScrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_node, self, friend_add_item)
  self:AddClick(self.uiBinder.btn_find, function()
    self:OnClickSearch()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.AddFriend)
  end)
  self:AddClick(self.uiBinder.btn_suggestion, function()
    self:OnClickGetSuggestionList()
  end)
  self:AddClick(self.uiBinder.btn_return_suggestion, function()
    self.uiBinder.input_search.text = ""
    self:updateSubViewShow(E.FriendAddSubShowType.ESuggestion)
  end)
  self.uiBinder.lab_uid_num.text = string.format("%s:%s", Lang("friendUid"), Z.EntityMgr.PlayerEnt.EntId)
end

function Friends_add_subView:OnRefresh()
  self.friendMainData_:ClearSendedFriendList()
  if self.viewData and self.viewData.refreshShow then
    self.viewData.refreshShow = false
    self:updateSubViewShow(E.FriendAddSubShowType.ESuggestion)
  elseif self.showType_ == E.FriendAddSubShowType.ESuggestion then
    self:refreshSuggestion()
  end
end

function Friends_add_subView:updateSubViewShow(type)
  self.showType_ = type
  if self.showType_ == E.FriendAddSubShowType.ESuggestion then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_no_text, false)
    self:initSuggestionList()
    self.uiBinder.loopscroll_node_ref:SetOffsetMax(0, -243)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_no_text, true)
    self:refreshSearch()
    self.uiBinder.loopscroll_node_ref:SetOffsetMax(0, -197)
  end
end

function Friends_add_subView:initSuggestionList()
  self.uiBinder.input_search.text = ""
  local lastGetSuggestionTime = self.friendMainData_:GetLastGetSuggestionTime()
  if lastGetSuggestionTime < Time.time then
    self:OnClickGetSuggestionList()
  else
    self:refreshSuggestion()
  end
end

function Friends_add_subView:OnClickGetSuggestionList()
  local lastGetSuggestionTime = self.friendMainData_:GetLastGetSuggestionTime()
  if lastGetSuggestionTime < Time.time then
    self.friendMainData_:SetLastGetSuggestionTime(Time.time + Z.Global.Chat_RECFriendsListRefreshCD)
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncGetSuggestionList(self.cancelSource)
      self:refreshSuggestion()
    end)()
  else
    local param = {
      time = {
        cd = math.ceil(lastGetSuggestionTime - Time.time)
      }
    }
    Z.TipsVM.ShowTipsLang(130100, param)
  end
end

function Friends_add_subView:refreshScrollRectSize()
  if self.showType_ == E.FriendAddSubShowType.ESuggestion then
    self.uiBinder.loopscroll_node_ref:SetOffsetMin(0, 127)
    self.uiBinder.loopscroll_node_ref:SetOffsetMax(0, 243)
  else
    self.uiBinder.loopscroll_node_ref:SetOffsetMin(0, 127)
    self.uiBinder.loopscroll_node_ref:SetOffsetMax(0, 206)
  end
end

function Friends_add_subView:refreshSuggestion()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_friend_recommend, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uid_num, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_suggestion, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return_suggestion, false)
  self:refreshSuggestionList()
end

function Friends_add_subView:refreshSuggestionList()
  if self.showType_ == E.FriendAddSubShowType.ESuggestion then
    local charList = self.friendMainData_:GetSuggestionList()
    local showCharList = {}
    for i = 1, #charList do
      if not self.friendMainData_:IsFriendByCharId(charList[i].charId) and not self.chatMainData_:IsInBlack(charList[i].charId) then
        showCharList[#showCharList + 1] = charList[i]
      end
    end
    self.friendScrollRect_:SetData(showCharList)
  end
end

function Friends_add_subView:refreshSearch()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_friend_recommend, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uid_num, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_suggestion, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return_suggestion, true)
end

function Friends_add_subView:OnClickSearch()
  local searchContent = self.uiBinder.input_search.text
  if searchContent == "" then
    Z.TipsVM.ShowTipsLang(100004)
    return
  end
  local lastTime = self.friendMainData_:GetLastSearchTime()
  if lastTime < Time.time then
    self.friendMainData_:SetLastSearchTime(Time.time + Z.Global.Chat_RECFriendsListRefreshCD)
    Z.CoroUtil.create_coro_xpcall(function()
      local ret = self.friendsMainVm_.SearchFriend(searchContent, self.cancelSource:CreateToken())
      if ret.errorCode == 0 then
        self:updateSubViewShow(E.FriendAddSubShowType.ESearch)
        local datas = {}
        if ret.data then
          for _, value in ipairs(ret.data) do
            if value.charId ~= 0 then
              local data = {}
              data.charId = value.charId
              data.friendShowInfo = value.info
              data.socialData = value.socialData
              data.source = self.searchType_
              table.insert(datas, data)
            end
          end
          table.sort(datas, function(a, b)
            return a.socialData.basicData.showId < b.socialData.basicData.showId
          end)
        end
        self.friendScrollRect_:SetData(datas)
      end
    end)()
  else
    local param = {
      time = {
        cd = math.ceil(lastTime - Time.time)
      }
    }
    Z.TipsVM.ShowTipsLang(130100, param)
  end
end

return Friends_add_subView
