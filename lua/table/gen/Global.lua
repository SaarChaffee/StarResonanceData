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
  ClimbVelocity = 1,
  ClimbStepDistance = 0.5,
  ClimbableAngle = 50,
  ClimbableDistance = 0.5,
  ClimbableOffset = 1.5,
  ClimbTopBraceDistance = 1.65,
  ClimbRushDistance = 3,
  ClimbRushVelocity = 8,
  ClimbRushInterval = 0.7,
  ShinCrossDistance = 1.4,
  ShinCrossTime = 0.6,
  ShinCrossVelocity = 3,
  ShinTouchSwitchTime = 0.1,
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
  WeatherStartTime = "2024-08-09 00:18:00",
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
  ResidualBloodPer = 30,
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
  BornMap = 5002,
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
    "mon_vo",
    "npc_vo",
    "player_vo",
    "hero_sf01",
    "Wpn_ScytheKatana",
    "Wpn_MagicWand",
    "Wpn_WindKnight",
    "Wpn_MagicHoop",
    "hero_tls01",
    "Wpn_GuardBlade",
    "hero_qp01",
    "vo_fz01",
    "vo_qq01",
    "vo_sf01",
    "vo_tdl01",
    "vo_tm01",
    "talent_dps",
    "talent_tank",
    "talent_sup",
    "vo_story",
    "Enemy_Common",
    "Enemy_Impact",
    "Wpn_Tribebow",
    "Wpn_ShieldKnight",
    "Amb_3D",
    "SFX_Vehicles"
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
      1070010,
      2
    },
    {
      0,
      201,
      1070010,
      2
    },
    {
      0,
      202,
      1070010,
      2
    },
    {
      0,
      203,
      1070010,
      2
    },
    {
      0,
      204,
      1070010,
      2
    },
    {
      0,
      205,
      1070010,
      2
    },
    {
      0,
      206,
      1070010,
      2
    },
    {
      0,
      207,
      1070010,
      2
    },
    {
      0,
      208,
      1070010,
      2
    },
    {
      0,
      209,
      1070010,
      2
    },
    {
      0,
      210,
      1070010,
      2
    },
    {
      1,
      200,
      1070010,
      2
    },
    {
      1,
      201,
      1070010,
      2
    },
    {
      1,
      202,
      1070010,
      2
    },
    {
      1,
      203,
      1070010,
      2
    },
    {
      1,
      204,
      1070010,
      2
    },
    {
      1,
      205,
      1070010,
      2
    },
    {
      1,
      206,
      1070010,
      2
    },
    {
      1,
      207,
      1070010,
      2
    },
    {
      1,
      208,
      1070010,
      2
    },
    {
      1,
      209,
      1070010,
      2
    },
    {
      1,
      210,
      1070010,
      2
    },
    {
      2,
      200,
      1070010,
      5
    },
    {
      2,
      201,
      1070010,
      5
    },
    {
      2,
      202,
      1070010,
      5
    },
    {
      2,
      203,
      1070010,
      5
    },
    {
      2,
      204,
      1070010,
      5
    },
    {
      2,
      205,
      1070010,
      5
    },
    {
      2,
      206,
      1070010,
      5
    },
    {
      2,
      207,
      1070010,
      5
    },
    {
      2,
      208,
      1070010,
      5
    },
    {
      2,
      209,
      1070010,
      5
    },
    {
      2,
      210,
      1070010,
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
      1070010,
      2
    },
    {
      202,
      1070010,
      2
    },
    {
      203,
      1070010,
      2
    },
    {
      204,
      1070010,
      2
    },
    {
      205,
      1070010,
      2
    },
    {
      206,
      1070010,
      2
    },
    {
      207,
      1070010,
      1
    },
    {
      208,
      1070010,
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
      43
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
      67.3
    },
    {34.1, 67.3}
  },
  Photograph_SelfCameraHorizontalRange = {
    {
      -0.3,
      0.05,
      0
    },
    {0, 100}
  },
  Photograph_SelfCameraVerticalRange = {
    {
      -1,
      1,
      0
    },
    {0, 100}
  },
  Photograph_SelfCameraOffsetValue = Vector3.New(-0.23, -0.05, -0.08),
  Photograph_ARCameraVFOVRange = {
    {
      12.9,
      67.3,
      43
    },
    {12.9, 67.3}
  },
  Photograph_DOFApertureFactorRange = {
    {
      1,
      32,
      10
    },
    {1, 32}
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
  ItemDropRadius = 3,
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
  GlideParamDefAngle = -10,
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
  DimensionShader = 1003,
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
    [1] = "emoji_tab_icon_01",
    [3] = "emoji_tab_icon_03",
    [6] = "emoji_tab_icon_04"
  },
  PostSnapshotToHttpGap = 30,
  JumpResetStartVelocity = false,
  WeaponLevelUpItem = {
    {
      1020001,
      10,
      1070010,
      1
    },
    {
      1020002,
      100,
      1070010,
      10
    },
    {
      1020003,
      500,
      1070010,
      50
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
  MailQuantityMax = 100,
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
  UnionApplyMaxLimit = 50,
  UnionApplyListMaxTime = 86400,
  UnionListLoadNum = 50,
  UnionListLoadLimitOne = 140,
  UnionListLoadLimitTwo = 120,
  UnionListLoadLimitThree = 100,
  UnionListLoadLimitFive = 50,
  UnionListLoadLimitSix = 0,
  UnionListSiftMax = 0,
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
  ChatVoiceMsgMaxDuration = 60,
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
  SameScreenNumMin = 5,
  SameScreenNumMax = 30,
  ReviveDefaultId = 10,
  ReviveText = 100132,
  ReviveHudDistance = 8,
  ReviveInteractDistance = 3,
  GlideAttachVelocityWindRingMultiple = 2,
  CharStandardScale = {
    Vector3.New(0.76, 0.95, 1.02),
    Vector3.New(0.76, 0.9, 0.98)
  },
  CharWeaponScaleRange = {
    Vector2.New(0.9, 1.1),
    Vector2.New(0.9, 1.1)
  },
  TeamCallCD = 15,
  HitWeight = {
    1,
    1,
    1,
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
  HandInHandLen = {0.62, 0.62},
  HandInHandShouldHeight = {1.23, 1.23},
  HandInHandIKParam1 = {
    30,
    90,
    10,
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
  SeasonTargetStartServerTime = "2024-06-25 05:00:00",
  InitialEquipment = {},
  FaceSaveItem = {1074001, 1},
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
    {721, 50000018},
    {722, 50000018},
    {723, 50000037}
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
    {721, 50000015},
    {722, 50000015},
    {723, 50000036}
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
    10002
  },
  ItemSortLast = {10001},
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
  FriendshipSelfValueDayLimit = 100,
  FriendshipTotalValueDayLimit = 300,
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
    3309
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
  SameScreenNumMinPC = 5,
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
  BPCardMailId = 127,
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
  HudLoadDisMinSqr = 200,
  HudLoadDisMaxSqr = 600,
  RollTime = 0.7,
  RunEndTime = 0.4,
  MoveSkinWidth = 0.05,
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
  PersonalPhotoLimit = 5,
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
      20006,
      1
    }
  },
  ProgressMoneyNum = {
    1,
    10001,
    1000
  },
  WeekText = {
    "\229\145\168\230\151\165",
    "\229\145\168\228\184\128",
    "\229\145\168\228\186\140",
    "\229\145\168\228\184\137",
    "\229\145\168\229\155\155",
    "\229\145\168\228\186\148",
    "\229\145\168\229\133\173"
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
    {3, 4}
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
      15
    },
    {
      10010002,
      999999,
      15
    }
  },
  UnionActiveRefresh = 17,
  UnionUpgradingNum = {3, 15},
  UnionActiveAwardMailTime = 2592000,
  UnionDuration = 60,
  UnionActiveAwardMailId = 1070,
  UnionApplyListMaxLimit = 100,
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
  ActivationTimesWeight = {15, 85},
  ActivationTimes = {500, 250},
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
      1070010,
      10
    },
    {
      3,
      1070010,
      50
    },
    {
      4,
      1021001,
      5
    }
  },
  EnhancementHoleNum = {
    {2, 7},
    {3, 7},
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
  UnionResolveKeepNum = 8,
  UnionResolveKeepProbability = 0,
  UnionResolveDownNum = 4,
  UnionResolveDownProbability = 20,
  UnionResolveBaseAwardId = 20500400,
  UnionResolveExtraAwardId = {
    {5000, 20500410},
    {10000, 20500420},
    {20000, 20500430},
    {40000, 20500440}
  },
  UnionResolveMinValue = 5000,
  UnionResolveAutoGo = 280,
  UnionResolveAutoBack = 281,
  UnionResolveMaxValue = 45249,
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
    {15, 2}
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
    3.87
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
  ResearchRecipeCraftEnergyConsume = 0,
  CookCuisineCraftEnergyConsume = 10,
  CookCuisineMaterialConsume = 3,
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
    1.5,
    0.03,
    3,
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
    2020001,
    2030001,
    2040001
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
      "20",
      "10-20\232\163\133\231\173\137"
    },
    {
      "40",
      "60",
      "40-60\232\163\133\231\173\137"
    }
  },
  EquipScreenType = {
    {
      "0",
      "20",
      "0-20\230\172\161"
    },
    {
      "21",
      "50",
      "21-50\230\172\161"
    },
    {
      "51",
      "100",
      "51-100\230\172\161"
    },
    {
      "101",
      "99999999",
      "100\230\172\161\228\187\165\228\184\138"
    }
  },
  EquipScreenPerfectVal = {
    {
      "0",
      "30",
      "0-30\233\151\180"
    },
    {
      "31",
      "60",
      "31-60\233\151\180"
    },
    {
      "61",
      "80",
      "61-80\233\151\180"
    },
    {
      "81",
      "100",
      "81-100\233\151\180"
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
  EquipAttColourNotActive = "#8d8d8d",
  VehicleTogetherInteractRange = 5,
  VehicleTogetherApplyDuration = 20,
  RecycleItemMax = 30,
  RecycleItemNumMax = 99,
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
    180,
    0.5,
    45,
    5
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
  FireworkResourceOne = "effect/common_new/env/p_fx_scene_fireworksshow",
  FireworkResourceTwo = "effect/common_new/env/p_fx_scene_fireworksshow_year",
  FireworkResourceTimeOne = 344,
  FireworkResourceTimeTwo = 344,
  PhotoShareDefaultCode = 1000,
  SwimDrowningDeathReviveConfig = 12
}
return read_onlyHelper.Read_only(Global)
