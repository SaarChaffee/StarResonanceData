local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_result_windowView = class("Gasha_result_windowView", super)
local animName = "gasha_result_item_show"
local animLoopName = "gasha_result_item_loop"
local openInterval = 0.8
local GashaCountType = {One = 1, Ten = 10}

function Gasha_result_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_result_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Gasha_result_windowView:OnActive()
  self:initComp()
  self.uiBinder.Ref:SetVisible(self.skip_root_, false)
  self.btn_close_.interactable = false
  self.isPlayingOver_ = false
  self:onAddListener()
  self:bindEvent()
  self.tipsIds_ = {}
  Z.UnrealSceneMgr:InitSceneCamera(false, true, true)
  self.modelTable_ = {}
  self:showHighQuility(false)
  Z.UnrealSceneMgr:SetNodeRenderColorByName("e_sky", false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_tips, false)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
end

function Gasha_result_windowView:initComp()
  self.btn_close_ = self.uiBinder.btn_close
  self.node_ten_ = self.uiBinder.node_ten
  self.node_bottom_ = self.uiBinder.node_bottom
  self.node_one_ = self.uiBinder.node_one
  self.btn_skip_ = self.uiBinder.btn_skip
  self.skip_root_ = self.uiBinder.skip_root
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

function Gasha_result_windowView:OnInputBack()
  if not self.isPlayingOver_ then
    return
  end
  self.gashaVm_.CloseGashaResultView()
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
  self.gasha_result_one_item_.btn_item_replace_tips:RemoveAllListeners()
  for i = 1, 10 do
    local uiBinder = self.gasha_result_ten_items_[i]
    uiBinder.btn_item_tips:RemoveAllListeners()
    uiBinder.btn_item_replace_tips:RemoveAllListeners()
  end
  self.isPlayingOver_ = false
  for index, value in ipairs(self.tipsIds_) do
    Z.TipsVM.CloseItemTipsView(value)
  end
  Z.UnrealSceneMgr:CloseUnrealScene("gasha_result_window")
  self.modelTable_ = nil
  self:resetItemBinder(self.gasha_result_one_item_)
  for k, v in pairs(self.gasha_result_ten_items_) do
    self:resetItemBinder(v)
  end
  self.uiBinder.anim:ClearAll()
  self.uiBinder.anim:ResetAniState("anim_gasha_result_window_open", 0)
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
  self.replaceItems_ = self.viewData.replaceItems
  self.gashaCount_ = #self.items_
  if self.items_ == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.node_bottom_, false)
  self.uiBinder.anim:CoroPlayOnce("anim_gasha_result_window_open", self.cancelSource:CreateToken(), function()
    self:showItems(self.items_)
  end, function(err)
    if err ~= nil then
      self.gashaVm_.CloseGashaResultView()
      logError("CoroPlay err={0}", err)
    end
  end)
end

function Gasha_result_windowView:getReplaceItem(index)
  if self.replaceItems_ == nil then
    return nil
  end
  if not self.replaceItems_[index - 1] then
    return nil
  end
  return self.replaceItems_[index - 1].items[1]
end

function Gasha_result_windowView:OnDestory()
end

function Gasha_result_windowView:showItems(items)
  if self.gashaCount_ == 0 then
    return
  end
  self:setItemsDepth()
  self.modelTable_ = {}
  if self.gashaCount_ == GashaCountType.One then
    self:showOneGashaModel(items[1])
  elseif self.gashaCount_ == GashaCountType.Ten then
    self:showTenGashaModel(items)
  end
end

function Gasha_result_windowView:showOneGashaModel(item)
  Z.CoroUtil.create_coro_xpcall(function()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(0.1, self.cancelSource:CreateToken())
    self:createGashaModel(Z.ConstValue.GashaModels[item.quality], self.gasha_result_one_item_, 0.7, Z.Global.GashaFlyInTimeForSingle, Z.Global.GashaDelayTimeForSingle)
    coro(1, self.cancelSource:CreateToken())
    self:showOneDrawItem(item)
  end)()
end

function Gasha_result_windowView:showTenGashaModel(items)
  Z.CoroUtil.create_coro_xpcall(function()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(0.1, self.cancelSource:CreateToken())
    for index, value in ipairs(items) do
      local timeIndex = self:getRandomFlyTimeIndex()
      self:createGashaModel(Z.ConstValue.GashaModels[value.quality], self.gasha_result_ten_items_[index], 0.45, Z.Global.GashaFlyInTime[timeIndex], Z.Global.GashaDelayTime[timeIndex])
    end
    coro(self:getFlyMaxTime(), self.cancelSource:CreateToken())
    self:showTenDrawItems(items)
  end)()
end

function Gasha_result_windowView:getRandomFlyTimeIndex()
  local count = table.zcount(Z.Global.GashaFlyInTime)
  local randomIndex = math.random(1, count)
  local maxLoopCount = 10
  while self.randomTable and self.randomTable[randomIndex] and self.randomTable[randomIndex] >= Z.Global.GashaFlySameTimeCount and 0 < maxLoopCount do
    randomIndex = math.random(1, count)
    maxLoopCount = maxLoopCount - 1
  end
  if not self.randomTable then
    self.randomTable = {}
  end
  if not self.randomTable[randomIndex] then
    self.randomTable[randomIndex] = 1
  else
    self.randomTable[randomIndex] = self.randomTable[randomIndex] + 1
  end
  return randomIndex
end

function Gasha_result_windowView:getFlyMaxTime()
  local maxTime = 0
  local count = table.zcount(Z.Global.GashaFlyInTime)
  for i = 1, count do
    maxTime = math.max(maxTime, Z.Global.GashaFlyInTime[i] + Z.Global.GashaDelayTime[i])
  end
  return maxTime
end

function Gasha_result_windowView:createGashaModel(modelPath, posUnit, scale, flyTime, delayTime)
  local parentTran = Z.UnrealSceneMgr:GetGOByBinderName("gasha_root").transform
  if parentTran == nil then
    return
  end
  local modelPos = self:getModelPosition(posUnit)
  local go = Z.UnrealSceneMgr:LoadScenePrefab(modelPath, parentTran, Vector3.New(0, 0, 0), self.cancelSource:CreateToken())
  if go == nil then
    return
  end
  Z.UnrealSceneMgr:ChangeLoadPrefabScale(go, scale, scale, scale)
  Z.UnrealSceneMgr:ChangeLoadPrefabRotation(go, 0, 0, 0)
  local gashaModelComp = Panda.ZUi.ZUnrealSceneGashaModel.GetZUnrealGashaComp(go)
  if gashaModelComp == nil then
    return
  end
  if not self.flyInTrans then
    self.flyInTrans = Z.UnrealSceneMgr:GetGOByBinderName("fly_in")
  end
  if self.flyInTrans then
    gashaModelComp:SetWorldPosition(modelPos, self.flyInTrans.transform.position, true, flyTime, delayTime)
  else
    gashaModelComp:SetWorldPosition(modelPos, modelPos)
  end
  if gashaModelComp ~= nil then
    table.insert(self.modelTable_, gashaModelComp)
  end
end

function Gasha_result_windowView:getModelPosition(unit)
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(unit.Trans.position)
  local cameraPosition = Z.CameraMgr.MainCamera.transform.position
  screenPosition.z = Z.NumTools.Distance(cameraPosition, pos)
  local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(screenPosition)
  return worldPosition
end

function Gasha_result_windowView:showOneDrawItem(item)
  self.uiBinder.Ref:SetVisible(self.skip_root_, false)
  self.uiBinder.Ref:SetVisible(self.node_one_, true)
  self.uiBinder.Ref:SetVisible(self.node_ten_, false)
  self:showItem(item, self:getReplaceItem(1), self.gasha_result_one_item_)
  self:playSingleItem(item)
end

function Gasha_result_windowView:showTenDrawItems(items)
  self.uiBinder.Ref:SetVisible(self.skip_root_, true)
  self.uiBinder.Ref:SetVisible(self.node_one_, false)
  self.uiBinder.Ref:SetVisible(self.node_ten_, true)
  for index, value in ipairs(items) do
    self:showItem(value, self:getReplaceItem(index), self.gasha_result_ten_items_[index])
  end
  self:playMultipleItems(items)
end

function Gasha_result_windowView:showItem(item, replaceItem, uiBinder)
  local itemId = item.uuid
  local configId = item.configId
  local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if itemConfig == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(configId))
  local colorTag = "ItemQuality_" .. itemConfig.Quality
  local nameText = itemConfig.Name
  if item.count > 1 then
    nameText = Lang("ItemNameWithCount", {
      name = itemConfig.Name,
      count = item.count
    })
  end
  uiBinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(nameText, colorTag)
  self:resetItemBinder(uiBinder)
  uiBinder.btn_item_tips.interactable = false
  uiBinder.btn_item_tips:RemoveAllListeners()
  self:AddClick(uiBinder.btn_item_tips, function()
    local tipsId = Z.TipsVM.ShowItemTipsView(uiBinder.Trans, configId, itemId)
    table.insert(self.tipsIds_, tipsId)
  end)
  uiBinder.btn_item_replace_tips.interactable = false
  uiBinder.btn_item_replace_tips:RemoveAllListeners()
  self:AddClick(uiBinder.btn_item_replace_tips, function()
    local tipsId = Z.TipsVM.ShowItemTipsView(uiBinder.Trans, configId, itemId)
    table.insert(self.tipsIds_, tipsId)
  end)
  uiBinder.Ref:SetVisible(uiBinder.img_label, false)
  uiBinder.Ref:SetVisible(uiBinder.lab_name_replace, false)
  uiBinder.Ref:SetVisible(uiBinder.rimg_icon_replace, false)
  if replaceItem ~= nil then
    local replaceItemconfigId = replaceItem.configId
    local replaceItemConfig = Z.TableMgr.GetRow("ItemTableMgr", replaceItemconfigId)
    if replaceItemConfig == nil then
      return
    end
    uiBinder.rimg_icon_replace:SetImage(itemsVM.GetItemIcon(replaceItemconfigId))
    local colorTag = "ItemQuality_" .. replaceItemConfig.Quality
    local nameText = replaceItemConfig.Name
    if replaceItem.count > 1 then
      nameText = Lang("ItemNameWithCount", {
        name = replaceItemConfig.Name,
        count = replaceItem.count
      })
    end
    uiBinder.lab_name_replace.text = Z.RichTextHelper.ApplyStyleTag(nameText, colorTag)
  end
end

function Gasha_result_windowView:playSingleItem(item)
  Z.CoroUtil.create_coro_xpcall(function()
    local uiBinder = self.gasha_result_one_item_
    self:playAnim(uiBinder, item, self:getReplaceItem(1), self.modelTable_[1], 0.2)
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
      self:playAnim(uiBinder, item, self:getReplaceItem(i), self.modelTable_[i], 0.2)
    end
    self:displayClose()
  end)()
end

function Gasha_result_windowView:playAnim(uiBinder, item, replaceItem, gashaModelComp, delayTime)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
  coro(delayTime, self.cancelSource:CreateToken())
  if item.quality == Z.ConstValue.GashaQuality.Golden or item.quality == Z.ConstValue.GashaQuality.AllGolden then
    self:playGoldAnim(uiBinder, item, replaceItem, gashaModelComp)
  else
    self:playNormalAnim(uiBinder, item, replaceItem, gashaModelComp)
  end
  uiBinder.btn_item_tips.interactable = true
  uiBinder.btn_item_replace_tips.interactable = true
end

function Gasha_result_windowView:playGoldAnim(uiBinder, item, replaceItem, gashaModelComp)
  Z.UIMgr:FadeIn({
    TimeOut = 1.5,
    EndCallback = function()
      Z.UIMgr:FadeOut({IsInstant = true})
      Z.UnrealSceneMgr:SetNodeRenderColorByName("e_sky", true)
      self.gashaVm_.OpenGashaHighQualityDetailView(self.gashaId_, item, replaceItem)
    end
  })
  self.canContinue_ = false
  self:showHighQuility(true)
  self:skipAnim(uiBinder, item, replaceItem, gashaModelComp)
  while not self.canContinue_ do
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(0.1, self.cancelSource:CreateToken())
  end
end

function Gasha_result_windowView:playNormalAnim(uiBinder, item, replaceItem, gashaModelComp)
  gashaModelComp:PlayOpenAnim(2, nil, nil)
  self:playEffect(uiBinder, item)
  uiBinder.anim:CoroPlayOnce(animName, self.cancelSource:CreateToken(), function()
    self:PlayReplaceItem(uiBinder, replaceItem)
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
  coro(openInterval, self.cancelSource:CreateToken())
end

function Gasha_result_windowView:PlayReplaceItem(uiBinder, replaceItem)
  if replaceItem == nil then
    return
  end
  self:playReplaceEff(uiBinder)
  uiBinder.Ref:SetVisible(uiBinder.img_label, true)
  uiBinder.anim:PlayLoop(animLoopName)
end

function Gasha_result_windowView:onGashaHighQualityDetailShowEnd()
  self:showHighQuility(false)
  Z.UnrealSceneMgr:SetNodeRenderColorByName("e_sky", false)
  self.canContinue_ = true
end

function Gasha_result_windowView:showHighQuility(isHighQuility)
  Z.UnrealSceneMgr:SetNodeActiveByName("gasha_root", not isHighQuility)
  Z.UnrealSceneMgr:SetNodeActiveByName("gasha_highquility_root", isHighQuility)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, not isHighQuility)
end

function Gasha_result_windowView:displayClose()
  self.btn_close_.interactable = true
  self.isPlayingOver_ = true
  self.uiBinder.Ref:SetVisible(self.node_bottom_, true)
  self.uiBinder.Ref:SetVisible(self.skip_root_, false)
  if table.zcount(self.replaceItems_) <= 0 then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_tips, true)
  local nameTable = {}
  for key, value in pairs(self.replaceItems_) do
    for k, v in pairs(value.items) do
      local configId = v.configId
      local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", configId)
      if itemConfig ~= nil then
        local colorTag = "ItemQuality_" .. itemConfig.Quality
        local nameText = itemConfig.Name
        if v.count > 1 then
          nameText = Lang("ItemNameWithCount", {
            name = itemConfig.Name,
            count = v.count
          })
        end
        nameText = Z.RichTextHelper.ApplyStyleTag(nameText, colorTag)
        table.insert(nameTable, nameText)
      end
    end
  end
  self.uiBinder.lab_tips.text = Lang("GashaResultReplaceItem", {
    val = table.concat(nameTable, Lang("Comma"))
  })
end

function Gasha_result_windowView:skip()
  self.cancelSource:CancelAll()
  self:displayClose()
  if self.gashaCount_ == GashaCountType.One then
    self:skipAnim(self.gasha_result_one_item_, self.items_[1], self:getReplaceItem(1), self.modelTable_[1])
  else
    for i = 1, GashaCountType.Ten do
      local item = self.items_[i]
      self:skipAnim(self.gasha_result_ten_items_[i], item, self:getReplaceItem(i), self.modelTable_[i])
    end
  end
end

function Gasha_result_windowView:skipAnim(uiBinder, item, replaceItem, gashaModelComp)
  gashaModelComp:SkipAnim()
  uiBinder.anim:Stop()
  uiBinder.anim:ResetAniState(animName, 1)
  uiBinder.btn_item_tips.interactable = true
  uiBinder.btn_item_replace_tips.interactable = true
  self:playEffect(uiBinder, item)
  self:PlayReplaceItem(uiBinder, replaceItem)
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
  uiBinder.uidepth:AddChildDepth(uiBinder.eff_replace)
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
    "UI_GashaResult_General",
    "UI_GashaResult_General",
    "UI_GashaResult_Purple"
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

function Gasha_result_windowView:playReplaceEff(uiBinder)
  uiBinder.eff_replace:SetEffectGoVisible(true)
  uiBinder.eff_replace:Play()
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
  uiBinder.eff_replace:SetEffectGoVisible(false)
  uiBinder.anim:ResetAniState(animLoopName, 0)
  uiBinder.anim:ResetAniState(animName, 0)
  uiBinder.anim:Stop()
  uiBinder.Ref:SetVisible(uiBinder.img_label, false)
end

return Gasha_result_windowView
