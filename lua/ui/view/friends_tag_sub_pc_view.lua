local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_tag_sub_pcView = class("Friends_tag_sub_pcView", super)
local loopListView = require("ui.component.loop_list_view")
local friendTagItemPC = require("ui.component.friends_pc.friend_tag_item_pc")

function Friends_tag_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_tag_sub_pc", "friends_pc/friends_tag_sub_pc", UI.ECacheLv.None)
end

function Friends_tag_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self:AddClick(self.uiBinder.btn_person, function()
    local personalZoneVM = Z.VMMgr.GetVM("personal_zone")
    personalZoneVM.OpenPersonalZoneMainByCharId(self.viewData.charId, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_send, function()
    local friendsMainVM = Z.VMMgr.GetVM("friends_main")
    friendsMainVM.OpenPrivateChat(self.viewData.charId)
  end)
end

function Friends_tag_sub_pcView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVM_.AsyncGetPersonalZone(self.viewData.charId, self.cancelSource:CreateToken())
    if socialData and socialData.personalZone then
      self:refreshPersonalityLabels(socialData.personalZone.tags or {})
      self:refreshOnlineTime(socialData.personalZone.onlinePeriods or {})
    else
      self:refreshPersonalityLabels({})
      self:refreshOnlineTime({})
    end
  end)()
end

function Friends_tag_sub_pcView:OnDeActive()
  if self.tagLoopList_ then
    self.tagLoopList_:UnInit()
    self.tagLoopList_ = nil
  end
  if self.timeLoopList_ then
    self.timeLoopList_:UnInit()
    self.timeLoopList_ = nil
  end
end

function Friends_tag_sub_pcView:refreshPersonalityLabels(tags)
  local tagList = {}
  if 0 < #tags then
    local personalTagMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
    for i = 1, #tags do
      local config = personalTagMgr.GetRow(tags[i])
      tagList[#tagList + 1] = config
    end
    table.sort(tagList, function(aConfig, bConfig)
      if aConfig.ShowSort == bConfig.ShowSort then
        return aConfig.Id < bConfig.Id
      else
        return aConfig.ShowSort < bConfig.ShowSort
      end
    end)
  end
  if 0 < #tagList then
    if self.tagLoopList_ then
      self.tagLoopList_:RefreshListView(tagList, false)
    else
      self.tagLoopList_ = loopListView.new(self, self.uiBinder.loop_tag, friendTagItemPC, "friends_tag_tpl")
      self.tagLoopList_:Init(tagList)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_tag_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tag, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_tag_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_tag, false)
  end
end

function Friends_tag_sub_pcView:refreshOnlineTime(onlineDay)
  local onlineDayList = {}
  if 0 < #onlineDay then
    local personalTagMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
    for i = 1, #onlineDay do
      local config = personalTagMgr.GetRow(onlineDay[i])
      onlineDayList[#onlineDayList + 1] = config
    end
    table.sort(onlineDayList, function(aConfig, bConfig)
      if aConfig.ShowSort == bConfig.ShowSort then
        return aConfig.Id < bConfig.Id
      else
        return aConfig.ShowSort < bConfig.ShowSort
      end
    end)
  end
  if 0 < #onlineDayList then
    if self.timeLoopList_ then
      self.timeLoopList_:RefreshListView(onlineDayList, false)
    else
      self.timeLoopList_ = loopListView.new(self, self.uiBinder.loop_time, friendTagItemPC, "friends_tag_tpl")
      self.timeLoopList_:Init(onlineDayList)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_time, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_time, false)
  end
end

return Friends_tag_sub_pcView
