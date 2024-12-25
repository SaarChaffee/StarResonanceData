local UI = Z.UI
local super = require("ui.ui_view_base")
local Reward_Preview_PopupView = class("Reward_Preview_PopupView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local comRewardItem = require("ui.component.award.com_reward_item")
local comRewardDetailItem = require("ui.component.award.com_reward_detail_item")
local LEFT_ITEM_COUNT = 8

function Reward_Preview_PopupView:ctor()
  self.panel = nil
  super.ctor(self, "reward_preview_popup")
end

function Reward_Preview_PopupView:OnActive()
  self.panel.cont_base_popup.scenemask.SceneMask:SetSceneMaskByKey(self.SceneMaskKey)
  local list = {}
  local reawardScrollRect = self.panel.cont_base_popup.loopscroll_reward_list.HLoopScrollRect
  local content = self.panel.cont_base_popup.node_reward_content
  local loopItem
  if self.viewData.award then
    for _, value in pairs(self.viewData.award) do
      list[#list + 1] = value
    end
    loopItem = comRewardItem
  else
    list = self.viewData.itemList
    loopItem = comRewardDetailItem
  end
  if list and content then
    if #list >= LEFT_ITEM_COUNT then
      content.Ref:SetPivot(0, 1)
    else
      content.Ref:SetPivot(0.5, 1)
    end
  end
  if not loopItem then
    return
  end
  self.rewardScrollRect = loopscrollrect.new(reawardScrollRect, self, loopItem)
  self.rewardScrollRect:SetData(list)
  self:AddAsyncClick(self.panel.cont_base_popup.btn_yes.btn_yes.Btn, function()
    Z.UIMgr:CloseView("reward_preview_popup")
  end)
  self.panel.cont_base_popup.lab_title.TMPLab.text = Lang(self.viewData.title)
  self.panel.cont_base_popup.lab_tips:SetVisible(false)
  self.panel.cont_base_popup.lab_content.TMPLab.text = ""
end

function Reward_Preview_PopupView:initInfoByAward()
end

function Reward_Preview_PopupView:OnDeActive()
end

function Reward_Preview_PopupView:OnRefresh()
end

return Reward_Preview_PopupView
