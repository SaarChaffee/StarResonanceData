local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_scheme_sub_pcView = class("Camera_menu_container_scheme_sub_pcView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local camera_setting_config_item_tpl_ = require("ui/component/camerasys/camera_setting_config_item_tpl_pc")

function Camera_menu_container_scheme_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_scheme_sub_pc", "photograph_pc/camera_menu_container_scheme_sub_pc", UI.ECacheLv.None)
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
end

function Camera_menu_container_scheme_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.schemeScrollRect_ = loopScrollRect_.new(self, self.uiBinder.scrollview_scheme_item, camera_setting_config_item_tpl_, "camera_setting_config_item_tpl_pc")
  self.schemeScrollRect_:Init({})
  self:initBtn()
  self.cameraData_.IsInitSchemeState = true
  self:refSchemeData()
  self:BindEvents()
end

function Camera_menu_container_scheme_sub_pcView:OnDeActive()
  self:UnBindEvents()
  self.cameraData_.IsInitSchemeState = true
  if self.schemeScrollRect_ then
    self.schemeScrollRect_:ClearAllSelect()
    self.schemeScrollRect_:UnInit()
    self.schemeScrollRect_ = nil
  end
end

function Camera_menu_container_scheme_sub_pcView:OnRefresh()
  self.schemeScrollRect_:SetSelected(self.cameraData_.CameraSchemeSelectIndex)
  self:checkSchemeIsUpdated()
end

function Camera_menu_container_scheme_sub_pcView:initBtn()
  self:AddClick(self.uiBinder.img_btn_add, function()
    local schemeInfoDatas = self.cameraData_:GetSchemeInfoDatas()
    if table.zcount(schemeInfoDatas) < 5 then
      self.cameraVM_.AddCameraSchemeInfo()
      self:refSchemeData()
      local count = table.zcount(self.schemeScrollRect_:GetData())
      self.cameraData_.CameraSchemeSelectIndex = count
      self.schemeScrollRect_:SetSelected(count)
    else
      self.cameraData_:SetCameraSchemeTempInfo()
      Z.UIMgr:OpenView("camera_config_popup")
    end
  end)
  self:AddClick(self.uiBinder.btn_preservation, function()
    if not self.cameraData_:GetIsSchemeParamUpdated() then
      return
    end
    local schemeInfo = self.cameraData_:GetCameraSchemeInfo()
    self.cameraVM_.SaveCameraSchemeInfoEX(schemeInfo)
    self.cameraData_:SetIsSchemeParamUpdated(false)
    Z.TipsVM.ShowTipsLang(1000053)
    self:checkSchemeIsUpdated()
  end)
  self:AddClick(self.uiBinder.btn_delete, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DeleteAlubmScheme"), function()
      self.cameraVM_.DeleteCameraSchemeInfo(self.cameraData_.CameraSchemeSelectInfo)
      self:refSchemeData()
      self.cameraData_.CameraSchemeSelectIndex = 1
      self.schemeScrollRect_:SetSelected(1)
    end)
  end)
  self:AddClick(self.uiBinder.btn_compile, function()
    self:amendName()
  end)
end

function Camera_menu_container_scheme_sub_pcView:amendName()
  local schemeData = self.schemeScrollRect_:GetDataByIndex(self.cameraData_.CameraSchemeSelectIndex)
  local limitNum = Z.Global.PlayerNameLimit
  local data = {
    title = Lang("UI_AlertsTitle_ChangeName"),
    inputContent = schemeData.schemeName,
    onConfirm = function(value)
      if value == "" or value == schemeData.schemeName then
        return
      end
      Z.CoroUtil.create_coro_xpcall(function()
        local result = self.cameraVM_.AsyncSetPhotoSchemeName(schemeData.id, value, self.cancelSource:CreateToken())
        if result and result.errCode == 0 then
          schemeData.schemeName = value
          self.cameraVM_.ReplaceCameraSchemeInfo(schemeData)
          self.schemeScrollRect_:RefreshAllShownItem()
        end
      end)()
    end,
    stringLengthLimitNum = limitNum,
    inputDesc = Lang("UI_AlertsContent_InputPlanName")
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Camera_menu_container_scheme_sub_pcView:changeBottom(cameraSchemeType)
  local isShow = false
  if cameraSchemeType == E.CameraSchemeType.CustomScheme then
    isShow = true
  end
  self:checkSchemeIsUpdated()
end

function Camera_menu_container_scheme_sub_pcView:refSchemeData(eventData)
  self.schemeScrollRect_:ClearAllSelect()
  local schemeInfoDatas = self.cameraData_:GetSchemeInfoDatas()
  table.sort(schemeInfoDatas, function(a, b)
    return a.schemeTime < b.schemeTime
  end)
  self.schemeScrollRect_:RefreshListView(schemeInfoDatas)
  if eventData and next(eventData) then
    self.cameraData_.CameraSchemeSelectIndex = eventData.index
    self.schemeScrollRect_:SetSelected(eventData.index)
  end
end

function Camera_menu_container_scheme_sub_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.SchemeBtnUpdate, self.changeBottom, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.RefSchemeList, self.refSchemeData, self)
end

function Camera_menu_container_scheme_sub_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.SchemeBtnUpdate, self.changeBottom, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.RefSchemeList, self.refSchemeData, self)
end

function Camera_menu_container_scheme_sub_pcView:checkSchemeIsUpdated()
  if self.cameraData_.CameraSchemeSelectIndex ~= 1 then
    local schemeUpdated = self.cameraData_:GetIsSchemeParamUpdated()
    self.uiBinder.btn_preservation.IsDisabled = not schemeUpdated
    self.uiBinder.btn_preservation.interactable = schemeUpdated
  end
end

function Camera_menu_container_scheme_sub_pcView:SetSchemeCanControls(index)
  local IsDisable = index == 1
  self.uiBinder.btn_preservation.IsDisabled = IsDisable
  self.uiBinder.btn_preservation.interactable = not IsDisable
  self.uiBinder.btn_delete.IsDisabled = IsDisable
  self.uiBinder.btn_delete.interactable = not IsDisable
  self.uiBinder.btn_compile.IsDisabled = IsDisable
  self.uiBinder.btn_compile.interactable = not IsDisable
end

return Camera_menu_container_scheme_sub_pcView
