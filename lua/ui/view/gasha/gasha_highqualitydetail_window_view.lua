local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_highqualitydetail_windowView = class("Gasha_highqualitydetail_windowView", super)

function Gasha_highqualitydetail_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_highqualitydetail_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
end

function Gasha_highqualitydetail_windowView:OnActive()
  Z.AudioMgr:Play("UI_GashaResult_Gold")
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
  self.gasha_result_item_.uidepth:RemoveChildDepth(self.gasha_result_item_.eff_ui_start)
  self.gasha_result_item_.uidepth:RemoveChildDepth(self.gasha_result_item_.eff_ui_start1)
  self.gasha_result_item_.uidepth:RemoveChildDepth(self.gasha_result_item_.eff_ui_loop)
  self.uidepth_:RemoveChildDepth(self.gasha_result_item_.uidepth)
end

function Gasha_highqualitydetail_windowView:OnRefresh()
  self.isPlayingOver_ = false
  self.gashaId_ = self.viewData.gashaId
  self.item_ = self.viewData.item
  self.hasReplace_ = self.viewData.hasReplace
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
  self.gasha_result_item_.rimg_icon:SetImage(itemsVM.GetItemLargeIcon(configId))
  self.gasha_result_item_.anim:ResetAniState("gasha_result_item_show_texie", 0)
  self.gasha_result_item_.Ref:SetVisible(self.gasha_result_item_.rimg_icon, false)
  self.gasha_result_item_.eff_ui_start:SetEffectGoVisible(false)
  self.gasha_result_item_.eff_ui_start1:SetEffectGoVisible(false)
  self.gasha_result_item_.eff_ui_loop:SetEffectGoVisible(false)
  self.gasha_result_item_.lab_name.text = itemConfig.Name
  self.gasha_result_item_.Ref:SetVisible(self.gasha_result_item_.img_label, false)
  self.uidepth_:AddChildDepth(self.gasha_result_item_.uidepth)
  self.gasha_result_item_.uidepth:AddChildDepth(self.gasha_result_item_.eff_ui_start)
  self.gasha_result_item_.uidepth:AddChildDepth(self.gasha_result_item_.eff_ui_start1)
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
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
  coro(0.1, self.cancelSource:CreateToken())
  local parentTran = Z.UnrealSceneMgr:GetGOByBinderName("gasha_highquility_root").transform
  local modelPos = self:getModelPosition(self.uiBinder.gasha_result_one_item)
  local go = Z.UnrealSceneMgr:LoadScenePrefab(Z.ConstValue.GashaModels[self.item_.quality], parentTran, Vector3.New(0, 0, 0), self.cancelSource:CreateToken())
  Z.UnrealSceneMgr:ChangeLoadPrefabScale(go, 0.7, 0.7, 0.7)
  Z.UnrealSceneMgr:ChangeLoadPrefabRotation(go, 0, 0, 0)
  local gashaModelComp_ = Panda.ZUi.ZUnrealSceneGashaModel.GetZUnrealGashaComp(go)
  gashaModelComp_:SetWorldPosition(modelPos, modelPos)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
  coro(0.1, self.cancelSource:CreateToken())
  gashaModelComp_:PlayOpenAnim(1, nil, nil)
  coro(0.3, self.cancelSource:CreateToken())
  self.gasha_result_item_.eff_ui_loop:SetEffectGoVisible(true)
  self.gasha_result_item_.eff_ui_loop:Play()
  if self.item_.quality > Z.ConstValue.GashaQuality.Golden then
    self.gasha_result_item_.eff_ui_start1:SetEffectGoVisible(true)
    self.gasha_result_item_.eff_ui_start1:Play()
  else
    self.gasha_result_item_.eff_ui_start:SetEffectGoVisible(true)
    self.gasha_result_item_.eff_ui_start:Play()
  end
  local asyncCall = Z.CoroUtil.async_to_sync(self.gasha_result_item_.anim.CoroPlayOnce)
  asyncCall(self.gasha_result_item_.anim, "gasha_result_item_show_texie", self.cancelSource:CreateToken())
  self.gasha_result_item_.btn_item_tips.interactable = true
  self.isPlayingOver_ = true
  self.gasha_result_item_.Ref:SetVisible(self.gasha_result_item_.img_label, self.hasReplace_)
end

function Gasha_highqualitydetail_windowView:getModelPosition(unit)
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(unit.Trans.position)
  local cameraPosition = Z.CameraMgr.MainCamera.transform.position
  screenPosition.z = Z.NumTools.Distance(cameraPosition, pos)
  local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(screenPosition)
  return worldPosition
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
