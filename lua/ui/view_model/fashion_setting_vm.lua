local SETTING_KEY = 201
local getCurFashionSettingRegionDict = function()
  local setting = Z.ContainerMgr.CharSerialize.settingData.settingMap[SETTING_KEY]
  local regionStrList = string.split(setting, "|")
  local regionDict = {}
  for _, regionStr in pairs(regionStrList) do
    local data = string.split(regionStr, "=")
    local region = tonumber(data[1])
    local intIsOpen = tonumber(data[2])
    if region then
      regionDict[region] = intIsOpen
    end
  end
  return regionDict
end
local getFashionRegionIsHide = function(region)
  local allSetting = getCurFashionSettingRegionDict()
  return allSetting[region] == 2
end
local regionDictToSettingStr = function(regionDict)
  local str = ""
  for region, intIsOpen in pairs(regionDict) do
    str = str .. region .. "=" .. intIsOpen .. "|"
  end
  return str
end
local setFashionRegionIsHide = function(regionHideDict)
  local regionDict = getCurFashionSettingRegionDict()
  for region, isHide in pairs(regionHideDict) do
    regionDict[region] = isHide and 2 or 1
  end
  local str = regionDictToSettingStr(regionDict)
  local data = {}
  data[SETTING_KEY] = str
  Z.VMMgr.GetVM("setting").AsyncSaveSetting(data)
  Z.EventMgr:Dispatch(Z.ConstValue.FashionAttrChange, Z.LocalAttr.EWearSetting, str)
end
local checkFashionRegionWear = function(region, isHide)
  if isHide then
    return
  end
  local data = Z.DataMgr.Get("fashion_data")
  local styleData = data:GetWear(region)
  if not styleData or styleData.fashionId <= 0 then
    return
  end
  local colorData = data:GetColor(styleData.fashionId)
  if not colorData then
    return
  end
  local fashionVM = Z.VMMgr.GetVM("fashion")
  fashionVM.ShowFashionColor(styleData.fashionId)
end
local setSingleFashionRegionIsHide = function(region, isHide)
  local regionHideDict = {}
  regionHideDict[region] = isHide
  setFashionRegionIsHide(regionHideDict)
  checkFashionRegionWear(region, isHide)
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local param = {
    str = fashionVM.GetRegionName(region)
  }
  if isHide then
    Z.TipsVM.ShowTipsLang(120013, param)
  else
    Z.TipsVM.ShowTipsLang(120014, param)
  end
end
local ret = {
  GetCurFashionSettingRegionDict = getCurFashionSettingRegionDict,
  GetFashionRegionIsHide = getFashionRegionIsHide,
  SetFashionRegionIsHide = setFashionRegionIsHide,
  SetSingleFashionRegionIsHide = setSingleFashionRegionIsHide,
  RegionDictToSettingStr = regionDictToSettingStr
}
return ret
