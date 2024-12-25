local super = require("ui.component.loop_list_view_item")
local HelpsysLoopItem = class("HelpsysLoopItem", super)

function HelpsysLoopItem:ctor()
end

function HelpsysLoopItem:OnInit()
end

function HelpsysLoopItem:OnRefresh(data)
  self.data_ = data
  local helpLibraryTableRow = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(data.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
  if helpLibraryTableRow then
    self.uiBinder.lab_name_off.text = helpLibraryTableRow.Title
    self.uiBinder.lab_name_on.text = helpLibraryTableRow.Title
  end
  self.state = Z.RedPointMgr.GetRedState(E.RedType.HelpsysItemRed .. data.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.c_com_reddot, self.state)
end

function HelpsysLoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    if self.state then
      self.state = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.c_com_reddot, self.state)
    end
    self.uiView_ = self.parent.UIView
    self.uiView_:tabViewCallback(self.data_)
  end
end

function HelpsysLoopItem:OnUnInit()
end

return HelpsysLoopItem
