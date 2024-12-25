local super = require("ui.component.loop_list_view_item")
local HelpsysFindLoopItem = class("HelpsysFindLoopItem", super)

function HelpsysFindLoopItem:ctor()
end

function HelpsysFindLoopItem:OnInit()
end

function HelpsysFindLoopItem:OnRefresh(data)
  self.uiBinder.lab_name.text = ""
  self.data_ = data
  local helpLibraryTableRow = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(self.data_.data.Id)
  if helpLibraryTableRow then
    self.uiBinder.lab_name.text = helpLibraryTableRow.Title
  end
end

function HelpsysFindLoopItem:OnPointerClick(go, eventData)
  self.uiView_ = self.parent.UIView
  self.uiView_:OnSelectedFindItem(self.data_)
end

function HelpsysFindLoopItem:OnUnInit()
end

return HelpsysFindLoopItem
