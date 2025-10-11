local template = require("zutil.template")
local entityVm = Z.VMMgr.GetVM("entity")
local dungeonVm = Z.VMMgr.GetVM("dungeon")
local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
local setNpcPlaceholder = function(placeholderParam, id)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if placeholderParam.npc == nil then
    placeholderParam.npc = {}
  end
  placeholderParam.npc.name = entityVm.GetNpcName
  placeholderParam.npc.Id = id
  return placeholderParam
end
local setSceneObjPlaceholder = function(placeholderParam, id)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if placeholderParam.sceneObj == nil then
    placeholderParam.sceneObj = {}
  end
  placeholderParam.sceneObj.name = entityVm.GetSceneObjName
  placeholderParam.sceneObj.Id = id
  return placeholderParam
end
local setCollectPlaceholder = function(placeholderParam, id)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if placeholderParam.coll == nil then
    placeholderParam.coll = {}
  end
  placeholderParam.coll.name = entityVm.GetCollectName
  placeholderParam.coll.Id = id
  return placeholderParam
end
local setDungeonValVluew = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if placeholderParam.dungeonvar == nil then
    placeholderParam.dungeonvar = {}
  end
  placeholderParam.dungeonvar.value = dungeonVm.GetDungeonValValue
  return placeholderParam
end
local setMePlaceholder = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if placeholderParam.me == nil then
    placeholderParam.me = {}
  end
  placeholderParam.me.name = Z.ContainerMgr.CharSerialize.charBase.name
  return placeholderParam
end
local setToPercentPlaceholder = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  
  function placeholderParam.toP(value)
    if value == nil then
      return "0%"
    end
    return tostring(value) .. "%"
  end
  
  return placeholderParam
end
local setDungeonName = function(placeholderParam, actionStageData)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if actionStageData == nil then
    return placeholderParam
  end
  local dungeonId = 0
  for _, stageData in ipairs(actionStageData) do
    if stageData ~= nil then
      for _, actionData in ipairs(stageData) do
        if tonumber(actionData[1]) == Z.PbEnum("EInteractionAction", "EInteractionActionDungeonEntry") then
          dungeonId = tonumber(actionData[2])
          break
        end
      end
    end
  end
  if dungeonId == 0 then
    return placeholderParam
  end
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonsTable then
    return placeholderParam
  end
  if placeholderParam.dungeon == nil then
    placeholderParam.dungeon = {}
  end
  placeholderParam.dungeon.name = dungeonsTable.Name
  return placeholderParam
end
local setHeroChallengeDungeonName = function(placeholderParam, actionStageData)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if actionStageData == nil then
    return placeholderParam
  end
  local groupId = 0
  for _, stageData in ipairs(actionStageData) do
    if stageData ~= nil then
      for _, actionData in ipairs(stageData) do
        if tonumber(actionData[1]) == Z.PbEnum("EInteractionAction", "EInteractionActionHeroChallengeDungeon") then
          groupId = tonumber(actionData[2])
          break
        end
      end
    end
  end
  if groupId == 0 then
    return placeholderParam
  end
  local groupDict = dungeonVm.GetHeroDungeonGroup(groupId)
  if table.zcount(groupDict) == 0 then
    return placeholderParam
  end
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(groupDict[1].DungeonId)
  if not dungeonsTable then
    return placeholderParam
  end
  if placeholderParam.heroChallengeDungeon == nil then
    placeholderParam.heroChallengeDungeon = {}
  end
  placeholderParam.heroChallengeDungeon.name = dungeonsTable.Name
  return placeholderParam
end
local asyncSetHeroNormalDungeonName = function(placeholderParam, actionStageData)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if actionStageData == nil then
    return placeholderParam
  end
  local dataId = 0
  for _, stageData in ipairs(actionStageData) do
    if stageData ~= nil then
      for _, actionData in ipairs(stageData) do
        if tonumber(actionData[1]) == Z.PbEnum("EInteractionAction", "EInteractionActionHeroNormalDungeon") then
          dataId = tonumber(actionData[2])
          break
        end
      end
    end
  end
  if dataId == 0 then
    return placeholderParam
  end
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  dungeonVm.AsyncGetSeasonDungeonList()
  local dungeonData = dungeonVm.GetHerDungeonData(dataId)
  if dungeonData == nil then
    return placeholderParam
  end
  if placeholderParam.heroNormalDungeon == nil then
    placeholderParam.heroNormalDungeon = {}
  end
  placeholderParam.heroNormalDungeon.name = dungeonData.Name
  return placeholderParam
end
local setNpcName = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  
  function placeholderParam.npcname(npcId)
    local entityVm = Z.VMMgr.GetVM("entity")
    local npcName = entityVm.GetNpcName(npcId)
    if npcName then
      return npcName
    else
      return ""
    end
  end
  
  return placeholderParam
end
local setItemName = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  
  function placeholderParam.itemname(itemId)
    local itemTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
    if not itemTable then
      return ""
    end
    return itemTable.Name
  end
  
  return placeholderParam
end
local setMonsterName = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  
  function placeholderParam.monstername(monsterId)
    local monsterTable = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(monsterId)
    if not monsterTable then
      return ""
    end
    return monsterTable.Name
  end
  
  return placeholderParam
end
local setQuestName = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  
  function placeholderParam.questname(questId)
    local questTable = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if not questTable then
      return ""
    end
    local param = Z.Placeholder.SetPlayerSelfPronoun()
    local ret = Z.Placeholder.Placeholder(questTable.QuestName, param)
    return ret
  end
  
  return placeholderParam
end
local setCollectionName = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  
  function placeholderParam.collectionname(collectionId)
    local collectionTable = Z.TableMgr.GetTable("CollectionTableMgr").GetRow(collectionId)
    if not collectionTable then
      return ""
    end
    return collectionTable.CollectionName
  end
  
  return placeholderParam
end
local setPlayerSelfPronoun = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  if gender == Z.PbEnum("EGender", "GenderMale") then
    placeholderParam.playerself = Lang("PlayerselfMale")
  else
    placeholderParam.playerself = Lang("PlayerselfFemale")
  end
  return placeholderParam
end
local placeholderHandle = function(content, param)
  local view = template.compile(content)(param)
  return tostring(view)
end
local placeholder = function(content, param)
  if param == nil or not next(param) then
    return content
  end
  local status, result = pcall(placeholderHandle, content, param)
  if status then
    return result
  else
    logError("[Placeholder] " .. result)
    return content
  end
end
local placeholder_task = function(content, replaceText)
  local arg_ = replaceText
  local index_ = 1
  for str, _ in string.gmatch(content, "<[^<>]+>") do
    local tempStr_
    local key_, value_ = string.match(str, "(<[a-z%.]+=)([^>]+)")
    if key_ and value_ then
      if key_ == "<i=" then
      elseif key_ == "<i.n=" then
        tempStr_ = value_
      elseif key_ == "<i.ic=" then
      elseif key_ == "<cd.mm=" then
      elseif key_ == "<cd.ss=" then
      end
      if tempStr_ and key_ and value_ then
        content = string.gsub(content, str, tempStr_, 1)
      end
    else
      if string.find(str, "<npc") then
        tempStr_ = arg_[str]
      else
        tempStr_ = arg_[str]
      end
      if tempStr_ then
        content = string.gsub(content, str, tempStr_, 1)
      end
    end
  end
  return content
end
local setTextColor = function(text, colorTag)
  if colorTag == "" or colorTag == nil then
    return text
  end
  return string.format("<color=%s>%s</color>", colorTag, text)
end
local setTextSize = function(text, size)
  if size == nil then
    return text
  end
  return string.format("<size=%s>%s</size>", size, text)
end
local ret = {
  SetNpcPlaceholder = setNpcPlaceholder,
  SetSceneObjPlaceholder = setSceneObjPlaceholder,
  SetCollectPlaceholder = setCollectPlaceholder,
  SetMePlaceholder = setMePlaceholder,
  SetDungeonValVluew = setDungeonValVluew,
  SetToPercentPlaceholder = setToPercentPlaceholder,
  SetNpcName = setNpcName,
  SetItemName = setItemName,
  SetMonsterName = setMonsterName,
  SetQuestName = setQuestName,
  SetCollectionName = setCollectionName,
  SetPlayerSelfPronoun = setPlayerSelfPronoun,
  Placeholder = placeholder,
  Placeholder_task = placeholder_task,
  SetTextColor = setTextColor,
  SetTextSize = setTextSize,
  SetDungeonName = setDungeonName,
  SetHeroChallengeDungeonName = setHeroChallengeDungeonName,
  AsyncSetHeroNormalDungeonName = asyncSetHeroNormalDungeonName
}
return ret
