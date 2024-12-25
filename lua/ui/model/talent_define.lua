local DEF = {}
DEF.TalentTagType = {
  Damage = 1,
  Support = 2,
  Tank = 3
}
DEF.TalentType = {
  MainActive = 1,
  SubActive = 2,
  Passive = 3
}
DEF.TalentEffectType = {
  Property = 1,
  Skill = 2,
  Buff = 3,
  BasicAttrEffectCoefficient = 4
}
DEF.TalentSubViewType = {Skill = 1, Mod = 2}
local Red = DEF.TalentTagType.Damage
local Green = DEF.TalentTagType.Support
local Blue = DEF.TalentTagType.Tank
DEF.DefaultColor = Color.New(1, 1, 1, 1)
DEF.LockColor = Color.New(1, 1, 1, 0.3)
DEF.TagUnSelectColor = Color.New(1, 1, 1, 0.7)
DEF.TalentWindowTagEffectConfig = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_red_001",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_green_002",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_blue_003"
}
DEF.TalentTagSelectColor = {
  [Red] = Color.New(1.0, 0.6941176470588235, 0.6941176470588235, 1),
  [Green] = Color.New(0.6470588235294118, 0.9921568627450981, 0.9529411764705882, 1),
  [Blue] = Color.New(0.7137254901960784, 0.8862745098039215, 1.0, 1)
}
DEF.TalentTagUnSelectColor = {
  [Red] = Color.New(1.0, 0.8235294117647058, 0.8235294117647058, 0.30980392156862746),
  [Green] = Color.New(0.8509803921568627, 1.0, 0.9882352941176471, 0.30980392156862746),
  [Blue] = Color.New(0.5411764705882353, 0.5803921568627451, 1.0, 0.30980392156862746)
}
DEF.TalentTagSelectStartEffectConfig = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_select_001_02",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_select_002_02",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_select_003_02"
}
DEF.TalentTagSelectEndEffectConfig = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_select_001_03",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_select_002_03",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_select_003_03"
}
DEF.TalentTagUnSelectStartEffectConfig = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_unselect_red",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_unselect_green",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_unselect_blue"
}
DEF.TalentTagUnSelectEffectConfig = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_color_red_001",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_color_green_001",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_color_blue_001"
}
DEF.TalentTagUnSelectEndTailEffectConfig = {
  [Red] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_color_red_001_02",
  [Green] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_color_green_001_02",
  [Blue] = "ui/uieffect/prefab/ui_sfx_talent_001/ui_sfx_talent_color_blue_001_02"
}
DEF.MainTalentBgColor = {
  [Red] = Color.New(1.0, 0.8431372549019608, 0.7764705882352941, 1),
  [Green] = Color.New(0.7764705882352941, 1.0, 0.9882352941176471, 1),
  [Blue] = Color.New(0.7764705882352941, 0.8862745098039215, 1.0, 1)
}
DEF.TalentUnitSelectColor = {
  [Red] = Color.New(0.5725490196078431, 0.25882352941176473, 0 / 255, 1),
  [Green] = Color.New(0 / 255, 0.396078431372549, 0.34509803921568627, 1),
  [Blue] = Color.New(0 / 255, 0.33725490196078434, 0.5098039215686274, 1)
}
DEF.MainBtnConfig = {
  [1] = "ui/uieffect/prefab/common/ui_sfx_group_select_03_red",
  [2] = "ui/uieffect/prefab/common/ui_sfx_group_select_03_green",
  [3] = "ui/uieffect/prefab/common/ui_sfx_group_select_03_blue"
}
DEF.TagLightBgPath = {
  [Red] = "ui/textures/talent/talent_light_3",
  [Green] = "ui/textures/talent/talent_light_2",
  [Blue] = "ui/textures/talent/talent_light_1"
}
DEF.TagFramePath = {
  [Red] = "ui/atlas/talent/talent_main_skill_frame_3",
  [Green] = "ui/atlas/talent/talent_main_skill_frame_2",
  [Blue] = "ui/atlas/talent/talent_main_skill_frame_1"
}
DEF.TagMainSelectPath = {
  [Red] = "ui/atlas/talent/talent_select_skill_red",
  [Green] = "ui/atlas/talent/talent_select_skill_green",
  [Blue] = "ui/atlas/talent/talent_select_skill_blue"
}
DEF.TagMainSelectIconPath = {
  [1] = "ui/atlas/c_common/com_circle_tab_select_red",
  [2] = "ui/atlas/c_common/com_circle_tab_select_green",
  [3] = "ui/atlas/c_common/com_circle_tab_select_blue"
}
DEF.TagPassiveSelectPath = {
  [Red] = "ui/atlas/talent/talent_passive_frame_red",
  [Green] = "ui/atlas/talent/talent_passive_frame_green",
  [Blue] = "ui/atlas/talent/talent_passive_frame_blue"
}
DEF.MainTalentHighlightPath = {
  [Red] = "ui/atlas/talent/talent_main_skill_light_3",
  [Green] = "ui/atlas/talent/talent_main_skill_light_2",
  [Blue] = "ui/atlas/talent/talent_main_skill_light_1"
}
DEF.SubTalentUsePath = {
  [Red] = "ui/atlas/talent/talent_main_skill_bottom_3",
  [Green] = "ui/atlas/talent/talent_main_skill_bottom_2",
  [Blue] = "ui/atlas/talent/talent_main_skill_bottom_1"
}
DEF.PassiveTalentNumPath = {
  [Red] = "ui/atlas/talent/talent_passive_num_red",
  [Green] = "ui/atlas/talent/talent_passive_num_green",
  [Blue] = "ui/atlas/talent/talent_passive_num_blue"
}
DEF.TalentEmptyTagIcon = "ui/atlas/talent/talent_tag_small_icon_empty"
DEF.UnrealSceneStyle = {
  [Red] = E.UnrealSceneStyle.Red,
  [Green] = E.UnrealSceneStyle.Green,
  [Blue] = E.UnrealSceneStyle.Blue
}
DEF.SelectTalentUnrealSceneStyle = {
  [Red] = E.UnrealSceneStyle.TalentRed,
  [Green] = E.UnrealSceneStyle.TalentGreen,
  [Blue] = E.UnrealSceneStyle.TalentBlue
}
DEF.LONG_PRESS_INTERVAL = 0.3
DEF.Enum_Step = {
  None = -1,
  HadSelect = 0,
  SelectMainTalent = 1,
  SelectSubTalent = 2,
  SelectPassiveTalent = 3
}
DEF.Enum_State = {
  None = -1,
  InPool_None = 0,
  InPool_Sub = 1,
  InPool_Passive = 2,
  InPool_Sub_Passive = 3,
  NotPool_Init_None = 4,
  NotPool_Init_Sub = 5,
  NotPool_Init_Passive = 6,
  NotPool_Init_Sub_Passive = 7,
  NotPool_None = 8,
  NotPool_Sub = 9,
  NotPool_Passive = 10,
  NotPool_Sub_Passive = 11
}
return DEF
