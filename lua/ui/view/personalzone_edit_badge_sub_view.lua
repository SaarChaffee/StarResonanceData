local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_edit_badge_subView = class("Personalzone_edit_badge_subView", super)
local LoopGridView = require("ui/component/loop_grid_view")
local PersonalzoneEditBadge01TplItem = require("ui/component/personalzone/personalzone_edit_badge_01_tpl_item")

function Personalzone_edit_badge_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_edit_badge_sub", "personalzone/personalzone_edit_badge_sub", UI.ECacheLv.None)
  self.parentView_ = parent
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Personalzone_edit_badge_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_badge_book, function()
    self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneMedal)
  end)
  self.datas = {}
  local datasCount = 0
  local allConfigs = self.personalZoneData_:GetAllMedalConfig()
  for _, configs in pairs(allConfigs) do
    for _, config in ipairs(configs) do
      if 0 < self.itemsVm_.GetItemTotalCount(config.Id) then
        datasCount = datasCount + 1
        self.datas[datasCount] = config
      end
    end
  end
  self.listItem_ = LoopGridView.new(self, self.uiBinder.loop_item, PersonalzoneEditBadge01TplItem, "personalzone_edit_badge_01_tpl")
  self.listItem_:Init(self.datas)
  for k, v in ipairs(self.datas) do
    if self:IsSelect(v.Id) then
      self.listItem_:SetSelected(k)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, datasCount == 0)
  self.personalZoneData_:ClearMedalAddReddot()
  self.personalzoneVm_.CheckRed()
end

function Personalzone_edit_badge_subView:OnDeActive()
  self.listItem_:UnInit()
  self.listItem_ = nil
end

function Personalzone_edit_badge_subView:OnRefresh()
end

function Personalzone_edit_badge_subView:IsSelect(id)
  return self.parentView_:IsMedalUse(id)
end

function Personalzone_edit_badge_subView:SelectId(id)
  self.parentView_:SelectMedal(id)
end

function Personalzone_edit_badge_subView:RefreshAllShownItem()
  self.listItem_:RefreshAllShownItem()
end

return Personalzone_edit_badge_subView
