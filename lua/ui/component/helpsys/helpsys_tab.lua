local HelpSysTab = class("HelpSysTab")
local helpSysFirstTabItem = require("ui/component/helpsys/helpsys_first_tab_item")

function HelpSysTab:ctor(uiView, parent, firstTpl, secondTpl)
  self.uiObj_ = nil
  self.parent_ = parent
  self.isVisible_ = true
  self.uiView_ = uiView
  self.firstTpl_ = firstTpl
  self.secondTpl_ = secondTpl
  self.firstList_ = {}
  self.lastSecondTab_ = nil
  self.defaultSelectId_ = 0
  self.isSearchState_ = false
end

function HelpSysTab:Init(datas, selectId)
  if selectId ~= nil then
    self.defaultSelectId_ = selectId
  end
  for firstIndex, value in ipairs(datas) do
    local firstItem = helpSysFirstTabItem.new(self, self.uiView_, self.parent_, self.firstTpl_, self.secondTpl_)
    firstItem:Init(value, firstIndex)
    table.insert(self.firstList_, firstItem)
  end
  self:layoutRebuilder()
end

function HelpSysTab:InitShow(isAllOpen)
  local isExist = false
  self.lastSecondTab_ = nil
  for firstIndex = 1, #self.firstList_ do
    local firstItem = self.firstList_[firstIndex]
    firstItem:SetEnable(true)
    if self.defaultSelectId_ == 0 and firstIndex == 1 then
      firstItem:SetOpen(true)
      self.lastSecondTab_ = firstItem:SetDefaultSelect(0)
    elseif firstItem:IsContain(self.defaultSelectId_) then
      firstItem:SetOpen(true)
      self.lastSecondTab_ = firstItem:SetDefaultSelect(self.defaultSelectId_)
    else
      firstItem:SetOpen(false)
    end
    isExist = true
  end
  self.lastSecondTab_:SetSelect(true)
  self.isSearchState_ = false
  self:layoutRebuilder()
  return isExist
end

function HelpSysTab:Search(isAllOpen, filter)
  local isExist = false
  local isEmpty = string.zisEmpty(filter)
  self.isSearchState_ = not isEmpty
  for firstIndex = 1, #self.firstList_ do
    local firstItem = self.firstList_[firstIndex]
    local filterFlag = firstItem:CheckFilterShow(filter)
    firstItem:SetEnable(filterFlag, filter)
    if filterFlag ~= E.HelpSysFilterType.None then
      firstItem:SetOpen(not isEmpty)
      isExist = true
    end
  end
  if self.lastSecondTab_ then
    self.lastSecondTab_:SetSelect(false)
    if isEmpty then
      self.lastSecondTab_:SetSelect(true)
      self.lastSecondTab_:GetParentItem():SetOpen(true)
    end
  end
  self:layoutRebuilder()
  return isExist
end

function HelpSysTab:layoutRebuilder()
  self.uiView_.uiBinder.node_content_LayoutRebuilder:ForceRebuildLayoutImmediate()
end

function HelpSysTab:SetOpen(firstTab)
  for i = 1, #self.firstList_ do
    if self.firstList_[i] == firstTab then
      self.firstList_[i]:SetOpen(true)
    else
      self.firstList_[i]:SetOpen(false)
    end
  end
end

function HelpSysTab:GetLastSecond()
  return self.lastSecondTab_
end

function HelpSysTab:SetLastSecond(item)
  self.lastSecondTab_ = item
end

function HelpSysTab:Callback(data)
  self.uiView_:tabViewCallback(data)
end

function HelpSysTab:GetSearchState()
  return self.isSearchState_
end

function HelpSysTab:UnInit()
  for i = 1, #self.firstList_ do
    self.firstList_[i]:UnInit()
  end
end

return HelpSysTab
