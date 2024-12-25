local FaceDef = require("ui.model.face_define")
local PRECISION = 10000
local FaceOptionDataBase = class("FaceOptionDataBase")

function FaceOptionDataBase:ctor(optionEnum)
  self.optionEnum_ = optionEnum
  self.value_ = self:getDefaultValue()
end

function FaceOptionDataBase:GetOptionEnum()
  return self.optionEnum_
end

function FaceOptionDataBase:GetOptionValueType()
  error("func must be override!")
end

function FaceOptionDataBase:GetValue()
  if type(self.value_) == "table" then
    return table.zclone(self.value_)
  else
    return self.value_
  end
end

function FaceOptionDataBase:SetValue(value, isLimit)
  error("func must be override!")
end

function FaceOptionDataBase:GetProtoValue()
  error("func must be override!")
end

function FaceOptionDataBase:SetByProtoValue(protoValue)
  error("func must be override!")
end

function FaceOptionDataBase:GetLocalValue(protoValue)
  error("func must be override!")
end

function FaceOptionDataBase:IsEqualTo(value)
  return self.value_ == value
end

function FaceOptionDataBase:getDefaultValue()
  error("func must be override!")
end

local FaceOptionIdData = class("FaceOptionIdData", FaceOptionDataBase)

function FaceOptionIdData:GetOptionValueType()
  return FaceDef.EOptionValueType.Id
end

function FaceOptionIdData:SetValue(value, isLimit)
  if type(value) == "number" then
    self.value_ = math.floor(value + 0.5)
  else
    logError("[FaceOption SetValue] \228\184\141\230\148\175\230\140\129\231\154\132value\231\177\187\229\158\139, optionEnum = {0}", self.optionEnum_)
  end
end

function FaceOptionIdData:GetProtoValue()
  return self.value_
end

function FaceOptionIdData:SetByProtoValue(protoValue)
  self:SetValue(protoValue)
end

function FaceOptionIdData:GetLocalValue(protoValue)
  return math.floor(protoValue + 0.5)
end

function FaceOptionIdData:getDefaultValue()
  return 0
end

local FaceOptionFloatData = class("FaceOptionFloatData", FaceOptionDataBase)

function FaceOptionFloatData:GetOptionValueType()
  return FaceDef.EOptionValueType.Float
end

function FaceOptionFloatData:SetValue(value, isLimit)
  if type(value) == "number" then
    self.value_ = value
  else
    logError("[FaceOption SetValue] \228\184\141\230\148\175\230\140\129\231\154\132value\231\177\187\229\158\139, optionEnum = {0}", self.optionEnum_)
  end
end

function FaceOptionFloatData:GetProtoValue()
  return math.floor(self.value_ * PRECISION + 0.5)
end

function FaceOptionFloatData:SetByProtoValue(protoValue)
  self:SetValue(protoValue / PRECISION)
end

function FaceOptionFloatData:GetLocalValue(protoValue)
  return protoValue / PRECISION
end

function FaceOptionFloatData:IsEqualTo(value)
  if type(value) ~= "number" then
    return false
  end
  return math.abs(self.value_ - value) < 1 / PRECISION
end

function FaceOptionFloatData:getDefaultValue()
  return 0
end

local FaceOptionHSVData = class("FaceOptionHSVData", FaceOptionDataBase)

function FaceOptionHSVData:GetOptionValueType()
  return FaceDef.EOptionValueType.HSV
end

function FaceOptionHSVData:SetValue(value, isLimit)
  if type(value) == "table" then
    for k, v in pairs(value) do
      self.value_[k] = v
    end
  else
    logError("[FaceOption SetValue] \228\184\141\230\148\175\230\140\129\231\154\132value\231\177\187\229\158\139, optionEnum = {0}", self.optionEnum_)
  end
end

function FaceOptionHSVData:GetProtoValue()
  local intX = math.floor(self.value_.h * PRECISION + 0.5)
  local intY = math.floor(self.value_.s * PRECISION + 0.5)
  local intZ = math.floor(self.value_.v * PRECISION + 0.5)
  return {
    x = intX,
    y = intY,
    z = intZ
  }
end

function FaceOptionHSVData:SetByProtoValue(protoValue)
  local hsv = {
    h = protoValue.x / PRECISION,
    s = protoValue.y / PRECISION,
    v = protoValue.z / PRECISION
  }
  self:SetValue(hsv)
end

function FaceOptionHSVData:GetLocalValue(protoValue)
  return {
    h = protoValue.x / PRECISION,
    s = protoValue.y / PRECISION,
    v = protoValue.z / PRECISION
  }
end

function FaceOptionHSVData:IsEqualTo(value)
  if type(value) ~= "table" then
    return false
  end
  local maxDiff = 1 / PRECISION
  return maxDiff > math.abs(self.value_.h - value.h) and maxDiff > math.abs(self.value_.s - value.s) and maxDiff > math.abs(self.value_.v - value.v)
end

function FaceOptionHSVData:getDefaultValue()
  return Z.ColorHelper.GetDefaultHSV()
end

local FaceOptionBoolData = class("FaceOptionBoolData", FaceOptionDataBase)

function FaceOptionBoolData:GetOptionValueType()
  return FaceDef.EOptionValueType.Bool
end

function FaceOptionBoolData:SetValue(value, isLimit)
  if type(value) == "boolean" then
    self.value_ = value
  else
    logError("[FaceOption SetValue] \228\184\141\230\148\175\230\140\129\231\154\132value\231\177\187\229\158\139, optionEnum = {0}", self.optionEnum_)
  end
end

function FaceOptionBoolData:GetProtoValue()
  return self.value_ and 1 or 0
end

function FaceOptionBoolData:SetByProtoValue(protoValue)
  self:SetValue(protoValue == 1)
end

function FaceOptionBoolData:GetLocalValue(protoValue)
  return protoValue == 1
end

function FaceOptionBoolData:getDefaultValue()
  return false
end

local createFaceOption = function(optionEnum)
  local row = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
  if row then
    local valueType = row.Option
    if valueType == FaceDef.EOptionValueType.Id then
      return FaceOptionIdData.new(optionEnum)
    elseif valueType == FaceDef.EOptionValueType.Float then
      return FaceOptionFloatData.new(optionEnum)
    elseif valueType == FaceDef.EOptionValueType.HSV then
      return FaceOptionHSVData.new(optionEnum)
    elseif valueType == FaceDef.EOptionValueType.Bool then
      return FaceOptionBoolData.new(optionEnum)
    else
      logError("[createFaceOption] \233\128\137\233\161\185\231\177\187\229\158\139\228\184\141\229\173\152\229\156\168, optionEnum = {0}, valueType = {1}", optionEnum, valueType)
    end
  end
end
local ret = {CreateFaceOption = createFaceOption}
return ret
