local super = require("ui.component.loop_grid_view_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local UnionHuntRankItem = class("UnionHuntRankItem", super)

function UnionHuntRankItem:OnInit()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.view_ = self.parent.UIView
end

function UnionHuntRankItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_player_name.text = self.data_.charName
  local rankNum = self.data_.rankIdx
  local showRankImg = rankNum <= 3
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_ranking_bg, showRankImg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_ranking_num, not showRankImg)
  if showRankImg then
    self.uiBinder.img_ranking_bg:SetImage("ui/atlas/union_active/union_active_ranking_" .. rankNum)
  else
    self.uiBinder.lab_ranking_num.text = rankNum
  end
  local bgNum = math.min(4, rankNum)
  self.uiBinder.img_frame:SetImage("ui/atlas/union_active/union_active_ranking_bg_" .. bgNum)
  self.uiBinder.lab_active_num.text = self.data_.value
  self:RefreshColor()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncRefreshSelfHead()
  end)()
end

function UnionHuntRankItem:asyncRefreshSelfHead()
  local socialVm = Z.VMMgr.GetVM("social")
  local data_ = self:GetCurData()
  local charId_ = data_.charId
  local socialData = socialVm.AsyncGetHeadAndHeadFrameInfo(charId_, self.parent.UIView.cancelSource:CreateToken())
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, socialData)
  self.uiBinder.binder_head.img_bg:AddListener(Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(charId_, self.parent.UIView.cancelSource:CreateToken())
  end, nil))
end

function UnionHuntRankItem:RefreshColor()
  local c1, c2, c3 = self.view_:GetItemColorByIndex(self.data_.rankIdx)
  self.uiBinder.img_bg.color = c1
  self.uiBinder.rimg_decorate.color = c2
end

function UnionHuntRankItem:OnUnInit()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
end

return UnionHuntRankItem
