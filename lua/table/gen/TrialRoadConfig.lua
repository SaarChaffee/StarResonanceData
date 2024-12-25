local read_onlyHelper = require("utility.readonly_helper")
local TrialRoadConfig = {
  TrialRoadAward = {
    {3003001, 12101010},
    {3003002, 12101020},
    {3003003, 12101030},
    {3003004, 12101040},
    {3003005, 12101050},
    {3003006, 12101060},
    {3003007, 12101070},
    {3003008, 12101080},
    {3003009, 12101090},
    {3003010, 12101100}
  }
}
return read_onlyHelper.Read_only(TrialRoadConfig)
