local DEF = {}
local ModelMountPointName = Panda.ZGame.EModelMountPointName
DEF.Model_Effect_Path_Config = {
  [1] = "effect/common_new/buff/p_fx_common_moster_blue_fantasy_%s_point",
  [2] = "effect/common_new/buff/p_fx_common_moster_purple_fantasy_%s_point",
  [3] = "effect/common_new/buff/p_fx_common_moster_colorful_fantasy_%s_point",
  [4] = "effect/common_new/buff/p_fx_common_moster_golden_fantasy_%s_point"
}
DEF.Model_Effect_Config = {
  {
    MountPointName = ModelMountPointName.EFF_HEAD_J,
    MountPointKey = "head_j"
  },
  {
    MountPointName = ModelMountPointName.EFF_SPINE2_J,
    MountPointKey = "spine2_j"
  },
  {
    MountPointName = ModelMountPointName.EFF_HIP_J,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.ARM_LEFT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.ARM_RIGHT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.FOREARM_LEFT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.FOREARM_RIGHT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.UP_LEG_LEFT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.UP_LEG_RIGHT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.LEG_LEFT,
    MountPointKey = "other"
  },
  {
    MountPointName = ModelMountPointName.LEG_RIGHT,
    MountPointKey = "other"
  }
}
return DEF
