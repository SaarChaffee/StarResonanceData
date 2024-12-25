local read_onlyHelper = require("utility.readonly_helper")
local GlobalParkour = {
  OriginEnergyValue = 1200,
  NonParkourOriginEnergyRecovery = 160,
  ParkourStandbyOriginEnergyRecovery = 160,
  ParkourOriginEnergyRecovery = 0,
  ParkourRunOriginEnergyLimit = 180,
  ParkourRunOriginTimeLimit = 1,
  ParkourRunPhaseOneStartSpeed = 6,
  ParkourRunPhaseOneAcceleration = 1,
  ParkourRunPhaseOneSpeedLimit = 6,
  ParkourRunPhaseOneTimeLimit = 1,
  ParkourRunPhaseTwoAcceleration = 1,
  ParkourRunPhaseTwoSpeedLimit = 7,
  ParkourRunPhaseTwoTimeLimit = 1,
  ParkourRunPhaseThreeAcceleration = 1,
  ParkourRunPhaseThreeSpeedLimit = 8,
  ParkourRunOriginEnergyConsume = 0,
  ParkourRunPhaseOneActionSpeed = 1,
  ParkourRunPhaseTwoActionSpeed = 1,
  ParkourRunPhaseThreeActionSpeed = 1,
  ShimmyJumpTime2ndCameraBlur = 0.7,
  ShimmyJumpQTE = {
    {
      3,
      500,
      250,
      30
    },
    {
      2,
      249,
      100,
      15
    },
    {
      1,
      99,
      0,
      5
    }
  },
  RadialLength = 0.5,
  ObstacleSlope = Vector2.New(45, 135),
  Assault1stOriginEnergyConsume = 0,
  Assault2ndOriginEnergyConsume = 0,
  AssaultQTE = {
    {
      3,
      500,
      300,
      10020
    },
    {
      2,
      299,
      100,
      10021
    },
    {
      1,
      99,
      0,
      10023
    }
  },
  OriginEnergyBarMuteTime = 3,
  OriginEnergyAlertPercent = 300,
  ParkourIdleShaderBrightness = 0,
  ParkourRunDashShaderBrightness = 0,
  ParkourRunPhaseOneShaderBrightness = 2,
  ParkourRunPhaseTwoShaderBrightness = 3,
  ParkourRunPhaseThreeShaderBrightness = 4,
  ParkourPedalWallBrightness = 6,
  StartParkourStateEffect = 510602,
  StartParkourStateBuff = 620601,
  ParkourIdleShaderBreath = true,
  ParkourIdleShaderLength = -0.1,
  ParkourRunDashShaderLength = 0.15,
  ParkourRunPhaseOneShaderLength = 0.15,
  ParkourRunPhaseTwoShaderLength = 0.15,
  ParkourRunPhaseThreeShaderLength = 0.15,
  ParkourPedalWallLength = 0.15,
  ParkourRunOriginEnergyConsume1stPhase = 0,
  ParkourRunOriginEnergyConsume2ndPhase = 0,
  ParkourRunOriginEnergyConsume3rdPhase = 0,
  ParkourPedalWallOriginEnergyLimit = 180,
  ParkourPedalWallOriginEnergyConsume = 40,
  ParkourPedalWallLimitAngle = Vector2.New(45, 150),
  ParkourPedalWallEnterAngle = 45,
  ParkourPedalWallEndActionTimeLimit = 0,
  ParkourPedalWallJoystickArea1 = 10,
  ParkourPedalWallJoystickArea2 = 70,
  ParkourPedalWallJoystickArea3 = 90,
  ParkourPedalWallStrideAcrossAngle = Vector2.New(60, 300),
  ParkourPedalWallVelocity = 6,
  ParkourPedalWallRayHight = 1.5,
  ParkourPedalWallRayOffsetHorizontal = 0.4,
  ParkourPedalWallRayOffsetVertical = 0.5,
  ParkourPedalWallRayDistance = 2,
  ParkourPedalWallPlatformWidth = 2,
  ParkourPedalWallAttachWallDistance = 0.3,
  ReverseJumpId = 2,
  FallenJumpId = 3,
  ShimmyJumpId = 4,
  KickWallJumpId = 5,
  FiveJumpId = 6,
  PedalWallEndJumpId = 7,
  PedalWallStopJumpId = 8,
  ParkourRunEnterEffectTime = 1,
  LazyJumpId = 9,
  LazyJumpRayHeight = Vector2.New(0.5, 1.5),
  LazyJumpRayLength = Vector2.New(0.3, 4),
  ParkourPedalWallUpRayLength = 2.5,
  ParkourInsightOriginEnergyLimit = 180,
  ParkourInsightOriginEnergyConsume = 10,
  ParkourFlowOriginEnergyConsume = 1,
  ParkourGlideOriginEnergyConsume = 10,
  FlowOriginEnergyLimit = 30,
  GlideOriginEnergyLimit = 30,
  ParkourHangWallOriginEnergyConsume = 0,
  MoveDashOriginEnergyConsume = 0,
  RushOriginEnergyConsume = 70,
  RunToPedalWallWaitTime = 0.2,
  ParkourPedalWallRaisedObstRayBackDis = 0.2,
  ShimmyJumpCameraBlurIntensity = 0.5,
  ShimmyJumpCameraBlurDistance = 0.3,
  ShimmyJumpCameraBlurPosition = Vector2.New(0.5, 0.5),
  ShimmyJumpCameraBlurMaskParams = {
    0,
    0,
    1,
    0,
    0
  },
  ShimmyJumpCameraBlurFadeInOutTime = {0.1, 0.5},
  ShimmyJumpCameraBlurStep = {
    0,
    1,
    2
  },
  SwimEnergyConsume = 10,
  SwimSprintEnergyConsume = 20,
  EnergyPercentAfterReborn = 50,
  QuickRiseOriginEnergyLimit = 250,
  QuickRiseOriginEnergyConsume = 250,
  ParkourRunWindEffectSpeedLimit = 5,
  PedalWallOverJumpId = 10,
  ParkourPedalWallRaisedBigObstRayBackDis = 1.5,
  LevitationVerticalSpeed = 2,
  LevitationCtrlHorizontalSpeed = 4,
  LevitationOriginEnergyConsume = 200,
  LevitationOriginEnergyLimit = 0,
  QteDotBuff = 682201,
  ShimmyJumpCameraBlurBuffs = {
    0,
    7600200,
    7600200
  },
  PedalWallBreakTime = 0.7,
  PedalWallHangStartMoveTime = 0.3,
  RushOriginEnergyLimit = 300,
  FastMoveToJumpOriginEnergyConsume = 0,
  JumpTurnFront = {-45, 45},
  JumpTurnSideDrop = {
    {
      0,
      8,
      18
    },
    {
      0.1,
      0.3,
      0.6
    }
  },
  JumpTurnBackDrop = {
    {
      0,
      8,
      18
    },
    {
      0.2,
      0.5,
      0.7
    }
  },
  MoveDashBattleOriginEnergyConsume = 120,
  ParkourRunBattleOriginEnergyConsume1stPhase = 20,
  ParkourRunBattleOriginEnergyConsume2ndPhase = 40,
  ParkourRunBattleOriginEnergyConsume3rdPhase = 60
}
return read_onlyHelper.Read_only(GlobalParkour)
