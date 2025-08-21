local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_schemeView = class("Camera_menu_container_schemeView", super)
local cameraData_ = Z.DataMgr.Get("camerasys_data")
local cameraVm_ = Z.VMMgr.GetVM("camerasys")

function Camera_menu_container_schemeView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_scheme_sub", "photograph/camera_menu_container_scheme_sub", UI.ECacheLv.None)
end

function Camera_menu_container_schemeView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  local schemeScrollRect = self.uiBinder.loopscroll_scheme
  self.schemeScrollRect_ = require("ui/component/loopscrollrect").new(schemeScrollRect, self, require("ui.component.camerasys.camera_setting_config_item"))
  self:initBtn()
  cameraData_.IsInitSchemeState = true
  self:refSchemeDatas(nil, true)
  self:BindEvents()
end

function Camera_menu_container_schemeView:initBtn()
  self.uiBinder.img_btn_add:AddListener(function()
    local schemeInfoDatas = cameraData_:GetSchemeInfoDatas()
    if #schemeInfoDatas < 5 then
      cameraVm_.AddCameraSchemeInfo()
      self:refSchemeDatas()
      local count = self.schemeScrollRect_:GetCount() - 1
      cameraData_.CameraSchemeSelectIndex = count
      self.schemeScrollRect_:SetSelected(count)
    else
      cameraData_:SetCameraSchemeTempInfo()
      Z.UIMgr:OpenView("camera_config_popup")
    end
  end)
  self:AddClick(self.uiBinder.cont_btn_preservation, function()
    if not cameraData_:GetIsSchemeParamUpdated() then
      return
    end
    local schemeInfo = cameraData_:GetCameraSchemeInfo()
    cameraVm_.SaveCameraSchemeInfoEX(schemeInfo)
    cameraData_:SetIsSchemeParamUpdated(false)
    Z.TipsVM.ShowTipsLang(1000053)
    self:checkSchemeIsUpdated()
  end)
  self.uiBinder.cont_btn_delete:AddListener(function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DeleteAlubmScheme"), function()
      cameraVm_.DeleteCameraSchemeInfo(cameraData_.CameraSchemeSelectInfo)
      self:refSchemeDatas()
      cameraData_.CameraSchemeSelectIndex = 0
      self.schemeScrollRect_:SetSelected(0)
    end)
  end)
  self.uiBinder.cont_btn_compile:AddListener(function()
    self:amendName()
  end)
end

function Camera_menu_container_schemeView:amendName()
  local schemedata = self.schemeScrollRect_:GetDataByIndex(cameraData_.CameraSchemeSelectIndex + 1)
  local limitNum = Z.Global.PlayerNameLimit
  local data = {
    title = Lang("UI_AlertsTitle_ChangeName"),
    inputContent = schemedata.schemeName,
    onConfirm = function(value)
      if value == "" or value == schemedata.schemeName then
        return
      end
      Z.CoroUtil.create_coro_xpcall(function()
        local result = cameraVm_.AsyncSetPhotoSchemeName(schemedata.id, value, self.cancelSource:CreateToken())
        if result and result.errCode == 0 then
          schemedata.schemeName = value
          cameraVm_.ReplaceCameraSchemeInfo(schemedata)
          self.schemeScrollRect_:RefreshAllItem()
        end
      end)()
    end,
    stringLengthLimitNum = limitNum,
    inputDesc = Lang("UI_AlertsContent_InputPlanName")
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Camera_menu_container_schemeView:changeBottom(cameraSchemeType)
  local isShow = false
  if cameraSchemeType == E.CameraSchemeType.CustomScheme then
    isShow = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_btn_2, isShow)
  self:checkSchemeIsUpdated()
end

function Camera_menu_container_schemeView:refSchemeDatas(eventData, isInit)
  local schemeInfoDatas = cameraData_:GetSchemeInfoDatas()
  table.sort(schemeInfoDatas, function(a, b)
    return a.schemeTime < b.schemeTime
  end)
  if isInit then
    self.schemeScrollRect_:SetData(schemeInfoDatas)
  else
    self.schemeScrollRect_:RefreshData(schemeInfoDatas)
  end
  if eventData and next(eventData) then
    cameraData_.CameraSchemeSelectIndex = eventData.index
    self.schemeScrollRect_:SetSelected(eventData.index)
  end
end

function Camera_menu_container_schemeView:OnDeActive()
  self:UnBindEvents()
  cameraData_.IsInitSchemeState = true
  if self.schemeScrollRect_ then
    self.schemeScrollRect_:ClearCells()
    self.schemeScrollRect_ = nil
  end
end

function Camera_menu_container_schemeView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.SchemeBtnUpdate, self.changeBottom, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.RefSchemeList, self.refSchemeDatas, self)
end

function Camera_menu_container_schemeView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.SchemeBtnUpdate, self.changeBottom, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.RefSchemeList, self.refSchemeDatas, self)
end

function Camera_menu_container_schemeView:OnRefresh()
  self:refSchemeDatas()
  self.schemeScrollRect_:SetSelected(cameraData_.CameraSchemeSelectIndex)
  self:checkSchemeIsUpdated()
end

function Camera_menu_container_schemeView:checkSchemeIsUpdated()
  local schemeUpdated = cameraData_:GetIsSchemeParamUpdated()
  self.uiBinder.cont_btn_preservation.IsDisabled = not schemeUpdated
end

return Camera_menu_container_schemeView
