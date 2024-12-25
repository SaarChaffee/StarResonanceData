local UI = Z.UI
local super = require("ui.ui_subview_base")
local Decorate_subView = class("Decorate_subView", super)
local IconPath = "ui/atlas/photograph_decoration/stickers/"
local LeftBottomIcon = {
  [5] = "ui/atlas/photograph/camera_sticker_btn_transform",
  [6] = "ui/atlas/photograph/camera_sticker_btn_revert"
}
local LeftUpIcon = {
  [5] = "ui/atlas/photograph/camera_sticker_btn_flip",
  [6] = "ui/atlas/photograph/camera_sticker_btn_scale"
}

function Decorate_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "decorate_sub", "photograph/decorate_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.camerasysVM_ = Z.VMMgr.GetVM("camerasys")
  self.camerasysData_ = Z.DataMgr.Get("camerasys_data")
  self.viewData = nil
  self.sliderPellecidityIsShow_ = false
  self.decorateItems_ = {}
  self.selectDecorateUnit_ = nil
end

function Decorate_subView:OnActive()
  self.uiBinder.rect_sub:SetOffsetMin(0, 0)
  self.uiBinder.rect_sub:SetOffsetMax(0, 0)
  self.decorateItems_ = {}
  self.selectDecorateUnit_ = nil
  if self.viewData.activeUnit then
    self.viewData.activeUnit(nil)
  end
  self.uiBinder.node_chese_layer.onDown:AddListener(function()
    if self.viewData.activeUnit then
      self.viewData.activeUnit(nil)
    end
  end)
  self.uiBinder.slider_pellucidity:AddListener(function()
    if self.viewData.changeAlpha and self.selectDecorateUnit_ then
      self.viewData.changeAlpha(self.selectDecorateUnit_.name, self.uiBinder.slider_pellucidity.value)
    end
  end)
end

function Decorate_subView:OnDeActive()
  for _, unit in pairs(self.decorateItems_) do
    unit.evt_controller_item:ClearAll()
    unit.dragtool_left:ClearAll()
    unit.dragtool_up_left:ClearAll()
    unit.evt_up_left:ClearAll()
  end
end

function Decorate_subView:OnRefresh()
  self:changeSliderIsShow(false)
  if self.viewData and self.viewData.decorateData and next(self.viewData.decorateData) then
    Z.CoroUtil.create_coro_xpcall(function()
      local decorateDatas = {}
      for _, decorateInfo in pairs(self.viewData.decorateData) do
        decorateDatas[decorateInfo.number] = decorateInfo
      end
      for _, decorateInfo in ipairs(decorateDatas) do
        self:createDecorateItem(decorateInfo)
      end
    end)()
  end
end

function Decorate_subView:createDecorateItem(decorateData)
  local unit = self:getUnitFromPool(decorateData)
  if unit then
    self:initDecorateItem(unit)
    self:refreshDecorateItem(unit, decorateData)
    self:setEditorUI(unit, false)
    unit.Trans:SetAnchorPosition(decorateData.pos.x, decorateData.pos.y)
    if self.viewData.isCanEditor then
      self:bindDecorateItem(unit, decorateData)
    end
    self.decorateItems_[decorateData.name] = unit
  end
end

function Decorate_subView:initDecorateItem(unit)
  unit.Ref:SetVisible(unit.img_txt_frame, false)
  unit.Ref:SetVisible(unit.img_decorate_icon, false)
end

function Decorate_subView:setEditorUI(unit, show)
  unit.img_txt_frame:SetColor(Color.New(1, 1, 1, show and 1 or 0))
  unit.Ref:SetVisible(unit.img_frame, show)
  unit.Ref:SetVisible(unit.btn_up_left, show)
  unit.Ref:SetVisible(unit.btn_up_right, show)
  unit.Ref:SetVisible(unit.dragtool_left, show)
  unit.Ref:SetVisible(unit.btn_right, show)
end

function Decorate_subView:refreshDecorateItem(unit, decorateInfo)
  if E.CamerasysFuncType.Sticker == decorateInfo.decorateType then
    unit.Ref:SetVisible(unit.img_decorate_icon, true)
    unit.img_decorate_icon:SetImage(string.format("%s%s_2", IconPath, decorateInfo.res))
    unit.img_decorate_icon:SetColor(Color.New(1, 1, 1, decorateInfo.transparency))
    unit.rect_decorate_icon:SetScale(decorateInfo.iconScale.x, decorateInfo.iconScale.y)
    if decorateInfo.isFlip then
      unit.rect_decorate_icon:SetRot(0, 180, 0)
    else
      unit.rect_decorate_icon:SetRot(0, 0, 0)
    end
    unit.Trans:SetLocalEuler(0, 0, decorateInfo.rotateZ)
  elseif E.CamerasysFuncType.Text == decorateInfo.decorateType then
    unit.sizeFitter_input.Enabled = true
    unit.Ref:SetVisible(unit.img_txt_frame, true)
    if decorateInfo.textColor then
      unit.lab_input.color = Color.New(decorateInfo.textColor.x, decorateInfo.textColor.y, decorateInfo.textColor.z, decorateInfo.transparency)
    else
      unit.lab_input.color = Color.New(1, 1, 1, decorateInfo.transparency)
    end
    unit.lab_input.fontSize = decorateInfo.textSize
    unit.lab_input.text = decorateInfo.textValue
    unit.rect_input:SetWidthAndHeight(decorateInfo.textScale.x, decorateInfo.textScale.y)
    unit.Trans:SetLocalEuler(0, 0, decorateInfo.rotateZ)
  end
  unit.lay_controller_item:ForceRebuildLayoutImmediate()
end

function Decorate_subView:bindDecorateItem(unit, decorateData)
  unit.evt_controller_item.onDown:AddListener(function()
    if self.viewData.activeUnit then
      self.viewData.activeUnit(decorateData.name)
    end
  end)
  unit.evt_controller_item.onDrag:AddListener(function(go, pointerData)
    local pos = unit.Trans.anchoredPosition
    local posX, posY = self.camerasysVM_.PosKeepBounds(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
    unit.Trans:SetAnchorPosition(posX, posY)
    decorateData.pos = {x = posX, y = posY}
  end)
  unit.btn_right:AddListener(function()
    self.uiBinder.slider_pellucidity.value = decorateData.transparency
    self:changeSliderIsShow(not self.sliderPellecidityIsShow_)
  end)
  unit.btn_up_right:AddListener(function()
    if self.viewData.removeFunc then
      self.viewData.removeFunc(decorateData.name)
    end
  end)
  unit.img_up_left_icon:SetImage(LeftUpIcon[decorateData.decorateType])
  unit.img_left_icon:SetImage(LeftBottomIcon[decorateData.decorateType])
  if decorateData.decorateType == E.CamerasysFuncType.Sticker then
    unit.btn_up_left:AddListener(function()
      decorateData.isFlip = not decorateData.isFlip
      if decorateData.isFlip then
        unit.rect_decorate_icon:SetRot(0, 180, 0)
      else
        unit.rect_decorate_icon:SetRot(0, 0, 0)
      end
    end)
    unit.evt_left.onDown:AddListener(function(go, pointerData)
      local position = unit.rect_unit.anchoredPosition
      unit.dragtool_left:UnOriDir(pointerData.position.x, pointerData.position.y, position.x, position.y)
    end)
    unit.evt_left.onDrag:AddListener(function(go, pointerData)
      local sizeRange = self.camerasysData_:GetCameraDecorateScaleRange()
      local controllerItemSize = unit.rect_controller_item.rect.size
      local size = unit.dragtool_left:ComputeScale(pointerData.delta.x, pointerData.delta.y, controllerItemSize.x, controllerItemSize.y, sizeRange.define, sizeRange.max)
      local rotation = unit.dragtool_left:ComputeRotate()
      size = math.min(size, sizeRange.max)
      size = math.max(size, sizeRange.min)
      decorateData.iconScale = {x = size, y = size}
      decorateData.rotateZ = rotation.z
      unit.rect_decorate_icon:SetScale(size, size)
      unit.Trans:SetLocalEuler(0, 0, rotation.z)
      unit.lay_controller_item:ForceRebuildLayoutImmediate()
    end)
  elseif decorateData.decorateType == E.CamerasysFuncType.Text then
    unit.evt_left.onDown:AddListener(function(go, pointerData)
      local position = unit.rect_unit.anchoredPosition
      unit.dragtool_left:UnOriDir(pointerData.position.x, pointerData.position.y, position.x, position.y)
    end)
    unit.evt_left.onDrag:AddListener(function(go, pointerData)
      local controllerItemSize = unit.rect_unit.rect.size
      local size = unit.dragtool_left:ComputeScaleXY(pointerData.delta.x, pointerData.delta.y, controllerItemSize.x, controllerItemSize.y)
      local ratotion = unit.dragtool_left:ComputeRotate()
      unit.Trans:SetLocalEuler(0, 0, ratotion.z)
      decorateData.rotateZ = ratotion.z
    end)
    unit.evt_up_left.onDown:AddListener(function(go, pointerData)
      local position = unit.rect_unit.anchoredPosition
      unit.dragtool_up_left:UnOriDir(pointerData.position.x, pointerData.position.y, position.x, position.y)
      unit.sizeFitter_input.Enabled = false
      self.textSize = unit.rect_input.rect.size
    end)
    unit.evt_up_left.onDrag:AddListener(function(go, pointerData)
      local controllerItemSize = unit.rect_controller_item.rect.size
      local size = unit.dragtool_up_left:ComputeScaleXY(pointerData.delta.x, pointerData.delta.y, controllerItemSize.x, controllerItemSize.y)
      size.x = math.max(0, size.x)
      size.y = math.max(0, size.y)
      local x = size.x * self.textSize.x
      local y = size.y * self.textSize.y
      decorateData.textScale = {x = x, y = y}
      unit.rect_input:SetWidthAndHeight(x, y)
    end)
  end
end

function Decorate_subView:ChangeDecorateAlpha(decorateData)
  if self.selectDecorateUnit_ == nil then
    return
  end
  if decorateData.decorateType == E.CamerasysFuncType.Sticker then
    self.selectDecorateUnit_.unit.img_decorate_icon:SetColor(Color.New(1, 1, 1, decorateData.transparency))
  else
    self.selectDecorateUnit_.unit.lab_input.color = Color.New(decorateData.textColor.x, decorateData.textColor.y, decorateData.textColor.z, decorateData.transparency)
  end
end

function Decorate_subView:changeSliderIsShow(isShow)
  self.sliderPellecidityIsShow_ = isShow
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider, isShow)
end

function Decorate_subView:RemoveUnit(name)
  local unit = self.decorateItems_[name]
  unit.dragtool_left:ClearAll()
  unit.dragtool_up_left:ClearAll()
  unit.evt_up_left:ClearAll()
  unit.Ref:SetVisible(unit.rect_unit, false)
  unit.Trans:SetParent(self.uiBinder.node_delete_decorate_layer)
end

function Decorate_subView:getUnitFromPool(decorateData)
  if self.decorateItems_[decorateData.name] then
    local unit = self.decorateItems_[decorateData.name]
    unit.Trans:SetParent(self.uiBinder.node_decorate_layer)
    unit.Ref:SetVisible(unit.rect_unit, true)
    return unit
  else
    local unitPath = self.uiBinder.prefabCasheData:GetString("decorate_item")
    local unitName = decorateData.name
    local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_decorate_layer)
    return unit
  end
end

function Decorate_subView:AddDecorateItem(decorateData)
  self:changeSliderIsShow(false)
  Z.CoroUtil.create_coro_xpcall(function()
    self:createDecorateItem(decorateData)
  end)()
end

function Decorate_subView:EditorText(decorateData)
  local unit = self.decorateItems_[decorateData.name]
  unit.lab_input.text = decorateData.textValue
end

function Decorate_subView:ChangeDecorateTextFontSize(decorateData)
  local unit = self.decorateItems_[decorateData.name]
  unit.lab_input.fontSize = decorateData.textSize
end

function Decorate_subView:ChangeDecorateTextFontColor(decorateData)
  local unit = self.decorateItems_[decorateData.name]
  unit.lab_input.color = Color.New(decorateData.textColor.x, decorateData.textColor.y, decorateData.textColor.z, decorateData.transparency)
end

function Decorate_subView:ActiveDecorateUnit(decorateData)
  if self.selectDecorateUnit_ then
    self:setEditorUI(self.selectDecorateUnit_.unit, false)
  end
  self:changeSliderIsShow(false)
  if decorateData then
    self.selectDecorateUnit_ = {
      unit = self.decorateItems_[decorateData.name],
      name = decorateData.name
    }
    self:setEditorUI(self.selectDecorateUnit_.unit, true)
  else
    self.selectDecorateUnit_ = nil
  end
end

return Decorate_subView
