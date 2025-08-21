local super = require("ui.component.loop_list_view_item")
local starImgPath = "ui/atlas/treasure/treasure_img_star_"
local TreasureLoopItem = class("TreasureLoopItem", super)
local itemTypeIconPath = {
  [1] = "ui/atlas/item/c_tab_icon/com_icon_tab_01",
  [2] = "ui/atlas/item/c_tab_icon/com_icon_tab_247",
  [3] = "ui/atlas/item/c_tab_icon/com_icon_tab_62"
}
local itemBinder = require("common.item_binder")

function TreasureLoopItem:ctor()
  self.treasureVm_ = Z.VMMgr.GetVM("treasure")
  self.itemClass_ = {}
end

function TreasureLoopItem:OnInit()
  self.parent.UIView:AddClick(self.uiBinder.treasure_list_entrance_tpl.btn, function()
    local key = "treasure_reward_level"
    if self.isMaxRewardLevel_ then
      key = "treasure_reward_max_level"
    end
    local title = Lang(key, {
      val = self.nowRewradLevel_
    })
    local desc = ""
    if self.nextRewardLevelTargetId_ ~= 0 then
      local targetRow = Z.TableMgr.GetTable("WeeklyTreasureTargetTableMgr").GetRow(self.nextRewardLevelTargetId_)
      desc = targetRow.TargetDes .. Lang("treasure_reward_level_up")
    else
      desc = Lang("max_treasure_reward_level")
    end
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.treasure_list_entrance_tpl.tip_root, title, desc)
  end)
  self.parent.UIView:AddClick(self.uiBinder.treasure_list_entrance_tpl.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(self.config_.HelpId)
  end)
  for index = 1, 3 do
    local root = self.uiBinder["treasure_list_item_tpl_0" .. index]
    self.itemClass_[index] = itemBinder.new(self.parent.UIView)
    self.parent.UIView:AddClick(root.btn_tips, function()
      if self.treasureVm_:CheckCanGetTreasure() then
        if not self.targetFinish_[index] then
          Z.TipsVM.ShowTips(15010002)
        end
        return
      end
      local title = ""
      local desc = ""
      if self.targetFinish_[index] then
        title = Lang("CurrentBonus")
        desc = Lang("treasure_target_finish")
      else
        title = Lang("UnlockBonus")
        desc = Lang("treasure_target_not_finish")
      end
      Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder["treasure_list_item_tpl_0" .. index].tips_root, title, desc)
    end)
    self.parent.UIView:AddClick(root.btn_select, function()
      if self.targetFinish_[index] then
        self.parent.UIView:OnItemSelect(self.config_.Type, index, self.rewards_[index], root)
      else
        Z.TipsVM.ShowTips(15010002)
      end
    end)
  end
end

function TreasureLoopItem:OnRefresh(data)
  self.config_ = data.config
  self.serverData_ = data.serverData or {}
  self:refreshEntrance()
  self:refreshTarget()
  self:refreshReward()
end

function TreasureLoopItem:refreshEntrance()
  self.uiBinder.treasure_list_entrance_tpl.img_entrance:SetImage(self.config_.Picture)
  self.uiBinder.treasure_list_entrance_tpl.lab_name.text = self.config_.Name
  self.maxRewradLevel_ = 1 + #self.config_.UpTargetAward
  for i = 1, 5 do
    local star = self.uiBinder.treasure_list_entrance_tpl["img_star_0" .. i]
    self.uiBinder.treasure_list_entrance_tpl.Ref:SetVisible(star, i <= self.maxRewradLevel_)
    star:SetImage(starImgPath .. "off")
  end
  self.nowRewradLevel_ = 1
  self.nextRewardLevelTargetId_ = 0
  self.isMaxRewardLevel_ = true
  self.uiBinder.treasure_list_entrance_tpl.img_star_01:SetImage(starImgPath .. "on")
  for i = 1, #self.config_.UpTargetAward do
    self.isMaxRewardLevel_ = false
    local targetId = self.config_.UpTargetAward[i][1]
    local finishNum = 0
    local targetRow = Z.TableMgr.GetTable("WeeklyTreasureTargetTableMgr").GetRow(targetId)
    if self.serverData_.mainTargets then
      for _, value in pairs(self.serverData_.mainTargets) do
        if value.targetId == targetId then
          finishNum = value.targetNum
        end
      end
    end
    local star = self.uiBinder.treasure_list_entrance_tpl["img_star_0" .. self.nowRewradLevel_ + 1]
    if finishNum >= targetRow.Num then
      star:SetImage(starImgPath .. "on")
      self.nowRewradLevel_ = self.nowRewradLevel_ + 1
    else
      if self.nextRewardLevelTargetId_ == 0 then
        self.nextRewardLevelTargetId_ = targetId
      end
      star:SetImage(starImgPath .. "off")
    end
  end
  self.isMaxRewardLevel_ = self.nowRewradLevel_ - 1 >= #self.config_.UpTargetAward
end

function TreasureLoopItem:refreshTarget()
  self.targetFinish_ = {}
  for i = 1, 3 do
    local root = self.uiBinder["treasure_list_item_tpl_0" .. i]
    local baseTargetId = self.config_.Target[i]
    root.Ref:SetVisible(root.img_select, false)
    self.targetFinish_[i] = false
    if baseTargetId then
      root.Ref.UIComp:SetVisible(true)
      local targetRow = Z.TableMgr.GetTable("WeeklyTreasureTargetTableMgr").GetRow(baseTargetId)
      local finishNum = 0
      if self.serverData_.subTargets then
        for _, value in pairs(self.serverData_.subTargets) do
          if value.targetId == baseTargetId then
            finishNum = value.targetNum
          end
        end
      end
      self.targetFinish_[i] = finishNum >= targetRow.Num
      root.Ref:SetVisible(root.img_complete, finishNum >= targetRow.Num)
      root.Ref:SetVisible(root.img_unfinished, finishNum < targetRow.Num)
      root.Ref:SetVisible(root.rimg_icon_on, finishNum >= targetRow.Num)
      root.Ref:SetVisible(root.rimg_icon_off, finishNum < targetRow.Num)
      root.lab_progress_complete.text = finishNum .. "/" .. targetRow.Num
      root.lab_progress_unfinished.text = finishNum .. "/" .. targetRow.Num
      root.lab_name.text = targetRow.TargetDes
    else
      root.Ref.UIComp:SetVisible(false)
    end
  end
end

function TreasureLoopItem:refreshReward()
  self.rewards_ = {}
  for i = 1, 3 do
    local root = self.uiBinder["treasure_list_item_tpl_0" .. i]
    local baseTargetId = self.config_.Target[i]
    local hasReward = false
    if self.serverData_.subTargets then
      for _, value in pairs(self.serverData_.subTargets) do
        if value.targetId == baseTargetId then
          local item = value.reward.items[1]
          if item then
            self.rewards_[i] = value.reward
            root.item_uibinder.Ref.UIComp:SetVisible(true)
            root.Ref:SetVisible(root.img_type_item, true)
            root.img_type_icon:SetImage(itemTypeIconPath[value.reward.type])
            root.lab_type_name.text = Lang("treasure_type_" .. value.reward.type)
            root.Ref:SetVisible(root.img_item, false)
            local itemData = {
              uiBinder = root.item_uibinder,
              configId = item.configId,
              itemInfo = item,
              labType = E.ItemLabType.Num,
              lab = item.count
            }
            self.itemClass_[i]:Init(itemData)
            hasReward = true
          end
        end
      end
    end
    if not hasReward then
      root.Ref:SetVisible(root.img_type_item, false)
      root.Ref:SetVisible(root.img_item, true)
      root.item_uibinder.Ref.UIComp:SetVisible(false)
    end
    local canGetTreasure = self.treasureVm_:CheckCanGetTreasure()
    root.Ref:SetVisible(root.btn_select, canGetTreasure)
  end
end

function TreasureLoopItem:OnSelected(isSelected, isClick)
end

function TreasureLoopItem:OnUnInit()
  for _, value in ipairs(self.itemClass_) do
    value:UnInit()
  end
end

return TreasureLoopItem
