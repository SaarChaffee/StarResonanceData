local read_onlyHelper = require("utility.readonly_helper")
local PlanetMemorySeasonConfig = {
  SeasonId = 1,
  SeasonName = "\231\150\145\228\186\145\229\136\157\231\142\176",
  SeasonAward = {
    {100101, 13100010},
    {100102, 13100020},
    {100103, 13100030},
    {100104, 13100030}
  },
  SeasonAffix = {
    {
      "\230\173\163\233\157\162\229\188\130\229\143\152",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "13",
      "18",
      "25",
      "26",
      "27"
    },
    {
      "\228\184\141\229\136\169\229\188\130\229\143\152",
      "20",
      "22",
      "23",
      "24",
      "29",
      "36",
      "37",
      "39",
      "40",
      "41"
    },
    {
      "\232\176\131\229\146\140\229\188\130\229\143\152",
      "16",
      "17",
      "38"
    }
  },
  SeasonAwardDesc = "\228\189\147\233\170\140%d\228\184\170\232\174\176\229\191\134",
  LockedPointModel = {
    {1, 31003},
    {2, 31003},
    {3, 31003},
    {4, 31003},
    {5, 31003}
  },
  UnlockPointModel = {
    {1, 31002},
    {2, 31002},
    {3, 31002},
    {4, 31002},
    {5, 31002}
  },
  FinishedPointModel = {
    {1, 31001},
    {2, 31001},
    {3, 31001},
    {4, 31001},
    {5, 31001}
  },
  StartPointModel = 31004,
  CurrentPointModel = 31005,
  SpecialPointEffect = {
    [1] = "prefabs/skilleffect/effect_5.prefab",
    [2] = "prefabs/skilleffect/effect_5.prefab",
    [3] = "prefabs/skilleffect/effect_5.prefab",
    [4] = "prefabs/skilleffect/effect_5.prefab",
    [5] = "prefabs/skilleffect/effect_5.prefab"
  },
  SmokePosition = Vector3.New(11.5, 7.5, 5),
  LinkModelRadius = Vector2.New(0.08, 0.03),
  SmokeModel = 31009,
  RoomTypeIcon = {
    [1] = "ui/atlas/planetmemory/planetmemory_icon_4",
    [2] = "ui/atlas/planetmemory/planetmemory_icon_2",
    [3] = "ui/atlas/planetmemory/planetmemory_icon_3",
    [4] = "ui/atlas/planetmemory/planetmemory_icon_1"
  },
  RoomTypeBallIcon = {
    [1] = "ui/textures/planetmemory/planetmemory_icon_ordinary",
    [2] = "ui/textures/planetmemory/planetmemory_icon_elite",
    [3] = "ui/textures/planetmemory/planetmemory_icon_boss",
    [4] = "ui/textures/planetmemory/planetmemory_icon_dangerous"
  },
  SceneZoom = Vector2.New(1.2, 3),
  FirstRoomCamOffset = Vector3.New(2, 0, 0),
  TrialRoadAward = {
    {100101, 13100010},
    {100102, 13100020},
    {100103, 13100030},
    {100104, 13100030}
  }
}
return read_onlyHelper.Read_only(PlanetMemorySeasonConfig)
