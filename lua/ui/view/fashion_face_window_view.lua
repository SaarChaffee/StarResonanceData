local UI = Z.UI
local uibase = require("ui.ui_view_base")
local super = require("ui.view.fashion_system_view")
local Fashion_face_windowView = class("Fashion_face_windowView", super)

function Fashion_face_windowView:ctor()
  self.uiBinder = nil
  uibase.ctor(self, "fashion_face_window")
end

function Fashion_face_windowView:OnActive()
  super.OnActive(self)
  local regionDict = {}
  for _, region in pairs(E.FashionRegion) do
    regionDict[region] = 1
  end
  local settingVM = Z.VMMgr.GetVM("fashion_setting")
  local settingStr = settingVM.RegionDictToSettingStr(regionDict)
  if self.playerModel_ then
    self.playerModel_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
  end
  self.uiBinder.node_schedule.Ref.UIComp:SetVisible(false)
  self:refreshCustomBtn(false)
end

function Fashion_face_windowView:initPlayerModel()
  self.playerModel_ = Z.UnrealSceneMgr:GetCacheModel(self.faceData_.FaceModelName)
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
  Z.UIMgr:FadeOut()
end

function Fashion_face_windowView:clearModel()
  if self.playerModel_ then
    local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
    self.playerModel_:SetLuaAttr(Z.LocalAttr.EWearFashion, zList)
    zList:Recycle()
  end
  self.playerModel_ = nil
end

function Fashion_face_windowView:OnInputBack()
  if self.isOpenStyle_ then
    self.fashionVM_.CloseFashionFaceView()
  else
    self:OpenStyleView()
  end
end

function Fashion_face_windowView:OpenDyeingView(fashionId, area)
  self:showSubView(self.dyeingView_, {
    fashionId = fashionId,
    area = area,
    isPreview = true
  })
end

function Fashion_face_windowView:OpenStyleView()
  super.OpenStyleView(self, true)
end

return Fashion_face_windowView
