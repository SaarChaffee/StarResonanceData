local DEF = {}
E.LoginType = {
  None = 0,
  WeChat = 1,
  QQ = 2,
  LevelInfinite = 131,
  HaoPlay = 1001
}
E.OS = {
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
  HaoPlayPlatform = Z.PbEnum("LoginPlatFormType", "HaoPlayPlatForm")
}
E.LoginSDKType = {
  None = Z.PbEnum("LoginSdkType", "LoginSdkTypeNull"),
  INTL = Z.PbEnum("LoginSdkType", "LoginSdkTypeIntl"),
  MSDK = Z.PbEnum("LoginSdkType", "LoginSdkTypeMSdk"),
  WeGame = Z.PbEnum("LoginSdkType", "LoginSdkTypeWeGame"),
  GLauncher = Z.PbEnum("LoginSdkType", "LoginSdkTypeGLauncher"),
  HaoPlay = Z.PbEnum("LoginSdkType", "LoginSdkTypeHaoPlay")
}
DEF.CONFIG = {
  [E.LoginPlatformType.InnerPlatform] = {
    IsShowAgreementTips = false,
    ContractUrlPath = "",
    PrivacyGuideUrlPath = "",
    ChildrenPrivacyUrlPath = ""
  },
  [E.LoginPlatformType.TencentPlatform] = {
    IsShowAgreementTips = true,
    ContractUrlPath = "https://game.qq.com/tencent_other_contract.shtml",
    PrivacyGuideUrlPath = "https://game.qq.com/tencent_other_privacy.shtml",
    ChildrenPrivacyUrlPath = "https://game.qq.com/tencent_other_children_privacy.shtml"
  },
  [E.LoginPlatformType.IntlPlatform] = {
    IsShowAgreementTips = false,
    ContractUrlPath = "",
    PrivacyGuideUrlPath = "",
    ChildrenPrivacyUrlPath = ""
  }
}
return DEF
