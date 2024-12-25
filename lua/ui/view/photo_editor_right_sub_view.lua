local UI = Z.UI
local super = require("ui.ui_subview_base")
local Photoeditor_right_subView = class("Photoeditor_right_subView", super)
local TogsSubViewConfig = {
  [E.CamerasysFuncType.Frame] = {
    FunctionId = E.CamerasysFuncType.Frame,
    LuaFileName = "ui/view/photo_editor_container_frame_sub_view"
  },
  [E.CamerasysFuncType.Sticker] = {
    FunctionId = E.CamerasysFuncType.Sticker,
    LuaFileName = "ui/view/photo_editor_container_sticker_sub_view"
  },
  [E.CamerasysFuncType.Text] = {
    FunctionId = E.CamerasysFuncType.Text,
    LuaFileName = "ui/view/photo_editor_container_text_sub_view"
  },
  [E.CamerasysFuncType.Filter] = {
    FunctionId = E.CamerasysFuncType.Filter,
    LuaFileName = "ui/view/photo_editor_container_filter_sub_view"
  },
  [E.CamerasysFuncType.Shotset] = {
    FunctionId = E.CamerasysFuncType.Shotset,
    LuaFileName = "ui/view/photo_editor_container_moviescreen_sub_view"
  }
}
local TogIconPath = "ui/atlas/photograph/camera_menu_"

function Photoeditor_right_subView:ctor(parent)
  self.parent_ = parent
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "photo_editor_right_sub", "photograph/photoalbum_edit_right_sub", UI.ECacheLv.None)
  self.selectTogSubViewIndex_ = -1
  self.togSubViews_ = {}
  self.togUnits_ = {}
end

function Photoeditor_right_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_close, function()
    self:DeActive()
  end)
  self.selectTogSubViewIndex_ = -1
  self.togSubViews_ = {}
  self.togUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = self.uiBinder.uiprefab_cashdata:GetString("tag_tpl")
    local count = #self.viewData.togDatas
    for key, togInfo in ipairs(self.viewData.togDatas) do
      local config = TogsSubViewConfig[togInfo.functionId]
      local unitName = "togs_" .. config.FunctionId
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.layout_tog)
      if unit then
        local path = string.format("%s%s", TogIconPath, togInfo.functionId)
        unit.img_icon_ash:SetImage(path)
        unit.img_icon:SetImage(path)
        unit.tog.group = self.uiBinder.node_toggle
        unit.tog.isOn = false
        unit.tog:AddListener(function(isOn)
          if isOn then
            self:SelectTogsId(key)
          end
        end)
        self.togUnits_[key] = unit
      end
    end
    self.uiBinder.node_toggle:SetAllTogglesOff()
    self.togUnits_[self.viewData.selectIndex].tog.isOn = true
  end)()
end

function Photoeditor_right_subView:OnDeActive()
  self.uiBinder.node_toggle:ClearAll()
  if self.selectTogSubViewIndex_ ~= -1 then
    self.togSubViews_[self.selectTogSubViewIndex_]:DeActive()
  end
  self.selectTogSubViewIndex_ = -1
end

function Photoeditor_right_subView:SelectTogsId(index)
  if self.selectTogSubViewIndex_ == index then
    return
  end
  local view = self.togSubViews_[self.selectTogSubViewIndex_]
  if view then
    view:DeActive()
  end
  local info
  if self.viewData and self.viewData.togDatas then
    info = self.viewData.togDatas[index]
  end
  if info == nil then
    return
  end
  self.selectTogSubViewIndex_ = index
  if self.togSubViews_[index] == nil then
    local view = require(TogsSubViewConfig[info.functionId].LuaFileName).new(self)
    self.togSubViews_[index] = view
  end
  self.togSubViews_[index]:Active(info, self.uiBinder.node_container)
  self.curSelectTogSubView_ = self.togSubViews_[info]
end

return Photoeditor_right_subView
