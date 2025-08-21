local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_edit_bg_subView = class("Personalzone_edit_bg_subView", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")
local LoopListView = require("ui/component/loop_list_view")
local PersonalzoneEditBgItem = require("ui/component/personalzone/personalzone_edit_bg_item")

function Personalzone_edit_bg_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_edit_bg_sub", "personalzone/personalzone_edit_bg_sub", UI.ECacheLv.None)
  self.parentView_ = parent
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
end

function Personalzone_edit_bg_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_goto, function()
    if self.functionSearchData_ then
      self.itemSourceVm_.JumpToSource(self.functionSearchData_)
    end
  end)
  local configs = self.personalzoneVm_.GetProfileImageList(PersonalZoneDefine.ProfileImageType.PersonalzoneBg)
  local index = 1
  for k, v in ipairs(configs) do
    if v.Id == self.parentView_:GetCurBgId() then
      index = k
      break
    end
  end
  self.listItem_ = LoopListView.new(self, self.uiBinder.loop_item, PersonalzoneEditBgItem, "personalzone_edit_bg_item_tpl")
  self.listItem_:Init(configs)
  self.listItem_:SetSelected(index)
  self:refreshSearchData(self.parentView_:GetCurBgId())
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnPersonalBgRefresh, self.refreshLoopList, self)
end

function Personalzone_edit_bg_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnPersonalBgRefresh, self.refreshLoopList, self)
  self.listItem_:UnInit()
  self.listItem_ = nil
end

function Personalzone_edit_bg_subView:OnRefresh()
end

function Personalzone_edit_bg_subView:ChangeBg(id)
  self.parentView_:ChangeBg(id)
  self:refreshSearchData(id)
end

function Personalzone_edit_bg_subView:refreshSearchData(id)
  self.functionSearchData_ = self.itemSourceVm_.GetItemSource(id)[1]
  if self.functionSearchData_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, true)
    self.uiBinder.lab_info.text = string.format(Lang("FashionSource"), self.functionSearchData_.name)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, false)
  end
end

function Personalzone_edit_bg_subView:refreshLoopList()
  self.listItem_:RefreshAllShownItem()
end

return Personalzone_edit_bg_subView
