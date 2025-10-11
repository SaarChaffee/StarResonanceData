local super = require("ui.component.loop_list_view_item")
local HandbookPostcardLoopListItem = class("HandbookPostcardLoopListItem", super)
local handbookDefine = require("ui.model.handbook_define")

function HandbookPostcardLoopListItem:ctor()
  self.uiBinder = nil
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
end

function HandbookPostcardLoopListItem:OnInit()
end

function HandbookPostcardLoopListItem:OnRefresh(data)
  local config = Z.TableMgr.GetTable("NotePostcardTableMgr").GetRow(data)
  if config == nil then
    return
  end
  self.data = data
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Postcard, self.data)
  if isUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_postcard, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_unlocked, false)
    self.uiBinder.rimg_postcard:SetImage(config.ListResources)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_postcard, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_unlocked, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Postcard, self.data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, isNew)
  self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
end

function HandbookPostcardLoopListItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.parent.UIView:SelectId(self.data)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  else
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
  end
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Postcard, self.data)
  if isNew then
    self.handbookVM_.SetNotNew(handbookDefine.HandbookType.Postcard, self.data)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, false)
  end
end

function HandbookPostcardLoopListItem:OnUnInit()
end

return HandbookPostcardLoopListItem
