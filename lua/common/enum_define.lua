E = {}
E.RpcChannelType = {Gateway = 0, World = 1}
E.LocalUserDataType = {
  Device = 0,
  Env = 1,
  Account = 2,
  Character = 3
}
E.GameEnvironment = {
  Product = 0,
  Preview = 1,
  Test = 2
}
E.LevelTableType = {
  Npc = 1,
  Zone = 2,
  Monster = 3,
  Point = 4,
  SceneObject = 5
}
E.DlgType = {
  OK = "OK",
  YesNo = "YesNo",
  CountdownYes = "CountdownYes",
  CountdownNo = "CountdownNo"
}
E.QuitGameNoticeType = {
  Unknown = 0,
  AntiCheat = 1,
  WegameOffline = 2
}
E.DlgPreferencesType = {
  None = 1,
  Never = 2,
  Login = 3,
  Time = 4,
  Day = 5
}
E.DlgPreferencesKeyType = {
  SameModExchangeSlot = "SameModExchangeSlot",
  ReplaceSameModSimilarId = "ReplaceSameModSimilarId",
  ModDecomposeCertain = "ModDecomposeCertain",
  ModIntensifyNotEquip = "ModIntensifyNotEquip",
  ModIntensifyMaxSuccessTimes = "ModIntensifyMaxSuccessTimes",
  ModEquipBindFlag = "ModEquipBindFlag",
  ModIntensifyBindFlag = "ModIntensifyBindFlag",
  Equip_Decompose_Prompt = "Equip_Decompose_Prompt",
  SetSeverFaceData = "SetSeverFaceData",
  UnlockFaceStyle = "UnlockFaceStyle",
  FaceRandomPrompt = "FaceRandomPrompt",
  ConfirmRevertFaceData = "ConfirmRevertFaceData",
  UnlockFashionColorWithCost = "UnlockFashionColorWithCost",
  UnlockFashionColor = "UnlockFashionColor",
  UnSaveFashionColor = "UnSaveFashionColor",
  SeasonActivationRefer = "SeasonActivationRefer",
  SettingDefinitionFrameConfirm = "SettingDefinitionFrameConfirm",
  ResonancePower_Decompose_Prompt = "ResonancePower_Decompose_Prompt",
  WorldBossMatch = "WorldBossMatch",
  GashaEnsureTipsShowKey = "GashaEnsureTipsShowKey",
  EquipPutOnNoBindFlag = "EquipPutOnNoBindFlag",
  EquipBreakDownExclusiveEquipTips = "EquipBreakDownExclusiveEquipTips",
  EquipDecomposeHighQualityTips = "EquipDecomposeHighQualityTips",
  EquipBreakDownRareEquipTips = "EquipBreakDownRareEquipTips",
  EquipEquipDecomposeTips = "EquipEquipDecomposeTips",
  EquipRecastCanTradeTips = "EquipRecastCanTradeTips",
  EquipRecastingManytimesTips = "EquipRecastingManytimesTips",
  EquipRecastingManyTimesTips = "EquipRecastingManyTimesTips",
  EquipRecastingHighPerfectTips = "EquipRecastingHighPerfectTips",
  EquipRecastingBindingTips = "EquipRecastingBindingTips",
  EquipRecastMaxPerfect = "EquipRecastMaxPerfect",
  EquipEnchantBindingTips = "EquipEnchantBindingTips",
  StallPublicityDialogTips = "StallPublicityDialogTips",
  StallNormalDialogTips = "StallNormalDialogTips",
  ItemRecycleTips = "ItemRecycleTips",
  EquipChangeEnchantItem = "EquipChangeEnchantItem",
  FashionAdvancedColorTips = "FashionAdvancedColorTips",
  ExchangeShopExchangeNoCurProfession = "ExchangeShopExchangeNoCurProfession",
  GashaUseBinding = "gashaUseBinding",
  MailDeleteConfirmTips = "MailDeleteConfirmTips",
  MatchLeaderConfirmTips = "MatchLeaderConfirmTips",
  PersonalzoneSecondCheck = "PersonalzoneSecondCheck",
  ResonanceItemDecompose1 = "ResonanceItemDecompose1",
  ResonanceItemDecompose2 = "ResonanceItemDecompose2",
  MailGetTips = "MailGetTips",
  MailDeleteTips = "MailDeleteTips",
  SettingDeviceChange = "SettingDeviceChange"
}
E.PlayerBattleResType = {
  TdlPurpleRes = 12041,
  TdlBuleRes = 12061,
  TdlMPValue = 11001,
  TdlMPMax = 11007,
  FzMPValue = 12001,
  FzMPMax = 12007,
  FzColdValue = 12021,
  FzColdMax = 12027,
  SfMPValue = 13001,
  SfMPMax = 13007,
  SfRankLevel = 13021,
  SfRankLevelMax = 13027
}
E.ProfessionResType = {ProfessionResValueTest = 20001, ProfessionResMaxTest = 20007}
E.ProfessionResEffType = {
  Full = 1,
  Decline = 2,
  Empty = 3
}
E.MapMode = {World = 0, Area = 1}
E.MapFlagTypeId = {
  TransferDoor = 103,
  CustomTag1 = 301,
  CustomTag2 = 302,
  PositionShare = 303
}
E.SceneTagType = {
  SceneEnter = 2,
  Custom = 3,
  Dungeon = 4
}
E.SceneTagGroupId = {
  Shop = 1,
  Make = 2,
  Cook = 3,
  Custom = 10
}
E.ShowProportionType = {
  Low = 1,
  Middle = 2,
  High = 3
}
E.ViewFocusType = {focusDir = 1, focusPlayer = 2}
E.PlayerCtrlBtnTmpType = {
  Null = 0,
  Default = 1,
  Climb = 2,
  FlowGlide = 4,
  MulAction = 8,
  Swim = 16,
  Interactive = 32,
  ClimbRun = 64,
  ClimbDash = 128,
  Vehicles = 256,
  VehiclePassenger = 267,
  TunnelFly = 268
}
E.PlayerCtrlBtnPCShowBtnType = {
  Default = 1,
  Less = 2,
  Vehicles = 3
}
E.ItemBtnState = {
  Active = 1,
  Hide = 2,
  UnActive = 3,
  IsDisabled = 4
}
E.AwardPreLimitType = {SexLimit = 1}
E.AwardPreType = {
  Common = 1,
  Dungeon = 2,
  DungeonFirst = 3
}
E.LevelEventType = {
  TriggerEvent = 1,
  OnZoneEnterClient = 2,
  OnZoneExitClient = 3,
  OnSceneInit = 4,
  OnFlowPlayEnd = 7,
  OnOptionSelect = 8,
  OnCutsceneEnd = 9,
  CustomEventEndFlag = 10,
  OnSceneLeave = 11,
  OnVisualLayerEnter = 12,
  OnVisualLayerLeave = 13,
  OnUIOpen = 14,
  OnUIClose = 15,
  OnPlayerStateEnter = 16,
  OnPlayerStateLeave = 17,
  OnWorldQuestRefresh = 18
}
E.ColorHexValues = {
  InvestigateUnlockClue = "#DA9B8F",
  Yellow = "#FDC359",
  White = "#FFFFFF",
  Gray = "#808080",
  TipsGreen = "#CEE98D",
  JobActive = "#AFE716",
  JobNotActive = "#A2A2A2",
  DarkBrown = "#774E4A",
  DarkGreen = "#4C774A",
  DarkPruple = "#675397",
  DarkBlue = "#1B8BA5"
}
E.FashionCustomsizedLineColor = {
  Green = "#A1F2DF",
  Blue = "#9BC8FF",
  Pruple = "#E5B3FF",
  Yellow = "#FCE14A",
  Red = "#FFA391"
}
E.ItemQuality = {
  White = 0,
  Green = 1,
  Blue = 2,
  Purple = 3,
  Yellow = 4,
  Red = 5
}
E.ItemSpecialDisplayType = {
  Mod = 1,
  Talent = 2,
  ResonanceSkill = 3,
  FashionAndVehicle = 4,
  WeaponSkin = 5,
  HeadPortrait = 6,
  HeadFrame = 7,
  IdCard = 8,
  Badges = 9,
  ZoneBackground = 10,
  Title = 11,
  HouseCertificate = 12
}
E.TextStyleTag = {
  TipsTitle = "tipsTitle",
  TipsTitleMain = "tipsTitleMain",
  TipsGreen = "tipsGreen",
  TipsViolet = "tipsViolet",
  TipsYellow = "tipsYellow",
  TipsRed = "tipsRed",
  Black = "black",
  Second = "text_secondary",
  SecondGray = "text_secondary_gray",
  Third = "text_third",
  ThirdGray = "text_third_gray",
  HighLight = "text_highlight_greenyellow",
  AccentGreen = "accent-gn",
  AccentRed = "accent-red",
  JobActive = "job_active_green",
  JobNotActive = "job_not_active_gray",
  EmphRb = "emph-rb",
  InvestigateLockClue = "investigate_lock_clue",
  White = "White",
  NumModuleNormal = "numModuleNormal",
  Lab_num_white = "lab_num_white",
  Lab_number_white = "lab_number_white",
  Lab_num_black = "lab_num_black",
  Lab_number_black = "lab_number_black",
  Lab_num_red = "lab_num_red",
  Talk_option_yellow = "talk_option_yellow",
  Text_finish = "text_finish",
  Text_not_finish = "text_not_finish",
  ChannelWorld = "ChannelWorld",
  ChannelCurrent = "ChannelCurrent",
  ChannelTeam = "ChannelTeam",
  ChannelGuild = "ChannelGuild",
  ChannelSystem = "ChannelSystem",
  ChannelFriend = "ChannelFriend",
  ChannelPrivate = "ChannelPrivate",
  ChannelFriendPC = "ChannelFriendPC",
  ItemNotEnough = "item_not_enought",
  AttrUp = "attr_up",
  GrayTextColor = "GrayTextColor",
  GreenTextColor = "GreenTextColor",
  GreenTextColor2 = "GreenTextColor2",
  ChannelSetting = "ChannelSetting",
  Text_secondary = "text_secondary",
  ChannelMidLitMit = "ChannelMidLitMit",
  ChannelLowLitMit = "ChannelLowLitMit",
  Red = "Red",
  PureBlack = "PureBlack",
  FaceGray = "FaceGray",
  Gray = "Gray",
  LightYellow = "LightYellow",
  DmgYellow = "DmgYellow",
  DmgGray = "DmgGray",
  PlayerName = "player_name",
  RollNum = "roll_num",
  PreBuySuccess = "pre_buy_success",
  PreBuyFail = "pre_buy_fail",
  Orange = "orange",
  UnionResloveGreen = "union_reslove_greeen",
  UnionUnlockYellow = "union_unlock_yellow",
  SkillNum = "skill_num",
  SkillNumChange = "skill_num_change",
  SkillUnlock = "skill_unlock",
  MapTextFinish = "map_text_finish",
  RoloLabAttr = "role_lab_attr",
  UnionDeviceNormal = "UnionDeviceNormal",
  UnionDeviceLock = "UnionDeviceLock",
  RoleLevelLabUp = "RoleLevelLabUp",
  FashionCostRedTips = "FashionCostRedTips",
  ConditionMet = "condition_met",
  ConditionNotMet = "condition_not_met"
}
E.EquipPart = {
  Weapon = 200,
  Helmet = 201,
  Clothes = 202,
  Handguards = 203,
  Shoe = 204,
  Earring = 205,
  Necklace = 206,
  Ring = 207,
  LeftBracelet = 208,
  RightBracelet = 209,
  Amulet = 210
}
E.EquipRareQuality = {Purple = 301, Orange = 401}
E.EquipRareQualityColor = {
  [E.EquipRareQuality.Purple] = "#b08aff",
  [E.EquipRareQuality.Orange] = "#efda49"
}
E.WeaponPos = {Left = 1, Right = 2}
E.WeaponId = {
  tdl = 1,
  fz = 2,
  sf = 3
}
E.BuffId = {SceneLayerEnergy = 803201, SceneLayerSwitchCd = 803101}
E.ExpressionType = {
  None = 0,
  Action = 1,
  Emote = 2,
  MultAction = 3
}
E.DisplayExpressionType = {
  History = 0,
  CommonAction = 1,
  LoopAction = 2,
  MultAction = 3,
  Emote = 4,
  FishingAction = 5
}
E.ExpressionState = {
  UnActive = 0,
  Active = 1,
  CanActive = 2
}
E.ExpressionCommonTipsState = {Add = 1, Remove = 2}
E.ExpressionOpenSourceType = {
  Camera = 1,
  Expression = 2,
  PersonalZone = 3
}
E.CamerasysTopType = {
  None = 0,
  Action = 1,
  Decorate = 2,
  Setting = 3
}
E.CamerasysFuncType = {
  None = 0,
  CommonAction = 1,
  LoopAction = 2,
  Emote = 3,
  Frame = 4,
  Sticker = 5,
  Text = 6,
  Shotset = 7,
  Filter = 8,
  Moviescreen = 9,
  Show = 10,
  Scheme = 11,
  LookAt = 13,
  UnionBg = 14,
  Fishing = 15
}
E.CamerasysFuncIdType = {
  Action = 102018,
  Emote = 102019,
  Frame = 102014,
  Sticker = 102015,
  Text = 102016,
  Moviescreen = 102005,
  Filter = 102009,
  Shotset = 102010,
  Show = 102011,
  Scheme = 102012,
  QRCode = 102020
}
E.PhotoDecorationsType = {
  None = 0,
  Sticker = 1,
  Frame = 2,
  Filter = 3,
  Color = 4,
  UnionHeadBg = 5,
  UnionIdCardBg = 6
}
E.AlbumSelectType = {Normal = 0, Select = 1}
E.DecorateLayerType = {CamerasysType = 0, AlbumType = 1}
E.CameraStickType = {Small = 1, Middle = 2}
E.AlbumJurisdictionType = {
  All = 0,
  Friend = 1,
  Self = 2,
  Union = 3
}
E.AlbumOperationType = {
  None = -1,
  UpLoad = 0,
  Move = 1,
  UnionMove = 2
}
E.CameraSystemShowEntityType = {
  None = 0,
  Oneself = 1,
  Chum = 2,
  Team = 3,
  Union = 4,
  Community = 5,
  Stranger = 6,
  FriendlyNPCS = 7,
  AngelWeapons = 8,
  Enemy = 9,
  WeaponsAppearance = 10,
  OtherPlayer = 11,
  Collection = 12,
  CameraTeamMember = 13
}
E.CamerasysShowUIType = {None = 0, Name = 1}
E.CamerasysContrShowType = {Entity = 0, UI = 1}
E.CameraTextViewType = {Create = 0, Revise = 1}
E.CameraFrameType = {
  None = 0,
  Normal = 1,
  FillBlack = 2
}
E.CountDownEffectType = {
  Ring = 1,
  Horizontal = 2,
  Vertical = 3
}
E.DurationActionType = {
  Prepose = 1,
  Middle = 2,
  Post = 3
}
E.FaceDataState = {Create = 1, Edit = 2}
E.FaceFirstTab = {
  Body = 1,
  Hair = 2,
  Face = 3,
  Makeup = 4,
  HotPhoto = 5
}
E.FaceAttrUpdateMode = {
  ConfigTableRes = 1,
  OriginValue = 2,
  PinchHeadData = 3,
  RGBVector = 4,
  RGBVectorZList = 5,
  HairGradualData = 6,
  HairColorZList = 7,
  FaceHandleData = 8,
  PupilVector = 9,
  TwoConfigTabRes = 10
}
E.FashionRegion = {
  Suit = 701,
  UpperClothes = 702,
  Pants = 703,
  Gloves = 711,
  Shoes = 712,
  Headwear = 713,
  FaceMask = 714,
  MouthMask = 715,
  Tail = 716,
  Back = 717,
  Earrings = 721,
  Necklace = 722,
  Ring = 723,
  WeapoonSkin = 731
}
E.FashionResType = {
  Clothes = 0,
  Gloves = 1,
  Pants = 2,
  Shoes = 3,
  Ring = 4,
  Neck = 5,
  Socks = 6,
  UnderWear = 7,
  Suit = 8,
  HalfSuit = 9,
  HeadWear = 10,
  FaceWear = 11,
  MouthWear = 12,
  Earrings = 13,
  Tail = 14,
  Back = 15
}
E.FashionPrivilegeType = {
  ExchangeShop = 1,
  ExclusiveShop = 2,
  MoonGift = 3
}
E.FashionTipsReason = {
  UnlockedWear = 1,
  UnlockedColor = 2,
  UnlockedWeaponSkin = 3,
  UnlockedFashionAdvanced = 4
}
E.EquipItemSortType = {
  Quality = 1,
  GS = 2,
  Lv = 3,
  QualityConfig = 4,
  QualityAndGS = 5,
  Season = 6
}
E.ResonanceItemSortType = {Quality = 1}
E.RecycleItemSortType = {Quality = 1, Count = 2}
E.EquipFuncViewType = {
  Weapon = 0,
  Equip = 1,
  Decompose = 2,
  Recast = 3,
  Enchant = 4
}
E.SpecialItem = {RefineEnergy = 1030001}
E.ItemChangeType = {
  Add = 1,
  Delete = 2,
  Change = 3,
  Insert = 4,
  Reduce = 5,
  AllChange = 6
}
E.ItemAddEventType = {
  ItemId = 10,
  ItemType = 11,
  ItemPackage = 12
}
E.EItemTipsPopType = {
  Parent = 1,
  Bounds = 2,
  WorldPosition = 3,
  ScreenPosition = 4
}
E.EItemTipsShowType = {Default = 1, OnlyClient = 2}
E.TipsItemFuncType = {
  Nomal = 0,
  Unlock = 1,
  Look = 2
}
E.TeamTargetId = {All = 999, Costume = 1000}
E.DialogueType = {Default = 0, Quest = 1}
E.CutsceneQteType = {
  ClickOnce = 1,
  ClickMulti = 2,
  Slide = 3,
  LongPress = 4
}
E.CutsceneSkipType = {
  Allow = 0,
  FirstNotAllow = 1,
  NotAllow = 2
}
E.SceneTagId = {
  PlayerPos = 101,
  Quest = 201,
  DynamicTrace = 202,
  UnionEnter = 710
}
E.GoalGuideSource = {
  Default = 0,
  Quest = 1,
  Dungeon = 2,
  CustomMapFlag = 3,
  DungeonEntrance = 4,
  Activity = 5,
  MapFlag = 6,
  MonsterExplore = 7,
  GetItem = 8,
  Env = 9,
  CanAcceptSideQuest = 10,
  CanAcceptAreaQuest = 11,
  CanAcceptGuideQuest = 12,
  CanAcceptEventQuest = 13,
  PositionShare = 14
}
E.GoalParam = {
  Type = 1,
  Num = 2,
  SceneLimit = 3,
  Check = 4
}
E.GoalUIType = {
  TrackBar = 1,
  DetailPanel = 2,
  MapPanel = 3
}
E.QuestMgrStage = {
  UnInitEnd = 1,
  LoadEnd = 2,
  InitEnd = 3,
  BeginUnInit = 4
}
E.QuestType = {
  Main = 1,
  Side = 2,
  Area = 3,
  Guide = 4,
  Event = 5,
  WorldQuest = 16
}
E.QuestTypeGroup = {WorldEvent = 8}
E.QuestTrackViewState = {
  Detail = 1,
  StepChange = 2,
  TrackingChange = 3,
  Finish = 4,
  Fail = 5,
  Accept = 6,
  StateChange = 7
}
E.SocialType = {
  Chat = 1,
  Friends = 2,
  Mail = 3
}
E.ChatSettingTagType = {
  Show = 1,
  Voice = 2,
  Barrage = 3,
  Filter = 4
}
E.ChatSetTab = {
  ChannelShow = 1,
  Bullet = 2,
  Voice = 3,
  MsgFilter = 4
}
E.ChatChannelType = {
  EChannelNull = 0,
  EChannelWorld = 1,
  EChannelScene = 2,
  EChannelTeam = 3,
  EChannelUnion = 4,
  EChannelPrivate = 5,
  EChannelGroup = 6,
  EChannelTopNotice = 7,
  ESystem = 99,
  EComprehensive = 100,
  EMain = 101
}
E.ChatWindow = {Main = 1, Mini = 2}
E.Language = {
  SimplifiedChinese = 0,
  English = 1,
  Japanese = 2,
  Korean = 3
}
E.ChatEmojiTabType = {
  History = 1,
  Standard = 1,
  PixelEmoji = 2,
  BigPictureEmoji = 3
}
E.FriendGroupType = {
  None = 0,
  All = 1,
  Shield = 99
}
E.BulletSpeed = {
  low = 1,
  mid = 2,
  high = 3
}
E.BackPackItemPackageType = {
  Currency = 100,
  Item = 1,
  Equip = 2,
  Mod = 5,
  ResonanceSkill = 6,
  Fashion = 7,
  Weapon = 8,
  Personalzone = 9,
  UnionResource = 10,
  HouseItem = 11,
  Ride = 12,
  HouseCurrency = 13,
  SpecialItem = 102,
  CookFoodType = 109,
  RecycleItem = 110,
  FurnitureItem = 1101
}
E.ItemFunctionType = {
  Buff = 1,
  Gift = 2,
  Hero = 3,
  Function = 101,
  FuncSwitch = 102
}
E.ResonanceSkillItemType = {Prop = 300, Material = 301}
E.FishingItemType = {FishingRod = 1103, FishBait = 1102}
E.TeamInviteType = {
  Friend = 1,
  Guild = 2,
  Near = 3
}
E.InvitationTipsType = {
  TeamInvite = 1,
  TeamRequest = 2,
  TeamLeader = 3,
  TeamTransfer = 4,
  MultActionInvite = 5,
  Branching = 6,
  WorldQuest = 7,
  FriendApply = 8,
  UnionHunt = 9,
  Warehouse = 10,
  VehicleApply = 11,
  VehicleInvite = 12,
  UnionWarDance = 13,
  Summon = 14,
  LeisureActivity = 15
}
E.MultActionType = {
  Null = 1,
  ActionIng = 2,
  ActionInvite = 3
}
E.ChestStateTpe = {
  NotOpen = 1,
  AlreadyOpen = 2,
  CanOpen = 3
}
E.DungeonPrecondition = {
  CondPersonNumb = 1,
  CondGS = 2,
  CondQuest = 3,
  CondDungeon = 4,
  CondItem = 5
}
E.DungeonExploreType = {
  MainTarget = 1,
  VagueTarget = 2,
  HideTarget = 3
}
E.AbnormalPanelType = {Self = 1, Boss = 2}
E.BuffLayoutType = {DeBuff = 1, Gain = 2}
E.AttrTipsColorTag = {
  AttrGray = 1,
  Purple = 2,
  Orange = 3
}
E.ChatFuncId = {
  Expression = 102120,
  Backpack = 102121,
  WeaponEnvoy = 102122,
  Achievement = 102123,
  Task = 102124,
  Record = 102125,
  Position = 102126,
  Phrase = 102127,
  NormalItem = 102202,
  EquipItem = 102203,
  ModItem = 102204
}
E.ChatFuncType = {
  Emoji = 1,
  Record = 2,
  Backpack = 3,
  QuickMessage = 4,
  LocalPosition = 5
}
E.FunctionID = {
  None = 0,
  MiniMap = 100301,
  Map = 100302,
  MapMark = 801002,
  MapSetting = 801003,
  Synthesis = 100220,
  Shredder = 100241,
  Fashion = 101101,
  MainFuncMenu = 200000,
  Memory = 300301,
  Cosmetology = 103004,
  Role = 104000,
  RoleAttr = 104001,
  RoleSkill = 104002,
  RoleMemory = 104003,
  Insight = 200201,
  Task = 600100,
  QuestBook = 600102,
  EnvResonance = 200301,
  Guide = 103001,
  MapExplore = 100801,
  MapBook = 100802,
  PhotoTask = 100803,
  ExploreMonster = 100804,
  ExploreMonsterNormal = 100815,
  ExploreMonsterElite = 100805,
  ExploreMonsterBoss = 100806,
  MagicalCreature = 100814,
  MainChat = 102100,
  LandScapeMode = 333334,
  WeaponProfression = 104100,
  EquipChange = 100701,
  EquipFunc = 100702,
  PersonalzoneRecord = 100903,
  PersonalzoneHead = 100904,
  PersonalzoneHeadFrame = 100905,
  PersonalzoneCard = 100906,
  PersonalzoneMedal = 100907,
  Personalzone = 100908,
  PersonalzoneTitle = 100909,
  PersonalzonePhoto = 100910,
  PersonalzoneBg = 100911,
  HeroDungeon = 300200,
  ExtremeSpace = 300206,
  WorldEvent = 800100,
  PayFunction = 800801,
  ExChangeMoney = 800700,
  DiamondToMoney = 800701,
  MoneyToIntegral = 800702,
  RoleInfo = 200001,
  WeaponSkill = 200500,
  WeaponAoyiSkill = 200501,
  WeaponNormalSkill = 200502,
  WeaponSupportSkill = 200503,
  Talent = 104200,
  ProfessionLv = 104201,
  Mod = 104210,
  ModIntensify = 104211,
  ModDecompose = 104212,
  ModTrace = 104213,
  Illustrated = 105010,
  Collect = 600301,
  Monster = 800901,
  PivotManual = 801001,
  Weapon = 110801,
  WeaponSlot = 110821,
  WeaponStrengthen = 110802,
  WeaponReform = 110803,
  WeaponBuild = 110811,
  WeaponSkin = 110804,
  SeasonActivity = 800502,
  SeasonHandbook = 800501,
  SeasonBattlePass = 800505,
  SeasonShop = 800601,
  SeasonTitle = 800503,
  SeasonCenter = 800500,
  SeasonAchievement = 800504,
  SeasonCultivate = 800506,
  SeasonTitleEnter = 800510,
  SeasonBpUnlockUpgrade = 800514,
  MonthlyCard = 801200,
  Shop = 800800,
  QueryBalance = 800805,
  TokenShop = 800812,
  FriendShipShop = 800817,
  FashionShop = 800830,
  FashionGiftShop = 800831,
  FashionClothesShop = 800832,
  FashionJewelryShop = 800833,
  FashionFaceShop = 800834,
  TreasuresShop = 800840,
  MountShop = 800841,
  WeaponShop = 800842,
  WeaponShop2 = 800829,
  Cook = 600901,
  CompensatenShop = 800870,
  ActivityShop = 819300,
  CookLife = 501004,
  LifeWork = 501100,
  Questionnaire = 900101,
  HeroNormalDungeon = 300205,
  HeroDungeonGoblin = 300212,
  HeroDungeonDiNa = 300201,
  HeroChallengeDungeon = 300202,
  HeroDungeonJuTaYiJi = 300203,
  HeroChallengeJuTaYiJi = 300204,
  HeroDungeonJuLongZhuaHen = 300207,
  HeroChallengeJuLongZhuaHen = 300208,
  HeroDungeonKaNiMan = 300209,
  HeroChallengeKaNiMan = 300210,
  HeroDungeonDarkFort = 300213,
  HeroChallengeDarkFort = 300214,
  EntranceDiNa = 300100,
  EntranceJuTaYiJi = 300101,
  UnionTask = 500122,
  Home = 102501,
  Trade = 800400,
  TradeConsignment = 800401,
  TradeBuy = 800405,
  TradeBuyFocus = 800406,
  TradePublicNotice = 800407,
  TradePublicNoticeFocus = 800408,
  TradePreorder = 800409,
  TradeSell = 800410,
  ExitDungeon = 100401,
  WorldBoss = 800902,
  WorldBossSchedule = 800903,
  Fishing = 300000,
  FishingShop = 300003,
  CraftEnergy = 100807,
  Rename = 700102,
  MysteriousShop = 800803,
  SeasonPass = 800509,
  SeasonPassShop = 800818,
  Vehicle = 102800,
  VehicleRide = 102803,
  ShopReputation = 800819,
  WeeklyHunt = 500888,
  Recycle = 106100,
  SevendayTargetTitlePage = 800507,
  SevendayTargetManual = 800508,
  FunctionPreview = 800512,
  UnionHunt = 500151,
  UnionDailySign = 500155,
  UnionWarDance = 900200,
  RecommendFightValue = 200700,
  CompetencyAssess = 200701,
  Proficiency = 200401,
  LifeProfession = 501000,
  LifeProfessionPlant = 501001,
  LifeProfessionMine = 501002,
  LifeProfessionStone = 501003,
  LifeProfessionCook = 501004,
  LifeProfessionChemistry = 501005,
  LifeProfessionCast = 501006,
  LifeProfessionJinXie = 501007,
  LifeProfessionMaterial = 501008,
  SkillSkin = 200506,
  RechargeActivityBuyGift = 801300,
  RechargeActivityBuyGiftA = 801301,
  RechargeActivityBuyGiftB = 801302,
  RoleLevel = 200101,
  Performace = 100601,
  ExpressionPC = 100605,
  FishingAction = 100606,
  CollectionReward = 101105,
  CollectionVipLevel = 101106,
  SceneLine = 101010,
  ShortcutMenu = 106001,
  UnionHeadCamera = 500153,
  UnionCardCamera = 500154,
  UnionPhotoWall = 500156,
  UnionPhotoSet = 500157,
  ChatSettingChannelShow = 102195,
  ChatSettingBarrageShow = 102197,
  ChatSettingFilter = 102198,
  ShareToChat = 300007,
  SelectProfession = 200600,
  ChatExpressionFast = 102250,
  SharePhotoToUnion = 102413,
  Warehouse = 100106,
  Report = 500400,
  UserSupport = 100211,
  Announcement = 100212,
  HaoPlayAnnouncement = 100213,
  HaoPlayUserSupport = 900116,
  HaoPlayUserCenter = 900117,
  APJAnnouncement = 100214,
  BlessExp = 500500,
  DetachStuck = 100200,
  Treasure = 501201,
  CameraDepth = 102007,
  House = 102500,
  HouseFurnitureGuide = 102502,
  HouseProduction = 102503,
  TencentQQChannel = 900102,
  TencentQQPrivilege = 900103,
  TencentQQGift = 900104,
  TencentQQGameCenter = 900105,
  TencentWeChatGift = 900106,
  TencentWeChatPrivilege = 900107,
  TencentSuperVip = 900108,
  TencentGrowth = 900109,
  TencentFriends = 900110,
  TencentGroup = 900111,
  TencentQQArk = 900112,
  TapTapEvaluation = 900113,
  TokenLink = 900114,
  AppleStoreEvaluation = 900115,
  GoogleStoreEvaluation = 900120,
  TencentWechatOriginalShare = 300008,
  SDKShareLocalPhoto = 102414,
  SDKShareCloudPhoto = 102415,
  Handbook = 600400,
  HandbookMonthCard = 600401,
  HandbookRead = 600402,
  HandbookDictionary = 600403,
  HandbookPostCard = 600404,
  HandbookCharater = 600405,
  PathFinding = 102900,
  LeisureActivities = 800200,
  Achievement = 800515,
  Gacha = 800820,
  SpecialGacha = 800821,
  HouseQuest = 102505,
  PlayerNewbie = 100502,
  HomeFlowerRecycle = 106105,
  HomeBuyShop = 102504,
  HomeSellShop = 102508,
  HomeWarehouse = 102507,
  HomeLiveTogether = 102513,
  TeamVoice = 101008,
  TeamVoiceMic = 101009,
  FaceShareScanIOS = 103005,
  FaceShareScanAndroid = 103006,
  FaceShareLoadWin = 103007,
  FaceShareLoadIOS = 103008,
  FaceShareLoadAndroid = 103009,
  ThemePlay = 820000,
  Dps = 100503,
  RaidDungeonBuff = 500125,
  PandoraPopup = 819000,
  AddFriend = 102301,
  DeleteFriend = 102312,
  FashionDyeing = 101107,
  TeamTwenty = 101011,
  ChatVoiceInput = 102206,
  ChatVoiceText = 102207,
  DisplayCustomHeadPhoto = 100912,
  DisplayCustomHalfBody = 100913,
  CdKey = 500450
}
E.BackpackFuncId = {
  Backpack = 100101,
  ItemBp = 100103,
  EquipBp = 100104,
  CardBp = 100105,
  ResonanceSkill = 100107
}
E.ResonanceFuncId = {
  Decompose = 200505,
  Create = 200504,
  Advance = 200507
}
E.SetFuncId = {
  Setting = 100201,
  SettingControl = 100202,
  SettingBasic = 100203,
  SettingFrame = 100204,
  SettingAccount = 100205,
  SettingOther = 100206,
  SettingExpend = 100207,
  SettingKey = 100208,
  SettingLanguage = 100209,
  GamepadKeyDisplay = 100260,
  SettingLanguageVoice = 110209,
  NpcVoice = 110210
}
E.EquipFuncId = {
  Equip = 100701,
  EquipFunc = 100702,
  EquipDecompose = 100707,
  EquipRecast = 100708,
  EquipRefine = 100709,
  EquipEnchant = 100710,
  EquipTrace = 100711,
  EquipBreak = 100712,
  EquipMake = 100713,
  EquipSuit = 100714
}
E.PerformanceFuncId = {
  Performace = 100601,
  Action = 100602,
  Expression = 100603,
  Interactive = 100604
}
E.TeamFuncId = {
  Team = 101001,
  Hall = 101002,
  Vicinity = 101003,
  Mine = 101004
}
E.UnionFuncId = {
  Union = 500100,
  UnionList = 500101,
  Create = 500103,
  Main = 500104,
  Member = 500105,
  Build = 500106,
  Collection = 500107,
  Active = 500109,
  Hunt = 500108,
  Buff = 500121
}
E.AlbumFuncId = {
  Album = 102400,
  Temporary = 102401,
  Mine = 102402,
  UnionAlbum = 102410,
  UnionTemporary = 102411,
  UnionCloud = 102412
}
E.IdCardFuncId = {
  JoinTeam = 2001,
  InviteTeam = 2002,
  RequestLeader = 2003,
  TransferLeader = 2004,
  KickTeam = 2005,
  InviteAction = 2006,
  AddFriend = 2007,
  SendMsg = 2008,
  BlockPlayer = 2009,
  CancelBlock = 2010,
  InviteUnion = 3001,
  JoinUnion = 3002,
  UnionPosManage = 3003,
  KickUnion = 3004,
  EnterLine = 4001,
  InvteWarehouse = 100106,
  ApplyForRide = 102801,
  InviteRide = 102802,
  Report = 500400
}
E.ExchangeFuncId = {Exchange = 100230, UnionExchange = 100233}
E.ShopFuncID = {MonthlyCard = 801200}
E.ExchangeLimitType = {
  Not = -1,
  Always = 0,
  Day = 1,
  Week = 2
}
E.GlobalTimerTag = {
  TeamApply = 1,
  TeamMatch = 2,
  HallTeamListRefresh = 3,
  NearbyTeamListRefresh = 4,
  TeamOneKeyJoin = 5,
  TeamInvite = 6,
  TeamApplyCaptain = 7,
  SnapShot = 8,
  HeadSnapShot = 9,
  HalfSnapShot = 10,
  MultActionInvite = 11,
  MultActionBevited = 12,
  RedDotPoint = 13,
  TalkEnd = 14,
  Investigate = 15,
  PivotUnlock = 16,
  DungeonSettle = 17,
  TeamSpeakVoice = 18,
  LoadPlayerHead = 19,
  RefreshEnergy = 20,
  WeeklyHuntNext = 21,
  SeasonAchievementRed = 22,
  DungeonPrepareTime = 23,
  DungeonPrepareCD = 24,
  TeamTypeCD = 25
}
E.PrefabPoolState = {
  None = 0,
  Active = 1,
  Rest = 3
}
E.SettingID = {
  Master = 1,
  Bgm = 2,
  Sfx = 3,
  Voice = 4,
  System = 5,
  P3 = 12,
  PlayerVoiceReceptionVolume = 13,
  PlayerVoiceTransmissionVolume = 14,
  LockOpen = 1001,
  LockOperationMode = 1002,
  GlideDirectionCtrl = 1003,
  GlideDiveCtrl = 1004,
  HorizontalSensitivity = 1005,
  VerticalSensitivity = 1006,
  BattleZoomCorrection = 1007,
  BattlePitchAngkeCorrection = 1008,
  CameraTemplate = 1009,
  PitchAngleCorrection = 1010,
  ShowSkillTag = 1011,
  AutoBattle = 1012,
  CameraLockFirst = 1013,
  CameraSeismicScreen = 1014,
  PulseScreen = 1015,
  SkillController = 1016,
  SkillControllerPcUp = 1024,
  CameraTranslationRotate = 1017,
  CameraReleasingSkill = 1018,
  CameraReleasingSkillAngle = 1019,
  CameraSeek = 1020,
  CameraMelee = 1022,
  RemoveMouseRestrictions = 1023,
  CameraMove = 1021,
  CameraInertia = 1025,
  HorizontalSensitivityHandle = 1026,
  VerticalSensitivityHandle = 1027,
  MouseSpeedHandle = 1028,
  KeyHint = 2001,
  EffSelf = 3001,
  EffEnemy = 3002,
  EffTeammate = 3003,
  EffOther = 3004,
  EffectRest = 3005,
  HudNumberClose = 3010,
  HudNumberSimple = 3011,
  WeaponDisplay = 4001,
  PlayerHeadInformation = 4002,
  OtherPlayerHeadInformation = 4003,
  NPCPlayerHeadInformation = 4004,
  ShowTaskEffect = 4005,
  ToyVisible = 5000
}
E.SettingToyType = {
  Invisible = 0,
  VisibleNoInteract = 1,
  VisibleAndInteract = 2
}
E.SettingHUDType = {
  Name = 1,
  Title = 2,
  Func = 3
}
E.ClientSettingID = {Grade = -1, AutoPlay = -2}
E.HelpSysType = {
  Mul = 1,
  Tips = 2,
  FullScreen = 3,
  Mix = 4
}
E.HelpSysFilterType = {
  None = 0,
  First = 1,
  Second = 2
}
E.AlbumType = {
  Temporary = 0,
  Couldalbum = 1,
  UnionTemporary = 2,
  UnionCloud = 3
}
E.AlbumPopupType = {Create = 0, Change = 1}
E.AlbumPhotoType = {OriPhoto = 0, EffPhoto = 1}
E.AlbumMainState = {
  Temporary = 0,
  Couldalbum = 1,
  MovePhoto = 2,
  UnionTemporary = 3,
  UnionCloud = 4
}
E.CachePhotoType = {
  CacheOriPhoto = 1,
  CacheEffectPhoto = 2,
  CacheThumbPhoto = 3,
  CacheHeadPhoto = 4,
  CacheHalfPhoto = 5
}
E.HttpTokenType = {
  FuncTypeDefault = 0,
  HeadProfile = 1,
  Photograph = 2
}
E.AlbumSecondEditType = {
  None = 0,
  Exposure = 1,
  Contrast = 2,
  Saturation = 3
}
E.UpgradeType = {
  WeaponHeroLevel = 1,
  WeaponHeroOverstep = 2,
  WeaponHeroSkillLevel = 3,
  SkillRemodel = 4,
  WeaponSkillUnlock = 5
}
E.CameraState = {
  None = -1,
  Default = 0,
  Cooking = 2,
  Position = 3,
  SelfPhoto = 8,
  AR = 9,
  UnrealScene = 10,
  ThreeRD = 12,
  MiscSystem = 13
}
E.TakePhotoSate = {
  Default = 1,
  SelfPhoto = 2,
  AR = 3,
  UnionTakePhoto = 4,
  Battle = 5
}
E.UnionCameraSubType = {
  Body = 0,
  Head = 1,
  Fashion = 2
}
E.CameraTargetStage = {
  [E.TakePhotoSate.Default] = 1,
  [E.TakePhotoSate.AR] = 2,
  [E.TakePhotoSate.SelfPhoto] = 3,
  [E.TakePhotoSate.UnionTakePhoto] = 4,
  [E.TakePhotoSate.Battle] = 5
}
E.ESystemTipInfoType = {
  ItemInfo = 1,
  MessageInfo = 2,
  HeroDungeonRoll = 3
}
E.WeaponHeroResonanceType = {Default = 1, Details = 2}
E.EnvResonanceSkillState = {
  Lock = 1,
  NotActive = 2,
  Active = 3,
  Equip = 4,
  Expired = 5
}
E.ParkourStyleItemLifeCycle = {
  None = 0,
  Entrance = 1,
  Stay = 2,
  Exit = 3,
  Death = 4
}
E.LockOperationMode = {Btn = 1, Free = 2}
E.GlideDirectionCtrlMode = {Axis = 1, Camera = 2}
E.FreeSkillUseMode = {Click = 1, Release = 2}
E.GlideDiveCtrlMode = {Up = 1, Down = 2}
E.PictureType = {
  ENormalPicture = 0,
  ECameraOriginal = 1,
  ECameraRender = 2,
  ECameraThumbnail = 3,
  EProfileSnapShot = 4,
  EProfileHalfBody = 5
}
E.CharacterViewType = {
  ERoleInfo = 1,
  EWeaponHero = 2,
  EEquip = 3
}
E.LevelMapFlagSrc = {
  Function = 1,
  WorldQuest = 2,
  QuestGoal = 3,
  QuestNpc = 4
}
E.MapFlagType = {
  None = 0,
  Entity = 1,
  NotEntity = 2,
  AreaName = 3,
  Custom = 4,
  Team = 5,
  Position = 6
}
E.MapSubViewType = {
  Info = 1,
  NormalQuest = 2,
  EventQuest = 3,
  Custom = 5,
  PivotReward = 6,
  PivotProgress = 7,
  DungeonEnter = 8,
  DungeonAdd = 9,
  LifeSystem = 10,
  Collection = 11,
  SceneLock = 12
}
E.CameraSchemeType = {DefaultScheme = 0, CustomScheme = 1}
E.AlbumServerCtrlType = {
  DefaultCtrlType = 0,
  TempUpLoad = 1,
  CloudMove = 2,
  CloudUpLoad = 3
}
E.CameraUpLoadStateType = {
  DefaultState = 0,
  UpStart = 1,
  UpLoading = 2,
  UpLoadSuccess = 3,
  UpLoadFail = 4,
  UpLoadOverTime = 5
}
E.CameraUpLoadErrorType = {CommonError = 0, HttpError = 1}
E.PhotoUpLoadType = {FullUpload = 0, ThumbnailAndEffectUpload = 1}
E.TipsType = {
  PopTip = 1,
  CopyMode = 2,
  Captions = 3,
  TalkInfo = 4,
  DungeonSpecialTips = 5,
  DungeonChallengeWinTips = 6,
  DungeonChallengeFailTips = 7,
  BottomTips = 8,
  MiddleTips = 9,
  QuestLetter = 10,
  DungeonRedTips = 11,
  DungeonGreenTips = 12,
  QuestLetterWithBackground = 13
}
E.NativeTextureCallToken = {
  album_photo_item = 10001,
  album_photo_show_view = 10002,
  alnum_main_vm = 10003,
  CommonPlayerPortraitItem = 10004,
  IdcardView = 10005,
  Camera_photo_secondary_editingView1 = 10006,
  CamerasysView = 10007,
  album_loop_item = 10008,
  alnum_newlybuild_item = 10009,
  album_photo_details_view = 10010,
  Camera_photo_secondary_editingView2 = 10011,
  CamerasysViewOri = 10012,
  Personalzone_photo_show_view = 10013,
  GameShare = 10014,
  Personalzone_main_view = 10015
}
E.SkillSlotType = {
  NormalAttack = 1,
  SpecialSkills = 2,
  UltimateSkill = 3,
  NormalSkill = 4,
  MysteriesSkill = 5,
  SupportSkill = 6,
  ResonanceSkill = 7
}
E.SlotType = {Skill = 0, Normal = 1}
E.SkillType = {
  WeaponSkill = 1,
  MysteriesSkill = 2,
  EnvironmentSkill = 3
}
E.SkillSlotLogicType = {
  Normal = 0,
  WeaponSkill = 1,
  MysteriesSkill = 2,
  InteractiveSkill = 3,
  EnvironmentSkill = 4,
  MountSkill = 5,
  SceneMaskSkill = 200
}
E.SlotName = {
  SkillSlot_1 = "1",
  SkillSlot_2 = "2",
  SkillSlot_3 = "3",
  SkillSlot_4 = "4",
  SkillSlot_5 = "5",
  SkillSlot_9 = "9",
  SkillSlot_6 = "6",
  SkillSlot_7 = "7",
  SkillSlot_8 = "8",
  SkillSlot_10 = "10",
  ExtraSlot_1 = "11",
  ExtraSlot_2 = "12",
  ExtraSlot_3 = "13",
  ExtraSlot_4 = "14",
  VehicleSkillsSlot_1 = "30",
  ResonanceSkillSlot_left = "101",
  ResonanceSkillSlot_right = "102",
  Interactive = "111",
  Swim = "112",
  CancelMulAction = "113"
}
E.SkillSlot = {
  SkillSlot_1 = E.SlotName.SkillSlot_1,
  SkillSlot_2 = E.SlotName.SkillSlot_2,
  SkillSlot_3 = E.SlotName.SkillSlot_3,
  SkillSlot_4 = E.SlotName.SkillSlot_4,
  SkillSlot_5 = E.SlotName.SkillSlot_5,
  SkillSlot_6 = E.SlotName.SkillSlot_6,
  SkillSlot_7 = E.SlotName.SkillSlot_7,
  SkillSlot_8 = E.SlotName.SkillSlot_8,
  SkillSlot_9 = E.SlotName.SkillSlot_9
}
E.NormalSkill = {
  SkillSlot_1 = E.SlotName.SkillSlot_1,
  SkillSlot_2 = E.SlotName.SkillSlot_2,
  SkillSlot_3 = E.SlotName.SkillSlot_3,
  SkillSlot_4 = E.SlotName.SkillSlot_4,
  SkillSlot_5 = E.SlotName.SkillSlot_5,
  SkillSlot_6 = E.SlotName.SkillSlot_6,
  SkillSlot_9 = E.SlotName.SkillSlot_9
}
E.AoyiSkill = {
  SkillSlot_7 = E.SlotName.SkillSlot_7,
  SkillSlot_8 = E.SlotName.SkillSlot_8
}
E.ResonanceSkillSlot = {
  ResonanceSkillSlot_left = E.SlotName.ResonanceSkillSlot_left,
  ResonanceSkillSlot_right = E.SlotName.ResonanceSkillSlot_right
}
E.Jump = {
  ExtraSlot_2 = E.SlotName.ExtraSlot_2
}
E.Dash = {
  ExtraSlot_3 = E.SlotName.ExtraSlot_1
}
E.WeaponOperate = {
  LockTarget = E.SlotName.ExtraSlot_4
}
E.VehicleSkills = {
  VehicleSkillSlot_1 = E.SlotName.VehicleSkillsSlot_1
}
E.SkillSlotEventCtrlType = {EAddSlot = 0, ERemoveSlot = 1}
E.PlayerCtrlBtnType = {
  ESkillSlotBtn = 1,
  EFlowBtn = 2,
  EJumpBtn = 3,
  ERushBtn = 4
}
E.FriendsSetShowSubViewType = {PeosonalityLabelSub = 0, PeosonalitySignatureSub = 1}
E.UnionPowerDef = {
  None = -1,
  SetMemberPosition = 500201,
  ProcessApplication = 500202,
  KickOut = 500203,
  ModifyName = 500204,
  ModifyIcon = 500205,
  ModifyManifesto = 500206,
  ModifyPositionName = 500207,
  ModifyPositionPower = 500208,
  ModifyRecruit = 500209,
  ModifyTag = 500211,
  UpgradeBuilding = 500212,
  SetBuildingEffect = 500213,
  SetCover = 500219,
  SetEScreenPhoto = 500220,
  EditAlbum = 500221
}
E.UnionIconType = {
  EMascot = 1,
  EIcon = 2,
  EPattern = 3
}
E.UnionPositionDef = {
  President = 1,
  VicePresident = 2,
  Administrator = 3,
  Member = 4,
  Custom1 = 10,
  Custom2 = 11,
  Custom3 = 12,
  Custom4 = 13
}
E.UnionLogoItemShowType = {
  None = 0,
  Logo = 1,
  Element = 2
}
E.UnionPositionPopupType = {
  None = 0,
  PositionEdit = 1,
  MemberAppoint = 2,
  PowerEdit = 3
}
E.UnionMemberSortMode = {
  None = 0,
  Name = 1,
  Position = 2,
  RoleLevel = 4,
  Contribution = 5,
  OfflineTime = 6
}
E.UnionMemberOrderMode = {
  None = 0,
  Ascending = 1,
  Descending = 2
}
E.UnionSettingSubType = {
  Name = 1,
  Icon = 2,
  Tag = 3,
  Picture = 4,
  Announce = 5
}
E.UnionTagType = {Time = 1, Activity = 2}
E.UnionMainTab = {
  Home = 1,
  Member = 2,
  Build = 3,
  Active = 4,
  Hunt = 5
}
E.UnionRecruitViewType = {List = 1, Preview = 2}
E.UnionTagItemType = {
  Normal = 1,
  Selection = 2,
  Label = 3
}
E.UnionResourceId = {
  Exp = 10010001,
  Gold = 10010002,
  Active = 10010003
}
E.UnionBuildPopupType = {Upgrade = 1, Buff = 2}
E.UnionBuildId = {
  BaseBuild = 1,
  Buff = 2,
  Practice = 3,
  Rest = 4,
  Mall = 5,
  Screen = 6,
  IdPhoto = 7
}
E.UnionServerQueryTimeKey = {
  UnionList = 1,
  UnionCollection = 2,
  UnionInfo = 3
}
E.UnionUnlockState = {
  WaitBegin = 1,
  IsCrowding = 2,
  WaitBuildEnd = 3,
  BuildEnd = 4
}
E.UnionIconType = {
  EMascot = 1,
  EIcon = 2,
  EPattern = 3
}
E.UnionPositionDef = {
  President = 1,
  VicePresident = 2,
  Administrator = 3,
  Member = 4,
  Custom1 = 10,
  Custom2 = 11,
  Custom3 = 12,
  Custom4 = 13
}
E.UnionLogoItemShowType = {
  None = 0,
  Logo = 1,
  Element = 2
}
E.UnionMemberSortMode = {
  None = 0,
  Name = 1,
  Position = 2,
  GearScore = 3,
  RoleLevel = 4,
  Contribution = 5,
  OfflineTime = 6
}
E.UnionMemberOrderMode = {
  None = 0,
  Ascending = 1,
  Descending = 2
}
E.DrawState = {
  NoDraw = 0,
  CanDraw = 1,
  AlreadyDraw = 2
}
E.TrialRoadDeadViewBtnType = {LeaveCopy = 0, Restart = 1}
E.DungeonType = {
  None = 0,
  DungeonCopy = 1,
  HeroCopy = 2,
  Planetmemory = 3,
  DungeonNormal = 1,
  DungeonLiner = 2,
  DungeonPlanetmemory = 3,
  Parkour = 5,
  Flux = 6,
  ThunderElemental = 7,
  HeroNormalDungeon = 8,
  HeroChallengeDungeon = 9,
  Union = 10,
  UnionHunt = 13,
  HeroKeyDungeon = 14,
  WorldBoss = 15,
  WeeklyTower = 16,
  MasterChallengeDungeon = 17
}
E.DungeonResultHudType = {
  None = 0,
  Normal = 1,
  Liner = 2,
  HeroCopy = 3,
  TrialRoad = 4,
  Parkour = 5
}
E.DungeonState = {
  DungeonStateNull = 0,
  DungeonStateActive = 1,
  DungeonStateReady = 2,
  DungeonStatePlaying = 3,
  DungeonStateEnd = 4,
  DungeonStateSettlement = 5,
  DungeonStateVote = 6
}
E.DungeonResult = {
  DungeonResultNull = 0,
  DungeonResultSuccess = 1,
  DungeonResultFailed = 2
}
E.DungeonTimeShowType = {time = 1, num = 2}
E.PCKeyHint = {
  LockTarget = 23,
  ShowMouse = 116,
  RunWalkSwitch = 6,
  Dash = 8,
  Jump = 7
}
E.SceneObjType = {
  Normal = 0,
  Pivot = 1,
  PivotPort = 2,
  Resonance = 3,
  Transfer = 4,
  WorldQuest = 5,
  Collection = 6,
  MonsterHunt = 7
}
E.RedType = {
  TeamApplyMain = 1,
  TeamApplySystem = 2,
  TeamApplyButton = 3,
  EscMenu = 12,
  UnionMemberTab = 14,
  UnionApplyButton = 15,
  WorldEventReward = 16,
  RoleMain = 17,
  RoleMainRolelevelBtn = 18,
  Equip = 19,
  QuestSeasonDay1 = 21,
  QuestSeasonDay2 = 22,
  QuestSeasonDay3 = 23,
  Proficiency = 24,
  HeroMemory = 103,
  HeroDungeonReward = 104,
  TalentEnter = 201,
  ModEnter = 202,
  TalentTab = 203,
  TalentTree = 203001,
  ModTab = 204,
  TalentRoleEnter = 205,
  ModRoleEnter = 206,
  Surveys = 901,
  Socialcontact = 1001,
  SocialcontactFriendTab = 1002,
  FriendChatTab = 1003,
  FriendAddressTab = 1004,
  SocialcontactMail = 1101,
  SocialcontactMailTab = 1102,
  MailNormal = 1103,
  MailImport = 1104,
  MailNormalItem = 1105,
  MailImportItem = 1106,
  ScenicPhoto = 1201,
  QuestMain = 1301,
  QuestList = 1302,
  Backpack = 100101,
  BagTab = 100102,
  BagSecondTab = 100103,
  BagItem = 100104,
  Shop = 2000,
  ShopOneTab = 2001,
  ShopTwoTab = 2002,
  ShopItem = 2003,
  SeasonShop = 2010,
  SeasonShopOneTab = 2011,
  SeasonShopItem = 2012,
  SeasonTitle = 2020,
  MonthlyCardTab = 2007,
  MonthlyCardGift = 2008,
  WorldEvent = 38,
  PivotProgress = 40,
  MonsterExplore = 36,
  MapMain = 37,
  ExpressionMain = 1401,
  ExpressionAction = 1402,
  ExpressionEmote = 1403,
  ExpressionItem = 1404,
  WeaponDevelop = 304,
  WeaponSlotLeft = 305,
  WeaponSlotRight = 309,
  WeaponCulture = 306,
  WeaponEnhancement = 307,
  WeaponModification = 308,
  RoleEquipPart = 401,
  EquipPart = 402,
  EquipItem = 403,
  WeaponSkillTab = 501,
  WeaponSkillDetail = 502,
  WeaponResonanceTab = 503,
  WeaponResonanceDynamic = 504,
  WeaponResonanceActive = 505,
  WeaponResonanceAdvance = 506,
  WeaponSkillUpLevel = 508,
  WeaponSkillRemould = 509,
  ResonanceMakePropItem = 520,
  Achievement = 1029000,
  SeasonAchievement = 1029001,
  SeasonCenter = 800500,
  SeasonBpCardAndActivation = 39,
  HeroDungeonWeek = 41,
  HeroDungeonWeekTraget = 42,
  SeasonActivationTab = 43,
  BpCardTab = 44,
  SeasonActivationAward = 45,
  BpCardAward = 46,
  UnionActiveTab = 51,
  UnionActiveItem = 52,
  UnionBuildTab = 53,
  UnionBuildItem = 54,
  UnionBuildUpgradeBtn = 55,
  UnionSceneUnlockRed = 170,
  UnionSceneUnlockBtnRed = 171,
  TrialRoadMain = 60,
  TrialRoadSelectTab = 61,
  TrialRoadRoomSelect = 62,
  TrialRoadRoomTarget = 63,
  TrialRoadGradeBtn = 64,
  TrialRoadGradeTarget = 65,
  SeasonCultivateRed = 66,
  SeasonCultivateCoreRed = 67,
  SeasonCultivateCoreSlotRed = 68,
  SeasonCultivateNodeRed = 69,
  SeasonCultivateCoreBtnRed = 70,
  SevenDaysTargetMain = 20,
  SevenDaysTargetTitlePageTab = 21,
  SevenDaysTargetTitlePageBtn = 23,
  SevenDaysTargetManualTab = 22,
  SevenDaysTargetManualQuestTab = 24,
  SevenDaysTargetManualQuest = 25,
  SevenDaysTargetManualQuestBtn = 26,
  SevenDaysTargetFuncPreviewTab = 27,
  SevenDaysTargetFuncPreviewItem = 28,
  FuncPreviewESC = 31,
  SevenDaysTargetFuncPreviewAwardMain = 32,
  MonsterHuntMapBtn = 71,
  MonsterHuntRightListBtn = 100804,
  MonsterHuntLeftTab = 72,
  MonsterHuntMonsterItem = 73,
  MonsterHuntTargetReceiveBtn = 74,
  MonsterHuntLevel = 75,
  MonsyerHuntLevelReceiveBtn = 76,
  RoleMainRolelevelPageBtn = 77,
  EnvSkillPageBtn = 78,
  HelpsysRed = 103001,
  HelpsysTabRed = 1030010001,
  HelpsysItemRed = 103001002,
  Personalzone = 1501,
  PersonalzoneHead = 1502,
  PersonalzoneHeadFrame = 1503,
  PersonalzoneCard = 1505,
  PersonalzoneMedal = 1506,
  PersonalzoneTitle = 1504,
  PersonalzoneBg = 1507,
  FishingEsc = 150,
  FishingMainLevelBtn = 151,
  FishingIllustratedTab = 152,
  FishingIllustratedAreaTab = 153,
  FishingIllustratedFishTypeTab = 154,
  FishingShopTab = 163,
  FishingShopLevel = 164,
  FishingLevelAwardBtn = 165,
  FishingLevelAwardAllBtn = 166,
  SkillEntranceInEscMenu = 156,
  SkillUnlock = 157,
  SkillEquip = 158,
  SkillEquipSlot = 159,
  SkillEquipBtn = 160,
  NormalSkillTab = 161,
  ResonanceSkillEquipBtn = 162,
  MysteriousShopRed = 2004,
  RecommendedPlayRed = 111,
  WorldBossGotoBtnRed = 112,
  WorldBossScoreRed = 113,
  WorldBossScoreAwardItemRed = 114,
  WorldBossProgressRed = 115,
  WorldBossProgressAwardItemRed = 116,
  FaceEditor = 1511,
  FaceEditorHair = 1512,
  FaceEditorHairWhole = 1513,
  FaceEditorHairCustom = 1514,
  FaceEditorHairCustomFront = 1515,
  FaceEditorHairCustomBack = 1516,
  FaceEditorHairCustomDull = 1517,
  EquipRefineRed = 410,
  EquipRefinePartRed = 411,
  TradeItemTimeout = 1210,
  TradeItemSell = 1211,
  TradeItemPreBuy = 1212,
  TradeRedMainui = 1213,
  TradeSellType = 1214,
  UnionActivity = 3000,
  UnionHuntPorgress = 3001,
  UnionHuntTab = 3002,
  UnionHuntCount = 3003,
  UnionDanceTab = 3004,
  UnionDanceCount = 3005,
  HouseRed = 4000,
  HouseLevelRed = 4001,
  HouseInviteRed = 4002,
  WeeklyHuntTarget = 1601,
  SkillSkinUnlock = 172,
  SkillSkinBtn = 173,
  WeeklyHuntAward = 1602,
  RechargeActivityBuyGift = 2005,
  FashionRed = 601,
  FashionCollectionScoreRewardRed = 602,
  FashionCollectionWindowRed = 603,
  FashionCollectionWindowPrivilegeRed = 604,
  FashionClothes = 605,
  FashionOrnament = 606,
  FashionWeapon = 607,
  PandoraAnnounce = 1701,
  WeaponRolePlayerPc = 1021001,
  ChatInputBoxMoreBtn = 701,
  ChatInputBoxEmojiFunctionBtn = 702,
  Treasure = 50120101,
  Vehicle = 651,
  VehicleItem = 652,
  MasterScore = 81000701,
  ThemePlay = 82000000,
  ThemePlayActivity = 82000001,
  ThemePlayPandora = 82000002
}
E.UnBreakType = {
  Default = 1,
  Flick = 2,
  FlickPause = 3,
  Lock = 4
}
E.WorldEventDungeonViewState = {
  Prepare = "Prepare",
  CountDown = "CountDown",
  Ranking = "Ranking",
  EndState = "EndState"
}
E.TimeStyle = {
  YMD = 1,
  YMDToYMD = 2,
  MD = 3,
  MDToMD = 4,
  HMS = 5
}
E.TalkOptionsType = {Normal = 1, Confrontation = 2}
E.TalkItemSubmitType = {Submit = 1, Show = 2}
E.MasteryCombinationType = {
  NotComb = 0,
  Normal = 1,
  pro = 2
}
E.AttrInfoType = {
  All = -1,
  Buff = 1,
  Attr = 2
}
E.RemodelInfoType = {
  All = -1,
  Attr = 1,
  SkillId = 2,
  Buff = 3,
  SixDimensional = 4,
  TmpAttr = 5,
  SkillReplace = 6,
  SkillDamageMultiple = 7,
  ReduceSkillCD = 8,
  ReduceSkillCharge = 9
}
E.ShortcutsItemType = {
  Shortcuts = 0,
  Quest = 1,
  Other = 2
}
E.ProficiencyItemState = {
  None = 0,
  NotLock = 1,
  On = 2,
  Off = 3,
  NotGrade = 4
}
E.NoticeType = {
  Event = 1001,
  System = 1002,
  Update = 1003
}
E.SteerType = {
  InputEvent = 500,
  EnterScene = 501,
  ReceiveItem = 502,
  OpenUi = 503,
  AcceptQuest = 504,
  FinishQuest = 505,
  Trigger = 506,
  ChangeWeapon = 507,
  OnInputKey = 508,
  StopEPFlow = 509,
  EndCutscene = 510,
  ActiveTaskGuide = 511,
  PlayCutscene = 512,
  GuideEvent = 513,
  ResonancEnvironment = 514,
  OnClickAllArea = 515,
  OnFinishSteer = 516,
  OnSelectFashion = 517,
  OnClickSteerArea = 518,
  CloseUi = 519,
  UnLockFunction = 520,
  AtWillOperation = 521,
  UseItem = 522,
  ReceiveItemType = 523,
  BagItem = 524,
  AlreadyPutEquip = 525,
  Timer = 526,
  Rolelevel = 533,
  ResonanceWeapon = 9,
  PutOnEquip = 11
}
E.ShowSteerType = {OnSelectFashion = 1, FocusUIViewConfigKey = 2}
E.SteerGuideEventType = {
  Investigation = 1,
  PutOnEquip = 2,
  Fishing = 3,
  RecastEquip = 4,
  SelectedMainFunction = 5,
  AssemblySkillSlot = 6
}
E.DynamicSteerType = {
  FunctionId = 1,
  ExpressionTab = 2,
  ExpressionId = 3,
  SceneId = 4,
  MapFlag = 5,
  FashionId = 6,
  KeyBoardId = 7,
  MapActivityId = 8,
  LockSkillIndex = 9,
  EquipSlotIndex = 10,
  ResonanceIndex = 11,
  InteractionId = 12,
  SeasonFunctionId = 13,
  Fishing = 14,
  WeaponSkillSlot = 15,
  EquipBtn = 16,
  ChooseSkillIndex = 17,
  MedalEditItemIndex = 18,
  EquipEnchantItemIndex = 19,
  BagFirstIndex = 20,
  FashionItemIndex = 21,
  expressionGroupIndex = 22,
  HomeEditorTogId = 23,
  HomeEditorItemIndex = 24,
  AchievementSeasonClassId = 25,
  CurrencyItemId = 26
}
E.ItemLabType = {
  Num = 1,
  Expend = 2,
  Str = 3
}
E.AudioState = {
  Game = "GameState",
  Boss = "BossState",
  Login = "BGM_System"
}
E.AudioGameState = {
  None = "",
  Realtime = "RTCuts",
  Cutscene = "Cutscene",
  Dialogue = "SKT",
  Ingame = "Normal",
  Menu = "Menu"
}
E.ItemType = {
  CostItem = 11,
  ActionExpression = 107,
  Blueprint = 117,
  FashinUnlockItem = 119,
  VehicleUnlockItem = 120,
  Vehicle = 1201
}
E.EBuffPriority = {
  NotShow = 0,
  Secondly = 1,
  Highest = 2,
  Notice = 3,
  NoticeAndTeamShow = 4
}
E.EBuffType = {
  Debuff = 0,
  Gain = 1,
  GainRecovery = 2,
  Item = 3
}
E.ESystemCameraId = {WeaponRole = 4000, WeaponRoleScreen = 4001}
E.MainViewHideStyle = {
  None = 0,
  Left = 1,
  Right = 2,
  Top = 3,
  Bottom = 4,
  UpperLeft = 5,
  UpperRight = 6,
  LowLeft = 7,
  LowRight = 8
}
E.MainUIArea = {
  UpperLeft = 1,
  LowLeft = 2,
  UpperRight = 3,
  LowRight = 4
}
E.MainUIShowLeftType = {
  DefaultHideButRec = 0,
  DefaultShowButRec = 1,
  DefaultHide = 2,
  DefaultShow = 3
}
E.MainUIPlaceType = {
  LeftTop = 1,
  LeftBottom = 2,
  RightTop = 3,
  Esc = 4,
  EscRight = 5
}
E.SkillViewSubViewType = {
  skillLevel = "skillLevelUp",
  skillRemodel = "skillRemodel"
}
E.ItemFilterType = {
  ItemRare = 1,
  ModType = 2,
  ItemType = 4,
  MonsterHunt = 8,
  ModRare = 16,
  ModEffectType = 32,
  ResonanceSkillRarity = 64,
  ResonanceSkillType = 128,
  ModSuccessTimes = 256,
  EquipProfession = 512,
  EquipGs = 1024,
  EquipRecast = 2048,
  EquipPerfect = 4096
}
E.CommonFilterType = {
  ModType = 1,
  ModQuality = 2,
  ModEffectSelect = 3,
  SeasonEquip = 4,
  EquipGs = 5,
  UnlockProfession = 6,
  ResonanceSkillRarity = 7,
  ResonanceSkillType = 8,
  ResonanceHave = 9
}
E.EWorldEventType = {
  Blue = 1,
  Purple = 2,
  Orange = 3
}
E.DungeonTimerDirection = {DungeonTimerDirectionDown = 0, DungeonTimerDirectionUp = 1}
E.DungeonTimerType = {
  DungeonTimerTypeNull = 0,
  DungeonTimerTypeRightCommon = 1,
  DungeonTimerTypeMiddlerCommon = 2,
  DungeonTimerTypeHero = 3,
  DungeonTimerTypeWait = 4,
  DungeonTimerTypePrepare = 5
}
E.DungeonCondition = {
  LevelConditionalLimitations = 1,
  QuestConditionalLimitations = 2,
  TalentConditionalLimitations = 3,
  GSConditionalLimitations = 4,
  ItemConditionalLimitations = 5,
  DungeonConditionalLimitations = 6,
  DungeonScoreConditionalLimitations = 7,
  TimeConditionalLimitations = 8,
  TimeIntervalConditionalLimitations = 9,
  SkillLevelConditionalLimitations = 17,
  SeasonTimeOffset = 27
}
E.DungeonTimerEffectType = {
  EDungeonTimerEffectTypeNull = 0,
  EDungeonTimerEffectTypeAdd = 1,
  EDungeonTimerEffectTypeSub = 2,
  EDungeonTimerEffectTypeChange = 3
}
E.DungeonTimerTimerLookType = {EDungeonTimerTimerLookTypeDefault = 0, EDungeonTimerTimerLookTypeRed = 1}
E.EActionType = {Idle = 19}
E.UnrealSceneSlantingLightStyle = {
  Green = 0,
  Red = 1,
  Blue = 2,
  Teal = 3,
  Purple = 4,
  Yellow = 5,
  Turquoise = 6
}
E.UnrealSceneStyle = {
  Green = 0,
  Red = 1,
  Blue = 2,
  Dark = 3,
  TalentGreen = 4,
  TalentRed = 5,
  TalentBlue = 6
}
E.EHueModifiedMode = {
  Option = 1,
  Slider = 2,
  Board = 3
}
E.EShopItemType = {ItemType = 1, WeaponProfession = 2}
E.EShopType = {
  Shop = 0,
  SeasonShop = 1,
  FishingShop = 2,
  TokenShop = 3,
  HouseShop = 4,
  CompensateShop = 5,
  ActivityShop = 6
}
E.SeasonJumpType = {
  MapFlag = 1,
  MapFunc = 2,
  WorldEvent = 3,
  Function = 4
}
E.ItemTipsViewType = {SkillTagTips = 1, UnderLine = 2}
E.EQueueTipType = {
  FunctionOpen = 1,
  ItemGet = 2,
  FinishSeasonAchievement = 4,
  FashionAndVehicle = 5,
  ResonanceSkillGet = 7,
  ItemShow = 8,
  SelectPack = 9,
  Episode = 10,
  Activities = 11,
  LifeRecipe = 12
}
E.EItemSource = {
  Self = 0,
  Npc = 1,
  ZoneEntity = 2,
  SceneObject = 3
}
E.EInteractiveGroup = {Pivot = 1, PivotProgress = 2}
E.ELookAtScaleType = {
  BodyHeight = 1,
  ShoeHeight = 2,
  ShoeHeightFace = 3
}
E.ECounterType = {
  NormalDungeonAwardCount = 1,
  HeroKeyCount = 2,
  HeroRollCount = 3
}
E.EBpDailyTaskRandom = {Fixed = 1, Random = 2}
E.EBattlePassAwardType = {Free = 1, Payment = 2}
E.EBattlePassPurchaseType = {
  Normal = 1,
  Super = 2,
  Discount = 3
}
E.EBattlePassViewType = {Task = 1, BattlePassCard = 2}
E.QuickJumpType = {
  TraceSceneTarget = 1,
  Function = 2,
  TraceNearestTarget = 4,
  Message = 5,
  GoUnionTarget = 6,
  TraceScenePosition = 7
}
E.TrackType = {
  Point = 1,
  Npc = 2,
  Monster = 3,
  Zone = 4,
  SceneObject = 5,
  Collection = 7,
  Position = 8
}
E.NearTraceTargetType = {
  Npc = 1,
  Zone = 2,
  SceneObject = 3
}
E.PersonalZoneRecordMainSub = {
  Head = 1,
  HeadFrame = 2,
  IDCard = 3
}
E.PersonalZoneMedalMainSub = {Show = 1, Edit = 2}
E.PersonalZoneMedalShowType = {
  Season = 1,
  Collect = 2,
  History = 3
}
E.SeasonCultivateHole = {
  Core = 999,
  Hole1 = 1,
  Hole2 = 2,
  Hole3 = 3,
  Hole4 = 4,
  Hole5 = 5,
  Hole6 = 6
}
E.AlbumOpenSource = {
  Album = 0,
  Union = 1,
  UnionElectronicScreen = 2
}
E.SkillCostType = {
  WeaponSkill = 1001,
  SupportSkill = 1002,
  MysteriesSkill = 1003
}
E.SeasonUnRealBgPath = {
  Scene = "ui/textures/virtual_scene/virtual_scene_bg_7",
  Characters = "ui/textures/virtual_scene/virtual_scene_bg_8"
}
E.ExpressionActionPlayTargetType = {
  None = 0,
  Entity = 1,
  Model = 2
}
E.QuestTaskBtnsSource = {
  Cutscene = 1,
  Talk = 2,
  TalkMode = 3
}
E.ExchangePreItemResult = {
  ExchangePreItemResultNone = 0,
  ExchangePreItemResultSuccess = 1,
  ExchangePreItemResultFail = 2
}
E.AlbumTabType = {
  EAlbumTemporary = 1,
  EAlbumCloud = 2,
  EAlbumUnionTemporary = 3,
  EAlbumUnion = 4
}
E.FightAttrId = {
  Cri = 11110,
  Crit = 11710,
  Haste = 11120,
  HastePct = 11930,
  Luck = 11130,
  LuckyStrikeProb = 11780,
  Versatility = 11150,
  VersatilityPct = 11950,
  Mastery = 11140,
  MasteryPct = 11940,
  Block = 11170,
  BlockPct = 11970
}
E.ReviveType = {BeRevived = 5}
E.CurrencyType = {
  Vitality = 20003,
  Honour = 10006,
  Friendship = 10004,
  Home = 10010
}
E.EDungeonResult = {
  DungeonResultNull = 0,
  DungeonResultSuccess = 1,
  DungeonResultFailed = 2
}
E.EPictureReviewType = {
  EPictureReviewNull = 0,
  EPictureReviewFail = 1,
  EPictureReviewed = 2,
  EPictureReviewing = 3
}
E.SevenDayTargetAwardState = {
  notFinish = 0,
  canGet = 1,
  hasGet = 2,
  notOpen = 3
}
E.UnionActivityType = {UnionHunt = 1, UnionDance = 2}
E.WeeklyHuntMonsterType = {
  Samll = 1,
  Elite = 2,
  Boss = 3
}
E.RichTextContentType = {Text = 1, Image = 2}
E.EExchangeItemType = {
  ExchangeItemTypeNone = 0,
  ExchangeItemTypeShopItem = 1,
  ExchangeItemTypeNoticeShopItem = 2
}
E.EExchangeItemState = {ExchangeItemStateNone = 0, ExchangeItemStatePublic = 1}
E.InteractionBtnType = {ENormal = 1, EProgress = 2}
E.InteractionBtnParentType = {LayoutContent = 1, CollectAll = 2}
E.InteractionProgressCheckType = {OpenUI = 1, InteractionDeActive = 2}
E.InteractionBtnSort = {
  DropItemSort = 1,
  NpcTalkSort = 2,
  DungeonEntrySort = 3,
  FunctionEntrySort = 4,
  OptionSelectSort = 5,
  HeroChallengeDungeonSort = 6,
  HeroNormalDungeonSort = 7,
  CollectionSort = 8,
  CollectionProgressSort = 9,
  PersonEntitySort = 10,
  EntityDeadSort = 11,
  CollectAllSort = 12,
  StaticObjSort = 13
}
E.StepTimeLimitType = {FailEvaluators = 1, TargetTime = 2}
E.AwardPrevDropType = {
  Definitely = 0,
  Probability = 1,
  Multipe = 2
}
E.AwardPrevLimitType = {
  Sex = 1,
  Weapon = 2,
  Lv = 3,
  GS = 4,
  Title = 5,
  Task = 6,
  Action = 7,
  Function = 8,
  Data = 9
}
E.AwardGroupContentType = {Id = 1, Group = 2}
E.TeamQuitType = {
  Quit = 1,
  KickOut = 2,
  MatchUnReady = 3
}
E.VehicleApplyRideResult = {
  ApplyRideResultNone = 0,
  ApplyRideResultAgree = 1,
  ApplyRideResultRefuse = 2,
  ApplyRideResultTimeOut = 3
}
E.ETipsType = {
  ETipsTypeNormal = 0,
  ETipsTypeUseItemLimit = 1,
  ETipsTypeCraftEnergy = 2,
  ETipsTypeGetLifePoint = 3
}
E.MonthlyAwardType = {
  EReward = 1,
  EPrivilege = 2,
  EFixedItem = 3
}
E.MonthlyAwardItemType = {
  MonthAward = 1,
  DayAward = 2,
  MonthLimitAwardId = 3
}
E.FlowPlayStateEnum = {
  WaitNpc = 1,
  Loading = 2,
  Playing = 3,
  Finish = 4
}
E.FlowPlaySourceEnum = {
  TalkPlayFlow = 1,
  AutoPlayFlow = 2,
  OptionPlayFlow = 3,
  OtherPlayFlow = 4
}
E.EPreloadTypeEnum = {
  ETexture = 0,
  EPrefab = 1,
  ETextAsset = 2
}
E.MallCouponsEffectiveType = {MallTableId = 1, MallItemTableId = 2}
E.MallCouponsType = {Discount = 1, Deduction = 2}
E.ELifeProfession = {
  Collection = 101,
  Cook = 201,
  Chemistry = 202,
  Cast = 203
}
E.ELifeProfessionMainType = {
  Collection = 1,
  Manufacture = 2,
  Cook = 3
}
E.EExchangeWithDrawType = {
  ExchangeWithDrawTypeNone = 0,
  ExchangeWithDrawTypePart = 1,
  ExchangeWithDrawTypeAll = 2
}
E.QuestLimitState = {
  None = 0,
  NotMet = 1,
  Met = 2
}
E.EQuestLimitEnum = {
  itemCount = 2,
  date = 3,
  roleLv = 4,
  questStep = 5
}
E.EQuestLimitType = {
  RoleLv = 1,
  ItemCount = 11,
  QuestStep = 21,
  Timer = 18,
  Date = 80
}
E.EChatStickersType = {
  EStandardEmoji = 1,
  EEmoji = 2,
  EPicture = 3,
  EHeadPicture = 4,
  EQuickMessage = 5
}
E.RoleLevelPageIndex = {RoleLevel = 1, Proficiency = 2}
E.MonthlyCardTipsClicked = {
  None = 0,
  CanShow = 1,
  Showed = 2
}
E.MonthCardPrivilegeLabType = {
  TradingRing = 4,
  NormalWarehouseCount = 5,
  HomeWarehouseCount = 6
}
E.WarehouseType = {Normal = 1, House = 2}
E.WarehouseGroupId = {Normal = 101, Precious = 201}
E.ProductType = {
  NormalItem = 1,
  MonthlyCard = 2,
  MonthlyCardTencent = 998
}
E.EnchantType = {
  Common = 1,
  Middle = 2,
  Advanced = 3
}
E.WheelViewType = {EEditor = 1, EUse = 2}
E.ExpressionRightSubType = {ECamerasysRightSub = 1, EExpressionRightSub = 2}
E.ExpressionSettingType = {
  CommonAction = 1,
  LoopAction = 2,
  MultAction = 3,
  Emoji = 4,
  QuickMessage = 5,
  AllAction = 6,
  UseItem = 7,
  Transporter = 8
}
E.CameraPlayerLookAtType = {
  Default = 1,
  Camera = 2,
  Free = 3,
  Lock = 4
}
E.CameraPlayerLookAtShowType = {
  Default = 1,
  Camera = 2,
  Free = 3
}
E.ItemTracePosType = {Top = 1, Right = 2}
E.CameraCharacterRelationship = {
  Union = 1,
  Friend = 2,
  Team = 3
}
E.AssistType = {
  None = 0,
  AssistReward = 1,
  AssistLimit = 2
}
E.CollectionHistoryType = {
  Fashion = 1,
  Weapon = 2,
  Ride = 3
}
E.SysDevelopTreeActiveType = {Start = 0, StartAndEnd = 1}
E.CommonRechargePopViewType = {Monthly = 1, Item = 2}
E.EIgnoreMaskSource = {
  EDefault = 0,
  EScene = 1,
  ELevel = 2,
  EAttr = 3,
  EFlow = 4,
  EGlide = 5,
  EMultActionAttr = 6,
  EFlowActionControlCamera = 7,
  EStageTransfer = 8,
  EBattleShowCameraOffset = 9,
  EBattleShowInputMask = 10,
  ECutScene = 11,
  ECutSceneTalk = 12,
  EUIView = 13,
  EUITalk = 14,
  EUIPivot = 15,
  EUIMultiAction = 16,
  EGm = 17,
  Fishing = 18,
  QuestEpisode = 19,
  EInteraction = 20,
  EBigSkill = 21,
  EEPFlow = 22,
  EResurrection = 23,
  EPayWebView = 24,
  EUIMask = 25
}
E.ModelDisplayType = {
  Ui = 0,
  Lod0 = 1,
  Lod1 = 2,
  Lod2 = 3,
  Lod3 = 4,
  Culling = 5,
  Count = 6
}
E.PrivilegeShowType = {
  Item = 1,
  Experience = 2,
  lv = 3,
  Count = 4
}
E.RedDotStyleType = {
  Normal = 0,
  Image = 1,
  Number = 2,
  CEffect = 3,
  UEffect = 4
}
E.EShopViewType = {
  ECommon = 1,
  EGift = 2,
  ERewardCard = 3,
  EFashion = 4,
  EMysterious = 5,
  EPay = 6
}
E.EShopGoodsType = {
  ENormal = 0,
  EFashion = 1,
  EMount = 2,
  EWeapon = 3
}
E.GoToFunc = {
  team = 1,
  chatSet = 2,
  union = 3
}
E.EChatRightChannelBtnFunctionId = {
  EExpand = 102128,
  EPop = 102129,
  ESetting = 102130,
  ERotate = 102131
}
E.FriendAddSubShowType = {ESuggestion = 1, ESearch = 2}
E.FriendLoopItemType = {
  EPrivateChat = 1,
  EFriendItem = 2,
  EFriendGroup = 3,
  EFriendGroupName = 4
}
E.FriendMainPCRightViewType = {
  Empty = 1,
  Message = 2,
  FriendApply = 3
}
E.ExpressionTabType = {
  History = 0,
  Collection = 1,
  NormalAction = 2,
  LoopAction = 3,
  Emote = 4,
  MulAction = 5,
  Fishing = 6
}
E.CameraSystemFunctionType = {
  Camera = 101,
  Action = 102,
  Decorations = 103,
  Setting = 104
}
E.CameraSystemSubFunctionType = {
  None = 0,
  CommonAction = 1001,
  LoopAction = 1002,
  Emote = 1003,
  LookAt = 1004,
  Frame = 1005,
  Sticker = 1006,
  Text = 1007,
  Camera = 1008,
  ShotSet = 1009,
  Filter = 1010,
  Show = 1011,
  Scheme = 1012,
  UnionBg = 1013,
  Fishing = 1014
}
E.CameraSystemPlatform = {
  General = 1,
  Pc = 2,
  Mobile = 3
}
E.CameraPcSliderEnum = {
  Fov = 1,
  CameraTilt = 2,
  Horizontal = 3,
  Vertical = 4,
  Aperture = 5,
  Near = 6,
  Far = 7,
  Focus = 8,
  StickerAlpha = 9,
  TextSize = 10,
  TextHue = 11,
  TextAlpha = 12,
  Brightness = 13,
  Saturation = 14,
  Contrast = 15,
  DayTime = 16,
  PlayerRotation = 17
}
E.DungeonMultiAwardItemId = 1040144
E.InputTriggerViewActionType = {
  None = 0,
  CloseView = 1,
  NavigationUp = 2,
  NavigationDown = 3,
  NavigationLeft = 4,
  NavigationRight = 5,
  Custom = 99
}
E.HouseSetOptionType = {
  Set = 1,
  Member = 2,
  Apply = 3
}
E.HouseMemberState = {
  Normal = 1,
  Quit = 2,
  InitiativeQuit = 3,
  Transfer = 4
}
E.HomeEnvLightType = {Static = 1, Dynamic = 2}
E.HomeFarmActionType = {
  Seed = 1,
  Pollination = 2,
  Manure = 3,
  Watering = 4,
  Collect = 5,
  Harvest = 6
}
E.HomeEnvMode = {EnvPrefab = 0, EnvColor = 1}
E.EHomeEditType = {
  All = 0,
  AllNoOverlying = 1,
  NoOverlyingXZRotate = 2
}
E.EWorldChannelState = {
  Low = 1,
  Hot = 2,
  Height = 3
}
E.ESeasonShopRefreshType = {
  None = 0,
  Season = 1,
  Daily = 2,
  Month = 3,
  Week = 4,
  Compensate = 5,
  Permanent = 999
}
E.NodeState = {
  Normal = 0,
  Highlighted = 1,
  Pressed = 2,
  Disabled = 3
}
E.ActionAccessory = {
  Normal = 0,
  Fish = 1,
  Pendant = 2
}
E.BlockSteerType = {ScreenSaver = 1, Gamepad = 2}
E.BlockChatType = {HomeEditor = 1}
E.ShopDeliverWayType = {
  EDeliverWayType = 1,
  EDeliverWayParam = 2,
  EDeliverWayTipsParam = 3
}
E.MainViewLeftTrackUIMark = {
  Task = 1,
  Bubble = 2,
  Dps = 3
}
E.EDeliverWayType = {EBack = 0, EMail = 1}
E.ManufactureProductType = {
  All = 0,
  Material = 1,
  ConsumeItem = 2,
  Equip = 3,
  House = 4
}
E.MatchActivityType = {CommonActivity = 1, WorldBoseActivity = 2}
E.ESocialApplySettingType = {
  EAllApply = 0,
  EFriendApply = 1,
  ENoneApply = 2
}
E.ESocialApplyType = {
  ETeamApply = 1,
  ECarpoolApply = 2,
  EInteractiveApply = 3
}
E.SeasonActFuncType = {Recommend = 1, Theme = 2}
E.MenuBannerType = {FuncPreview = 1, Theme = 2}
E.ThemeActivitySubType = {SeasonActivity = 1, PandoraActivity = 2}
E.ThemeActivityFuncType = {Sign = 2, Shop = 3}
E.ThemeActivityFunctionId = {
  Sign1 = 820005,
  Sign2 = 820009,
  Entrance = 820001,
  Celebration = 820002
}
E.ThemeActivityRedDot = {
  [E.ThemeActivityFunctionId.Sign1] = 82000004,
  [E.ThemeActivityFunctionId.Sign2] = 82000008
}
E.SeasonActivityTimeStage = {
  NotOpen = 0,
  Open = 1,
  Over = 2
}
E.RecommendFightValueType = {
  Level = E.FunctionID.RoleLevel,
  Talent = E.FunctionID.Talent,
  Equip = E.FunctionID.EquipChange,
  Skill = E.FunctionID.WeaponSkill,
  Mod = E.FunctionID.Mod,
  Season = E.FunctionID.SeasonCultivate
}
E.ETeamVoiceState = {
  SpeakerVoice = 0,
  MicVoice = 1,
  CloseVoice = 2,
  ShieldVoice = 3,
  SpeakingVoice = 4
}
E.ETeamVoiceSpeakState = {
  NotSpeak = 0,
  Speaking = 1,
  EndSpeak = 2
}
E.DpsDpdTypeList = {
  Damage = 1,
  Cure = 2,
  TakeDamage = 3,
  DamageSecond = 4,
  CureSecond = 5
}
E.SignActivityType = {ThemeActivity1 = 1, ThemeActivity2 = 2}
E.ESceneType = {
  Unknown = 0,
  Static = 1,
  Dynamic = 2
}
E.MonthShowLang = {
  [1] = "Jan",
  [2] = "Feb",
  [3] = "Mar",
  [4] = "Apr",
  [5] = "May",
  [6] = "Jun",
  [7] = "Jul",
  [8] = "Aug",
  [9] = "Sept",
  [10] = "Oct",
  [11] = "Nov",
  [12] = "Dec"
}
E.TimeFormatType = {
  YMDHMS = 1,
  YMD = 2,
  HMS = 3,
  MD = 4
}
E.AwardCountType = {RaidDungeon = 30}
E.LeisureActivityState = {
  TodayOpenAndCurOpen = 0,
  TodayOpen = 1,
  TodayNotOpen = 2
}
E.SeasonPreviewType = {Single = 1, Double = 2}
E.InputDirectionType = {
  None = 0,
  Front = 1,
  Back = 2,
  Left = 3,
  Right = 4
}
E.HttpPictureDownFoldType = {Head = "head", HalfBody = "halfBody"}
E.CameraSysInputKey = {
  ESC = 108,
  Shot = 162,
  Hide = 161,
  Translation = 160,
  Move = 159,
  LeftPanel = 163,
  rightPanel = 164
}
return E
