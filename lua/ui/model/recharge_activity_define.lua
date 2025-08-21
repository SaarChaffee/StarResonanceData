local DEF = {}
DEF.ProductIdType = {Free = 0, Payment = 1}
DEF.GiftShowType = {Icon = 0, Model = 1}
DEF.DiscountType = {
  Discount = 1,
  Text = 2,
  Time = 3
}
DEF.EActivityStatus = {ActivityStatusOnline = 0, ActivityStatusOffline = 1}
DEF.EActivityType = {ActivityTypeNone = 0, ActivityTypeBuyGift = 1}
DEF.EActivityObtainStatus = {
  ActivityObtainStatusNone = 0,
  ActivityObtainStatusCan = 1,
  ActivityObtainStatusAlready = 2
}
DEF.EActivityRewardTimesType = {
  ActivityRewardTimesTypeNone = 0,
  ActivityRewardTimesTypeOnce = 1,
  ActivityRewardTimesTypeDay = 2,
  ActivityRewardTimesTypeWeek = 4
}
return DEF
