local commonPlayerPortraitItemUnit = require("ui.component.role_info.common_player_portrait_item")
local commonPlayerPortraitNewItem = require("ui.component.role_info.common_player_portrait_new_item")
local getHeadPortraitTab = {}
local loadHeadPortraitTab = {}
local headSnapshotData = Z.DataMgr.Get("head_snapshot_data")
local setHeadPortrait = function(charId, headId)
  if headId and headId ~= 0 and getHeadPortraitTab[charId] then
    for index, item in ipairs(getHeadPortraitTab[charId]) do
      if index == 1 then
        item:SetRimgPortrait(headId)
      end
    end
  end
  loadHeadPortraitTab[charId] = nil
  getHeadPortraitTab[charId] = nil
end
local removeSameItem = function(newItem)
  for index, items in pairs(getHeadPortraitTab) do
    for k, item in ipairs(items) do
      if item.unit and item.unit == newItem.unit or item.uiBinder and item.uiBinder == newItem.uiBinder then
        table.remove(items, k)
        return
      end
    end
  end
end
local setHeadImage = function(item, viewData)
  if (viewData.id == 0 or viewData.id == 1) and viewData.charId then
    if getHeadPortraitTab[viewData.charId] == nil then
      getHeadPortraitTab[viewData.charId] = {}
    end
    removeSameItem(item)
    table.insert(getHeadPortraitTab[viewData.charId], item)
    item:GetLocalHeadPortrait(viewData.charId, viewData.modelId)
    if loadHeadPortraitTab[viewData.charId] == nil then
      loadHeadPortraitTab[viewData.charId] = true
      item:GetSnapshot(viewData.charId, setHeadPortrait)
    end
  else
    item:SetImgPortrait(viewData.id)
  end
end
local setHeadImageBySocialData = function(item, socialData)
  local socialVm = Z.VMMgr.GetVM("social")
  local modelId = socialVm.GetModelId(socialData)
  if socialData.avatarInfo then
    local avatarId = socialData.avatarInfo.avatarId
    if avatarId and (avatarId == 1 or avatarId == 0) then
      if getHeadPortraitTab[socialData.basicData.charID] == nil then
        getHeadPortraitTab[socialData.basicData.charID] = {}
      end
      removeSameItem(item)
      table.insert(getHeadPortraitTab[socialData.basicData.charID], item)
      item:GetLocalHeadPortrait(socialData.basicData.charID, modelId)
      if loadHeadPortraitTab[socialData.basicData.charID] == nil then
        loadHeadPortraitTab[socialData.basicData.charID] = true
        item:GetSnapshotBySocialData(socialData.basicData.charID, socialData, setHeadPortrait)
      end
    else
      item:SetImgPortrait(avatarId)
    end
  else
    item:SetModelPortrait(modelId)
  end
end
local insertPortrait = function(go, viewData)
  if go == nil or viewData == nil then
    return
  end
  local item = commonPlayerPortraitItemUnit.new()
  item:Init(go, viewData)
  item:Refresh()
  setHeadImage(item, viewData)
  return item
end
local insertNewPortrait = function(uiBinder, viewData)
  if viewData == nil or uiBinder == nil then
    return
  end
  local binderItem = commonPlayerPortraitNewItem.new()
  binderItem:Init(uiBinder, viewData)
  binderItem:Refresh()
  setHeadImage(binderItem, viewData)
  return binderItem
end
local refreshNewProtrait = function(uiBinder, viewData, binderItem)
  if viewData == nil or uiBinder == nil then
    return
  end
  binderItem:Init(uiBinder, viewData)
  binderItem:Refresh()
  setHeadImage(binderItem, viewData)
end
local insertNewPortraitBySocialData = function(uiBinder, socialData, func, token)
  if socialData == nil or uiBinder == nil then
    return
  end
  local binderItem = commonPlayerPortraitNewItem.new()
  binderItem:InitSocialData(uiBinder, socialData, func, token)
  setHeadImageBySocialData(binderItem, socialData)
  return binderItem
end
local insertNewPortraitByHeadPath = function(uiBinder, headPath)
  if uiBinder == nil or headPath == nil or headPath == "" then
    return
  end
  local binderItem = commonPlayerPortraitNewItem.new()
  binderItem.uiBinder = uiBinder
  binderItem:SetHeadPicture(headPath)
  return binderItem
end
local asyncCheckHead = function(headInfo, mask, token)
  local socialVm = Z.VMMgr.GetVM("social")
  local socialData = socialVm.AsyncGetSocialData(mask, headInfo.charId, token)
  if socialData then
    local headSnapshotData = Z.DataMgr.Get("head_snapshot_data")
    headSnapshotData:AddPlayerHeadSocialData(headInfo.charId, socialData)
    for i = 1, #headInfo.callBackList do
      if headInfo.callBackList[i] then
        headInfo.callBackList[i](headInfo.charId, socialData)
      end
    end
  end
end
local loadSocialData = function()
  Z.CoroUtil.create_coro_xpcall(function()
    if headSnapshotData.IsRefreshPlayerHeadData then
      return
    end
    local CheckHeadCount = math.min(#headSnapshotData.LoadPlayerHeadData, headSnapshotData.TimeCheckCount)
    if 0 < CheckHeadCount then
      headSnapshotData.IsRefreshPlayerHeadData = true
      headSnapshotData.RefreshPlayerHeadData = {}
      local loadIndex = #headSnapshotData.LoadPlayerHeadData - CheckHeadCount + 1
      for i = #headSnapshotData.LoadPlayerHeadData, loadIndex, -1 do
        table.insert(headSnapshotData.RefreshPlayerHeadData, headSnapshotData.LoadPlayerHeadData[i])
        headSnapshotData.LoadPlayerHeadData[i] = nil
      end
      for i = #headSnapshotData.RefreshPlayerHeadData, 1, -1 do
        asyncCheckHead(headSnapshotData.RefreshPlayerHeadData[i], headSnapshotData.PlayerHeadMask, headSnapshotData.CancelSource:CreateToken())
      end
      headSnapshotData.RefreshPlayerHeadData = {}
    end
    if #headSnapshotData.LoadPlayerHeadData == 0 then
      Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.LoadPlayerHead)
    end
    headSnapshotData.IsRefreshPlayerHeadData = false
  end)()
end
local loadSocialDataByCharId = function(charId, callBackFunc)
  if charId == nil or callBackFunc == nil then
    return
  end
  local data = headSnapshotData:GetPlayerHeadSocialData(charId)
  if data then
    if callBackFunc then
      callBackFunc(charId, data)
    end
  else
    if headSnapshotData:CheckPlayerHeadInLoadingList(charId, callBackFunc) or headSnapshotData:CheckPlayerHeadIsLoading(charId, callBackFunc) then
      return
    end
    local playerHeadData = {}
    playerHeadData.charId = charId
    playerHeadData.callBackList = {}
    table.insert(playerHeadData.callBackList, callBackFunc)
    table.insert(headSnapshotData.LoadPlayerHeadData, 1, playerHeadData)
    if not Z.GlobalTimerMgr:IsHaveTimer(E.GlobalTimerTag.LoadPlayerHead) then
      Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.LoadPlayerHead, function()
        loadSocialData()
      end, 1, -1)
      loadSocialData()
    end
  end
end
local clearActiveItem = function(acitveItem)
end
local clearAllActiveItems = function()
end
local ret = {
  InsertPortrait = insertPortrait,
  ClearActiveItem = clearActiveItem,
  ClearAllActiveItems = clearAllActiveItems,
  InsertNewPortraitBySocialData = insertNewPortraitBySocialData,
  InsertNewPortraitByHeadPath = insertNewPortraitByHeadPath,
  LoadSocialDataByCharId = loadSocialDataByCharId,
  InsertNewPortrait = insertNewPortrait,
  RefreshNewProtrait = refreshNewProtrait
}
return ret
