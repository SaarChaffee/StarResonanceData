local DEF = {}
DEF.PersonalTagType = {OnlineDayTime = 1, OnlineActivity = 2}
DEF.UNSHOWTAGICON = "ui/atlas/label_icon/personalzone_labels_0"
DEF.ColorStateEnum = {
  Normal = Color.New(1, 1, 1, 1),
  Disable = Color.New(0.6039215686274509, 0.9215686274509803, 0, 1)
}
DEF.MainIconType = {
  Tag = 1,
  Photo = 2,
  Medal = 2
}
DEF.BgSubViewFuncType = {
  SelectBg = 1,
  Reset = 2,
  Save = 3
}
DEF.ModelAnimTags = {
  CommonAction = 1,
  LoopAction = 2,
  Emote = 3
}
DEF.ModelAnimFunctionId = {
  [1] = {
    funcId = DEF.ModelAnimTags.CommonAction,
    icon = "ui/atlas/photograph/camera_menu_1"
  },
  [2] = {
    funcId = DEF.ModelAnimTags.LoopAction,
    icon = "ui/atlas/photograph/camera_menu_2"
  },
  [3] = {
    funcId = DEF.ModelAnimTags.Emote,
    icon = "ui/atlas/photograph/camera_menu_3"
  }
}
DEF.ShowPhotoMaxCount = 5
DEF.ProfileImageType = {
  Head = 1,
  HeadFrame = 2,
  Card = 3,
  Medal = 4,
  PersonalzoneBg = 5,
  Title = 6
}
DEF.ProfileImageUnlockType = {GetUnlock = 0, DefaultUnlock = 1}
DEF.ProfileImageFunctionId = {
  [DEF.ProfileImageType.Head] = E.FunctionID.PersonalzoneHead,
  [DEF.ProfileImageType.HeadFrame] = E.FunctionID.PersonalzoneHeadFrame,
  [DEF.ProfileImageType.Card] = E.FunctionID.PersonalzoneCard,
  [DEF.ProfileImageType.Medal] = E.FunctionID.PersonalzoneMedal,
  [DEF.ProfileImageType.Title] = E.FunctionID.PersonalzoneTitle
}
DEF.ProfileImageRedDot = {
  [DEF.ProfileImageType.Head] = E.RedType.PersonalzoneHead,
  [DEF.ProfileImageType.HeadFrame] = E.RedType.PersonalzoneHeadFrame,
  [DEF.ProfileImageType.Card] = E.RedType.PersonalzoneCard,
  [DEF.ProfileImageType.Medal] = E.RedType.PersonalzoneMedal,
  [DEF.ProfileImageType.Title] = E.RedType.PersonalzoneTitle
}
DEF.PersonalzoneMedalGridHeightCount = 5
DEF.PersonalzoneMedalGridWidthCount = 5
DEF.PersonalzoneMedal3DArea = {
  [1] = {
    [1] = 1.25,
    [2] = 1.25
  },
  [2] = {
    [1] = -1.25,
    [2] = -1.25
  }
}
DEF.PersonalzoneMedal3DGridSize = 0.5
DEF.PersonalzoneMedalType = {
  Season = 1,
  Career = 2,
  Leisure = 3
}
DEF.PersonalzoneMedalUnitSize = {
  [DEF.PersonalzoneMedalType.Season] = {
    [1] = 1,
    [2] = 1
  },
  [DEF.PersonalzoneMedalType.Career] = {
    [1] = 1,
    [2] = 2
  },
  [DEF.PersonalzoneMedalType.Leisure] = {
    [1] = 2,
    [2] = 2
  }
}
return DEF
