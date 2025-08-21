local config_mt = {
  __index = {
    PCLuaFileName = "",
    Layer = Z.UI.ELayer.UILayerFunc,
    ViewType = Z.UI.EType.Standalone,
    CacheLv = Z.UI.ECacheLv.None,
    AudioGameState = E.AudioGameState.None,
    SceneMaskType = Z.UI.ESceneMaskType.None,
    CameraState = E.CameraState.None,
    IsFullScreen = false,
    IgnoreFocus = false,
    ShowMouse = true,
    IsUnrealScene = false,
    IgnoreBack = false,
    IsRefreshSteer = true,
    IsHavePCUI = false
  }
}
local UIConfig = {
  acquiretip = {
    LuaFileName = "acquiretip_view",
    PrefabPath = "tv/tv_acquiretip",
    Layer = Z.UI.ELayer.UILayerTip,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IsRefreshSteer = false,
    IsHavePCUI = true
  },
  tv_acquiretip_special = {
    LuaFileName = "tv_acquiretip_special_view",
    PrefabPath = "tv/tv_acquiretip_special",
    Layer = Z.UI.ELayer.UILayerTip,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IsRefreshSteer = false,
    IsHavePCUI = true
  },
  album_create_popup = {
    LuaFileName = "album_create_popup_view",
    PrefabPath = "photograph/album_create_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  album_main = {
    LuaFileName = "album_main_view",
    PrefabPath = "photograph/album_main",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  album_mobile_album = {
    LuaFileName = "album_mobile_album_view",
    PrefabPath = "photograph/album_mobile_album",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  album_photo_show = {
    LuaFileName = "album_photo_show_view",
    PrefabPath = "photograph/album_photo_show_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  album_storage_tips = {
    LuaFileName = "album_storage_tips_view",
    PrefabPath = "photograph/album_storage_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    IgnoreBack = true
  },
  all_item_info_tips = {
    LuaFileName = "all_item_info_tips_view",
    PrefabPath = "tips/all_item_info_tips",
    Layer = Z.UI.ELayer.UILayerTipTop,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_title_content = {
    LuaFileName = "tips_title_content_view",
    PrefabPath = "common_tips_new/tips_title_content",
    Layer = Z.UI.ELayer.UILayerTipTop,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_content = {
    LuaFileName = "tips_content_view",
    PrefabPath = "common_tips_new/tips_content",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_richtext = {
    LuaFileName = "tips_richtext_view",
    PrefabPath = "common_tips_new/tips_richtext",
    Layer = Z.UI.ELayer.UILayerTipTop,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_underline = {
    LuaFileName = "tips_underline_view",
    PrefabPath = "common_tips_new/tips_underline",
    Layer = Z.UI.ELayer.UILayerTipTop,
    ShowMouse = false
  },
  common_skill_tips = {
    LuaFileName = "common_skill_tips_view",
    PrefabPath = "common_tips_new/common_skill_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_title_content_btn = {
    LuaFileName = "tips_title_content_btn_view",
    PrefabPath = "helpsys/tips_title_content_btn",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_title_content_items = {
    LuaFileName = "tips_title_content_items_view",
    PrefabPath = "common_tips_new/tips_title_content_items",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_exp = {
    LuaFileName = "tips_exp_view",
    PrefabPath = "common_tips_new/tips_exp",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_monsters = {
    LuaFileName = "tips_monsters_view",
    PrefabPath = "trialroad/tips_monsters",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_approach = {
    LuaFileName = "tips_approach_view",
    PrefabPath = "equip/tips_approach",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_icontitle_content = {
    LuaFileName = "tips_icontitle_content_view",
    PrefabPath = "equip/tips_icontitle_content",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_title_content_items_btn = {
    LuaFileName = "tips_title_content_items_btn_view",
    PrefabPath = "expression/tips_title_content_items_btn",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  tips_rolelevelitems = {
    LuaFileName = "tips_rolelevelitems_view",
    PrefabPath = "rolelevel/tips_rolelevelitems",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  backpack_main = {
    LuaFileName = "backpack_main_view",
    PrefabPath = "bag/bag_backpack_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  bag_selectpack_popup = {
    LuaFileName = "bag_selectpack_popup_view",
    PrefabPath = "bag/bag_selectpack_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  bag_selectpack_popup_new = {
    LuaFileName = "bag_selectpack_popup_new_view",
    PrefabPath = "bag/bag_selectpack_popup_new",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  battle_hit = {
    LuaFileName = "battle_hit_view",
    PrefabPath = "battle/battle_hit_tpl"
  },
  bossbattle = {
    LuaFileName = "bossbattle_view",
    PrefabPath = "battle/battle_boss_blood_sub",
    Layer = Z.UI.ELayer.UILayerMain,
    CacheLv = Z.UI.ECacheLv.High,
    AudioGameState = E.AudioGameState.Ingame,
    IgnoreFocus = true,
    ShowMouse = false,
    IsRefreshSteer = false,
    IsHavePCUI = true
  },
  camerasys = {
    LuaFileName = "camerasys_view",
    PrefabPath = "photograph/camerasys_main",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame
  },
  camera_photo_main = {
    LuaFileName = "camera_photo_main_view",
    PrefabPath = "photograph/camera_photo_main",
    AudioGameState = E.AudioGameState.Ingame,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  camera_config_popup = {
    LuaFileName = "camera_config_popup_view",
    PrefabPath = "photograph/camera_config_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  camera_photo_album_window = {
    LuaFileName = "camera_photo_album_window_view",
    PrefabPath = "photograph/camera_photo_album_window",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  camera_photo_details = {
    LuaFileName = "camera_photo_details_view",
    PrefabPath = "photograph/camera_photo_details_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  photo_editing = {
    LuaFileName = "photo_editing_view",
    PrefabPath = "photograph/photo_editing_window",
    AudioGameState = E.AudioGameState.Ingame,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  photo_txt_input = {
    LuaFileName = "photo_txt_input_view",
    PrefabPath = "n_prefab/com_input_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  characterinfo_gather = {
    LuaFileName = "characterinfo_gather_view",
    PrefabPath = "role_info/character_gather_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu
  },
  chat_emoji_container_popup = {
    LuaFileName = "chat_emoji_container_popup_view",
    PrefabPath = "chat/chat_emoji_container_popup",
    IsHavePCUI = true
  },
  chat_setting_popup = {
    LuaFileName = "chat_setting_popup_view",
    PrefabPath = "chat/chat_setting_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  combo = {
    LuaFileName = "combo_view",
    PrefabPath = "battle/battle_combo_tpl"
  },
  common_popup_input = {
    LuaFileName = "common_popup_input_view",
    PrefabPath = "commonui/common_popup_input",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  compose = {
    LuaFileName = "compose_view",
    PrefabPath = "compose/compose_main",
    ViewType = Z.UI.EType.Exclusive
  },
  tips_item_submit_popup = {
    LuaFileName = "tips_item_submit_popup_view",
    PrefabPath = "tips/tips_item_submit_popup",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Cutscene,
    IgnoreBack = true
  },
  tips_item_reward_popup = {
    LuaFileName = "tips_item_reward_popup_view",
    PrefabPath = "common_tips/tips_item_reward_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false
  },
  cutscene_main = {
    LuaFileName = "cutscene_main_view",
    PrefabPath = "cutscene/cutscene_main",
    Layer = Z.UI.ELayer.UILayerDramaTop,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Cutscene,
    ShowMouse = false,
    IgnoreBack = true
  },
  cutscene_bottom = {
    LuaFileName = "cutscene_bottom_view",
    PrefabPath = "cutscene/cutscene_bottom",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Cutscene,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  cutscene_qte_main = {
    LuaFileName = "cutscene_qte_main_view",
    PrefabPath = "cutscene/cutscene_qte_main",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  c_com_select_use_popup = {
    LuaFileName = "c_com_select_use_popup_view",
    PrefabPath = "n_prefab/c_com_select_use_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  dead = {
    LuaFileName = "dead_view",
    PrefabPath = "dead/dead_window",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    IgnoreBack = true,
    IsHavePCUI = true
  },
  dead_property_popup = {
    LuaFileName = "dead_property_popup_view",
    PrefabPath = "dead/dead_property_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  dialog = {
    LuaFileName = "dialog_view",
    PrefabPath = "tips/tips_common_popup",
    Layer = Z.UI.ELayer.UILayerTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  sys_dialog = {
    LuaFileName = "sys_dialog_view",
    PrefabPath = "tips/tips_sys_dialog",
    Layer = Z.UI.ELayer.UILayerSystemTip,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  common_recharge_pop = {
    LuaFileName = "common_recharge_pop_view",
    PrefabPath = "recharge/common_recharge_pop",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  dmg_control = {
    LuaFileName = "dmg/dmg_control_view",
    PrefabPath = "dmg/dmg_control",
    ViewType = Z.UI.EType.Permanent,
    ShowMouse = false
  },
  dmg_data_panel = {
    LuaFileName = "dmg/dmg_data_panel_view",
    PrefabPath = "dmg/dmg_data_panel",
    ViewType = Z.UI.EType.Permanent,
    ShowMouse = false
  },
  dungeon_main = {
    LuaFileName = "dungeon_main_view",
    PrefabPath = "dungeon/dungeon_main",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  dungeon_main_window = {
    LuaFileName = "dungeon_main_window_view",
    PrefabPath = "dungeon/dungeon_main",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  dungeon_monster_affix_tips = {
    LuaFileName = "dungeon_monster_affix_tips_view",
    PrefabPath = "dungeon/dungeon_monster_affix_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IsHavePCUI = true
  },
  world_boss_main = {
    LuaFileName = "world_boss_main_view",
    PrefabPath = "worldboss/world_boss_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  world_boss_matching = {
    LuaFileName = "world_boss_matching_view",
    PrefabPath = "worldboss/world_boss_matching",
    Layer = Z.UI.ELayer.UILayerTop,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IgnoreBack = true
  },
  common_matching = {
    LuaFileName = "common_matching_view",
    PrefabPath = "match/common_matching",
    Layer = Z.UI.ELayer.UILayerTop,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IgnoreBack = true
  },
  world_boss_settlement = {
    LuaFileName = "world_boss_settlement_view",
    PrefabPath = "worldboss/world_boss_settlement",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  world_boss_bonus_points_popup = {
    LuaFileName = "world_boss_bonus_points_popup_view",
    PrefabPath = "worldboss/world_boss_bonus_points_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  world_boss_full_schedule_popup = {
    LuaFileName = "world_boss_full_schedule_popup_view",
    PrefabPath = "worldboss/world_boss_full_schedule_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  equip_change_window = {
    LuaFileName = "equip_change_window_view",
    PrefabPath = "equip/equip_change_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    CameraState = E.CameraState.MiscSystem,
    IsHavePCUI = true
  },
  equip_function = {
    LuaFileName = "equip_function_view",
    PrefabPath = "equip/equip_function_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  resonacne_power_decompose_acquire = {
    LuaFileName = "resonacne_power_decompose_acquire_view",
    PrefabPath = "rolelevel/rolelevel_obtain_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weapon_develop_intensify_window = {
    LuaFileName = "weapon_develop_intensify_window_view",
    PrefabPath = "weapon_develop/weapon_develop_intensify_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  exchange_main = {
    LuaFileName = "exchange_main_view",
    PrefabPath = "compose/exchange_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu
  },
  expression = {
    LuaFileName = "expression_view",
    PrefabPath = "expression/expression_window",
    AudioGameState = E.AudioGameState.Ingame
  },
  face_rolechoose_window = {
    LuaFileName = "face_rolechoose_window_view",
    PrefabPath = "face/face_rolechoose_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true
  },
  face_create = {
    LuaFileName = "face_create_view",
    PrefabPath = "face/face_create",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  face_edit = {
    LuaFileName = "face_edit_view",
    PrefabPath = "face/face_edit_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  face_gender_window = {
    LuaFileName = "face_gender_window_view",
    PrefabPath = "face/face_gender_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  face_system = {
    LuaFileName = "face_system_view",
    PrefabPath = "face/face_system_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  face_unlock_popup = {
    LuaFileName = "face_unlock_popup_view",
    PrefabPath = "face/face_unlock_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  fade_window = {
    LuaFileName = "fade_window_view",
    PrefabPath = "fade/fade_window",
    Layer = Z.UI.ELayer.UILayerSystem,
    ViewType = Z.UI.EType.Permanent,
    CacheLv = Z.UI.ECacheLv.High,
    IgnoreBack = true
  },
  fashion_face_window = {
    LuaFileName = "fashion_face_window_view",
    PrefabPath = "fashion/fashion_system_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  fashion_save_confirm_popup = {
    LuaFileName = "fashion_save_confirm_popup_view",
    PrefabPath = "fashion/fashion_save_confirm_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  fashion_system = {
    LuaFileName = "fashion_system_view",
    PrefabPath = "fashion/fashion_system_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  gm_item_popup = {
    LuaFileName = "gm/gm_item_popup_view",
    PrefabPath = "gm/gm_item_popup",
    Layer = Z.UI.ELayer.UILayerDebug,
    ShowMouse = false
  },
  gm_main = {
    LuaFileName = "gm/gm_main_view",
    PrefabPath = "gm/gm_main",
    Layer = Z.UI.ELayer.UILayerDebug,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  gm = {
    LuaFileName = "gm/gm_view",
    PrefabPath = "gm/gm_window",
    Layer = Z.UI.ELayer.UILayerDebug
  },
  gm_fashion_popup = {
    LuaFileName = "gm/gm_fashion_popup_view",
    PrefabPath = "gm/gm_fashion_popup",
    Layer = Z.UI.ELayer.UILayerDebug,
    ShowMouse = false
  },
  helpsys_popup01 = {
    LuaFileName = "helpsys_popup01_view",
    PrefabPath = "helpsys/helpsys_illustrate_window",
    Layer = Z.UI.ELayer.UILayerTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  helpsys_popup02 = {
    LuaFileName = "helpsys_popup02_view",
    PrefabPath = "helpsys/helpsys_list_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  helpsys_popup_entrance_tpl = {
    LuaFileName = "helpsys_popup_entrance_tpl_view",
    PrefabPath = "helpsys/helpsys_popup_entrance_tpl",
    IgnoreFocus = true,
    ShowMouse = false,
    IsHavePCUI = true
  },
  helpsys_window = {
    LuaFileName = "helpsys_window_view",
    PrefabPath = "helpsys/helpsys_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  hero_dungeon_copy_window = {
    LuaFileName = "hero_dungeon_copy_window_view",
    PrefabPath = "hero_dungeon/hero_dungeon_settled_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IgnoreBack = true
  },
  hero_dungeon_main = {
    LuaFileName = "hero_dungeon_main_view",
    PrefabPath = "hero_dungeon/hero_dungeon_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  hero_dungeon_praise_window = {
    LuaFileName = "hero_dungeon_praise_window_view",
    PrefabPath = "hero_dungeon/hero_dungeon_praise_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IgnoreBack = true
  },
  idcard = {
    LuaFileName = "idcard_view",
    PrefabPath = "idcard/idcard_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsHavePCUI = true
  },
  investigation_clue_window = {
    LuaFileName = "investigation_clue_window_view",
    PrefabPath = "investigation/investigation_clue_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  item_shortcuts_popup = {
    LuaFileName = "item_shortcuts_popup_view",
    PrefabPath = "bag/item_shortcuts_popup",
    IgnoreFocus = true
  },
  loading_window = {
    LuaFileName = "loading_window_view",
    PrefabPath = "loading/loading_window",
    Layer = Z.UI.ELayer.UILayerSystemTip,
    ViewType = Z.UI.EType.Permanent,
    CacheLv = Z.UI.ECacheLv.High,
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IgnoreBack = true,
    IsHavePCUI = true
  },
  login_affiche_popup = {
    LuaFileName = "login_affiche_popup_view",
    PrefabPath = "login/login_affiche_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  login_agreement_popup = {
    LuaFileName = "login_agreement_popup_view",
    PrefabPath = "login/login_agreement_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    AudioGameState = E.AudioGameState.Menu,
    IgnoreBack = true
  },
  login = {
    LuaFileName = "login_view",
    PrefabPath = "login/login_main",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    IsFullScreen = true,
    IgnoreBack = true
  },
  mainui_funcs_list = {
    LuaFileName = "mainui_funcs_list_view",
    PrefabPath = "main/main_funcs_list_window",
    Layer = Z.UI.ELayer.UILayerMain,
    AudioGameState = E.AudioGameState.Ingame,
    IsHavePCUI = true
  },
  main_line_window = {
    LuaFileName = "main_line_window_view",
    PrefabPath = "line/main_line_window",
    Layer = Z.UI.ELayer.UILayerMain,
    AudioGameState = E.AudioGameState.Ingame
  },
  fishing_main_window = {
    LuaFileName = "fishing_main_window_view",
    PrefabPath = "fishing/fishing_main_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    ShowMouse = false,
    IsHavePCUI = true
  },
  fishing_func_main_window = {
    LuaFileName = "fishing_func_main_window_view",
    PrefabPath = "fishing/fishing_func_main_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  fishing_obtain_window = {
    LuaFileName = "fishing_obtain_window_view",
    PrefabPath = "fishing/fishing_obtain_window",
    ViewType = Z.UI.EType.Exclusive,
    CacheLv = Z.UI.ECacheLv.Low,
    AudioGameState = E.AudioGameState.Ingame
  },
  fishing_study_popup = {
    LuaFileName = "fishing_study_popup_view",
    PrefabPath = "fishing/fishing_study_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  fishing_acquire_window = {
    LuaFileName = "fishing_acquire_window_view",
    PrefabPath = "fishing/fishing_acquire_window",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  fishing_archives_window = {
    LuaFileName = "fishing_archives_window_view",
    PrefabPath = "fishing/fishing_archives_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  fishing_reward_popup = {
    LuaFileName = "fishing_reward_popup_view",
    PrefabPath = "fishing/fishing_reward_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  fishing_share_illustrate_window = {
    LuaFileName = "fishing_share_illustrate_window_view",
    PrefabPath = "fishing/fishing_share_illustrate_window",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  fishing_share_ranking_window = {
    LuaFileName = "fishing_share_ranking_window_view",
    PrefabPath = "fishing/fishing_share_ranking_window",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  mainui = {
    LuaFileName = "mainui_view",
    PrefabPath = "main/main_main",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    CacheLv = Z.UI.ECacheLv.High,
    AudioGameState = E.AudioGameState.Ingame,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  main_chat = {
    LuaFileName = "main_chat_view",
    PrefabPath = "main/main_chat_tpl",
    Layer = Z.UI.ELayer.UILayerMain,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsHavePCUI = true
  },
  main_chat_pc = {
    LuaFileName = "main_chat_pc_view",
    PrefabPath = "main/chat/main_chat_pc",
    Layer = Z.UI.ELayer.UILayerMain,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  main_waiting_tips = {
    LuaFileName = "main_waiting_tips_view",
    PrefabPath = "main/main_waiting_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  map_clock_window = {
    LuaFileName = "map_clock_window_view",
    PrefabPath = "map/map_clock_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  map_lock_main = {
    LuaFileName = "map_lock_main_view",
    PrefabPath = "map/map_lock_main",
    Layer = Z.UI.ELayer.UILayerMain,
    AudioGameState = E.AudioGameState.Ingame
  },
  map_main = {
    LuaFileName = "map_main_view",
    PrefabPath = "map/map_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  worldquest_interactive_window = {
    LuaFileName = "worldquest_interactive_window_view",
    PrefabPath = "worldquest/worldquest_interactive_window",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true
  },
  worldquest_main_window = {
    LuaFileName = "worldquest_main_window_view",
    PrefabPath = "worldquest/worldquest_main_window",
    ViewType = Z.UI.EType.Exclusive
  },
  mark_main = {
    LuaFileName = "mark_main_view",
    PrefabPath = "mark/mark_main",
    Layer = Z.UI.ELayer.UILayerMark,
    ViewType = Z.UI.EType.Permanent,
    CacheLv = Z.UI.ECacheLv.High,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsHavePCUI = true
  },
  name_window = {
    LuaFileName = "name_window_view",
    PrefabPath = "name/name_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    IgnoreBack = true
  },
  rename_window = {
    LuaFileName = "rename_window_view",
    PrefabPath = "name/rename_window",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  noticetip_copy = {
    LuaFileName = "noticetip_copy_view",
    PrefabPath = "tips/tips_noticetip_copy_window",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false
  },
  noticetip_middle_popup = {
    LuaFileName = "noticetip_middle_popup_view",
    PrefabPath = "tips/tips_noticetip_middle_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  noticetip_pop = {
    LuaFileName = "noticetip_pop_view",
    PrefabPath = "tips/tips_noticetip_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  parkour_tooltip_window = {
    LuaFileName = "parkour_tooltip_window_view",
    PrefabPath = "parkour/parkour_tooltip_window",
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  pivot_reward_empty = {
    LuaFileName = "pivot_reward_empty_view",
    PrefabPath = "pivot/pivot_reward_empty",
    ViewType = Z.UI.EType.Exclusive
  },
  pub_talk_option_window = {
    LuaFileName = "pub_talk_option_window_view",
    PrefabPath = "pub/pub_talk_option_window",
    Layer = Z.UI.ELayer.UILayerTip
  },
  qte = {LuaFileName = "qte_view", PrefabPath = "qte/qte"},
  quest_detail = {
    LuaFileName = "quest_task/quest_detail_view",
    PrefabPath = "quest/quest_detail_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  quest_season_window = {
    LuaFileName = "quest_season_window_view",
    PrefabPath = "quest/quest_season_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  questionnaire_banner_popup = {
    LuaFileName = "questionnaire_banner_popup_view",
    PrefabPath = "questionnaire/questionnaire_banner_popup",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  refine_dialog = {
    LuaFileName = "refine_dialog_view",
    PrefabPath = "refine/refine_dialog_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  refine_system = {
    LuaFileName = "refine_system_view",
    PrefabPath = "refine/refine_system_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  reward_preview_popup = {
    LuaFileName = "reward_preview_popup_view",
    PrefabPath = "n_prefab/com_reward_preview_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  rolelevel_mian = {
    LuaFileName = "rolelevel_mian_view",
    PrefabPath = "rolelevel/rolelevel_mian",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  competency_rating_main = {
    LuaFileName = "competency_rating_main_view",
    PrefabPath = "competency_rating/competency_rating_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  rolelevel_acquire_window = {
    LuaFileName = "rolelevel_acquire_window_view",
    PrefabPath = "rolelevel/rolelevel_acquire_window",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  main_upgrade_window = {
    LuaFileName = "main_upgrade_window_view",
    PrefabPath = "main/main_upgrade_window",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false,
    IsRefreshSteer = false,
    IsHavePCUI = true
  },
  rolelevel_way_window = {
    LuaFileName = "rolelevel_way_window_view",
    PrefabPath = "rolelevel/rolelevel_way_window",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  trialroad_main = {
    LuaFileName = "trialroad_main_view",
    PrefabPath = "trialroad/trialroad_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  trialroad_grade_popup = {
    LuaFileName = "trialroad_grade_popup_view",
    PrefabPath = "trialroad/trialroad_grade_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  trialroad_closing_window = {
    LuaFileName = "trialroad_closing_window_view",
    PrefabPath = "trialroad/trialroad_closing_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  trialroad_battle_failure_window = {
    LuaFileName = "trialroad_battle_failure_window_view",
    PrefabPath = "trialroad/trialroad_battle_failure_window",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IgnoreBack = true
  },
  role_info_attr_detail = {
    LuaFileName = "role_info_attr_detail_view",
    PrefabPath = "role_info/role_info_attr_detail_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  screeneffect = {
    LuaFileName = "screeneffect_view",
    PrefabPath = "screeneffect",
    Layer = Z.UI.ELayer.UILayerSystem,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  setting = {
    LuaFileName = "setting_view",
    PrefabPath = "set/setting_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  socialize_main = {
    LuaFileName = "socialize_main_view",
    PCLuaFileName = "socialize_main_pc_view",
    PrefabPath = "socialize/socialize_main",
    AudioGameState = E.AudioGameState.Ingame,
    IsHavePCUI = true
  },
  socialize_main_pc = {
    LuaFileName = "socialize_main_pc_view",
    PrefabPath = "socialize/socialize_main_pc",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame
  },
  steer_tips_window = {
    LuaFileName = "steer_tips_window_view",
    PrefabPath = "steer/steer_tips_window",
    Layer = Z.UI.ELayer.UILayerGuide,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  talk_dialog_window = {
    LuaFileName = "talk_dialog_window_view",
    PrefabPath = "npc/talk_dialog_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Dialogue,
    ShowMouse = false,
    IgnoreBack = true
  },
  talk_info_window = {
    LuaFileName = "talk_info_window_view",
    PrefabPath = "npc/talk_info_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Dialogue,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  quest_letter_window = {
    LuaFileName = "quest_letter_window_view",
    PrefabPath = "quest/quest_letter_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Dialogue,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IgnoreBack = true
  },
  quest_chapter_window = {
    LuaFileName = "quest_task/quest_chapter_window_view",
    PrefabPath = "quest/quest_chapter_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Dialogue,
    SceneMaskType = Z.UI.ESceneMaskType.Normal
  },
  talk_main = {
    LuaFileName = "talk_main_view",
    PrefabPath = "npc/talk_main",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Dialogue,
    ShowMouse = false,
    IgnoreBack = true
  },
  talk_model_window = {
    LuaFileName = "talk_model_window_view",
    PrefabPath = "npc/talk_model_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Dialogue,
    SceneMaskType = Z.UI.ESceneMaskType.Custom,
    ShowMouse = false,
    IgnoreBack = true
  },
  talk_option_window = {
    LuaFileName = "talk_option_window_view",
    PrefabPath = "npc/talk_option_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    IgnoreBack = true
  },
  team_enter = {
    LuaFileName = "team_enter_view",
    PrefabPath = "team/team_copy_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IgnoreBack = true
  },
  team_invite_popup = {
    LuaFileName = "team_invite_popup_view",
    PrefabPath = "team/team_invite_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  team_main = {
    LuaFileName = "team_main_view",
    PrefabPath = "team/team_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  team_request = {
    LuaFileName = "team_request_view",
    PrefabPath = "team/team_apply_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  team_target = {
    LuaFileName = "team_target_view",
    PrefabPath = "team/team_target_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  team_tips = {
    LuaFileName = "team_tips_view",
    PrefabPath = "main/team/main_team_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  tips_broadcast = {
    LuaFileName = "tips_broadcast_view",
    PrefabPath = "tips/tips_broadcast",
    Layer = Z.UI.ELayer.UILayerSystemTip,
    ViewType = Z.UI.EType.Permanent,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsHavePCUI = true
  },
  tips_game_broadcast = {
    LuaFileName = "tips_game_broadcast_view",
    PrefabPath = "tips/tips_game_broadcast",
    Layer = Z.UI.ELayer.UILayerTipTop,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  tips_countdown_popup = {
    LuaFileName = "tips_countdown_popup_view",
    PrefabPath = "tips/tips_countdown_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  union_application_popup = {
    LuaFileName = "union_application_popup_view",
    PrefabPath = "union/union_application_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_appoint_edit_tips = {
    LuaFileName = "union_appoint_edit_tips_view",
    PrefabPath = "union/union_appoint_edit_tips",
    Layer = Z.UI.ELayer.UILayerFuncPopup
  },
  union_create_window = {
    LuaFileName = "union_create_window_view",
    PrefabPath = "union/union_create_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  union_join_window = {
    LuaFileName = "union_join_window_view",
    PrefabPath = "union/union_join_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  union_main = {
    LuaFileName = "union_main_view",
    PrefabPath = "union/union_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  union_position_manage_popup = {
    LuaFileName = "union_position_manage_popup_view",
    PrefabPath = "union/union_position_manage_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_recruit_popup = {
    LuaFileName = "union_recruit_popup_view",
    PrefabPath = "union/union_recruit_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_detail_popup = {
    LuaFileName = "union_detail_popup_view",
    PrefabPath = "union/union_detail_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_filter_tips = {
    LuaFileName = "union_filter_tips_view",
    PrefabPath = "union/union_filter_tips"
  },
  union_label_tips = {
    LuaFileName = "union_label_tips_view",
    PrefabPath = "union/union_label_tips"
  },
  union_set_popup = {
    LuaFileName = "union_set_popup_view",
    PrefabPath = "union/union_set_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_hunt_enter_into_main = {
    LuaFileName = "union_hunt_enter_into_main_view",
    PrefabPath = "union/union_hunt_enter_into_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame
  },
  union_active_hot_popup = {
    LuaFileName = "union_active_hot_popup_view",
    PrefabPath = "union/union_active_hot_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_unit_popup = {
    LuaFileName = "union_unit_popup_view",
    PrefabPath = "union_2/union_unit_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_scene_unlock_popup = {
    LuaFileName = "union_scene_unlock_popup_view",
    PrefabPath = "union_2/union_scene_unlock_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  union_upgrade_main = {
    LuaFileName = "union_upgrade_main_view",
    PrefabPath = "union_2/union_upgrade_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame
  },
  union_device_main = {
    LuaFileName = "union_device_main_view",
    PrefabPath = "union_2/union_device_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame
  },
  union_buff_tips = {
    LuaFileName = "union_buff_tips_view",
    PrefabPath = "union_2/union_buff_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false
  },
  union_task_main = {
    LuaFileName = "union_task_main_view",
    PrefabPath = "union_2/union_task_main",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true
  },
  union_unlockscene_main = {
    LuaFileName = "union_unlockscene_main_view",
    PrefabPath = "union_2/union_unlockscene_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  union_wardance_window = {
    LuaFileName = "union_wardance_window_view",
    PrefabPath = "union_2/union_wardance_window",
    Layer = Z.UI.ELayer.UILayerMain,
    AudioGameState = E.AudioGameState.Ingame,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  union_group_popup = {
    LuaFileName = "union_group_popup_view",
    PrefabPath = "union/union_group_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weaponhero_choose_window = {
    LuaFileName = "weaponhero_choose_window_view",
    PrefabPath = "weaponhero/weaponhero_choose_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  weaponhero_main = {
    LuaFileName = "weaponhero_main_view",
    PrefabPath = "weaponhero/weaponhero_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  weaponhero_obtain_window = {
    LuaFileName = "weaponhero_obtain_window_view",
    PrefabPath = "weaponhero/weaponhero_obtain_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  weaponhero_resonance_main = {
    LuaFileName = "weaponhero_resonance_main_view",
    PrefabPath = "weaponhero/weap_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  weapon_skill_upgrades_popup = {
    LuaFileName = "weapon_skill_upgrades_popup_view",
    PrefabPath = "weapon_skill/weapon_skill_upgrades_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weaponhero_upgrade_popup = {
    LuaFileName = "weaponhero_upgrade_popup_view",
    PrefabPath = "weaponhero/weaponhero_upgrade_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weaponhero_advance_popup = {
    LuaFileName = "weaponhero_advance_popup_view",
    PrefabPath = "weaponhero/weaponhero_advance_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weap_change_window = {
    LuaFileName = "weap_change_window_view",
    PrefabPath = "weaponhero/weap_change_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  weap_profession_effect_selcect_window = {
    LuaFileName = "weap_profession_effect_selcect_window_view",
    PrefabPath = "weaponhero/weap_profession_effect_selcect_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  weap_profession_effect_window = {
    LuaFileName = "weap_profession_effect_window_view",
    PrefabPath = "weaponhero/weap_profession_effect_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  weap_window = {
    LuaFileName = "weap_window_view",
    PrefabPath = "weaponhero/weap_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  zrp_setting = {
    LuaFileName = "zrp_setting_view",
    PrefabPath = "gm/gm_setting_window",
    Layer = Z.UI.ELayer.UILayerDebug
  },
  pub_mixology_main = {
    LuaFileName = "pub/pub_mixology_main_view",
    PrefabPath = "pub/pub_mixology_main",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    IgnoreBack = true
  },
  pub_mixology_recipe_main = {
    LuaFileName = "pub/pub_mixology_recipe_main_view",
    PrefabPath = "pub/pub_mixology_recipe_main",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  season_main = {
    LuaFileName = "season_main_view",
    PrefabPath = "season/season_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  season_window = {
    LuaFileName = "season_window_view",
    PrefabPath = "season/season_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsUnrealScene = true
  },
  season_item_buy_popup = {
    LuaFileName = "season_item_buy_popup_view",
    PrefabPath = "season/season_item_buy_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  cutscene_subtitle_window = {
    LuaFileName = "cutscene_subtitle_window_view",
    PrefabPath = "cutscene/cutscene_subtitle_window",
    Layer = Z.UI.ELayer.UILayerDramaTop,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Ingame,
    ShowMouse = false,
    IgnoreBack = true
  },
  cutscene_image_window = {
    LuaFileName = "cutscene_image_window_view",
    PrefabPath = "cutscene/cutscene_image_window",
    Layer = Z.UI.ELayer.UILayerDramaTop,
    AudioGameState = E.AudioGameState.Ingame,
    ShowMouse = false,
    IgnoreBack = true
  },
  cutscene_ui_effect_window = {
    LuaFileName = "cutscene_ui_effect_window_view",
    PrefabPath = "cutscene/cutscene_ui_effect_window",
    Layer = Z.UI.ELayer.UILayerDramaTop,
    AudioGameState = E.AudioGameState.Ingame,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  cutscene_play_cg = {
    LuaFileName = "cutscene_play_cg_view",
    PrefabPath = "cutscene/cutscene_play_cg",
    Layer = Z.UI.ELayer.UILayerDramaVideo,
    CacheLv = Z.UI.ECacheLv.High,
    AudioGameState = E.AudioGameState.Ingame,
    IsFullScreen = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  shop_window = {
    LuaFileName = "shop_window_view",
    PrefabPath = "shop/shop_window",
    ViewType = Z.UI.EType.Exclusive,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  shop_token = {
    LuaFileName = "shop_token_view",
    PrefabPath = "shop/shop_window",
    ViewType = Z.UI.EType.Exclusive,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  shop_money_changing_popup = {
    LuaFileName = "shop_money_changing_popup_view",
    PrefabPath = "shop/shop_money_changing_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  shop_exchange_popup = {
    LuaFileName = "shop_exchange_popup_view",
    PrefabPath = "shop/shop_exchange_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  explore_monster_window = {
    LuaFileName = "explore_monster_window_view",
    PrefabPath = "explore_monster/explore_monster_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  explore_monster_grade_popup = {
    LuaFileName = "explore_monster_grade_popup_view",
    PrefabPath = "explore_monster/explore_monster_grade_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  explore_monster_level_popup = {
    LuaFileName = "explore_monster_level_popup_view",
    PrefabPath = "explore_monster/explore_monster_level_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  explore_monster_deplete_popup = {
    LuaFileName = "explore_monster_deplete_popup_view",
    PrefabPath = "explore_monster/explore_monster_deplete_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  sevendaystarget_main = {
    LuaFileName = "sevendaystarget_main_view",
    PrefabPath = "sevendaystarget/sevendaystarget_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  weapon_role_main = {
    LuaFileName = "weapon_role_main_view",
    PrefabPath = "weapon/weapon_role_main",
    ViewType = Z.UI.EType.Exclusive,
    CameraState = E.CameraState.MiscSystem
  },
  weapon_role_main_pc = {
    LuaFileName = "weapon_role_main_pc_view",
    PrefabPath = "weapon/weapon_role_main_pc",
    ViewType = Z.UI.EType.Exclusive,
    CameraState = E.CameraState.MiscSystem
  },
  weapon_choose_main = {
    LuaFileName = "weapon_choose_main_view",
    PrefabPath = "weapon/weapon_choose_main",
    ViewType = Z.UI.EType.Exclusive,
    CameraState = E.CameraState.MiscSystem
  },
  talent_select_window = {
    LuaFileName = "talent_select_window_view",
    PrefabPath = "talent/talent_select_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  talent_select_detail_window = {
    LuaFileName = "talent_select_detail_window_view",
    PrefabPath = "talent/talent_select_detail_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  talent_skill_window = {
    LuaFileName = "talent_skill_window_view",
    PrefabPath = "talent_new/talent_skill_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  talent_award_window = {
    LuaFileName = "talent_award_window_view",
    PrefabPath = "talent_new/talent_award_window",
    AudioGameState = E.AudioGameState.Menu,
    IgnoreFocus = true,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  mod_fantasy_window = {
    LuaFileName = "mod_fantasy_window_view",
    PrefabPath = "mod_new/mod_fantasy_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  mod_preview_window = {
    LuaFileName = "mod_preview_window_view",
    PrefabPath = "mod_new/mod_preview_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  mod_intensify_window = {
    LuaFileName = "mod_intensify_window_view",
    PrefabPath = "mod_new/mod_intensify_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  mod_intensify_popup = {
    LuaFileName = "mod_intensify_popup_view",
    PrefabPath = "mod_new/mod_intensify_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  mod_main = {
    LuaFileName = "mod_main_view",
    PrefabPath = "mod_new/mod_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  mod_item_popup = {
    LuaFileName = "mod_item_popup_view",
    PrefabPath = "common_tips/mod_item_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    AudioGameState = E.AudioGameState.Menu
  },
  mod_term_recommend_popup = {
    LuaFileName = "mod_term_recommend_popup_view",
    PrefabPath = "mod_new/mod_term_recommend_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  cook_main = {
    LuaFileName = "cook_main_view",
    PrefabPath = "cook/cook_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsHavePCUI = true
  },
  chemistry_main = {
    LuaFileName = "chemistry_main_view",
    PrefabPath = "chemistry/chemistry_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu
  },
  chemistry_recipe_popup = {
    LuaFileName = "chemistry_recipe_popup_view",
    PrefabPath = "chemistry/chemistry_recipe_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  gm_quest_popup = {
    LuaFileName = "gm/gm_quest_popup_view",
    PrefabPath = "gm/gm_quest_popup",
    Layer = Z.UI.ELayer.UILayerDebug,
    ViewType = Z.UI.EType.Permanent,
    ShowMouse = false
  },
  weapon_build_obtain_window = {
    LuaFileName = "weapon_build_obtain_window_view",
    PrefabPath = "weapon_build/weapon_build_obtain_window",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  weapon_resonance_preview_popup = {
    LuaFileName = "weapon_resonance_preview_popup_view",
    PrefabPath = "weapon_develop/weapon_resonance_preview_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weapon_resonance_obtain_popup = {
    LuaFileName = "weapon_resonance_obtain_popup_view",
    PrefabPath = "weapon_develop/weapon_resonance_obtain_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weapon_resonance_advance_window = {
    LuaFileName = "weapon_resonance_advance_window_view",
    PrefabPath = "weapon_develop/weapon_resonance_advance_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  friend_degree_window = {
    LuaFileName = "friend_degree_window_view",
    PrefabPath = "friends/friend_degree_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  friends_group_popup = {
    LuaFileName = "friends_group_popup_view",
    PrefabPath = "friends_pc/friends_group_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  friends_add_popup = {
    LuaFileName = "friends_add_popup_view",
    PrefabPath = "friends_pc/friends_add_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  profession_select_window = {
    LuaFileName = "profession_select_window_view",
    PrefabPath = "professsion/profession_select_window",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  friend_degree_popup = {
    LuaFileName = "friend_degree_popup_view",
    PrefabPath = "friends/friend_degree_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_affix_popup = {
    LuaFileName = "hero_dungeon_affix_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_affix_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_score_popup = {
    LuaFileName = "hero_dungeon_score_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_score_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_open_window = {
    LuaFileName = "hero_dungeon_open_window_view",
    PrefabPath = "hero_dungeon/hero_dungeon_open_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IgnoreFocus = true,
    IgnoreBack = true
  },
  interrogate_window = {
    LuaFileName = "interrogate_window_view",
    PrefabPath = "interrogate/interrogate_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  steer_helpsy_window = {
    LuaFileName = "steer_helpsy_window_view",
    PrefabPath = "steer/steer_helpsy_window",
    Layer = Z.UI.ELayer.UILayerTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  dungeon_timer_window = {
    LuaFileName = "dungeon_timer_window_view",
    PrefabPath = "dungeon/dungeon_timer_window",
    Layer = Z.UI.ELayer.UILayerMain,
    AudioGameState = E.AudioGameState.Ingame,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true
  },
  tips_unlock_condition = {
    LuaFileName = "tips_unlock_condition_view",
    PrefabPath = "tips/tips_unlock_condition",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  season_achievement_detail_window = {
    LuaFileName = "season_achievement_detail_window_view",
    PrefabPath = "season_achievement/season_achievement_detail_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  achievement_window = {
    LuaFileName = "achievement_window_view",
    PrefabPath = "season_achievement/achievement_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  achievement_detail_window = {
    LuaFileName = "achievement_detail_window_view",
    PrefabPath = "season_achievement/achievement_detail_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  season_achievement_finish_popup = {
    LuaFileName = "season_achievement_finish_popup_view",
    PrefabPath = "season_achievement/season_achievement_finish_popup",
    AudioGameState = E.AudioGameState.Menu,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsHavePCUI = true
  },
  quick_item_usage = {
    LuaFileName = "quick_item_usage_view",
    PrefabPath = "quick_item_usage/quick_item_usage_window",
    Layer = Z.UI.ELayer.UILayerTip,
    CacheLv = Z.UI.ECacheLv.Low,
    IgnoreFocus = true,
    ShowMouse = false,
    IsHavePCUI = true
  },
  battle_pass_buy = {
    LuaFileName = "battle_pass_buy_permit_view",
    PrefabPath = "bpcard/bpcard_buy_permit_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  battle_pass_level_up = {
    LuaFileName = "battle_pass_level_up_view",
    PrefabPath = "bpcard/cont_level_up_tpl",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  battle_pass_purchase_level = {
    LuaFileName = "battle_pass_purchase_level_view",
    PrefabPath = "bpcard/bpcard_purchase_level_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_key = {
    LuaFileName = "hero_dungeon_key_view",
    PrefabPath = "hero_dungeon/hero_dungeon_key",
    Layer = Z.UI.ELayer.UILayerTop,
    ViewType = Z.UI.EType.Permanent,
    IgnoreBack = true
  },
  season_energy_window = {
    LuaFileName = "season_energy_window_view",
    PrefabPath = "season_title/season_energy_window",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  season_course_sub = {
    LuaFileName = "season_course_sub_view",
    PrefabPath = "season_title/season_course_sub",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  season_starlevel_popup = {
    LuaFileName = "season_starlevel_popup_view",
    PrefabPath = "season_title/season_starlevel_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  personal_zone_record_main = {
    LuaFileName = "personal_zone/record_main_view",
    PrefabPath = "personalzone/personalzone_record_main",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  season_cultivate_reset_popup = {
    LuaFileName = "season_cultivate/season_cultivate_reset_popup_view",
    PrefabPath = "season_cultivate/season_reset_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  personalzone_main = {
    LuaFileName = "personalzone_main_view",
    PrefabPath = "personalzone/personalzone_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  personalzone_edit_window = {
    LuaFileName = "personalzone_edit_window_view",
    PrefabPath = "personalzone/personalzone_edit_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  personalzone_obtained_popup = {
    LuaFileName = "personalzone_obtained_popup_view",
    PrefabPath = "personalzone/personalzone_obtained_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  personalzone_photo_show_window = {
    LuaFileName = "personalzone_photo_show_window_view",
    PrefabPath = "personalzone/personalzone_photo_show_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  home_editor_main = {
    LuaFileName = "home_editor_main_view",
    PrefabPath = "home_editor/home_editor_main",
    ViewType = Z.UI.EType.Exclusive,
    IgnoreBack = true
  },
  home_edit_option_window = {
    LuaFileName = "home_edit_option_window_view",
    PrefabPath = "home_editor/home_edit_option_window",
    IgnoreBack = true
  },
  com_rewards_window = {
    LuaFileName = "com_rewards_window_view",
    PrefabPath = "common_tips_new/com_rewards_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_instability_main = {
    LuaFileName = "hero_dungeon_instability_main_view",
    PrefabPath = "hero_dungeon/hero_dungeon_instability_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  hero_dungeon_target_popup = {
    LuaFileName = "hero_dungeon_target_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_target_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_probability_popup = {
    LuaFileName = "hero_dungeon_probability_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_probability_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_key_tips = {
    LuaFileName = "hero_dungeon_key_tips_view",
    PrefabPath = "hero_dungeon/hero_dungeon_key_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false
  },
  hero_dungeon_key_popup = {
    LuaFileName = "hero_dungeon_key_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_key_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_key_expend_popup = {
    LuaFileName = "hero_dungeon_key_expend_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_key_expend_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_affix_item_tpl = {
    LuaFileName = "hero_dungeon_affix_item_tpl_view",
    PrefabPath = "hero_dungeon/hero_dungeon_affix_item_tpl",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false
  },
  weapon_skill_remodel_popup = {
    LuaFileName = "weapon_skill_remodel_popup_view",
    PrefabPath = "weapon_skill/weapon_skill_remodel_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weapon_skill_main = {
    LuaFileName = "weapon_skill_main_view",
    PrefabPath = "weapon_develop/weapon_skill_main",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true
  },
  weapon_skill_unlock_popup = {
    LuaFileName = "weapon_skill_unlock_popup_view",
    PrefabPath = "weapon_skill/weapon_skill_unlock_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  season_cultivate_effect_popup = {
    LuaFileName = "season_cultivate_effect_popup_view",
    PrefabPath = "season_cultivate/season_cultivate_effect_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  trading_ring_main = {
    LuaFileName = "trading_ring_main_view",
    PrefabPath = "trading_ring/trading_ring_main",
    ViewType = Z.UI.EType.Exclusive,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  warehouse_main = {
    LuaFileName = "warehouse_main_view",
    PrefabPath = "warehouse/warehouse_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  warehouse_popup = {
    LuaFileName = "warehouse_popup_view",
    PrefabPath = "warehouse/warehouse_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  wardrobe_collection_tips = {
    LuaFileName = "wardrobe_collection_tips_view",
    PrefabPath = "common_tips/wardrobe_collection_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu
  },
  tips_battle_buff_popup = {
    LuaFileName = "tips_battle_buff_popup_view",
    PrefabPath = "tips/tips_battle_buff_popup",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu
  },
  gasha_window = {
    LuaFileName = "gasha/gasha_window_view",
    PrefabPath = "gasha/gasha_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  gasha_record_window = {
    LuaFileName = "gasha/gasha_record_window_view",
    PrefabPath = "gasha/gasha_record_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  gasha_detail_window = {
    LuaFileName = "gasha/gasha_detail_window_view",
    PrefabPath = "gasha/gasha_detail_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  gasha_result_window = {
    LuaFileName = "gasha/gasha_result_window_view",
    PrefabPath = "gasha/gasha_result_window",
    CacheLv = Z.UI.ECacheLv.Low,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true
  },
  gasha_highqualitydetail_window = {
    LuaFileName = "gasha/gasha_highqualitydetail_window_view",
    PrefabPath = "gasha/gasha_highqualitydetail_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    IsUnrealScene = true
  },
  gasha_video_window = {
    LuaFileName = "gasha/gasha_video_window_view",
    PrefabPath = "gasha/gasha_video_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  cook_rejuvenation_popup = {
    LuaFileName = "cook_rejuvenation_popup_view",
    PrefabPath = "cook/cook_rejuvenation_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  photo_personal_idcard_popup = {
    LuaFileName = "photo_personalzone_idcard_popup_view",
    PrefabPath = "photograph/photo_personalzone_idcard_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  face_share_popup = {
    LuaFileName = "face_share_popup_view",
    PrefabPath = "face/face_share_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  quest_book_window = {
    LuaFileName = "quest_task/quest_book_window_view",
    PrefabPath = "quest/quest_book_window",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  equip_vocational_refining_popup = {
    LuaFileName = "equip_vocational_refining_popup_view",
    PrefabPath = "equip/equip_vocational_refining_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  weekly_hunt_main = {
    LuaFileName = "weekly_hunt_main_view",
    PrefabPath = "weekly_hunt/weekly_hunt_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  weekly_hunt_rankings_window = {
    LuaFileName = "weekly_hunt_rankings_window_view",
    PrefabPath = "weekly_hunt/weekly_hunt_rankings_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  weekly_hunt_target_reward_popup = {
    LuaFileName = "weekly_hunt_target_reward_popup_view",
    PrefabPath = "weekly_hunt/weekly_hunt_target_reward_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  recycle_window = {
    LuaFileName = "recycle_window_view",
    PrefabPath = "recycle/recycle_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsHavePCUI = true
  },
  recommendedplay_main = {
    LuaFileName = "recommendedplay_main_view",
    PrefabPath = "recommendedplay/recommendedplay_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  themeact_main = {
    LuaFileName = "themeact_main_view",
    PrefabPath = "themeact/themeact_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  vehicle_main = {
    LuaFileName = "vehicle_main_view",
    PrefabPath = "vehicle/vehicle_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true,
    IsHavePCUI = true
  },
  vehicle_equip_popup = {
    LuaFileName = "vehicle_equip_popup_view",
    PrefabPath = "vehicle/vehicle_equip_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  vehicle_skill_popup = {
    LuaFileName = "vehicle_skill_popup_view",
    PrefabPath = "vehicle/vehicle_skill_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  vehicle_tips = {
    LuaFileName = "vehicle_tips_view",
    PrefabPath = "vehicle/vehicle_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    IgnoreFocus = true,
    ShowMouse = false,
    IsHavePCUI = true
  },
  tips_box_show_popup = {
    LuaFileName = "tips_box_show_popup_view",
    PrefabPath = "common_tips/tips_box_show_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    IgnoreFocus = true,
    ShowMouse = false
  },
  monthly_reward_card_list = {
    LuaFileName = "monthly_reward_card_list_view",
    PrefabPath = "monthly_reward_card/monthly_reward_card_list",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  monthly_reward_card_look_window = {
    LuaFileName = "monthly_reward_card_look_window_view",
    PrefabPath = "monthly_reward_card/monthly_reward_card_look_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  monthly_reward_card_window = {
    LuaFileName = "monthly_reward_card_window_view",
    PrefabPath = "monthly_reward_card/monthly_reward_card_window",
    Layer = Z.UI.ELayer.UILayerTipTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IgnoreBack = true
  },
  monthly_reward_card_privilege_window = {
    LuaFileName = "monthly_reward_card_privilege_view",
    PrefabPath = "monthly_reward_card/monthly_reward_card_privilege_window",
    Layer = Z.UI.ELayer.UILayerTipTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  interaction_skip_window = {
    LuaFileName = "interaction_skip_window_view",
    PrefabPath = "interaction/interaction_skip_window",
    Layer = Z.UI.ELayer.UILayerDramaBottom,
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IgnoreBack = true
  },
  life_profession_main = {
    LuaFileName = "life_profession_main_view",
    PrefabPath = "life_profession/life_profession_main",
    ViewType = Z.UI.EType.Exclusive,
    IsHavePCUI = true,
    IsFullScreen = true
  },
  life_profession_acquisition_main = {
    LuaFileName = "life_profession_acquisition_main_view",
    PrefabPath = "life_profession/life_profession_acquisition_main",
    ViewType = Z.UI.EType.Exclusive,
    IsHavePCUI = true,
    IsFullScreen = true
  },
  life_profession_unlock_window = {
    LuaFileName = "life_profession_unlock_window_view",
    PrefabPath = "life_profession/life_profession_unlock_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  shop_buy_popup = {
    LuaFileName = "shop_buy_popup_view",
    PrefabPath = "shop/shop_buy_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  shop_coupon_popup = {
    LuaFileName = "shop_coupon_popup_view",
    PrefabPath = "shop/shop_coupon_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  life_profession_levelup_window = {
    LuaFileName = "life_profession_levelup_window_view",
    PrefabPath = "life_profession/life_profession_levelup_window",
    Layer = Z.UI.ELayer.UILayerTip,
    ShowMouse = false,
    IsRefreshSteer = false
  },
  life_profession_cast_main = {
    LuaFileName = "life_profession_cast_main_view",
    PrefabPath = "life_profession/life_profession_cast_main",
    ViewType = Z.UI.EType.Exclusive,
    IsRefreshSteer = false,
    IsHavePCUI = true
  },
  fashion_weapon_skill_window = {
    LuaFileName = "fashion_weapon_skill_window_view",
    PrefabPath = "fashion/fashion_weapon_skill_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  handbook_main_window = {
    LuaFileName = "handbook_main_window_view",
    PrefabPath = "handbook/handbook_main_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  handbook_dictionaries_window = {
    LuaFileName = "handbook_dictionaries_window_view",
    PrefabPath = "handbook/handbook_dictionaries_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  handbook_postcard_window = {
    LuaFileName = "handbook_postcard_window_view",
    PrefabPath = "handbook/handbook_postcard_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  handbook_character_window = {
    LuaFileName = "handbook_character_window_view",
    PrefabPath = "handbook/handbook_character_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  handbook_read_window = {
    LuaFileName = "handbook_read_window_view",
    PrefabPath = "handbook/handbook_read_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  handbook_read_detail_window = {
    LuaFileName = "handbook_read_detail_window_view",
    PrefabPath = "handbook/handbook_read_detail_window",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  equip_enchant_popup = {
    LuaFileName = "equip_enchant_popup_view",
    PrefabPath = "equip/equip_enchant_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  expression_fast_window = {
    LuaFileName = "expression_fast_window_view",
    PrefabPath = "expression/expression_fast_window",
    Layer = Z.UI.ELayer.UILayerTip
  },
  expression_fast_window_pc = {
    LuaFileName = "expression_fast_window_pc_view",
    PrefabPath = "expression/expression_fast_window_pc",
    Layer = Z.UI.ELayer.UILayerTip
  },
  expression_wheel_setting_window = {
    LuaFileName = "expression_wheel_setting_window_view",
    PrefabPath = "expression/expression_wheel_setting_window",
    ViewType = Z.UI.EType.Exclusive
  },
  expression_wheel_setting_window_pc = {
    LuaFileName = "expression_wheel_setting_window_pc_view",
    PrefabPath = "expression/expression_wheel_setting_window_pc",
    ViewType = Z.UI.EType.Exclusive
  },
  lifework_main = {
    LuaFileName = "lifework_main_view",
    PrefabPath = "lifework/lifework_main",
    ViewType = Z.UI.EType.Exclusive,
    IsRefreshSteer = false,
    IsHavePCUI = true,
    IsFullScreen = true
  },
  lifework_record_popup = {
    LuaFileName = "lifework_record_popup_view",
    PrefabPath = "lifework/lifework_record_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    ViewType = Z.UI.EType.Exclusive,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsRefreshSteer = false
  },
  lifework_settle_window = {
    LuaFileName = "lifework_settle_window_view",
    PrefabPath = "lifework/lifework_settle_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    ViewType = Z.UI.EType.Exclusive,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsRefreshSteer = false
  },
  collection_window = {
    LuaFileName = "collection_window_view",
    PrefabPath = "collection/collection_window",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  collection_reward_popup = {
    LuaFileName = "collection_reward_popup_view",
    PrefabPath = "collection/collection_reward_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  collection_membership_popup = {
    LuaFileName = "collection_membership_popup_view",
    PrefabPath = "collection/collection_membership_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  face_rolechoose_popup = {
    LuaFileName = "face_rolechoose_popup_view",
    PrefabPath = "face/face_rolechoose_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true,
    IsRefreshSteer = false
  },
  hero_dungeon_prewar_popup = {
    LuaFileName = "hero_dungeon_prewar_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_prewar_popup"
  },
  house_main = {
    LuaFileName = "house_main_view",
    PrefabPath = "house/house_main",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  house_check_signature_popup = {
    LuaFileName = "house_check_signature_popup_view",
    PrefabPath = "house/house_check_signature_popup",
    ViewType = Z.UI.EType.Exclusive,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  house_invitation_letter_popup = {
    LuaFileName = "house_invitation_letter_popup_view",
    PrefabPath = "house/house_invitation_letter_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  house_buy_title_deed_sub = {
    LuaFileName = "house_buy_title_deed_sub_view",
    PrefabPath = "house/house_buy_title_deed_sub",
    ViewType = Z.UI.EType.Exclusive,
    SceneMaskType = Z.UI.ESceneMaskType.Normal,
    IsFullScreen = true
  },
  house_get_popup = {
    LuaFileName = "house_get_popup_view",
    PrefabPath = "house/house_get_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    ViewType = Z.UI.EType.Exclusive,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  house_application_list_popup = {
    LuaFileName = "house_application_list_popup_view",
    PrefabPath = "house/house_application_list_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  house_bulletin_board_popup = {
    LuaFileName = "house_bulletin_board_popup_view",
    PrefabPath = "house/house_bulletin_board_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  house_furniture_guide_window = {
    LuaFileName = "house_furniture_guide_window_view",
    PrefabPath = "house/house_furniture_guide_window"
  },
  house_set_popup = {
    LuaFileName = "house_set_popup_view",
    PrefabPath = "house/house_set_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  house_production_main = {
    LuaFileName = "house_production_main_view",
    PrefabPath = "house/house_production_main",
    ViewType = Z.UI.EType.Exclusive
  },
  house_get_item_popup = {
    LuaFileName = "house_get_item_popup_view",
    PrefabPath = "house/house_get_item_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  camera_invited_photo_popup = {
    LuaFileName = "camera_invited_photo_popup_view",
    PrefabPath = "photograph/camera_invited_photo_pupup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  report_popup = {
    LuaFileName = "report_popup_view",
    PrefabPath = "report/report_popup",
    Layer = Z.UI.ELayer.UILayerTipTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  treasure_window = {
    LuaFileName = "treasure_window_view",
    PrefabPath = "treasure/treasure_window",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  bug_window = {
    LuaFileName = "bug_window_view",
    PrefabPath = "bug/bug_window",
    Layer = Z.UI.ELayer.UILayerDebug,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  camerasys_main_pc = {
    LuaFileName = "camerasys_main_pc_view",
    PrefabPath = "photograph_pc/camerasys_main_pc",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame
  },
  house_level_window = {
    LuaFileName = "house_level_sub_view",
    PrefabPath = "house/house_level_sub",
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  house_upgrade_popup = {
    LuaFileName = "house_upgrade_popup_view",
    PrefabPath = "house/house_upgrade_popup",
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  house_quest_window = {
    LuaFileName = "house_quest_window_view",
    PrefabPath = "house/house_quest_window",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  house_shop_main = {
    LuaFileName = "house_shop_main_view",
    PrefabPath = "house/house_shop_main",
    AudioGameState = E.AudioGameState.Menu,
    IsFullScreen = true
  },
  house_play_farm_tips = {
    LuaFileName = "house_play_farm_tips_view",
    PrefabPath = "house/house_play_farm_tips",
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IgnoreBack = true,
    IgnoreFocus = true
  },
  house_play_farm_main = {
    LuaFileName = "house_play_farm_main_view",
    PrefabPath = "house/house_play_farm_main",
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IgnoreBack = true,
    IgnoreFocus = true
  },
  hero_dungeon_begin_ready_tpl = {
    LuaFileName = "hero_dungeon_begin_ready_tpl_view",
    PrefabPath = "hero_dungeon/hero_dungeon_begin_ready_tpl",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    IgnoreFocus = true,
    ShowMouse = false,
    IgnoreBack = true,
    IsRefreshSteer = false
  },
  pandora_announce_popup = {
    LuaFileName = "pandora_announce_popup_view",
    PrefabPath = "pandora/pandora_announce_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  setting_popup = {
    LuaFileName = "set_item_popup_view",
    PrefabPath = "set/set_image_window",
    Layer = Z.UI.ELayer.UILayerMain,
    AudioGameState = E.AudioGameState.Menu
  },
  fishing_ranking_reward_popup = {
    LuaFileName = "fishing_ranking_reward_popup_view",
    PrefabPath = "fishing/fishing_ranking_reward_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  story_fade_message_window = {
    LuaFileName = "story_fade_message_window_view",
    PrefabPath = "story/story_fade_message_window",
    Layer = Z.UI.ELayer.UILayerDramaVideo,
    AudioGameState = E.AudioGameState.Menu,
    ShowMouse = false,
    IgnoreBack = true
  },
  common_privilege_popup = {
    LuaFileName = "common_privilege_popup_view",
    PrefabPath = "commonui/common_privilege_popup",
    Layer = Z.UI.ELayer.UILayerTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  friends_play_friends_popup = {
    LuaFileName = "friends_play_friends_popup_view",
    PrefabPath = "friends/friends_play_friends_popup",
    Layer = Z.UI.ELayer.UILayerTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  friends_play_friends_more_popup = {
    LuaFileName = "friends_play_friends_more_popup_view",
    PrefabPath = "friends/friends_play_friends_more_popup",
    Layer = Z.UI.ELayer.UILayerTop,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  hero_dungeon_master_popup = {
    LuaFileName = "hero_dungeon_master_popup_view",
    PrefabPath = "hero_dungeon/hero_dungeon_master_popup",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  hero_dungeon_master_share_window = {
    LuaFileName = "hero_dungeon_master_share_window_view",
    PrefabPath = "hero_dungeon/hero_dungeon_master_share_window",
    Layer = Z.UI.ELayer.UILayerTipTop
  },
  power_saving_window = {
    LuaFileName = "power_saving_window_view",
    PrefabPath = "power_saving/power_saving_window",
    Layer = Z.UI.ELayer.UILayerGuide,
    ViewType = Z.UI.EType.Permanent,
    AudioGameState = E.AudioGameState.Menu
  },
  battle_auto_battle_set = {
    LuaFileName = "battle_auto_battle_set_view",
    PrefabPath = "battle/battle_auto_battle_set",
    AudioGameState = E.AudioGameState.Menu
  },
  equip_forge_main = {
    LuaFileName = "equip_forge_main_view",
    PrefabPath = "equip/equip_forge_main",
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true,
    IsUnrealScene = true
  },
  equip_obtaining_popup = {
    LuaFileName = "equip_obtaining_popup_view",
    PrefabPath = "equip/equip_obtaining_popup",
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IsFullScreen = true
  },
  life_profession_formula_tips = {
    LuaFileName = "life_profession_formula_tips_view",
    PrefabPath = "life_profession/life_profession_formula_tips",
    Layer = Z.UI.ELayer.UILayerTip,
    AudioGameState = E.AudioGameState.Menu,
    IsHavePCUI = true
  },
  gasha_illusion_popup = {
    LuaFileName = "gasha_illusion_popup_view",
    PrefabPath = "gasha/gasha_illusion_popup"
  },
  tips_action_name_popup = {
    LuaFileName = "tips_action_name_popup_view",
    PrefabPath = "expression/tips_action_name",
    Layer = Z.UI.ELayer.UILayerTip,
    CacheLv = Z.UI.ECacheLv.Middle,
    IgnoreFocus = true
  },
  master_dungeon_failure_window = {
    LuaFileName = "master_dungeon_failure_window_view",
    PrefabPath = "trialroad/trialroad_battle_failure_window",
    Layer = Z.UI.ELayer.UILayerMain,
    ViewType = Z.UI.EType.Exclusive,
    AudioGameState = E.AudioGameState.Ingame,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay,
    IgnoreBack = true
  },
  camera_cloud_game_share = {
    LuaFileName = "camera_cloud_game_share_view",
    PrefabPath = "photograph/camera_cloud_game_share",
    AudioGameState = E.AudioGameState.Ingame,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  camera_cloud_game_share_code_window = {
    LuaFileName = "camera_cloud_game_share_code_window_view",
    PrefabPath = "photograph/camera_cloud_game_share_code_window",
    AudioGameState = E.AudioGameState.Ingame,
    IsFullScreen = true
  },
  face_scan_window = {
    LuaFileName = "face_scan_window_view",
    PrefabPath = "face/face_scan_window",
    Layer = Z.UI.ELayer.UILayerFuncPopup,
    AudioGameState = E.AudioGameState.Menu,
    SceneMaskType = Z.UI.ESceneMaskType.Overlay
  },
  raid_main = {
    LuaFileName = "raid_main_view",
    PrefabPath = "raid/raid_main",
    Layer = Z.UI.ELayer.UILayerFunc,
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true
  },
  raid_monster_window = {
    LuaFileName = "raid_monster_window_view",
    PrefabPath = "raid/raid_monster_window",
    Layer = Z.UI.ELayer.UILayerFunc,
    ViewType = Z.UI.EType.Exclusive,
    IsFullScreen = true
  }
}
for viewConfigKey, config in pairs(UIConfig) do
  setmetatable(config, config_mt)
end
return UIConfig
