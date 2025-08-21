local super = require("ui.component.loop_list_view_item")
local HandbookDetailReadLoopListItem = class("HandbookDetailReadLoopListItem", super)
local handbookDefine = require("ui.model.handbook_define")

function HandbookDetailReadLoopListItem:ctor()
  self.uiBinder = nil
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
end

function HandbookDetailReadLoopListItem:OnInit()
end

function HandbookDetailReadLoopListItem:OnRefresh(data)
  self.data = data
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Read, self.data)
  if isUnlock then
    local config = Z.TableMgr.GetTable("NoteReadingBookTableMgr").GetRow(self.data)
    if config then
      self.uiBinder.lab_name_off.text = config.BookName
      self.uiBinder.lab_name_on.text = config.BookName
    end
  else
    self.uiBinder.lab_name_off.text = Lang("HandbookLockContent")
    self.uiBinder.lab_name_on.text = Lang("HandbookLockContent")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Read, self.data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, isNew)
end

function HandbookDetailReadLoopListItem:OnSelected(isSelected)
  if isSelected then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, true)
    self.parent.UIView:SelectId(self.data)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  end
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Read, self.data)
  if isNew then
    self.handbookVM_.SetNotNew(handbookDefine.HandbookType.Read, self.data)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, false)
  end
end

function HandbookDetailReadLoopListItem:OnUnInit()
end

return HandbookDetailReadLoopListItem
