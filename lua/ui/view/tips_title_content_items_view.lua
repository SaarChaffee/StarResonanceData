local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_title_content_itemsView = class("Tips_title_content_itemsView", super)
local itemClass = require("common.item_binder")

function Tips_title_content_itemsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_title_content_items")
  self.itemClassTab_ = {}
end

function Tips_title_content_itemsView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.lab_info.text = self.viewData.content
  if self.viewData.itemDataArray then
    Z.CoroUtil.create_coro_xpcall(function()
      local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
      local path = self.uiBinder.prefab_cache:GetString("item")
      for key, itemData in ipairs(self.viewData.itemDataArray) do
        local itemName = key
        local unit = self:AsyncLoadUiUnit(path, itemName, self.uiBinder.rect_item, self.cancelSource:CreateToken())
        if unit then
          self.itemClassTab_[itemName] = itemClass.new(self)
          local itemPreviewData = {
            uiBinder = unit,
            configId = itemData.awardId,
            isSquareItem = true,
            PrevDropType = itemData.PrevDropType
          }
          itemPreviewData.labType, itemPreviewData.lab = awardPreviewVm.GetPreviewShowNum(itemData)
          self.itemClassTab_[itemName]:Init(itemPreviewData)
        end
      end
    end)()
  end
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_title_content_itemsView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  for _, item in pairs(self.itemClassTab_) do
    item:UnInit()
  end
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_title_content_itemsView:OnRefresh()
end

return Tips_title_content_itemsView
