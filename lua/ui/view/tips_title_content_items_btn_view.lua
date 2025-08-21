local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_title_content_items_btnView = class("Tips_title_content_items_btnView", super)
local itemClass = require("common.item_binder")

function Tips_title_content_items_btnView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_title_content_items_btn")
  self.itemClassTab_ = {}
end

function Tips_title_content_items_btnView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.lab_info.text = self.viewData.content
  self.uiBinder.lab_content.text = self.viewData.btnContent
  self:AddAsyncClick(self.uiBinder.btn_go, function()
    if self.viewData.func then
      self.viewData.func()
    end
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.btn_go.enabled = self.viewData.enabled
  if self.viewData.itemDataArray then
    Z.CoroUtil.create_coro_xpcall(function()
      local itemsVm = Z.VMMgr.GetVM("items")
      local path = self.uiBinder.prefab_cache:GetString("item")
      for key, itemData in ipairs(self.viewData.itemDataArray) do
        local itemName = key
        local unit = self:AsyncLoadUiUnit(path, itemName, self.uiBinder.rect_item, self.cancelSource:CreateToken())
        if unit then
          self.itemClassTab_[itemName] = itemClass.new(self)
          local unlockItemData = {
            uiBinder = unit,
            configId = itemData.ItemId,
            expendCount = itemData.ItemNum,
            lab = itemsVm.GetItemTotalCount(itemData.ItemId),
            labType = E.ItemLabType.Expend,
            isSquareItem = true,
            tipsBindPressCheckComp = self.uiBinder.presscheck
          }
          self.itemClassTab_[itemName]:Init(unlockItemData)
        end
      end
    end)()
  end
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, self.viewData.isCenter, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_title_content_items_btnView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  for _, item in pairs(self.itemClassTab_) do
    item:UnInit()
  end
  self.uiBinder.anim:ResetAniState("anim_iteminfo_tips_001")
  self.uiBinder.anim:ClearAll()
end

function Tips_title_content_items_btnView:OnRefresh()
end

return Tips_title_content_items_btnView
