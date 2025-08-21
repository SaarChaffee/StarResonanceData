local super = require("ui.ui_view_base")
local BattlePass_buy_permitView = class("BattlePass_buy_permitView", super)
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local loopScrollRect_ = require("ui.component.loop_grid_view")
local battle_pass_privileges_item = require("ui/component/battle_pass/battle_pass_privileges_item")
local itemClass = require("common.item_binder")
local BattlePassAwardTypeEnum = {
  Normal = 1,
  PayNow = 2,
  PayLevel = 3
}

function BattlePass_buy_permitView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "battle_pass_buy")
end

function BattlePass_buy_permitView:OnActive()
  Z.AudioMgr:Play("UI_Event_BP_Show")
  self:onStartAnimShow()
  Z.UnrealSceneMgr:InitSceneCamera()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.paymentData_ = Z.DataMgr.Get("payment_data")
  self.paymentVm_ = Z.VMMgr.GetVM("payment")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:SwicthVirtualStyle(E.UnrealSceneSlantingLightStyle.Turquoise)
  Z.UnrealSceneMgr:AsyncSetBackGround(E.SeasonUnRealBgPath.Scene)
  Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.52, 0.5))
  Z.UnrealSceneMgr:DoCameraAnim("battlePassCardFocusBoby")
  self:onInitModel()
  self:initWidgets()
  self:initParam()
  self:bindWatchers()
  self:initView()
end

function BattlePass_buy_permitView:initView()
  if Z.IsPCUI then
    self.battlePassLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_gird_privileges, battle_pass_privileges_item, "bpcard_privilege_tpl_pc")
  else
    self.battlePassLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_gird_privileges, battle_pass_privileges_item, "bpcard_privilege_tpl")
  end
  self.battlePassLoopScrollRect_:Init({})
  self:refreshLoopScrollRect()
end

function BattlePass_buy_permitView:refreshLoopScrollRect()
  local privilegesData = self.battlePassVM_.GetBpCardPrivilegesData(self.battlePassData_.CurBattlePassData.id)
  if not self.battlePassLoopScrollRect_ or table.zcount(privilegesData) <= 0 then
    return
  end
  self.battlePassLoopScrollRect_:RefreshListView(privilegesData)
end

function BattlePass_buy_permitView:OnDeActive()
  self.battlePassLoopScrollRect_:UnInit()
  self.battlePassLoopScrollRect_ = nil
  self:removeShowAwardItem()
  self:unBindWatchers()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
end

function BattlePass_buy_permitView:OnRefresh()
  self:setViewInfo()
  self:setPayBtnState()
  self:initAwardItem()
end

function BattlePass_buy_permitView:bindWatchers()
  Z.EventMgr:Add(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
end

function BattlePass_buy_permitView:onBattlePassDataUpDateFunc(dirtyTable)
  if dirtyTable.buyNormalPas or dirtyTable.buyPrimePass then
    self:setPayBtnState()
  end
end

function BattlePass_buy_permitView:unBindWatchers()
  Z.EventMgr:Remove(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
end

function BattlePass_buy_permitView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("battle_pass_buy")
end

function BattlePass_buy_permitView:initParam()
  self.battlePassInfo_ = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassData_.CurBattlePassData.id)
  self.payInfo_ = self.battlePassVM_.GetBattlePassPayId(self.battlePassData_.CurBattlePassData.id)
  self.itemUnit_ = {}
  self.itemClassTab_ = {}
end

function BattlePass_buy_permitView:initWidgets()
  self.money_lab_1 = self.uiBinder.lab_title_1
  self.money_lab_2 = self.uiBinder.lab_title_2
  self.pay_btn_1 = self.uiBinder.btn_round_1
  self.pay_btn_2 = self.uiBinder.btn_round_2
  self.btn_close = self.uiBinder.cont_btn_close
  self.get_lab = self.uiBinder.lab_bug_get
  self.fashion_name_lab = self.uiBinder.lab_name
  self.lab_up = self.uiBinder.lab_up
  self.prefabcache_root = self.uiBinder.prefabcache_root
  self.normal_layout = self.uiBinder.layout_normal_content
  self.pay_top_layout = self.uiBinder.layout_pay_top_content
  self.pay_bottom_layout = self.uiBinder.layout_pay_bottom_content
  self.model_node = self.uiBinder.node_model_position
  self.unrealSceneDrag_node = self.uiBinder.rayimg_unrealscene_drag
  self.lab_normal_name_ = self.uiBinder.lab_bpcard_name_normal
  self.lab_pro_name_ = self.uiBinder.lab_bpcard_name_pro
  self:AddClick(self.btn_close, function()
    self.battlePassVM_.CloseBattlePassBuyView()
  end)
  self:AddAsyncClick(self.pay_btn_1, function()
    self:payBtnClick(E.EBattlePassPurchaseType.Normal)
  end)
  self:AddAsyncClick(self.pay_btn_2, function()
    if self.battlePassData_.CurBattlePassData.buyNormalPas then
      self:payBtnClick(E.EBattlePassPurchaseType.Discount)
    else
      self:payBtnClick(E.EBattlePassPurchaseType.Super)
    end
  end)
  self.unrealSceneDrag_node.onDrag:AddListener(function(go, eventData)
    self:onModelDrag(eventData)
  end)
end

function BattlePass_buy_permitView:setViewInfo()
  self.lab_up.text = Lang("primepassextralevel", {
    val = self.battlePassInfo_.PrimePassAddLevel
  })
  self.fashion_name_lab.text = self.battlePassVM_.GetFashionName(self.battlePassData_.CurBattlePassData.id)
  self.lab_normal_name_.text = self.battlePassInfo_.NormalPassName
  self.lab_pro_name_.text = self.battlePassInfo_.PrimePassName
  self.uiBinder.lab_normal_return.text = Lang("BpCardReturn", {
    val = self.battlePassInfo_.PassRoi[1]
  })
  self.uiBinder.lab_perfection_return.text = Lang("BpCardReturn", {
    val = self.battlePassInfo_.PassRoi[2]
  })
  local passPicture = string.split(self.battlePassInfo_.PassPicture, "=")
  self.uiBinder.img_icon_normal:SetImage(passPicture[3])
  self.uiBinder.img_icon_noble:SetImage(passPicture[4])
  self.uiBinder.rimg_bg_normal:SetImage(passPicture[5])
  self.uiBinder.rimg_bg_noble:SetImage(passPicture[6])
end

function BattlePass_buy_permitView:setPayBtnState()
  if not (self.payInfo_ and next(self.payInfo_)) or table.zcount(self.battlePassData_.CurBattlePassData) == 0 then
    return
  end
  local curBattleData = self.battlePassData_.CurBattlePassData
  local normalProductId = self.paymentData_:GetProdctsName(self.payInfo_.normalPayInfo.Id)
  local primePayData = self.payInfo_.primePayInfo
  if curBattleData.buyNormalPas and not curBattleData.buyPrimePass then
    primePayData = self.payInfo_.discountPayInfo
  end
  local primeProductId = self.paymentData_:GetProdctsName(primePayData.Id)
  local prodctionId = {normalProductId, primeProductId}
  local priceNumber = {
    self.payInfo_.normalPayInfo.Price,
    primePayData.Price
  }
  local textGroup = {
    self.money_lab_1,
    self.money_lab_2
  }
  self:setPrice(prodctionId, priceNumber, textGroup)
  self.pay_btn_1.interactable = not curBattleData.buyNormalPas and not curBattleData.buyPrimePass
  self.pay_btn_1.IsDisabled = curBattleData.buyNormalPas or curBattleData.buyPrimePass
  self.pay_btn_2.interactable = not curBattleData.buyPrimePass
  self.pay_btn_2.IsDisabled = curBattleData.buyPrimePass
end

function BattlePass_buy_permitView:setPrice(serverProductIds, priceNumber, showTextLab)
  self.paymentVm_:GetProductionInfos(serverProductIds, function(data)
    local currencySymbol = self.shopVm_.GetShopItemCurrencySymbol()
    local showPrice = {}
    if data ~= nil then
      for index, value in ipairs(serverProductIds) do
        if data[index] == nil then
          showPrice[index] = currencySymbol .. priceNumber[index]
        else
          showPrice[index] = data[index].DisplayPrice
        end
      end
    else
      for index, value in ipairs(priceNumber) do
        showPrice[index] = currencySymbol .. value[index]
      end
    end
    for index, value in ipairs(showTextLab) do
      value.text = showPrice[index]
    end
  end)
end

function BattlePass_buy_permitView:payBtnClick(payType)
  if not self.payInfo_ or not next(self.payInfo_) then
    logError("Battle pass pay info is null!")
    return
  end
  local payId = self.payInfo_.normalPayInfo.Id
  if payType == E.EBattlePassPurchaseType.Normal then
    payId = self.payInfo_.normalPayInfo.Id
  elseif payType == E.EBattlePassPurchaseType.Super then
    payId = self.payInfo_.primePayInfo.Id
  else
    payId = self.payInfo_.discountPayInfo.Id
  end
  self.paymentVm_:AsyncPayment(self.paymentVm_:GetPayType(), payId)
end

function BattlePass_buy_permitView:onModelDrag(eventData)
  if not self.playerModel_ then
    return
  end
  local curShowModelRotation = self.playerModel_:GetAttrGoRotation().eulerAngles
  curShowModelRotation.y = curShowModelRotation.y - eventData.delta.x
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(curShowModelRotation))
end

function BattlePass_buy_permitView:initAwardItem()
  self:loadAwardUnit(self.battlePassInfo_.AwardPreview, self.normal_layout, BattlePassAwardTypeEnum.Normal)
  self:loadAwardUnit(self.battlePassInfo_.AwardPreview, self.pay_bottom_layout, BattlePassAwardTypeEnum.PayLevel)
  self:loadAwardUnit(self.battlePassInfo_.PrimeExtraAward, self.pay_top_layout, BattlePassAwardTypeEnum.PayNow)
end

function BattlePass_buy_permitView:loadAwardUnit(awards, rootTrans, awardType)
  if awards == nil or #awards < 1 then
    return
  end
  local awardInfo = awardPreviewVm.GetAllAwardPreListByIds(awards)
  local itemPath = self:GetPrefabCacheData("itemPath")
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(awardInfo) do
      self.cancelToken_ = self.cancelSource:CreateToken()
      local name = string.format("contentAwardItem_%s_%s", awardType, k)
      local item = self:AsyncLoadUiUnit(itemPath, name, rootTrans, self.cancelToken_)
      self:initItemData(item, rootTrans, name, v)
    end
  end)()
end

function BattlePass_buy_permitView:initItemData(item, rootTrans, name, awardData)
  item.event_triggle_temp:SetScrollRect(rootTrans)
  item.event_triggle_temp.onBeginDrag:AddListener(function(go, eventData)
    item.btn_temp.interactable = false
  end)
  item.event_triggle_temp.onDrag:AddListener(function(go, eventData)
    item.btn_temp.interactable = false
  end)
  item.event_triggle_temp.onEndDrag:AddListener(function(go, eventData)
    item.btn_temp.interactable = true
  end)
  table.insert(self.itemUnit_, name)
  local data = awardData
  self.itemClassTab_[name] = itemClass.new(self)
  local itemData = {
    uiBinder = item,
    configId = data.awardId,
    isSquareItem = true,
    PrevDropType = data.PrevDropType,
    isClickOpenTips = true,
    isShowReceive = false,
    isSquareItem = true
  }
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
  self.itemClassTab_[name]:Init(itemData)
  self.itemClassTab_[name]:SetRedDot(false)
end

function BattlePass_buy_permitView:removeShowAwardItem()
  for _, v in pairs(self.itemUnit_) do
    self:RemoveUiUnit(v)
  end
  for _, item in pairs(self.itemClassTab_) do
    item:UnInit()
  end
  self.itemClassTab_ = {}
  self.itemUnit_ = {}
end

function BattlePass_buy_permitView:GetPrefabCacheData(path)
  if self.prefabcache_root == nil then
    return nil
  end
  return self.prefabcache_root:GetString(path)
end

function BattlePass_buy_permitView:onInitModel()
  local clipName = ""
  if Z.ContainerMgr.CharSerialize.charBase.gender == Z.PbEnum("EGender", "GenderMale") then
    clipName = "as_m_base_emo_bowl"
  else
    clipName = "as_f_base_emo_goodbyef"
  end
  Z.CoroUtil.create_coro_xpcall(function()
    Z.Delay(0.1, ZUtil.ZCancelSource.NeverCancelToken)
    local rootCanvas = Z.UIRoot.RootCanvas.transform
    local rate = rootCanvas.localScale.x / 0.00925
    local pos = Z.UnrealSceneMgr:GetTransPos("pos")
    self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetLuaAttr(Z.ModelAttr.EModelAnimOverrideByName, Z.AnimBaseData.Rent(clipName, Panda.ZAnim.EAnimBase.EIdle))
      model:SetAttrGoPosition(pos)
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
      model:SetLuaAttrLookAtEnable(true)
      local modelScale = model:GetLuaAttrGoScale()
      model:SetLuaAttrGoScale(modelScale * rate)
      self:initFashion(model)
    end, function(model)
      local fashionVm = Z.VMMgr.GetVM("fashion")
      fashionVm.SetModelAutoLookatCamera(model)
    end)
  end)()
end

function BattlePass_buy_permitView:initFashion(model)
  self.fashionZlist_ = self.battlePassVM_.SetPlayerFashion(self.battlePassData_.CurBattlePassData.id)
  if not self.fashionZlist_ then
    return
  end
  self:setAllModelAttr(model, "SetLuaAttr", Z.LocalAttr.EWearFashion, table.unpack({
    self.fashionZlist_
  }))
  self.fashionZlist_:Recycle()
  self.fashionZlist_ = nil
end

function BattlePass_buy_permitView:setAllModelAttr(model, funcName, ...)
  local arg = {
    ...
  }
  model[funcName](model, table.unpack(arg))
end

function BattlePass_buy_permitView:initFashion(model)
  self.fashionZlist_ = self.battlePassVM_.SetPlayerFashion(self.battlePassData_.CurBattlePassData.id)
  if not self.fashionZlist_ then
    return
  end
  self:setAllModelAttr(model, "SetLuaAttr", Z.LocalAttr.EWearFashion, table.unpack({
    self.fashionZlist_
  }))
  self.fashionZlist_:Recycle()
  self.fashionZlist_ = nil
end

function BattlePass_buy_permitView:onStartAnimShow()
  self.uiBinder.anim:PlayOnce("anim_bpcard_buy_permit_window")
end

return BattlePass_buy_permitView
