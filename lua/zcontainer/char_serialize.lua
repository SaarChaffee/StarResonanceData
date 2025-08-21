local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [2] = function(container, buffer, watcherList)
    container.charBase:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("charBase", {})
  end,
  [5] = function(container, buffer, watcherList)
    container.pioneerData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("pioneerData", {})
  end,
  [7] = function(container, buffer, watcherList)
    container.itemPackage:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("itemPackage", {})
  end,
  [8] = function(container, buffer, watcherList)
    container.questList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("questList", {})
  end,
  [9] = function(container, buffer, watcherList)
    container.settingData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("settingData", {})
  end,
  [10] = function(container, buffer, watcherList)
    container.miscInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("miscInfo", {})
  end,
  [11] = function(container, buffer, watcherList)
    container.exchangeItems:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("exchangeItems", {})
  end,
  [12] = function(container, buffer, watcherList)
    container.equip:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("equip", {})
  end,
  [13] = function(container, buffer, watcherList)
    container.energyItem:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("energyItem", {})
  end,
  [14] = function(container, buffer, watcherList)
    container.mapData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("mapData", {})
  end,
  [15] = function(container, buffer, watcherList)
    container.dungeonList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonList", {})
  end,
  [16] = function(container, buffer, watcherList)
    container.attr:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("attr", {})
  end,
  [17] = function(container, buffer, watcherList)
    container.fashion:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fashion", {})
  end,
  [18] = function(container, buffer, watcherList)
    container.profileList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("profileList", {})
  end,
  [19] = function(container, buffer, watcherList)
    container.help:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("help", {})
  end,
  [20] = function(container, buffer, watcherList)
    container.counterList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("counterList", {})
  end,
  [22] = function(container, buffer, watcherList)
    container.roleLevel:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("roleLevel", {})
  end,
  [23] = function(container, buffer, watcherList)
    container.pivot:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("pivot", {})
  end,
  [24] = function(container, buffer, watcherList)
    container.transferPoint:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("transferPoint", {})
  end,
  [25] = function(container, buffer, watcherList)
    container.planetMemory:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("planetMemory", {})
  end,
  [26] = function(container, buffer, watcherList)
    container.planetMemoryTarget:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("planetMemoryTarget", {})
  end,
  [27] = function(container, buffer, watcherList)
    container.redDot:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("redDot", {})
  end,
  [28] = function(container, buffer, watcherList)
    container.resonance:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("resonance", {})
  end,
  [29] = function(container, buffer, watcherList)
    container.cutsState:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("cutsState", {})
  end,
  [30] = function(container, buffer, watcherList)
    container.investigateList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("investigateList", {})
  end,
  [31] = function(container, buffer, watcherList)
    container.records:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("records", {})
  end,
  [32] = function(container, buffer, watcherList)
    container.interaction:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("interaction", {})
  end,
  [33] = function(container, buffer, watcherList)
    container.seasonQuestList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonQuestList", {})
  end,
  [34] = function(container, buffer, watcherList)
    container.roleFace:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("roleFace", {})
  end,
  [35] = function(container, buffer, watcherList)
    container.mapBookList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("mapBookList", {})
  end,
  [36] = function(container, buffer, watcherList)
    container.FunctionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("FunctionData", {})
  end,
  [37] = function(container, buffer, watcherList)
    container.antiInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("antiInfo", {})
  end,
  [38] = function(container, buffer, watcherList)
    container.monsterExploreList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("monsterExploreList", {})
  end,
  [39] = function(container, buffer, watcherList)
    container.showPieceData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("showPieceData", {})
  end,
  [42] = function(container, buffer, watcherList)
    container.collectionBook:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("collectionBook", {})
  end,
  [44] = function(container, buffer, watcherList)
    container.cookList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("cookList", {})
  end,
  [45] = function(container, buffer, watcherList)
    container.refreshDataList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("refreshDataList", {})
  end,
  [46] = function(container, buffer, watcherList)
    container.challengeDungeonInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("challengeDungeonInfo", {})
  end,
  [47] = function(container, buffer, watcherList)
    container.syncAwardData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("syncAwardData", {})
  end,
  [48] = function(container, buffer, watcherList)
    container.seasonAchievementList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonAchievementList", {})
  end,
  [49] = function(container, buffer, watcherList)
    container.seasonRankList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonRankList", {})
  end,
  [50] = function(container, buffer, watcherList)
    container.seasonCenter:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonCenter", {})
  end,
  [51] = function(container, buffer, watcherList)
    container.personalZone:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("personalZone", {})
  end,
  [52] = function(container, buffer, watcherList)
    container.seasonMedalInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonMedalInfo", {})
  end,
  [53] = function(container, buffer, watcherList)
    container.communityHomeInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("communityHomeInfo", {})
  end,
  [54] = function(container, buffer, watcherList)
    container.seasonActivation:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonActivation", {})
  end,
  [55] = function(container, buffer, watcherList)
    container.slots:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("slots", {})
  end,
  [56] = function(container, buffer, watcherList)
    container.monsterHuntInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("monsterHuntInfo", {})
  end,
  [57] = function(container, buffer, watcherList)
    container.mod:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("mod", {})
  end,
  [58] = function(container, buffer, watcherList)
    container.worldEventMap:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("worldEventMap", {})
  end,
  [59] = function(container, buffer, watcherList)
    container.fishSetting:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fishSetting", {})
  end,
  [60] = function(container, buffer, watcherList)
    container.freightData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("freightData", {})
  end,
  [61] = function(container, buffer, watcherList)
    container.professionList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("professionList", {})
  end,
  [62] = function(container, buffer, watcherList)
    container.trialRoad:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("trialRoad", {})
  end,
  [63] = function(container, buffer, watcherList)
    container.gashaData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("gashaData", {})
  end,
  [64] = function(container, buffer, watcherList)
    container.shopData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("shopData", {})
  end,
  [65] = function(container, buffer, watcherList)
    container.personalWorldBossInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("personalWorldBossInfo", {})
  end,
  [66] = function(container, buffer, watcherList)
    container.craftEnergy:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("craftEnergy", {})
  end,
  [67] = function(container, buffer, watcherList)
    container.weeklyTower:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("weeklyTower", {})
  end,
  [70] = function(container, buffer, watcherList)
    container.rideList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("rideList", {})
  end,
  [72] = function(container, buffer, watcherList)
    container.lifeProfession:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("lifeProfession", {})
  end,
  [73] = function(container, buffer, watcherList)
    container.lifeProfessionWork:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("lifeProfessionWork", {})
  end,
  [77] = function(container, buffer, watcherList)
    container.monthlyCard:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("monthlyCard", {})
  end,
  [78] = function(container, buffer, watcherList)
    container.fashionBenefit:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fashionBenefit", {})
  end,
  [79] = function(container, buffer, watcherList)
    container.itemCurrency:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("itemCurrency", {})
  end,
  [80] = function(container, buffer, watcherList)
    container.privilegeEffectData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("privilegeEffectData", {})
  end,
  [81] = function(container, buffer, watcherList)
    container.treasure:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("treasure", {})
  end,
  [82] = function(container, buffer, watcherList)
    container.unlockEmojiData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("unlockEmojiData", {})
  end,
  [83] = function(container, buffer, watcherList)
    container.playerOrderComtainerInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("playerOrderComtainerInfo", {})
  end,
  [84] = function(container, buffer, watcherList)
    container.playerBox:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("playerBox", {})
  end,
  [85] = function(container, buffer, watcherList)
    container.launchPrivilegeData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("launchPrivilegeData", {})
  end,
  [87] = function(container, buffer, watcherList)
    container.rechargeData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("rechargeData", {})
  end,
  [88] = function(container, buffer, watcherList)
    container.luckyValueMgr:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("luckyValueMgr", {})
  end,
  [89] = function(container, buffer, watcherList)
    container.handbookData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("handbookData", {})
  end,
  [90] = function(container, buffer, watcherList)
    container.masterModeDungeonInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("masterModeDungeonInfo", {})
  end,
  [92] = function(container, buffer, watcherList)
    container.compenstionStatistics:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("compenstionStatistics", {})
  end,
  [93] = function(container, buffer, watcherList)
    container.bubbleActData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("bubbleActData", {})
  end,
  [96] = function(container, buffer, watcherList)
    container.fightPoint:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fightPoint", {})
  end,
  [97] = function(container, buffer, watcherList)
    container.sign:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("sign", {})
  end
}
local setForbidenMt = function(t)
  local mt = {
    __index = t.__data__,
    __newindex = function(_, _, _)
      error("__newindex is forbidden for container")
    end,
    __pairs = function(tbl)
      local stateless_iter = function(tbl, k)
        local v
        k, v = next(t.__data__, k)
        if nil ~= v or "__data__" ~= k then
          return k, v
        end
      end
      return stateless_iter, tbl, nil
    end
  }
  setmetatable(t, mt)
end
local resetData = function(container, pbData)
  if not container or not container.__data__ then
    error("container is nil or not container")
  end
  if not pbData then
    return
  end
  container.__data__ = pbData
  if not pbData.charId then
    container.__data__.charId = 0
  end
  if not pbData.charBase then
    container.__data__.charBase = {}
  end
  if not pbData.sceneData then
    container.__data__.sceneData = {}
  end
  if not pbData.sceneLuaData then
    container.__data__.sceneLuaData = {}
  end
  if not pbData.pioneerData then
    container.__data__.pioneerData = {}
  end
  if not pbData.buffInfo then
    container.__data__.buffInfo = {}
  end
  if not pbData.itemPackage then
    container.__data__.itemPackage = {}
  end
  if not pbData.questList then
    container.__data__.questList = {}
  end
  if not pbData.settingData then
    container.__data__.settingData = {}
  end
  if not pbData.miscInfo then
    container.__data__.miscInfo = {}
  end
  if not pbData.exchangeItems then
    container.__data__.exchangeItems = {}
  end
  if not pbData.equip then
    container.__data__.equip = {}
  end
  if not pbData.energyItem then
    container.__data__.energyItem = {}
  end
  if not pbData.mapData then
    container.__data__.mapData = {}
  end
  if not pbData.dungeonList then
    container.__data__.dungeonList = {}
  end
  if not pbData.attr then
    container.__data__.attr = {}
  end
  if not pbData.fashion then
    container.__data__.fashion = {}
  end
  if not pbData.profileList then
    container.__data__.profileList = {}
  end
  if not pbData.help then
    container.__data__.help = {}
  end
  if not pbData.counterList then
    container.__data__.counterList = {}
  end
  if not pbData.personalObj then
    container.__data__.personalObj = {}
  end
  if not pbData.roleLevel then
    container.__data__.roleLevel = {}
  end
  if not pbData.pivot then
    container.__data__.pivot = {}
  end
  if not pbData.transferPoint then
    container.__data__.transferPoint = {}
  end
  if not pbData.planetMemory then
    container.__data__.planetMemory = {}
  end
  if not pbData.planetMemoryTarget then
    container.__data__.planetMemoryTarget = {}
  end
  if not pbData.redDot then
    container.__data__.redDot = {}
  end
  if not pbData.resonance then
    container.__data__.resonance = {}
  end
  if not pbData.cutsState then
    container.__data__.cutsState = {}
  end
  if not pbData.investigateList then
    container.__data__.investigateList = {}
  end
  if not pbData.records then
    container.__data__.records = {}
  end
  if not pbData.interaction then
    container.__data__.interaction = {}
  end
  if not pbData.seasonQuestList then
    container.__data__.seasonQuestList = {}
  end
  if not pbData.roleFace then
    container.__data__.roleFace = {}
  end
  if not pbData.mapBookList then
    container.__data__.mapBookList = {}
  end
  if not pbData.FunctionData then
    container.__data__.FunctionData = {}
  end
  if not pbData.antiInfo then
    container.__data__.antiInfo = {}
  end
  if not pbData.monsterExploreList then
    container.__data__.monsterExploreList = {}
  end
  if not pbData.showPieceData then
    container.__data__.showPieceData = {}
  end
  if not pbData.collectionBook then
    container.__data__.collectionBook = {}
  end
  if not pbData.notGetProceedAwardTimes then
    container.__data__.notGetProceedAwardTimes = {}
  end
  if not pbData.cookList then
    container.__data__.cookList = {}
  end
  if not pbData.refreshDataList then
    container.__data__.refreshDataList = {}
  end
  if not pbData.challengeDungeonInfo then
    container.__data__.challengeDungeonInfo = {}
  end
  if not pbData.syncAwardData then
    container.__data__.syncAwardData = {}
  end
  if not pbData.seasonAchievementList then
    container.__data__.seasonAchievementList = {}
  end
  if not pbData.seasonRankList then
    container.__data__.seasonRankList = {}
  end
  if not pbData.seasonCenter then
    container.__data__.seasonCenter = {}
  end
  if not pbData.personalZone then
    container.__data__.personalZone = {}
  end
  if not pbData.seasonMedalInfo then
    container.__data__.seasonMedalInfo = {}
  end
  if not pbData.communityHomeInfo then
    container.__data__.communityHomeInfo = {}
  end
  if not pbData.seasonActivation then
    container.__data__.seasonActivation = {}
  end
  if not pbData.slots then
    container.__data__.slots = {}
  end
  if not pbData.monsterHuntInfo then
    container.__data__.monsterHuntInfo = {}
  end
  if not pbData.mod then
    container.__data__.mod = {}
  end
  if not pbData.worldEventMap then
    container.__data__.worldEventMap = {}
  end
  if not pbData.fishSetting then
    container.__data__.fishSetting = {}
  end
  if not pbData.freightData then
    container.__data__.freightData = {}
  end
  if not pbData.professionList then
    container.__data__.professionList = {}
  end
  if not pbData.trialRoad then
    container.__data__.trialRoad = {}
  end
  if not pbData.gashaData then
    container.__data__.gashaData = {}
  end
  if not pbData.shopData then
    container.__data__.shopData = {}
  end
  if not pbData.personalWorldBossInfo then
    container.__data__.personalWorldBossInfo = {}
  end
  if not pbData.craftEnergy then
    container.__data__.craftEnergy = {}
  end
  if not pbData.weeklyTower then
    container.__data__.weeklyTower = {}
  end
  if not pbData.cutSceneInfos then
    container.__data__.cutSceneInfos = {}
  end
  if not pbData.recommendPlayData then
    container.__data__.recommendPlayData = {}
  end
  if not pbData.rideList then
    container.__data__.rideList = {}
  end
  if not pbData.payOrderList then
    container.__data__.payOrderList = {}
  end
  if not pbData.lifeProfession then
    container.__data__.lifeProfession = {}
  end
  if not pbData.lifeProfessionWork then
    container.__data__.lifeProfessionWork = {}
  end
  if not pbData.userActivityList then
    container.__data__.userActivityList = {}
  end
  if not pbData.playerRecord then
    container.__data__.playerRecord = {}
  end
  if not pbData.dropContainer then
    container.__data__.dropContainer = {}
  end
  if not pbData.monthlyCard then
    container.__data__.monthlyCard = {}
  end
  if not pbData.fashionBenefit then
    container.__data__.fashionBenefit = {}
  end
  if not pbData.itemCurrency then
    container.__data__.itemCurrency = {}
  end
  if not pbData.privilegeEffectData then
    container.__data__.privilegeEffectData = {}
  end
  if not pbData.treasure then
    container.__data__.treasure = {}
  end
  if not pbData.unlockEmojiData then
    container.__data__.unlockEmojiData = {}
  end
  if not pbData.playerOrderComtainerInfo then
    container.__data__.playerOrderComtainerInfo = {}
  end
  if not pbData.playerBox then
    container.__data__.playerBox = {}
  end
  if not pbData.launchPrivilegeData then
    container.__data__.launchPrivilegeData = {}
  end
  if not pbData.battlePassData then
    container.__data__.battlePassData = {}
  end
  if not pbData.rechargeData then
    container.__data__.rechargeData = {}
  end
  if not pbData.luckyValueMgr then
    container.__data__.luckyValueMgr = {}
  end
  if not pbData.handbookData then
    container.__data__.handbookData = {}
  end
  if not pbData.masterModeDungeonInfo then
    container.__data__.masterModeDungeonInfo = {}
  end
  if not pbData.statisticsData then
    container.__data__.statisticsData = {}
  end
  if not pbData.compenstionStatistics then
    container.__data__.compenstionStatistics = {}
  end
  if not pbData.bubbleActData then
    container.__data__.bubbleActData = {}
  end
  if not pbData.mailClaimedInfo then
    container.__data__.mailClaimedInfo = {}
  end
  if not pbData.newbieData then
    container.__data__.newbieData = {}
  end
  if not pbData.fightPoint then
    container.__data__.fightPoint = {}
  end
  if not pbData.sign then
    container.__data__.sign = {}
  end
  if not pbData.charStatisticsData then
    container.__data__.charStatisticsData = {}
  end
  setForbidenMt(container)
  container.charBase:ResetData(pbData.charBase)
  container.__data__.charBase = nil
  container.sceneData:ResetData(pbData.sceneData)
  container.__data__.sceneData = nil
  container.sceneLuaData:ResetData(pbData.sceneLuaData)
  container.__data__.sceneLuaData = nil
  container.pioneerData:ResetData(pbData.pioneerData)
  container.__data__.pioneerData = nil
  container.buffInfo:ResetData(pbData.buffInfo)
  container.__data__.buffInfo = nil
  container.itemPackage:ResetData(pbData.itemPackage)
  container.__data__.itemPackage = nil
  container.questList:ResetData(pbData.questList)
  container.__data__.questList = nil
  container.settingData:ResetData(pbData.settingData)
  container.__data__.settingData = nil
  container.miscInfo:ResetData(pbData.miscInfo)
  container.__data__.miscInfo = nil
  container.exchangeItems:ResetData(pbData.exchangeItems)
  container.__data__.exchangeItems = nil
  container.equip:ResetData(pbData.equip)
  container.__data__.equip = nil
  container.energyItem:ResetData(pbData.energyItem)
  container.__data__.energyItem = nil
  container.mapData:ResetData(pbData.mapData)
  container.__data__.mapData = nil
  container.dungeonList:ResetData(pbData.dungeonList)
  container.__data__.dungeonList = nil
  container.attr:ResetData(pbData.attr)
  container.__data__.attr = nil
  container.fashion:ResetData(pbData.fashion)
  container.__data__.fashion = nil
  container.profileList:ResetData(pbData.profileList)
  container.__data__.profileList = nil
  container.help:ResetData(pbData.help)
  container.__data__.help = nil
  container.counterList:ResetData(pbData.counterList)
  container.__data__.counterList = nil
  container.personalObj:ResetData(pbData.personalObj)
  container.__data__.personalObj = nil
  container.roleLevel:ResetData(pbData.roleLevel)
  container.__data__.roleLevel = nil
  container.pivot:ResetData(pbData.pivot)
  container.__data__.pivot = nil
  container.transferPoint:ResetData(pbData.transferPoint)
  container.__data__.transferPoint = nil
  container.planetMemory:ResetData(pbData.planetMemory)
  container.__data__.planetMemory = nil
  container.planetMemoryTarget:ResetData(pbData.planetMemoryTarget)
  container.__data__.planetMemoryTarget = nil
  container.redDot:ResetData(pbData.redDot)
  container.__data__.redDot = nil
  container.resonance:ResetData(pbData.resonance)
  container.__data__.resonance = nil
  container.cutsState:ResetData(pbData.cutsState)
  container.__data__.cutsState = nil
  container.investigateList:ResetData(pbData.investigateList)
  container.__data__.investigateList = nil
  container.records:ResetData(pbData.records)
  container.__data__.records = nil
  container.interaction:ResetData(pbData.interaction)
  container.__data__.interaction = nil
  container.seasonQuestList:ResetData(pbData.seasonQuestList)
  container.__data__.seasonQuestList = nil
  container.roleFace:ResetData(pbData.roleFace)
  container.__data__.roleFace = nil
  container.mapBookList:ResetData(pbData.mapBookList)
  container.__data__.mapBookList = nil
  container.FunctionData:ResetData(pbData.FunctionData)
  container.__data__.FunctionData = nil
  container.antiInfo:ResetData(pbData.antiInfo)
  container.__data__.antiInfo = nil
  container.monsterExploreList:ResetData(pbData.monsterExploreList)
  container.__data__.monsterExploreList = nil
  container.showPieceData:ResetData(pbData.showPieceData)
  container.__data__.showPieceData = nil
  container.collectionBook:ResetData(pbData.collectionBook)
  container.__data__.collectionBook = nil
  container.notGetProceedAwardTimes:ResetData(pbData.notGetProceedAwardTimes)
  container.__data__.notGetProceedAwardTimes = nil
  container.cookList:ResetData(pbData.cookList)
  container.__data__.cookList = nil
  container.refreshDataList:ResetData(pbData.refreshDataList)
  container.__data__.refreshDataList = nil
  container.challengeDungeonInfo:ResetData(pbData.challengeDungeonInfo)
  container.__data__.challengeDungeonInfo = nil
  container.syncAwardData:ResetData(pbData.syncAwardData)
  container.__data__.syncAwardData = nil
  container.seasonAchievementList:ResetData(pbData.seasonAchievementList)
  container.__data__.seasonAchievementList = nil
  container.seasonRankList:ResetData(pbData.seasonRankList)
  container.__data__.seasonRankList = nil
  container.seasonCenter:ResetData(pbData.seasonCenter)
  container.__data__.seasonCenter = nil
  container.personalZone:ResetData(pbData.personalZone)
  container.__data__.personalZone = nil
  container.seasonMedalInfo:ResetData(pbData.seasonMedalInfo)
  container.__data__.seasonMedalInfo = nil
  container.communityHomeInfo:ResetData(pbData.communityHomeInfo)
  container.__data__.communityHomeInfo = nil
  container.seasonActivation:ResetData(pbData.seasonActivation)
  container.__data__.seasonActivation = nil
  container.slots:ResetData(pbData.slots)
  container.__data__.slots = nil
  container.monsterHuntInfo:ResetData(pbData.monsterHuntInfo)
  container.__data__.monsterHuntInfo = nil
  container.mod:ResetData(pbData.mod)
  container.__data__.mod = nil
  container.worldEventMap:ResetData(pbData.worldEventMap)
  container.__data__.worldEventMap = nil
  container.fishSetting:ResetData(pbData.fishSetting)
  container.__data__.fishSetting = nil
  container.freightData:ResetData(pbData.freightData)
  container.__data__.freightData = nil
  container.professionList:ResetData(pbData.professionList)
  container.__data__.professionList = nil
  container.trialRoad:ResetData(pbData.trialRoad)
  container.__data__.trialRoad = nil
  container.gashaData:ResetData(pbData.gashaData)
  container.__data__.gashaData = nil
  container.shopData:ResetData(pbData.shopData)
  container.__data__.shopData = nil
  container.personalWorldBossInfo:ResetData(pbData.personalWorldBossInfo)
  container.__data__.personalWorldBossInfo = nil
  container.craftEnergy:ResetData(pbData.craftEnergy)
  container.__data__.craftEnergy = nil
  container.weeklyTower:ResetData(pbData.weeklyTower)
  container.__data__.weeklyTower = nil
  container.cutSceneInfos:ResetData(pbData.cutSceneInfos)
  container.__data__.cutSceneInfos = nil
  container.recommendPlayData:ResetData(pbData.recommendPlayData)
  container.__data__.recommendPlayData = nil
  container.rideList:ResetData(pbData.rideList)
  container.__data__.rideList = nil
  container.payOrderList:ResetData(pbData.payOrderList)
  container.__data__.payOrderList = nil
  container.lifeProfession:ResetData(pbData.lifeProfession)
  container.__data__.lifeProfession = nil
  container.lifeProfessionWork:ResetData(pbData.lifeProfessionWork)
  container.__data__.lifeProfessionWork = nil
  container.userActivityList:ResetData(pbData.userActivityList)
  container.__data__.userActivityList = nil
  container.playerRecord:ResetData(pbData.playerRecord)
  container.__data__.playerRecord = nil
  container.dropContainer:ResetData(pbData.dropContainer)
  container.__data__.dropContainer = nil
  container.monthlyCard:ResetData(pbData.monthlyCard)
  container.__data__.monthlyCard = nil
  container.fashionBenefit:ResetData(pbData.fashionBenefit)
  container.__data__.fashionBenefit = nil
  container.itemCurrency:ResetData(pbData.itemCurrency)
  container.__data__.itemCurrency = nil
  container.privilegeEffectData:ResetData(pbData.privilegeEffectData)
  container.__data__.privilegeEffectData = nil
  container.treasure:ResetData(pbData.treasure)
  container.__data__.treasure = nil
  container.unlockEmojiData:ResetData(pbData.unlockEmojiData)
  container.__data__.unlockEmojiData = nil
  container.playerOrderComtainerInfo:ResetData(pbData.playerOrderComtainerInfo)
  container.__data__.playerOrderComtainerInfo = nil
  container.playerBox:ResetData(pbData.playerBox)
  container.__data__.playerBox = nil
  container.launchPrivilegeData:ResetData(pbData.launchPrivilegeData)
  container.__data__.launchPrivilegeData = nil
  container.battlePassData:ResetData(pbData.battlePassData)
  container.__data__.battlePassData = nil
  container.rechargeData:ResetData(pbData.rechargeData)
  container.__data__.rechargeData = nil
  container.luckyValueMgr:ResetData(pbData.luckyValueMgr)
  container.__data__.luckyValueMgr = nil
  container.handbookData:ResetData(pbData.handbookData)
  container.__data__.handbookData = nil
  container.masterModeDungeonInfo:ResetData(pbData.masterModeDungeonInfo)
  container.__data__.masterModeDungeonInfo = nil
  container.statisticsData:ResetData(pbData.statisticsData)
  container.__data__.statisticsData = nil
  container.compenstionStatistics:ResetData(pbData.compenstionStatistics)
  container.__data__.compenstionStatistics = nil
  container.bubbleActData:ResetData(pbData.bubbleActData)
  container.__data__.bubbleActData = nil
  container.mailClaimedInfo:ResetData(pbData.mailClaimedInfo)
  container.__data__.mailClaimedInfo = nil
  container.newbieData:ResetData(pbData.newbieData)
  container.__data__.newbieData = nil
  container.fightPoint:ResetData(pbData.fightPoint)
  container.__data__.fightPoint = nil
  container.sign:ResetData(pbData.sign)
  container.__data__.sign = nil
  container.charStatisticsData:ResetData(pbData.charStatisticsData)
  container.__data__.charStatisticsData = nil
end
local mergeData = function(container, buffer, watcherList)
  if not container or not container.__data__ then
    error("container is nil or not container")
  end
  local tag = br.ReadInt32(buffer)
  if tag ~= -2 then
    error("Invalid begin tag:" .. tag)
    return
  end
  local size = br.ReadInt32(buffer)
  if size == -3 then
    return
  end
  local offset = br.Offset(buffer)
  local index = br.ReadInt32(buffer)
  while 0 < index do
    local func = mergeDataFuncs[index]
    if func ~= nil then
      func(container, buffer, watcherList)
    else
      logWarning("Unknown field: " .. index)
      br.SetOffset(buffer, offset + size)
    end
    index = br.ReadInt32(buffer)
  end
  if index ~= -3 then
    error("Invalid end tag:" .. index)
  end
  if watcherList and container.Watcher.isDirty then
    watcherList[#watcherList + 1] = container.Watcher
  end
end
local getContainerElem = function(container)
  if container == nil then
    return nil
  end
  local ret = {}
  ret.charId = {
    fieldId = 1,
    dataType = 0,
    data = container.charId
  }
  if container.charBase == nil then
    ret.charBase = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.charBase = {
      fieldId = 2,
      dataType = 1,
      data = container.charBase:GetContainerElem()
    }
  end
  if container.sceneData == nil then
    ret.sceneData = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.sceneData = {
      fieldId = 3,
      dataType = 1,
      data = container.sceneData:GetContainerElem()
    }
  end
  if container.sceneLuaData == nil then
    ret.sceneLuaData = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.sceneLuaData = {
      fieldId = 4,
      dataType = 1,
      data = container.sceneLuaData:GetContainerElem()
    }
  end
  if container.pioneerData == nil then
    ret.pioneerData = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.pioneerData = {
      fieldId = 5,
      dataType = 1,
      data = container.pioneerData:GetContainerElem()
    }
  end
  if container.buffInfo == nil then
    ret.buffInfo = {
      fieldId = 6,
      dataType = 1,
      data = nil
    }
  else
    ret.buffInfo = {
      fieldId = 6,
      dataType = 1,
      data = container.buffInfo:GetContainerElem()
    }
  end
  if container.itemPackage == nil then
    ret.itemPackage = {
      fieldId = 7,
      dataType = 1,
      data = nil
    }
  else
    ret.itemPackage = {
      fieldId = 7,
      dataType = 1,
      data = container.itemPackage:GetContainerElem()
    }
  end
  if container.questList == nil then
    ret.questList = {
      fieldId = 8,
      dataType = 1,
      data = nil
    }
  else
    ret.questList = {
      fieldId = 8,
      dataType = 1,
      data = container.questList:GetContainerElem()
    }
  end
  if container.settingData == nil then
    ret.settingData = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.settingData = {
      fieldId = 9,
      dataType = 1,
      data = container.settingData:GetContainerElem()
    }
  end
  if container.miscInfo == nil then
    ret.miscInfo = {
      fieldId = 10,
      dataType = 1,
      data = nil
    }
  else
    ret.miscInfo = {
      fieldId = 10,
      dataType = 1,
      data = container.miscInfo:GetContainerElem()
    }
  end
  if container.exchangeItems == nil then
    ret.exchangeItems = {
      fieldId = 11,
      dataType = 1,
      data = nil
    }
  else
    ret.exchangeItems = {
      fieldId = 11,
      dataType = 1,
      data = container.exchangeItems:GetContainerElem()
    }
  end
  if container.equip == nil then
    ret.equip = {
      fieldId = 12,
      dataType = 1,
      data = nil
    }
  else
    ret.equip = {
      fieldId = 12,
      dataType = 1,
      data = container.equip:GetContainerElem()
    }
  end
  if container.energyItem == nil then
    ret.energyItem = {
      fieldId = 13,
      dataType = 1,
      data = nil
    }
  else
    ret.energyItem = {
      fieldId = 13,
      dataType = 1,
      data = container.energyItem:GetContainerElem()
    }
  end
  if container.mapData == nil then
    ret.mapData = {
      fieldId = 14,
      dataType = 1,
      data = nil
    }
  else
    ret.mapData = {
      fieldId = 14,
      dataType = 1,
      data = container.mapData:GetContainerElem()
    }
  end
  if container.dungeonList == nil then
    ret.dungeonList = {
      fieldId = 15,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonList = {
      fieldId = 15,
      dataType = 1,
      data = container.dungeonList:GetContainerElem()
    }
  end
  if container.attr == nil then
    ret.attr = {
      fieldId = 16,
      dataType = 1,
      data = nil
    }
  else
    ret.attr = {
      fieldId = 16,
      dataType = 1,
      data = container.attr:GetContainerElem()
    }
  end
  if container.fashion == nil then
    ret.fashion = {
      fieldId = 17,
      dataType = 1,
      data = nil
    }
  else
    ret.fashion = {
      fieldId = 17,
      dataType = 1,
      data = container.fashion:GetContainerElem()
    }
  end
  if container.profileList == nil then
    ret.profileList = {
      fieldId = 18,
      dataType = 1,
      data = nil
    }
  else
    ret.profileList = {
      fieldId = 18,
      dataType = 1,
      data = container.profileList:GetContainerElem()
    }
  end
  if container.help == nil then
    ret.help = {
      fieldId = 19,
      dataType = 1,
      data = nil
    }
  else
    ret.help = {
      fieldId = 19,
      dataType = 1,
      data = container.help:GetContainerElem()
    }
  end
  if container.counterList == nil then
    ret.counterList = {
      fieldId = 20,
      dataType = 1,
      data = nil
    }
  else
    ret.counterList = {
      fieldId = 20,
      dataType = 1,
      data = container.counterList:GetContainerElem()
    }
  end
  if container.personalObj == nil then
    ret.personalObj = {
      fieldId = 21,
      dataType = 1,
      data = nil
    }
  else
    ret.personalObj = {
      fieldId = 21,
      dataType = 1,
      data = container.personalObj:GetContainerElem()
    }
  end
  if container.roleLevel == nil then
    ret.roleLevel = {
      fieldId = 22,
      dataType = 1,
      data = nil
    }
  else
    ret.roleLevel = {
      fieldId = 22,
      dataType = 1,
      data = container.roleLevel:GetContainerElem()
    }
  end
  if container.pivot == nil then
    ret.pivot = {
      fieldId = 23,
      dataType = 1,
      data = nil
    }
  else
    ret.pivot = {
      fieldId = 23,
      dataType = 1,
      data = container.pivot:GetContainerElem()
    }
  end
  if container.transferPoint == nil then
    ret.transferPoint = {
      fieldId = 24,
      dataType = 1,
      data = nil
    }
  else
    ret.transferPoint = {
      fieldId = 24,
      dataType = 1,
      data = container.transferPoint:GetContainerElem()
    }
  end
  if container.planetMemory == nil then
    ret.planetMemory = {
      fieldId = 25,
      dataType = 1,
      data = nil
    }
  else
    ret.planetMemory = {
      fieldId = 25,
      dataType = 1,
      data = container.planetMemory:GetContainerElem()
    }
  end
  if container.planetMemoryTarget == nil then
    ret.planetMemoryTarget = {
      fieldId = 26,
      dataType = 1,
      data = nil
    }
  else
    ret.planetMemoryTarget = {
      fieldId = 26,
      dataType = 1,
      data = container.planetMemoryTarget:GetContainerElem()
    }
  end
  if container.redDot == nil then
    ret.redDot = {
      fieldId = 27,
      dataType = 1,
      data = nil
    }
  else
    ret.redDot = {
      fieldId = 27,
      dataType = 1,
      data = container.redDot:GetContainerElem()
    }
  end
  if container.resonance == nil then
    ret.resonance = {
      fieldId = 28,
      dataType = 1,
      data = nil
    }
  else
    ret.resonance = {
      fieldId = 28,
      dataType = 1,
      data = container.resonance:GetContainerElem()
    }
  end
  if container.cutsState == nil then
    ret.cutsState = {
      fieldId = 29,
      dataType = 1,
      data = nil
    }
  else
    ret.cutsState = {
      fieldId = 29,
      dataType = 1,
      data = container.cutsState:GetContainerElem()
    }
  end
  if container.investigateList == nil then
    ret.investigateList = {
      fieldId = 30,
      dataType = 1,
      data = nil
    }
  else
    ret.investigateList = {
      fieldId = 30,
      dataType = 1,
      data = container.investigateList:GetContainerElem()
    }
  end
  if container.records == nil then
    ret.records = {
      fieldId = 31,
      dataType = 1,
      data = nil
    }
  else
    ret.records = {
      fieldId = 31,
      dataType = 1,
      data = container.records:GetContainerElem()
    }
  end
  if container.interaction == nil then
    ret.interaction = {
      fieldId = 32,
      dataType = 1,
      data = nil
    }
  else
    ret.interaction = {
      fieldId = 32,
      dataType = 1,
      data = container.interaction:GetContainerElem()
    }
  end
  if container.seasonQuestList == nil then
    ret.seasonQuestList = {
      fieldId = 33,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonQuestList = {
      fieldId = 33,
      dataType = 1,
      data = container.seasonQuestList:GetContainerElem()
    }
  end
  if container.roleFace == nil then
    ret.roleFace = {
      fieldId = 34,
      dataType = 1,
      data = nil
    }
  else
    ret.roleFace = {
      fieldId = 34,
      dataType = 1,
      data = container.roleFace:GetContainerElem()
    }
  end
  if container.mapBookList == nil then
    ret.mapBookList = {
      fieldId = 35,
      dataType = 1,
      data = nil
    }
  else
    ret.mapBookList = {
      fieldId = 35,
      dataType = 1,
      data = container.mapBookList:GetContainerElem()
    }
  end
  if container.FunctionData == nil then
    ret.FunctionData = {
      fieldId = 36,
      dataType = 1,
      data = nil
    }
  else
    ret.FunctionData = {
      fieldId = 36,
      dataType = 1,
      data = container.FunctionData:GetContainerElem()
    }
  end
  if container.antiInfo == nil then
    ret.antiInfo = {
      fieldId = 37,
      dataType = 1,
      data = nil
    }
  else
    ret.antiInfo = {
      fieldId = 37,
      dataType = 1,
      data = container.antiInfo:GetContainerElem()
    }
  end
  if container.monsterExploreList == nil then
    ret.monsterExploreList = {
      fieldId = 38,
      dataType = 1,
      data = nil
    }
  else
    ret.monsterExploreList = {
      fieldId = 38,
      dataType = 1,
      data = container.monsterExploreList:GetContainerElem()
    }
  end
  if container.showPieceData == nil then
    ret.showPieceData = {
      fieldId = 39,
      dataType = 1,
      data = nil
    }
  else
    ret.showPieceData = {
      fieldId = 39,
      dataType = 1,
      data = container.showPieceData:GetContainerElem()
    }
  end
  if container.collectionBook == nil then
    ret.collectionBook = {
      fieldId = 42,
      dataType = 1,
      data = nil
    }
  else
    ret.collectionBook = {
      fieldId = 42,
      dataType = 1,
      data = container.collectionBook:GetContainerElem()
    }
  end
  if container.notGetProceedAwardTimes == nil then
    ret.notGetProceedAwardTimes = {
      fieldId = 43,
      dataType = 1,
      data = nil
    }
  else
    ret.notGetProceedAwardTimes = {
      fieldId = 43,
      dataType = 1,
      data = container.notGetProceedAwardTimes:GetContainerElem()
    }
  end
  if container.cookList == nil then
    ret.cookList = {
      fieldId = 44,
      dataType = 1,
      data = nil
    }
  else
    ret.cookList = {
      fieldId = 44,
      dataType = 1,
      data = container.cookList:GetContainerElem()
    }
  end
  if container.refreshDataList == nil then
    ret.refreshDataList = {
      fieldId = 45,
      dataType = 1,
      data = nil
    }
  else
    ret.refreshDataList = {
      fieldId = 45,
      dataType = 1,
      data = container.refreshDataList:GetContainerElem()
    }
  end
  if container.challengeDungeonInfo == nil then
    ret.challengeDungeonInfo = {
      fieldId = 46,
      dataType = 1,
      data = nil
    }
  else
    ret.challengeDungeonInfo = {
      fieldId = 46,
      dataType = 1,
      data = container.challengeDungeonInfo:GetContainerElem()
    }
  end
  if container.syncAwardData == nil then
    ret.syncAwardData = {
      fieldId = 47,
      dataType = 1,
      data = nil
    }
  else
    ret.syncAwardData = {
      fieldId = 47,
      dataType = 1,
      data = container.syncAwardData:GetContainerElem()
    }
  end
  if container.seasonAchievementList == nil then
    ret.seasonAchievementList = {
      fieldId = 48,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonAchievementList = {
      fieldId = 48,
      dataType = 1,
      data = container.seasonAchievementList:GetContainerElem()
    }
  end
  if container.seasonRankList == nil then
    ret.seasonRankList = {
      fieldId = 49,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonRankList = {
      fieldId = 49,
      dataType = 1,
      data = container.seasonRankList:GetContainerElem()
    }
  end
  if container.seasonCenter == nil then
    ret.seasonCenter = {
      fieldId = 50,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonCenter = {
      fieldId = 50,
      dataType = 1,
      data = container.seasonCenter:GetContainerElem()
    }
  end
  if container.personalZone == nil then
    ret.personalZone = {
      fieldId = 51,
      dataType = 1,
      data = nil
    }
  else
    ret.personalZone = {
      fieldId = 51,
      dataType = 1,
      data = container.personalZone:GetContainerElem()
    }
  end
  if container.seasonMedalInfo == nil then
    ret.seasonMedalInfo = {
      fieldId = 52,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonMedalInfo = {
      fieldId = 52,
      dataType = 1,
      data = container.seasonMedalInfo:GetContainerElem()
    }
  end
  if container.communityHomeInfo == nil then
    ret.communityHomeInfo = {
      fieldId = 53,
      dataType = 1,
      data = nil
    }
  else
    ret.communityHomeInfo = {
      fieldId = 53,
      dataType = 1,
      data = container.communityHomeInfo:GetContainerElem()
    }
  end
  if container.seasonActivation == nil then
    ret.seasonActivation = {
      fieldId = 54,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonActivation = {
      fieldId = 54,
      dataType = 1,
      data = container.seasonActivation:GetContainerElem()
    }
  end
  if container.slots == nil then
    ret.slots = {
      fieldId = 55,
      dataType = 1,
      data = nil
    }
  else
    ret.slots = {
      fieldId = 55,
      dataType = 1,
      data = container.slots:GetContainerElem()
    }
  end
  if container.monsterHuntInfo == nil then
    ret.monsterHuntInfo = {
      fieldId = 56,
      dataType = 1,
      data = nil
    }
  else
    ret.monsterHuntInfo = {
      fieldId = 56,
      dataType = 1,
      data = container.monsterHuntInfo:GetContainerElem()
    }
  end
  if container.mod == nil then
    ret.mod = {
      fieldId = 57,
      dataType = 1,
      data = nil
    }
  else
    ret.mod = {
      fieldId = 57,
      dataType = 1,
      data = container.mod:GetContainerElem()
    }
  end
  if container.worldEventMap == nil then
    ret.worldEventMap = {
      fieldId = 58,
      dataType = 1,
      data = nil
    }
  else
    ret.worldEventMap = {
      fieldId = 58,
      dataType = 1,
      data = container.worldEventMap:GetContainerElem()
    }
  end
  if container.fishSetting == nil then
    ret.fishSetting = {
      fieldId = 59,
      dataType = 1,
      data = nil
    }
  else
    ret.fishSetting = {
      fieldId = 59,
      dataType = 1,
      data = container.fishSetting:GetContainerElem()
    }
  end
  if container.freightData == nil then
    ret.freightData = {
      fieldId = 60,
      dataType = 1,
      data = nil
    }
  else
    ret.freightData = {
      fieldId = 60,
      dataType = 1,
      data = container.freightData:GetContainerElem()
    }
  end
  if container.professionList == nil then
    ret.professionList = {
      fieldId = 61,
      dataType = 1,
      data = nil
    }
  else
    ret.professionList = {
      fieldId = 61,
      dataType = 1,
      data = container.professionList:GetContainerElem()
    }
  end
  if container.trialRoad == nil then
    ret.trialRoad = {
      fieldId = 62,
      dataType = 1,
      data = nil
    }
  else
    ret.trialRoad = {
      fieldId = 62,
      dataType = 1,
      data = container.trialRoad:GetContainerElem()
    }
  end
  if container.gashaData == nil then
    ret.gashaData = {
      fieldId = 63,
      dataType = 1,
      data = nil
    }
  else
    ret.gashaData = {
      fieldId = 63,
      dataType = 1,
      data = container.gashaData:GetContainerElem()
    }
  end
  if container.shopData == nil then
    ret.shopData = {
      fieldId = 64,
      dataType = 1,
      data = nil
    }
  else
    ret.shopData = {
      fieldId = 64,
      dataType = 1,
      data = container.shopData:GetContainerElem()
    }
  end
  if container.personalWorldBossInfo == nil then
    ret.personalWorldBossInfo = {
      fieldId = 65,
      dataType = 1,
      data = nil
    }
  else
    ret.personalWorldBossInfo = {
      fieldId = 65,
      dataType = 1,
      data = container.personalWorldBossInfo:GetContainerElem()
    }
  end
  if container.craftEnergy == nil then
    ret.craftEnergy = {
      fieldId = 66,
      dataType = 1,
      data = nil
    }
  else
    ret.craftEnergy = {
      fieldId = 66,
      dataType = 1,
      data = container.craftEnergy:GetContainerElem()
    }
  end
  if container.weeklyTower == nil then
    ret.weeklyTower = {
      fieldId = 67,
      dataType = 1,
      data = nil
    }
  else
    ret.weeklyTower = {
      fieldId = 67,
      dataType = 1,
      data = container.weeklyTower:GetContainerElem()
    }
  end
  if container.cutSceneInfos == nil then
    ret.cutSceneInfos = {
      fieldId = 68,
      dataType = 1,
      data = nil
    }
  else
    ret.cutSceneInfos = {
      fieldId = 68,
      dataType = 1,
      data = container.cutSceneInfos:GetContainerElem()
    }
  end
  if container.recommendPlayData == nil then
    ret.recommendPlayData = {
      fieldId = 69,
      dataType = 1,
      data = nil
    }
  else
    ret.recommendPlayData = {
      fieldId = 69,
      dataType = 1,
      data = container.recommendPlayData:GetContainerElem()
    }
  end
  if container.rideList == nil then
    ret.rideList = {
      fieldId = 70,
      dataType = 1,
      data = nil
    }
  else
    ret.rideList = {
      fieldId = 70,
      dataType = 1,
      data = container.rideList:GetContainerElem()
    }
  end
  if container.payOrderList == nil then
    ret.payOrderList = {
      fieldId = 71,
      dataType = 1,
      data = nil
    }
  else
    ret.payOrderList = {
      fieldId = 71,
      dataType = 1,
      data = container.payOrderList:GetContainerElem()
    }
  end
  if container.lifeProfession == nil then
    ret.lifeProfession = {
      fieldId = 72,
      dataType = 1,
      data = nil
    }
  else
    ret.lifeProfession = {
      fieldId = 72,
      dataType = 1,
      data = container.lifeProfession:GetContainerElem()
    }
  end
  if container.lifeProfessionWork == nil then
    ret.lifeProfessionWork = {
      fieldId = 73,
      dataType = 1,
      data = nil
    }
  else
    ret.lifeProfessionWork = {
      fieldId = 73,
      dataType = 1,
      data = container.lifeProfessionWork:GetContainerElem()
    }
  end
  if container.userActivityList == nil then
    ret.userActivityList = {
      fieldId = 74,
      dataType = 1,
      data = nil
    }
  else
    ret.userActivityList = {
      fieldId = 74,
      dataType = 1,
      data = container.userActivityList:GetContainerElem()
    }
  end
  if container.playerRecord == nil then
    ret.playerRecord = {
      fieldId = 75,
      dataType = 1,
      data = nil
    }
  else
    ret.playerRecord = {
      fieldId = 75,
      dataType = 1,
      data = container.playerRecord:GetContainerElem()
    }
  end
  if container.dropContainer == nil then
    ret.dropContainer = {
      fieldId = 76,
      dataType = 1,
      data = nil
    }
  else
    ret.dropContainer = {
      fieldId = 76,
      dataType = 1,
      data = container.dropContainer:GetContainerElem()
    }
  end
  if container.monthlyCard == nil then
    ret.monthlyCard = {
      fieldId = 77,
      dataType = 1,
      data = nil
    }
  else
    ret.monthlyCard = {
      fieldId = 77,
      dataType = 1,
      data = container.monthlyCard:GetContainerElem()
    }
  end
  if container.fashionBenefit == nil then
    ret.fashionBenefit = {
      fieldId = 78,
      dataType = 1,
      data = nil
    }
  else
    ret.fashionBenefit = {
      fieldId = 78,
      dataType = 1,
      data = container.fashionBenefit:GetContainerElem()
    }
  end
  if container.itemCurrency == nil then
    ret.itemCurrency = {
      fieldId = 79,
      dataType = 1,
      data = nil
    }
  else
    ret.itemCurrency = {
      fieldId = 79,
      dataType = 1,
      data = container.itemCurrency:GetContainerElem()
    }
  end
  if container.privilegeEffectData == nil then
    ret.privilegeEffectData = {
      fieldId = 80,
      dataType = 1,
      data = nil
    }
  else
    ret.privilegeEffectData = {
      fieldId = 80,
      dataType = 1,
      data = container.privilegeEffectData:GetContainerElem()
    }
  end
  if container.treasure == nil then
    ret.treasure = {
      fieldId = 81,
      dataType = 1,
      data = nil
    }
  else
    ret.treasure = {
      fieldId = 81,
      dataType = 1,
      data = container.treasure:GetContainerElem()
    }
  end
  if container.unlockEmojiData == nil then
    ret.unlockEmojiData = {
      fieldId = 82,
      dataType = 1,
      data = nil
    }
  else
    ret.unlockEmojiData = {
      fieldId = 82,
      dataType = 1,
      data = container.unlockEmojiData:GetContainerElem()
    }
  end
  if container.playerOrderComtainerInfo == nil then
    ret.playerOrderComtainerInfo = {
      fieldId = 83,
      dataType = 1,
      data = nil
    }
  else
    ret.playerOrderComtainerInfo = {
      fieldId = 83,
      dataType = 1,
      data = container.playerOrderComtainerInfo:GetContainerElem()
    }
  end
  if container.playerBox == nil then
    ret.playerBox = {
      fieldId = 84,
      dataType = 1,
      data = nil
    }
  else
    ret.playerBox = {
      fieldId = 84,
      dataType = 1,
      data = container.playerBox:GetContainerElem()
    }
  end
  if container.launchPrivilegeData == nil then
    ret.launchPrivilegeData = {
      fieldId = 85,
      dataType = 1,
      data = nil
    }
  else
    ret.launchPrivilegeData = {
      fieldId = 85,
      dataType = 1,
      data = container.launchPrivilegeData:GetContainerElem()
    }
  end
  if container.battlePassData == nil then
    ret.battlePassData = {
      fieldId = 86,
      dataType = 1,
      data = nil
    }
  else
    ret.battlePassData = {
      fieldId = 86,
      dataType = 1,
      data = container.battlePassData:GetContainerElem()
    }
  end
  if container.rechargeData == nil then
    ret.rechargeData = {
      fieldId = 87,
      dataType = 1,
      data = nil
    }
  else
    ret.rechargeData = {
      fieldId = 87,
      dataType = 1,
      data = container.rechargeData:GetContainerElem()
    }
  end
  if container.luckyValueMgr == nil then
    ret.luckyValueMgr = {
      fieldId = 88,
      dataType = 1,
      data = nil
    }
  else
    ret.luckyValueMgr = {
      fieldId = 88,
      dataType = 1,
      data = container.luckyValueMgr:GetContainerElem()
    }
  end
  if container.handbookData == nil then
    ret.handbookData = {
      fieldId = 89,
      dataType = 1,
      data = nil
    }
  else
    ret.handbookData = {
      fieldId = 89,
      dataType = 1,
      data = container.handbookData:GetContainerElem()
    }
  end
  if container.masterModeDungeonInfo == nil then
    ret.masterModeDungeonInfo = {
      fieldId = 90,
      dataType = 1,
      data = nil
    }
  else
    ret.masterModeDungeonInfo = {
      fieldId = 90,
      dataType = 1,
      data = container.masterModeDungeonInfo:GetContainerElem()
    }
  end
  if container.statisticsData == nil then
    ret.statisticsData = {
      fieldId = 91,
      dataType = 1,
      data = nil
    }
  else
    ret.statisticsData = {
      fieldId = 91,
      dataType = 1,
      data = container.statisticsData:GetContainerElem()
    }
  end
  if container.compenstionStatistics == nil then
    ret.compenstionStatistics = {
      fieldId = 92,
      dataType = 1,
      data = nil
    }
  else
    ret.compenstionStatistics = {
      fieldId = 92,
      dataType = 1,
      data = container.compenstionStatistics:GetContainerElem()
    }
  end
  if container.bubbleActData == nil then
    ret.bubbleActData = {
      fieldId = 93,
      dataType = 1,
      data = nil
    }
  else
    ret.bubbleActData = {
      fieldId = 93,
      dataType = 1,
      data = container.bubbleActData:GetContainerElem()
    }
  end
  if container.mailClaimedInfo == nil then
    ret.mailClaimedInfo = {
      fieldId = 94,
      dataType = 1,
      data = nil
    }
  else
    ret.mailClaimedInfo = {
      fieldId = 94,
      dataType = 1,
      data = container.mailClaimedInfo:GetContainerElem()
    }
  end
  if container.newbieData == nil then
    ret.newbieData = {
      fieldId = 95,
      dataType = 1,
      data = nil
    }
  else
    ret.newbieData = {
      fieldId = 95,
      dataType = 1,
      data = container.newbieData:GetContainerElem()
    }
  end
  if container.fightPoint == nil then
    ret.fightPoint = {
      fieldId = 96,
      dataType = 1,
      data = nil
    }
  else
    ret.fightPoint = {
      fieldId = 96,
      dataType = 1,
      data = container.fightPoint:GetContainerElem()
    }
  end
  if container.sign == nil then
    ret.sign = {
      fieldId = 97,
      dataType = 1,
      data = nil
    }
  else
    ret.sign = {
      fieldId = 97,
      dataType = 1,
      data = container.sign:GetContainerElem()
    }
  end
  if container.charStatisticsData == nil then
    ret.charStatisticsData = {
      fieldId = 98,
      dataType = 1,
      data = nil
    }
  else
    ret.charStatisticsData = {
      fieldId = 98,
      dataType = 1,
      data = container.charStatisticsData:GetContainerElem()
    }
  end
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    charBase = require("zcontainer.char_base_info").New(),
    sceneData = require("zcontainer.scene_data").New(),
    sceneLuaData = require("zcontainer.scene_lua_data").New(),
    pioneerData = require("zcontainer.pioneer_data").New(),
    buffInfo = require("zcontainer.buff_d_b_info").New(),
    itemPackage = require("zcontainer.item_package").New(),
    questList = require("zcontainer.quest_data_list").New(),
    settingData = require("zcontainer.setting_data").New(),
    miscInfo = require("zcontainer.misc_info").New(),
    exchangeItems = require("zcontainer.exchange_item").New(),
    equip = require("zcontainer.equip_list").New(),
    energyItem = require("zcontainer.energy_item").New(),
    mapData = require("zcontainer.map_data").New(),
    dungeonList = require("zcontainer.dungeon_list").New(),
    attr = require("zcontainer.user_fight_attr").New(),
    fashion = require("zcontainer.fashion_mgr").New(),
    profileList = require("zcontainer.profile_list").New(),
    help = require("zcontainer.play_helper").New(),
    counterList = require("zcontainer.counter_list").New(),
    personalObj = require("zcontainer.personal_object").New(),
    roleLevel = require("zcontainer.role_level").New(),
    pivot = require("zcontainer.pivot").New(),
    transferPoint = require("zcontainer.transfer_point").New(),
    planetMemory = require("zcontainer.planet_memory").New(),
    planetMemoryTarget = require("zcontainer.season_target").New(),
    redDot = require("zcontainer.red_dot_data").New(),
    resonance = require("zcontainer.resonance").New(),
    cutsState = require("zcontainer.cuts_state").New(),
    investigateList = require("zcontainer.investigate_list").New(),
    records = require("zcontainer.parkour_record_list").New(),
    interaction = require("zcontainer.interaction_info").New(),
    seasonQuestList = require("zcontainer.season_quest_list").New(),
    roleFace = require("zcontainer.role_face").New(),
    mapBookList = require("zcontainer.map_book_info_list").New(),
    FunctionData = require("zcontainer.function_data").New(),
    antiInfo = require("zcontainer.anti_addiction_info").New(),
    monsterExploreList = require("zcontainer.monster_explore_list").New(),
    showPieceData = require("zcontainer.show_piece_data").New(),
    collectionBook = require("zcontainer.collection_book").New(),
    notGetProceedAwardTimes = require("zcontainer.not_get_proceed_award_info").New(),
    cookList = require("zcontainer.cook_list").New(),
    refreshDataList = require("zcontainer.timer_refresh_data_list").New(),
    challengeDungeonInfo = require("zcontainer.challenge_dungeon_info").New(),
    syncAwardData = require("zcontainer.sync_award_data").New(),
    seasonAchievementList = require("zcontainer.season_achievement_list").New(),
    seasonRankList = require("zcontainer.season_rank_list").New(),
    seasonCenter = require("zcontainer.season_center").New(),
    personalZone = require("zcontainer.personal_zone").New(),
    seasonMedalInfo = require("zcontainer.season_medal_info").New(),
    communityHomeInfo = require("zcontainer.community_home_data").New(),
    seasonActivation = require("zcontainer.season_activation").New(),
    slots = require("zcontainer.slot").New(),
    monsterHuntInfo = require("zcontainer.monster_hunt_info").New(),
    mod = require("zcontainer.mod").New(),
    worldEventMap = require("zcontainer.world_event_map").New(),
    fishSetting = require("zcontainer.fish_setting").New(),
    freightData = require("zcontainer.freight_data").New(),
    professionList = require("zcontainer.profession_list").New(),
    trialRoad = require("zcontainer.trial_road").New(),
    gashaData = require("zcontainer.gasha_data").New(),
    shopData = require("zcontainer.shop_data").New(),
    personalWorldBossInfo = require("zcontainer.personal_world_boss_info").New(),
    craftEnergy = require("zcontainer.craft_energy_record").New(),
    weeklyTower = require("zcontainer.weekly_tower_record").New(),
    cutSceneInfos = require("zcontainer.cut_scene_infos").New(),
    recommendPlayData = require("zcontainer.user_recommend_play_data").New(),
    rideList = require("zcontainer.ride_list").New(),
    payOrderList = require("zcontainer.pay_order_list").New(),
    lifeProfession = require("zcontainer.life_profession").New(),
    lifeProfessionWork = require("zcontainer.life_profession_work").New(),
    userActivityList = require("zcontainer.user_activity_list").New(),
    playerRecord = require("zcontainer.player_record").New(),
    dropContainer = require("zcontainer.drop_container_info").New(),
    monthlyCard = require("zcontainer.monthly_card").New(),
    fashionBenefit = require("zcontainer.fashion_benefit").New(),
    itemCurrency = require("zcontainer.item_currency").New(),
    privilegeEffectData = require("zcontainer.privilege_effect_data").New(),
    treasure = require("zcontainer.treasure").New(),
    unlockEmojiData = require("zcontainer.unlock_emoji_data").New(),
    playerOrderComtainerInfo = require("zcontainer.player_order_comtainer_info").New(),
    playerBox = require("zcontainer.player_box").New(),
    launchPrivilegeData = require("zcontainer.launch_privilege_data").New(),
    battlePassData = require("zcontainer.battle_pass_data").New(),
    rechargeData = require("zcontainer.recharge_data").New(),
    luckyValueMgr = require("zcontainer.lucky_value_mgr").New(),
    handbookData = require("zcontainer.handbook_data").New(),
    masterModeDungeonInfo = require("zcontainer.master_mode_dungeon_info").New(),
    statisticsData = require("zcontainer.statistics_data").New(),
    compenstionStatistics = require("zcontainer.compensation_statistics").New(),
    bubbleActData = require("zcontainer.bubble_act_data").New(),
    mailClaimedInfo = require("zcontainer.mail_claimed_info").New(),
    newbieData = require("zcontainer.newbie_data").New(),
    fightPoint = require("zcontainer.fight_point").New(),
    sign = require("zcontainer.sign_info").New(),
    charStatisticsData = require("zcontainer.char_statistics_data").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
