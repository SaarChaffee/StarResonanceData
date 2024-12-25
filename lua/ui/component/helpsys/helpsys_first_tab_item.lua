local HelpSysFirstTabItem = class("HelpSysFirstTabItem")
local helpSysSecondTab = require("ui/component/helpsys/helpsys_second_tab_item")

function HelpSysFirstTabItem:ctor(tabView, uiView, parent, firstTpl, secondTpl)
  self.uiObj_ = nil
  self.tabView_ = tabView
  self.parent_ = parent
  self.isVisible_ = true
  self.uiView_ = uiView
  self.firstTpl_ = firstTpl
  self.secondTpl_ = secondTpl
  self.secondList_ = {}
  self.isOpen_ = nil
  self.firstData_ = nil
end

function HelpSysFirstTabItem:Init(firstData, firstIndex)
  self.firstData_ = firstData
  self.firstIndex_ = firstIndex
  self.uiObj_ = self.uiView_:AsyncLoadUiUnit(self.firstTpl_, "first" .. firstIndex, self.parent_)
  self.uiObj_.lab_name_off.text = firstData.GroupName
  self.uiObj_.lab_name_on.text = firstData.GroupName
  self:layoutRebuilder()
  for secondIndex, data in ipairs(firstData.DataList) do
    local secondItem = helpSysSecondTab.new(self.tabView_, self.uiView_, self.uiObj_.layout_list, self.secondTpl_, self)
    secondItem:Init(data, firstIndex, secondIndex, secondIndex == #firstData.DataList)
    table.insert(self.secondList_, secondItem)
  end
  self:SetOpen(false)
  self:addClick()
end

function HelpSysFirstTabItem:addClick()
  self.uiView_:AddClick(self.uiObj_.btn_more, function()
    if self.tabView_:GetSearchState() then
      return
    end
    if self.isOpen_ then
      self.tabView_:SetOpen(nil)
      self:layoutRebuilder()
      return
    end
    self.tabView_:SetOpen(self)
    self:layoutRebuilder()
  end)
end

function HelpSysFirstTabItem:Refresh()
end

function HelpSysFirstTabItem:layoutRebuilder()
  self.uiObj_.layoutRebuilder:ForceRebuildLayoutImmediate()
end

function HelpSysFirstTabItem:SetEnable(filterFlag, filter)
  self.isVisible_ = filterFlag ~= E.HelpSysFilterType.None
  self.uiObj_.Ref.UIComp:SetVisible(self.isVisible_)
  local islast = true
  for i = #self.secondList_, 1, -1 do
    local isshow = self.secondList_[i]:CheckFilterShow(filter)
    self.secondList_[i]:SetEnable(isshow, islast)
    if isshow then
      islast = false
    end
  end
end

function HelpSysFirstTabItem:CheckFilterShow(filter)
  if filter == nil or filter == "" then
    return E.HelpSysFilterType.First
  end
  for i = 1, #self.secondList_ do
    if self.secondList_[i]:CheckFilterShow(filter) then
      return E.HelpSysFilterType.Second
    end
  end
  return E.HelpSysFilterType.None
end

function HelpSysFirstTabItem:SetOpen(value)
  if self.isOpen_ == value then
    self:layoutRebuilder()
    return
  end
  self.isOpen_ = value
  self.uiObj_.Ref:SetVisible(self.uiObj_.img_on, self.isOpen_)
  self.uiObj_.Ref:SetVisible(self.uiObj_.img_off, not self.isOpen_)
  self.uiObj_.Ref:SetVisible(self.uiObj_.layout_list, self.isOpen_)
  self:layoutRebuilder()
end

function HelpSysFirstTabItem:GetOpen()
  return self.isOpen_
end

function HelpSysFirstTabItem:SetSelect(isselect)
  self.uiObj_.Ref:SetVisible(self.uiObj_.img_on, isselect and not self.tabView_:GetSearchState())
  self.uiObj_.Ref:SetVisible(self.uiObj_.img_off, not isselect or self.tabView_:GetSearchState())
end

function HelpSysFirstTabItem:SetDefaultSelect(id)
  for i = 1, #self.secondList_ do
    local secondItem = self.secondList_[i]
    if secondItem:GetEnable() and (id == 0 or secondItem:GetId() == id) then
      secondItem:SetSelect(true)
      return secondItem
    end
  end
  return nil
end

function HelpSysFirstTabItem:IsContain(id)
  for i = 1, #self.secondList_ do
    local secondItem = self.secondList_[i]
    if secondItem:GetId() == id then
      return true
    end
  end
  return false
end

function HelpSysFirstTabItem:UnInit()
  for i = 1, #self.secondList_ do
    self.secondList_[i].UnInit()
  end
  self.secondList_ = nil
end

return HelpSysFirstTabItem
