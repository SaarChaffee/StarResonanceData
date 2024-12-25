local super = require("ui.component.loop_grid_view_item")
local PersonalzoneLabelIconItem = class("PersonalzoneLabelIconItem", super)

function PersonalzoneLabelIconItem:ctor()
end

function PersonalzoneLabelIconItem:InitListener()
end

function PersonalzoneLabelIconItem:OnInit()
  self.data_ = nil
  self.uiBinder.btn:AddListener(function()
    self.parent.UIView:AddSelectTags(self.data_.id)
  end)
end

function PersonalzoneLabelIconItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.data_.isSelect)
  local personalzoneTagTabelMgr = Z.TableMgr.GetTable("PersonalTagTableMgr")
  local config = personalzoneTagTabelMgr.GetRow(data.id)
  if config then
    self.uiBinder.img_icon:SetImage(config.TagIcon)
  end
end

function PersonalzoneLabelIconItem:OnUnInit()
end

function PersonalzoneLabelIconItem:OnBeforePlayAnim()
end

return PersonalzoneLabelIconItem
