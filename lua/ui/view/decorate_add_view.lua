local UI = Z.UI
local super = require("ui.ui_subview_base")
local Decorate_addView = class("Decorate_addView", super)
local vm = Z.VMMgr.GetVM("camerasys")
local camerasysData = Z.DataMgr.Get("camerasys_data")
local decorateData = Z.DataMgr.Get("decorate_add_data")
local secondaryData = Z.DataMgr.Get("photo_secondary_data")
local iconPath = "ui/textures/photograph_decoration/stickers/"

function Decorate_addView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "decorate_add_sub", "photograph/decorate_add_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.decorates_ = {}
  self.decoratePool_ = {}
  self.decoratePoolIndex_ = 0
  self.stickerIndex_ = 0
  self.decorateLayerType_ = E.DecorateLayerType.CamerasysType
  self.addViewData_ = nil
  self.cameraData = Z.DataMgr.Get("camerasys_data")
end

function Decorate_addView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.event_chese_layer.onDown:AddListener(function()
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerDown)
    camerasysData.IsDecorateAddViewSliderShow = false
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetActionSliderHide, true)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_cont, false)
  self.uiBinder.slider_pellucidity.value = 0
  self.uiBinder.slider_pellucidity:AddListener(function()
    local valueData = {}
    valueData.value = self.uiBinder.slider_pellucidity.value
    self:camerasysHyalinerSet(valueData)
  end)
  if self.viewData and next(self.viewData) then
    if self.viewData.viewType == E.DecorateLayerType.AlbumType then
      self.decorateLayerType_ = E.DecorateLayerType.AlbumType
    else
      self.decorateLayerType_ = E.DecorateLayerType.CamerasysType
    end
  else
    self.decorateLayerType_ = E.DecorateLayerType.CamerasysType
  end
  if self.decorateLayerType_ == E.DecorateLayerType.CamerasysType then
    self.addViewData_ = decorateData
  else
    self.addViewData_ = secondaryData
  end
  self:BindEvents()
  self:SetCheseLayerState(false)
end

function Decorate_addView:OnDeActive()
  self:UnBindEvents()
  self.addViewData_ = nil
  camerasysData.IsDecorateAddViewSliderShow = false
  camerasysData.ActiveItem = nil
  self.decorateLayerType_ = E.DecorateLayerType.CamerasysType
  self.decorates_ = {}
  self.decoratePool_ = {}
  self.decoratePoolIndex_ = 0
  self.stickerIndex_ = 0
end

function Decorate_addView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.CreateDecorate, self.CreateDecorate, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateLayerDown, self.CamerasysDecorateLayerDown, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateDeActive, self.camerasysDecorateDeActive, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateTextCreate, self.camerasysDecorateTextCreate, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.AllDecorateVisible, self.setAllDecorateVisible, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.TextSizeGet, self.getTextSize, self)
end

function Decorate_addView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.CreateDecorate, self.CreateDecorate, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateLayerDown, self.CamerasysDecorateLayerDown, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateDeActive, self.camerasysDecorateDeActive, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateTextCreate, self.camerasysDecorateTextCreate, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.AllDecorateVisible, self.setAllDecorateVisible, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.TextSizeGet, self.getTextSize, self)
end

function Decorate_addView:camerasysHyalinerSet(valueData)
  if not camerasysData.ActiveItem then
    return
  end
  local color = camerasysData.ActiveItem.lab_input.color
  color.a = valueData.value
  camerasysData.ActiveItem.lab_input.color = color
  camerasysData.ActiveItem.rimg_decorate_icon:SetColor(Color.New(1, 1, 1, valueData.value))
  self.addViewData_:GetDecorateData(camerasysData.ActiveItem).transparency = valueData.value
end

function Decorate_addView:camerasysDecorateTextCreate(valueData)
  if valueData.viewType ~= self.decorateLayerType_ then
    return
  end
  local dataValue = {}
  dataValue.value = valueData.value
  dataValue.type = E.CamerasysFuncType.Text
  dataValue.viewType = valueData.viewType
  if valueData.type == E.CameraTextViewType.Create then
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.CreateDecorate, dataValue)
  else
    if not camerasysData.ActiveItem then
      return
    end
    self.addViewData_:GetDecorateData(camerasysData.ActiveItem).textValue = valueData.value
    camerasysData.ActiveItem.lab_input.text = valueData.value
  end
end

function Decorate_addView:OnRefresh()
  if self.viewData and next(self.viewData) then
    if self.viewData.viewType == E.DecorateLayerType.AlbumType then
      self.decorateLayerType_ = E.DecorateLayerType.AlbumType
    else
      self.decorateLayerType_ = E.DecorateLayerType.CamerasysType
    end
  else
    self.decorateLayerType_ = E.DecorateLayerType.CamerasysType
  end
  if self.decorateLayerType_ == E.DecorateLayerType.CamerasysType then
    self.addViewData_ = decorateData
  else
    self.addViewData_ = secondaryData
    self.addViewData_:SetDecorateData(self.viewData.decorateData.decorateData)
    self:ReductionDecorate(self.viewData.decorateData.decorateData)
  end
end

function Decorate_addView:CamerasysDecorateLayerDown()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_cont, false)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
  self:SetCheseLayerState(false)
end

function Decorate_addView:camerasysDecorateDeActive(valueData)
  if not camerasysData.ActiveItem then
    return
  end
  self:setFrameVisible(camerasysData.ActiveItem, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_cont, false)
  if not valueData then
    camerasysData.ActiveItem = nil
  end
end

function Decorate_addView:CreateDecorate(cfgdata)
  if cfgdata.viewType ~= self.decorateLayerType_ then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
  local valueData = {}
  valueData.isShow = false
  valueData.value = 1
  self:camerasysDoodleSliderSet(valueData)
  Z.CoroUtil.create_coro_xpcall(function()
    self:camerasysDecorateSet(cfgdata.value, cfgdata.type)
  end)()
end

function Decorate_addView:SetCheseLayerState(show)
  self.uiBinder.canvas_chese_layer.interactable = show
  self.uiBinder.canvas_chese_layer.blocksRaycasts = show
end

function Decorate_addView:camerasysDoodleSliderSet(valueData)
  local isVisible = self.uiBinder.Ref:GetUIComp(self.uiBinder.rect_cont).IsVisible
  if valueData.change then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rect_cont, not isVisible)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.rect_cont, valueData.isShow)
  end
  camerasysData.IsDecorateAddViewSliderShow = isVisible
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetActionSliderHide, not isVisible)
  if valueData.isShow and not Z.IsPCUI then
    self.uiBinder.slider_pellucidity.value = valueData.value
  end
end

function Decorate_addView:setColorByIndex(item, index)
  local itemList = camerasysData:GetDecorateTextCfg()
  local data = itemList[index]
  if not data then
    return
  end
  local colorRgb = Z.ColorHelper.Hex2Rgba(string.gsub(data.Res, "#", ""))
  local newColor = Color.New(colorRgb.r / 255, colorRgb.g / 255, colorRgb.b / 255, item.lab_input.color.a)
  item.lab_input.color = newColor
end

function Decorate_addView:camerasysDecorateSet(data, valueType)
  self.parent_.uiBinder.Ref:SetVisible(self.parent_.uiBinder.node_decorate, true)
  self:SetCheseLayerState(true)
  local item = self:popPool()
  if not item then
    local name = string.format("decorate%s", self.stickerIndex_)
    self.stickerIndex_ = self.stickerIndex_ + 1
    item = self:AsyncLoadUiUnit("ui/prefabs/photograph/camera_decorate_controller_item_tpl", name, self.uiBinder.rect_decorate_layer)
    local pos = self.uiBinder.rect_decorate_porn_point.anchoredPosition
    item.Trans:SetAnchorPosition(pos.x, pos.y)
    item.name = name
    item.poolState = E.PrefabPoolState.Active
    self.decorates_[name] = item
  else
    self:initItemPool(item)
  end
  local baseData = {}
  baseData.typeData = data
  baseData.res = data.Res
  baseData.decorateType = valueType
  local commonData = {}
  commonData.number = self.stickerIndex_
  baseData.commonData = commonData
  self.addViewData_:InitDecorateData(item, baseData)
  self.addViewData_:GetDecorateData(item).name = item.name
  item.decorateType = valueType
  camerasysData.ActiveItem = item
  local ctrlObjAll = self:getFrame(item)
  for _, comp in pairs(ctrlObjAll) do
    local uiComp = item.Ref:GetUIComp(comp)
    uiComp.IgnoreLayout = true
  end
  if valueType == E.CamerasysFuncType.Text then
    self.addViewData_.DecorationTextNum = self.addViewData_.DecorationTextNum + 1
  end
  self.addViewData_:AddDecoreateNum(1)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateNumberUpdate)
  self:setDecorateItemBaseInfo(item, data, valueType)
  self:setItemMoveEvent(item, valueType)
  self:addListenerBing(item)
  self:addSpecialListenerBing(item, valueType, data)
end

function Decorate_addView:refDecorate(item, decorateType)
  local isSticker = false
  if decorateType == E.CamerasysFuncType.Sticker then
    isSticker = true
  end
end

function Decorate_addView:setDecorateItemBaseInfo(item, data, decorateType)
  self:refDecorate(item, decorateType)
  self:changeItemSettingState(decorateType, item)
  if decorateType == E.CamerasysFuncType.Sticker then
    item.rimg_decorate_icon:SetImage(string.format("%s%s", iconPath, data.Res))
    if self.decorateLayerType_ == E.DecorateLayerType.AlbumType and data.transparency then
      item.rimg_decorate_icon:SetColor(Color.New(1, 1, 1, data.transparency))
      item.rect_decorate_icon:SetScale(data.iconScale.x * -1, data.iconScale.y)
      item.Trans:SetLocalEuler(0, 0, data.rotateZ)
      self:setFrameVisible(item, false)
    else
      item.rimg_decorate_icon:SetColor(Color.New(1, 1, 1, 1))
      local sizeRange = camerasysData:GetCameraDecorateScaleRangeByType(data.Parameter)
      item.rect_decorate_icon:SetScale(sizeRange.define, sizeRange.define)
    end
    item.controller_item:ForceRebuildLayoutImmediate()
  elseif decorateType == E.CamerasysFuncType.Text then
    item.size_fitter_input.Enabled = true
    local color = self.cameraData.ColorPaletteColor
    if self.decorateLayerType_ == E.DecorateLayerType.AlbumType and data.transparency then
      item.lab_input.color = Color.New(color.r, color.g, color.b, data.transparency)
      item.lab_input.fontSize = data.textSize
      item.lab_input.text = data.textValue
      self:setColorByIndex(item, data.colorIndex)
      item.size_fitter_input.Enabled = false
      item.rect_input.sizeDelta.x = data.textScale.x
      item.rect_input.sizeDelta.y = data.textScale.y
      item.Trans:SetLocalEuler(0, 0, data.rotateZ)
      self:setFrameVisible(item, false)
    else
      item.lab_input.color = Color.New(color.r, color.g, color.b, 1)
      item.lab_input.fontSize = camerasysData:GetTextFontSize()
      item.lab_input.text = data
    end
  end
  self:setFrameVisible(item, true)
  item.Ref.UIComp:SetVisible(true)
end

function Decorate_addView:changeItemSettingState(decorateType, item)
  item.Ref:SetVisible(item.img_txt_frame, decorateType == E.CamerasysFuncType.Text)
  item.Ref:SetVisible(item.rimg_decorate_icon, decorateType ~= E.CamerasysFuncType.Text)
  local iconPath = "Left_Up_Icon_%d"
  local imagePath = self.uiBinder.prefab_cache:GetString(string.format(iconPath, decorateType))
  if imagePath and not string.zisEmpty(imagePath) then
    item.img_up_left_icon_sticker:SetImage(imagePath)
  end
  iconPath = "Left_Bottom_Icon_%d"
  imagePath = self.uiBinder.prefab_cache:GetString(string.format(iconPath, decorateType))
  if imagePath and not string.zisEmpty(imagePath) then
    item.img_left_icon_sticker:SetImage(imagePath)
  end
end

function Decorate_addView:setItemMoveEvent(item, decorateType)
  item.event_controller_item.onDown:AddListener(function()
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
    camerasysData.ActiveItem = item
    local valueData = {}
    valueData.isShow = false
    valueData.value = 1
    self:camerasysDoodleSliderSet(valueData)
    self:setFrameVisible(item, true)
    self:SetCheseLayerState(true)
    if decorateType == E.CamerasysFuncType.Sticker then
      Z.EventMgr:Dispatch(Z.ConstValue.Camera.TextViewChange)
    elseif decorateType == E.CamerasysFuncType.Text then
      item.img_txt_frame:SetColor(Color.New(1, 1, 1, 1))
      local sizeRange = camerasysData:GetCameraFontSizeRange()
      local fontSize = item.lab_input.fontSize
      Z.EventMgr:Dispatch(Z.ConstValue.Camera.TextViewChange, {sizeRange = sizeRange, fontSize = fontSize})
    end
  end)
  item.event_controller_item.onDrag:AddListener(function(go, pointerData)
    local pos = item.Trans.anchoredPosition
    local posX, posY = vm.PosKeepBounds(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
    item.Trans:SetAnchorPosition(posX, posY)
    self.addViewData_:GetDecorateData(item).pos = {x = posX, y = posY}
  end)
end

function Decorate_addView:addSpecialListenerBing(item, decorateType, data)
  if decorateType == E.CamerasysFuncType.Sticker then
    local isTurn = false
    item.btn_up_left:AddListener(function()
      isTurn = not isTurn
      local itemDecorateIconScale = item.rect_decorate_icon.localScale
      item.rect_decorate_icon.localScale = Vector2.New(itemDecorateIconScale.x * -1, itemDecorateIconScale.y)
      self.addViewData_:GetDecorateData(item).isFlip = isTurn
    end)
    self:setItemRotateSizeEventSticker(item, data)
  elseif decorateType == E.CamerasysFuncType.Text then
    item.rect_input:SetLocalEuler(0, 0, 0)
    item.event_left.onDown:AddListener(function(go, pointerData)
      item.drag_left:UnOriDir(pointerData.position.x, pointerData.position.y, item.Trans.anchoredPosition.x, item.Trans.anchoredPosition.y)
    end)
    item.event_left.onDrag:AddListener(function(go, pointerData)
      local x, y = 0, 0
      x, y = item.node_controller_item:GetSize(x, y)
      local size = item.drag_left:ComputeScaleXY(pointerData.delta.x, pointerData.delta.y, x, y)
      local ratotion = item.drag_left:ComputeRotate()
      item.Trans:SetLocalEuler(0, 0, ratotion.z)
      self.addViewData_:GetDecorateData(item).rotateZ = ratotion.z
    end)
    self:setItemSizeEventText(item)
  end
end

function Decorate_addView:setItemSizeEventText(item)
  item.event_up_left.onDown:AddListener(function(go, pointerData)
    item.size_fitter_input.Enabled = false
    item.drag_up_left:UnOriDir(pointerData.position.x, pointerData.position.y, item.Trans.anchoredPosition.x, item.Trans.anchoredPosition.y)
  end)
  item.event_up_left.onDrag:AddListener(function(go, pointerData)
    local x, y = 0, 0
    x, y = item.node_controller_item:GetSize(x, y)
    local size = item.drag_up_left:ComputeScaleXY(pointerData.delta.x, pointerData.delta.y, x, y)
    local rectInputX, rectInputY = 0, 0
    rectInputX, rectInputY = item.rect_input:GetSize(rectInputX, rectInputY)
    if 0 > size.x then
      size.x = -size.x
    end
    if 0 > size.y then
      size.y = -size.y
    end
    if rectInputX < 5 then
      rectInputX = 5
    end
    if rectInputY < 5 then
      rectInputY = 5
    end
    item.rect_input:SetSizeDelta(rectInputX * size.x, rectInputY * size.y)
    self.addViewData_:GetDecorateData(item).textScale = {
      x = rectInputX * size.x,
      y = rectInputY * size.y
    }
  end)
end

function Decorate_addView:addListenerBing(item)
  item.btn_right:AddListener(function()
    local valueData = {}
    local hyaliner = item.rimg_decorate_icon.color.a
    valueData.isShow = true
    if Z.IsPCUI then
      valueData.isShow = false
    end
    if not item then
      hyaliner = 1
    else
      hyaliner = item.rimg_decorate_icon.color.a
    end
    valueData.value = hyaliner
    valueData.change = true
    self:camerasysDoodleSliderSet(valueData)
  end)
  item.btn_up_right:AddListener(function()
    local itemData = self.addViewData_:GetDecorateData(item)
    if itemData.decorateType == E.CamerasysFuncType.Text then
      self.addViewData_.DecorationTextNum = 0
    end
    self:pushPool(item)
    self.addViewData_:AddDecoreateNum(-1)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateNumberUpdate)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerDown)
    self.addViewData_:DeleteDecorateData(item)
  end)
end

function Decorate_addView:setItemRotateSizeEventSticker(item, data)
  local sizeRange = camerasysData:GetCameraDecorateScaleRangeByType(data.Parameter)
  item.event_left.onDown:AddListener(function(go, pointerData)
    local posX, posY = 0, 0
    posX, posY = item.Trans:GetAnchorPosition(posX, posY)
    item.drag_left:UnOriDir(pointerData.position.x, pointerData.position.y, posX, posY)
  end)
  item.event_left.onDrag:AddListener(function(go, pointerData)
    local nodeSizeX, nodeSizeY = 0, 0
    nodeSizeX, nodeSizeY = item.node_controller_item:GetSize(nodeSizeX, nodeSizeY)
    local scale = item.drag_left:ComputeScale(pointerData.delta.x, pointerData.delta.y, nodeSizeX, nodeSizeY, sizeRange.define, sizeRange.max)
    local rotation = item.drag_left:ComputeRotate()
    if scale > sizeRange.max then
      scale = sizeRange.max
    end
    if scale < sizeRange.min then
      scale = sizeRange.min
    end
    item.rect_decorate_icon:SetScale(scale, scale)
    item.Trans:SetLocalEuler(0, 0, rotation.z)
    item.controller_item:ForceRebuildLayoutImmediate()
    self.addViewData_:GetDecorateData(item).iconScale = {x = scale, y = scale}
    self.addViewData_:GetDecorateData(item).rotateZ = rotation.z
  end)
end

function Decorate_addView:getFrame(item)
  local ctrlObjAll = {
    item.btn_up_left,
    item.btn_up_right,
    item.event_left,
    item.btn_right,
    item.img_frame
  }
  return ctrlObjAll
end

function Decorate_addView:setFrameVisible(item, isVisible)
  if isVisible and camerasysData.ActiveItem and camerasysData.ActiveItem ~= item then
    local activeItemF = self:getFrame(camerasysData.ActiveItem)
    for _, obj in pairs(activeItemF) do
      item.Ref:SetVisible(obj, isVisible)
    end
    camerasysData.ActiveItem.img_txt_frame:SetColor(Color.New(1, 1, 1, 0))
  end
  local ctrlObjAll = self:getFrame(item)
  for _, obj in pairs(ctrlObjAll) do
    item.Ref:SetVisible(obj, isVisible)
  end
  item.btn_right.interactable = not Z.IsPCUI
  item.btn_right.IsDisabled = Z.IsPCUI
  item.img_icon.alpha = Z.IsPCUI and 0.5 or 1
  item.img_txt_frame:SetColor(Color.New(1, 1, 1, isVisible and 1 or 0))
end

function Decorate_addView:pushPool(item)
  self.decoratePoolIndex_ = self.decoratePoolIndex_ + 1
  self.decoratePool_[self.decoratePoolIndex_] = item.name
  item.poolState = E.PrefabPoolState.Rest
  item.drag_left:ClearAll()
  item.drag_up_left:ClearAll()
  item.Ref.UIComp:SetVisible(false)
end

function Decorate_addView:popPool()
  local item
  if self.decoratePoolIndex_ > 0 then
    local decName = self.decoratePool_[self.decoratePoolIndex_]
    item = self.decorates_[decName]
    self.decoratePoolIndex_ = self.decoratePoolIndex_ - 1
    item.Ref.UIComp:SetVisible(true)
  end
  return item
end

function Decorate_addView:initItemPool(item)
  local pos = self.uiBinder.rect_decorate_porn_point.anchoredPosition
  item.Trans:SetAnchorPosition(pos.x, pos.y)
  item.poolState = E.PrefabPoolState.Active
  item.size_fitter_input.Enabled = true
  item.lab_input.color = Color.New(1, 1, 1, 1)
  item.rimg_decorate_icon:SetColor(Color.New(1, 1, 1, 1))
  item.rect_decorate_icon:SetLocalEuler(0, 0, 0)
  item.Trans:SetLocalEuler(0, 0, 0)
  item.rect_input.sizeDelta = Vector2.New(1, 1)
  item.rect_input.localPosition = Vector3.New(item.rect_input.localPosition.x, item.rect_input.localPosition.y, 0)
  item.rect_decorate_icon:SetScale(1, 1)
  item.colorIndex = false
  item.lab_input.text = ""
  item.btn_right.interactable = not Z.IsPCUI
  item.btn_right.IsDisabled = Z.IsPCUI
  item.img_icon.alpha = Z.IsPCUI and 0.5 or 1
end

function Decorate_addView:getTextSize(eventData)
  if not eventData or not next(eventData) then
    return
  end
  if eventData.type ~= self.decorateLayerType_ then
    return
  end
  for key, item in pairs(self.decorates_) do
    if item.decorateType == E.CamerasysFuncType.Text then
      local size = item.rect_input.rect.size
      self.addViewData_:GetDecorateData(item).textScale = {
        x = size.x,
        y = size.y
      }
    end
  end
end

function Decorate_addView:setAllDecorateVisible(isShow)
  for key, item in pairs(self.decorates_) do
    if item.poolState ~= E.PrefabPoolState.Rest then
      item.Ref.UIComp:SetVisible(isShow)
    end
  end
end

function Decorate_addView:reductionDecorateItem(data)
  self:SetCheseLayerState(true)
  local item = self:popPool()
  if not item then
    local name = data.name
    self.stickerIndex_ = self.stickerIndex_ + 1
    item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Decorate_Controller_Item), name, self.uiBinder.rect_decorate_layer)
    item.Trans:SetAnchorPosition(data.pos.x, data.pos.y)
    item.name = name
    item.poolState = E.PrefabPoolState.Active
    self.decorates_[name] = item
  else
    self:initItemPool(item)
  end
  item.decorateType = data.decorateType
  if data.decorateType == E.CamerasysFuncType.Text then
    self.addViewData_.DecorationTextNum = self.addViewData_.DecorationTextNum + 1
  end
  self.addViewData_:AddDecoreateNum(1)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateNumberUpdate)
  self:setDecorateItemBaseInfo(item, data, data.decorateType)
  self:setItemMoveEvent(item, data.decorateType)
  self:addListenerBing(item)
  self:addSpecialListenerBing(item, data.decorateType, data)
  self:setFrameVisible(item, false)
end

function Decorate_addView:ReductionDecorate(decorateData)
  self.addViewData_ = secondaryData
  self.decorateLayerType_ = E.DecorateLayerType.AlbumType
  local decorateDataSort = {}
  for key, value in pairs(decorateData) do
    decorateDataSort[#decorateDataSort + 1] = value
  end
  table.sort(decorateDataSort, function(a, b)
    return a.number < b.number
  end)
  for key, data in ipairs(decorateDataSort) do
    Z.CoroUtil.create_coro_xpcall(function()
      self:reductionDecorateItem(data)
    end)()
  end
end

return Decorate_addView
