local super = require("ui.component.loop_grid_view_item")
local HandbookReadingWorksLoopGridItem = class("HandbookReadingWorksLoopGridItem", super)
local handbookDefine = require("ui.model.handbook_define")

function HandbookReadingWorksLoopGridItem:ctor()
  self.uiBinder = nil
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
end

function HandbookReadingWorksLoopGridItem:OnInit()
end

function HandbookReadingWorksLoopGridItem:OnRefresh(data)
  local config = Z.TableMgr.GetTable("NoteReadingBookWorksTableMgr").GetRow(data)
  if config == nil then
    return
  end
  self.data = data
  if self.data then
    self.uiBinder.img_quality:SetImage(handbookDefine.MaterialQualityPath .. config.Quality)
    self.uiBinder.rimg_icon:SetImage(config.Icon)
    self.uiBinder.lab_name.text = config.WorksName
    local unlockCount = 0
    local allCount = 0
    local isNew = false
    for _, target in ipairs(config.TargetType) do
      if self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Read, target) then
        unlockCount = unlockCount + 1
      end
      if self.handbookVM_.IsNew(handbookDefine.HandbookType.Read, target) then
        isNew = true
      end
      allCount = allCount + 1
    end
    self.uiBinder.lab_gather.text = Lang("HandbookIsCollection", {val1 = unlockCount, val2 = allCount})
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, isNew)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function HandbookReadingWorksLoopGridItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.parent.UIView:SelectId(self.data)
  end
end

function HandbookReadingWorksLoopGridItem:OnUnInit()
end

return HandbookReadingWorksLoopGridItem
