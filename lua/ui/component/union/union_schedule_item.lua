local UnionScheduleItem = class("UnionScheduleItem")

function UnionScheduleItem:ctor()
end

function UnionScheduleItem:Init(viewParent, uiBinder, param)
  self.allTagItemDict_ = {}
  self.allTagConfigDict_ = {}
  self.view_ = viewParent
  self.uiBinder = uiBinder
  self.param_ = param
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self:SetUI()
end

function UnionScheduleItem:UnInit()
  Z.UIMgr:CloseView("tips_item_reward_popup")
  self.view_ = nil
  self.uiBinder = nil
  self.param_ = nil
  self.unionVM_ = nil
end

function UnionScheduleItem:SetUI()
  self.uiBinder.lab_schedule_num.text = self.param_.scoreNum
  self.uiBinder.btn_item:AddListener(function()
    self:OnItemClick()
  end)
end

function UnionScheduleItem:SetRootPos(posX, posY)
  self.uiBinder.Trans:SetAnchorPosition(posX, posY)
end

function UnionScheduleItem:SetState(scoreNum, isReceive)
  local isScoreEnough = scoreNum >= self.param_.scoreNum
  self.isScoreEnough = isScoreEnough
  self.isReceive = isReceive
  self:SetVisible(self.uiBinder.img_unselected, not isScoreEnough)
  self:SetVisible(self.uiBinder.img_selected, isScoreEnough)
  self:SetVisible(self.uiBinder.node_finish_icon, isScoreEnough)
  self:SetVisible(self.uiBinder.img_receive, isReceive)
  self:SetVisible(self.uiBinder.img_red, isScoreEnough and not isReceive)
end

function UnionScheduleItem:OnItemClick()
  if self.isScoreEnough and not self.isReceive then
    self.view_:SendGetUnionHuntAward(self.param_.scoreNum)
  else
    local viewData = {
      AwardId = self.param_.awardID,
      ParentTrans = self.uiBinder.btn_item.transform
    }
    Z.UIMgr:OpenView("tips_item_reward_popup", viewData)
  end
end

function UnionScheduleItem:SetVisible(comp, isVisible)
  self.uiBinder.Ref:SetVisible(comp, isVisible)
end

return UnionScheduleItem
