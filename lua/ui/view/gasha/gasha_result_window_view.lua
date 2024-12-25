local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_result_windowView = class("Gasha_result_windowView", super)
local animName = "gasha_result_item_show"
local GashaCountType = {One = 1, Ten = 10}
local GashaQuality = {
  White = 1,
  Purple = 2,
  Golden = 3
}

function Gasha_result_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_result_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Gasha_result_windowView:OnActive()
  self:initComp()
  self.btn_close_.interactable = false
  self.isPlayingOver_ = false
  self:onAddListener()
  self:bindEvent()
  self.tipsIds_ = {}
end

function Gasha_result_windowView:initComp()
  self.btn_close_ = self.uiBinder.btn_close
  self.node_ten_ = self.uiBinder.node_ten
  self.node_bottom_ = self.uiBinder.node_bottom
  self.node_one_ = self.uiBinder.node_one
  self.btn_skip_ = self.uiBinder.btn_skip
  self.gasha_result_one_item_ = self.uiBinder.gasha_result_one_item
  self.uidepth_ = self.uiBinder.uidepth
  self.gasha_result_ten_items_ = {
    self.uiBinder.gasha_result_ten_item_0,
    self.uiBinder.gasha_result_ten_item_1,
    self.uiBinder.gasha_result_ten_item_2,
    self.uiBinder.gasha_result_ten_item_3,
    self.uiBinder.gasha_result_ten_item_4,
    self.uiBinder.gasha_result_ten_item_5,
    self.uiBinder.gasha_result_ten_item_6,
    self.uiBinder.gasha_result_ten_item_7,
    self.uiBinder.gasha_result_ten_item_8,
    self.uiBinder.gasha_result_ten_item_9
  }
end

function Gasha_result_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Gasha.GashaHighQualityDetailShowEnd, self.onGashaHighQualityDetailShowEnd, self)
end

function Gasha_result_windowView:onAddListener()
  self:AddClick(self.btn_close_, function()
    if not self.isPlayingOver_ then
      return
    end
    self.gashaVm_.CloseGashaResultView()
  end)
  self:AddClick(self.btn_skip_, function()
    self:skip()
  end)
end

function Gasha_result_windowView:OnDeActive()
  self.gasha_result_one_item_.btn_item_tips:RemoveAllListeners()
  for i = 1, 10 do
    local uiBinder = self.gasha_result_ten_items_[i]
    uiBinder.btn_item_tips:RemoveAllListeners()
  end
  self.isPlayingOver_ = false
  for index, value in ipairs(self.tipsIds_) do
    Z.TipsVM.CloseItemTipsView(value)
  end
end

function Gasha_result_windowView:OnRefresh()
  self.isPlayingOver_ = false
  self.btn_close_.interactable = false
  if self.viewData == nil then
    return
  end
  self.canContinue_ = true
  self.gashaId_ = self.viewData.gashaId
  self.items_ = self.viewData.items
  self.gashaCount_ = #self.items_
  if self.items_ == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.node_bottom_, false)
  self:showItems(self.items_)
end

function Gasha_result_windowView:showItems(items)
  if self.gashaCount_ == 0 then
    return
  end
  self:setItemsDepth()
  if self.gashaCount_ == GashaCountType.One then
    self:showOneDrawItem(items[1])
  elseif self.gashaCount_ == GashaCountType.Ten then
    self:showTenDrawItems(items)
  end
end

function Gasha_result_windowView:showOneDrawItem(item)
  self.uiBinder.Ref:SetVisible(self.btn_skip_, false)
  self.uiBinder.Ref:SetVisible(self.node_one_, true)
  self.uiBinder.Ref:SetVisible(self.node_ten_, false)
  self:showItem(item, self.gasha_result_one_item_)
  self:playSingleItem(item)
end

function Gasha_result_windowView:showTenDrawItems(items)
  self.uiBinder.Ref:SetVisible(self.btn_skip_, true)
  self.uiBinder.Ref:SetVisible(self.node_one_, false)
  self.uiBinder.Ref:SetVisible(self.node_ten_, true)
  for index, value in ipairs(items) do
    self:showItem(value, self.gasha_result_ten_items_[index])
  end
  self:playMultipleItems(items)
end

function Gasha_result_windowView:showItem(item, uiBinder)
  local itemId = item.uuid
  local configId = item.configId
  local quality = item.quality
  local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if itemConfig == nil then
    return
  end
  uiBinder.tanim_gasha:SetAnimation(tostring(quality))
  uiBinder.tanim_gasha:PauseAnimation()
  local itemsVM = Z.VMMgr.GetVM("items")
  uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(configId))
  local colorTag = "ItemQuality_" .. itemConfig.Quality
  uiBinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(Lang("ItemNameWithCount", {
    name = itemConfig.Name,
    count = item.count
  }), colorTag)
  self:resetItemBinder(uiBinder)
  uiBinder.btn_item_tips.interactable = false
  uiBinder.btn_item_tips:RemoveAllListeners()
  self:AddClick(uiBinder.btn_item_tips, function()
    local tipsId = Z.TipsVM.ShowItemTipsView(uiBinder.Trans, configId, itemId)
    table.insert(self.tipsIds_, tipsId)
  end)
end

function Gasha_result_windowView:playSingleItem(item)
  Z.CoroUtil.create_coro_xpcall(function()
    local uiBinder = self.gasha_result_one_item_
    self:playAnim(uiBinder, item, 0.2)
    self:displayClose()
  end)()
end

function Gasha_result_windowView:playMultipleItems(items)
  Z.CoroUtil.create_coro_xpcall(function()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(0.5, self.cancelSource:CreateToken())
    for i = 1, GashaCountType.Ten do
      local item = items[i]
      local uiBinder = self.gasha_result_ten_items_[i]
      self:playAnim(uiBinder, item, 0.2)
    end
    self:displayClose()
  end)()
end

function Gasha_result_windowView:playAnim(uiBinder, item, delayTime)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
  coro(delayTime, self.cancelSource:CreateToken())
  if item.quality == GashaQuality.Golden then
    self:playGoldAnim(uiBinder, item)
  else
    self:playNormalAnim(uiBinder, item)
  end
  uiBinder.btn_item_tips.interactable = true
end

function Gasha_result_windowView:playGoldAnim(uiBinder, item)
  self.canContinue_ = false
  self.gashaVm_.OpenGashaHighQualityDetailView(self.gashaId_, item)
  while not self.canContinue_ do
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(0.1, self.cancelSource:CreateToken())
  end
  self:skipAnim(uiBinder, item)
end

function Gasha_result_windowView:playNormalAnim(uiBinder, item)
  self:playEffect(uiBinder, item)
  uiBinder.tanim_gasha:ResumeAnimation()
  local asyncCall = Z.CoroUtil.async_to_sync(uiBinder.anim.CoroPlayOnce)
  asyncCall(uiBinder.anim, animName, self.cancelSource:CreateToken())
end

function Gasha_result_windowView:onGashaHighQualityDetailShowEnd()
  self.canContinue_ = true
end

function Gasha_result_windowView:displayClose()
  self.btn_close_.interactable = true
  self.isPlayingOver_ = true
  self.uiBinder.Ref:SetVisible(self.node_bottom_, true)
  self.uiBinder.Ref:SetVisible(self.btn_skip_, false)
end

function Gasha_result_windowView:skip()
  self.cancelSource:CancelAll()
  self:displayClose()
  if self.gashaCount_ == GashaCountType.One then
    self:skipAnim(self.gasha_result_one_item_, self.items_[1])
  else
    for i = 1, GashaCountType.Ten do
      local item = self.items_[i]
      self:skipAnim(self.gasha_result_ten_items_[i], item)
    end
  end
end

function Gasha_result_windowView:skipAnim(uiBinder, item)
  uiBinder.anim:Stop()
  uiBinder.anim:ResetAniState(animName, 1)
  uiBinder.btn_item_tips.interactable = true
  self:playEffect(uiBinder, item)
end

function Gasha_result_windowView:setItemsDepth()
  if self.gashaCount_ == GashaCountType.One then
    self:setItemDepth(self.gasha_result_one_item_)
  else
    for i = 1, GashaCountType.Ten do
      self:setItemDepth(self.gasha_result_ten_items_[i])
    end
  end
end

function Gasha_result_windowView:setItemDepth(uiBinder)
  self.uidepth_:AddChildDepth(uiBinder.uidepth)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_white_start)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_purple_start)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_golden_start)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_white_loop)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_purple_loop)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_golden_loop)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_blue_start)
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_blue_loop)
end

function Gasha_result_windowView:playEffect(uiBinder, item)
  local configId = item.configId
  local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if itemConfig == nil then
    return
  end
  local quality = itemConfig.Quality
  local eff_start = {
    uiBinder.eff_white_start,
    uiBinder.eff_blue_start,
    uiBinder.eff_purple_start,
    uiBinder.eff_golden_start
  }
  local eff_loop = {
    uiBinder.eff_white_loop,
    uiBinder.eff_blue_loop,
    uiBinder.eff_purple_loop,
    uiBinder.eff_golden_loop
  }
  local audio = {
    "sfx_treasure_general",
    "sfx_treasure_general",
    "sfx_treasure_gold"
  }
  if 4 < quality then
    quality = 4
  end
  if quality < 1 then
    quality = 1
  end
  eff_start[quality]:SetEffectGoVisible(true)
  eff_loop[quality]:SetEffectGoVisible(true)
  eff_start[quality]:Play()
  eff_loop[quality]:Play()
  if quality ~= 4 then
    Z.AudioMgr:Play(audio[quality])
  end
end

function Gasha_result_windowView:resetItemBinder(uiBinder)
  uiBinder.eff_white_start:SetEffectGoVisible(false)
  uiBinder.eff_purple_start:SetEffectGoVisible(false)
  uiBinder.eff_golden_start:SetEffectGoVisible(false)
  uiBinder.eff_white_loop:SetEffectGoVisible(false)
  uiBinder.eff_purple_loop:SetEffectGoVisible(false)
  uiBinder.eff_golden_loop:SetEffectGoVisible(false)
  uiBinder.eff_blue_start:SetEffectGoVisible(false)
  uiBinder.eff_blue_loop:SetEffectGoVisible(false)
  uiBinder.anim:ResetAniState(animName, 0)
end

return Gasha_result_windowView
