local UI = Z.UI
local uibase = require("ui.ui_view_base")
local super = require("ui.view.fashion_system_view")
local Fashion_face_windowView = class("Fashion_face_windowView", super)

function Fashion_face_windowView:ctor()
  self.uiBinder = nil
  uibase.ctor(self, "fashion_face_window")
  self.styleView_ = require("ui/view/fashion_style_select_view").new(self)
  self.dyeingView_ = require("ui/view/fashion_dyeing_view").new(self)
  self.settingView_ = require("ui/view/fashion_setting_sub_view").new(self)
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_return_btn, true)
  self:AddClick(self.uiBinder.btn_return_face, function()
    self.fashionVM_.CloseFashionFaceView()
  end)
  self:AddClick(self.uiBinder.btn_return_fashion, function()
    self:OpenStyleView()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_total_collection, false)
end

function Fashion_face_windowView:OnDeActive()
  super.OnDeActive(self)
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
  self.fashionVM_.CloseFashionFaceView()
end

function Fashion_face_windowView:OpenDyeingView(fashionId, area)
  self:updateSaveBtnState(fashionId)
  self.styleView_:DeActive()
  self.dyeingView_:Active({
    fashionId = fashionId,
    area = area,
    isPreview = true
  }, self.uiBinder.node_viewport)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_return_btn, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return_fashion, true)
end

function Fashion_face_windowView:onOpenStyleView()
  super.onOpenStyleView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_return_btn, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return_fashion, false)
end

return Fashion_face_windowView
