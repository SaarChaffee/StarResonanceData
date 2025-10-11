local actionConfig = {
  backpack_main = {
    {
      ActionId = Z.InputActionIds.Backpack,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  chat_emoji_container_popup = {
    {
      ActionId = Z.InputActionIds.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  chat_input_box_tpl = {
    {
      ActionId = Z.InputActionIds.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  cutscene_qte_main = {
    {
      ActionId = Z.InputActionIds.CutsceneQTE,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.CutsceneQTE,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  equip_change_window = {
    {
      ActionId = Z.InputActionIds.EquipView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  quest_detail = {
    {
      ActionId = Z.InputActionIds.Quest,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_role_main = {
    {
      ActionId = Z.InputActionIds.Role,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_skill_main = {
    {
      ActionId = Z.InputActionIds.SkillView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_role_main_skill_sub = {
    {
      ActionId = Z.InputActionIds.RoleViewDetail,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  weapon_role_main_pc = {
    {
      ActionId = Z.InputActionIds.Role,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_role_main_mod_sub = {
    {
      ActionId = Z.InputActionIds.RoleViewDetail,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  union_main = {
    {
      ActionId = Z.InputActionIds.UnionView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  team_window = {
    {
      ActionId = Z.InputActionIds.TeamVoice,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  team_tips = {
    {
      ActionId = Z.InputActionIds.TipsAgree,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.TipsRefuse,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  team_main = {
    {
      ActionId = Z.InputActionIds.Team,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  talent_skill_window = {
    {
      ActionId = Z.InputActionIds.TalentView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  season_main = {
    {
      ActionId = Z.InputActionIds.Season,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  recommendedplay_main = {
    {
      ActionId = Z.InputActionIds.RecommendEvent,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  quick_item_usage = {
    {
      ActionId = Z.InputActionIds.QuickItemUsage,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  quest_letter_window = {
    {
      ActionId = Z.InputActionIds.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  main_minimap_sub = {
    {
      ActionId = Z.InputActionIds.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  mainui = {
    {
      ActionId = Z.InputActionIds.ExpressionUse1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse2,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse3,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse4,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse5,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse6,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse7,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionUse8,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.EnableMap,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0, 0.5}
    },
    {
      ActionId = Z.InputActionIds.EnableMap,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.TrackUITurnLeft,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.TrackUITurnRight,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  camerasys_main_pc = {
    {
      ActionId = Z.InputActionIds.Photograph,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    },
    {
      ActionId = Z.InputActionIds.Mounts,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.PhotoGamepadPointVisible,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  camerasys = {
    {
      ActionId = Z.InputActionIds.Photograph,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    },
    {
      ActionId = Z.InputActionIds.Mounts,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.PhotoGamepadPointVisible,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  expression_fast_window_pc = {
    {
      ActionId = Z.InputActionIds.ExpressionSetting,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionPageSwitch,
      InputActionEventType = Z.InputActionEventType.AxisActiveOrJustInactive,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionPageSwitch,
      InputActionEventType = Z.InputActionEventType.AxisJustChanged,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExpressionFast,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  fishing_btn_ctrl = {
    {
      ActionId = Z.InputActionIds.FishingClick,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingClick,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  fishing_main_window = {
    {
      ActionId = Z.InputActionIds.FishingLevel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingStudy,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingBait,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingRod,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingGuide,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingSetting,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.FishingPlayerDetail,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  helpsys_popup_entrance_tpl = {
    {
      ActionId = Z.InputActionIds.HelpView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  interaction_skip_window = {
    {
      ActionId = Z.InputActionIds.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  main_chat_pc = {
    {
      ActionId = Z.InputActionIds.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.OpenChat,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0.5}
    },
    {
      ActionId = Z.InputActionIds.ChatChannelUp,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.ChatChannelDown,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.InputChannelUp,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.InputChannelDown,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  main_line_window = {
    {
      ActionId = Z.InputActionIds.SceneLine,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  map_main = {
    {
      ActionId = Z.InputActionIds.EnableMap,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  main_take_medicine_sub = {
    {
      ActionId = Z.InputActionIds.QuickUse1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.TakeMedicineLeft,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.TakeMedicineRight,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  talk_dialog_window = {
    {
      ActionId = Z.InputActionIds.Jump,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0, 0.2}
    }
  },
  talk_option_window = {
    {
      ActionId = Z.InputActionIds.NavigateInteraction,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.NavigateInteraction,
      InputActionEventType = Z.InputActionEventType.AxisActiveOrJustInactive,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0, 0.2}
    }
  },
  battle_auto_battle_set = {
    {
      ActionId = Z.InputActionIds.OpenChat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Skill1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Skill2,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Skill3,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Skill4,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.UltimateSkill,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.SpecialSkill,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.SupportSkill1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.SupportSkill2,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  dialog = {
    {
      ActionId = Z.InputActionIds.Confirm,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.InputActionIds.Cancel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  }
}
return actionConfig
