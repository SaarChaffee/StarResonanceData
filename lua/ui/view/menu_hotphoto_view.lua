local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_templateView = class("Menu_templateView", super)
local loopGridView = require("ui/component/loop_grid_view")
local face_hotphoto_item = require("ui.component.face.face_hotphoto_item")

function Menu_templateView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_hotphoto_sub", "face/face_menu_hotphoto_sub", UI.ECacheLv.None)
end

function Menu_templateView:OnActive()
  super.OnActive(self)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.loopItem_ = loopGridView.new(self, self.uiBinder.loop_item, face_hotphoto_item, "face_hotphoto_tpl", true)
  self.loopItem_:Init({})
  self:initTemplateItem()
end

function Menu_templateView:initTemplateItem()
  local rowList = {}
  for _, row in pairs(self.faceData_:GetFaceDataTableData()) do
    if row.Sex == self.faceData_.Gender and row.Model == self.faceData_.BodySize then
      table.insert(rowList, row)
    end
  end
  table.sort(rowList, function(a, b)
    return a.Sort < b.Sort
  end)
  self.loopItem_:RefreshListView(rowList, false)
  self.loopItem_:ClearAllSelect()
end

function Menu_templateView:OnSelect(data, index)
  if self.isRefreshIndex_ then
    self.isRefreshIndex_ = false
    return
  end
  self.faceVM_.RecordFaceEditorCommand(nil, index)
  local faceRandomVM = Z.VMMgr.GetVM("face_random")
  faceRandomVM.ApplyRandomFaceFile(string.zconcat("preset.", data.file))
  self.faceVM_.CacheFaceData()
end

function Menu_templateView:OnDeActive()
  self.loopItem_:UnInit()
  super.OnDeActive(self)
end

function Menu_templateView:ClearSelect()
  self.loopItem_:ClearAllSelect()
end

function Menu_templateView:IsAllowDyeing()
  return false
end

function Menu_templateView:refreshFaceMenuView(hotId)
  if not hotId then
    self.loopItem_:ClearAllSelect()
    return
  end
  self.isRefreshIndex_ = true
  self.loopItem_:ClearAllSelect()
  self.loopItem_:SelectIndex(hotId - 1)
end

return Menu_templateView
