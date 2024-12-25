local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_schemeView = class("Camera_menu_container_schemeView", super)
local cameraData_ = Z.DataMgr.Get("camerasys_data")
local cameraVm_ = Z.VMMgr.GetVM("camerasys")

function Camera_menu_container_schemeView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_menu_container_scheme_sub", "photograph/camera_menu_container_scheme_sub", UI.ECacheLv.None)
end

function Camera_menu_container_schemeView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  local schemeScrollRect = self.panel.loopscroll_scheme.VLoopScrollRect
  self.schemeScrollRect_ = require("ui/component/loopscrollrect").new(schemeScrollRect, self, require("ui.component.camerasys.camera_setting_config_item"))
  self:initBtn()
  self.selectedItem_ = nil
  cameraData_.IsInitSchemeState = true
  self:refSchemeDatas()
  self:BindEvents()
end

function Camera_menu_container_schemeView:SetSelectedItem(item)
  self.selectedItem_ = item
end

function Camera_menu_container_schemeView:initBtn()
  self.panel.img_btn_add.Btn:AddListener(function()
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
  self:AddClick(self.panel.cont_btn_preservation.Btn, function()
    if not cameraData_:GetIsSchemeParamUpdated() then
      return
    end
    local schemeInfo = cameraData_:GetCameraSchemeInfo()
    cameraVm_.SaveCameraSchemeInfoEX(schemeInfo)
    cameraData_:SetIsSchemeParamUpdated(false)
    Z.TipsVM.ShowTipsLang(1000001)
    self:checkSchemeIsUpdated()
  end)
  self.panel.cont_btn_delete.Btn:AddListener(function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DeleteAlubmScheme"), function()
      cameraVm_.DeleteCameraSchemeInfo(cameraData_.CameraSchemeSelectInfo)
      self:refSchemeDatas()
      cameraData_.CameraSchemeSelectIndex = 0
      self.schemeScrollRect_:SetSelected(0)
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  end)
  self.panel.cont_btn_compile.Btn:AddListener(function()
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
        local vm = Z.VMMgr.GetVM("screenword")
        vm.CheckScreenWord(value, E.TextCheckSceneType.TextCheckAlbumPhotoEditText, self.cancelSource:CreateToken(), function()
          schemedata.schemeName = value
          cameraVm_.ReplaceCameraSchemeInfo(schemedata)
          self.schemeScrollRect_:RefreshAllItem()
        end)
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
  self.panel.layout_btn_2:SetVisible(isShow)
  self:checkSchemeIsUpdated()
end

function Camera_menu_container_schemeView:refSchemeDatas(eventData)
  self.schemeScrollRect_:ClearSelected()
  local schemeInfoDatas = cameraData_:GetSchemeInfoDatas()
  table.sort(schemeInfoDatas, function(a, b)
    return a.schemeTime < b.schemeTime
  end)
  self.schemeScrollRect_:SetData(schemeInfoDatas)
  if eventData and next(eventData) then
    cameraData_.CameraSchemeSelectIndex = eventData.index
    self.schemeScrollRect_:SetSelected(eventData.index)
  end
end

function Camera_menu_container_schemeView:OnDeActive()
  self:UnBindEvents()
  cameraData_.IsInitSchemeState = true
  self.schemeScrollRect_:ClearSelected()
end

function Camera_menu_container_schemeView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.SchemeBtnUpdate, self.changeBottom, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.RefSchemeLsit, self.refSchemeDatas, self)
end

function Camera_menu_container_schemeView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.SchemeBtnUpdate, self.changeBottom, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.RefSchemeLsit, self.refSchemeDatas, self)
end

function Camera_menu_container_schemeView:OnRefresh()
  self.schemeScrollRect_:SetSelected(cameraData_.CameraSchemeSelectIndex)
  self:checkSchemeIsUpdated()
end

function Camera_menu_container_schemeView:checkSchemeIsUpdated()
  local schemeUpdated = cameraData_:GetIsSchemeParamUpdated()
  self.panel.cont_btn_preservation.Btn.IsDisabled = not schemeUpdated
end

return Camera_menu_container_schemeView
