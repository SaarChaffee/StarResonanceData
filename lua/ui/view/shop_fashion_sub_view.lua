local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_fashion_subView = class("Shop_fashion_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local shop_loop_item = require("ui.component.season.season_shop_loop_item")
local labImgStr_ = "ui/atlas/shop/shop_lab_quality_%d"

function Shop_fashion_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_fashion_sub", "shop/shop_fashion_sub", UI.ECacheLv.None)
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
end

function Shop_fashion_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onStartAnimShow()
  self.IsFashionShop = true
  self.fashionData_:InitFashionData()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionLoopGridView_ = loopGridView.new(self, self.uiBinder.loop_fashion, shop_loop_item, "shop_item_8_tpl")
  self.fashionLoopGridView_:Init({})
  self.uiBinder.btn_reset:AddListener(function()
    if self.playerModel_ then
      self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    end
  end)
  self.uiBinder.btn_wardrobe:AddListener(function()
    local vm = Z.VMMgr.GetVM("fashion")
    vm.OpenFashionSystemView()
  end)
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    self:onModelDrag(eventData)
  end)
  self.actionDict_ = {}
  local glb = Z.Global
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self.actionVM_:InitModelActionInfo(self.actionDict_, glb.FashionShowActionM, glb.FashionShowActionF)
  self.settingVm_ = Z.VMMgr.GetVM("fashion_setting")
  self.curWearSetting_ = self.settingVm_.GetCurFashionSettingRegionDict()
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  local size = Z.ContainerMgr.CharSerialize.charBase.bodySize
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, size)
  local offset = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(modelId)
  Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusBody", Vector3.New(0, offset.y, 0))
  self:showModel()
  self:refreshData()
  self:asyncRefreshModelPosition()
end

function Shop_fashion_subView:OnDeActive()
  self:clearRefreshTimer()
  self.actionDict_ = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.EventMgr:Remove(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
  self:clearModel()
  self.curFashionId_ = nil
  self.worldPosition_ = nil
  self.curRegionActionId_ = nil
  self.fashionLoopGridView_:UnInit()
  self.fashionData_:ClearWearDict()
  Z.UnrealSceneMgr:HideCachePlayerModel()
end

function Shop_fashion_subView:OnRefresh()
end

function Shop_fashion_subView:showCost(cfg)
  local cost = 0
  for id, num in pairs(cfg.Cost) do
    cost = num
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      self.uiBinder.rimg_gold:SetImage(itemcfg.Icon)
    end
    break
  end
  if cost == 0 then
    cost = Lang("Free")
  end
  self.uiBinder.lab_digit.text = Z.NumTools.FormatNumberWithCommas(cost)
end

function Shop_fashion_subView:refreshCameraFocus(fashionId)
  self.curFashionId_ = fashionId
  if not self.playerModel_ or not self.curFashionId_ then
    return
  end
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if not fashionRow then
    return
  end
  self:refreshModelAction(fashionRow.Type)
  self:checkWearSetting(fashionRow.Type)
end

function Shop_fashion_subView:asyncRefreshModelPosition()
  self:clearRefreshTimer()
  self.refreshTimer = self.timerMgr:StartTimer(function()
    local pos = Z.UnrealSceneMgr:GetTransPos("pos")
    local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.uiBinder.node_model_position.position)
    local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos))
    self.worldPosition_ = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
    if self.playerModel_ then
      self.playerModel_:SetAttrGoPosition(self.worldPosition_)
    end
  end, 0.6)
end

function Shop_fashion_subView:clearRefreshTimer()
  if self.refreshTimer then
    self.refreshTimer:Stop()
    self.refreshTimer = nil
  end
end

function Shop_fashion_subView:refreshModelAction(resType)
  local actionInfo = self.actionDict_[resType] or 0
  if actionInfo and 0 < actionInfo.actionId then
    if self.curRegionActionId_ and self.curRegionActionId_ == actionInfo.actionId then
      return
    end
    self.curRegionActionId_ = actionInfo.actionId
    self.actionVM_:PlayAction(self.playerModel_, actionInfo)
  end
end

function Shop_fashion_subView:clearModel()
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
end

function Shop_fashion_subView:showModel()
  if not self.playerModel_ then
    self:createModel()
    return
  end
  if self.playerModel_ then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_UNREALSCENE)
  end
end

function Shop_fashion_subView:createModel()
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    if self.worldPosition_ then
      model:SetAttrGoPosition(self.worldPosition_)
    end
  end, function(model)
    self:refreshCameraFocus(self.curFashionId_)
    if self.curFashionId_ then
      self.fashionVM_.SetFashionWearByFashionId(self.curFashionId_)
    end
    if model and self.worldPosition_ then
      model:SetAttrGoPosition(self.worldPosition_)
    end
  end)
end

function Shop_fashion_subView:checkWearSetting(region)
  local setting = {}
  for type, isHide in pairs(self.curWearSetting_) do
    setting[type] = isHide
  end
  setting[region] = 1
  local settingStr = self.settingVm_.RegionDictToSettingStr(setting)
  self.playerModel_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
end

function Shop_fashion_subView:onModelDrag(eventData)
  if not self.playerModel_ then
    return
  end
  local curShowModelRotation = self.playerModel_:GetAttrGoRotation().eulerAngles
  curShowModelRotation.y = curShowModelRotation.y - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(curShowModelRotation))
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

function Shop_fashion_subView:OpenBuyPopup(data, index)
  local mallItemRow = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(mallItemRow.ItemId)
  if not mallItemRow or not itemRow then
    return
  end
  self.uiBinder.img_name_bg:SetImage(string.format(labImgStr_, itemRow.Quality))
  self.uiBinder.lab_name.text = itemRow.Name
  self.fashionVM_.RevertAllFashionWear()
  self.fashionVM_.SetFashionWearByFashionId(mallItemRow.ItemId)
  local uuId = self.fashionVM_.GetFashionUuid(mallItemRow.ItemId)
  if uuId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_wear, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_wear, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, true)
    self.uiBinder.btn_buy:AddListener(function()
      self.viewData.parentView:OpenBuyPopup(data, index, self.viewData.shopTabData.fristLevelTabData.Id)
    end)
  end
  self:showCost(data.cfg)
  self:refreshCameraFocus(mallItemRow.ItemId)
end

local sortFunc = function(left, right)
  local mallData = Z.TableMgr.GetTable("MallItemTableMgr")
  local leftData = mallData.GetRow(left.itemId)
  local rightData = mallData.GetRow(right.itemId)
  if not leftData or not rightData then
    return false
  end
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local leftHave = fashionVM.GetFashionUuid(leftData.ItemId)
  local rightHave = fashionVM.GetFashionUuid(rightData.ItemId)
  if leftHave then
    if rightHave then
      return leftData.Sort < rightData.Sort
    else
      return false
    end
  elseif rightHave then
    return true
  else
    return leftData.Sort < rightData.Sort
  end
end

function Shop_fashion_subView:refreshData()
  local showItemList = self:getShowData(E.MallType.EFashion)
  table.sort(showItemList, sortFunc)
  self.fashionLoopGridView_:ClearAllSelect()
  self.fashionLoopGridView_:RefreshListView(showItemList, false)
  self.fashionLoopGridView_:SetSelected(1)
end

function Shop_fashion_subView:SetSelected(Index)
  self.fashionLoopGridView_:SetSelected(Index)
end

function Shop_fashion_subView:getShowData(Id)
  for _, value in pairs(self.viewData.shopData) do
    if value.Id == Id then
      return value.items
    end
  end
end

function Shop_fashion_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_fashion_subView
