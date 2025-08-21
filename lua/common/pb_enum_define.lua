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
  TargetTime = Z.PbEnum("ETargetType", "TargetTime"),
  TargetMultiPlayerPhoto = Z.PbEnum("ETargetType", "TargetMultiPlayerPhoto"),
  TargetShortcutKeySetting = Z.PbEnum("ETargetType", "TargetShortcutKeySetting")
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
  Activity = 2
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
  TextCheckTeamTargetInfo = Z.PbEnum("TextCheckSceneType", "TextCheckTeamTargetInfo"),
  TextCheckTeamTargetQuickSay = Z.PbEnum("TextCheckSceneType", "TextCheckTeamTargetQuickSay"),
  TextCheckCommunityCheckInvite = Z.PbEnum("TextCheckSceneType", "TextCheckCommunityCheckInvite")
}
E.TeamVoteRet = {
  None = Z.PbEnum("ETeamVoteRet", "ETeamVoteRetNull"),
  Agree = Z.PbEnum("ETeamVoteRet", "ETeamVoteRetAgree"),
  Refuse = Z.PbEnum("ETeamVoteRet", "ETeamVoteRetRefuse"),
  Cancel = Z.PbEnum("ETeamVoteRet", "ETeamVoteRetCancel"),
  TimeOut = Z.PbEnum("ETeamVoteRet", "ETeamVoteRetTimeOut")
}
E.ETeamMemberType = {
  Five = Z.PbEnum("ETeamMemberType", "ETeamMemberTypeFive"),
  Twenty = Z.PbEnum("ETeamMemberType", "ETeamMemberTypeTwenty")
}
E.ShowItemType = {
  None = Z.PbEnum("EShowItemType", "EShowItemTypeNull"),
  RewardTips = Z.PbEnum("EShowItemType", "EShowItemTypeCommon"),
  MonthCardTips = Z.PbEnum("EShowItemType", "EShowItemTypeMonthlyCard"),
  ItemTips = Z.PbEnum("EShowItemType", "EShowItemTypeTips")
}
E.TempAttrEffectType = {
  TempAttrLifeProfessionWorkCost = Z.PbEnum("ETempAttrEffectType", "TempAttrLifeProfessionWorkCost"),
  TempAttrLifeProfessionWorkCostRate = Z.PbEnum("ETempAttrEffectType", "TempAttrLifeProfessionWorkCostRate"),
  TempAttrLifeProfessionWorkTime = Z.PbEnum("ETempAttrEffectType", "TempAttrLifeProfessionWorkTime"),
  TempAttrHeroDungeonMultiaAward = Z.PbEnum("ETempAttrEffectType", "TempAttrHeroDungeonMultiaAward"),
  TempAttrInteractionTimeRate = Z.PbEnum("ETempAttrEffectType", "TempAttrInteractionTimeRate"),
  TempAttrInteractionTime = Z.PbEnum("ETempAttrEffectType", "TempAttrInteractionTime")
}
E.ETempAttrType = {
  TempAttrGlobal = Z.PbEnum("ETempAttrType", "TempAttrGlobal"),
  TempAttrLifeProfession = Z.PbEnum("ETempAttrType", "TempAttrLifeProfession")
}
E.TimerType = {
  Null = Z.PbEnum("ETimerType", "TimerTypeNull"),
  FixedTime = Z.PbEnum("ETimerType", "TimerType_Point"),
  Daily = Z.PbEnum("ETimerType", "TimerType_Day"),
  Monthly = Z.PbEnum("ETimerType", "TimerType_Month"),
  Weekly = Z.PbEnum("ETimerType", "TimerType_Week"),
  Interval = Z.PbEnum("ETimerType", "TimerType_Interval")
}
E.TimerExeType = {
  Null = Z.PbEnum("ETimerExeType", "TimerExeTypeNull"),
  Start = Z.PbEnum("ETimerExeType", "TimerExeType_Start"),
  End = Z.PbEnum("ETimerExeType", "TimerExeType_End"),
  CycleStart = Z.PbEnum("ETimerExeType", "TimerExeType_Cycle_Start"),
  CycleEnd = Z.PbEnum("ETimerExeType", "TimerExeType_Cycle_End")
}
E.PrivilegeSourceType = {
  Null = Z.PbEnum("EPrivilegeEffectSourceType", "EPrivilegeEffectSourceTypeNone"),
  BattlePass = Z.PbEnum("EPrivilegeEffectSourceType", "EPrivilegeEffectSourceTypeBattlePass"),
  LaunchPrivilege = Z.PbEnum("EPrivilegeEffectSourceType", "EPrivilegeEffectSourceTypeLaunchPrivilege")
}
E.PrivilegeEffectType = {
  Null = Z.PbEnum("EPrivilegeEffectType", "EPrivilegeEffectTypeNone"),
  Item = Z.PbEnum("EPrivilegeEffectType", "EPrivilegeEffectTypeItemDropBonus"),
  DailyActivityBonus = Z.PbEnum("EPrivilegeEffectType", "EPrivilegeEffectTypeDailyActivityBonus"),
  BattlePassLv = Z.PbEnum("EPrivilegeEffectType", "EPrivilegeEffectTypeBattlePassLevAdd"),
  ShopRefreshTimesBonus = Z.PbEnum("EPrivilegeEffectType", "EPrivilegeEffectTypeShopRefreshTimesBonus")
}
E.HousePlayerLimitType = {
  FurnitureEdit = Z.PbEnum("ECommunityPlayerAuthorityType", "CommunityAuthorityPlayerTypeFurnitureEdit"),
  FurnitureMake = Z.PbEnum("ECommunityPlayerAuthorityType", "CommunityAuthorityPlayerTypeFurnitureMake"),
  Production = Z.PbEnum("ECommunityPlayerAuthorityType", "CommunityAuthorityPlayerTypeProduction"),
  Plant = Z.PbEnum("ECommunityPlayerAuthorityType", "CommunityAuthorityPlayerTypePlant"),
  WareHouse = Z.PbEnum("ECommunityPlayerAuthorityType", "CommunityAuthorityPlayerTypeWareHouse")
}
E.HouseLimitType = {
  WareHouse = Z.PbEnum("ECommunityAuthorityType", "CommunityAuthorityTypeWareHouse")
}
E.HouseBoardType = {
  Transfer = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinBoardTransfer"),
  TransferAgree = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinBoardTransferAgree"),
  TransferCancel = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinBoardTransferCancel"),
  TransferRefusal = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinBoardTransferRefusal"),
  CohabitantJoin = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinCohabitantJoin"),
  CohabitantExit = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinCohabitantExit"),
  Authority = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinAuthority"),
  PlayerAuthority = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinPlayerAuthority"),
  Create = Z.PbEnum("ECommunityBulletinBoardType", "CommunityBulletinCreate")
}
E.BuildFurnitureState = {
  BuildFurnitureStateNone = Z.PbEnum("EBuildFurnitureState", "BuildFurnitureStateNone"),
  BuildFurnitureStateBuilding = Z.PbEnum("EBuildFurnitureState", "BuildFurnitureStateBuilding"),
  BuildFurnitureStateSuccess = Z.PbEnum("EBuildFurnitureState", "BuildFurnitureStateSuccess")
}
E.VisualLayerType = {
  VisualLayerTypePublic = Z.PbEnum("VisualLayerType", "VisualLayerTypePublic"),
  VisualLayerTypeMultiPlayer = Z.PbEnum("VisualLayerType", "VisualLayerTypeMultiPlayer"),
  VisualLayerTypePrivate = Z.PbEnum("VisualLayerType", "VisualLayerTypePrivate"),
  VisualLayerTypeMultiPlayerUuid = Z.PbEnum("VisualLayerType", "VisualLayerTypeMultiPlayerUuid"),
  VisualLayerTypeCommunityOutdoor = Z.PbEnum("VisualLayerType", "VisualLayerTypeCommunityOutdoor"),
  VisualLayerTypeCommunityIndoor = Z.PbEnum("VisualLayerType", "VisualLayerTypeCommunityIndoor")
}
E.HousingItemGroupType = {
  HousingItemGroupTypeNone = Z.PbEnum("EEnumStructureType", "EnumStructureTypeNone"),
  HousingItemGroupTypeLampLight = Z.PbEnum("EEnumStructureType", "EnumStructureTypeLamplight"),
  HousingItemGroupTypeFarmland = Z.PbEnum("EEnumStructureType", "EnumStructureTypeFarmland"),
  HousingItemGroupTypeDecoration = Z.PbEnum("EEnumStructureType", "EnumStructureTypeDecoration"),
  HousingItemGroupTypePartitionWall = Z.PbEnum("EEnumStructureType", "EnumStructureTypePartitionWall"),
  HousingItemGroupTypePartitionWallMat = Z.PbEnum("EEnumStructureType", "EnumStructureTypePartitionWallMat")
}
E.HomelandLamplightState = {
  HomelandLamplightStateDefault = Z.PbEnum("EHomelandLamplightState", "HomelandLamplightStateDefault"),
  HomelandLamplightStateOff = Z.PbEnum("EHomelandLamplightState", "HomelandLamplightStateOff"),
  HomelandLamplightStateOn = Z.PbEnum("EHomelandLamplightState", "HomelandLamplightStateOn")
}
E.HomeEFarmlandState = {
  EFarmlandStateEmpty = Z.PbEnum("EFarmlandState", "EFarmlandStateEmpty"),
  EFarmlandStateGrow = Z.PbEnum("EFarmlandState", "EFarmlandStateGrow"),
  EFarmlandStatePollen = Z.PbEnum("EFarmlandState", "EFarmlandStatePollen"),
  EFarmlandStateHarvest = Z.PbEnum("EFarmlandState", "EFarmlandStateHarvest"),
  EFarmlandStateOver = Z.PbEnum("EFarmlandState", "EFarmlandStateOver")
}
E.HomeStructureOpType = {
  StructureOpTypeAdd = Z.PbEnum("StructureOpType", "StructureOpTypeAdd"),
  StructureOpTypeUpdate = Z.PbEnum("StructureOpType", "StructureOpTypeUpdate"),
  StructureOpTypeDelete = Z.PbEnum("StructureOpType", "StructureOpTypeDelete")
}
E.FightPointFunctionType = {
  FightPointFunctionType_RoleBasic = Z.PbEnum("FightPointFunctionType", "FightPointFunctionType_RoleBasic"),
  FightPointFunctionType_Equip = Z.PbEnum("FightPointFunctionType", "FightPointFunctionType_Equip"),
  FightPointFunctionType_Mod = Z.PbEnum("FightPointFunctionType", "FightPointFunctionType_Mod"),
  FightPointFunctionType_Skill = Z.PbEnum("FightPointFunctionType", "FightPointFunctionType_Skill"),
  FightPointFunctionType_Medal = Z.PbEnum("FightPointFunctionType", "FightPointFunctionType_Medal"),
  FightPointFunctionType_Talent = Z.PbEnum("FightPointFunctionType", "FightPointFunctionType_Talent")
}
E.EDamageSourceSkill = {
  EDamageSourceSkill = Z.PbEnum("EDamageSource", "EDamageSourceSkill"),
  EDamageSourceBullet = Z.PbEnum("EDamageSource", "EDamageSourceBullet"),
  EDamageSourceBuff = Z.PbEnum("EDamageSource", "EDamageSourceBuff")
}
E.EDamageType = {
  Normal = Z.PbEnum("EDamageType", "Normal"),
  Miss = Z.PbEnum("EDamageType", "Miss"),
  Heal = Z.PbEnum("EDamageType", "Heal"),
  Immune = Z.PbEnum("EDamageType", "Immune"),
  Fall = Z.PbEnum("EDamageType", "Fall"),
  Absorbed = Z.PbEnum("EDamageType", "Absorbed")
}
