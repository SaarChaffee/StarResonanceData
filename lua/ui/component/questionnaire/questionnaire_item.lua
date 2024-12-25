local super = require("ui.component.loop_list_view_item")
local QuestionnaireReceiveTplItem = class("QuestionnaireItem", super)
local itemClass = require("common.item_binder")

function QuestionnaireReceiveTplItem:ctor()
end

function QuestionnaireReceiveTplItem:OnInit()
  self.itemClass_ = itemClass.new(self.parent.UIView.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    isClickOpenTips = true,
    isSquareItem = true
  })
end

function QuestionnaireReceiveTplItem:OnRefresh(data)
  self.itemClass_:RefreshByData(data)
end

function QuestionnaireReceiveTplItem:OnUnInit()
  self.itemClass_:UnInit()
end

return QuestionnaireReceiveTplItem
