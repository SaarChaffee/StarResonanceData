local DEF = {}
local EAttrParamHairGradient = {
  IsOpen = 1,
  Range = 2,
  Color = 3
}
DEF.EAttrParamHairGradient = EAttrParamHairGradient
local EAttrParamFaceHandleData = {
  Scale = 1,
  X = 2,
  Y = 3,
  Rotation = 4,
  IsFlip = 5
}
DEF.EAttrParamFaceHandleData = EAttrParamFaceHandleData
DEF.ATTR_TABLE = {
  [Z.ModelAttr.EModelHairWearId] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "HairID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelFrontHair] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FrontHairID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelBackHair] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "BackHairID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelDullHair] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "DullHairID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = true
  },
  [Z.ModelAttr.EModelHeadFace] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FaceShapeID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadBrow] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyebrowID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadEye] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyeID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadTexLash] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyelashID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadTexEye_d] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "PupilID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadNose] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "NoseID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadMouth] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "MouthID"),
      Z.PbEnum("EFaceDataType", "Tooth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.TwoConfigTabRes
    },
    IsAllowNull = false
  },
  [Z.ModelAttr.EModelHeadBeard] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "BeardID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = true
  },
  [Z.ModelAttr.EModelHeadTexEye_Shadow] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyeshadowID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = true
  },
  [Z.ModelAttr.EModelHeadTexLip] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "LipstickID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = true
  },
  [Z.ModelAttr.EModelHeadTexFeature] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FeatureOneID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = true
  },
  [Z.ModelAttr.EModelHeadTexDecal] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FeatureTwoID")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.ConfigTableRes
    },
    IsAllowNull = true
  },
  [Z.ModelAttr.EModelAnimHeadPinchChinLength] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FaceLength")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.PinchHeadData
    }
  },
  [Z.ModelAttr.EModelAnimHeadPinchBrowAngle] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyebrowAngle")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.PinchHeadData
    }
  },
  [Z.ModelAttr.EModelAnimHeadPinchEyeUD] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyeUpDown")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.PinchHeadData
    }
  },
  [Z.ModelAttr.EModelAnimHeadPinchEyeAngle] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyeAngle")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.PinchHeadData
    }
  },
  [Z.ModelAttr.EModelAnimHeadPinchNoseUD] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "NoseUpDown")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.PinchHeadData
    }
  },
  [Z.ModelAttr.EModelPinchHeight] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "BodyHeight")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchArmThickness] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "ArmWidth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchChestWidth] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "ChestWidth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchWaistFatThin] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "WaistWidth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchCrotchWidth] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "CrotchWidth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchThighThickness] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "ThighWidth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchCalfThickness] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "ShankWidth")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelPinchFemaleChest] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FemaleChest")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.OriginValue
    }
  },
  [Z.ModelAttr.EModelSkinColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "SkinColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelBrowColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyebrowColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelLashColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyelashColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelBeardColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "BeardColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelEyeShadowColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "EyeshadowColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelLipColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "LipstickColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelFeatureColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FeatureOneColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelDecalColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FeatureTwoColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVector
    }
  },
  [Z.ModelAttr.EModelCHairGradient] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "HairIsGradual"),
      Z.PbEnum("EFaceDataType", "HairGradualRange"),
      Z.PbEnum("EFaceDataType", "HairGradualColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.HairGradualData
    }
  },
  [Z.ModelAttr.EModelCMountHairColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "HairColorBase"),
      Z.PbEnum("EFaceDataType", "HairOneHighlightsColor"),
      Z.PbEnum("EFaceDataType", "HairTwoHighlightsColor")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.HairColorZList
    }
  },
  [Z.ModelAttr.EModelLEyeArrColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "PupilLeftColor0"),
      Z.PbEnum("EFaceDataType", "PupilLeftColor1"),
      Z.PbEnum("EFaceDataType", "PupilLeftColor2"),
      Z.PbEnum("EFaceDataType", "PupilLeftColor3")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVectorZList
    }
  },
  [Z.ModelAttr.EModelREyeArrColor] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "PupilRightColor0"),
      Z.PbEnum("EFaceDataType", "PupilRightColor1"),
      Z.PbEnum("EFaceDataType", "PupilRightColor2"),
      Z.PbEnum("EFaceDataType", "PupilRightColor3")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.RGBVectorZList
    }
  },
  [Z.ModelAttr.EModelFaceFeatureData] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FeatureOneScale"),
      Z.PbEnum("EFaceDataType", "FeatureOnePosX"),
      Z.PbEnum("EFaceDataType", "FeatureOnePosY"),
      Z.PbEnum("EFaceDataType", "FeatureOneRotation"),
      Z.PbEnum("EFaceDataType", "FeatureOneIsReverse")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.FaceHandleData,
      Z.PbEnum("EFaceDataType", "FeatureOneID")
    }
  },
  [Z.ModelAttr.EModelFaceDecalData] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "FeatureTwoScale"),
      Z.PbEnum("EFaceDataType", "FeatureTwoPosX"),
      Z.PbEnum("EFaceDataType", "FeatureTwoPosY"),
      Z.PbEnum("EFaceDataType", "FeatureTwoRotation"),
      Z.PbEnum("EFaceDataType", "FeatureTwoIsReverse")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.FaceHandleData,
      Z.PbEnum("EFaceDataType", "FeatureTwoID")
    }
  },
  [Z.ModelAttr.EModelAnimHeadPinchEyeSize] = {
    OptionList = {
      Z.PbEnum("EFaceDataType", "PupilShortDiameter"),
      Z.PbEnum("EFaceDataType", "PupilLongDiameter")
    },
    UpdateParamList = {
      E.FaceAttrUpdateMode.PupilVector
    }
  }
}
local EOptionValueType = {
  Id = 1,
  Float = 2,
  HSV = 3,
  Bool = 4
}
DEF.EOptionValueType = EOptionValueType
local EOptionInitType = {
  FaceId = 1,
  OriginValue = 2,
  BodyParam = 3,
  HSVVector = 4,
  Switch = 5,
  HairHighlightsColor = 6,
  HairGradualColor = 7,
  PupilAreaColor = 8,
  PartHair = 9,
  FeatureData = 10,
  FeatureColor = 11
}
DEF.EOptionInitType = EOptionInitType
DEF.OPTION_TABLE = {
  [Z.PbEnum("EFaceDataType", "HairID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Hair"
    }
  },
  [Z.PbEnum("EFaceDataType", "FrontHairID")] = {
    InitParamList = {
      EOptionInitType.PartHair,
      "Fhair"
    }
  },
  [Z.PbEnum("EFaceDataType", "BackHairID")] = {
    InitParamList = {
      EOptionInitType.PartHair,
      "Bhair"
    }
  },
  [Z.PbEnum("EFaceDataType", "DullHairID")] = {
    InitParamList = {
      EOptionInitType.PartHair,
      "DullHair"
    }
  },
  [Z.PbEnum("EFaceDataType", "FaceShapeID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Face"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyebrowID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Eyebrow"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyeID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Eye"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyelashID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "LashTex"
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "EyeTex"
    }
  },
  [Z.PbEnum("EFaceDataType", "NoseID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Nose"
    }
  },
  [Z.PbEnum("EFaceDataType", "MouthID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Mouth"
    }
  },
  [Z.PbEnum("EFaceDataType", "Tooth")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Tooth"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyeshadowID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "EyeShadow"
    }
  },
  [Z.PbEnum("EFaceDataType", "LipstickID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Lip"
    }
  },
  [Z.PbEnum("EFaceDataType", "BeardID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Beard"
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOneID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Feature"
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoID")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "DecalTex"
    }
  },
  [Z.PbEnum("EFaceDataType", "FaceLength")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "Chin"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyebrowAngle")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "EyebrowAngle"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyeUpDown")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "EyeUpDown"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyeAngle")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "EyeAngle"
    }
  },
  [Z.PbEnum("EFaceDataType", "NoseUpDown")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "NoseUpDown"
    }
  },
  [Z.PbEnum("EFaceDataType", "BodyHeight")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "HeightParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "ArmWidth")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "ArmParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "ChestWidth")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "ChestParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "WaistWidth")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "WaistParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "CrotchWidth")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "CrotchParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "ThighWidth")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "ThighParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "ShankWidth")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "CalfParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "FemaleChest")] = {
    InitParamList = {
      EOptionInitType.BodyParam,
      "FemaleParm"
    }
  },
  [Z.PbEnum("EFaceDataType", "SkinColor")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "Skin"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyebrowColor")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "EyebrowColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyelashColor")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "LashColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "BeardColor")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "BeardColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "EyeshadowColor")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "EyeShadowColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "LipstickColor")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "LipColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "HairOneIsHighlights")] = {
    InitParamList = {
      EOptionInitType.Switch,
      "HairHighlight"
    }
  },
  [Z.PbEnum("EFaceDataType", "HairTwoIsHighlights")] = {
    InitParamList = {
      EOptionInitType.Switch,
      "HairHighlight2"
    }
  },
  [Z.PbEnum("EFaceDataType", "HairOneHighlightsColor")] = {
    InitParamList = {
      EOptionInitType.HairHighlightsColor,
      2
    }
  },
  [Z.PbEnum("EFaceDataType", "HairTwoHighlightsColor")] = {
    InitParamList = {
      EOptionInitType.HairHighlightsColor,
      3
    }
  },
  [Z.PbEnum("EFaceDataType", "HairColorBase")] = {
    InitParamList = {
      EOptionInitType.HSVVector,
      "HairColor",
      1
    }
  },
  [Z.PbEnum("EFaceDataType", "HairIsGradual")] = {
    InitParamList = {
      EOptionInitType.Switch,
      "HairGradient",
      1
    }
  },
  [Z.PbEnum("EFaceDataType", "HairGradualRange")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "HairGradient",
      2
    }
  },
  [Z.PbEnum("EFaceDataType", "HairGradualColor")] = {
    InitParamList = {
      EOptionInitType.HairGradualColor
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilIsDiff")] = {
    InitParamList = {
      EOptionInitType.Switch,
      "EyeColorDiff"
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilIsArea")] = {
    InitParamList = {
      EOptionInitType.Switch,
      "ColorZone"
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilLeftColor0")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      1,
      true
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilLeftColor1")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      2,
      true
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilLeftColor2")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      3,
      true
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilLeftColor3")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      4,
      true
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilRightColor0")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      1,
      false
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilRightColor1")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      2,
      false
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilRightColor2")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      3,
      false
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilRightColor3")] = {
    InitParamList = {
      EOptionInitType.PupilAreaColor,
      4,
      false
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOneScale")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      1,
      EAttrParamFaceHandleData.Scale
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOnePosX")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      1,
      EAttrParamFaceHandleData.X
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOnePosY")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      1,
      EAttrParamFaceHandleData.Y
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOneRotation")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      1,
      EAttrParamFaceHandleData.Rotation
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOneIsReverse")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      1,
      EAttrParamFaceHandleData.IsFlip
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureOneColor")] = {
    InitParamList = {
      EOptionInitType.FeatureColor,
      1,
      "FeatureColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoScale")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      2,
      EAttrParamFaceHandleData.Scale
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoPosX")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      2,
      EAttrParamFaceHandleData.X
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoPosY")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      2,
      EAttrParamFaceHandleData.Y
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoRotation")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      2,
      EAttrParamFaceHandleData.Rotation
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoIsReverse")] = {
    InitParamList = {
      EOptionInitType.FeatureData,
      2,
      EAttrParamFaceHandleData.IsFlip
    }
  },
  [Z.PbEnum("EFaceDataType", "FeatureTwoColor")] = {
    InitParamList = {
      EOptionInitType.FeatureColor,
      2,
      "DecalColor"
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilLongDiameter")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "EyeLong"
    }
  },
  [Z.PbEnum("EFaceDataType", "PupilShortDiameter")] = {
    InitParamList = {
      EOptionInitType.OriginValue,
      "EyeShort"
    }
  },
  [Z.PbEnum("EFaceDataType", "Tooth")] = {
    InitParamList = {
      EOptionInitType.FaceId,
      "Tooth"
    }
  }
}
return DEF
