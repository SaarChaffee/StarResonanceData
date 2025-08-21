local DEF = {}
DEF.IdCardEditorType = {
  None = 0,
  Set = 1,
  Frame = 2,
  Badge = 3,
  Album = 4
}
DEF.UNSHOWTAGICON = "ui/atlas/label_icon/personalzone_labels_0"
DEF.PageIndexColor = {
  Select = Color.New(1, 1, 1, 1),
  UnSelect = Color.New(0, 0, 0, 0.3)
}
DEF.PageBtnColor = {
  CanTouch = Color.New(0, 0, 0, 1),
  CannotTouch = Color.New(0, 0, 0, 0.3)
}
DEF.OnlineTagColor = {
  [1] = Color.New(1, 1, 1, 1),
  [2] = Color.New(0.7803921568627451, 0.984313725490196, 1.0, 1)
}
DEF.UnLockIconColorState = {
  Unlock = Color.New(1, 1, 1, 1),
  Unlocked = Color.New(1, 1, 1, 0.7058823529411765)
}
DEF.PersonalTagType = {OnlineDayTime = 1, OnlineActivity = 2}
DEF.ModelAnimTags = {
  CommonAction = 1,
  LoopAction = 2,
  Emote = 3
}
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
  [DEF.ProfileImageType.PersonalzoneBg] = E.FunctionID.PersonalzoneBg,
  [DEF.ProfileImageType.Title] = E.FunctionID.PersonalzoneTitle
}
DEF.ProfileImageRedDot = {
  [DEF.ProfileImageType.Head] = E.RedType.PersonalzoneHead,
  [DEF.ProfileImageType.HeadFrame] = E.RedType.PersonalzoneHeadFrame,
  [DEF.ProfileImageType.Card] = E.RedType.PersonalzoneCard,
  [DEF.ProfileImageType.Medal] = E.RedType.PersonalzoneMedal,
  [DEF.ProfileImageType.PersonalzoneBg] = E.RedType.PersonalzoneBg,
  [DEF.ProfileImageType.Title] = E.RedType.PersonalzoneTitle
}
DEF.PersonalzoneMedalType = {
  Season = 1,
  Career = 2,
  Leisure = 3
}
return DEF
