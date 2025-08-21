local read_onlyHelper = require("utility.readonly_helper")
local GlobalHome = {
  AlignMoveValue = {
    1,
    3,
    10,
    3
  },
  AlignHeightValue = {
    1,
    3,
    10,
    3
  },
  AlignAnglesValue = {
    15,
    45,
    90,
    45
  },
  AlignAnglesSensitivity = 40,
  RotateTriggerValue = 2,
  RotateSpeedValue = {
    80,
    80,
    80
  },
  AdsorbEffectiveDistance = 0.5,
  AdsorbFailureDistance = 1,
  FurnitureGroupCircleEffectRadiusOffset = 0.2,
  MultiChoiceLimit = 10,
  HouseCertificateID = 1070037,
  HouseCertificateCost = {10003, 999},
  HouseCertificateCondition = {
    {
      1,
      18,
      60
    },
    {71}
  },
  HouseTransferCD = 60,
  HouseLivetogetherFriendshipValue = 2,
  HouseLivetogetherCD = 60,
  HouseLivetogetherInviteTime = 86400,
  HouseLivetogetherCount = 4,
  BuildMaxCount = {
    {1, 4}
  },
  BuildAccelerateItem = {1070038, 1},
  InviteLiveTogetherPassiveCD = 86400,
  InviteLiveTogetherActiveCD = 1800,
  PreviewItemId = 1079999,
  PreviewItemType = 1101,
  ModifyHouseNameOrStatementCD = 60,
  HouseWarehouseCapacity = 100,
  HouseTransferApplyCountdown = 604800,
  HouseDivorceCountdown = 604800,
  ItemWarehouseMaxCount = 100,
  QuitCohabitantMailConfigId = 1588,
  MoveToOthersHouseItemMailConfigId = 1589,
  HouseNameLimit = 14,
  HouseIntroLimit = 100,
  HouseWelcomeNotesLimit = 200,
  MaxStructureGroupNameLength = 14,
  MaxIndoorStructureGroup = 100,
  MaxOutdoorStructureGroup = 100,
  GroupFurnitureCircleColor = {
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
  MaxNoticeBoard = 100,
  RecycleHouseNpcTrack = {
    1,
    8,
    2,
    504756
  },
  HomeCleanInitial = 1000,
  HomeCleanWaste = {
    {13, 1000},
    {12, 960},
    {11, 880},
    {10, 800},
    {9, 720},
    {8, 640},
    {7, 560},
    {6, 480},
    {5, 400},
    {4, 320},
    {3, 240},
    {2, 160},
    {1, 80}
  },
  HomeTaskRule = {
    {1, 1},
    {2, 3},
    {3, 6}
  },
  HomeTaskMax = 10,
  HomeTaskDaily = 3,
  HomeTaskMaxGiven = 9,
  HomeTaskInitNum = 3,
  HomeExpItemId = 13010012,
  HomeResourceItemId = 13010013,
  HomeNormalNum = {5, 7},
  HomeMaxHighNum = {5, 7},
  HomeHighMagnification = {
    120,
    130,
    140,
    150
  },
  HomeLandCoin = 10010,
  HomeEnvironmentLightPrefab = "home_system_outdoor_001_env_center",
  HomeEnvironmentLightDefault = 1,
  HomeDayNightLightDefault = 7,
  LightNameLimit = 14,
  HomeOtherCollectPollenCount = 2,
  HomePlantFieldHybridization = 2,
  HomeFlowerType = 1111,
  HomeSeedType = 1112,
  HomePollenType = 1113,
  HomeCleanLevel = {
    800,
    700,
    600,
    500
  },
  HomeItemBagLimit = 9999,
  HomeEnvironmentColorGroupId = 210,
  HomeStateGrowIcon = "ui/atlas/house/house_play_growth_stage",
  HomeStatePollenIcon = "ui/atlas/house/house_play_pollinate",
  HomeStateHarvestIcon = "ui/atlas/house/house_play_reap",
  HomeLandLevelLimit = 18,
  HomeFurnitureSnapAudio = "UI_Home_Furniture_Attracted",
  HomeFurnitureRotateStartAudio = "UI_Home_Furniture_Rotate_Start",
  HomeFurnitureRotateEndAudio = "UI_Home_Furniture_Rotate_End",
  HomePlantFieldTypeId = 4,
  HomeLookAt = 200,
  ModifyHouseIntroductionStatementCD = 60,
  HomePlayerFurniturePackageItemId = 1075999,
  FurnitureWarehouseFullMailConfigId = 1590,
  HomeFurnitureRotateDragAudio = "UI_Home_Furniture_Drag",
  HomeSelectFurnitureCameraRange = 50,
  HomeTaskWeeklyExpLimit = 190000
}
return read_onlyHelper.Read_only(GlobalHome)
