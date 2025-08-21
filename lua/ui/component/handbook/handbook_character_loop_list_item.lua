local super = require("ui.component.loop_list_view_item")
local HandbookCharacterLoopListItem = class("HandbookCharacterLoopListItem", super)
local handbookDefine = require("ui.model.handbook_define")
local lockColor = Color.New(0, 0, 0, 1)
local unlockColor = Color.New(1, 1, 1, 1)

function HandbookCharacterLoopListItem:ctor()
  self.uiBinder = nil
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
end

function HandbookCharacterLoopListItem:OnInit()
end

function HandbookCharacterLoopListItem:OnRefresh(data)
  local config = Z.TableMgr.GetTable("NoteImportantRoleTableMgr").GetRow(data)
  if config == nil then
    return
  end
  self.data = data
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Character, self.data)
  if self.data then
    self.uiBinder.rimg_avatar:SetImage(config.HeadIcon)
    if isUnlock then
      self.uiBinder.lab_name.text = config.RoleName
      self.uiBinder.rimg_avatar:SetColor(unlockColor)
    else
      self.uiBinder.lab_name.text = Lang("HandbookLockContent")
      self.uiBinder.rimg_avatar:SetColor(lockColor)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Character, self.data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, isNew)
end

function HandbookCharacterLoopListItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.parent.UIView:SelectId(self.data)
  end
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Character, self.data)
  if isNew then
    self.handbookVM_.SetNotNew(handbookDefine.HandbookType.Character, self.data)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, false)
  end
end

function HandbookCharacterLoopListItem:OnUnInit()
end

return HandbookCharacterLoopListItem
