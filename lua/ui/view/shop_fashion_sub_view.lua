local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_fashion_subView = class("shop_fashion_subView", super)
local loopListView = require("ui.component.loop_list_view")
local tog2_Item = require("ui.component.shop.shop_tog2_loop_item")
E.EShopSubViewType = {
  EFashion = 1,
  EFashionGift = 2,
  EWeapon = 3,
  EMount = 4,
  EFace = 5
}
E.EShopModelType = {
  EPlayer = 1,
  EPlayerWeapon = 2,
  EMount = 3
}

function Shop_fashion_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "shop_fashion_sub", "shop/shop_fashion_sub", UI.ECacheLv.None, true)
end

function Shop_fashion_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onStartAnimShow()
  self:initVMData()
  self:initActionDict()
  self:initFunc()
  self:refreshWorldPosition()
  self:HideVideo()
  self:initSubViewList()
  self:initSecondShopList()
  self:bindEvent()
end

function Shop_fashion_subView:OnDeActive()
  self.ESCInputFunction_ = nil
  self.secondListView_:UnInit()
  if self.curShopView_ then
    self.curShopView_:DeActive()
    self.curShopView_ = nil
  end
  self.fashionData_:ClearWearDict()
  self:clearPlayerModel()
  self:clearMountModel()
  self:unBindEvent()
end

function Shop_fashion_subView:initVMData()
  self.shopData_ = Z.DataMgr.Get("shop_data")
  if self.viewData.isClick then
    self.shopData_:InitShopBuyItemInfoList()
  end
  self.settingVM_ = Z.VMMgr.GetVM("fashion_setting")
  self.weaponSkillSkinVm_ = Z.VMMgr.GetVM("weapon_skill_skin")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local curProfessionId = weaponVm.GetCurWeapon()
  self.equipWeaponSkinId_ = self.weaponSkillSkinVm_:GetWeaponSkinId(curProfessionId)
  self.curWearSetting_ = self.settingVM_.GetCurFashionSettingRegionDict()
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.fashionData_:ClearWearDict()
end

function Shop_fashion_subView:initActionDict()
  self.actionDict_ = {}
  self.actionVM_:InitModelActionInfo(self.actionDict_, Z.Global.FashionShowActionM, Z.Global.FashionShowActionF)
end

function Shop_fashion_subView:initSubViewList()
  self.shopFashionPartView_ = require("ui.view.shop_fashion_part_view").new(self)
  self.shopFashionGiftView_ = require("ui.view.shop_fashion_gift_view").new(self)
  self.shopFashionWeaponView_ = require("ui.view.shop_fashion_weapon_view").new(self)
  self.shopFashionMountView_ = require("ui.view.shop_fashion_mount_view").new(self)
  self.shopFashionFaceView_ = require("ui.view.shop_fashion_face_view").new(self)
  self.subViewList_ = {
    [E.EShopSubViewType.EFashion] = {
      view = self.shopFashionPartView_,
      modelType = E.EShopModelType.EPlayer
    },
    [E.EShopSubViewType.EFashionGift] = {
      view = self.shopFashionGiftView_,
      modelType = E.EShopModelType.EPlayer
    },
    [E.EShopSubViewType.EWeapon] = {
      view = self.shopFashionWeaponView_,
      modelType = E.EShopModelType.EPlayerWeapon
    },
    [E.EShopSubViewType.EMount] = {
      view = self.shopFashionMountView_,
      modelType = E.EShopModelType.EMount
    },
    [E.EShopSubViewType.EFace] = {
      view = self.shopFashionFaceView_,
      modelType = E.EShopModelType.EPlayer
    }
  }
end

function Shop_fashion_subView:initFunc()
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    self:onModelDrag(eventData)
  end)
  self:AddClick(self.uiBinder.btn_play, function()
    self:PlayVideo()
  end)
  self:AddClick(self.uiBinder.btn_clost_video, function()
    self:CloseVideo()
  end)
  self:AddClick(self.uiBinder.btn_show, function()
    self:PlayVideo()
  end)
  self.uiBinder.group_video:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
  end, function()
    self:CloseVideo()
  end, function()
    self:CloseVideo()
  end)
  
  function self.activeESCInput_()
    self:CloseVideo()
  end
end

function Shop_fashion_subView:initSecondShopList()
  self.secondListView_ = loopListView.new(self, self.uiBinder.loop_second, tog2_Item, "shop_fashion_tog_tpl", true)
  self.secondListView_:Init(self.viewData.shopTabData.secondaryTabList)
  if self.viewData.secondIndex then
    self.secondListView_:SetSelected(self.viewData.secondIndex)
    self.viewData.secondIndex = nil
    self.viewData.parentView.viewData.secondIndex = nil
  else
    self.secondListView_:SetSelected(1)
  end
end

function Shop_fashion_subView:Tog2Click(data, index, isClick)
  local subViewType = data.SubViewType[1] or E.EShopSubViewType.EFashion
  if self.subViewList_[subViewType] and self.subViewList_[subViewType].view then
    if self.curShopView_ then
      self.curShopView_:DeActive()
    end
    local viewData = {
      shopData = self.viewData.shopData,
      mallTableRow = data,
      threeTabList = self.viewData.shopTabData.threeTabList,
      parentView = self,
      threeIndex = self.viewData.threeIndex,
      shopItemIndex = self.viewData.shopItemIndex,
      configId = self.viewData.configId
    }
    self.curShopView_ = self.subViewList_[subViewType].view
    self.curShopView_:Active(viewData, self.uiBinder.node_parent)
    self.viewData.configId = nil
    self:CheckModelChange(self.subViewList_[subViewType].modelType)
  end
  if isClick then
    self.viewData.parentView:SetSecondIndex(index)
    self.viewData.parentView:SetThreeIndex(nil)
    self.viewData.parentView:SetShopItemIndex(nil)
  end
end

function Shop_fashion_subView:CheckModelChange(modelType)
  if modelType == E.EShopModelType.EPlayer then
    self:showPlayerModel()
    self:hidePlayerWeaponModel()
    self:clearMountModel()
  elseif modelType == E.EShopModelType.EPlayerWeapon then
    self:showPlayerModel()
    self:ShowPlayerWeaponModel()
    self:clearMountModel()
  else
    self:hidePlayerModel()
    self:hidePlayerWeaponModel()
  end
end

function Shop_fashion_subView:RefreshData()
  if self.curShopView_ then
    self.curShopView_:ClearSelectItemList()
    self.curShopView_:RefreshData(self.viewData.shopData)
  end
end

function Shop_fashion_subView:refreshWorldPosition()
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local playerScreenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.uiBinder.node_player_position.position)
  local playerNewScreenPos = Vector3.New(playerScreenPosition.x, playerScreenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos) - 0.8)
  self.playerWorldPosition_ = Z.CameraMgr.MainCamera:ScreenToWorldPoint(playerNewScreenPos)
  local mountScreenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.uiBinder.node_mount_position.position)
  local mountNewScreenPos = Vector3.New(mountScreenPosition.x, mountScreenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos))
  self.mountWorldPosition_ = Z.CameraMgr.MainCamera:ScreenToWorldPoint(mountNewScreenPos)
end

function Shop_fashion_subView:onModelDrag(eventData)
  if self.showPlayerModel_ then
    self:onPlayerModelDrag(eventData)
  else
    self:onMountModelDrag(eventData)
  end
end

function Shop_fashion_subView:showPlayerModel()
  if not self.playerModel_ then
    self:initPlayerModel()
  else
    self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelRenderInvisible, false)
    Z.ModelHelper.SetRenderLayerMaskByRenderType(self.playerModel_, Z.ZRenderingLayerUtils.RENDERING_LAYER_MASK_DEFAULT, Z.ModelRenderMask.All)
  end
  self.showPlayerModel_ = true
end

function Shop_fashion_subView:hidePlayerModel()
  if not self.playerModel_ then
    return
  end
  self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelRenderInvisible, true)
  Z.ModelHelper.SetRenderLayerMaskByRenderType(self.playerModel_, Z.ZRenderingLayerUtils.RENDERING_LAYER_MASK_INVISIBLE, Z.ModelRenderMask.All)
  self.showPlayerModel_ = false
end

function Shop_fashion_subView:ShowPlayerWeaponModel(weaponSkilId)
  weaponSkilId = weaponSkilId or self.shopData_:GetShopBuyItemWeaponFashionId()
  if weaponSkilId then
    self:setLuaIntModelAttr(Z.ModelAttr.EModelDisplayWeaponSkinId, weaponSkilId)
  else
    self:setLuaIntModelAttr(Z.ModelAttr.EModelDisplayWeaponSkinId, self.equipWeaponSkinId_)
  end
end

function Shop_fashion_subView:hidePlayerWeaponModel()
  self:setLuaIntModelAttr(Z.ModelAttr.EModelDisplayWeaponSkinId, 0)
end

function Shop_fashion_subView:setLuaIntModelAttr(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  self.playerModel_:SetLuaIntAttr(attrType, table.unpack(arg))
end

function Shop_fashion_subView:initPlayerModel()
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local rate = rootCanvas.localScale.x / 0.00925
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    local faceData = Z.DataMgr.Get("face_data")
    local curRotation = Z.ConstValue.FaceGenderRotation[faceData:GetPlayerGender()]
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, curRotation, 0)))
    model:SetAttrGoPosition(self.playerWorldPosition_)
    local modelScale = model:GetLuaAttrGoScale()
    model:SetLuaAttrGoScale(modelScale * rate)
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    model:SetLuaAttrLookAtEnable(true)
    local faceVM = Z.VMMgr.GetVM("face")
    local actionData = faceVM.GetDefaultActionData()
    local actionVM = Z.VMMgr.GetVM("action")
    actionVM:PlayAction(model, actionData)
  end, function(model)
    local fashionVm = Z.VMMgr.GetVM("fashion")
    fashionVm.SetModelAutoLookatCamera(model)
  end)
end

function Shop_fashion_subView:onPlayerModelDrag(eventData)
  if not self.playerModel_ then
    return
  end
  local rotation = self.playerModel_:GetAttrGoRotation()
  if not rotation then
    return
  end
  local curShowModelRotation = rotation.eulerAngles
  curShowModelRotation.y = curShowModelRotation.y - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(curShowModelRotation))
end

function Shop_fashion_subView:ResetPlayer()
  if not self.playerModel_ then
    return
  end
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
end

function Shop_fashion_subView:clearPlayerModel()
  if not self.playerModel_ then
    return
  end
  Z.UnrealSceneMgr:ClearModel(self.playerModel_)
  self.playerModel_ = nil
end

function Shop_fashion_subView:RefreshPlayerModelAction(fashionId)
  if not self.showPlayerModel_ then
    return
  end
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId, true)
  if not fashionRow then
    return
  end
  local actionInfo = self.actionDict_[fashionRow.Type] or 0
  if actionInfo and 0 < actionInfo.actionId then
    if self.curRegionActionId_ and self.curRegionActionId_ == actionInfo.actionId then
      return
    end
    self.curRegionActionId_ = actionInfo.actionId
    self.actionVM_:PlayAction(self.playerModel_, actionInfo)
  end
end

function Shop_fashion_subView:RefreshWearSetting()
  if not self.playerModel_ then
    return
  end
  local setting = {}
  for type, isHide in pairs(self.curWearSetting_) do
    setting[type] = isHide
  end
  local fashionData = Z.TableMgr.GetTable("FashionTableMgr")
  for _, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      local row = fashionData.GetRow(data.mallItemRow.ItemId, true)
      if row then
        setting[row.Type] = 1
      end
    end
  end
  local settingStr = self.settingVM_.RegionDictToSettingStr(setting)
  self.playerModel_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
end

function Shop_fashion_subView:RefreshMountModel(mallItemId)
  local selectConfig = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(mallItemId, true)
  if not selectConfig then
    return
  end
  local vehicleActionPreviewConfig = Z.TableMgr.GetTable("VehicleActionPreviewTableMgr").GetRow(selectConfig.Id, true)
  if not vehicleActionPreviewConfig then
    return
  end
  self.mountModel_ = Z.UnrealSceneMgr:GenModelByLua(self.mountModel_, selectConfig.ModelID, function(model)
    local rotation = Quaternion.Euler(Vector3.New(0, -134.7, 0))
    model:SetAttrGoRotation(rotation)
    model:SetAttrGoPosition(self.mountWorldPosition_)
    model:SetLuaAttrGoScale(vehicleActionPreviewConfig.UIModelScale)
    if vehicleActionPreviewConfig then
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(vehicleActionPreviewConfig.IdleAction))
    end
  end)
end

function Shop_fashion_subView:clearMountModel()
  if self.mountModel_ then
    Z.UnrealSceneMgr:ClearModel(self.mountModel_)
    self.mountModel_ = nil
  end
end

function Shop_fashion_subView:onMountModelDrag(eventData)
  if not self.mountModel_ then
    return
  end
  local rotation = self.mountModel_:GetAttrGoRotation()
  if not rotation then
    return
  end
  local curShowModelRotation = rotation.eulerAngles
  curShowModelRotation.y = curShowModelRotation.y - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self.mountModel_:SetAttrGoRotation(Quaternion.Euler(curShowModelRotation))
end

function Shop_fashion_subView:ShowVideo(videoName)
  self.curVideoName_ = videoName .. ".mp4"
  local array = string.split(videoName, "/")
  if not array then
    return
  end
  self.audioName = array[#array]
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_show, true)
  self:PlayVideo()
end

function Shop_fashion_subView:HideVideo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_show, false)
  self:CloseVideo()
end

function Shop_fashion_subView:PlayVideo()
  self.viewData.parentView:SetEscInputFuction(function()
    self:CloseVideo()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close_new, true)
  self.uiBinder.group_video:Prepare(self.curVideoName_, false, true)
  self:PlayVideoAudio()
end

function Shop_fashion_subView:CloseVideo()
  self.viewData.parentView:SetEscInputFuction(nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close_new, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, false)
  self.uiBinder.group_video:Stop()
  self:StopVideoAudio()
end

function Shop_fashion_subView:PlayVideoAudio(goodsVideo)
  if self.audioName then
    Z.AudioMgr:Play(self.audioName)
    Z.AudioMgr:PlayBGM(string.zconcat("BGM_", self.audioName))
    Z.AudioMgr:PlayBGM("BGM_System")
  end
end

function Shop_fashion_subView:StopVideoAudio()
  if self.audioName then
    Z.AudioMgr:StopSound(self.audioName, nil, 0.5)
    Z.AudioMgr:PlayBGM("BGM_Sys_Shop_End")
  end
end

function Shop_fashion_subView:RigestTimerCall(key, func)
  self.viewData.parentView:RigestTimerCall(key, func)
end

function Shop_fashion_subView:UnrigestTimerCall(key)
  self.viewData.parentView:UnrigestTimerCall(key)
end

function Shop_fashion_subView:UpdateProp()
  self.viewData.parentView:UpdateProp()
end

function Shop_fashion_subView:onFashionAttrChange(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  self:setAllModelAttr("SetLuaAttr", attrType, table.unpack(arg))
end

function Shop_fashion_subView:setAllModelAttr(funcName, ...)
  local arg = {
    ...
  }
  self.playerModel_[funcName](self.playerModel_, table.unpack(arg))
end

function Shop_fashion_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
end

function Shop_fashion_subView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
end

function Shop_fashion_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_fashion_subView
