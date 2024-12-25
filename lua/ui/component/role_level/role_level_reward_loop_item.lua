local super = require("ui.component.loop_list_view_item")
local RoleLevelRewardItem = class("RoleLevelRewardItem", super)
local itemClass = require("common.item_binder")
local awardType = {
  prop = 1,
  attr = 2,
  func = 3
}

function RoleLevelRewardItem:initZWidget()
end

function RoleLevelRewardItem:ctor()
  self.roleLevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
  self.itemClass_ = nil
end

function RoleLevelRewardItem:OnInit()
  self:initZWidget()
end

function RoleLevelRewardItem:OnUnInit()
  if self.itemClass_ then
    self.itemClass_:UnInit()
  end
  self.itemClass_ = nil
  self.roleLevelVm_.CloseRoleLevelItems()
end

function RoleLevelRewardItem:Refresh()
  self.index_ = self.Index + 1
  self.data_ = self:GetCurData()
  self:SetRewardItem()
end

function RoleLevelRewardItem:SetRewardItem()
  self.itemClass_ = itemClass.new(self.parent.UIView)
  local itemPreviewData = {}
  local clickCallFunc
  local levelData = {}
  if self.data_.type == awardType.prop then
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local itemData = self.data_.data
    itemPreviewData = {
      uiBinder = self.uiBinder,
      configId = itemData.awardId,
      isSquareItem = true,
      PrevDropType = itemData.PrevDropType
    }
    itemPreviewData.labType, itemPreviewData.lab = awardPreviewVm.GetPreviewShowNum(itemData)
  elseif self.data_.type == awardType.attr then
    function clickCallFunc()
      levelData = {
        LevelAwardID = 0,
        
        Level = self.data_.level,
        LevelUpAttr = {
          self.data_.attr
        },
        ExplainText = ""
      }
      self.roleLevelVm_.OpenRoleLevelItemTips(self.uiBinder.Trans, levelData)
    end
    
    itemPreviewData = {
      uiBinder = self.uiBinder,
      iconPath = "item_icons_virtually_attr",
      qualityPath = Z.ConstValue.Item.ItemQualityPath .. "4",
      clickCallFunc = clickCallFunc,
      isSquareItem = true
    }
  elseif self.data_.type == awardType.func then
    function clickCallFunc()
      levelData = {
        LevelAwardID = 0,
        
        LevelUpAttr = {},
        ExplainText = self.data_.explainText
      }
      self.roleLevelVm_.OpenRoleLevelItemTips(self.uiBinder.Trans, levelData)
    end
    
    itemPreviewData = {
      uiBinder = self.uiBinder,
      iconPath = "rolelevel_item_icon_function",
      qualityPath = Z.ConstValue.QualityImgSquareBg .. 5,
      clickCallFunc = clickCallFunc,
      isSquareItem = true
    }
  end
  self.itemClass_:Init(itemPreviewData)
  self.itemClass_:SetReceive(self.data_.isGetAward)
end

return RoleLevelRewardItem
