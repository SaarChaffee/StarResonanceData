local super = require("ui.model.data_base")
local PhotoSecondary = class("PhotoSecondary", super)
local camerasysData = Z.DataMgr.Get("camerasys_data")

function PhotoSecondary:ctor()
  super.ctor(self)
  self.decorateData_ = {}
  self.decorateOriData_ = {}
  self.shotsetData_ = {}
  self.shotsetData_.exposure = 0
  self.shotsetData_.contrast = 0
  self.shotsetData_.saturation = 0
  self.shotsetData_.filterData = ""
  self.shotsetData_.frameData = Z.ConstValue.Album.DefineFrame
  self.shotsetOriData_ = {}
  self.shotsetOriData_.exposure = 0
  self.shotsetOriData_.contrast = 0
  self.shotsetOriData_.saturation = 0
  self.shotsetOriData_.filterData = ""
  self.shotsetOriData_.frameData = Z.ConstValue.Album.DefineFrame
  self.DecoreateNum = 0
  self.DecorationTextNum = 0
end

function PhotoSecondary:ClearDecorateData()
  self.decorateData_ = {}
  self.decorateOriData_ = {}
  self.DecoreateNum = 0
  self.DecorationTextNum = 0
end

function PhotoSecondary:InitDecorateData(item, baseData)
  local decorateData = {}
  decorateData.decorateType = baseData.decorateType
  decorateData.number = baseData.commonData.number
  decorateData.pos = {x = 0, y = 0}
  decorateData.rotateZ = 0
  decorateData.transparency = 1
  if decorateData.decorateType == E.CamerasysFuncType.Sticker then
    decorateData.res = baseData.res
    decorateData.iconScale = {x = 0.5, y = 0.5}
    decorateData.isFlip = false
  elseif decorateData.decorateType == E.CamerasysFuncType.Text then
    decorateData.textValue = baseData.typeData
    decorateData.textSize = Z.DataMgr.Get("camerasys_data"):GetTextFontSize()
    decorateData.color = {
      r = 1,
      b = 1,
      g = 1,
      a = 1
    }
    decorateData.colorIndex = 0
    decorateData.textScale = {x = 0, y = 0}
  end
  self.decorateData_[item.name] = decorateData
end

function PhotoSecondary:SetDecorateData(decorateData)
  self.decorateData_ = decorateData
  self.decorateOriData_ = decorateData
end

function PhotoSecondary:GetDecorateData(item)
  return self.decorateData_[item.name]
end

function PhotoSecondary:DeleteDecorateData(item)
  self.decorateData_[item.name] = nil
end

function PhotoSecondary:InitMoviescreenData()
  self.shotsetData_.exposure = camerasysData:GetScreenBrightnessRange().define
  self.shotsetData_.contrast = camerasysData:GetScreenContrastRange().define
  self.shotsetData_.saturation = camerasysData:GetScreenSaturationRange().define
  self.shotsetData_.filterData = ""
  self.shotsetData_.frameData = Z.ConstValue.Album.DefineFrame
end

function PhotoSecondary:GetMoviescreenData()
  return self.shotsetData_
end

function PhotoSecondary:GetMoviescreenOriData()
  return self.shotsetOriData_
end

function PhotoSecondary:SetMoviescreenData(shotsetData)
  self.shotsetData_ = shotsetData
  local oriData = {}
  oriData.contrast = shotsetData.contrast
  oriData.exposure = shotsetData.exposure
  oriData.filterData = shotsetData.filterData
  oriData.frameData = shotsetData.frameData
  oriData.saturation = shotsetData.saturation
  self.shotsetOriData_ = oriData
end

function PhotoSecondary:CopyMoviescreenOriData()
  local oriData = {}
  oriData.contrast = self.shotsetData_.contrast
  oriData.exposure = self.shotsetData_.exposure
  oriData.filterData = self.shotsetData_.filterData
  oriData.frameData = self.shotsetData_.frameData
  oriData.saturation = self.shotsetData_.saturation
  self.shotsetOriData_ = oriData
end

function PhotoSecondary:DeleteMoviescreenData()
  self.shotsetData_ = {}
  self.shotsetOriData_ = {}
end

function PhotoSecondary:SavaDecorateData()
  local tab = {}
  tab.decorateData = self.decorateData_
  tab.shotsetData = self.shotsetData_
end

function PhotoSecondary:GetMoviescreenTempData()
  local tab = {}
  tab.decorateData = self.decorateData_
  tab.shotsetData = self.shotsetData_
  return tab
end

function PhotoSecondary:AddDecoreateNum(num)
  self.DecoreateNum = self.DecoreateNum + num
end

function PhotoSecondary:SetDecoreateNum(num)
  self.DecoreateNum = num
end

function PhotoSecondary:GetDecoreateNum()
  return self.DecoreateNum
end

return PhotoSecondary
