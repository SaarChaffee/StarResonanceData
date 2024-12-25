local super = require("ui.component.loop_grid_view_item")
local UnionActiveItem = class("UnionActiveItem", super)
local MAX_ITEM_COUNT = 3

function UnionActiveItem:OnInit()
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.uiBinder.btn_go:AddListener(function()
    self:OnGoBtnClick()
  end)
  for i = 1, MAX_ITEM_COUNT do
    local btn_item = self.uiBinder["btn_item_" .. i]
    btn_item:AddListener(function()
      self:OnItemBtnClick(i, btn_item.transform)
    end)
  end
  self.itemIdDict_ = {}
end

function UnionActiveItem:OnRefresh(data)
  local config = data.config
  local targetInfo = data.targetInfo
  local isReached = targetInfo and targetInfo.hasFinished
  local curValue = targetInfo and targetInfo.curNum or 0
  local targetValue = config.TargetId[2]
  if curValue > targetValue then
    curValue = targetValue
  end
  self.uiBinder.lab_title.text = config.UnionTitle
  self.uiBinder.lab_time.text = config.Label
  self.uiBinder.lab_desc.text = Z.Placeholder.Placeholder(config.UnionComment, {
    val = string.zconcat(curValue, "/", targetValue)
  })
  self.uiBinder.rimg_bg:SetImage(config.Picture)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_reached, isReached)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_go, not isReached)
  local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(config.AwardId)
  self.itemIdDict_ = {}
  for i = 1, MAX_ITEM_COUNT do
    local transItem = self.uiBinder["trans_item_" .. i]
    local awardInfo = awardList[i]
    if awardInfo then
      local labItem = self.uiBinder["lab_digit_" .. i]
      local imgItem = self.uiBinder["rimg_icon_" .. i]
      local itemInfo = self.itemTableMgr_.GetRow(awardInfo.awardId)
      if itemInfo then
        self.itemIdDict_[i] = awardInfo.awardId
        labItem.text = awardInfo.awardNum
        local itemsVM = Z.VMMgr.GetVM("items")
        imgItem:SetImage(itemsVM.GetItemIcon(awardInfo.awardId))
      end
    end
    self.uiBinder.Ref:SetVisible(transItem, awardInfo ~= nil)
  end
end

function UnionActiveItem:OnUnInit()
  self:closeItemTips()
end

function UnionActiveItem:OnGoBtnClick()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  quickJumpVm.DoJumpByConfigParam(curData.config.QuickJumpType, curData.config.QuickJumpParam)
end

function UnionActiveItem:OnItemBtnClick(index, trans)
  local itemConfigId = self.itemIdDict_[index]
  if itemConfigId == nil then
    return
  end
  self:closeItemTips()
  self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(trans, itemConfigId)
end

function UnionActiveItem:closeItemTips()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
end

return UnionActiveItem
