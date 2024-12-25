local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_bg_right_subView = class("Personalzone_bg_right_subView", super)
local DEFINE = require("ui.model.personalzone_define")
local loopGridView_ = require("ui/component/loop_grid_view")
local tagItem = require("ui.component.personalzone.personalzone_main_bg_item")

function Personalzone_bg_right_subView:ctor(parent)
  self.panel = nil
  self.viewData = nil
  self.parent_ = parent
  super.ctor(self, "personalzone_bg_right_sub", "personalzone/personalzone_bg_right_sub", UI.ECacheLv.None)
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.data_ = nil
end

function Personalzone_bg_right_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_update, function()
    local bgThemeId = self.personalzoneVm_.GetCurProfileImageId(DEFINE.ProfileImageType.PersonalzoneBg)
    self:SetSelect(bgThemeId)
    self.viewData.func(DEFINE.BgSubViewFuncType.Reset)
    Z.TipsVM.ShowTipsLang(1002102)
  end)
  self:AddAsyncClick(self.uiBinder.uibinder_save.btn, function()
    self.viewData.func(DEFINE.BgSubViewFuncType.Save)
    self.bgScrollRect_:RefreshListView(self.data_)
  end)
  self.bgScrollRect_ = loopGridView_.new(self, self.uiBinder.loopscroll_bg_item, tagItem, "personalzone_main_bg_item_tpl")
  if self.data_ then
    self:SetSelect(self.viewData.param, true)
  else
    self.data_ = {}
    local index = 0
    local profileImageConfigs = self.personalzoneVm_.GetProfileImageList(DEFINE.ProfileImageType.PersonalzoneBg)
    if profileImageConfigs then
      for _, config in pairs(profileImageConfigs) do
        index = index + 1
        self.data_[index] = {
          config = config,
          isSelect = config.Id == self.viewData.param
        }
      end
    end
    self.bgScrollRect_:Init(self.data_)
    self:refreshInfo(self.viewData.param)
  end
end

function Personalzone_bg_right_subView:OnDeActive()
  self.bgScrollRect_:UnInit()
  self.bgScrollRect_ = nil
end

function Personalzone_bg_right_subView:SetSelect(id, isInit)
  for _, value in ipairs(self.data_) do
    value.isSelect = value.config.Id == id
  end
  if isInit then
    self.bgScrollRect_:Init(self.data_)
  else
    self.bgScrollRect_:RefreshListView(self.data_)
  end
  self.viewData.func(DEFINE.BgSubViewFuncType.SelectBg, id)
  self:refreshInfo(id)
end

function Personalzone_bg_right_subView:refreshInfo(id)
  local bgConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.viewData.param)
  if bgConfig then
    self.uiBinder.lab_info.text = bgConfig.UnlockDes
  else
    self.uiBinder.lab_info.text = ""
  end
  local isUnlock = self.personalzoneVm_.CheckProfileImageIsUnlock(id)
  self.uiBinder.uibinder_save.lab_normal.text = Lang("Save")
  if isUnlock then
    self.uiBinder.uibinder_save.lab_normal.text = Lang("Save")
  else
    self.uiBinder.uibinder_save.lab_normal.text = Lang("common_lock")
  end
end

return Personalzone_bg_right_subView
