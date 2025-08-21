local DEF = {}
DEF.UnlockSkillUIRotRange = {Min = 79, Max = -79}
DEF.TalentAttrInfoSubViewType = {
  Weapon = 1,
  Skill = 2,
  Talent = 3,
  DefaultSkill = 4,
  TalentBD = 5
}
DEF.TalentTreePrefabPath = "ui/prefabs/talent_new/talent_tree_%s_%s_%s"
DEF.TalentTreeMaxStage = 2
DEF.TalentTreeStageIconPath = {
  [1] = "ui/atlas/talent/talent_class_1",
  [2] = "ui/atlas/talent/talent_class_2",
  [3] = "ui/atlas/talent/talent_class_3"
}
DEF.TalentSkillWindowAdornIconPath = {
  [1] = "ui/textures/weaopn/weapon_adorn",
  [2] = "ui/textures/weaopn/weapon_adorn_light"
}
DEF.TalentTreeUnitEffectType = {
  Basic = 1,
  Buff = 3,
  BasicAttrEffectCoefficient = 4,
  TempBasic = 5,
  ReplaceSpecialAttack = 6
}
DEF.TalentTreeUnitType = {
  Attr = 1,
  BigAttr = 2,
  Buff = 3,
  BigBuff = 4,
  Special = 5
}
DEF.TalentTreeUnitIconPath = {
  [DEF.TalentTreeUnitType.Attr] = {
    img_off_active = "ui/atlas/talent/talent_base_noactive",
    img_off_active_select = "ui/atlas/talent/talent_base_on",
    img_on_active = "ui/atlas/talent/talent_base_active",
    img_on_active_select = "ui/atlas/talent/talent_base_active_on"
  },
  [DEF.TalentTreeUnitType.BigAttr] = {
    img_off_active = "ui/atlas/talent/talent_base_noactive",
    img_off_active_select = "ui/atlas/talent/talent_base_on",
    img_on_active = "ui/atlas/talent/talent_base_active",
    img_on_active_select = "ui/atlas/talent/talent_base_active_on"
  },
  [DEF.TalentTreeUnitType.Buff] = {
    img_off_active = "ui/atlas/talent/talent_base_buff_noactive",
    img_off_active_select = "ui/atlas/talent/talent_base_buff_on",
    img_on_active = "ui/atlas/talent/talent_base_buff_active",
    img_on_active_select = "ui/atlas/talent/talent_base_buff_active_on"
  },
  [DEF.TalentTreeUnitType.BigBuff] = {
    img_off_active = "ui/atlas/talent/talent_base_buff_noactive",
    img_off_active_select = "ui/atlas/talent/talent_base_buff_on",
    img_on_active = "ui/atlas/talent/talent_base_buff_active",
    img_on_active_select = "ui/atlas/talent/talent_base_buff_active_on"
  }
}
DEF.TalentTreeUnitState = {
  NoActive = 0,
  NoActiveSelect = 1,
  Active = 2,
  ActiveSelect = 3
}
DEF.TalentTagType = {
  Damage = 1,
  Support = 2,
  Tank = 3
}
local Red = DEF.TalentTagType.Damage
local Green = DEF.TalentTagType.Support
local Blue = DEF.TalentTagType.Tank
DEF.SelectTalentUnrealSceneStyle = {
  [Red] = 1,
  [Green] = 2,
  [Blue] = 0
}
DEF.TalentWindowMiddelRimg = {
  [Red] = Color.New(1.0, 0.6745098039215687, 0.3803921568627451, 1),
  [Green] = Color.New(0 / 255, 1.0, 0.5176470588235295, 1),
  [Blue] = Color.New(0.4666666666666667, 1.0, 0.9019607843137255, 1)
}
DEF.TalentWindowCharacerLeftRimg = "ui/textures/talent_new/talent_bg_left_"
DEF.TalentWindowCharacerRightRimg = "ui/textures/talent_new/talent_bg_right_"
DEF.TalentWindowAnim = "talent_skill_window_anim_"
DEF.TalentWindowTreeBg = {
  SmallBg = {
    [Red] = {
      Active = "ui/atlas/talent/talent_icon_active",
      Unactive = "ui/atlas/talent/talent_icon_active",
      Select = "ui/atlas/talent/talent_select_red"
    },
    [Green] = {
      Active = "ui/atlas/talent/talent_icon_active",
      Unactive = "ui/atlas/talent/talent_icon_active",
      Select = "ui/atlas/talent/talent_select_green"
    },
    [Blue] = {
      Active = "ui/atlas/talent/talent_icon_active",
      Unactive = "ui/atlas/talent/talent_icon_active",
      Select = "ui/atlas/talent/talent_select_blue"
    }
  },
  BigBg = {
    [Red] = {
      Active = "ui/atlas/talent/talent_icon_red",
      Unactive = "ui/atlas/talent/talent_icon_red",
      Select = "ui/atlas/talent/talent_select_red"
    },
    [Green] = {
      Active = "ui/atlas/talent/talent_icon_green",
      Unactive = "ui/atlas/talent/talent_icon_green",
      Select = "ui/atlas/talent/talent_select_green"
    },
    [Blue] = {
      Active = "ui/atlas/talent/talent_icon_blue",
      Unactive = "ui/atlas/talent/talent_icon_blue",
      Select = "ui/atlas/talent/talent_select_blue"
    }
  },
  Special = {
    [Red] = {
      Active = "ui/atlas/talent/talent_icon_genre",
      Unactive = "ui/atlas/talent/talent_icon_genre",
      Select = "ui/atlas/talent/talent_select2_red"
    },
    [Green] = {
      Active = "ui/atlas/talent/talent_icon_genre",
      Unactive = "ui/atlas/talent/talent_icon_genre",
      Select = "ui/atlas/talent/talent_select2_green"
    },
    [Blue] = {
      Active = "ui/atlas/talent/talent_icon_genre",
      Unactive = "ui/atlas/talent/talent_icon_genre",
      Select = "ui/atlas/talent/talent_select2_blue"
    }
  }
}
DEF.TalentSkillWeaponLevelUpEffect = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jihuo_hit_001_shengji_red",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jihuo_hit_001_shengji_green",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jihuo_hit_001_shengji_blue"
}
DEF.TalentSkillWeaponOpenEffect = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_skill_hit_01_red",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_skill_hit_01_green",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_skill_hit_01_blue"
}
DEF.TalentSkillUnitActiveEffect = {
  [1] = {
    [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jd_up_hit_red",
    [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jd_up_hit_green",
    [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jd_up_hit_bule"
  },
  [2] = {
    [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jd_up_hit_red_s",
    [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jd_up_hit_green_s",
    [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_jd_up_hit_bule_s"
  }
}
DEF.TalentSkillTreeNodeSelectEffect = {
  [1] = {
    [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_item_glow_02_red",
    [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_item_glow_02_green",
    [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_item_glow_02_blue"
  },
  [2] = {
    [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_item_glow_01_red",
    [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_item_glow_01_green",
    [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_group_talent_item_glow_01_blue"
  }
}
DEF.TalentSkillMaskIconPath = {
  [1] = "ui/atlas/talent/talent_mask_circle",
  [2] = "ui/atlas/talent/talent_mask_hexagon"
}
return DEF
