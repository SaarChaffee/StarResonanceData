local super = require("ui.component.loop_list_view_item")
local SkillRemodelItem = class("SkillRemodelItem", super)
local itemClass = require("common.item_binder")

function SkillRemodelItem:ctor()
end

function SkillRemodelItem:OnInit()
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.skillVm_ = Z.VMMgr.GetVM("skill")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.itemClassTab_ = {}
  self.itemUibinder_ = {}
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn_select, function()
    self.parent:SetSelected(self.Index)
  end)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
end

function SkillRemodelItem:OnRefresh(data)
  self.nodeId_ = data.Id
  self.data_ = data
  self.uiBinder.lab_digit.text = data.Level
  self.uiBinder.lab_title01.text = data.Name
  local remodelSkill = self.weaponSkillVm_:GetSkillRemodelLevel(data.SkillId)
  local red = self.weaponSkillVm_:GetSkillRemouldRedId(data.SkillId)
  local state = Z.RedPointMgr.GetRedState(red)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_red, data.Level == remodelSkill + 1 and state)
  if data.Level == remodelSkill then
    self.uiBinder.img_arrow:SetColorByHex("#71ccff")
  else
    self.uiBinder.img_arrow:SetColorByHex("#5d5d5f")
  end
  if remodelSkill >= data.Level then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_condition, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_advance, true)
    self.uiBinder.img_title_arrow:SetColorByHex("#6c431a")
    self.uiBinder.img_title:SetColorByHex("#a96e34")
  else
    if data.Level > remodelSkill + 1 then
      self.uiBinder.img_title_arrow:SetColorByHex("#494949")
      self.uiBinder.img_title:SetColorByHex("#777777")
    else
      self.uiBinder.img_title_arrow:SetColorByHex("#1a586c")
      self.uiBinder.img_title:SetColorByHex("#348ca9")
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_condition, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_advance, false)
  end
  local content, descList = self.weaponSkillVm_:ParseRemodelDesc(data.SkillId, data.Level)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_content, content)
  self.uiBinder.node_content:SetAnchorPosition(0, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow, self.Index < #self.parent.DataList)
  if #data.UlockSkillLevel ~= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_icon, true)
    local passCondition = Z.ConditionHelper.CheckCondition(data.UlockSkillLevel)
    local results = Z.ConditionHelper.GetConditionDescList(data.UlockSkillLevel)
    local conditionContent = ""
    for _, value in ipairs(results) do
      conditionContent = conditionContent .. value.Desc .. "\n"
    end
    if passCondition then
      self.uiBinder.Ref:SetVisible(self.uiBinder.condition_off, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.condition_on, true)
      self.uiBinder.lab_condition.text = Z.RichTextHelper.ApplyStyleTag(conditionContent, E.TextStyleTag.ConditionMet)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.condition_off, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.condition_on, false)
      self.uiBinder.lab_condition.text = Z.RichTextHelper.ApplyStyleTag(conditionContent, E.TextStyleTag.ConditionNotMet)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_icon, false)
    self.uiBinder.lab_condition.text = ""
  end
  self.costItem_ = {}
  for _, value in ipairs(data.UpgradeCost) do
    table.insert(self.costItem_, value)
  end
  for _, value in ipairs(data.UpgradeExtraCost) do
    table.insert(self.costItem_, value)
  end
  for _, value in ipairs(self.itemUibinder_) do
    value.itemUIBinder.Ref.UIComp:SetVisible(false)
  end
  local parent = self.uiBinder.layout_item
  local itemPath = GetLoadAssetPath(Z.ConstValue.Backpack.BackPack_Item_Unit_Addr1_8_New)
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(self.costItem_) do
      local itemUIBinder
      if self.itemUibinder_[index] and self.itemUibinder_[index].itemUIBinder then
        itemUIBinder = self.itemUibinder_[index].itemUIBinder
      end
      if itemUIBinder == nil then
        if self.itemUibinder_[index] then
          self.parent.UIView:RemoveUiUnit(self.itemUibinder_[index].name)
        end
        local slibingIndex = self.uiBinder.Trans:GetSiblingIndex()
        local data = {
          itemUIBinder = nil,
          name = slibingIndex .. "_" .. index
        }
        self.itemUibinder_[index] = data
        itemUIBinder = self.parent.UIView:AsyncLoadUiUnit(itemPath, slibingIndex .. "_" .. index, parent)
        self.itemUibinder_[index].itemUIBinder = itemUIBinder
      end
      itemUIBinder.Ref.UIComp:SetVisible(true)
      local totalCount = self.itemVm_.GetItemTotalCount(value[1])
      local itemClassData = {
        uiBinder = itemUIBinder,
        configId = value[1],
        isShowZero = true,
        lab = totalCount,
        expendCount = value[2],
        isSquareItem = true
      }
      if self.itemClassTab_[index] == nil then
        self.itemClassTab_[index] = itemClass.new(self.parent.UIView)
      end
      self.itemClassTab_[index]:Init(itemClassData)
      self.itemClassTab_[index]:SetExpendCount(totalCount, value[2])
    end
  end)()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function SkillRemodelItem:onItemCountChange()
  for index, value in ipairs(self.costItem_) do
    if self.itemClassTab_[index] == nil then
      return
    end
    local totalCount = self.itemVm_.GetItemTotalCount(value[1])
    self.itemClassTab_[index]:SetExpendCount(totalCount, value[2])
  end
end

function SkillRemodelItem:OnSelected()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  if self.IsSelected then
    self.parent.UIView:onItemSelected(self.data_)
  end
end

function SkillRemodelItem:OnUnInit()
  Z.CommonTipsVM.CloseRichText()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.itemClassTab_ = {}
  for _, value in ipairs(self.itemUibinder_) do
    self.parent.UIView:RemoveUiUnit(value.name)
  end
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
end

return SkillRemodelItem
