E = {}
E.RpcChannelType = {Gateway = 0, World = 1}
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
  EquipDecomposeHighQualityTips = "EquipDecomposeHighQualityTips",
  EquipEquipDecomposeTips = "EquipEquipDecomposeTips",
  EquipRecastCanTradeTips = "EquipRecastCanTradeTips",
  EquipRecastingManytimesTips = "EquipRecastingManytimesTips",
  EquipRecastingManyTimesTips = "EquipRecastingManyTimesTips",
  EquipRecastingHighPerfectTips = "EquipRecastingHighPerfectTips",
  EquipRecastingBindingTips = "EquipRecastingBindingTips",
  StallPublicityDialogTips = "StallPublicityDialogTips",
  StallNormalDialogTips = "StallNormalDialogTips",
  ItemRecycleTips = "ItemRecycleTips"
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
E.MapFlagTypeId = {
  TransferDoor = 103,
  CustomTag1 = 301,
  CustomTag2 = 302,
  CustomTag3 = 504
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
  UnActive = 3
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
  TipsGreen = "#CEE98D",
  JobActive = "#AFE716",
  JobNotActive = "#A2A2A2",
  DarkBrown = "#774E4A",
  DarkGreen = "#4C774A",
  DarkPruple = "#675397",
  DarkBlue = "#1B8BA5"
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
  FashionAndVehicle = 4
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
  UnionDeviceLock = "UnionDeviceLock"
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
  None = 0,
  CommonAction = 1,
  LoopAction = 2,
  MultAction = 3,
  Emote = 4
}
E.ExpressionTogType = {
  Action = 1,
  Emo = 2,
  Double = 3,
  Collection = 4,
  Customization = 5
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
  UnionBg = 14
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
E.CamerasysShowEntityType = {
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
  OtherPlayer = 11
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
  Earrings = 721,
  Necklace = 722,
  Ring = 723
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
  Tail = 14
}
E.FashionTipsReason = {UnlockedWear = 1, UnlockedColor = 2}
E.EquipItemSortType = {
  Quality = 1,
  GS = 2,
  Lv = 3,
  QualityConfig = 4,
  QualityAndGS = 5
}
E.ResonanceItemSortType = {Quality = 1}
E.RecycleItemSortType = {Quality = 1, Count = 2}
E.EquipFuncViewType = {
  Weapon = 0,
  Equip = 1,
  Decompose = 6,
  Recast = 7
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
  WorldPosition = 3
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
  Env = 9
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
E.QuestType = {Main = 1, WorldQuest = 16}
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
  SpecialItem = 102,
  CookFoodType = 109,
  RecycleItem = 110
}
E.ItemFunctionType = {
  Buff = 1,
  Gift = 2,
  Hero = 3,
  Function = 101
}
E.ResonanceSkillItemType = {Prop = 300, Material = 301}
E.FishingItemType = {FishingRod = 1103, FishBait = 1102}
E.TeamInviteType = {
  Friend = 1,
  Guild = 2,
  Near = 3
}
E.InvitationTipsType = {
  Invite = 1,
  Request = 2,
  Leader = 3,
  Transfer = 4,
  MultActionInvite = 5,
  Branching = 6,
  WorldQuest = 7,
  FriendApply = 8,
  UnionHunt = 9,
  Warehouse = 10,
  VehicleApply = 11,
  VehicleInvite = 12,
  UnionWarDance = 13
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
  Backpack = 3
}
E.FunctionID = {
  None = 0,
  MiniMap = 100301,
  Map = 100302,
  Synthesis = 100220,
  Shredder = 100241,
  Fashion = 101101,
  MainFuncMenu = 200000,
  Memory = 300301,
  RoleResonance = 103000,
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
  MonsterExplore = 100804,
  MainChat = 102100,
  LandScapeMode = 333333,
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
  HeroDungeon = 300200,
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
  Mod = 104210,
  ModIntensify = 104211,
  ModDecompose = 104212,
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
  Shop = 800800,
  Cook = 600901,
  Questionnaire = 900101,
  HeroNormalDungeon = 30020,
  HeroDungeonDiNa = 300201,
  HeroChallengeDungeon = 300202,
  HeroDungeonJuTaYiJi = 300203,
  HeroChallengeJuTaYiJi = 300204,
  HeroDungeonJuLongZhuaHen = 300207,
  HeroChallengeJuLongZhuaHen = 300208,
  HeroDungeonKaNiMan = 300209,
  HeroChallengeKaNiMan = 300210,
  EntranceDiNa = 300100,
  EntranceJuTaYiJi = 300101,
  UnionTask = 500122,
  ExploreMonsterElite = 100805,
  ExploreMonsterBoss = 100806,
  Home = 102501,
  Trade = 800400,
  ExitDungeon = 100401,
  WorldBoss = 800902,
  Fishing = 300000,
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
  UnionHunt = 500151,
  UnionWarDance = 900200
}
E.BackpackFuncId = {
  Backpack = 100101,
  ItemBp = 100103,
  EquipBp = 100104,
  CardBp = 100105,
  ResonanceSkill = 100107
}
E.ResonanceFuncId = {Decompose = 200505, Create = 200504}
E.SetFuncId = {
  Setting = 100201,
  SettingControl = 100202,
  SettingBasic = 100203,
  SettingFrame = 100204,
  SettingAccount = 100205,
  SettingOther = 100206,
  SettingExpend = 100207,
  SettingKey = 100208,
  SettingLanguage = 100209
}
E.EquipFuncId = {
  Equip = 100701,
  EquipFunc = 100702,
  EquipDecompose = 100707,
  EquipRecast = 100708,
  EquipRefine = 100709
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
  Hunt = 500108
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
  InviteRide = 102802
}
E.ExchangeFuncId = {Exchange = 100230, UnionExchange = 100233}
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
  WeeklyHuntNext = 21
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
  KeyHint = 2001,
  EffSelf = 3001,
  EffEnemy = 3002,
  EffTeammate = 3003,
  EffOther = 3004,
  WeaponDisplay = 4001,
  PlayerHeadInformation = 4002,
  OtherPlayerHeadInformation = 4003,
  NPCPlayerHeadInformation = 4004
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
  CacheEffectPhoto = 0,
  CacheOriPhoto = 1,
  CacheThumbPhoto = 2,
  CacheHeadPhoto = 3,
  CacheHalfPhoto = 4
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
  FreeLook = 1,
  SelfPhoto = 2,
  VR = 3,
  UnionTakePhoto = 4
}
E.UnionCameraSubType = {Body = 0, Head = 1}
E.CameraTargetStage = {
  [E.CameraState.Default] = 1,
  [E.CameraState.AR] = 2,
  [E.CameraState.SelfPhoto] = 3
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
  Team = 5
}
E.MapSubViewType = {
  Info = 1,
  NormalQuest = 2,
  EventQuest = 3,
  Setting = 4,
  Custom = 5,
  PivotReward = 6,
  PivotProgress = 7,
  DungeonEnter = 8,
  DungeonAdd = 9
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
  DungeonGreenTips = 12
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
  SupportSkill = 3
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
E.PlanetmemoryType = {
  None = 0,
  Common = 1,
  Cream = 2,
  Boss = 3,
  Special = 4,
  Incident = 5
}
E.PlanetmemoryState = {
  Close = 0,
  Open = 1,
  Pass = 2
}
E.PlanetmemoryFogState = {Unlocked = 0, NotYetUnlocked = 1}
E.PlanetMemoryDeadViewBtnType = {LeaveCopy = 0, Restart = 1}
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
  WeeklyTower = 16
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
E.PlanetMemoryTipsType = {Affix = 0, Monster = 1}
E.PCKeyHint = {
  LockTarget = "KeyHint23",
  ShowMouse = "KeyHint116",
  RunWalkSwitch = "KeyHint6",
  Dash = "KeyHint8",
  Jump = "KeyHint7"
}
E.SceneObjType = {
  Normal = 0,
  Pivot = 1,
  PivotPort = 2,
  Resonance = 3,
  Transfer = 4,
  WorldQuest = 5
}
E.RedType = {
  TeamApplyMain = 1,
  TeamApplySystem = 2,
  TeamApplyButton = 3,
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
  EnvEnter1 = 25,
  EnvEnter2 = 26,
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
  HelpsysRed = 103001,
  HelpsysTabRed = 1030010001,
  HelpsysItemRed = 103001002,
  Personalzone = 1501,
  PersonalzoneHead = 1502,
  PersonalzoneHeadFrame = 1503,
  PersonalzoneCard = 1505,
  PersonalzoneMedal = 1506,
  PersonalzoneTitle = 1504,
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
  WeeklyHuntTarget = 1601,
  WeeklyHuntAward = 1602
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
  MedalEditItemIndex = 18
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
E.ItemType = {ActionExpression = 107, Vehicle = 1201}
E.EBuffPriority = {
  NotShow = 0,
  Secondly = 1,
  Highest = 2,
  Notice = 3
}
E.EBuffType = {
  Debuff = 0,
  Gain = 1,
  GainRecovery = 2,
  Item = 3
}
E.ESystemCameraId = {WeaponRole = 4000}
E.MainViewHideStyle = {
  None = 0,
  Left = 1,
  Right = 2,
  Top = 3,
  Bottom = 4
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
E.EShopType = {Shop = 0, SeasonShop = 1}
E.EShopShowType = {Shop = 0, FishingShop = 1}
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
  Episode = 10
}
E.EItemSource = {
  Self = 0,
  Npc = 1,
  ZoneEntity = 2,
  SceneObject = 3
}
E.EDialogViewDataType = {System = 1, Game = 2}
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
  GoUnionTarget = 6
}
E.TrackType = {
  Point = 1,
  Npc = 2,
  Monster = 3,
  Zone = 4,
  SceneObject = 5
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
  Personal = 1,
  Union = 2,
  UnionElectronicScreen = 3
}
E.SkillCostType = {
  WeaponSkill = 1001,
  SupportSkill = 1002,
  MysteriesSkill = 1003
}
E.SeasonUnRealBgPath = {
  Scene = "ui/textures/virtual_scene/virtual scene_bg_7",
  Characters = "ui/textures/virtual_scene/virtual scene_bg_8"
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
  MasteryPct = 11940
}
E.ReviveType = {BeRevived = 5}
E.CurrencyType = {Vitality = 20003, Honour = 10006}
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
E.MainUiArea = {
  TopLeft = 1,
  BottomLeft = 2,
  UpperRight = 3,
  BottomRight = 4
}
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
E.ETipsType = {ETipsTypeNormal = 0, ETipsTypeUseItemLimit = 1}
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
return E
