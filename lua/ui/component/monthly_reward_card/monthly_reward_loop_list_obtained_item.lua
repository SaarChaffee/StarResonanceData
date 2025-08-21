local super = require("ui.component.loop_list_view_item")
local MonthlyRewardLoopListObtainedItem = class("MonthlyRewardLoopListObtainedItem", super)

function MonthlyRewardLoopListObtainedItem:OnInit()
end

function MonthlyRewardLoopListObtainedItem:OnRefresh(data)
  self.data_ = data
  local config = Z.TableMgr.GetTable("NoteMonthCardTableMgr").GetRow(data)
  if config == nil then
    return
  end
  self.uiBinder.rimg_icon:SetImage(config.ListResources)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, self.IsSelected)
end

function MonthlyRewardLoopListObtainedItem:OnUnInit()
end

function MonthlyRewardLoopListObtainedItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, isSelected)
  self.parent.UIView:SetCardInfo(self.data_)
end

return MonthlyRewardLoopListObtainedItem
