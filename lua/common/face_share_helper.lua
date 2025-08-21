local FaceShareHelper = {}
local ECodeType = {EFaceShareCode = 1}
local faceShareFly = "Star/"
local faceSchemeFlg = "PREFACEMODE"
local FaceShareCodeVersion = 1
local FaceShareCodeOptionArrayVersion1 = {
  [1] = {id = 1, type = 3},
  [2] = {id = 11, type = 2},
  [3] = {id = 12, type = 2},
  [4] = {id = 13, type = 2},
  [5] = {id = 14, type = 2},
  [6] = {id = 15, type = 2},
  [7] = {id = 16, type = 2},
  [8] = {id = 17, type = 2},
  [9] = {id = 18, type = 2},
  [10] = {id = 101, type = 1},
  [11] = {id = 102, type = 1},
  [12] = {id = 103, type = 1},
  [13] = {id = 104, type = 1},
  [14] = {id = 10101, type = 3},
  [15] = {id = 10102, type = 4},
  [16] = {id = 10103, type = 3},
  [17] = {id = 10104, type = 2},
  [18] = {id = 10105, type = 4},
  [19] = {id = 10106, type = 3},
  [20] = {id = 10107, type = 4},
  [21] = {id = 10108, type = 3},
  [22] = {id = 401, type = 1},
  [23] = {id = 40101, type = 2},
  [24] = {id = 402, type = 1},
  [25] = {id = 40201, type = 2},
  [26] = {id = 40202, type = 3},
  [27] = {id = 404, type = 1},
  [28] = {id = 40401, type = 2},
  [29] = {id = 40402, type = 2},
  [30] = {id = 403, type = 1},
  [31] = {id = 40301, type = 3},
  [32] = {id = 301, type = 1},
  [33] = {id = 30101, type = 4},
  [34] = {id = 30102, type = 4},
  [35] = {id = 30103, type = 3},
  [36] = {id = 30104, type = 3},
  [37] = {id = 30105, type = 3},
  [38] = {id = 30106, type = 3},
  [39] = {id = 30107, type = 3},
  [40] = {id = 30108, type = 3},
  [41] = {id = 30109, type = 3},
  [42] = {id = 30110, type = 3},
  [43] = {id = 30111, type = 2},
  [44] = {id = 30112, type = 2},
  [45] = {id = 405, type = 1},
  [46] = {id = 40501, type = 2},
  [47] = {id = 406, type = 1},
  [48] = {id = 407, type = 1},
  [49] = {id = 40701, type = 3},
  [50] = {id = 408, type = 1},
  [51] = {id = 40801, type = 3},
  [52] = {id = 409, type = 1},
  [53] = {id = 40901, type = 3},
  [54] = {id = 410, type = 1},
  [55] = {id = 201, type = 1},
  [56] = {id = 20101, type = 2},
  [57] = {id = 20102, type = 2},
  [58] = {id = 20103, type = 2},
  [59] = {id = 20104, type = 2},
  [60] = {id = 20105, type = 4},
  [61] = {id = 20106, type = 3},
  [62] = {id = 202, type = 1},
  [63] = {id = 20201, type = 2},
  [64] = {id = 20202, type = 2},
  [65] = {id = 20203, type = 2},
  [66] = {id = 20204, type = 2},
  [67] = {id = 20205, type = 4},
  [68] = {id = 20206, type = 3}
}
local faceCodeValueTypeList = {
  [1] = 3,
  [2] = 3,
  [3] = 3,
  [4] = 3,
  [5] = 3,
  [6] = 3,
  [7] = 5,
  [8] = 2,
  [9] = 2,
  [10] = 2,
  [11] = 2,
  [12] = 2,
  [13] = 2,
  [14] = 2,
  [15] = 2,
  [16] = 1,
  [17] = 1,
  [18] = 1,
  [19] = 1,
  [20] = 5,
  [21] = 3,
  [22] = 5,
  [23] = 3,
  [24] = 3,
  [25] = 5,
  [26] = 3,
  [27] = 5,
  [28] = 1,
  [29] = 2,
  [30] = 1,
  [31] = 2,
  [32] = 5,
  [33] = 1,
  [34] = 2,
  [35] = 2,
  [36] = 1,
  [37] = 5,
  [38] = 1,
  [39] = 3,
  [40] = 3,
  [41] = 5,
  [42] = 5,
  [43] = 5,
  [44] = 5,
  [45] = 5,
  [46] = 5,
  [47] = 5,
  [48] = 5,
  [49] = 2,
  [50] = 2,
  [51] = 1,
  [52] = 2,
  [53] = 1,
  [54] = 1,
  [55] = 5,
  [56] = 1,
  [57] = 5,
  [58] = 1,
  [59] = 5,
  [60] = 1,
  [61] = 1,
  [62] = 4,
  [63] = 4,
  [64] = 2,
  [65] = 2,
  [66] = 3,
  [67] = 5,
  [68] = 1,
  [69] = 4,
  [70] = 4,
  [71] = 2,
  [72] = 2,
  [73] = 3,
  [74] = 5
}
local CodeValueFunc = {
  [1] = function(value)
    return value
  end,
  [2] = function(value)
    return math.floor(value * 100 + 0.5)
  end,
  [3] = function(hsv)
    local h = math.floor(hsv.h * 360 + 0.5) & 65535
    local s = math.floor(hsv.s * 100 + 0.5) & 255
    local v = math.floor(hsv.v * 100 + 0.5) & 255
    return h << 16 | s << 8 | v
  end,
  [4] = function(value)
    return value and 1 or 0
  end,
  [5] = function(value)
    return math.floor(value * 10000 + 0.5)
  end
}
local RealValueFunc = {
  [1] = function(value)
    return value
  end,
  [2] = function(value)
    return value * 0.01
  end,
  [3] = function(value)
    local h = value >> 16 & 65535
    local s = value >> 8 & 255
    local v = value & 255
    return {
      h = h / 360,
      s = s * 0.01,
      v = v * 0.01
    }
  end,
  [4] = function(value)
    if value == 1 then
      return true
    else
      return false
    end
  end,
  [5] = function(value)
    return value * 1.0E-4
  end
}

function FaceShareHelper.IsFaceShareScheme(schemeFlg)
  if #schemeFlg < #faceSchemeFlg then
    return false
  end
  local flg = string.sub(schemeFlg, #schemeFlg - #faceSchemeFlg, #schemeFlg)
  return flg == faceSchemeFlg
end

function FaceShareHelper.IsFaceShareCode(data)
  if data == "" then
    return false
  end
  local fly = string.sub(data, 1, #faceShareFly)
  if fly ~= faceShareFly then
    return false
  end
  local codeData = string.sub(data, #faceShareFly + 1, -1)
  local valueList = Z.ShareCodeUtils.DecodeContent(codeData, faceCodeValueTypeList)
  local codeType = valueList[0]
  local version = valueList[1]
  if codeType ~= ECodeType.EFaceShareCode or version ~= FaceShareCodeVersion then
    return false
  end
  return true
end

function FaceShareHelper.UseFaceShareCode(data, useGenderSize, ignoreTips)
  if data == "" then
    Z.TipsVM.ShowTips(120019)
    return false
  end
  local fly = string.sub(data, 1, #faceShareFly)
  if fly ~= faceShareFly then
    Z.TipsVM.ShowTips(120019)
    return false
  end
  local codeData = string.sub(data, #faceShareFly + 1, -1)
  local valueList = Z.ShareCodeUtils.DecodeContent(codeData, faceCodeValueTypeList)
  if valueList.Length < 2 then
    Z.TipsVM.ShowTips(120019)
    return false
  end
  local codeType = valueList[0]
  local version = valueList[1]
  if codeType ~= ECodeType.EFaceShareCode or version ~= FaceShareCodeVersion then
    Z.TipsVM.ShowTips(120019)
    return false
  end
  local param1 = valueList[2]
  local param2 = valueList[3]
  local gender = valueList[4]
  local bodySize = valueList[5]
  local faceData = Z.DataMgr.Get("face_data")
  if useGenderSize then
    faceData.Gender = gender
    faceData.BodySize = bodySize
    faceData.ModelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, bodySize)
  elseif codeType ~= ECodeType.EFaceShareCode or version ~= FaceShareCodeVersion then
    Z.TipsVM.ShowTips(120019)
    return false
  end
  if gender ~= faceData:GetPlayerGender() or bodySize ~= faceData:GetPlayerBodySize() then
    Z.TipsVM.ShowTips(120017)
    return false
  end
  local faceLuaData = {}
  for i = 1, #FaceShareCodeOptionArrayVersion1 do
    if i <= valueList.Length - 5 then
      local valueData = FaceShareCodeOptionArrayVersion1[i]
      faceLuaData[valueData.id] = RealValueFunc[valueData.type](valueList[i + 5])
    end
  end
  local faceVm = Z.VMMgr.GetVM("face")
  faceVm.UseFashionLuaDataWithDefaultValue(faceLuaData, true, true)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
  if not ignoreTips then
    Z.TipsVM.ShowTips(120029)
  end
  return true
end

function FaceShareHelper.CreateFaceShareCode()
  local faceData = Z.DataMgr.Get("face_data")
  local gender = faceData:GetPlayerGender()
  local bodySize = faceData:GetPlayerBodySize()
  local valueList = {
    [1] = ECodeType.EFaceShareCode,
    [2] = FaceShareCodeVersion,
    [3] = 0,
    [4] = 0,
    [5] = gender,
    [6] = bodySize
  }
  for i = 1, #FaceShareCodeOptionArrayVersion1 do
    local optionData = FaceShareCodeOptionArrayVersion1[i]
    local optionEnum = optionData.id
    local valueType = optionData.type
    local optionValue = faceData:GetFaceOptionValue(optionEnum)
    valueList[#valueList + 1] = CodeValueFunc[valueType](optionValue)
  end
  local faceShareCode = Z.ShareCodeUtils.EncodeContnent(valueList, faceCodeValueTypeList)
  return faceShareFly .. faceShareCode
end

E.QrCodeErrorCode = {
  Success = 0,
  PathNull = 1,
  OpenFileFail = 2,
  ScanQrFail = 3
}
local OpenFaceShareErrorTips = {
  [E.QrCodeErrorCode.PathNull] = 120026,
  [E.QrCodeErrorCode.OpenFileFail] = 120026,
  [E.QrCodeErrorCode.ScanQrFail] = 120027
}

function FaceShareHelper.OpenFaceShareFiler()
  local picturePath = Z.LuaBridge.GetShareCodeFilePath()
  if picturePath == "" then
    Z.TipsVM.ShowTips(120026)
    return
  end
  Z.QrCodeUtil.OpenQrCodeFile(picturePath, Lang("WindowOpenFaceShareFileTitle"), Lang("WindowOpenFaceShareFileType"), function(errorCode, result)
    if errorCode == E.QrCodeErrorCode.Success then
      FaceShareHelper.UseFaceShareCode(result)
    else
      Z.TipsVM.ShowTips(OpenFaceShareErrorTips[errorCode])
    end
  end)
end

return FaceShareHelper
