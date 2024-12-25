local UI = Z.UI
local super = require("ui.ui_subview_base")
local Sys_right_subView = class("Sys_right_subView", super)
local TogsConfig = {
  [1] = {
    Id = 1,
    LuaFileName = "ui/view/personalzone_bg_right_sub_view",
    TogIcon = "ui/atlas/photograph/camera_main_photo",
    Sort = 1
  },
  [2] = {
    Id = 2,
    LuaFileName = "ui/view/personalzone_model_anim_sub_view",
    TogIcon = "ui/atlas/photograph/camera_main_action",
    Sort = 2
  }
}

function Sys_right_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  super.ctor(self, "sys_right_sub", "personalzone/sys_right_sub", UI.ECacheLv.None)
  self.togUnits_ = {}
  self.togSubViews_ = {}
  self.curSelectTogSubView_ = nil
end

function Sys_right_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    if self.viewData.closeFunc then
      self.viewData.closeFunc()
    else
      self:DeActive()
    end
  end)
  table.sort(self.viewData.togs, function(a, b)
    return TogsConfig[a.tog].Sort < TogsConfig[b.tog].Sort
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    local selectUnit
    local unitPath = self.uiBinder.uiprefab_cashdata:GetString("cont_togs")
    for _, togInfo in ipairs(self.viewData.togs) do
      local config = TogsConfig[togInfo.tog]
      local unitName = "togs_" .. config.Id
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.rect_togs_group)
      if unit then
        unit.img_on:SetImage(config.TogIcon)
        unit.img_off:SetImage(config.TogIcon)
        unit.tog_tab_select.group = self.uiBinder.layout_togs_group
        self:AddClick(unit.tog_tab_select, function()
          self:SelectTogsId(togInfo)
        end)
        self.togUnits_[togInfo.tog] = unit
        if togInfo.tog == self.viewData.selectTogs then
          selectUnit = unit
        end
      end
    end
    self.uiBinder.layout_togs_group:SetAllTogglesOff()
    if selectUnit then
      selectUnit.tog_tab_select.isOn = true
    end
    self:SelectTogsId(self.viewData.togs[self.viewData.selectTogs])
  end)()
end

function Sys_right_subView:OnDeActive()
  self.uiBinder.layout_togs_group:ClearAll()
  if self.curSelectTogSubView_ then
    self.curSelectTogSubView_:DeActive()
  end
  self.curSelectTogSubView_ = nil
end

function Sys_right_subView:SelectTogsId(togInfo)
  if self.curSelectTogSubView_ then
    self.curSelectTogSubView_:DeActive()
  end
  if self.togSubViews_[togInfo.tog] == nil then
    local view = require(TogsConfig[togInfo.tog].LuaFileName).new(self)
    self.togSubViews_[togInfo.tog] = view
  end
  self.togSubViews_[togInfo.tog]:Active(togInfo, self.uiBinder.rect_container)
  self.curSelectTogSubView_ = self.togSubViews_[togInfo.tog]
end

return Sys_right_subView
