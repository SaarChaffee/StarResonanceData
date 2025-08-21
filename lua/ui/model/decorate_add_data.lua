local super = require("ui.model.data_base")
local DecorateAdd = class("DecorateAdd", super)
local camerasysData = Z.DataMgr.Get("camerasys_data")

function DecorateAdd:ctor()
  super.ctor(self)
  self.decorateData_ = {}
  self.shotsetData_ = {}
  self.shotsetData_.exposure = 0
  self.shotsetData_.contrast = 0
  self.shotsetData_.saturation = 0
  self.shotsetData_.filterData = ""
  self.shotsetData_.frameData = ""
  self.DecoreateNum = 0
  self.DecorationTextNum = 0
end

function DecorateAdd:ClearDecorateData()
  self.decorateData_ = {}
  self.DecoreateNum = 0
  self.DecorationTextNum = 0
end

function DecorateAdd:InitDecorateData(item, baseData)
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
    decorateData.stickType = baseData.typeData.Parameter
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
    decorateData.stickType = nil
  end
  self.decorateData_[item.name] = decorateData
end

function DecorateAdd:SetDecorateData(decorateData)
  self.decorateData_ = decorateData
end

function DecorateAdd:GetDecorateData(item)
  return self.decorateData_[item.name]
end

function DecorateAdd:DeleteDecorateData(item)
  self.decorateData_[item.name] = nil
end

function DecorateAdd:InitMoviescreenData()
  self.shotsetData_.exposure = camerasysData:GetScreenBrightnessRange().define
  self.shotsetData_.contrast = camerasysData:GetScreenContrastRange().define
  self.shotsetData_.saturation = camerasysData:GetScreenSaturationRange().define
  self.shotsetData_.filterData = ""
  self.shotsetData_.frameData = ""
end

function DecorateAdd:GetMoviescreenData()
  return self.shotsetData_
end

function DecorateAdd:SetMoviescreenDataEX(shotsetData)
  self.shotsetData_.exposure = shotsetData.exposure
  self.shotsetData_.contrast = shotsetData.contrast
  self.shotsetData_.saturation = shotsetData.saturation
  self.shotsetData_.filterData = shotsetData.filterData
end

function DecorateAdd:SetMoviescreenData(shotsetData)
  self.shotsetData_ = shotsetData
end

function DecorateAdd:DeleteMoviescreenData()
  self.shotsetData_ = {}
end

function DecorateAdd:SavaDecorateData()
  local tab = {}
  tab.decorateData = self.decorateData_
  tab.shotsetData = self.shotsetData_
end

function DecorateAdd:GetMoviescreenTempData()
  local tab = {}
  tab.decorateData = self.decorateData_
  tab.shotsetData = self.shotsetData_
  return tab
end

function DecorateAdd:AddDecoreateNum(num)
  self.DecoreateNum = self.DecoreateNum + num
end

function DecorateAdd:SetDecoreateNum(num)
  self.DecoreateNum = num
end

function DecorateAdd:GetDecoreateNum()
  return self.DecoreateNum
end

return DecorateAdd
