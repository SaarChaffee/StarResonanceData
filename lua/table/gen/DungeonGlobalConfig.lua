local read_onlyHelper = require("utility.readonly_helper")
local DungeonGlobalConfig = {
  MasterScoreAward = {
    {500, 12030010},
    {1000, 12030020},
    {1500, 12030030},
    {2000, 12030040},
    {2500, 12030050},
    {3000, 12030060}
  },
  MasterHistoryScoreSeasonNum = 3,
  MasterSeasonAwardMailId = 1405,
  MasterSingleDungeonScoreLevel = {
    {1, 1},
    {100, 2},
    {200, 3},
    {300, 4},
    {400, 5},
    {500, 6}
  },
  MasterTotolDungeonScoreLevel = {
    {1, 1},
    {500, 2},
    {1200, 3},
    {1800, 4},
    {2400, 5},
    {3000, 6}
  },
  MasterScoreLevelColor = {
    {"1", "#dedede"},
    {"2", "#89bd92"},
    {"3", "#9cb9ef"},
    {"4", "#ab85f6"},
    {"5", "#eed335"},
    {"6", "#ef8e60"}
  }
}
return read_onlyHelper.Read_only(DungeonGlobalConfig)
