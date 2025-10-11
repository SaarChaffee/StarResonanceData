local read_onlyHelper = require("utility.readonly_helper")
local SeasonGlobalConfig = {
  SeasonLifePointMaxLimit = {
    {1, 1001},
    {2, 1002}
  }
}
return read_onlyHelper.Read_only(SeasonGlobalConfig)
