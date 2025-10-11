local DEF = {}
DEF.MessageType = {
  Enter = "pandoraShowEntrance",
  ShowRedDot = "pandoraShowRedpoint",
  ShowTip = "pandoraShowTextTip",
  ShowLoading = "pandoraShowLoading",
  pandoraShowItemTip = "pandoraShowItemTip",
  ShowReceivedItem = "pandoraShowReceivedItem",
  OpenUrl = "pandoraOpenUrl",
  GoFunc = "pandoraGoSystem",
  GoPandora = "pandoraGoPandora",
  GetUserInfo = "pandoraGetUserInfo",
  GetUserInfoResult = "getUserInfoResult",
  OpenMiniApp = "pandoraOpenMiniApp",
  ShowAnnounce = "show",
  HideAnnounce = "hide",
  RefreshAnnounce = "panameraRefreshADData",
  CloseApp = "pandoraCloseApp",
  panameraCheckUnShowData = "panameraCheckUnShowData",
  panameraCheckUnShowDataResult = "panameraCheckUnShowDataResult",
  GetNotchHeight = "pandoraGetNotchHeight",
  SendNotchHeight = "getNotchHeightResult"
}
DEF.EventName = {
  ResourceReady = "ResourceReady",
  ViewCreate = "ViewCreate",
  ViewDestroy = "ViewDestroy"
}
DEF.PlatformId = {
  iOS = 0,
  Android = 1,
  PC = 2
}
DEF.AreaId = {WeChat = 1, QQ = 2}
DEF.SERVER_TYPE = "bpm"
DEF.APP_ID = {
  Announce = "7014",
  Activity = "7517",
  Popup = "7518"
}
DEF.APP_CONFIG = {
  [DEF.APP_ID.Announce] = {
    IsSubView = false,
    Layer = Z.UI.ELayer.UILayerSDK,
    RedDotId = 1701
  },
  [DEF.APP_ID.Activity] = {IsSubView = true, RedDotId = 82000002},
  [DEF.APP_ID.Popup] = {
    IsSubView = false,
    Layer = Z.UI.ELayer.UILayerTipTop
  }
}
return DEF
