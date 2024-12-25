local super = require("ui.component.loop_grid_view_item")
local ComRewardsWindowItem = class("ComRewardsWindowItem", super)
local itemQuality2Effect = {
  [0] = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit_white",
  [1] = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit_green",
  [2] = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit_blue",
  [3] = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit_purple",
  [4] = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit_yellow",
  [5] = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit_red"
}
local itemShowInterval = 0
local item = require("common.item_binder")

function ComRewardsWindowItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.com_item_square
  })
end

function ComRewardsWindowItem:OnUnInit()
  self.itemClass_:UnInit()
end

function ComRewardsWindowItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_root, false)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.configId,
    uuid = data.uuid,
    lab = data.count,
    itemInfo = data.itemInfo
  }
  self.itemClass_:RefreshByData(itemData)
  local interval = self.Index > 12 and 0 or (self.Index - 1) * itemShowInterval
  self.playedAnim = self.parent.UIView.itemAnimEnd
  if self.playedAnim then
    interval = 0
  end
  self.playEffect = self.Index <= 12
  Z.CoroUtil.create_coro_xpcall(function()
    self:Show(interval)
  end)()
end

function ComRewardsWindowItem:Show(interval)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
  coro(interval, self.parent.UIView.cancelSource:CreateToken())
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_root, true)
  if self.playedAnim then
    return
  end
  if not self.playEffect then
    return
  end
  self.playedAnim = true
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.data_.configId)
  if itemConfig == nil then
    return
  end
  Z.AudioMgr:Play("UI_Event_ItemGet_S")
  local quality = itemConfig.Quality
  self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:CreatEFFGO(itemQuality2Effect[quality], Vector3.zero)
  self.uiBinder.node_effect:SetEffectGoVisible(true)
  coro(1, self.parent.UIView.cancelSource:CreateToken())
  self.uiBinder.node_effect:ReleseEffGo()
end

return ComRewardsWindowItem
