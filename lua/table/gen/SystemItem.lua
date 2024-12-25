local read_onlyHelper = require("utility.readonly_helper")
local SystemItem = {
  ItemLevelExp = 201,
  ItemOpenPoint = 10001,
  ItemCoin = 10002,
  ItemDiamond = 10003,
  ItemFriendPoint = 10004,
  ItemEnergyPoint = 10005,
  ItemTalentPoint = 30001,
  EnergyItemID = 20001,
  TalentPointConfigId = 30001,
  DefaultCurrencyDisplay = {
    10002,
    10005,
    10003
  },
  NameCard = 1070001
}
return read_onlyHelper.Read_only(SystemItem)
