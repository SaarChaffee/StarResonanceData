local read_onlyHelper = require("utility.readonly_helper")
local UnionActivityConfig = {
  HuntUnionScore = {
    {1, 100},
    {2, 100},
    {3, 100},
    {4, 100},
    {5, 100},
    {6, 100},
    {7, 100},
    {8, 100}
  },
  HuntTreasureChest = {
    {40, 20500600},
    {70, 20500610},
    {100, 20500620}
  },
  HuntDungeonScore = {
    {
      12015,
      5,
      5,
      2
    },
    {
      12014,
      2,
      2,
      1
    }
  },
  HuntListLimitNum = 20,
  HuntListAwardNum = 5,
  HuntListAwardText = "\231\139\169\231\140\142\229\133\136\233\148\139",
  HuntDungeonCount = {
    {12015, 5},
    {12014, 6}
  },
  HuntPvxQuestID = 12023650,
  HuntPvxDungeonID = 12013,
  UnionSceneID = 12000,
  HuntUnionProgressTime = 3600,
  HuntUnionProgressFull = 100,
  HuntUnionAwardCounter = 4,
  NewUnionActLimitTime = 0,
  HuntActivityId = {
    {12014, 1},
    {12015, 1}
  },
  HuntAwardLeaveTimeLimit = 0,
  HuntCameraID = {4012}
}
return read_onlyHelper.Read_only(UnionActivityConfig)
