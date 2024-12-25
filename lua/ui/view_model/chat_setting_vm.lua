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
  Z.LocalUserDataMgr.SetBool(key, isShow)
end
local setBullet = function(functionId, isShow)
  data:SetBullet(functionId, isShow)
  local key = string.zconcat("BKL_SHOW_BULLET", Z.ContainerMgr.CharSerialize.charBase.charId, functionId)
  Z.LocalUserDataMgr.SetBool(key, isShow)
end
local ret = {
  SetBullet = setBullet,
  SetChannel = setChannel,
  SetTagIndex = setTagIndex,
  SetChannelIndex = setChannelIndex,
  TakeEffectSettingData = takeEffectSettingData
}
return ret
