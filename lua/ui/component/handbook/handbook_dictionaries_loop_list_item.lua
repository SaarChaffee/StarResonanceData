local super = require("ui.component.loop_list_view_item")
local HandbookDictionariesLoopListItem = class("HandbookDictionariesLoopListItem", super)
local handbookDefine = require("ui.model.handbook_define")

function HandbookDictionariesLoopListItem:ctor()
  self.uiBinder = nil
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
end

function HandbookDictionariesLoopListItem:OnInit()
end

function HandbookDictionariesLoopListItem:OnRefresh(data)
  local config = Z.TableMgr.GetTable("NoteDictionaryTableMgr").GetRow(data)
  if config == nil then
    return
  end
  self.data = data
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Dictionary, self.data)
  if isUnlock then
    self.uiBinder.lab_name_off.text = config.Name
    self.uiBinder.lab_name_on.text = config.Name
  else
    self.uiBinder.lab_name_off.text = Lang("HandbookLockContent")
    self.uiBinder.lab_name_on.text = Lang("HandbookLockContent")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Dictionary, self.data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, isNew)
end

function HandbookDictionariesLoopListItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, true)
    self.parent.UIView:SelectId(self.data, isClick)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  end
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Dictionary, self.data)
  if isNew then
    self.handbookVM_.SetNotNew(handbookDefine.HandbookType.Dictionary, self.data)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, false)
  end
end

function HandbookDictionariesLoopListItem:OnUnInit()
end

return HandbookDictionariesLoopListItem
