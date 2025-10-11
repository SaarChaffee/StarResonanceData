local cls = {}
local worldProxy = require("zproxy.world_proxy")
local DEFINE = require("ui.model.personalzone_define")

function cls.OpenAwardPopView(id)
  local personalzoneData = Z.DataMgr.Get("personal_zone_data")
  if personalzoneData:IsIgnorePopup() then
    return
  end
  local type
  local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(id, true)
  if profileImageConfig then
    type = profileImageConfig.Type
  else
    type = DEFINE.ProfileImageType.Medal
  end
  local viewData = {type = type, id = id}
  Z.UIMgr:OpenView("personalzone_obtained_popup", viewData)
end

function cls.GetProfileImageList(type)
  local datas = {}
  local itemsVM = Z.VMMgr.GetVM("items")
  local personalzoneData = Z.DataMgr.Get("personal_zone_data")
  local configs = personalzoneData:GetProfileImageConfigsByType(type)
  local tempItemsCount = {}
  if configs then
    for _, config in pairs(configs) do
      if (config.IsHide == nil or config.IsHide == 0) and Z.ConditionHelper.CheckCondition(config.Condition, false) then
        if config.Unlock == DEFINE.ProfileImageUnlockType.DefaultUnlock then
          table.insert(datas, config)
        elseif config.Unlock == DEFINE.ProfileImageUnlockType.GetUnlock then
          if config.NotUnlock and config.NotUnlock == 1 then
            local itemsCount = itemsVM.GetItemTotalCount(config.Id)
            if itemsCount and 0 < itemsCount then
              tempItemsCount[config.Id] = itemsCount
              table.insert(datas, config)
            end
          else
            local itemsCount = itemsVM.GetItemTotalCount(config.Id)
            tempItemsCount[config.Id] = itemsCount
            table.insert(datas, config)
          end
        end
      end
    end
  end
  local useId = cls.GetCurProfileImageId(type)
  table.sort(datas, function(a, b)
    if a.Unlock == b.Unlock then
      local aUse = useId == a.Id and 0 or 1
      local bUse = useId == b.Id and 0 or 1
      if aUse == bUse then
        local itemsACount = tempItemsCount[a.Id]
        local itemsBCount = tempItemsCount[b.Id]
        if itemsACount == itemsBCount then
          local aRed = cls.CheckSingleRedDot(a.Id) and 0 or 1
          local bRed = cls.CheckSingleRedDot(b.Id) and 0 or 1
          if aRed == bRed then
            return a.Sort < b.Sort
          else
            return aRed < bRed
          end
        else
          return itemsACount > itemsBCount
        end
      else
        return aUse < bUse
      end
    else
      return a.Unlock > b.Unlock
    end
  end)
  return datas
end

function cls.CheckProfileImageIsUnlock(id)
  local itemsVM = Z.VMMgr.GetVM("items")
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(id, true)
  if config then
    if config.Unlock and config.Unlock == DEFINE.ProfileImageUnlockType.GetUnlock then
      local itemsCount = itemsVM.GetItemTotalCount(config.Id)
      if itemsCount and 0 < itemsCount then
        return true
      end
    else
      return true
    end
  else
    local itemsCount = itemsVM.GetItemTotalCount(id)
    if itemsCount and 0 < itemsCount then
      return true
    end
  end
  return false
end

function cls.GetCurProfileImageId(type)
  local personalZoneData = Z.DataMgr.Get("personal_zone_data")
  local id = personalZoneData:GetDefaultProfileImageConfigByType(type)
  if type == DEFINE.ProfileImageType.Head then
    if Z.ContainerMgr.CharSerialize.charBase and Z.ContainerMgr.CharSerialize.charBase.avatarInfo and Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId then
      id = Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId
    end
  elseif type == DEFINE.ProfileImageType.HeadFrame then
    if Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.avatarFrameId and Z.ContainerMgr.CharSerialize.personalZone.avatarFrameId ~= 0 then
      id = Z.ContainerMgr.CharSerialize.personalZone.avatarFrameId
    end
  elseif type == DEFINE.ProfileImageType.Card then
    if Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.businessCardStyleId and Z.ContainerMgr.CharSerialize.personalZone.businessCardStyleId ~= 0 then
      id = Z.ContainerMgr.CharSerialize.personalZone.businessCardStyleId
    end
  elseif type == DEFINE.ProfileImageType.PersonalzoneBg then
    if Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.themeId and Z.ContainerMgr.CharSerialize.personalZone.themeId ~= 0 then
      id = Z.ContainerMgr.CharSerialize.personalZone.themeId
    end
  elseif type == DEFINE.ProfileImageType.Title and Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.titleId and Z.ContainerMgr.CharSerialize.personalZone.titleId ~= 0 then
    id = Z.ContainerMgr.CharSerialize.personalZone.titleId
  end
  return id
end

function cls.CheckSingleRedDot(id)
  local personalzone_data = Z.DataMgr.Get("personal_zone_data")
  local config = personalzone_data:GetProfileImageTarget(id)
  if config and config.currentNum >= config.profileImageTargetConfig.Num and not cls.CheckProfileImageIsUnlock(id) then
    return true
  end
  local itemRedDot = personalzone_data:GetAllRedDotItem()
  if itemRedDot[id] then
    return true
  end
  return false
end

function cls.CheckRed()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isPersonalzone = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone, true)
  if not isPersonalzone then
    return
  end
  local isPersonalzoneRecord = gotoFuncVM.CheckFuncCanUse(E.FunctionID.PersonalzoneRecord, true)
  if not isPersonalzoneRecord then
    return
  end
  local reddotType = {
    [DEFINE.ProfileImageType.Head] = false,
    [DEFINE.ProfileImageType.HeadFrame] = false,
    [DEFINE.ProfileImageType.Card] = false,
    [DEFINE.ProfileImageType.Medal] = false,
    [DEFINE.ProfileImageType.PersonalzoneBg] = false,
    [DEFINE.ProfileImageType.Title] = false
  }
  local personalzone_data = Z.DataMgr.Get("personal_zone_data")
  local unlockTargetConfig = personalzone_data:GetAllProfileImageTargets()
  for id, config in pairs(unlockTargetConfig) do
    if config.profileImageTargetConfig and config.currentNum >= config.profileImageTargetConfig.Num and not cls.CheckProfileImageIsUnlock(id) then
      if config.isProfileImageConfig then
        reddotType[config.profileImageConfig.Type] = true
      else
        reddotType[DEFINE.ProfileImageType.Medal] = true
      end
    end
  end
  local profileImageTableMgr = Z.TableMgr.GetTable("ProfileImageTableMgr")
  local allItemRedDot = personalzone_data:GetAllRedDotItem()
  for _, id in pairs(allItemRedDot) do
    local config = profileImageTableMgr.GetRow(id, true)
    if config == nil then
      reddotType[DEFINE.ProfileImageType.Medal] = true
    else
      reddotType[config.Type] = true
    end
  end
  for key, redDot in pairs(reddotType) do
    local redDotType = DEFINE.ProfileImageRedDot[key]
    local functionId = DEFINE.ProfileImageFunctionId[key]
    if functionId == nil or gotoFuncVM.CheckFuncCanUse(functionId, true) then
      if redDot then
        Z.RedPointMgr.UpdateNodeCount(redDotType, 1)
      else
        Z.RedPointMgr.UpdateNodeCount(redDotType, 0)
      end
    else
      Z.RedPointMgr.UpdateNodeCount(redDotType, 0)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnMedalRedDotRefresh)
end

function cls.CheckMedalRed_1()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isPersonalzone = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone, true)
  if not isPersonalzone then
    return false
  end
  local isPersonalzoneRecord = gotoFuncVM.CheckFuncCanUse(E.FunctionID.PersonalzoneRecord, true)
  if not isPersonalzoneRecord then
    return false
  end
  local personalzone_data = Z.DataMgr.Get("personal_zone_data")
  local unlockTargetConfig = personalzone_data:GetAllProfileImageTargets()
  for id, config in pairs(unlockTargetConfig) do
    if config.profileImageTargetConfig and config.currentNum >= config.profileImageTargetConfig.Num and not cls.CheckProfileImageIsUnlock(id) and not config.isProfileImageConfig then
      return true
    end
  end
  return false
end

function cls.CheckMedalRed_2()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isPersonalzone = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone, true)
  if not isPersonalzone then
    return false
  end
  local isPersonalzoneRecord = gotoFuncVM.CheckFuncCanUse(E.FunctionID.PersonalzoneRecord, true)
  if not isPersonalzoneRecord then
    return false
  end
  local personalzone_data = Z.DataMgr.Get("personal_zone_data")
  local profileImageTableMgr = Z.TableMgr.GetTable("ProfileImageTableMgr")
  local allItemRedDot = personalzone_data:GetAllRedDotItem()
  for _, id in pairs(allItemRedDot) do
    local config = profileImageTableMgr.GetRow(id, true)
    if config == nil then
      return true
    end
  end
  return false
end

function cls.GetItemExpireTime(configId)
  local itemsData = Z.DataMgr.Get("items_data")
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Personalzone]
  local itemUuids = itemsData:GetItemUuidsByConfigId(configId)
  if itemUuids == nil or #itemUuids < 1 then
    return 0
  end
  local uuid
  local expireTime = 0
  for _, v in ipairs(itemUuids) do
    if uuid == nil then
      uuid = v
      expireTime = package.items[v].expireTime
    else
      local tempExpireTime = package.items[v].expireTime
      if expireTime <= tempExpireTime then
        uuid = v
        expireTime = tempExpireTime
      end
    end
  end
  return expireTime
end

function cls.RefreshViewExpireTime(selectId, uibinder, lab)
  uibinder.Ref:SetVisible(lab, false)
  local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(selectId, true)
  if profileImageConfig and profileImageConfig.Unlock and profileImageConfig.Unlock == 1 then
    return
  end
  local config = Z.TableMgr.GetTable("ItemTableMgr").GetRow(selectId)
  if config == nil then
    return
  end
  local isUnlock = cls.CheckProfileImageIsUnlock(selectId)
  if config.TimeType ~= 0 and config.TimeType ~= 4 and isUnlock then
    uibinder.Ref:SetVisible(lab, true)
    local expireTime = cls.GetItemExpireTime(selectId)
    local timeStrYMDHMS = Z.TimeFormatTools.TicksFormatTime(expireTime, E.TimeFormatType.YMDHMS)
    local param = {str = timeStrYMDHMS}
    lab.text = Lang("Tips_TimeLimit_Valid", param)
  end
end

function cls.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function cls.AsyncGetPersonalZoneTargetAward(id, cancelToken)
  local request = {}
  request.id = id
  local reply = worldProxy.GetPersonalZoneTargetAward(request, cancelToken)
  return cls.CheckReply(reply)
end

function cls.OpenPersonalZoneMainByCharId(charId, cancelToken)
  Z.CoroUtil.create_coro_xpcall(function()
    local socialVM = Z.VMMgr.GetVM("social")
    local socialData = socialVM.AsyncGetSocialData(0, charId, cancelToken)
    cls.OpenPersonalZoneMain(socialData)
  end)()
end

function cls.OpenPersonalZoneMain(socialData)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isPersonalzone = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone)
  if not isPersonalzone then
    return
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Space_01, "personalzone_main", function()
    Z.UIMgr:OpenView("personalzone_main", socialData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Presonzone)
end

function cls.OpenPersonalZoneEditor(editorType)
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Space_01, "personalzone_edit_window", function()
    Z.UIMgr:OpenView("personalzone_edit_window", editorType)
  end, Z.ConstValue.UnrealSceneConfigPaths.Presonzone)
end

function cls.AsyncSavePersonalTags(onlineDaya, onlineTimes, tags, cancelToken)
  local request = {}
  request.onlineDay = onlineDaya
  request.onlinePeriods = onlineTimes
  request.tags = tags
  local reply = worldProxy.SetPersonalZoneTags(request, cancelToken)
  Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnTagsRefresh, Z.ContainerMgr.CharSerialize.personalZone.onlinePeriods, Z.ContainerMgr.CharSerialize.personalZone.tags)
  return cls.CheckReply(reply)
end

function cls.AsyncSaveTheme(id, cancelToken)
  local request = {}
  request.themeId = id
  local reply = worldProxy.SetPersonalZoneTheme(request, cancelToken)
  if cls.CheckReply(reply) then
    Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnPersonalBgRefresh, id)
    return true
  end
  return false
end

function cls.AsyncSavePhoto(photos, cancelToken)
  local request = {}
  request.photos = photos
  local reply = worldProxy.SetPersonalZonePhoto(request, cancelToken)
  Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnPhotoRefresh, Z.ContainerMgr.CharSerialize.personalZone.photosWall)
  return cls.CheckReply(reply)
end

function cls.OpenPersonalzoneRecordMain(functionId)
  if functionId ~= nil and type(functionId) == "string" then
    functionId = tonumber(functionId)
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isPersonalzoneRecordUnlock = gotoFuncVM.CheckFuncCanUse(E.FunctionID.PersonalzoneRecord)
  if not isPersonalzoneRecordUnlock then
    return
  end
  local isFunctionUnlock = gotoFuncVM.CheckFuncCanUse(functionId)
  if not isFunctionUnlock then
    return
  end
  Z.UIMgr:OpenView("personal_zone_record_main", functionId)
end

function cls.PrepareCellPos(width, height, size)
  local out = {}
  local widthCount = tonumber(width / size)
  local heightCount = tonumber(height / size)
  for j = 1, heightCount do
    for i = 1, widthCount do
      local x = (i - 1) * size
      local y = (1 - j) * size
      table.insert(out, Vector2.New(x, y))
    end
  end
  return out
end

function cls.IsHeadOrFrameUnLock(config)
  if config.Unlock == 0 then
    return true
  end
  local itemVM = Z.VMMgr.GetVM("items")
  local totalCount = itemVM.GetItemTotalCount(config.Id)
  return 0 < totalCount
end

function cls.AsyncSetPersonalZoneAvatar(headId, cancelToken)
  local request = {}
  request.avatarId = headId
  local ret = worldProxy.SetPersonalZoneAvatar(request, cancelToken)
  return cls.CheckReply(ret)
end

function cls.AsyncSetPersonalZoneAvatarFrame(frameId, cancelToken)
  local request = {}
  request.avatarFrameId = frameId
  local ret = worldProxy.SetPersonalZoneAvatarFrame(request, cancelToken)
  return cls.CheckReply(ret)
end

function cls.AsyncSetPersonalZoneBusinessCardStyle(id, cancelToken)
  local request = {}
  request.businessCardStyleId = id
  local ret = worldProxy.SetPersonalZoneBusinessCardStyle(request, cancelToken)
  if cls.CheckReply(ret) then
    Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnCardRefresh)
    return true
  else
    return false
  end
end

function cls.HasMedal(id)
  local config = Z.TableMgr.GetTable("MedalTableMgr").GetRow(id)
  if config then
    local itemVM = Z.VMMgr.GetVM("items")
    local totalCount = itemVM.GetItemTotalCount(config.Id)
    return 0 < totalCount
  end
  return false
end

function cls.GetMedalConfig(type, all)
  local personalzone_data = Z.DataMgr.Get("personal_zone_data")
  local configs = personalzone_data:GetMedalConfig(type)
  if all then
    return configs
  else
    local tempRes = {}
    local index = 0
    if configs then
      for _, config in ipairs(configs) do
        if cls.HasMedal(config.Id) then
          index = index + 1
          tempRes[index] = config
        end
      end
    end
    return tempRes
  end
end

function cls.AsyncSetPersonalZoneMedal(medals, cancelToken)
  local request = {}
  request.medals = medals
  local ret = worldProxy.SetPersonalZoneMedal(request, cancelToken)
  return cls.CheckReply(ret)
end

function cls.AsyncSetPersonalZoneTitle(id, cancelToken)
  local request = {}
  request.titleId = id
  local ret = worldProxy.SetPersonalZoneTitle(request, cancelToken)
  if cls.CheckReply(ret) then
    Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnTitleRefresh)
    return true
  else
    return false
  end
end

function cls.IDCardHelperBase(uibinder, idcard)
  if uibinder == nil then
    return
  end
  if idcard == 0 then
    return
  end
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idcard)
  if config == nil then
    return
  end
  if uibinder.rimg_bg then
    uibinder.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalCBg .. config.Image)
  end
end

function cls.IDCardHelperBasePC(uibinder, idcard)
  if uibinder == nil then
    return
  end
  if idcard == 0 then
    return
  end
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idcard)
  if config == nil then
    return
  end
  if uibinder.rimg_card then
    uibinder.rimg_card:SetImage(Z.ConstValue.PersonalZone.PersonalCardBgLong .. config.Image)
  end
  if uibinder.img_line_01 then
    uibinder.img_line_01:SetColorByHex(config.Color)
  end
  if uibinder.img_bg then
    uibinder.img_bg:SetColorByHex(config.Color2)
  end
end

function cls.SetPersonalInfoBgBySocialData(socialData, rimg)
  local cardConfig
  local personalzoneData = Z.DataMgr.Get("personal_zone_data")
  if socialData.avatarInfo and socialData.avatarInfo.businessCardStyleId > 0 then
    cardConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(socialData.avatarInfo.businessCardStyleId)
  else
    cardConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(personalzoneData:GetDefaultProfileImageConfigByType(DEFINE.ProfileImageType.Card))
  end
  if cardConfig then
    rimg:SetImage(Z.ConstValue.PersonalZone.PersonalInfoBg .. cardConfig.Image)
  end
end

return cls
