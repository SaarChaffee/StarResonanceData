local read_onlyHelper = require("utility.readonly_helper")
local Global = {
  FemaleModelId = 100004,
  MaleModelId = 100001,
  RunVelocity = 4,
  WalkVelocity = 1.75,
  TurnVelocity = 720,
  SwimVelocity = 3,
  RushTime = 0.4,
  RushVelocity = 8,
  DashVelocity = 6,
  DashHoldTime = 0.3,
  DashEndTime = 1,
  Gravity = -25,
  JumpId = 1,
  JumpUpControllableHeight = 1,
  JumpDownControllableHeight = 0.5,
  MoveSlopeLimit = 45,
  MoveStepOffset = 0.25,
  ShortSelectRange = 6,
  LongSelectRange = 10,
  SelectOffRange = 2,
  SelectRangeDiff = 10,
  ServerAddr = "49.234.244.162:9999",
  BattleOffTime = 10,
  DefaultLayerCullingDistance = {
    {-1, 1500},
    {28, 20000}
  },
  CollideMaxDistance = 5,
  SkyLongPressTime = 0.3,
  SkillStateCacheTime = 0.5,
  DeadDissolutionTime = 1.5,
  WeatherStartTime = "2025-04-01 00:00:00",
  MonsterResetTime = 3000,
  DummyId = 4,
  BulletId = 3,
  NpcLookAtDistance = 4,
  NpcLookAtAngle = Vector2.New(60, 30),
  LargeDropBloodPercent = 0.3,
  TeleportWaitTime = 1500,
  ShinVelocity = 1,
  ShinStepDistance = 0.5,
  IsShowSkillTestZone = false,
  PushSpeed = {3, 7},
  PushValidStates = {
    0,
    3,
    4
  },
  ResidualBloodPer = 15,
  SkillDamageRangeMultiplier = 1,
  SkillDamageRangeOffsetY = -0.3,
  ChangeMapDelay = 2,
  GMTableGroup = {
    [1] = "GMGropName1",
    [2] = "GMGropName2",
    [3] = "GMGropName3",
    [4] = "GMGropName4",
    [5] = "GMGropName5",
    [6] = "GMGropName6",
    [7] = "GMGropName7",
    [8] = "GMGropName8",
    [9] = "GMGropName9",
    [10] = "GMGropName10",
    [11] = "GMGropName11"
  },
  StiffMaxTime = 30000,
  BornMap = 8,
  PlayerFOVToNpc = 90,
  ShowNpcHUD = 8,
  HideNpcHUDAfterShow = 11,
  RecoverInterval = 1000,
  RecoverTime = 1000,
  UiEmoteTabsShow = {
    {
      "camera_menu_12",
      "0",
      "cameraMenu12"
    },
    {
      "camera_menu_1",
      "1",
      "cameraMenu1"
    },
    {
      "camera_menu_2",
      "2",
      "cameraMenu2"
    },
    {
      "camera_interaction_btn_ash",
      "3",
      "cameraInteraction"
    },
    {
      "camera_menu_3",
      "4",
      "cameraMenu3"
    },
    {
      "camera_menu_21",
      "5",
      "cameraMenu4"
    }
  },
  FacialDefaultDurationTime = 5000,
  FacialMaxHistoricalNum = 6,
  FacialMaxCommonNum = 20,
  CommonAudioBanks = {
    "Function",
    "BGM",
    "ui",
    "cutscene",
    "player_base",
    "player_skill",
    "scene_obj",
    "npc_vo",
    "Wpn_ScytheKatana",
    "Wpn_MagicWand",
    "Wpn_WindKnight",
    "Wpn_MagicHoop",
    "Wpn_GuardBlade",
    "Vo_Story",
    "Common_Effects",
    "Common_Impacts",
    "Wpn_Tribebow",
    "Wpn_ShieldKnight",
    "Wpn_Guitar",
    "Amb_3D",
    "Vo_Player_Battle",
    "Vo_Player_Action"
  },
  BodyPartHurtStateDuration = 200,
  EnduranceRecover = 20,
  RushEndurance = 25,
  DashEndurance = 8,
  ShinMoveEndurance = 5,
  ShinJumpEndurance = 20,
  SwimEndurance = 2,
  FastSwimEndurance = 6,
  EnduranceRecoverCD = 2,
  Endurance = 100,
  TachiEndurance = 30,
  EquipDurabilityDeathPunishment = {
    {0, 0},
    {1, 0},
    {2, 0},
    {3, 0},
    {4, 0},
    {5, 0}
  },
  EquipDurabilityLoss = {
    {0, 99999},
    {1, 99999},
    {2, 99999},
    {3, 99999},
    {4, 99999},
    {5, 99999}
  },
  EquipDurabilityFixCost = {
    {
      0,
      10001,
      1
    },
    {
      2,
      10001,
      1
    },
    {
      3,
      10001,
      2
    },
    {
      4,
      10001,
      3
    },
    {
      5,
      10001,
      1
    }
  },
  EquipDecompose = {
    {
      0,
      200,
      10008,
      2
    },
    {
      0,
      201,
      10008,
      2
    },
    {
      0,
      202,
      10008,
      2
    },
    {
      0,
      203,
      10008,
      2
    },
    {
      0,
      204,
      10008,
      2
    },
    {
      0,
      205,
      10008,
      2
    },
    {
      0,
      206,
      10008,
      2
    },
    {
      0,
      207,
      10008,
      2
    },
    {
      0,
      208,
      10008,
      2
    },
    {
      0,
      209,
      10008,
      2
    },
    {
      0,
      210,
      10008,
      2
    },
    {
      1,
      200,
      10008,
      2
    },
    {
      1,
      201,
      10008,
      2
    },
    {
      1,
      202,
      10008,
      2
    },
    {
      1,
      203,
      10008,
      2
    },
    {
      1,
      204,
      10008,
      2
    },
    {
      1,
      205,
      10008,
      2
    },
    {
      1,
      206,
      10008,
      2
    },
    {
      1,
      207,
      10008,
      2
    },
    {
      1,
      208,
      10008,
      2
    },
    {
      1,
      209,
      10008,
      2
    },
    {
      1,
      210,
      10008,
      2
    },
    {
      2,
      200,
      10008,
      5
    },
    {
      2,
      201,
      10008,
      5
    },
    {
      2,
      202,
      10008,
      5
    },
    {
      2,
      203,
      10008,
      5
    },
    {
      2,
      204,
      10008,
      5
    },
    {
      2,
      205,
      10008,
      5
    },
    {
      2,
      206,
      10008,
      5
    },
    {
      2,
      207,
      10008,
      5
    },
    {
      2,
      208,
      10008,
      5
    },
    {
      2,
      209,
      10008,
      5
    },
    {
      2,
      210,
      10008,
      5
    },
    {
      3,
      200,
      1070008,
      10
    },
    {
      3,
      201,
      1070008,
      5
    },
    {
      3,
      202,
      1070008,
      5
    },
    {
      3,
      203,
      1070008,
      5
    },
    {
      3,
      204,
      1070008,
      5
    },
    {
      3,
      205,
      1070008,
      5
    },
    {
      3,
      206,
      1070008,
      5
    },
    {
      3,
      207,
      1070008,
      5
    },
    {
      3,
      208,
      1070008,
      5
    },
    {
      3,
      209,
      1070008,
      5
    },
    {
      3,
      210,
      1070008,
      5
    },
    {
      4,
      200,
      1070008,
      10
    },
    {
      4,
      201,
      1070008,
      10
    },
    {
      4,
      202,
      1070008,
      10
    },
    {
      4,
      203,
      1070008,
      10
    },
    {
      4,
      204,
      1070008,
      10
    },
    {
      4,
      205,
      1070008,
      10
    },
    {
      4,
      206,
      1070008,
      10
    },
    {
      4,
      207,
      1070008,
      10
    },
    {
      4,
      208,
      1070008,
      10
    },
    {
      4,
      209,
      1070008,
      10
    },
    {
      4,
      210,
      1070008,
      10
    }
  },
  EquipExtraGs = 50,
  EquipExtraGsCost = {
    {
      201,
      10008,
      2
    },
    {
      202,
      10008,
      2
    },
    {
      203,
      10008,
      2
    },
    {
      204,
      10008,
      2
    },
    {
      205,
      10008,
      2
    },
    {
      206,
      10008,
      2
    },
    {
      207,
      10008,
      1
    },
    {
      208,
      10008,
      2
    }
  },
  EquipStyleEffectColor = {
    {0, 4999},
    {5000, 8999},
    {9000, 10000}
  },
  EquipLibType = {
    [0] = "EquipLib0",
    [101] = "EquipLib101",
    [201] = "EquipLib201",
    [202] = "EquipLib202",
    [203] = "EquipLib203",
    [204] = "EquipLib204",
    [205] = "EquipLib205",
    [301] = "EquipLib301",
    [1001] = "EquipLib1001",
    [1002] = "EquipLib1002",
    [1003] = "EquipLib1003"
  },
  Photograph_CameraVFOVRange = {
    {
      12.9,
      67.3,
      42
    },
    {12.9, 67.3}
  },
  Photograph_CameraHorizontalRange = {
    {
      -5,
      5,
      0
    },
    {0, 100}
  },
  Photograph_CameraVerticalRange = {
    {
      -5,
      5,
      0
    },
    {0, 100}
  },
  Photograph_CameraAngleRange = {
    {
      -180,
      180,
      0
    },
    {-180, 180}
  },
  Photograph_SelfCameraVFOVRange = {
    {
      34.1,
      67.3,
      43
    },
    {34.1, 67.3}
  },
  Photograph_SelfCameraHorizontalRange = {
    {
      -0.3,
      0.05,
      -0.09
    },
    {0, 100}
  },
  Photograph_SelfCameraVerticalRange = {
    {
      -1,
      1,
      0.14
    },
    {0, 100}
  },
  Photograph_SelfCameraOffsetValue = Vector3.New(-0.23, -0.05, -0.08),
  Photograph_ARCameraVFOVRange = {
    {
      12.9,
      67.3,
      42
    },
    {12.9, 67.3}
  },
  Photograph_DOFApertureFactorRange = {
    {
      1,
      20,
      10
    },
    {1, 20}
  },
  Photograph_DOFFocalLengthRange = {
    {
      1,
      10,
      1
    },
    {1, 1000}
  },
  Photograph_ScreenBrightnessRange = {
    {
      -0.4,
      0.4,
      0
    },
    {0, 100}
  },
  Photograph_ScreenContrastRange = {
    {
      -5,
      5,
      0
    },
    {0, 100}
  },
  Photograph_ScreenSaturationRange = {
    {
      -100,
      30,
      0
    },
    {0, 100}
  },
  Photograph_FontSizeRange = {
    {
      24,
      120,
      48
    },
    {24, 120}
  },
  Photograph_DecorateScaleRange = {
    {
      0.25,
      3,
      0.5
    },
    {0.25, 3}
  },
  Photograph_TextMaxLength = 100,
  Photograph_DecorationsAddLimit = 100,
  Photograph_DecorationsOfTextAddLimit = 1,
  PhotoAlbum_MaxAlbumNum = 10,
  PhotoAlbum_MaxAlbumNameLength = 16,
  PhotoAlbum_MaxCloudPhotoNum = 50,
  PhotoAlbum_MaxTempPhotoNum = 100,
  PhotoAlbum_TempPhotoDelTime = 7,
  PhotoAlbum_MaxUploadPhotoSize = 10240,
  PhotoAlbum_MaxLengthRS = 102400,
  PhotoAlbum_AlbumThumbnailMaxSize = 100,
  RoleEditorShowAction = {
    {
      19,
      0,
      0,
      0
    },
    {
      20,
      0,
      1,
      0
    },
    {
      21,
      0,
      1,
      0
    },
    {
      22,
      0,
      1,
      0
    },
    {
      23,
      0,
      1,
      0
    },
    {}
  },
  RoleEditorShowFacial = {
    {
      30,
      30,
      0,
      29,
      330,
      27
    },
    {
      90,
      27,
      15,
      30,
      210,
      30
    },
    {
      30,
      29,
      0,
      27,
      330,
      27
    }
  },
  RoleEditorDefaultColor = {
    {
      2,
      25,
      65,
      85
    },
    {
      1,
      210,
      19,
      12
    },
    {
      1,
      0,
      0,
      8
    },
    {
      1,
      0,
      0,
      8
    },
    {
      1,
      7,
      66,
      30
    },
    {
      3,
      5,
      75,
      40
    }
  },
  EyeBallMainColor = {
    4,
    214,
    80,
    10
  },
  EyeBallBaseColor = {
    {
      4,
      189,
      75,
      40
    },
    {
      4,
      217,
      70,
      60
    },
    {
      4,
      208,
      75,
      40
    }
  },
  BlinkEyeLastTime = 0.1,
  EnergyDefaultMAX = 100,
  EnergyAddMax = {
    {
      110,
      10002,
      100
    },
    {
      120,
      10002,
      200
    },
    {
      130,
      10003,
      100
    },
    {
      150,
      10003,
      200
    }
  },
  EnergyMAX = 150,
  EnergyItemID = 20001,
  HideAfterShow = 2,
  TeamSendNum = 200,
  MatchTime = 300,
  TeamNearlyInfoCount = 50,
  TeamAFKCD = 300,
  TeamInviteCD = 10,
  TeamInviteLastTime = 15,
  TeamApplyCaptainLastTime = 10,
  TeamApplyCaptainCD = 60,
  TeamDutyMatchDelayTime = 20,
  TeamApplyCD = 60,
  TeamSortTimeM = 300,
  TeamSortTimeM1 = 300,
  TeamSortTimeM2 = 300,
  TeamApplyShowNum = 10,
  TeamApplyShowNumMax = 30,
  TeamApplyRefreshCD = 30,
  TeamRefreshNewCD = 10,
  TeamApplyActivityLastTime = 30,
  TeamMatchTipsTime = 30,
  TeamInviteMaxNum = 5,
  TeamApplyMaxNum = 6,
  TeamInputDescMax = 20,
  MaxComboCountDecayTime = 3,
  ItemDropRadius = 0,
  ItemDropOwnershipTime = 10,
  ItemDropDisappearTime = 20,
  ItemPickUpRadius = 5,
  ItemDropTime = 0,
  ItemTextColor = {
    [0] = "White",
    [1] = "Green",
    [2] = "Blue",
    [3] = "Purple",
    [4] = "Yellow",
    [5] = "Red"
  },
  BreakStandupTime = 1,
  BattleMark = 3,
  YDirPowerRatio = 0.5,
  BulletUpClimbHeight = 0.1,
  BulletDownClimbHeight = 0.25,
  tempFlowOffset = 3,
  ModPlanNum = {3, 8},
  ModPlanCost = {
    {
      4,
      10002,
      100
    },
    {
      5,
      10002,
      200
    },
    {
      6,
      10003,
      100
    },
    {
      7,
      10003,
      150
    },
    {
      8,
      10003,
      200
    }
  },
  FlowDropSpeed = 2.5,
  FlowForwardSpeed = 8,
  FlowRotateSpeed = 180,
  FlowAllowHeight = 0.5,
  GlideParamUp = 5,
  GlideParamAtmo = 0,
  GlideParamBord = 100,
  GlideParamAtmoV = 2,
  GlideParamFlow = 21,
  GlideParamVHorMin = 10,
  GlideParamVMax = 100,
  GlideParamMinAngle = -90,
  GlideParamMaxAngle = 30,
  GlideParamDefAngle = 10,
  GlideParamVerRotSpeed = 64,
  GlideParamHorRotSpeed = 48,
  GlideParamAehAtmo = 0.04,
  GlideParamVeh = 35,
  GlideParamAevAtmo = 0.14,
  GlideParamVev = 45,
  GlideParamHorizonStop = 0.3,
  GlideAllowHeight = 3,
  GlideEffectVelocity = 25,
  NormalHeroDungeonAward = 400220,
  NormalHeroAwardLimitTime = 50,
  VictoryAction = {
    9002,
    9003,
    9011
  },
  VictoryToTeamTime = {10, 15},
  LikedAction = {
    {2, 9002},
    {4, 9003}
  },
  HudSize = {
    {
      0,
      1999,
      1
    },
    {
      2000,
      4999,
      1.3
    },
    {
      5000,
      20000,
      1.6
    }
  },
  ReviveRadius = 5,
  BulletMaxPenetrate = 64,
  ExploreProgressAwardText = {},
  TrapVoidModelId = 3,
  DimensionBuff = 7920061,
  SwitchLayerDelayTime = 0.3,
  PartCheckTime = 2000,
  WeaponSwitchCd = 1,
  InvincibleBuffConfigId = 521001,
  InitialItem = 20000000,
  BuffFristTime = 2,
  BuffTurningTime = 3,
  CommonAbnormalCDTime = 6,
  IsVisibleBugBtn = 1,
  RunEditorBornMap = 11001,
  ChatEnterFunction = {
    {1, 102120},
    {2, 102125},
    {
      3,
      102202,
      102203,
      102204,
      102205
    }
  },
  ChatStickersSort = {
    [1] = "1=emoji_tab_icon_01=0",
    [2] = "3=emoji_tab_icon_03=0",
    [3] = "6=emoji_tab_icon_04=0",
    [4] = "8=emoji_tab_icon_05=0",
    [5] = "9=emoji_tab_icon_06=0",
    [6] = "10=emoji_tab_icon_07=0",
    [7] = "12=emoji_tab_icon_04=1",
    [8] = "11=emoji_tab_icon_05=1"
  },
  PostSnapshotToHttpGap = 30,
  JumpResetStartVelocity = false,
  WeaponLevelUpItem = {
    {
      1020001,
      10,
      10008,
      10
    },
    {
      1020002,
      100,
      10008,
      100
    },
    {
      1020003,
      500,
      10008,
      500
    }
  },
  MonsterFormation = {
    {
      "MonsterFormation101",
      "101",
      "5"
    },
    {
      "MonsterFormation102",
      "102",
      "3"
    }
  },
  FightTestPanelButton = {
    [821301] = "Fight821301",
    [500103] = "Fight500103"
  },
  FightTestPanelAttrPara = {
    {"AttrAdd"},
    {"AttrExAdd"},
    {"AttrPer"},
    {"AttrExPer"}
  },
  TrainingHallId = {10001, 10002},
  SpecialHairColorPR = {50, 50},
  SpecialEyeBallColorPR = 30,
  FaceStickerPR = {
    10,
    20,
    0,
    0
  },
  StiffAirDefaultVerUpSpd = 20,
  StiffAirDefaultVerUpAccSpd = -80,
  StiffAirDefaultVerDownSpd = 15,
  StiffAirDefaultVerDownAccSpd = 10,
  StiffAirDefaultHorSpd = 7,
  StiffAirDefaultHorAccSpd = 0,
  StiffAirDefaultHangTime = 0.25,
  StiffAirDefaultDownTime = 0.2,
  EmoteMPInvitationTime = 10,
  InteractionOffSet = 0.74,
  InteractionAngle = 150,
  DamageWeightRange = 30,
  STAccurateAngleWeight = 800,
  STAccurateAngleThreshold = 7,
  STSmallDistanceWeight = 500,
  STBigDistanceAddWeight = 20,
  STBigDistanceMultiWeight = 0.1,
  STChangeThreshold = 200,
  STVerySmallDistanceWeight = 1.5,
  MailTitleLenMax = 50,
  MailListTitleLenMax = 14,
  MailContentLenMax = 600,
  MailNoAttachmentDeleteDay = 30,
  MailAttachmentDeleteDay = 30,
  MailQuantityMax = 500,
  MailListRefreshNum = 20,
  invincibilityWithBorn = 620701,
  DebugMode = 1,
  FreeFallDamageHeight = 20,
  SkillFallDamageHeight = 40,
  DodgeBreakSkillPriority = 0,
  RushBreakSkillPriority = 0,
  NpcBePushedRange = 0.8,
  ActionTimeFrontPushed = 1,
  ActionTimeBackPushed = 1,
  ActionTimeFrightened = 1,
  ActionTimeCompliment = 1,
  FleshyAudioEnum = {
    [0] = "General",
    [1] = "Flesh",
    [2] = "Horniness",
    [3] = "Metal"
  },
  SceneTagTitleLenMax = 7,
  SceneTagContentLenMax = 20,
  SceneTagMaxNum = 50,
  HeroNormalDungeonArea = {
    {7, 149},
    {7, 150},
    {7, 151}
  },
  SettlementCameraConfig = {
    1,
    0,
    0
  },
  SettlementCameraOffset = {
    Vector3.New(-1, 1, 0),
    Vector3.New(-1, 1, 0)
  },
  SettlementCameraMoveDir = {
    0,
    0,
    0
  },
  SetKeyboardShow = {
    23,
    116,
    6,
    8,
    7
  },
  ResolutionType = {
    {
      2560,
      1440,
      1
    },
    {
      2560,
      1440,
      2
    },
    {
      1920,
      1080,
      2
    },
    {
      1680,
      1050,
      2
    },
    {
      1600,
      900,
      2
    },
    {
      1366,
      768,
      2
    },
    {
      1280,
      1024,
      2
    },
    {
      1280,
      800,
      2
    },
    {
      1280,
      768,
      2
    },
    {
      1280,
      720,
      2
    },
    {
      1024,
      768,
      2
    },
    {
      1024,
      600,
      2
    },
    {
      1024,
      576,
      2
    },
    {
      800,
      600,
      2
    },
    {
      640,
      480,
      2
    }
  },
  NavmeshPath = "../resource/",
  WholeOneDayTime = 24,
  RoleInfoCameraInit = {0},
  ChestInteractRange = 5,
  ShadowRushEnergy = 0,
  InsightHierarchy = 1,
  InsightCD = 0,
  InsightShutdownCD = 1,
  InsightAutoShutdownTime = 8,
  UnionNameLengthMaxLimit = 14,
  UnionNameLengthMinLimit = 1,
  UnionInitialLevel = 1,
  UnionMemberInitialBankroll = 999,
  UnionMemberInitialNum = 80,
  UnionNameChangeRecordLimit = 5,
  UnionChairmanNum = 1,
  UnionViceChairmanNum = 2,
  UnionDirectorNum = 3,
  MemberTitleLength = {1, 14},
  MemberTitleNum = 4,
  UnionBuildMailId = 1020,
  UnionJoinMailId = 1021,
  UnionViceChairmanMailId = 1022,
  UnionViceChairmanCancelMailId = 1023,
  UnionDirectorMailId = 1024,
  UnionDirectorCancelMailId = 1025,
  UnionCreateCost = {
    {1073002, 1}
  },
  UnionNewsMax = 100,
  UnionNameCost = {
    {1073002, 1}
  },
  UnionNoticeLengthMaxLimit = 60,
  UnionNoticeLengthMinLimit = 1,
  UnionBankroll = 10010,
  UnionNoticeReviseCD = 5,
  UnionSearchMaxLimit = 14,
  UnionSearchMinLimit = 1,
  UnionSearchListMax = 20,
  UnionSearchCD = 5,
  UnionApplyAllCD = 30,
  UnionApplyMaxLimit = 200,
  UnionApplyListMaxTime = 86400,
  UnionListLoadNum = 50,
  UnionListLoadLimitOne = 140,
  UnionListLoadLimitTwo = 120,
  UnionListLoadLimitThree = 100,
  UnionListLoadLimitFive = 50,
  UnionListLoadLimitSix = 0,
  UnionListSiftMax = 1,
  UnionApplyTimeLimitActive = 60,
  UnionApplyTimeLimitPassive = 60,
  UnionIconPreview = {
    {
      1,
      1001,
      5,
      2001,
      4,
      3004
    },
    {
      2,
      1007,
      2,
      2002,
      1,
      3003
    },
    {
      3,
      1003,
      4,
      2004,
      2,
      3001
    },
    {
      4,
      1006,
      1,
      2003,
      3,
      3002
    }
  },
  UnionNameReviseCD = 604800,
  UnionNewsKeepMaxNum = 100,
  UnionNewsKeepTime = 864000,
  UnionDefaultPosition = 4,
  Chat_MaxApplyFriendsList = 30,
  Chat_MaxSolvedFriendsList = 20,
  Chat_MaxFriendsNum = 100,
  Chat_FriendsSignatureMaxLength = 30,
  Chat_RECFriendsListRefreshCD = 5,
  Chat_MaxRECFriendsList = 20,
  Chat_MaxChatList = 200,
  Chat_FriendChatNoticeColor = "ChannelFriend",
  Chat_MiniTipsShowTime = 30,
  Chat_PrivateChatMessageCacheLimit = 1000,
  Chat_WorldChannelNum = 9999,
  Chat_WorldChannelLinkLimit = 500,
  Chat_WorldChannelMinimumLoad = 25,
  Chat_MsgCharacterLimit = 140280,
  ChatVoiceMsgMaxDuration = 58,
  FriendRequestNoticeShowTime = 15,
  RecoverOffsetYRatio = 0.5,
  PivotCameraInit = 0,
  LinearActionStateShowWeight = 0.5,
  Mix2DActionStateShowWeight = 0.5,
  NavMeshThreshold = 0.9,
  NavMeshRadius = 0.6,
  FashionSwitchPriority = {
    [6] = "Jacket_Metal",
    [5] = "Robe",
    [4] = "Thick",
    [3] = "Jacket",
    [2] = "Tight",
    [1] = "Thin"
  },
  EnvironmentResonanceScenePic = {
    [7] = "ui/textures/env_textures/main_bg_2",
    [8] = "ui/textures/env_textures/main_bg_4"
  },
  BreakingContinueTime = 5,
  BreakingAddBuff = 0,
  UnbreakLevelToStateTable = {
    {0},
    {
      1,
      2,
      20,
      21,
      3,
      4,
      5,
      12,
      14,
      15,
      16,
      17,
      18,
      25
    },
    {-1},
    {-1},
    {
      23,
      26,
      27
    }
  },
  WhackTakeEffectTime = 0.5,
  VigilanceMaxValue = 100,
  VigilanceIncrease = {
    {
      1,
      2,
      20
    },
    {
      3,
      8,
      40
    }
  },
  PlayerNameLimit = 14,
  VigilanceDecrease = 50,
  MaxPassiveSkillConcurrentNumber = 3,
  WorldQuestAawardMailID = 1026,
  WorldQuestDailyScore = 3,
  WorldQuestAawardBlue = 11200010,
  WorldQuestAawardPurple = 11200020,
  WorldQuestAawardOrange = 11200030,
  WorldQuestScoreDaysLimit = 4,
  ForceCorrectPosThreshold = 6,
  StiffEndRandomTime = 0.2,
  CDChangeTempAttrId = {},
  WindZoneHoverAngle = 10,
  WindZoneHoverHeightToTop = 1,
  WindZoneSpeedDamping = 300,
  OfflineDelay = 300,
  EquipDurabilityAlert = 0,
  SameScreenNumMin = 1,
  SameScreenNumMax = 20,
  ReviveDefaultId = 10,
  ReviveText = 100132,
  ReviveHudDistance = 15,
  ReviveInteractDistance = 3,
  GlideAttachVelocityWindRingMultiple = 2,
  CharStandardScale = {
    Vector3.New(0.76, 0.95, 1.02),
    Vector3.New(0.76, 0.9, 0.98)
  },
  CharWeaponScaleRange = {
    Vector2.New(1.05, 1),
    Vector2.New(0.95, 0.9)
  },
  TeamCallCD = 15,
  HitWeight = {
    1,
    0.5,
    0.3,
    0
  },
  StiffProtectionNum = 3,
  ModelDialogueLookatWeight = {
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.75,
      0.35,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.75,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    },
    {
      0.5,
      0,
      0.5,
      0.5,
      0.5,
      0.5
    }
  },
  TimeLimitQuestAlert = 10,
  HandInHandDisParam = {
    0.55,
    0.25,
    0.34
  },
  HandInHandLen = {0.65, 0.62},
  HandInHandShouldHeight = {1.2, 1.2},
  HandInHandIKParam1 = {
    30,
    90,
    15,
    10,
    10
  },
  HandInHandIKParam2 = {
    0.01,
    0.1,
    5
  },
  RushCurveArray = {
    "curve/as_f_base_dodge_b.bytes",
    "curve/as_f_base_dashstart.bytes"
  },
  RollCurveName = "curve/as_f_base_dodge_f.bytes",
  SeasonTargetStartTimeWeek = 24,
  SeasonTargetStartServerTime = "2025-02-24 05:00:00",
  InitialEquipment = {},
  FaceSaveItem = {
    {
      1,
      1074001,
      1
    },
    {
      2,
      1074004,
      1
    }
  },
  BagFullMailId = 1030,
  UnionDefaultJoinSwitch = 1,
  EnvironmentResonancePresetObject = {
    53002,
    0,
    226
  },
  NearBulletThreshold = 5,
  DefaultMonsterIntensitySetting = {
    {1, 2},
    {2, 8},
    {3, 15},
    {4, 40},
    {5, 80},
    {6, 250}
  },
  RoleLevelModelCamera = {
    [100001] = {-0.31, 0.02},
    [100002] = {-0.32, 0.07},
    [100003] = {-0.36, -0.17},
    [100004] = {-0.34, -0.06},
    [100005] = {-0.36, -0.21},
    [100006] = {-0.35, -0.09}
  },
  HandinHandBuffId = 681001,
  FashionShowActionM = {
    {701, 50000016},
    {702, 50000016},
    {703, 50000016},
    {711, 50000017},
    {712, 50000017},
    {713, 50000018},
    {714, 50000018},
    {715, 50000018},
    {716, 50000018},
    {717, 50000018},
    {721, 50000018},
    {722, 50000018},
    {723, 50000037},
    {731, 50000039}
  },
  GlideAttachVelocityWindZoneMultiple = 1.5,
  StiffGroundFriction = 10,
  StiffAirFriction = 5,
  StiffDefaultHorImpactForce = 100,
  StiffDefaultVerImpactForce = 100,
  StiffDefaultWeight = 51,
  ClickSwitch = {
    {1, 1},
    {2, 0}
  },
  FashionShowActionF = {
    {701, 50000013},
    {702, 50000013},
    {703, 50000013},
    {711, 50000014},
    {712, 50000014},
    {713, 50000015},
    {714, 50000015},
    {715, 50000015},
    {716, 50000015},
    {717, 50000015},
    {721, 50000015},
    {722, 50000015},
    {723, 50000036},
    {731, 50000038}
  },
  EquipShowActionM = {
    {
      202,
      9009,
      0,
      0,
      0
    },
    {
      203,
      9030,
      0,
      0,
      0
    },
    {
      204,
      9030,
      0,
      0,
      0
    },
    {
      201,
      9039,
      0,
      0,
      0
    },
    {
      205,
      9039,
      0,
      0,
      0
    },
    {
      206,
      9039,
      0,
      0,
      0
    },
    {
      207,
      21,
      1,
      1,
      0
    }
  },
  EquipShowActionF = {
    {
      202,
      9011,
      0,
      0,
      0
    },
    {
      203,
      9003,
      0,
      0,
      0
    },
    {
      204,
      9003,
      0,
      0,
      0
    },
    {
      201,
      9019,
      1,
      1,
      0
    },
    {
      205,
      9019,
      1,
      1,
      0
    },
    {
      206,
      9019,
      1,
      1,
      0
    },
    {
      207,
      21,
      1,
      1,
      0
    }
  },
  BreakingEventRadius = 30,
  UnionListLoadLimit = {
    140,
    120,
    100,
    50,
    0
  },
  MapTransferParam = 0,
  ShowMonsterMinHUD = 20,
  ShowMonsterMaxHUD = 25,
  CamShowAlphaDis = 0.9,
  BroadcastTipsMoveTime = 22,
  MixologyTipsTriggerStepId = 205015006,
  WalkAwayDistance = 0,
  ResonanceCutscene = {
    {
      50100104,
      50100105,
      50100106,
      50100101,
      50100102,
      50100103
    },
    {
      50100204,
      50100205,
      50100206,
      50100201,
      50100202,
      50100203
    },
    {
      50100304,
      50100305,
      50100306,
      50100301,
      50100302,
      50100303
    },
    {
      50100404,
      50100405,
      50100406,
      50100401,
      50100402,
      50100403
    },
    {
      50100504,
      50100505,
      50100506,
      50100501,
      50100502,
      50100503
    }
  },
  RushBreakOffTime = 0.33,
  RollBreakOffTime = 0.47,
  MixologyRecipeTriggerStepId = 205015002,
  GlideCameraAngleOffsetX = 0,
  GlideCameraControlRange = 30,
  TargetHitPosCheckHeight = 1.5,
  TargetHitPosCheckDown = 10,
  SoftAirWallMaxStayTime = 5,
  RoleEditorShowActionM = {
    {50000009, 35},
    {50000010, 36},
    {50000011, 37},
    {50000012, 38}
  },
  RoleEditorShowActionF = {
    {50000005, 31},
    {50000006, 32},
    {50000007, 33},
    {50000008, 34}
  },
  OFFICAL_VERSION = 0,
  StickOnGroundDatas = {1, 4},
  LookAtRateSpeed = {0.05, 0.5},
  UnstuckCD = 300,
  Dungeon000 = 5001,
  NameScene = 5002,
  IrunaData = {0},
  MainUITxt = 1,
  PhotoCameraChangeTime = 1.5,
  EnterDungeonCountTimeLimit = {60, 5},
  ItemSortFirst = {
    201,
    10003,
    10005,
    10009,
    10002,
    10008,
    20011
  },
  ItemSortLast = {10001, 20002},
  SwimSpeed = 3,
  SwimSprintSpeed = 6,
  SwimSprintMinTime = 0.93,
  SwimDepthLimit = 0.7,
  SwimDiveFastVerticalSpeedCondition = 8,
  SwimDiveVerticalSpeedCondition = 0.1,
  SwimDiveDuration = 0.3,
  SwimDrowningDuration = 1.4,
  SwimRayLength = 5,
  SwimRayRootUpOffsetToHead = 1,
  SwimRotateSpeed = 270,
  SwimSprintRotateSpeed = 180,
  SwimDetectStepForwardOffset = 0.3,
  SwimDetectStepUpOffsetToHead = 0.5,
  SwimDetectStepRayLength = 3,
  SwimBraceStepAltitudeLimit = Vector2.New(-0.2, 0.5),
  FallToShallowWaterEffectMinDepthLimit = 0.3,
  JumpInShallowWaterEffectMinDepthLimit = 0.3,
  MoveInShallowWaterEffectMinDepthLimit = 0.7,
  BigSkillBodyScaleRate = {0.97, 1},
  QuickRiseSkillID = 2002,
  ExchangeDiamondToSilvercoin = {
    {10003, 1},
    {10002, 100}
  },
  ExchangeDiamondToCoppercoin = {
    {10002, 1},
    {10001, 100}
  },
  ExchangePerMaxLimit = 10000,
  MoneyOverflowLimit = 0,
  PaymentSignal = {
    {"CNY", "\194\165"},
    {"KRW", "\226\130\169"},
    {"JPY", "\194\165"}
  },
  MosnterDiscoverConfig = {
    240,
    15,
    30,
    3,
    5
  },
  InteractMaxRange = 20,
  StandUpQuickTimeData = {
    0.5,
    0.9,
    1.1
  },
  StandUpQuickUCurveName = "curve/as_f_base_standupquick_u.bytes",
  StandUpQuickDCurveName = "curve/as_f_base_standupquick_d.bytes",
  FightTestPanelButtonPlayer = {
    [821101] = "Fight821101",
    [821201] = "Fight821201",
    [500103] = "Fight500103",
    [821102] = "Fight821102",
    [600201] = "Fight600201"
  },
  ClientViewFrameCount = {1, 30},
  ClientViewSize = 64,
  FriendshipSelfValueDayLimit = 200,
  FriendshipTotalValueDayLimit = 200,
  ResetTalentConsumables = {1070002, 1},
  ResetTalentFreeTimes = 999999999,
  BasicAttrType = {
    {
      11010,
      11020,
      11040
    },
    {
      11130,
      11140,
      11120
    }
  },
  AbnormalBuffs = {},
  BasicDish = 1010255,
  CookLimit = {4, 5},
  EnvironmentSkillDistance = 110,
  MixMaxFailureNum = 4,
  SelfPhotoRotateSpeed = 200,
  MainCitySceneIDs = {8},
  LoadingShortRange = 50,
  WindTunnelCorrectionSpeed = 2,
  WindTunnelDepartureAttenuationSpeed = 40,
  WindTunnelTransverseMoveSpeed = 2,
  WindTunnelEnterTime = 1,
  WindTunnelExitTime = 0.5,
  ZoomTriggerTime = 0.2,
  FaceRandomPR = 50,
  TalentPointConfigId = 30001,
  PassiveInterruptSkillState = {
    3,
    4,
    6,
    10
  },
  InputCacheTimes = {
    0.2,
    0.2,
    0.2,
    0.2,
    0.2
  },
  DashTurnInterval = 0.8,
  DashTurnTime = 0.4,
  DashTurnAngle = 150,
  DashTurnSlowdownTime = 0.2,
  HeroChallengeEventCountdownColor = {25, 50},
  HeroReadyToStartTime = 4,
  GlideWindRingFixAngleSpeed = 64,
  GlideWindRingFixMoveSpeed = 10,
  GlideWindRingFixTime = 1,
  BuyPerOverlapMaxLimit = 99,
  BuyPerNoOverlapMaxLimit = 50,
  PropertyTagMap = {
    [62] = 0,
    [28] = 1,
    [29] = 2,
    [30] = 3,
    [33] = 4,
    [31] = 5,
    [32] = 6,
    [34] = 7,
    [35] = 8
  },
  ModelDialogueLookatSpeed = 0.07,
  GuideAutoShowHelplibrary = {
    104,
    208,
    301,
    1003,
    3309,
    1111,
    1112
  },
  AwardNextLevelDailyCount = 302,
  CameraHorizontalRange = {
    0.55,
    0.7,
    0.85,
    1,
    1.15,
    1.3
  },
  CameraVerticalRange = {
    0.85,
    0.9,
    0.95,
    1,
    1.05,
    1.1
  },
  WorldEventMessageTimeIfOffLine = 30,
  AirLastTime = 20,
  SameScreenNumMinPC = 1,
  SameScreenNumMaxPC = 150,
  LoginDayCounter = 9,
  BuffHudTipsTime = 0.7,
  GSLevelCompare = {-5, 5},
  ModelAppearDisappearBuff = {},
  DefaultCurrencyDisplay = {
    10002,
    10005,
    10003
  },
  FirstTask = 10001,
  NormalHeroFreshTimerId = 203,
  DungeonEndBuffId = 902901,
  SeasonTaskDailyRandomCount = 1,
  BKClientBuff = {9401, 9402},
  SeasonTaskDailyRefreshTime = 302,
  BKDisplayDis = 50,
  NPCFadeOutDistance = 1,
  NPCDisappearDistance = 0.5,
  ProficiencyFunctionId = 200401,
  NameCard = 1070001,
  NameCardMailId = 1060,
  RollMaxNum = 99,
  BPCardMailId = 1027,
  RollChangeDelayTime = 2,
  RollLimitTime = 20,
  KeyRewardLimitId = 2,
  RollRewardLimitId = 3,
  RollInfoEndTime = 20,
  MonsterSkillDefaultRange = 15,
  NoWeaponSTParam = {
    0.5,
    0.5,
    8,
    2,
    4,
    -30,
    1500,
    -4,
    1500,
    14,
    15,
    25,
    15,
    2,
    0.8
  },
  SeasonIconStartCondition = {
    {
      "26",
      "1",
      "0",
      "0"
    },
    {
      "26",
      "2",
      "0",
      "0"
    },
    {
      "26",
      "3",
      "0",
      "0"
    },
    {
      "26",
      "4",
      "0",
      "0"
    }
  },
  SeasonIconStartPicture = "ui/atlas/login/common_redpoint_1",
  SeasonIconEndCondition = {
    {
      "26",
      "1",
      "0",
      "0"
    },
    {
      "26",
      "2",
      "0",
      "0"
    },
    {
      "26",
      "3",
      "0",
      "0"
    },
    {
      "26",
      "4",
      "0",
      "0"
    }
  },
  SeasonIconEndPicture = "ui/atlas/login/com_icon_choice_on_1",
  RankConditionItemIconId = {
    {2, 1071002},
    {2, 1071001}
  },
  CreatureHUDOffset = 0.5,
  CreatureMonsterHUDOffset = 1.1,
  HudLoadDisMinSqr = 400,
  HudLoadDisMaxSqr = 600,
  RollTime = 0.7,
  RunEndTime = 0.4,
  MoveSkinWidth = 0.02,
  MotionSpeedFrame = 4,
  NpcLookAtMinDistance = 0.1,
  ModelDisAppearCfg = {key = 7000111, value = 1},
  ModelAppearCfg = {key = 7000112, value = 1},
  ModelDissolutionCfg = {key = 7000114, value = 2},
  ModelReverseDissolutionCfg = {key = 7000113, value = 1.2},
  UnionJoinLimitLevel = 1,
  UnionJoinSloganMax = 20,
  UnionJoinDescriptionMax = 400,
  UnionCollectMax = 30,
  UnionListLoadRule = {
    {35, 30},
    {20, 20},
    {1, 10}
  },
  UnionListCD = 10,
  PersonalPhotoLimit = 4,
  PerosonalMainUIPosition = {
    [1] = Vector2.New(-705, 392),
    [2] = Vector2.New(-330, 105),
    [3] = Vector2.New(330, 105)
  },
  PersonalOnlinePeriodLimit = 3,
  PersonalTagLimit = 4,
  EffectiveNodeNum = {
    {34, 1},
    {69, 2},
    {999, 3}
  },
  RandomNodeEffectLevelWeight = {
    {0, 10},
    {1, 10},
    {2, 40},
    {3, 90},
    {4, 190},
    {5, 990}
  },
  NodeResetConsumption = {1070016, 3},
  ProgressValueItem = {
    {
      1,
      1220001,
      100
    },
    {
      1,
      1220002,
      500
    },
    {
      1,
      1220003,
      4500
    }
  },
  ProgressMoneyNum = {
    1,
    10001,
    0
  },
  WeekText = {
    "WeekNum7",
    "WeekNum1",
    "WeekNum2",
    "WeekNum3",
    "WeekNum4",
    "WeekNum5",
    "WeekNum6"
  },
  TalkModelOutlineMagnificationHair = {1, 1},
  TalkModelOutlineMagnificationHead = {1, 1},
  TalkModelOutlineMagnificationBody = {1, 1},
  NormalDungeonWeekTarget = {
    {101101, 400220},
    {101102, 400220},
    {101201, 400220},
    {101202, 400220}
  },
  DungeonSingleModeTime = 3,
  HeroNormalDungeonNumber = {
    {1, 2},
    {3, 5}
  },
  CookBuff = 7000091,
  TransferInvincibleBuff = 521001,
  TransferInvincibleBuffInMs = 2000,
  TransferInvincibleBuffLeaveMs = 2000,
  TransferTimeout = 8000,
  TelePortNotEffectWaitTime = 1500,
  ModelTransferLeaveCfg = {key = 7600193, value = 1.6},
  ModelTransferInCfg = {key = 7600194, value = 1.5},
  UnionResourceLimit = {
    {
      10010003,
      999999,
      33
    },
    {
      10010002,
      999999,
      33
    }
  },
  UnionActiveRefresh = 34,
  UnionUpgradingNum = {3, 33},
  UnionActiveAwardMailTime = 2592000,
  UnionDuration = 60,
  UnionActiveAwardMailId = 1070,
  UnionApplyListMaxLimit = 300,
  ActorHealthyThreshold = 8000,
  ActorHurtingThreshold = 3000,
  LineRankGreenNum = {key = 0, value = 60},
  LineRankOrangeNum = {key = 60, value = 80},
  LineRankRedNum = {key = 80, value = 100},
  LineChangeCD = 10,
  LineListFriends = 5,
  LineListGreenNum = 10,
  LineListOrangeNum = 10,
  LineListRedNum = 2,
  LineFriendshipLimit = 10,
  LineTipButtonCD = 5,
  LineSearchLimit = 5,
  LineCacheTime = 5,
  LineRefreshCD = 3,
  AvatarDefaultId = 1,
  ActivationTimesCount = 2,
  ActivationTimesWeight = {30, 70},
  ActivationTimes = {400, 200},
  ActivationTimesIcon = {
    [5] = "ui/atlas/season_activation/img_rate_bg_3",
    [2] = "ui/atlas/season_activation/img_rate_bg_2"
  },
  ActivationRefreshTimer = 10102,
  ActivationRefreshCount = 10,
  MoveInShallowWaterEffectOffsetZ = -0.8,
  TalentPageScale = {50, 100},
  ForceSyncRotateAngle = 10,
  SwimFallintoDuration = 1.2,
  DropItemCollectionId = 41001,
  ModEnhancedconsumption = {
    {
      2,
      10008,
      10
    },
    {
      3,
      10008,
      50
    },
    {
      4,
      1021001,
      5
    }
  },
  EnhancementHoleNum = {
    {2, 10},
    {3, 10},
    {4, 10}
  },
  ModTypeLimitNum = {
    {1, 6},
    {2, 6},
    {3, 6},
    {4, 6},
    {5, 6},
    {6, 6}
  },
  ModEnhancementSuccessRate = {
    {
      2,
      8000,
      1000,
      1000,
      10000,
      5000
    },
    {
      3,
      7500,
      1000,
      1000,
      7500,
      500
    },
    {
      4,
      7000,
      1000,
      1000,
      7000,
      500
    }
  },
  HateOTTime = 5,
  SkillTalkTime = 2,
  MonsterTargetLineBuff = 683302,
  WorldEventTypeGroup1 = {1},
  WorldEventTypeGroup2 = {2, 3},
  WorldEventTypeGroup1Count = 1,
  WorldEventTypeGroup2Count = 2,
  WorldEventATypeRandom = 1,
  WorldEventBTypeRandom = 1,
  WorldEventCTypeRandom = 1,
  WorldEventDaysLimit = 3,
  WorldEventDailyRefreshTimer = 15,
  WorldEventQuestId = 120001,
  WorldEventSceneTagIcon = 505,
  WorldEventSuccessMsgId = 16002025,
  FishingTensionGreen = {
    25,
    50,
    75,
    90
  },
  FishingFullTensionBreak = 5,
  FishingBuoyDiveTime = 1.5,
  FishingDragSpeed = 150,
  FishingDefaultSpeed = 100,
  FishingMidZone = 33,
  FishingQteAnimationSpeed = 100,
  FishingShadowInWater = 2100,
  FishingRodId = 1073001,
  FishingBaitId = 1054008,
  UnionResolveUpNum = 8,
  UnionResolveUpProbability = 50,
  UnionResolveKeepNum = 12,
  UnionResolveKeepProbability = 0,
  UnionResolveDownNum = 4,
  UnionResolveDownProbability = 20,
  UnionResolveBaseAwardId = 20500400,
  UnionResolveExtraAwardId = {
    {2000, 20500410},
    {5000, 20500420},
    {10000, 20500430},
    {20000, 20500440}
  },
  UnionResolveMinValue = 2000,
  UnionResolveAutoGo = 280,
  UnionResolveAutoBack = 281,
  UnionResolveMaxValue = 25249,
  WarehouseFoundItem = {1073003, 1},
  WarehousePopulation = 4,
  WarehouseCapacity = 100,
  WarehouseMail = 1090,
  WarehouseMailQuit = 1091,
  SettingoffGuideTime = 60,
  SettingoffGuideEffectStart = "effect/common_new/env/p_fx_xingyuan_zhiyinxian_start",
  SettingoffGuideEffectLoop = "effect/common_new/env/p_fx_xingyuan_zhiyinxian_loop",
  SettingoffGuideEffectEnd = "effect/common_new/env/p_fx_xingyuan_zhiyinxian_end",
  SettingoffGuideDistance = 1.5,
  WindTunnelGradientShow = {
    {30, 7600203},
    {50, 7600204}
  },
  WindTunnelCrossRingBuffId = 7600205,
  UnionPhotoAlbumTemporaryNumLimit = 20,
  UnionPhotoAlbumNumLimit = 50,
  UnionPhotoAlbumSendLimit = {
    {35, 2}
  },
  UnionPhotoAlbumTemporaryTimeLimit = 172800,
  UnionPhotoAlbumSendCoverNum = 1,
  UnionPhotoMaxAlbumNum = 10,
  WalkEndTime = 0.4,
  MoveStartTime = 0,
  TurnRunStartTime = 0.3,
  TurnMoveStartAngle = 10,
  TurnRunStartTurnTime = 0.17,
  TurnWalkStartTime = 0.5,
  TurnWalkStartTurnTime = 0.33,
  MoveEndToIdleTime = 0.5,
  GodModeConfig = {30, 3},
  ImportSkillCountCD = 10,
  UnionunlocksceneTaskTime = {
    2,
    10000,
    1
  },
  UnionunlocksceneNum = 10,
  UnionunlocksceneBuildingTime = 600,
  UnionUpgradingCount = 17,
  UnionPhotoAlbumSendCount = 18,
  UnionItemLimit = {1070006},
  UnionPhotoSetLimit = 19,
  HeroDungeonKeyModeAffixTableID = 15,
  HeroDungeonKeyRecastCost = {
    {
      1,
      3,
      10002,
      0
    },
    {
      4,
      5,
      10002,
      100
    },
    {
      6,
      10,
      10002,
      200
    },
    {
      11,
      1000,
      10002,
      300
    }
  },
  HeroDungeonKeyRecastCounterId = 20,
  HeroDungeonKeyId = 1070009,
  DashTurnTurnVelocity = 720,
  EquipPerfectionConfig = {
    0,
    100,
    0
  },
  EquipWeaponSlot = 200,
  EquipPerfectvalDecomTips = 80,
  EquipQualityvalDecomTips = 3,
  EquipRecastingNumConsumeTips = 0,
  EquipRecastingPerfectvalConsumeTips = 80,
  ModModel = {
    {
      "2",
      "mod/mod_base_2/mod_base_2"
    },
    {
      "3",
      "mod/mod_base_3/mod_base_3"
    },
    {
      "4",
      "mod/mod_base_4/mod_base_4"
    }
  },
  RoleEditorToothShow = {34, 34},
  SummonUpperLimit = 20,
  MonsterSummonUpperLimit = {
    20,
    30,
    40
  },
  UnionApplyMailId = {1201, 1202},
  MinVelocity = 1.5,
  MaxVelocity = 9,
  InterationCameraTemplateId = 1004,
  InterationMaxWaitTime = 5,
  IsOpenBotTest = 1,
  SkillRedDotJudgmentlevel = {
    {
      1,
      999,
      2
    }
  },
  SkillRedDotJudgmentStep = {
    {
      1,
      999,
      1
    }
  },
  TargetListClearDelay = 5,
  MedalModel = {
    {
      "1",
      "badge/model/badge_001"
    },
    {
      "2",
      "badge/model/badge_001"
    },
    {
      "3",
      "badge/model/badge_002"
    }
  },
  ServiceOpenTime = 10000,
  ModFilterCriteria = {
    {
      "1",
      "0",
      "3"
    },
    {
      "2",
      "4",
      "6"
    },
    {
      "3",
      "7",
      "10"
    }
  },
  AISTChangeThreshold = 200,
  FishTopN = 100,
  FishingItemSynOffset = {
    0,
    0,
    0.06
  },
  FishingItemSynMountRot = {
    -90,
    0,
    0
  },
  FishingSwitchTime = 1,
  FishingBuoyDiveToApearTime = 0.5,
  ChatItemPackageId = {
    {102202, 1},
    {102203, 2},
    {102204, 5},
    {102205, 6}
  },
  FunctionPreviewCount = 50,
  BossTaregtHide = {5002},
  OfflineHideTime = 10000,
  RouletteOffBattleSwitchTime = 20,
  ResearchRecipeCraftEnergyConsume = {5, 5},
  InvestigationGuideClueId = {100121, 100311},
  ExchangeSpecialItemId = {20003},
  UnionPunchClockItemId = {
    {
      4,
      1073006,
      1073004
    },
    {
      5,
      1073007,
      1073005
    }
  },
  Photograph_CameraOffsetSpeedCoefficient = {
    0.8,
    0.02,
    2,
    0.4,
    0.5
  },
  Photograph_CameraOffsetExtremumValue = {
    {-7.5, 7.5},
    {-2.7, 3}
  },
  Photograph_BusinessCardCameraOffsetRangeA = {0.38, 1.04},
  Photograph_BusinessCardCameraOffsetRangeB = {0.24, 0.37},
  Photograph_CameraOffsetCoefficient = 0.01,
  FishingWhaleId = 1094099,
  ItemGainLimit = {
    {10006, 22}
  },
  VRCameraPosOffset = {
    0.2,
    1.87,
    0
  },
  FishingHeight = 5,
  FireworkScene = {8},
  FireworkSceneAttrKey = 1007,
  SetKeyboardShowFishing = {125, 116},
  FishingBelowWater = 20,
  MapShowShopBtnSceneIDs = {
    7,
    71,
    72
  },
  BuyMaxTips = 51,
  FaceEquipment = {
    2020101,
    2030101,
    2040101
  },
  SeasonArmbandShowAction = {
    "as_m_base_armband",
    "as_f_base_armband"
  },
  RollSuccessMailId = 1301,
  RollFailedMailId = 1302,
  StallBuyMaxTips = 50,
  SeasonArmbandShowExpression = {328, 428},
  LoginTips = 31,
  EquipScreenGS = {
    {
      "10",
      "40",
      "10-40"
    },
    {
      "40",
      "80",
      "40-80"
    },
    {
      "80",
      "120",
      "80-120"
    },
    {
      "120",
      "160",
      "120-160"
    },
    {
      "160",
      "200",
      "160-200"
    },
    {
      "200",
      "240",
      "200-240"
    }
  },
  EquipScreenType = {
    {
      "0",
      "20",
      "0-20"
    },
    {
      "21",
      "50",
      "21-50"
    },
    {
      "51",
      "100",
      "51-100"
    },
    {
      "101",
      "99999999",
      "100"
    }
  },
  EquipScreenPerfectVal = {
    {
      "0",
      "30",
      "0-30"
    },
    {
      "31",
      "60",
      "31-60"
    },
    {
      "61",
      "80",
      "61-80"
    },
    {
      "81",
      "100",
      "81-100"
    }
  },
  UnstuckReviveId = 1,
  ChatMessageWindowSensitivityPC = 1,
  SetTipsCountdown = 10,
  AutoFlowMoveUpDistance = 0.5,
  CameraShakeWeakenQueue = {
    1,
    0.9,
    0.8,
    0.7,
    0.6,
    0.5
  },
  CameraShakeWeakenResetTime = 1,
  DeadChemicalBuff = 7000115,
  FishingDirectionRemindTime = 0.5,
  FishingPullRemindTime = 1,
  FishingPullRemindTension = 80,
  FishingShareTujian = "chat_fishing_share_tujian",
  FishingShareRank = "chat_fishing_share_rank",
  FishingShareProfile = "chat_fishing_share_profile",
  ChatWorldGreenNum = {0, 25},
  ChatWorldOrangeNum = {25, 60},
  ChatWorldRedNum = {60, 100},
  CameraFocusMainView = {1, 10},
  CameraFocusExchangeView = {1.5, 10},
  DefaultDialogFlow = 110081001,
  FishingBuoyDivPhoneVibrationTime = 0.1,
  FishingIKMaleOffset = {
    0.02,
    -0.04,
    0.02
  },
  FishingIKFemaleOffset = {
    -0.02,
    -0.02,
    0.02
  },
  FishingIKRotation = {
    0,
    -90,
    180
  },
  EquipRefineRedProbabilityLimit = 80,
  EquipRefineRedLevelLimit = {
    {
      1,
      999,
      2
    }
  },
  GoodEquipPerfectVal = 90,
  PetOutCombatHideTime = 10000,
  Photograph_DOFNearAmbiguityRange = {
    {
      0,
      1,
      0.5
    },
    {0, 100}
  },
  Photograph_DOFFarAmbiguityRange = {
    {
      0,
      1,
      0.5
    },
    {0, 100}
  },
  EquipAttColourSuitable = "#ffffff",
  EquipAttColourNotSuitable = "#b5b5b4",
  EquipAttColourNotActive = "#dadada",
  VehicleTogetherInteractRange = 5,
  VehicleTogetherApplyDuration = 20,
  RecycleItemMax = 50,
  RecycleItemNumMax = 999,
  DownshiftCoef = {1, 0.3},
  ModEffectDefaultSuccessTime = {
    {
      2,
      1,
      1,
      1
    },
    {
      2,
      2,
      1,
      1
    },
    {
      2,
      3,
      1,
      1
    },
    {
      2,
      4,
      1,
      1
    },
    {
      2,
      5,
      0,
      0
    },
    {
      3,
      1,
      1,
      2
    },
    {
      3,
      2,
      1,
      2
    },
    {
      3,
      3,
      1,
      2
    },
    {
      3,
      4,
      1,
      2
    },
    {
      3,
      5,
      0,
      0
    },
    {
      4,
      1,
      1,
      3
    },
    {
      4,
      2,
      1,
      3
    },
    {
      4,
      3,
      1,
      3
    },
    {
      4,
      4,
      1,
      3
    },
    {
      4,
      5,
      0,
      0
    }
  },
  ChallengeHeroDungeonFreshTimer = 305,
  ChallengeHeroDungeonMailId = 1403,
  DungeonOutTime = 600,
  CameraFocusRecycleView = {1, 10},
  CameraFocusMixologyView = {1, 10},
  VehicleCollideCheckHeight = 1,
  RotationStickGroundData = {
    0.65,
    45,
    1
  },
  RideTurnVelocity = 540,
  AngleSpeedRotate = false,
  RideAngleSpeedRotate = true,
  TalentRedDotFrequency = {
    {
      1,
      999,
      2
    }
  },
  FireworkResourceOne = "bin/simple_timeline/simple_timeline_p_fx_scene_fireworksshow",
  FireworkResourceTwo = "bin/simple_timeline/simple_timeline_p_fx_scene_fireworksshow_year",
  FireworkResourceTimeOne = 482,
  FireworkResourceTimeTwo = 482,
  PhotoShareDefaultCode = 1000,
  MonthCardDay = 2592000,
  MonthCardBuyTime = 3,
  MapRatio = {
    12,
    2,
    0.5,
    0.15,
    0.35,
    0
  },
  SwimDrowningDeathReviveConfig = 12,
  SkillPopMessageCd = 10,
  ChemistryExperimentTriesLimit = {5, 15},
  ChemistryExperimentCraftEnergyConsume = {0, 10},
  ChemistryExperimentSuccessProbability = {30, 4},
  ExtraPayFun = 800891,
  PayConfirm = true,
  PayConfirmDes = true,
  FirstPayFun = 800890,
  LifeProfessionWorkMaxHistoryCount = 50,
  RideMoveStartTime = 0.3,
  CastingConfirmTime = 5,
  ChatHUDDuration = 5,
  ChatFloatingWindowLimit = 7,
  BulletDelayDestroyTime = 1,
  UiWheelTabsShow = {
    {
      "camera_menu_1",
      "6"
    },
    {
      "camera_menu_18",
      "7"
    },
    {
      "camera_menu_17",
      "8"
    },
    {
      "camera_menu_5",
      "4"
    },
    {
      "camera_menu_15",
      "5"
    }
  },
  NpcHeadLookAtAngle = Vector2.New(60, 30),
  HeadLookAtAngle = Vector2.New(60, 30),
  RideJumpMaxAngleSpeed = 100,
  ConsumableItemType = {
    105,
    108,
    109,
    112,
    301
  },
  MonthCardAwardId = 50100000,
  MonthCardAwardCount = 27,
  MaxHitCount = 50,
  AssitRefresh = 28,
  FashionScoreResetTimer = 801,
  FashionTargetUpperLimit = {
    {802, 100},
    {803, 200},
    {804, 300}
  },
  FashionScoreTimeliness = 3,
  FashionScoreScale = {
    {1, 10000},
    {2, 10000},
    {3, 10000}
  },
  FashionPrivilegeSort = {
    1,
    2,
    3
  },
  FashionLevelMailTime = 3,
  FashionLevelItemId = 20011,
  MaxRoleNumber = 3,
  DeleteRoleTime = 168,
  MaxEquipEnchantItemNum = 3,
  SceneObjectModelDisAppearCfg = {key = 7000111, value = 1},
  SceneObjectModelAppearCfg = {key = 7000112, value = 1},
  SceneObjectModelDeathCfg = {key = 7000111, value = 1},
  SceneObjectModelBornCfg = {key = 7000112, value = 1},
  CollectionModelDisAppearCfg = {key = 7000111, value = 1},
  CollectionModelAppearCfg = {key = 7000112, value = 1},
  CollectionModelDeathCfg = {key = 7000111, value = 1},
  CollectionModelBornCfg = {key = 7000112, value = 1},
  DungeonPrepareTime = 20,
  DungeonPrepareCD = 5,
  DungeonTreasureMailID = 1303,
  DungeonTreasureInteractID = 1202,
  DungeonTreasureAwardCountID = 30,
  DungeonPrepareBuffType = {101, 102},
  DungeonPrepareRecoveryItemId = {
    1015001,
    1015002,
    1015003
  },
  DungeonPrepareReviveItemId = {1054015},
  DungeonPrepareFoodBuffDefaultIcon = "item_icons_cuisine24",
  DungeonPrepareMedicineBuffDefaultIcon = "item_icons_light_syrup_01",
  FashionColorGroupNum = {3, 3},
  FashionColorGroupUnlock = {
    {1074003, 5},
    {1074002, 5}
  },
  FashionLevelScoreTime = 31536000,
  NPCModelDisAppearCfg = {key = 7000111, value = 1},
  NPCModelAppearCfg = {key = 7000112, value = 1},
  NPCModelDeathCfg = {key = 7000111, value = 1},
  NPCModelBornCfg = {key = 7000112, value = 1},
  LifeProductionProHelpId = {
    {201, 5050},
    {202, 2103},
    {203, 2102},
    {204, 2113},
    {205, 2114},
    {206, 2115}
  },
  TakeShieldStiffBackForce = 2000,
  TakeShieldActionTime = 0.5,
  TalentRedDotLevelLimit = 25,
  BkLvFix = {
    1,
    0.97,
    0.92,
    0.85,
    0.72,
    0.5,
    0.25,
    0.1
  },
  BasicHateParam = {10, 0},
  GashaDelayTime = {
    0.2,
    0.35,
    0.5,
    0.65
  },
  GashaFlyInTime = {
    0.46,
    0.42,
    0.38,
    0.33
  },
  GashaFlySameTimeCount = 3,
  GashaDelayTimeForSingle = 0.5,
  GashaFlyInTimeForSingle = 0.5,
  StaticInteractionSeatTurnVelocity = 270,
  StaticInteractionActionCooldown = 0.5,
  EquipRefineReddotLevelLimit = 8,
  PlayerSkillReddotLevelLimit = 10,
  PlayerSkillReddotGradeLimit = 3,
  SkillFallBackCD = 1,
  RideJumpEndToIdleTime = 0.3,
  MagneticQueueSampleInterval = 3,
  MagneticQueueSampleAngle = 30,
  OpenMagnetFuncDynInteractionId = 6010,
  MagneticQueueClientSampleInterval = 0.5,
  MagneticQueueClientSampleAngle = 30,
  MagneticQueueCircleMoveSpeed = 2,
  MagneticAttachDirLimit = 75,
  LifeManufactureLackMatMessages = {
    {201, 1001902},
    {202, 1001902},
    {203, 1001902},
    {204, 1001902},
    {205, 1001902},
    {206, 1001910}
  },
  LifeManufactureLackVigourMessages = {
    {201, 1001903},
    {202, 1001903},
    {203, 1001903},
    {204, 1001903},
    {205, 1001903},
    {206, 1001911}
  },
  LifeManufactureStopMessages = {
    {201, 1001909},
    {202, 1001909},
    {203, 1001909},
    {204, 1001909},
    {205, 1001909},
    {206, 1001912}
  },
  PhotographTeamMemberLimit = {30, 10},
  PhotoLookAtEyeAngle = Vector2.New(90, 60),
  PhotoLookAtSpeed = Vector2.New(0.2, 2),
  Photograph_FightCameraVFOVRange = {
    {
      12.9,
      67.3,
      42
    },
    {12.9, 67.3}
  },
  PhotoMultiStateIcon = {
    {
      "1",
      "ui/atlas/photograph/photo_state_camera"
    },
    {
      "2",
      "ui/atlas/photograph/photo_state_notnearby"
    },
    {
      "3",
      "ui/atlas/photograph/photo_state_busy"
    },
    {
      "4",
      "ui/atlas/photograph/photo_state_leave"
    }
  },
  PhotoNearPlayerRefreshCD = 5,
  ChatWheelTransferList = {
    8,
    7,
    71,
    72,
    73,
    74,
    75
  },
  UseWheelExpressionCD = 1,
  AssociationMinSetOutCargoVolume = 2000,
  MagneticQueueCircleMinPassengerNumber = 2,
  MagneticQueueMaxPassengerNumber = 20,
  BlessExperienceId = {500500, 50000},
  LifeWorkMaxLimitNum = 20,
  DungeonPlayerFixPosRadius = 2,
  FashionLevelTimeRemind = 1382400,
  FashionLevelTimeTips = 1382400,
  ShopBuyDoodSingleNumMax = {
    {10002, 999999999},
    {10005, 999999999},
    {10008, 999999999}
  },
  ShopBuyDoodTypeNumMax = 30,
  TencentDiamondToRmbProportion = 10,
  ExploreWayPayType = {
    2,
    3,
    998
  },
  MagneticQueueIntervalAdjustTime = 1,
  ExplorTreasureFreshTimerId = 1103,
  ContinuousRotateTime = 0.5,
  TencentBindDiamondId = "PRO-6B58BB4ITDLK",
  TencentDiamondId = "PRO-GHN6JO2SIJRC",
  TencentGiftDiamondId = {
    {
      10011001,
      10003,
      6
    },
    {
      10011002,
      10003,
      30
    },
    {
      10011003,
      10003,
      120
    },
    {
      10011004,
      10003,
      288
    },
    {
      10011005,
      10003,
      528
    },
    {
      10011006,
      10003,
      1296
    }
  },
  TencentGiftShowTips = {3, 4},
  HitBloodPer = 25,
  PersonalMedalLimit = 5,
  TencentBpShopItemId = 10995,
  RotationStickGroundCurve = "curve/simple/stickground_rotate_speed.bytes",
  EquipDefaultPerfectUpperLimit = 30,
  UnlockToyMask = 15,
  RevivedByTeammateBuff = 7000140,
  TeamMaxNum = 5,
  PCUIEmoteTabsShow = {
    {
      "2",
      "ui/atlas/photograph/camera_menu_1"
    },
    {
      "3",
      "ui/atlas/photograph/camera_menu_2"
    },
    {
      "5",
      "ui/atlas/photograph/camera_interaction_btn_ash"
    },
    {
      "4",
      "ui/atlas/photograph/camera_menu_3"
    },
    {
      "6",
      "ui/atlas/photograph/camera_menu_21"
    },
    {
      "0",
      "ui/atlas/photograph/camera_menu_19"
    },
    {
      "1",
      "ui/atlas/photograph/camera_menu_12"
    }
  },
  PhotoPCSliderStepSize = {
    {1, 0.1},
    {2, 0.1},
    {3, 0.1},
    {4, 0.1},
    {5, 0.1},
    {6, 0.1},
    {7, 0.1},
    {8, 0.1},
    {9, 0.1},
    {10, 0.1},
    {11, 0.1},
    {12, 0.1},
    {13, 0.1},
    {14, 0.1},
    {15, 0.1},
    {16, 0.1},
    {17, 10}
  },
  ExchangeLimitHide = 99999,
  BeRevivedDynamicInteractionId = 4001,
  WorldShowMaxKillCnt = 40,
  DungeonStartCountDownTime = 5,
  DungeonReadyToGoTime = 2,
  FightbackSkillSlot = 113,
  QuickRiseSkillSlot = 114,
  PhotographDecorateScaleRangeLarge = {
    {
      1.2,
      4,
      2
    },
    {1.2, 4}
  },
  TapEvaluationCondition = "2=10097=2",
  FindActorMaxHitValue = 30,
  AttackSimplyDefParam = 6500,
  AttackSimplyRefineDefParam = 6500,
  AttackSimplyDeltaLevelMultiParam = {
    1,
    2,
    2,
    3,
    4,
    5,
    7,
    9,
    11,
    13,
    16,
    19,
    22,
    25,
    30
  },
  UnionGroupInviteLimit = 100,
  UnionGroupChatLinkId = 1004020,
  ChatVoiceMsgMaxLength = 350,
  IndicatorTargetRemoveTime = 0.2,
  IndicatorTargetMouseShock = 0.2,
  IndicatorTargetRouletteShock = 0.1,
  IndicatorRouletteShock = 0.2,
  IndicatorCameraID = {200, 201},
  PathFindingRunFirstDistance = 50,
  PathFindingEndDistance = 1,
  TowerFailCountDownTime = 1,
  TowerFailMessage = {1006003, 1005902},
  PathFindingCd = 0.5,
  RelaxGainLimit = {
    {10004, 35}
  },
  LipLang = {
    "zh",
    "en",
    "ja",
    "ko"
  },
  GamepadRotXSpeed = 40,
  GamepadRotYSpeed = 40,
  NewPeopleConditionLevel = {
    {
      1,
      1,
      10
    }
  },
  NewPeopleFunctionId = 100502,
  CompensationPointsPro = {
    {
      1,
      1000,
      1
    },
    {
      1001,
      10000,
      2
    },
    {
      10001,
      30000,
      5
    },
    {
      30001,
      50000,
      8
    },
    {
      50001,
      999999999,
      10
    }
  },
  NewbieFriendPointEvent = {4, 5},
  CompensationPointFunctionId = 800879,
  FishRankResetTimerId = 10103,
  EmoteNoFishQuickJump = {
    1,
    8,
    5,
    4732
  },
  TransferDefaultCameraId = 3001,
  HouseManufactureDialogShowItem = {
    {11010184, 1}
  },
  MatchWaitingTime = 300,
  MatchWaitingConfirmTime = 20,
  PersonalzonePhotoRow = {4, 3},
  PersonalzoneMedalRow = {7, 3},
  IdCardShowMedalCount = 5,
  TeamCardShowMedalCount = 5,
  PathFindingMoveHorizontalThreshold = 1,
  PathFindingMoveVerticalThreshold = 1,
  BuffAbnormalAbilityType = {
    301,
    302,
    303,
    304,
    305
  },
  BuffAbnormalDecayTime = 15,
  BuffAbnormalDecayPercent = {
    1,
    0.5,
    0.25,
    0
  },
  SkillAoyiSwitchSilentCd = 20000,
  SkillAoyiModelSkin1 = {
    {
      1,
      4,
      1
    },
    {
      5,
      5,
      2
    }
  },
  SkillAoyiModelSkin2 = {
    {
      1,
      4,
      1
    },
    {
      5,
      5,
      4
    }
  },
  GamepadZoomSpeed = 1,
  NewPeopleCancelCondition = {
    {102, 360000}
  },
  NewPeopleGiftGameplayType = {
    8,
    9,
    13,
    16,
    17
  },
  HelpNewPeopleGiftGameplayType = {
    9,
    13,
    16,
    17
  },
  NewPeopleGiftAwardPackageId = {
    10004,
    50,
    55
  },
  HelpNewPeopleGiftAwardPackageId = {
    10004,
    20,
    56
  },
  TeamTypeCD = 5,
  LifeCastMaxCnt = 999,
  ResonanceMaxLvSkin = 999999,
  SwimWaterNormalAngleLimit = 30,
  SeasonSigninMail = 2251,
  SigninRefresh = 40055,
  PhotoAlbumUploadMaxAmount = 10,
  DungeonSummonedCD = 20,
  ReceiveDungeonSummonedCD = 20,
  DungeonSummonedTime = 20,
  MailQuantityStorageMax = 500,
  ActNoticeTime = 30,
  UnionBossBuffFunctionId = 500125,
  DungeonPlayTypesToRecord = {
    9,
    16,
    17,
    18
  },
  DungeonActorRecordAttrIds = {
    11320,
    11330,
    11340,
    11410,
    11430,
    11710,
    11780,
    11930,
    11940,
    11950
  },
  MailRemindClaimNum = 100,
  MailRemindDeleteNum = 40,
  MailReadNumMax = 50,
  SkillResetActivityReturnItemId = {
    {1020151, 1040051},
    {1020152, 1040051},
    {1020153, 1040051},
    {1020154, 1040051},
    {1020155, 1040051},
    {1020156, 1040051},
    {1020157, 1040051},
    {1020158, 1040051}
  },
  SkillResetActivityReturnCounterId = 501,
  SkillResetActivityTxt = "SkillResetConfirmKey",
  SkillResetConsumeItemId = {
    {1020200, 1}
  },
  TauntInterval = 5000,
  StaticAttenuationHateRate = 50,
  DynamicAttenuationHateRate = 2000,
  EquipDecomposeLimit = 300,
  ModDecomposeLimit = 300,
  SkillAoyiDecomposeLimit = 300,
  FlagSkillEffectAddr = {
    "effect/common_new/tips/p_fx_dungeonsmask01",
    "effect/common_new/tips/p_fx_dungeonsmask02",
    "effect/common_new/tips/p_fx_dungeonsmask03",
    "effect/common_new/tips/p_fx_dungeonsmask04",
    "effect/common_new/tips/p_fx_dungeonsmask05",
    "effect/common_new/tips/p_fx_dungeonsmask06"
  },
  LoadingLevelWeight = 1.2,
  MaintenanceTipsSwitch = true,
  MaintenanceTipsURL = "https://discord.gg/starresonance",
  MaintenanceTipsShow = "MaintenanceTipsShow",
  SelfDefinePersonZoneFunctionId = 100913,
  RefundPayBanAccount = {3, 9900},
  MonthCardRefreshMonthlyOffset = 18000,
  HandleCamHorizontalRange = {
    0.05,
    0.1,
    0.15,
    0.2,
    0.25,
    0.3,
    0.35,
    0.4,
    0.45,
    0.5,
    0.55,
    0.6,
    0.65,
    0.7,
    0.75,
    0.8,
    0.85,
    0.9,
    0.95,
    1
  },
  HandleCamVerticalRange = {
    0.05,
    0.1,
    0.15,
    0.2,
    0.25,
    0.3,
    0.35,
    0.4,
    0.45,
    0.5,
    0.55,
    0.6,
    0.65,
    0.7,
    0.75,
    0.8,
    0.85,
    0.9,
    0.95,
    1
  },
  HandleMouseSpeedRange = {
    0.1,
    0.6,
    1.1,
    1.6,
    2.1,
    2.6,
    3.1,
    3.6,
    4.1,
    4.6
  },
  CdKeyButtonRequestCd = 5
}
return read_onlyHelper.Read_only(Global)
