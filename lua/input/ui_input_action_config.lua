local actionConfig = {
  backpack_main = {
    {
      ActionId = Z.RewiredActionsConst.Backpack,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  chat_emoji_container_popup = {
    {
      ActionId = Z.RewiredActionsConst.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  chat_input_box_tpl = {
    {
      ActionId = Z.RewiredActionsConst.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  cutscene_qte_main = {
    {
      ActionId = Z.RewiredActionsConst.CutsceneQTE,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.CutsceneQTE,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  equip_change_window = {
    {
      ActionId = Z.RewiredActionsConst.EquipView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  quest_detail = {
    {
      ActionId = Z.RewiredActionsConst.Quest,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_role_main = {
    {
      ActionId = Z.RewiredActionsConst.Role,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_skill_main = {
    {
      ActionId = Z.RewiredActionsConst.SkillView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_role_main_skill_sub = {
    {
      ActionId = Z.RewiredActionsConst.RoleViewDetail,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  weapon_role_main_pc = {
    {
      ActionId = Z.RewiredActionsConst.Role,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  weapon_role_main_mod_sub = {
    {
      ActionId = Z.RewiredActionsConst.RoleViewDetail,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  union_main = {
    {
      ActionId = Z.RewiredActionsConst.UnionView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  trading_ring_main = {
    {
      ActionId = Z.RewiredActionsConst.Trade_Center,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  team_window = {
    {
      ActionId = Z.RewiredActionsConst.TeamVoice,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  team_tips = {
    {
      ActionId = Z.RewiredActionsConst.TipsAgree,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.TipsRefuse,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  team_main = {
    {
      ActionId = Z.RewiredActionsConst.Team,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  talent_skill_window = {
    {
      ActionId = Z.RewiredActionsConst.TalentView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  season_main = {
    {
      ActionId = Z.RewiredActionsConst.Season,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  recommendedplay_main = {
    {
      ActionId = Z.RewiredActionsConst.RecommendEvent,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  quick_item_usage = {
    {
      ActionId = Z.RewiredActionsConst.QuickItemUsage,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  quest_letter_window = {
    {
      ActionId = Z.RewiredActionsConst.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  main_minimap_sub = {
    {
      ActionId = Z.RewiredActionsConst.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  mainui = {
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse2,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse3,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse4,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse5,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse6,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse7,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionUse8,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.EnableMap,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0, 0.5}
    },
    {
      ActionId = Z.RewiredActionsConst.EnableMap,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.TrackUITurnLeft,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.TrackUITurnRight,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  camerasys_main_pc = {
    {
      ActionId = Z.RewiredActionsConst.Photograph,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    },
    {
      ActionId = Z.RewiredActionsConst.Mounts,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  camerasys = {
    {
      ActionId = Z.RewiredActionsConst.Photograph,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    },
    {
      ActionId = Z.RewiredActionsConst.Mounts,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  expression_fast_window_pc = {
    {
      ActionId = Z.RewiredActionsConst.ExpressionSetting,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionPageSwitch,
      InputActionEventType = Z.InputActionEventType.AxisActiveOrJustInactive,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExpressionFast,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  fishing_btn_ctrl = {
    {
      ActionId = Z.RewiredActionsConst.FishingClick,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingClick,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  fishing_main_window = {
    {
      ActionId = Z.RewiredActionsConst.FishingLevel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingStudy,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingBait,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingRod,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingGuide,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingSetting,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.FishingPlayerDetail,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  helpsys_popup_entrance_tpl = {
    {
      ActionId = Z.RewiredActionsConst.HelpView,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  interaction_skip_window = {
    {
      ActionId = Z.RewiredActionsConst.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  main_chat_pc = {
    {
      ActionId = Z.RewiredActionsConst.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.OpenChat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ExitUI,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.ChangeChatChannel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.UpChatChannel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.DownChatChannel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Chat,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0.5}
    }
  },
  main_line_window = {
    {
      ActionId = Z.RewiredActionsConst.SceneLine,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  map_main = {
    {
      ActionId = Z.RewiredActionsConst.EnableMap,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.CloseView
    }
  },
  main_take_medicine_sub = {
    {
      ActionId = Z.RewiredActionsConst.QuickUse1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.TakeMedicineLeft,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.TakeMedicineRight,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  talk_dialog_window = {
    {
      ActionId = Z.RewiredActionsConst.Jump,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0, 0.2}
    }
  },
  talk_option_window = {
    {
      ActionId = Z.RewiredActionsConst.NavigateInteraction,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.NavigateInteraction,
      InputActionEventType = Z.InputActionEventType.AxisActiveOrJustInactive,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Interact,
      InputActionEventType = Z.InputActionEventType.ButtonPressedForTimeJustReleased,
      TriggerType = E.InputTriggerViewActionType.Custom,
      Params = {0, 0.2}
    }
  },
  battle_auto_battle_set = {
    {
      ActionId = Z.RewiredActionsConst.OpenChat,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Skill1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Skill2,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Skill3,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Skill4,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.UltimateSkill,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.SpecialSkill,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.SupportSkill1,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.SupportSkill2,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  },
  dialog = {
    {
      ActionId = Z.RewiredActionsConst.Confirm,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    },
    {
      ActionId = Z.RewiredActionsConst.Cancel,
      InputActionEventType = Z.InputActionEventType.ButtonJustPressed,
      TriggerType = E.InputTriggerViewActionType.Custom
    }
  }
}
return actionConfig
