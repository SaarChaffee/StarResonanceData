local read_onlyHelper = require("utility.readonly_helper")
local WorldBossGlobalConfig = {
  WorldBossFunctionId = 800902,
  WorldBossFinalHitAwardId = 11001031,
  WorldBossAwardCountId = 21,
  WorldBossMatchOverTime = 180,
  WorldBossMatchMaxNum = 20,
  WorldBossMatchMinNum = 12,
  WorldBossMatchAiMaxNum = 8,
  WorldBossMatchProfessionLimitNum = {
    {2, 1},
    {3, 1}
  },
  WorldBossPersonalScoreAward = {
    {500, 11001051},
    {1000, 11001052},
    {1500, 11001053},
    {2000, 11001054},
    {2500, 11001055},
    {3000, 11001056},
    {3500, 11001057},
    {4000, 11001058},
    {4500, 11001059},
    {5000, 11001060}
  },
  WorldBossDungeonId = 7150,
  WorldBossPreviewAward = 11001032,
  WorldBossMatchFillProfession = {1},
  WorldBossMonsterId = 20004,
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
    0.5,
    1,
    0
  },
  WorldBossDpsScorePara = {
    1,
    0.2,
    0
  },
  WorldBossHealerScorePara = {
    0.5,
    0.2,
    0.5
  },
  WorldBossOpenChat = {8009002, 8009006}
}
return read_onlyHelper.Read_only(WorldBossGlobalConfig)
