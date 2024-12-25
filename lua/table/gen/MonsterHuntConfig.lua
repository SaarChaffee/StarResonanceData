local read_onlyHelper = require("utility.readonly_helper")
local MonsterHuntConfig = {
  MonsterHuntEliteKeyCountId = 11,
  MonsterHuntBossKeyCountId = 12,
  MonsterHuntEliteBootyKeyId = 1070003,
  MonsterHuntBossBootyKeyId = 1070004,
  MonsterHuntEliteBootyKeyMaxNum = 9,
  MonsterHuntBossBootyKeyMaxNum = 3,
  MonsterHuntExpItemId = 20002,
  MonsterHuntTreasureBoxDisappearTime = 120,
  MonsterHuntBossMinScore = 2,
  MonsterHuntBossMvpEffect = "effect/common_new/p_fx_common_jisha",
  MonsterHuntBossDropAwardCountId = 23,
  MonsterHuntBossMvpEffectBandPoint = "ep_buff01_point",
  MonsterHuntBossMvpEffectDestroyTime = 5
}
return read_onlyHelper.Read_only(MonsterHuntConfig)
