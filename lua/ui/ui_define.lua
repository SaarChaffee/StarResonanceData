local UIEnum = {}
UIEnum.ELayer = {
  UILayerBottom = 0,
  UILayerMain = 1,
  UILayerFunc = 2,
  UILayerFuncPopup = 3,
  UILayerDramaBottom = 4,
  UILayerTip = 5,
  UILayerDramaVideo = 6,
  UILayerDramaTop = 7,
  UILayerTop = 8,
  UILayerTipTop = 9,
  UILayerGuide = 10,
  UILayerSystem = 11,
  UILayerSystemTip = 12,
  UILayerSDK = 13,
  UILayerDebug = 14,
  UILayerMark = 15,
  UILayerCount = 16
}
UIEnum.ECacheLv = {
  None = -1,
  Low = 0,
  Middle = 1,
  High = 2
}
UIEnum.EType = {
  Exclusive = 1,
  Standalone = 2,
  Permanent = 3
}
UIEnum.EFocusLayer = {
  [UIEnum.ELayer.UILayerMain] = true,
  [UIEnum.ELayer.UILayerFunc] = true,
  [UIEnum.ELayer.UILayerFuncPopup] = true,
  [UIEnum.ELayer.UILayerDramaBottom] = true,
  [UIEnum.ELayer.UILayerDramaTop] = true,
  [UIEnum.ELayer.UILayerTop] = true,
  [UIEnum.ELayer.UILayerTipTop] = true,
  [UIEnum.ELayer.UILayerSystem] = true,
  [UIEnum.ELayer.UILayerSystemTip] = true,
  [UIEnum.ELayer.UILayerSDK] = true
}
UIEnum.ESceneMaskType = {
  None = 0,
  Normal = 1,
  Overlay = 2,
  Custom = 3
}
UIEnum.ESceneMaskKey = {Default = "default"}
return UIEnum
