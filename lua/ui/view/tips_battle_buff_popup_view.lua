local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_battle_buff_popupView = class("Tips_battle_buff_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local buff_tips_item = require("ui.component.buff.buff_tips_item")

function Tips_battle_buff_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_battle_buff_popup")
end

function Tips_battle_buff_popupView:OnActive()
  if #self.viewData.buffList == 0 then
    Z.UIMgr:CloseView("tips_battle_buff_popup")
    return
  end
  self.buffList_ = self.viewData.buffList
  if self.viewData.type == E.AbnormalPanelType.Boss then
    self.uiBinder.node_buff:SetPivot(0.5, 1)
  else
    self.uiBinder.node_buff:SetPivot(0.5, 0)
  end
  self:refreshPosition()
  self.buffLoopList_ = loopListView.new(self, self.uiBinder.loop_buff, buff_tips_item, "tips_battle_buff_tpl")
  self.buffLoopList_:Init(self.buffList_)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      Z.UIMgr:CloseView("tips_battle_buff_popup")
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  Z.EventMgr:Add(Z.ConstValue.Buff.BuffDataRefresh, self.refreshData, self)
end

function Tips_battle_buff_popupView:OnDeActive()
  self.buffLoopList_:UnInit()
  self.uiBinder.presscheck:StopCheck()
  Z.EventMgr:Remove(Z.ConstValue.Buff.BuffDataRefresh, self.refreshData, self)
end

function Tips_battle_buff_popupView:refreshData(buffList, type)
  if self.viewData.type ~= type then
    return
  end
  if #buffList == 0 then
    Z.UIMgr:CloseView("tips_battle_buff_popup")
    return
  end
  self.buffList_ = buffList
  self:refreshPosition()
  self.buffLoopList_:RefreshListView(buffList, false)
end

function Tips_battle_buff_popupView:refreshPosition()
  local height = math.min(#self.buffList_ * 127, 400)
  self.uiBinder.node_buff:SetHeight(height)
  self.uiBinder.node_buff:SetWidth(407)
  self.uiBinder.node_buff:SetPos(self.viewData.position)
end

return Tips_battle_buff_popupView
