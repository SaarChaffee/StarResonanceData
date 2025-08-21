local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_nearby_tipsView = class("Main_nearby_tipsView", super)
local loopListView = require("ui.component.loop_list_view")
local nearbyPlayerLoopItem = require("ui.component.mainui.nearby_player_loop_item")

function Main_nearby_tipsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_nearby_tips", "main/nearby/main_nearby_tips", UI.ECacheLv.None)
end

function Main_nearby_tipsView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onStartAnimShow()
  self.nearbyPlayerLoopList = loopListView.new(self, self.uiBinder.loop_item, nearbyPlayerLoopItem, "main_nearby_tpl")
  self.nearbyPlayerLoopList:Init({})
  self:AddClick(self.uiBinder.btn_refresh, function()
    self:refreshPlayerList()
  end)
  self:AddClick(self.uiBinder.btn_open, function()
    self.isShowInScreen_ = not self.isShowInScreen_
    self:refreshViewPos()
  end)
  self.isShowInScreen_ = true
  self:refreshViewPos()
  self:refreshPlayerList()
end

function Main_nearby_tipsView:OnDeActive()
  self.nearbyPlayerLoopList:UnInit()
end

function Main_nearby_tipsView:OnRefresh()
end

function Main_nearby_tipsView:refreshPlayerList()
  local playerCount, playerInfos = Z.LuaBridge.GetNearPlayerInfoList(nil)
  local datas = {}
  local dataCount = 0
  for i = 0, playerCount - 1 do
    if playerInfos[i].CharId ~= 0 then
      dataCount = dataCount + 1
      datas[dataCount] = {
        charId = playerInfos[i].CharId,
        name = playerInfos[i].Name,
        level = playerInfos[i].Level,
        distance = playerInfos[i].Distance
      }
    end
  end
  table.sort(datas, function(a, b)
    if a.distance == b.distance then
      return a.charId < b.charId
    else
      return a.distance < b.distance
    end
  end)
  self.nearbyPlayerLoopList:RefreshListView(datas)
end

function Main_nearby_tipsView:refreshViewPos()
end

function Main_nearby_tipsView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Main_nearby_tipsView
