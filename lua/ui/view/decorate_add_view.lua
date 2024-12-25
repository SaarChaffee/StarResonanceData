local UI = Z.UI
local super = require("ui.ui_subview_base")
local Decorate_addView = class("Decorate_addView", super)
local vm = Z.VMMgr.GetVM("camerasys")
local camerasysData = Z.DataMgr.Get("camerasys_data")
local decorateData = Z.DataMgr.Get("decorate_add_data")
local secondaryData = Z.DataMgr.Get("photo_secondary_data")
local iconPath = "ui/atlas/photograph_decoration/stickers/"

function Decorate_addView:ctor(parent)
  self.panel = nil
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
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self.panel.img_chese_layer.EventTrigger.onDown:AddListener(function()
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerDown)
    camerasysData.IsDecorateAddViewSliderShow = false
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetActionSliderHide, true)
  end)
  self.panel.cont_slider.slider_pellucidity.Slider.value = 0
  self.panel.cont_slider:SetVisible(false)
  self.panel.cont_slider.slider_pellucidity.Slider:AddListener(function()
    local valueData = {}
    valueData.value = self.panel.cont_slider.slider_pellucidity.Slider.value
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
  local color = camerasysData.ActiveItem.lab_input.TMPLab.color
  color.a = valueData.value
  camerasysData.ActiveItem.lab_input.TMPLab.color = color
  camerasysData.ActiveItem.img_decorate_icon.Img:SetColor(Color.New(1, 1, 1, valueData.value))
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
    camerasysData.ActiveItem.lab_input.TMPLab.text = valueData.value
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
  self.panel.cont_slider:SetVisible(false)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
  self:SetCheseLayerState(false)
end

function Decorate_addView:camerasysDecorateDeActive(valueData)
  if not camerasysData.ActiveItem then
    return
  end
  self:setFrameVisible(camerasysData.ActiveItem, false)
  self.panel.cont_slider:SetVisible(false)
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
  self.panel.img_chese_layer.Ref.CanvasGroup.interactable = show
  self.panel.img_chese_layer.Ref.CanvasGroup.blocksRaycasts = show
end

function Decorate_addView:camerasysDoodleSliderSet(valueData)
  if valueData.change then
    self.panel.cont_slider:SetVisible(not self.panel.cont_slider.Ref.IsVisible)
  else
    self.panel.cont_slider:SetVisible(valueData.isShow)
  end
  camerasysData.IsDecorateAddViewSliderShow = self.panel.cont_slider.Ref.IsVisible
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetActionSliderHide, not self.panel.cont_slider.Ref.IsVisible)
  if valueData.isShow then
    self.panel.cont_slider.slider_pellucidity.Slider.value = valueData.value
  end
end

function Decorate_addView:setColorByIndex(item, index)
  local itemList = camerasysData:GetDecorateTextCfg()
  local data = itemList[index]
  if not data then
    return
  end
  local colorRgb = Z.ColorHelper.Hex2Rgba(string.gsub(data.Res, "#", ""))
  local newColor = Color.New(colorRgb.r / 255, colorRgb.g / 255, colorRgb.b / 255, item.lab_input.TMPLab.color.a)
  item.lab_input.TMPLab.color = newColor
end

function Decorate_addView:camerasysDecorateSet(data, valueType)
  self.parent_.uiBinder.Ref:SetVisible(self.parent_.uiBinder.node_decorate, true)
  self:SetCheseLayerState(true)
  local item = self:popPool()
  if not item then
    local name = string.format("decorate%s", self.stickerIndex_)
    self.stickerIndex_ = self.stickerIndex_ + 1
    item = self:AsyncLoadUiUnit("ui/prefabs/photograph/camera_decorate_controller_item_tpl", name, self.panel.img_decorate_layer.Trans)
    item.Ref:SetPosition(self.panel.node_decorate_porn_point.Ref:GetPosition())
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
  if valueType == E.CamerasysFuncType.Text then
    self.addViewData_.DecorationTextNum = self.addViewData_.DecorationTextNum + 1
  end
  self.addViewData_:AddDecoreateNum(1)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateNumberUpdate)
  self:setDecorateItemBaseInfo(item, data, valueType)
  self:setItemMoveEvent(item, valueType)
  self:addListenerBing(item)
  self:addSpecialListenerBing(item, valueType)
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
    item.img_decorate_icon.Img:SetImage(string.format("%s%s_2", iconPath, data.Res))
    if self.decorateLayerType_ == E.DecorateLayerType.AlbumType and data.transparency then
      item.img_decorate_icon.Img:SetColor(Color.New(1, 1, 1, data.transparency))
      item.img_decorate_icon.Ref:SetScale(data.iconScale.x * -1, data.iconScale.y)
      item.Ref:SetRotate(0, 0, data.rotateZ)
      self:setFrameVisible(item, false)
    else
      item.img_decorate_icon.Img:SetColor(Color.New(1, 1, 1, 1))
      local sizeRange = camerasysData:GetCameraDecorateScaleRange()
      item.img_decorate_icon.Ref:SetScale(sizeRange.define, sizeRange.define)
    end
    item.controller_item.ZLayout:ForceRebuildLayoutImmediate()
  elseif decorateType == E.CamerasysFuncType.Text then
    item.lab_input.ContentSizeFitter.Enabled = true
    local color = self.cameraData.ColorPaletteColor
    if self.decorateLayerType_ == E.DecorateLayerType.AlbumType and data.transparency then
      item.lab_input.TMPLab.color = Color.New(color.r, color.g, color.b, data.transparency)
      item.lab_input.TMPLab.fontSize = data.textSize
      item.lab_input.TMPLab.text = data.textValue
      self:setColorByIndex(item, data.colorIndex)
      item.lab_input.ContentSizeFitter.Enabled = false
      item.lab_input.Ref:SetSize(data.textScale.x, data.textScale.y)
      item.Ref:SetRotate(0, 0, data.rotateZ)
      self:setFrameVisible(item, false)
    else
      item.lab_input.TMPLab.color = Color.New(color.r, color.g, color.b, 1)
      item.lab_input.TMPLab.fontSize = camerasysData:GetTextFontSize()
      item.lab_input.TMPLab.text = data
    end
  end
  self:setFrameVisible(item, true)
  item:SetVisible(true)
end

function Decorate_addView:changeItemSettingState(decorateType, item)
  item.img_txt_frame:SetVisible(decorateType == E.CamerasysFuncType.Text)
  item.img_decorate_icon:SetVisible(decorateType ~= E.CamerasysFuncType.Text)
  local iconPath = "Left_Up_Icon_%d"
  local imagePath = self:GetPrefabCacheData(string.format(iconPath, decorateType))
  if imagePath and not string.zisEmpty(imagePath) then
    item.img_up_left_icon_sticker.Img:SetImage(imagePath)
  end
  iconPath = "Left_Bottom_Icon_%d"
  local imagePath = self:GetPrefabCacheData(string.format(iconPath, decorateType))
  if imagePath and not string.zisEmpty(imagePath) then
    item.img_left_icon_sticker.Img:SetImage(imagePath)
  end
end

function Decorate_addView:setItemMoveEvent(item, decorateType)
  item.controller_item.EventTrigger.onDown:AddListener(function()
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
      item.img_txt_frame.Img:SetColor(Color.New(1, 1, 1, 1))
      local sizeRange = camerasysData:GetCameraFontSizeRange()
      local fontSize = item.lab_input.TMPLab.fontSize
      Z.EventMgr:Dispatch(Z.ConstValue.Camera.TextViewChange, {sizeRange = sizeRange, fontSize = fontSize})
    end
  end)
  item.controller_item.EventTrigger.onDrag:AddListener(function(go, pointerData)
    local pos = item.Ref:GetPosition()
    local posX, posY = vm.PosKeepBounds(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
    item.Ref:SetPosition(posX, posY)
    self.addViewData_:GetDecorateData(item).pos = {x = posX, y = posY}
  end)
end

function Decorate_addView:addSpecialListenerBing(item, decorateType)
  if decorateType == E.CamerasysFuncType.Sticker then
    local isTurn = false
    item.btn_up_left.Btn:AddListener(function()
      isTurn = not isTurn
      local itemDecorateIconScale = item.img_decorate_icon.Ref:GetScale()
      item.img_decorate_icon.Ref:SetScale(itemDecorateIconScale.x * -1, itemDecorateIconScale.y)
      self.addViewData_:GetDecorateData(item).isFlip = isTurn
    end)
    self:setItemRotateSizeEventSticker(item)
  elseif decorateType == E.CamerasysFuncType.Text then
    item.lab_input.Ref:SetRotate(0, 0, 0)
    item.btn_left.EventTrigger.onDown:AddListener(function(go, pointerData)
      item.btn_left.DragTool:UnOriDir(pointerData.position.x, pointerData.position.y, item.Ref:GetPosition().x, item.Ref:GetPosition().y)
    end)
    item.btn_left.EventTrigger.onDrag:AddListener(function(go, pointerData)
      local size = item.btn_left.DragTool:ComputeScaleXY(pointerData.delta.x, pointerData.delta.y, item.controller_item.Ref:GetSize().x, item.controller_item.Ref:GetSize().y)
      local ratotion = item.btn_left.DragTool:ComputeRotate()
      item.Ref:SetRotate(0, 0, ratotion.z)
      self.addViewData_:GetDecorateData(item).rotateZ = ratotion.z
    end)
    self:setItemSizeEventText(item)
  end
end

function Decorate_addView:setItemSizeEventText(item)
  item.btn_up_left.EventTrigger.onDown:AddListener(function(go, pointerData)
    item.lab_input.ContentSizeFitter.Enabled = false
    item.btn_up_left.DragTool:UnOriDir(pointerData.position.x, pointerData.position.y, item.Ref:GetPosition().x, item.Ref:GetPosition().y)
  end)
  local once = true
  item.btn_up_left.EventTrigger.onDrag:AddListener(function(go, pointerData)
    local size = item.btn_up_left.DragTool:ComputeScaleXY(pointerData.delta.x, pointerData.delta.y, item.controller_item.Ref:GetSize().x, item.controller_item.Ref:GetSize().y)
    local textSize = item.lab_input.Ref:GetSize()
    if size.x < 0 then
      size.x = -size.x
    end
    if size.y < 0 then
      size.y = -size.y
    end
    if textSize.x < 5 then
      textSize.x = 5
    end
    if textSize.y < 5 then
      textSize.y = 5
    end
    item.lab_input.Ref:SetSize(textSize.x * size.x, textSize.y * size.y)
    self.addViewData_:GetDecorateData(item).textScale = {
      x = textSize.x * size.x,
      y = textSize.y * size.y
    }
  end)
end

function Decorate_addView:addListenerBing(item)
  item.btn_right.Btn:AddListener(function()
    local valueData = {}
    local hyaliner = item.img_decorate_icon.Img.color.a
    valueData.isShow = true
    if not item then
      hyaliner = 1
    else
      hyaliner = item.img_decorate_icon.Img.color.a
    end
    valueData.value = hyaliner
    valueData.change = true
    self:camerasysDoodleSliderSet(valueData)
  end)
  item.btn_up_right.Btn:AddListener(function()
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

function Decorate_addView:setItemRotateSizeEventSticker(item)
  local sizeRange = camerasysData:GetCameraDecorateScaleRange()
  item.btn_left.EventTrigger.onDown:AddListener(function(go, pointerData)
    item.btn_left.DragTool:UnOriDir(pointerData.position.x, pointerData.position.y, item.Ref:GetPosition().x, item.Ref:GetPosition().y)
  end)
  item.btn_left.EventTrigger.onDrag:AddListener(function(go, pointerData)
    local size = item.btn_left.DragTool:ComputeScale(pointerData.delta.x, pointerData.delta.y, item.controller_item.Ref:GetSize().x, item.controller_item.Ref:GetSize().y, sizeRange.define, sizeRange.max)
    local ratotion = item.btn_left.DragTool:ComputeRotate()
    if size > sizeRange.max then
      size = sizeRange.max
    end
    if size < sizeRange.min then
      size = sizeRange.min
    end
    item.img_decorate_icon.Ref:SetScale(size, size)
    item.Ref:SetRotate(0, 0, ratotion.z)
    item.controller_item.ZLayout:ForceRebuildLayoutImmediate()
    self.addViewData_:GetDecorateData(item).iconScale = {x = size, y = size}
    self.addViewData_:GetDecorateData(item).rotateZ = ratotion.z
  end)
end

function Decorate_addView:getFrame(item)
  local ctrlObjAll = {
    item.btn_up_left,
    item.btn_up_right,
    item.btn_left,
    item.btn_right,
    item.img_frame
  }
  return ctrlObjAll
end

function Decorate_addView:setFrameVisible(item, isVisible)
  if isVisible and camerasysData.ActiveItem and camerasysData.ActiveItem ~= item then
    local activeItemF = self:getFrame(camerasysData.ActiveItem)
    for _, obj in pairs(activeItemF) do
      obj.Ref:SetVisible(false, false)
    end
    camerasysData.ActiveItem.img_txt_frame.Img:SetColor(Color.New(1, 1, 1, 0))
  end
  local ctrlObjAll = self:getFrame(item)
  for _, obj in pairs(ctrlObjAll) do
    obj.Ref:SetVisible(isVisible, false)
  end
  item.img_txt_frame.Img:SetColor(Color.New(1, 1, 1, isVisible and 1 or 0))
end

function Decorate_addView:pushPool(item)
  self.decoratePoolIndex_ = self.decoratePoolIndex_ + 1
  self.decoratePool_[self.decoratePoolIndex_] = item.name
  item.poolState = E.PrefabPoolState.Rest
  item.btn_left.DragTool:ClearAll()
  item.btn_up_left.DragTool:ClearAll()
  item:SetVisible(false)
end

function Decorate_addView:popPool()
  local item
  if self.decoratePoolIndex_ > 0 then
    local decName = self.decoratePool_[self.decoratePoolIndex_]
    item = self.decorates_[decName]
    self.decoratePoolIndex_ = self.decoratePoolIndex_ - 1
    item:SetVisible(true)
  end
  return item
end

function Decorate_addView:initItemPool(item)
  item.Ref:SetPosition(self.panel.node_decorate_porn_point.Ref:GetPosition())
  item.poolState = E.PrefabPoolState.Active
  item.lab_input.ContentSizeFitter.Enabled = true
  item.lab_input.TMPLab.color = Color.New(1, 1, 1, 1)
  item.img_decorate_icon.Img:SetColor(Color.New(1, 1, 1, 1))
  item.img_decorate_icon.Ref:SetRotate(0, 0, 0)
  item.Ref:SetRotate(0, 0, 0)
  item.lab_input.Ref:SetSize(1, 1)
  item.img_decorate_icon.Ref:SetScale(1, 1)
  item.colorIndex = false
  item.lab_input.TMPLab.text = ""
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
      local size = item.lab_input.Ref:GetSize()
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
      item:SetVisible(isShow)
    end
  end
end

function Decorate_addView:reductionDecorateItem(data)
  self:SetCheseLayerState(true)
  local item = self:popPool()
  if not item then
    local name = data.name
    self.stickerIndex_ = self.stickerIndex_ + 1
    item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Decorate_Controller_Item), name, self.panel.img_decorate_layer.Trans)
    item.Ref:SetPosition(data.pos)
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
  self:addSpecialListenerBing(item, data.decorateType)
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
