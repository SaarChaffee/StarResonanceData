local super = require("ui.ui_view_base")
local BattlePass_buy_permitView = class("BattlePass_buy_permitView", super)
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
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
  Z.UnrealSceneMgr:InitSceneCamera()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:SwicthVirtualStyle(E.UnrealSceneSlantingLightStyle.Turquoise)
  Z.UnrealSceneMgr:AsyncSetBackGround(E.SeasonUnRealBgPath.Scene)
  self:initWidgets()
  self:initParam()
  self:bindWatchers()
  self:startAnimationShow()
end

function BattlePass_buy_permitView:OnDeActive()
  self:removeShowAwardItem()
  self:unBindWatchers()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
end

function BattlePass_buy_permitView:onInitModel()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.Delay(0.1, ZUtil.ZCancelSource.NeverCancelToken)
    local rootCanvas = Z.UIRoot.RootCanvas.transform
    local rate = rootCanvas.localScale.x / 0.00925
    local pos = Z.UnrealSceneMgr:GetTransPos("pos")
    pos.x = pos.x - 1.5
    local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.model_node.position)
    local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos))
    local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
    self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetAttrGoPosition(worldPosition)
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 165, 0)))
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
      local modelScale = model:GetLuaAttrGoScale()
      model:SetLuaAttrGoScale(modelScale * rate)
    end)
  end)()
end

function BattlePass_buy_permitView:OnRefresh()
  self:setViewInfo()
  self:setPayBtnState()
  self:initAwardItem()
end

function BattlePass_buy_permitView:bindWatchers()
  function self.battlePassDataUpDateFunc_(container, dirtys)
    if dirtys and (dirtys.buyNormalPas or dirtys.buyPrimePass) then
      self:setPayBtnState()
    end
  end
  
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:RegWatcher(self.battlePassDataUpDateFunc_)
end

function BattlePass_buy_permitView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:UnregWatcher(self.battlePassDataUpDateFunc_)
  self.battlePassDataUpDateFunc_ = nil
end

function BattlePass_buy_permitView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("battle_pass_buy")
end

function BattlePass_buy_permitView:initParam()
  self.battlePassContainer_ = self.battlePassVM_.GetBattlePassContainer()
  self.battlePassInfo_ = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassContainer_.id)
  self.payInfo_ = self.battlePassVM_.GetBattlePassPayId(self.battlePassContainer_.id)
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
    if self.battlePassContainer_.buyNormalPas then
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
  self.fashion_name_lab.text = self.battlePassVM_.GetFashionName(self.battlePassContainer_.id)
  self.lab_normal_name_.text = self.battlePassInfo_.NormalPassName
  self.lab_pro_name_.text = self.battlePassInfo_.PrimePassName
end

function BattlePass_buy_permitView:setPayBtnState()
  if not (self.payInfo_ and next(self.payInfo_)) or not self.battlePassContainer_ then
    return
  end
  self.money_lab_1.text = self.payInfo_.normalPayInfo.Price
  self.money_lab_2.text = self.payInfo_.primePayInfo.Price
  if self.battlePassContainer_.buyNormalPas and not self.battlePassContainer_.buyPrimePass then
    self.money_lab_2.text = self.payInfo_.discountPayInfo.Price
  end
  self.pay_btn_1.interactable = not self.battlePassContainer_.buyNormalPas or not self.battlePassContainer_.buyPrimePass
  self.pay_btn_1.IsDisabled = self.battlePassContainer_.buyNormalPas or self.battlePassContainer_.buyPrimePass
  self.pay_btn_2.interactable = not self.battlePassContainer_.buyPrimePass
  self.pay_btn_2.IsDisabled = self.battlePassContainer_.buyPrimePass
  self.uiBinder.Ref:SetVisible(self.money_lab_1, self.battlePassContainer_.buyNormalPas ~= true and self.battlePassContainer_.buyPrimePass ~= true)
  self.uiBinder.Ref:SetVisible(self.money_lab_2, not self.battlePassContainer_.buyPrimePass)
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
  self.battlePassVM_.AsyncPayment(payId)
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

function BattlePass_buy_permitView:initFashion(model)
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

function BattlePass_buy_permitView:startAnimationShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_collection_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_perfection_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.nood_perfection_eff_loop)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.nood_collection_eff_icon)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.nood_perfection_eff_icon)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  local cancelSourceToken = self.cancelSource:CreateToken()
  self.uiBinder.anim:CoroPlayOnce("anim_bpcard_buy_permit_window", cancelSourceToken, function()
    self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
    self.uiBinder.nood_perfection_eff_loop:SetEffectGoVisible(true)
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

return BattlePass_buy_permitView
