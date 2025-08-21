local DEF = {}
E.UserSupportType = {
  None = 0,
  Login = 1,
  MainFunc = 2,
  Activity = 3,
  Setting = 4,
  Recharge = 5
}
E.LoginType = {
  None = 0,
  WeChat = 1,
  QQ = 2,
  Apple = 15,
  LevelInfinite = 131,
  HaoPlay = 1001
}
E.OS = {
  Unknown = 0,
  Android = 1,
  iOS = 2,
  Web = 3,
  Linux = 4,
  Windows = 5,
  Nintendo = 6,
  Mac = 7,
  Playstation = 8,
  XBox = 9
}
E.LoginPlatformType = {
  InnerPlatform = Z.PbEnum("LoginPlatFormType", "InnerPlatForm"),
  TencentPlatform = Z.PbEnum("LoginPlatFormType", "TencentPlatForm"),
  IntlPlatform = Z.PbEnum("LoginPlatFormType", "IntlPlatForm"),
  HaoPlayPlatform = Z.PbEnum("LoginPlatFormType", "HaoPlayPlatForm"),
  APJPlatform = Z.PbEnum("LoginPlatFormType", "ApjPlatForm")
}
E.LoginSDKType = {
  None = Z.PbEnum("LoginSdkType", "LoginSdkTypeNull"),
  INTL = Z.PbEnum("LoginSdkType", "LoginSdkTypeIntl"),
  MSDK = Z.PbEnum("LoginSdkType", "LoginSdkTypeMSdk"),
  WeGame = Z.PbEnum("LoginSdkType", "LoginSdkTypeWeGame"),
  GLauncher = Z.PbEnum("LoginSdkType", "LoginSdkTypeGLauncher"),
  HaoPlay = Z.PbEnum("LoginSdkType", "LoginSdkTypeHaoPlay"),
  APJ = Z.PbEnum("LoginSdkType", "LoginSdkTypeApj")
}
E.PlatformToPayType = {
  [E.LoginSDKType.MSDK] = Z.PbEnum("EPayType", "PayTypeMPay"),
  [E.LoginSDKType.WeGame] = Z.PbEnum("EPayType", "PayTypeMPay"),
  [E.LoginSDKType.HaoPlay] = Z.PbEnum("EPayType", "PayTypeHaoPlay")
}
DEF.CONFIG = {
  [E.LoginPlatformType.InnerPlatform] = {
    IsShowAgreementTips = false,
    ContractUrlPath = "",
    PrivacyGuideUrlPath = "",
    ChildrenPrivacyUrlPath = "",
    ThirdInfoShareUrlPath = "",
    CollectedInfoListUrlPath = ""
  },
  [E.LoginPlatformType.TencentPlatform] = {
    IsShowAgreementTips = true,
    ContractUrlPath = "https://game.qq.com/tencent_other_contract.shtml",
    PrivacyGuideUrlPath = "https://rule.tencent.com/rule/202505280002",
    ChildrenPrivacyUrlPath = "https://game.qq.com/tencent_other_children_privacy.shtml",
    ThirdInfoShareUrlPath = "https://rule.tencent.com/rule/202505280001",
    CollectedInfoListUrlPath = "https://rule.tencent.com/rule/202505280003"
  },
  [E.LoginPlatformType.IntlPlatform] = {
    IsShowAgreementTips = false,
    ContractUrlPath = "",
    PrivacyGuideUrlPath = "",
    ChildrenPrivacyUrlPath = "",
    ThirdInfoShareUrlPath = "",
    CollectedInfoListUrlPath = ""
  },
  [E.LoginPlatformType.APJPlatform] = {
    IsShowAgreementTips = false,
    ContractUrlPath = "",
    PrivacyGuideUrlPath = "",
    ChildrenPrivacyUrlPath = "",
    ThirdInfoShareUrlPath = "",
    CollectedInfoListUrlPath = ""
  }
}
DEF.SDK_TYPE_CONFIG = {
  [E.LoginSDKType.MSDK] = {
    UserSupportUrlPathDict = {
      [E.UserSupportType.Login] = "https://kf.qq.com/touch/sy/prod/A11234/v2/index.html?scene_id=CSCE20250212170803mvQUsCre",
      [E.UserSupportType.MainFunc] = "https://kf.qq.com/touch/sy/prod/A11234/v2/index.html?scene_id=CSCE20250212170839RglZGvft",
      [E.UserSupportType.Activity] = "https://kf.qq.com/touch/sy/prod/A11234/v2/index.html?scene_id=CSCE20250212171937ZzfuOvqB",
      [E.UserSupportType.Setting] = "https://kf.qq.com/touch/sy/prod/A11234/v2/index.html?scene_id=CSCE20250212170906zXGsUbRC",
      [E.UserSupportType.Recharge] = "https://kf.qq.com/touch/sy/prod/A11234/v2/index.html?scene_id=CSCE20250212172005BjtAbLSh"
    },
    UserSupportIconPathDict = {
      [E.UserSupportType.Login] = "ui/atlas/new_com/com_icon_service",
      [E.UserSupportType.MainFunc] = "ui/atlas/esc_icon/esc_icon_service_special",
      [E.UserSupportType.Setting] = "ui/atlas/new_com/com_icon_service"
    },
    UserSupportFunctionId = 100211
  },
  [E.LoginSDKType.WeGame] = {
    UserSupportUrlPathDict = {
      [E.UserSupportType.MainFunc] = "https://kf.qq.com/touch/kfgames/A11234/v2/PClient/conf/index.html?scene_id=CSCE20250306155242zYcTpqlo"
    },
    UserSupportIconPathDict = {
      [E.UserSupportType.Login] = "ui/atlas/new_com/com_icon_service",
      [E.UserSupportType.MainFunc] = "ui/atlas/esc_icon/esc_icon_service_special",
      [E.UserSupportType.Setting] = "ui/atlas/new_com/com_icon_service"
    },
    UserSupportFunctionId = 100211
  },
  [E.LoginSDKType.HaoPlay] = {
    UserSupportUrlPathDict = {
      [E.UserSupportType.Login] = "Open",
      [E.UserSupportType.MainFunc] = "Open",
      [E.UserSupportType.Setting] = "Open"
    },
    UserSupportIconPathDict = {
      [E.UserSupportType.Login] = "ui/atlas/login/login_custom_service",
      [E.UserSupportType.MainFunc] = "ui/atlas/esc_icon/esc_icon_service_normal",
      [E.UserSupportType.Setting] = "ui/atlas/login/login_custom_service"
    },
    UserSupportFunctionId = 900116,
    UserCenterUrlPathDict = {
      [E.UserSupportType.Setting] = "Open"
    },
    UserCenterFunctionId = 900117,
    HttpNoticeUrlPath = "https://bpm.17996cdn.net/notice/notice.txt"
  },
  [E.LoginSDKType.APJ] = {
    UserSupportUrlPathDict = {
      [E.UserSupportType.Login] = "Open",
      [E.UserSupportType.MainFunc] = "Open",
      [E.UserSupportType.Setting] = "Open"
    },
    UserSupportIconPathDict = {
      [E.UserSupportType.Login] = "ui/atlas/login/login_custom_service",
      [E.UserSupportType.MainFunc] = "ui/atlas/esc_icon/esc_icon_service_normal",
      [E.UserSupportType.Setting] = "ui/atlas/login/login_custom_service"
    },
    UserSupportFunctionId = 900118,
    UserCenterUrlPathDict = {
      [E.UserSupportType.Login] = "Open",
      [E.UserSupportType.Setting] = "Open"
    },
    UserCenterFunctionId = 900119,
    HttpNoticeUrlPath = "https://notice.playbpsr.com/notice/notice.txt"
  }
}
DEF.SDK_CHANNEL_ID = {
  Huawei = 10018084,
  Honor = 10484106,
  OPPO = 10017385,
  Vivo = 10003392,
  Xiaomi = 10003898,
  TapTap = 10025553,
  Haoyou = 10022592,
  Game4399 = 10004231,
  Bilibili = 10029304,
  KuaiShou = 10045011,
  Blackshark = 10063229,
  Jiuyou = 10048734,
  Douyu = 10032223,
  Huya = 10018351,
  DouyinXintu = 10482661,
  DouyinLianyun = 10497811
}
DEF.LaunchPlatform = {
  LaunchPlatformNull = Z.PbEnum("LaunchPlatform", "LaunchPlatformNull"),
  LaunchPlatformWeXin = Z.PbEnum("LaunchPlatform", "LaunchPlatformWeXin"),
  LaunchPlatformQq = Z.PbEnum("LaunchPlatform", "LaunchPlatformQq")
}
DEF.PlatformConfig = {
  PlatformConfigNull = 0,
  PlatformConfigAreaBlacklist = 1,
  PlatformConfigUrl = 2,
  PlatformConfigDefaultAvatar = 3,
  PlatformConfigLegalSchemePrefix = 4
}
DEF.SDK_URL_FUNCTION_TYPE = {
  Channel = 1,
  Privilege = 2,
  Gift = 3,
  GameCenter = 4,
  SuperVip = 5,
  ARK = 6,
  Growth = 7
}
DEF.WEBVIEW_ORIENTATION = {
  Auto = 1,
  Portrait = 2,
  Landscape = 3
}
DEF.ORIGINAL_SHARE_FUNCTION_TYPE = {
  Fishing = 1,
  PhotoTogether = 2,
  SeasonPlayFriend = 3,
  HomeTogether = 4
}
return DEF
