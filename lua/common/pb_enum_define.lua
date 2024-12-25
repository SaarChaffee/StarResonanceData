E.GoalType = {
  AutoLuaTalk = Z.PbEnum("ETargetType", "TargetTalk"),
  NpcLuaTalk = Z.PbEnum("ETargetType", "TargetNpcTalk"),
  AutoPlayFlow = Z.PbEnum("ETargetType", "TargetAutoFlow"),
  NpcFlowTalk = Z.PbEnum("ETargetType", "TargetNpcFlow"),
  ClientAddNpc = Z.PbEnum("ETargetType", "TargetClientCreateNpc"),
  ClientRemoveNpc = Z.PbEnum("ETargetType", "TargetClientRemoveNpc"),
  ClientAddZone = Z.PbEnum("ETargetType", "TargetClientCreateZone"),
  ClientRemoveZone = Z.PbEnum("ETargetType", "TargetClientRemoveZone"),
  AutoPlayCutscene = Z.PbEnum("ETargetType", "TargetClientAutoCutScene"),
  ServerPlayCutscene = Z.PbEnum("ETargetType", "TargetAutoCutScene"),
  AutoOpenUI = Z.PbEnum("ETargetType", "TargetAutoOpenUi"),
  OpenInsight = Z.PbEnum("ETargetType", "TargetOpenInsight"),
  KillMonster = Z.PbEnum("ETargetType", "TargetKillMonster"),
  PlayerFollowNpc = Z.PbEnum("ETargetType", "TargetFollowNpc"),
  PlayerFollowNpcWalk = Z.PbEnum("ETargetType", "TargetFollowNpcWalk"),
  NpcFollowPlayer = Z.PbEnum("ETargetType", "TargetNpcFollowUser"),
  TakePhoto = Z.PbEnum("ETargetType", "TargetPhoto"),
  TargetEntityPhoto = Z.PbEnum("ETargetType", "TargetEntityPhoto"),
  SubmitItem = Z.PbEnum("ETargetType", "TargetClientSubmitItem"),
  ShowItem = Z.PbEnum("ETargetType", "TargetClientShowItem"),
  InMapArea = Z.PbEnum("ETargetType", "TargetInMapArea"),
  DoExpression = Z.PbEnum("ETargetType", "TargetDoExpression"),
  ChatChannel = Z.PbEnum("ETargetType", "TargetChatChannel"),
  UnionJoin = Z.PbEnum("ETargetType", "TargetUnionJoin"),
  CameraPatternType = Z.PbEnum("ETargetType", "TargetCameraPatternType"),
  HoverTime = Z.PbEnum("ETargetType", "TargetHoverTime"),
  FriendTotal = Z.PbEnum("ETargetType", "TargetFriendTotal"),
  FinishOperate = Z.PbEnum("ETargetType", "TargetFinishOperate"),
  EpisodeStart = Z.PbEnum("ETargetType", "TargetClientEpisodeStart"),
  TargetPhotoByTableId = Z.PbEnum("ETargetType", "TargetPhotoByTableId"),
  EpisodeEnd = Z.PbEnum("ETargetType", "TargetClientEpisodeEnd"),
  TargetTime = Z.PbEnum("ETargetType", "TargetTime")
}
E.QuestGoalGroupType = {
  None = Z.PbEnum("EQuestTargetType", "QuestTargetUnknown"),
  Single = Z.PbEnum("EQuestTargetType", "QuestTargetSingle"),
  Serial = Z.PbEnum("EQuestTargetType", "QuestTargetSerial"),
  All = Z.PbEnum("EQuestTargetType", "QuestTargetConcurrent"),
  ReachNum = Z.PbEnum("EQuestTargetType", "QuestTargetNum"),
  Optional = Z.PbEnum("EQuestTargetType", "QuestTargetSelect")
}
E.QuestState = {
  CanAccept = Z.PbEnum("EQuestStatusType", "QuestCanAccept"),
  InProgress = Z.PbEnum("EQuestStatusType", "QuestAccept"),
  Deliverable = Z.PbEnum("EQuestStatusType", "QuestFinish"),
  End = Z.PbEnum("EQuestStatusType", "QuestEnd"),
  NotEnough = Z.PbEnum("EQuestStatusType", "QuestNotEnough")
}
E.SceneSubType = {
  None = Z.PbEnum("ESceneSubType", "SceneSubTypeUnknown"),
  Login = Z.PbEnum("ESceneSubType", "SceneSubTypeLogin"),
  Select = Z.PbEnum("ESceneSubType", "SceneSubTypeSelect"),
  MainCity = Z.PbEnum("ESceneSubType", "SceneSubTypeStaticCity"),
  WildMap = Z.PbEnum("ESceneSubType", "SceneSubTypeStaticWildMap"),
  Dungeon = Z.PbEnum("ESceneSubType", "SceneSubTypeDungeon"),
  Mirror = Z.PbEnum("ESceneSubType", "SceneSubTypeMirror"),
  Community = Z.PbEnum("ESceneSubType", "SceneSubTypeCommunity"),
  Homeland = Z.PbEnum("ESceneSubType", "SceneSubTypeHomeland"),
  Union = Z.PbEnum("ESceneSubType", "SceneSubTypeUnion")
}
E.DungeonEventResult = {
  Null = Z.PbEnum("DungeonEventResult", "DungeonEventResultNull"),
  Success = Z.PbEnum("DungeonEventResult", "DungeonEventResultSuccess"),
  TimeOut = Z.PbEnum("DungeonEventResult", "DungeonEventResultTimeOut"),
  Failed = Z.PbEnum("DungeonEventResult", "DungeonEventResultFailed"),
  End = Z.PbEnum("DungeonEventResult", "DungeonEventResultEnd"),
  NotPerfectnd = Z.PbEnum("DungeonEventResult", "DungeonEventResultNotPerfect")
}
E.DungeonEventState = {
  Null = Z.PbEnum("DungeonEventState", "DungeonEventStateNull"),
  Running = Z.PbEnum("DungeonEventState", "DungeonEventStateRunning"),
  End = Z.PbEnum("DungeonEventState", "DungeonEventStateEnd")
}
E.PictureReviewType = {
  Null = Z.PbEnum("EPictureReviewType", "EPictureReviewNull"),
  Fail = Z.PbEnum("EPictureReviewType", "EPictureReviewFail"),
  Success = Z.PbEnum("EPictureReviewType", "EPictureReviewed"),
  Reviewing = Z.PbEnum("EPictureReviewType", "EPictureReviewing")
}
E.PlatformFuncType = {
  Default = Z.PbEnum("EPlatformFuncType", "EFuncTypeDefault"),
  HeadProfile = Z.PbEnum("EPlatformFuncType", "EHeadProfile"),
  Photograph = Z.PbEnum("EPlatformFuncType", "EPhotograph"),
  UnionPhoto = Z.PbEnum("EPlatformFuncType", "EUnionPhoto")
}
E.MatchType = {
  Null = 0,
  Team = 1,
  WorldBoss = 2
}
E.RedayType = {
  Wait = 0,
  Ready = 1,
  UnReady = 2
}
E.MatchCancelType = {
  Null = 0,
  Request = 1,
  TimeOut = 2,
  UnReady = 3
}
E.MatchSatatusType = {
  Null = 0,
  MatchIng = 1,
  WaitReady = 2,
  AllReady = 3,
  ReadyEnd = 4
}
E.ReceiveRewardStatus = {
  NotReceive = 0,
  CanReceive = 1,
  Received = 2
}
E.ItemExtendType = {
  None = 0,
  Rank = 1,
  BossValue = 2
}
E.UnionBuildEffectDef = {
  None = Z.PbEnum("PurviewType", "PurviewTypeDefault"),
  AddMenSumNum = Z.PbEnum("PurviewType", "PurviewTypeAddMenSumNum"),
  GridSumNum = Z.PbEnum("PurviewType", "PurviewTypeEffectGridSumNum"),
  UnlockEffectId = Z.PbEnum("PurviewType", "PurviewTypeUnlockEffectId"),
  UnlockKitchen = Z.PbEnum("PurviewType", "PurviewTypeUnlockKitchen"),
  UnlockPVE = Z.PbEnum("PurviewType", "PurviewTypeUnlockPVE"),
  UnlockResetArea = Z.PbEnum("PurviewType", "PurviewTypeUnlockResetArea"),
  UnlockAutoSeller = Z.PbEnum("PurviewType", "PurviewTypeUnlockAutoSeller"),
  UnlockEScreen = Z.PbEnum("PurviewType", "PurviewTypeUnlockEScreen"),
  UnlockUnionScene = Z.PbEnum("PurviewType", "PurviewTypeUnlockUnionScene"),
  UnlockUnionScreen = Z.PbEnum("PurviewType", "PurviewTypeUnlockEScreenPhotoNum"),
  UnlockUnionAlbum = Z.PbEnum("PurviewType", "PurviewTypeAddPhotoNum")
}
E.UnionMemberNotifyType = {
  None = Z.PbEnum("EnumUnionNotifyType", "UnionNotifyDefault"),
  Join = Z.PbEnum("EnumUnionNotifyType", "UnionNotifyJoin"),
  Leave = Z.PbEnum("EnumUnionNotifyType", "UnionNotifyLeave"),
  PositionChange = Z.PbEnum("EnumUnionNotifyType", "UnionNotifyMemUpdate")
}
E.TextCheckSceneType = {
  TextCheckError = Z.PbEnum("TextCheckSceneType", "TextCheckError"),
  TextCheckAlbumPhotoEditText = Z.PbEnum("TextCheckSceneType", "TextCheckAlbumPhotoEditText"),
  TextCheckTeamTargetInfo = Z.PbEnum("TextCheckSceneType", "TextCheckTeamTargetInfo")
}
