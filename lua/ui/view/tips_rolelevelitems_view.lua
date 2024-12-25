local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_rolelevelitemsView = class("Tips_rolelevelitemsView", super)
local itemClass = require("common.item_binder")

function Tips_rolelevelitemsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_rolelevelitems")
  self.itemClassTab_ = {}
end

function Tips_rolelevelitemsView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_award, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_attr, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, false)
  if self.viewData.award then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_award, true)
    self.uiBinder.lab_title_award.text = self.viewData.award.title
    if self.viewData.award.awards then
      Z.CoroUtil.create_coro_xpcall(function()
        local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
        local path = self.uiBinder.prefab_cache:GetString("item")
        for key, itemData in ipairs(self.viewData.itemDataArray) do
          local itemName = key
          local unit = self:AsyncLoadUiUnit(path, itemName, self.uiBinder.rect_award, self.cancelSource:CreateToken())
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
  end
  if self.viewData.attr then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_attr, true)
    self.uiBinder.lab_title_attr.text = self.viewData.attr.title
    self.uiBinder.lab_info_attr.text = self.viewData.attr.info
  end
  if self.viewData.unlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, true)
    self.uiBinder.lab_title_unlock.text = self.viewData.unlock.title
    self.uiBinder.lab_info_unlock.text = self.viewData.unlock.info
  end
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_rolelevelitemsView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  for _, item in pairs(self.itemClassTab_) do
    item:UnInit()
  end
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_rolelevelitemsView:OnRefresh()
end

return Tips_rolelevelitemsView
