local DEF = {}
DEF.QQAppId = "1112123139"
DEF.WechatAppId = "wx5f5e2ad064dcdefc"
DEF.QQFriendPicURLSuffix = "100"
DEF.WechatFriendPicURLSuffix = "96"
DEF.TencentTokenLinkOrientation = {
  Landscape = 1,
  Portrait = 2,
  isFullScrren = 4
}
DEF.SCHEMETYPE = {OpenWebView = 1, GameFunc = 2}
DEF.GROUP_CHANNEL = {
  None = -1,
  QQ = 0,
  WeChat = 1
}
DEF.GROUP_QQ_RET_MESSAGE = {
  [221001] = 160101,
  [221002] = 160102,
  [221005] = 160105,
  [221009] = 160109,
  [221010] = 160110,
  [221011] = 160111,
  [221012] = 160112,
  [221016] = 160116,
  [221018] = 160118,
  [221019] = 160119,
  [221020] = 160120,
  [221021] = 160121,
  [-182003] = 160124,
  [-182004] = 160125,
  [-182006] = 160127,
  [-182007] = 160128
}
DEF.GROUP_WECHAT_RET_MESSAGE = {
  [-10001] = 170203,
  [-10003] = 170205,
  [-10004] = 170206,
  [-10005] = 170207,
  [-10006] = 170208,
  [-10007] = 170209,
  [-10008] = 170210,
  [-10009] = 170211,
  [-10010] = 170212,
  [-20001] = 170213,
  [-20002] = 170214,
  [-20003] = 170215
}
DEF.GROUP_COMMON_RET_MESSAGE = 160140
DEF.TencentFriendSort = {
  Online = 0,
  OffOnline = 1,
  NoChar = 2
}
return DEF
