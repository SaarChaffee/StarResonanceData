local UnionTagItem = class("UnionTagItem")
local NORMAL_ICON_COLOR = Color.New(0.2784313725490196, 0.5764705882352941, 0.6549019607843137, 1)
local SELECT_ICON_COLOR = Color.black
local UNSELECT_ICON_COLOR = Color.white
local NORMAL_ON_COLOR = Color.New(0, 0, 0, 0)
local SELECT_ON_COLOR = Color.New(0.9058823529411765, 0.984313725490196, 0, 1)
local UNSELECT_ON_COLOR = Color.New(0, 0, 0, 0)
local LoadPathKey = {
  [E.UnionTagItemType.Normal] = Z.ConstValue.UnionLoadPathKey.UnionNormalTagItem,
  [E.UnionTagItemType.Selection] = Z.ConstValue.UnionLoadPathKey.UnionSelectionTagItem,
  [E.UnionTagItemType.Label] = Z.ConstValue.UnionLoadPathKey.UnionLabelTagItem
}

function UnionTagItem:ctor()
end

function UnionTagItem:Init(tagType, viewParent, transTimeTag, transActivityTag)
  self.allTagItemDict_ = {}
  self.allTagConfigDict_ = {}
  self.tagType_ = tagType
  self.view_ = viewParent
  self.trans_time_tag_ = transTimeTag
  self.trans_activity_tag_ = transActivityTag
end

function UnionTagItem:UnInit()
  self:clearAllTagItem()
  self.allTagConfigDict_ = {}
  self.tagList_ = nil
  self.itemPrefix_ = nil
  self.tagOnDict_ = nil
  self.callBack_ = nil
  self.loadedCallback_ = nil
  self.view_ = nil
  self.trans_time_tag_ = nil
  self.trans_activity_tag_ = nil
end

function UnionTagItem:SetCommonTagUI(tagIdList, binderParent, itemPrefix, tagOnDict)
  local unionTagTableMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  local tagConfigList = {}
  local isHaveTimeTag = false
  local isHaveActivityTag = false
  for i, id in ipairs(tagIdList) do
    local config = unionTagTableMgr.GetRow(id)
    if config then
      tagConfigList[i] = config
      if config.Type == E.UnionTagType.Time then
        isHaveTimeTag = true
      elseif config.Type == E.UnionTagType.Activity then
        isHaveActivityTag = true
      end
    end
  end
  self:SetTag(tagConfigList, itemPrefix, tagOnDict, function(tagConfig, binderItem)
    local viewData = {
      tagList = tagConfigList,
      trans = binderItem.Trans,
      type = 1
    }
    local unionVM = Z.VMMgr.GetVM("union")
    unionVM:OpenLabelTipsView(viewData)
  end)
  binderParent.Ref:SetVisible(self.trans_time_tag_, isHaveTimeTag)
  binderParent.Ref:SetVisible(self.trans_activity_tag_, isHaveActivityTag)
  binderParent.Ref:SetVisible(binderParent.lab_time_empty, not isHaveTimeTag)
  binderParent.Ref:SetVisible(binderParent.lab_activity_empty, not isHaveActivityTag)
end

function UnionTagItem:SetTag(tagList, itemPrefix, tagOnDict, callBack, loadedCallback)
  self.tagList_ = tagList
  self.itemPrefix_ = itemPrefix or "tag"
  self.tagOnDict_ = tagOnDict or {}
  self.callBack_ = callBack
  self.loadedCallback_ = loadedCallback
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearAllTagItem()
    self:createAllTagItem()
    if self.loadedCallback_ then
      self.loadedCallback_()
    end
  end)()
end

function UnionTagItem:createAllTagItem()
  local timeTagList = {}
  local activityTagList = {}
  for k, v in pairs(self.tagList_) do
    if v.IsHide == 0 then
      if v.Type == E.UnionTagType.Time then
        table.insert(timeTagList, v)
      elseif v.Type == E.UnionTagType.Activity then
        table.insert(activityTagList, v)
      end
    end
  end
  table.sort(timeTagList, function(a, b)
    return a.ShowSort < b.ShowSort
  end)
  table.sort(activityTagList, function(a, b)
    return a.ShowSort < b.ShowSort
  end)
  self:createTagItemByType(E.UnionTagType.Time, timeTagList, self.trans_time_tag_)
  self:createTagItemByType(E.UnionTagType.Activity, activityTagList, self.trans_activity_tag_)
end

function UnionTagItem:clearAllTagItem()
  for itemName, item in pairs(self.allTagItemDict_) do
    if self.tagType_ == E.UnionTagItemType.Normal then
      item.btn_item:RemoveAllListeners()
    elseif self.tagType_ == E.UnionTagItemType.Selection then
      item.tog_item:RemoveAllListeners()
    end
    self.view_:RemoveUiUnit(itemName)
  end
  self.allTagItemDict_ = {}
end

function UnionTagItem:createTagItemByType(type, tagList, parentTrans)
  for index, config in ipairs(tagList) do
    local itemName = string.zconcat(self.itemPrefix_, "_", self.tagType_, "_", type, "_", index)
    if self.allTagItemDict_[itemName] == nil then
      local itemPath = GetLoadAssetPath(LoadPathKey[self.tagType_])
      local binderItem = self.view_:AsyncLoadUiUnit(itemPath, itemName, parentTrans)
      self.allTagItemDict_[itemName] = binderItem
      self.allTagConfigDict_[itemName] = config
      if self.tagType_ == E.UnionTagItemType.Normal then
        self:SetNormalTag(binderItem, config)
      elseif self.tagType_ == E.UnionTagItemType.Selection then
        self:SetSelectionTag(binderItem, config, self.tagOnDict_[config.Id] or false)
      elseif self.tagType_ == E.UnionTagItemType.Label then
        self:SetLabelTag(binderItem, config)
      end
    end
  end
end

function UnionTagItem:SetNormalTag(binderItem, tagConfig)
  if tagConfig.ShowTagRoute ~= "" then
    binderItem.img_icon:SetImage(tagConfig.ShowTagRoute)
    binderItem.img_icon:SetColor(NORMAL_ICON_COLOR)
    binderItem.Ref:SetVisible(binderItem.img_icon, true)
  else
    binderItem.Ref:SetVisible(binderItem.img_icon, false)
  end
  binderItem.img_on:SetColor(NORMAL_ON_COLOR)
  if self.callBack_ then
    binderItem.btn_item:AddListener(function()
      self.callBack_(tagConfig, binderItem)
    end)
  end
end

function UnionTagItem:SetSelectionTag(binderItem, tagConfig, isOn)
  if tagConfig.ShowTagRoute ~= "" then
    binderItem.img_icon:SetImage(tagConfig.ShowTagRoute)
    binderItem.Ref:SetVisible(binderItem.img_icon, true)
  else
    binderItem.Ref:SetVisible(binderItem.img_icon, false)
  end
  binderItem.lab_title.text = tagConfig.Description
  binderItem.tog_item.isOn = isOn
  if self.callBack_ then
    binderItem.tog_item:AddListener(function(isOn)
      self.callBack_(tagConfig, binderItem, isOn)
    end)
  end
end

function UnionTagItem:SetLabelTag(binderItem, tagConfig)
  if tagConfig.ShowTagRoute ~= "" then
    binderItem.img_icon:SetImage(tagConfig.ShowTagRoute)
    binderItem.Ref:SetVisible(binderItem.img_icon, true)
  else
    binderItem.Ref:SetVisible(binderItem.img_icon, false)
  end
  binderItem.lab_title.text = tagConfig.Description
end

function UnionTagItem:SetTagColor(binderItem, isSelected)
  binderItem.img_icon:SetColor(isSelected and SELECT_ICON_COLOR or UNSELECT_ICON_COLOR)
end

function UnionTagItem:SetTagBgColor(binderItem, isSelected)
  binderItem.img_on:SetColor(isSelected and SELECT_ON_COLOR or UNSELECT_ON_COLOR)
end

function UnionTagItem:GetItemDict()
  local itemDict = {}
  for itemName, item in pairs(self.allTagItemDict_) do
    local config = self.allTagConfigDict_[itemName]
    itemDict[config.Id] = item
  end
  return itemDict
end

return UnionTagItem
