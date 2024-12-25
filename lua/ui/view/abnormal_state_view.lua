local UI = Z.UI
local super = require("ui.ui_subview_base")
local Abnormal_stateView = class("Abnormal_stateView", super)
local ShowBuffCountMax = 3
local loop_list_view = require("ui.component.loop_list_view")
local buff_item = require("ui.component.buff.buff_item")

function Abnormal_stateView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "abnormal_state", "abnormal/abnormal_state", UI.ECacheLv.None)
end

function Abnormal_stateView:OnActive()
  self.buffDataList_ = {}
  self.buffList_ = loop_list_view.new(self, self.uiBinder.node_buff_list, buff_item, "battle_icon_buff_tpl_new")
  self.buffList_:Init({})
  self:BindLuaAttrWatchers()
  if self.viewData.viewType == E.AbnormalPanelType.Boss then
    self.uiBinder.node_buff_tips:SetLocalPos(90, -193, 0)
  else
    self.uiBinder.node_buff_tips:SetLocalPos(75, 36, 0)
  end
end

function Abnormal_stateView:OnRefresh()
  self:refreshBuffList()
end

function Abnormal_stateView:OnDeActive()
  if self.buffList_ then
    self.buffList_:UnInit()
    self.buffList_ = nil
  end
end

function Abnormal_stateView:getShowEntity()
  local entity
  if self.viewData.viewType == E.AbnormalPanelType.Boss then
    local bossUuid = Z.VMMgr.GetVM("bossbattle").GetBossUuid()
    if not bossUuid then
      return
    end
    entity = Z.EntityMgr:GetEntity(bossUuid)
  elseif self.viewData.viewType == E.AbnormalPanelType.Self then
    entity = Z.EntityMgr.PlayerEnt
  end
  return entity
end

function Abnormal_stateView:BindLuaAttrWatchers()
  local entity = self:getShowEntity()
  if not entity then
    return
  end
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EShowBuffList
  }, entity, self.refreshBuffList, true)
end

function Abnormal_stateView:UnBindLuaAttrWatchers()
  self:UnBindAllWatchers()
end

function Abnormal_stateView:refreshBuffList()
  if not self.buffList_ then
    return
  end
  local entity = self:getShowEntity()
  local buffVm = Z.VMMgr.GetVM("buff")
  self.buffDataList_ = buffVm.GetEntityBuffList(entity, ShowBuffCountMax, E.EBuffPriority.NotShow)
  if not self.buffDataList_ then
    self.buffDataList_ = {}
  end
  self.buffList_:RefreshListView(self.buffDataList_, false)
  Z.EventMgr:Dispatch(Z.ConstValue.Buff.BuffDataRefresh, self.buffDataList_, self.viewData.viewType)
end

function Abnormal_stateView:OnClickBuff(buffData)
  if self.viewData.viewType == E.AbnormalPanelType.Boss then
    self:openBuffTips({buffData})
  else
    self:openBuffTips(self.buffDataList_)
  end
end

function Abnormal_stateView:openBuffTips(buffDataList)
  Z.UIMgr:OpenView("tips_battle_buff_popup", {
    buffList = buffDataList,
    position = self.uiBinder.node_buff_tips.position,
    type = self.viewData.viewType
  })
end

return Abnormal_stateView
