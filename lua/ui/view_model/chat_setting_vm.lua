local data = Z.DataMgr.Get("chat_setting_data")
local setTagIndex = function(valeType)
  data:SetSelectTagIndex(valeType)
  Z.EventMgr:Dispatch(Z.ConstValue.ChatSettingsTagIndex)
end
local setChannelIndex = function(valeType)
  Z.EventMgr:Dispatch(Z.ConstValue.ChatSettingChannelSelectionIndex)
end
local takeEffectSettingData = function()
  Z.EventMgr:Dispatch(Z.ConstValue.ChatSettingDataTakesEffect)
end
local setChannel = function(functionId, isShow)
  data:SetChatList(functionId, isShow)
  local key = string.zconcat("BKL_SHOW_CHANNEL", Z.ContainerMgr.CharSerialize.charBase.charId, functionId)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, isShow)
end
local setBullet = function(functionId, isShow)
  data:SetBullet(functionId, isShow)
  local key = string.zconcat("BKL_SHOW_BULLET", Z.ContainerMgr.CharSerialize.charBase.charId, functionId)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, isShow)
end
local chechFunc = {
  [E.ESocialApplySettingType.EAllApply] = function(charId)
    return true
  end,
  [E.ESocialApplySettingType.EFriendApply] = function(charId)
    local friendMainData = Z.DataMgr.Get("friend_main_data")
    return friendMainData:IsFriendByCharId(charId)
  end,
  [E.ESocialApplySettingType.ENoneApply] = function(charId)
    return false
  end
}
local getApplySettingFunc = {
  [E.ESocialApplyType.ETeamApply] = function()
    return data:GetTeamApply()
  end,
  [E.ESocialApplyType.ECarpoolApply] = function()
    return data:GetCarpoolApply()
  end,
  [E.ESocialApplyType.EInteractiveApply] = function()
    return data:GetInteractiveApply()
  end
}
local checkApplyType = function(applyType, charId)
  local type = getApplySettingFunc[applyType]()
  return chechFunc[type](charId)
end
local ret = {
  SetBullet = setBullet,
  SetChannel = setChannel,
  SetTagIndex = setTagIndex,
  SetChannelIndex = setChannelIndex,
  TakeEffectSettingData = takeEffectSettingData,
  CheckApplyType = checkApplyType
}
return ret
