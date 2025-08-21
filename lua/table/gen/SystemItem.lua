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
    10008,
    10002,
    10005,
    10003
  },
  NameCard = 1070001,
  VigourItemId = 20003,
  LifeProfessionExpItem = {
    {31001, 101},
    {31011, 102},
    {31021, 103},
    {31041, 201},
    {31051, 202},
    {31061, 203},
    {31071, 204},
    {31081, 205},
    {31091, 206}
  },
  LifeProfessionPointItem = 31000,
  SeasonExp = 301,
  FashionBenefitItemId = 20011,
  itemBlessExp = 202,
  Bindingcoin = 10008,
  SeasonExpIgnoreWeek = 302,
  HomeShopCurrencyDisplay = {10010},
  CompensationPoint = 10011,
  ShopPoint = 10006,
  ItemDiamondInMail = 10013
}
return read_onlyHelper.Read_only(SystemItem)
