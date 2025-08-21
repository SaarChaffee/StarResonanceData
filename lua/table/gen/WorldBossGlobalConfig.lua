local read_onlyHelper = require("utility.readonly_helper")
local WorldBossGlobalConfig = {
  WorldBossFunctionId = 800902,
  WorldBossFinalHitAwardId = 11001031,
  WorldBossAwardCountId = 21,
  WorldBossMatchOverTime = 120,
  WorldBossMatchMaxNum = 20,
  WorldBossMatchMinNum = 12,
  WorldBossMatchAiMaxNum = 8,
  WorldBossMatchProfessionLimitNum = {
    {2, 1},
    {3, 1}
  },
  WorldBossPersonalScoreAward = {
    {300, 11001051},
    {600, 11001052},
    {900, 11001053},
    {1200, 11001054}
  },
  WorldBossDungeonId = 12050,
  WorldBossPreviewAward = 20110130,
  WorldBossMatchFillProfession = {1},
  WorldBossMonsterId = 1205001,
  WorldBossOpenTimerId = 220,
  WorldBossPreOpenTimerId = 221,
  WorldBossAwardResetTimerId = 222,
  WorldBossConfirmTime = 30,
  WorldBossRankItem = 1071003,
  WorldBossRankAward = 3,
  WorldBossScoreItemId = 20010,
  WorldBossMinContribute = 1000,
  WorldBossStageAutoPlus = {540, 1},
  WorldBossPersonalScoreMailId = 1211,
  WorldBossStageMailId = 1212,
  WorldBossMatchMaxTime = 300,
  WorldBossTankScorePara = {
    2.5,
    0,
    0
  },
  WorldBossDpsScorePara = {
    1,
    0,
    0
  },
  WorldBossHealerScorePara = {
    1,
    0,
    0.12
  },
  WorldBossOpenChat = {8009002, 8009006}
}
return read_onlyHelper.Read_only(WorldBossGlobalConfig)
