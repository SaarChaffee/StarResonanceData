local super = require("ui.model.data_base")
local PhotoEditing = class("PhotoEditing", super)
local BigFilterPath = "ui/textures/photograph/"

function PhotoEditing:ctor()
  self.shotSetData_ = nil
  self.frameType_ = E.CameraFrameType.None
  self.frameRes_ = ""
  self.decorateDatas_ = {}
  self.decorateUnitCount_ = 0
  self.decorateTextCount_ = 0
  self.decorateDataPool_ = {}
  self.activeData_ = nil
  self.MaxDecorateCount = Z.Global.Photograph_DecorationsAddLimit
  self.MaxDecorateTextCount = Z.Global.Photograph_DecorationsOfTextAddLimit
end

function PhotoEditing:InitData()
  self.shotSetData_ = nil
  self.frameType_ = E.CameraFrameType.None
  self.frameRes_ = ""
  self.decorateDatas_ = {}
  self.decorateUnitCount_ = 0
  self.decorateTextCount_ = 0
  self.activeData_ = nil
  self.decorateDataPool_ = {}
  self:ResetExposure()
  self:ResetContrast()
  self:ResetSaturation()
end

function PhotoEditing:DeserializeDecorateInfo(decorateInfo)
  local cjson = require("cjson")
  local deData = cjson.decode(decorateInfo)
  self.shotSetData_ = deData.shotsetData
  if self.shotSetData_.frameData then
    self.frameRes_ = self.shotSetData_.frameData.frameRes
    self.frameType_ = self.shotSetData_.frameData.frameType
  end
  for _, data in pairs(deData.decorateData) do
    self.decorateDatas_[data.name] = data
    if data.decorateType == E.CamerasysFuncType.Text then
      self.decorateTextCount_ = self.decorateTextCount_ + 1
    end
    self.decorateUnitCount_ = self.decorateUnitCount_ + 1
  end
  self.moviescreen_exposure = self.shotSetData_.exposure
  self.moviescreen_contrast = self.shotSetData_.contrast
  self.moviescreen_saturation = self.shotSetData_.saturation
end

function PhotoEditing:SerializeDecorateInfo()
  local cjson = require("cjson")
  self.shotSetData_.exposure = self.moviescreen_exposure
  self.shotSetData_.contrast = self.moviescreen_contrast
  self.shotSetData_.saturation = self.moviescreen_saturation
  self.shotSetData_.frameData = {
    frameRes = self.frameRes_,
    frameType = self.frameType_
  }
  local photoInfo = {
    shotsetData = {}
  }
  for key, value in pairs(self.shotSetData_) do
    photoInfo.shotsetData[key] = value
  end
  local decorateCount = 0
  photoInfo.decorateData = {}
  for _, value in pairs(self.decorateDatas_) do
    value.name = "decorate" .. value.number
    photoInfo.decorateData[value.number] = value
    decorateCount = decorateCount + 1
  end
  local serial = cjson.encode(photoInfo)
  return serial
end

function PhotoEditing:GetFrame()
  return self.frameType_, string.format("%s%s", BigFilterPath, self.frameRes_)
end

function PhotoEditing:GetOriginalFrameTable()
  return self.frameType_, self.frameRes_
end

function PhotoEditing:ChangeFrame(frameType, frameRes)
  self.frameType_ = frameType
  self.frameRes_ = frameRes
end

function PhotoEditing:ActiveData(name)
  if name then
    self.activeData_ = self:GetDecorateData(name)
  else
    self.activeData_ = nil
  end
  return self.activeData_
end

function PhotoEditing:GetActiveDataName()
  if self.activeData_ then
    return self.activeData_.name
  end
  return ""
end

function PhotoEditing:AddDecorateSticker(res)
  if self.decorateUnitCount_ >= self.MaxDecorateCount then
    Z.TipsVM.ShowTipsLang(1000029)
    return nil
  end
  local data = self:getDecorateDataFromPool()
  data.pos = {x = 0, y = 0}
  data.decorateType = E.CamerasysFuncType.Sticker
  data.res = res
  data.transparency = 1
  data.iconScale = {x = 1, y = 1}
  data.isFlip = false
  data.rotateZ = 0
  self.decorateDatas_[data.name] = data
  self.decorateUnitCount_ = self.decorateUnitCount_ + 1
  return data
end

function PhotoEditing:CheckCanCreateText()
  if self.decorateTextCount_ >= self.MaxDecorateTextCount then
    Z.TipsVM.ShowTipsLang(1000032)
    return false
  elseif self.decorateUnitCount_ >= self.MaxDecorateCount then
    Z.TipsVM.ShowTipsLang(1000029)
    return false
  else
    return true
  end
end

function PhotoEditing:CheckCanEditorText()
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    return true
  else
    Z.TipsVM.ShowTipsLang(1000000)
    return false
  end
end

function PhotoEditing:GetTextFontSize()
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    return self.activeData_.textSize
  else
    return nil
  end
end

function PhotoEditing:GetTextFontColor()
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    return self.activeData_.textColor
  else
    return nil
  end
end

function PhotoEditing:GetText()
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    return self.activeData_.textValue
  else
    return ""
  end
end

function PhotoEditing:AddDecorateText(textTable)
  if self.decorateTextCount_ >= self.MaxDecorateTextCount then
    Z.TipsVM.ShowTipsLang(1000032)
    return nil
  elseif self.decorateUnitCount_ + self.decorateTextCount_ >= self.MaxDecorateCount then
    Z.TipsVM.ShowTipsLang(1000029)
    return nil
  else
    local data = self:getDecorateDataFromPool()
    data.pos = {x = 0, y = 0}
    data.decorateType = E.CamerasysFuncType.Text
    data.textColor = textTable.textColor
    data.textSize = textTable.textSize
    data.transparency = 1
    data.textScale = {x = 0, y = 0}
    data.isFlip = false
    data.rotateZ = 0
    data.textValue = textTable.textValue
    self.decorateDatas_[data.name] = data
    self.decorateUnitCount_ = self.decorateUnitCount_ + 1
    self.decorateTextCount_ = self.decorateTextCount_ + 1
    return data
  end
end

function PhotoEditing:RemoveDecorate(name)
  local data = self.decorateDatas_[name]
  self.decorateDatas_[name] = nil
  self.decorateDataPool_[name] = data
  self.decorateUnitCount_ = self.decorateUnitCount_ - 1
  if data.decorateType == E.CamerasysFuncType.Text then
    self.decorateTextCount_ = self.decorateTextCount_ - 1
  end
  for _, value in pairs(self.decorateDatas_) do
    if value.number > data.number then
      value.number = value.number - 1
    end
  end
end

function PhotoEditing:GetAllDecorateStickers()
  return self.decorateDatas_
end

function PhotoEditing:GetDecorateData(name)
  return self.decorateDatas_[name]
end

function PhotoEditing:GetDecorateCount()
  return self.decorateUnitCount_
end

function PhotoEditing:GetDecorateTextCount()
  return self.decorateTextCount_
end

function PhotoEditing:EditorDecorateText(text)
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    self.activeData_.textValue = text
    return self.activeData_
  else
    Z.TipsVM.ShowTipsLang(1000000)
    return nil
  end
end

function PhotoEditing:EditorDecorateTextFontSize(size)
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    self.activeData_.textSize = size
    return self.activeData_
  else
    return nil
  end
end

function PhotoEditing:EditorDecorateTextFontColor(color)
  if self.activeData_ and self.activeData_.decorateType == E.CamerasysFuncType.Text then
    self.activeData_.textColor = color
    return self.activeData_
  else
    return nil
  end
end

function PhotoEditing:getDecorateDataFromPool()
  for key, data in pairs(self.decorateDataPool_) do
    local res = data
    self.decorateDataPool_[key] = nil
    res.number = self.decorateUnitCount_ + 1
    return res
  end
  local tempData = {}
  tempData.name = "decorate" .. self.decorateUnitCount_ + 1
  tempData.number = self.decorateUnitCount_ + 1
  return tempData
end

function PhotoEditing:GetShotSetData()
  return self.shotSetData_
end

function PhotoEditing:GetFilter()
  if self.shotSetData_ and self.shotSetData_.filterData then
    return self.shotSetData_.filterData
  else
    return ""
  end
end

function PhotoEditing:SetFilter(filterData)
  if self.shotSetData_ == nil then
    self.shotSetData_ = {}
  end
  self.shotSetData_.filterData = filterData
end

function PhotoEditing:GetExposure()
  return self.moviescreen_exposure
end

function PhotoEditing:SetExposure(exposure)
  self.moviescreen_exposure = exposure
end

function PhotoEditing:ResetExposure()
  if self.shotSetData_ and self.shotSetData_.exposure then
    self.moviescreen_exposure = self.shotSetData_.exposure
  else
    local cameraData_ = Z.DataMgr.Get("camerasys_data")
    local exposure = cameraData_:GetScreenBrightnessRange()
    self.moviescreen_exposure = exposure.define
  end
end

function PhotoEditing:GetContrast()
  return self.moviescreen_contrast
end

function PhotoEditing:SetContrast(contrast)
  self.moviescreen_contrast = contrast
end

function PhotoEditing:ResetContrast()
  if self.shotSetData_ and self.shotSetData_.contrast then
    self.moviescreen_contrast = self.shotSetData_.contrast
  else
    local cameraData_ = Z.DataMgr.Get("camerasys_data")
    local contrast = cameraData_:GetScreenContrastRange()
    self.moviescreen_contrast = contrast.define
  end
end

function PhotoEditing:GetSaturation()
  return self.moviescreen_saturation
end

function PhotoEditing:SetSaturation(saturation)
  self.moviescreen_saturation = saturation
end

function PhotoEditing:ResetSaturation()
  if self.shotSetData_ and self.shotSetData_.saturation then
    self.moviescreen_saturation = self.shotSetData_.saturation
  else
    local cameraData_ = Z.DataMgr.Get("camerasys_data")
    local saturation = cameraData_:GetScreenSaturationRange()
    self.moviescreen_saturation = saturation.define
  end
end

return PhotoEditing
