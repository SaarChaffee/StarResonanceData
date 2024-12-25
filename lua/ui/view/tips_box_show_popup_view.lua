local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_box_show_popupView = class("Tips_box_show_popupView", super)
local itemClass = require("common.item")

function Tips_box_show_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_box_show_popup")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
end

function Tips_box_show_popupView:OnActive()
  self:BindEvents()
  self.itemClassTab_ = {}
  if not self.viewData then
    self:DeActive()
    return
  end
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.parentTrans.position)
  local showItemNode = self.viewData.itemList ~= nil and #self.viewData.itemList > 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_title, self.viewData.showTitle ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info, self.viewData.showContent ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, showItemNode)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line1, self.viewData.showContent ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line2, showItemNode)
  if self.viewData.showTitle then
    self.uiBinder.lab_title.text = self.viewData.showTitle
  end
  if self.viewData.showContent then
    self.uiBinder.lab_info.text = self.viewData.showContent
  end
  if showItemNode then
    self:RefreshItems()
  end
end

function Tips_box_show_popupView:RefreshItems()
  Z.CoroUtil.create_coro_xpcall(function()
    for i = 1, #self.viewData.itemList do
      local itemData = self.viewData.itemList[i]
      local itemPath = self.uiBinder.prefab_cache:GetString("previewItem")
      local itemName = string.format("item_%s", i)
      local item = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.node_info, self.cancelSource:CreateToken())
      if item ~= nil then
        self.itemClassTab_[itemName] = itemClass.new(self)
        local itemPreviewData = {}
        itemPreviewData.unit = item
        itemPreviewData.configId = itemData.awardId
        itemPreviewData.uiBinder = self.uiBinder
        itemPreviewData.labType, itemPreviewData.lab = self.awardPreviewVM_.GetPreviewShowNum(itemData)
        itemPreviewData.isShowZero = false
        itemPreviewData.isShowOne = true
        itemPreviewData.isShowReceive = itemData.beGet ~= nil and itemData.beGet
        itemPreviewData.isSquareItem = true
        itemPreviewData.PrevDropType = itemData.PrevDropType
        self.itemClassTab_[itemName]:Init(itemPreviewData)
      end
    end
  end)()
end

function Tips_box_show_popupView:OnDeActive()
  self.uiBinder.presscheck.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.presscheck:StopCheck()
end

function Tips_box_show_popupView:OnRefresh()
end

function Tips_box_show_popupView:BindEvents()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:DeActive()
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
end

return Tips_box_show_popupView
