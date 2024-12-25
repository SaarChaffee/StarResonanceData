local WeaponHeroProfessionJob = {
  [1] = "WeaponHeroProfessionJob_1",
  [2] = "WeaponHeroProfessionJob_2",
  [3] = "WeaponHeroProfessionJob_3"
}
local WeaponHeroProfessionIconGray = {
  [1] = "WeaponHeroProfessionIconGray_1",
  [2] = "WeaponHeroProfessionIconGray_2",
  [3] = "WeaponHeroProfessionIconGray_3",
  [4] = "WeaponHeroProfessionIconGray_4",
  [5] = "WeaponHeroProfessionIconGray_5",
  [6] = "WeaponHeroProfessionIconGray_6"
}
local WeaponHeroProfessionNewIcon = {
  [1] = "WeaponHeroProfessionNewIcon_1",
  [2] = "WeaponHeroProfessionNewIcon_2",
  [3] = "WeaponHeroProfessionNewIcon_3",
  [4] = "WeaponHeroProfessionNewIcon_4",
  [5] = "WeaponHeroProfessionNewIcon_5",
  [6] = "WeaponHeroProfessionNewIcon_6"
}
local WeaponHeroProfessionNewIconGray = {
  [1] = "WeaponHeroProfessionNewIconGray_1",
  [2] = "WeaponHeroProfessionNewIconGray_2",
  [3] = "WeaponHeroProfessionNewIconGray_3",
  [4] = "WeaponHeroProfessionNewIconGray_4",
  [5] = "WeaponHeroProfessionNewIconGray_5",
  [6] = "WeaponHeroProfessionNewIconGray_6"
}
local WeaponHeroElement = {
  [1] = "WeaponHeroElement_1",
  [2] = "WeaponHeroElement_2",
  [3] = "WeaponHeroElement_3",
  [4] = "WeaponHeroElement_4"
}
local WeaponHeroJob = {
  [1] = "WeaponHeroProfessionJob_1",
  [2] = "WeaponHeroProfessionJob_2",
  [3] = "WeaponHeroProfessionJob_3",
  [4] = "WeaponHeroJob_4"
}
local WeaponHeroProfessionIconBg = {
  [0] = "WeaponHeroProfessionIconBg_0",
  [1] = "WeaponHeroProfessionIconBg_1",
  [2] = "WeaponHeroProfessionIconBg_2",
  [3] = "WeaponHeroProfessionIconBg_3",
  [4] = "WeaponHeroProfessionIconBg_4",
  [5] = "WeaponHeroProfessionIconBg_5",
  [6] = "WeaponHeroProfessionIconBg_6"
}
local WeaponHeroElementFrame = {
  [1] = "weaponhero_frame_1",
  [2] = "weaponhero_frame_2",
  [3] = "weaponhero_frame_3"
}
local WeaponHeroJobWithElement = {
  [1] = {
    [1] = "WeaponHeroJobWithElement_1_1",
    [2] = "WeaponHeroJobWithElement_1_2",
    [3] = "WeaponHeroJobWithElement_1_3"
  },
  [2] = {
    [1] = "WeaponHeroJobWithElement_1_1",
    [2] = "WeaponHeroJobWithElement_1_2",
    [3] = "WeaponHeroJobWithElement_1_3"
  },
  [3] = {
    [1] = "WeaponHeroJobWithElement_1_1",
    [2] = "WeaponHeroJobWithElement_1_2",
    [3] = "WeaponHeroJobWithElement_1_3"
  }
}
local WeaponEffectSignFrame = {
  [3] = "weap_sign_3",
  [4] = "weap_sign_4"
}
local WeaponEffectSignFrameBack = {
  [3] = "weap_sign_back_3",
  [4] = "weap_sign_back_4"
}
local ProfesCornerQuality = {
  [3] = "profes_corner_quality_3",
  [4] = "profes_corner_quality_4"
}
local SignCardProfessionIcon = {
  [1] = "sign_card_profession_icon_1",
  [2] = "sign_card_profession_icon_2",
  [3] = "sign_card_profession_icon_3",
  [4] = "sign_card_profession_icon_4",
  [5] = "sign_card_profession_icon_5",
  [6] = "sign_card_profession_icon_6"
}
local WeaponHeroProfessionIcon_0 = "WeaponHeroProfessionIcon_0"
local getProfessionJob = function(idx)
  return GetLoadAssetPath(WeaponHeroProfessionJob[idx])
end
local getProfessionIconGray = function(idx)
  return GetLoadAssetPath(WeaponHeroProfessionIconGray[idx])
end
local getProfessionNewIcon = function(idx)
  return GetLoadAssetPath(WeaponHeroProfessionNewIcon[idx])
end
local getProfessionNewIconGray = function(idx)
  return GetLoadAssetPath(WeaponHeroProfessionNewIconGray[idx])
end
local getJob = function(idx)
  return GetLoadAssetPath(WeaponHeroJob[idx])
end
local getElement = function(idx)
  return GetLoadAssetPath(WeaponHeroElement[idx])
end
local getWeaponHeroProfessionIconBg = function(idx)
  return GetLoadAssetPath(WeaponHeroProfessionIconBg[idx])
end
local getWeaponHeroProfessionIconNormal = function()
  return GetLoadAssetPath(WeaponHeroProfessionIcon_0)
end
local getWeaponHeroElementFrame = function(idx)
  return GetLoadAssetPath(WeaponHeroElementFrame[idx])
end
local getWeaponHeroJobWithElement = function(element, job)
  return GetLoadAssetPath(WeaponHeroJobWithElement[element][job])
end
local getWeaponEffectSignFrame = function(quality)
  return GetLoadAssetPath(WeaponEffectSignFrame[quality])
end
local getWeaponEffectSignFrameBack = function(quality)
  return GetLoadAssetPath(WeaponEffectSignFrameBack[quality])
end
local getWeaponProfesCornerImg = function(quality)
  return GetLoadAssetPath(ProfesCornerQuality[quality])
end
local getSignCardProfessionIcon = function(index)
  return GetLoadAssetPath(SignCardProfessionIcon[index])
end
local ret = {
  GetProfessionJob = getProfessionJob,
  GetProfessionIconGray = getProfessionIconGray,
  GetProfessionNewIcon = getProfessionNewIcon,
  GetProfessionNewIconGray = getProfessionNewIconGray,
  GetJob = getJob,
  GetElement = getElement,
  GetWeaponHeroProfessionIconBg = getWeaponHeroProfessionIconBg,
  GetWeaponHeroProfessionIconNormal = getWeaponHeroProfessionIconNormal,
  GetWeaponHeroElementFrame = getWeaponHeroElementFrame,
  GetWeaponHeroJobWithElement = getWeaponHeroJobWithElement,
  GetWeaponEffectSignFrame = getWeaponEffectSignFrame,
  GetWeaponEffectSignFrameBack = getWeaponEffectSignFrameBack,
  GetWeaponProfesCornerImg = getWeaponProfesCornerImg,
  GetSignCardProfessionIcon = getSignCardProfessionIcon
}
return ret
