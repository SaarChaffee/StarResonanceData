local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_featureView = class("Menu_featureView", super)

function Menu_featureView:ctor(parentView, featureIndex)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_feature_sub", "face/face_menu_feature_sub", UI.ECacheLv.None)
  self.featureIndex_ = featureIndex
  if featureIndex == 1 then
    self.styleAttr_ = Z.ModelAttr.EModelHeadTexFeature
    self.featureDataAttr_ = Z.ModelAttr.EModelFaceFeatureData
    self.colorAttr_ = Z.ModelAttr.EModelFeatureColor
  else
    self.styleAttr_ = Z.ModelAttr.EModelHeadTexDecal
    self.featureDataAttr_ = Z.ModelAttr.EModelFaceDecalData
    self.colorAttr_ = Z.ModelAttr.EModelDecalColor
  end
  self.faceId_ = 0
end

function Menu_featureView:OnSelectFaceStyle(faceId)
  self.faceId_ = faceId
  super.OnSelectFaceStyle(self, faceId)
  self:refreshUIBySelectedStyle(faceId)
end

function Menu_featureView:OnActive()
  self:refreshScale()
  self:refreshRotate()
  local x, y = self.uiBinder.img_control_panel_ref:GetSize(nil, nil)
  self.controlPanelW_ = x
  self.controlPanelH_ = y
  super.OnActive(self)
  local isFeatureOne = self.featureIndex_ == 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_feature1, isFeatureOne)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_feature2, not isFeatureOne)
  self.uiBinder.img_control_panel.onDrag:AddListener(function(go, pointerData)
    self:updatePointerPos(pointerData)
  end)
  self.uiBinder.img_control_panel.onEndDrag:AddListener(function(go, pointerData)
    self.faceVM_.CacheFaceData()
  end)
  self.uiBinder.img_control_panel.onClick:AddListener(function(go, pointerData)
    self:updatePointerPos(pointerData)
  end)
  self:InitSliderFunc(self.uiBinder.node_scale.slider_sens, function(value)
    self.uiBinder.node_scale.lab_value.text = string.format("%d", math.floor(value + 0.5))
    self:SetFaceAttrValueByShowValue(value, self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.Scale)
  end, self.featureDataAttr_, self.isScale_)
  self:InitSliderFunc(self.uiBinder.node_rotation.slider_sens, function(value)
    self.uiBinder.node_rotation.lab_value.text = string.format("%d", math.floor(value + 0.5))
    self:SetFaceAttrValueByShowValue(value, self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.Rotation)
  end, self.featureDataAttr_, self.isRotation_)
  self.uiBinder.tog_open:AddListener(function(isOn)
    self.faceVM_.RecordFaceEditorCommand(self.featureDataAttr_)
    self.faceVM_.SetFaceOptionByAttrType(self.featureDataAttr_, isOn, self.faceData_.FaceDef.EAttrParamFaceHandleData.IsFlip)
    self.faceVM_.CacheFaceData()
  end)
end

function Menu_featureView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(self.colorAttr_, hsv)
end

function Menu_featureView:OnDeActive()
  super.OnDeActive(self)
  self.controlPanelW_ = nil
  self.controlPanelH_ = nil
end

function Menu_featureView:refreshMenu()
  local row = Z.TableMgr.GetTable("FaceStickerTableMgr").GetRow(self.faceId_, true)
  if row then
    if row.Move == 1 then
      self:refreshMove()
    end
    if row.Scale == 1 then
      self:refreshScale()
    end
    if row.Rotate == 1 then
      self:refreshRotate()
    end
    if row.Back == 1 then
      self:refreshBack()
    end
  end
end

function Menu_featureView:refreshMove()
  local normalizedX = self.faceVM_.GetFaceOptionByAttrType(self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.X)
  local normalizedY = self.faceVM_.GetFaceOptionByAttrType(self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.Y)
  self.uiBinder.img_pointer:SetLocalPos((normalizedX - 0.5) * self.controlPanelW_, (normalizedY - 0.5) * self.controlPanelH_)
end

function Menu_featureView:refreshScale()
  self:InitSlider(self.uiBinder.node_scale, self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.Scale)
end

function Menu_featureView:refreshRotate()
  self:InitSlider(self.uiBinder.node_rotation, self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.Rotation)
end

function Menu_featureView:refreshBack()
  self.uiBinder.tog_open:SetIsOnWithoutNotify(self.faceVM_.GetFaceOptionByAttrType(self.featureDataAttr_, self.faceData_.FaceDef.EAttrParamFaceHandleData.IsFlip))
end

function Menu_featureView:refreshUIBySelectedStyle(faceId)
  local isShow = 0 < faceId
  self.uiBinder.cont_palette.Ref.UIComp:SetVisible(isShow)
  local isShowFunc = false
  if isShow then
    local row = Z.TableMgr.GetTable("FaceStickerTableMgr").GetRow(faceId)
    if row then
      if row.Move == 1 then
        isShowFunc = true
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_pos_control, true)
        self:refreshMove()
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_pos_control, false)
      end
      if row.Scale == 1 then
        isShowFunc = true
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_scale.Ref, true)
        self:refreshScale()
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_scale.Ref, false)
      end
      if row.Rotate == 1 then
        isShowFunc = true
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_rotation.Ref, true)
        self:refreshRotate()
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_rotation.Ref, false)
      end
      if row.Back == 1 then
        isShowFunc = true
        self.uiBinder.Ref:SetVisible(self.uiBinder.tog_open, true)
        self:refreshBack()
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.tog_open, false)
      end
      self.colorPalette_:RefreshPaletteByColorGroupId(row.ColorId)
      local array = row.DefaultColor
      self.colorPalette_:SetDefaultColor({
        h = array[1] / 360,
        s = array[2] / 100,
        v = array[3] / 100
      })
      local hsv = self.faceVM_.GetFaceOptionByAttrType(self.colorAttr_)
      self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_pos_control, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_scale.Ref, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_rotation.Ref, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_open, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_pos_control, isShowFunc)
end

function Menu_featureView:updatePointerPos(pointerData)
  local isOk, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.img_control_panel_ref, pointerData.position, nil)
  local x = uiPos.x + self.controlPanelW_ / 2
  local y = uiPos.y + self.controlPanelH_ / 2
  if x > self.controlPanelW_ then
    x = self.controlPanelW_
  end
  if x < 0 then
    x = 0
  end
  if y > self.controlPanelH_ then
    y = self.controlPanelH_
  end
  if y < 0 then
    y = 0
  end
  self.faceVM_.RecordFaceEditorCommand(self.featureDataAttr_)
  self.uiBinder.img_pointer:SetLocalPos(x - self.controlPanelW_ / 2, y - self.controlPanelH_ / 2)
  self.faceVM_.SetFaceOptionByAttrType(self.featureDataAttr_, x / self.controlPanelW_, self.faceData_.FaceDef.EAttrParamFaceHandleData.X)
  self.faceVM_.SetFaceOptionByAttrType(self.featureDataAttr_, y / self.controlPanelH_, self.faceData_.FaceDef.EAttrParamFaceHandleData.Y)
end

function Menu_featureView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshMenu()
end

return Menu_featureView
