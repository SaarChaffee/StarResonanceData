local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_highqualitydetail_windowView = class("Gasha_highqualitydetail_windowView", super)

function Gasha_highqualitydetail_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_highqualitydetail_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
end

function Gasha_highqualitydetail_windowView:OnActive()
  Z.AudioMgr:Play("sfx_treasure_gorgeous")
  self:initComp()
  self:onAddListener()
end

function Gasha_highqualitydetail_windowView:initComp()
  self.btn_close_ = self.uiBinder.btn_close
  self.node_bottom_ = self.uiBinder.node_bottom
  self.uidepth_ = self.uiBinder.uidepth
  self.gasha_result_item_ = self.uiBinder.gasha_result_one_item
end

function Gasha_highqualitydetail_windowView:OnDeActive()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Gasha.GashaHighQualityDetailShowEnd)
end

function Gasha_highqualitydetail_windowView:OnRefresh()
  self.isPlayingOver_ = false
  self.gashaId_ = self.viewData.gashaId
  self.item_ = self.viewData.item
  self:refreshUi()
end

function Gasha_highqualitydetail_windowView:refreshUi()
  local itemId = self.item_.uuid
  local configId = self.item_.configId
  local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if itemConfig == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  self.gasha_result_item_.rimg_icon:SetImage(itemsVM.GetItemIcon(configId))
  self.gasha_result_item_.lab_name.text = itemConfig.Name
  self.uidepth_:AddChildDepth(self.gasha_result_item_.uidepth)
  self.gasha_result_item_.uidepth:AddChildDepth(self.gasha_result_item_.eff_ui_start)
  self.gasha_result_item_.uidepth:AddChildDepth(self.gasha_result_item_.eff_ui_loop)
  self.gasha_result_item_.btn_item_tips.interactable = false
  self.gasha_result_item_.btn_item_tips:RemoveAllListeners()
  self:AddClick(self.gasha_result_item_.btn_item_tips, function()
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.gasha_result_item_.Trans, configId, itemId)
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncPlay()
  end)()
end

function Gasha_highqualitydetail_windowView:asyncPlay()
  self.gasha_result_item_.tanim_gasha:SetAnimation("1")
  self.gasha_result_item_.eff_ui_start:SetEffectGoVisible(true)
  self.gasha_result_item_.eff_ui_loop:SetEffectGoVisible(true)
  self.gasha_result_item_.eff_ui_start:Play()
  self.gasha_result_item_.eff_ui_loop:Play()
  local asyncCall = Z.CoroUtil.async_to_sync(self.gasha_result_item_.anim.CoroPlayOnce)
  asyncCall(self.gasha_result_item_.anim, "gasha_result_item_show_texie", self.cancelSource:CreateToken())
  self.gasha_result_item_.btn_item_tips.interactable = true
  self.isPlayingOver_ = true
end

function Gasha_highqualitydetail_windowView:onAddListener()
  self:AddClick(self.btn_close_, function()
    if not self.isPlayingOver_ then
      return
    end
    self.gashaVm_.CloseGashaHighQualityDetailView()
  end)
end

return Gasha_highqualitydetail_windowView
