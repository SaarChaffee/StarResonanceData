local closePortraitView = function()
  Z.UIMgr:CloseView("portrait_indiv_popup")
end
local openPortraitView = function(viewData)
  Z.UIMgr:OpenView("portrait_indiv_popup", viewData)
end
local checkPortraitUnlock = function(portraitId)
  return true
end
local getNowPortrait = function()
  local avatarId = 1
  if Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId ~= 0 then
    avatarId = Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId
  end
  return avatarId
end
local asyncSetPortrait = function(portraitId, cancelToken)
  local socialProxy = require("zproxy.social_proxy")
  local request = {}
  request.avatarId = portraitId
  local ret = socialProxy.ChangeAvatar(request, cancelToken)
  if ret.errCode == 0 and ret.success then
    Z.EventMgr:Dispatch(Z.ConstValue.ChangeRoleAvatar, ret.avatarId)
  end
end
local getAllPortrait = function()
  local datatable = Z.TableMgr.GetTable("ProfileImageTableMgr").GetDatas()
  local data = {}
  for index, value in pairs(datatable) do
    table.insert(data, value)
  end
  table.sort(data, function(a, b)
    return a.Id < b.Id
  end)
  return data
end
local portraitId2Index = function(data, portraitId)
  for index, value in ipairs(data) do
    if value.Id == portraitId then
      return index
    end
  end
  return 1
end
local ret = {
  ClosePortraitView = closePortraitView,
  OpenPortraitView = openPortraitView,
  CheckPortraitUnlock = checkPortraitUnlock,
  GetNowPortrait = getNowPortrait,
  AsyncSetPortrait = asyncSetPortrait,
  GetAllPortrait = getAllPortrait,
  PortraitId2Index = portraitId2Index
}
return ret
