local HelpSysSecondTabItem = class("HelpSysSecondTabItem")

function HelpSysSecondTabItem:ctor(tabView_, uiView, parent, secondTpl, parentItem)
  self.uiObj_ = nil
  self.tabView_ = tabView_
  self.parent_ = parent
  self.isVisible_ = true
  self.uiView_ = uiView
  self.secondTpl_ = secondTpl
  self.secondData_ = nil
  self.parentItem_ = parentItem
  self.isSelect_ = false
end

function HelpSysSecondTabItem:Init(data, firstIndex, secondIndex, isLast)
  self.secondData_ = data
  self.firstIndex_ = firstIndex
  self.secondIndex_ = secondIndex
  self.uiObj_ = self.uiView_:AsyncLoadUiUnit(self.secondTpl_, "second" .. firstIndex .. "_" .. secondIndex, self.parent_)
  self.uiObj_.lab_name_on.text = data.Title
  self.uiObj_.lab_name_off.text = data.Title
  self:SetEnable(false, isLast)
  self:SetSelect(false)
  self:addClick()
end

function HelpSysSecondTabItem:addClick()
  self.uiView_:AddAsyncClick(self.uiObj_.btn_click, function()
    local lastsecond = self.tabView_:GetLastSecond()
    if self == lastsecond and lastsecond.isSelect_ then
      return
    end
    if lastsecond then
      lastsecond:SetSelect(false)
    end
    self:SetSelect(true)
    self.tabView_:SetLastSecond(self)
  end)
end

function HelpSysSecondTabItem:SetEnable(value, isLast)
  self.isVisible_ = value
  self.uiObj_.Ref.UIComp:SetVisible(self.isVisible_)
  self:SetSelect(false)
end

function HelpSysSecondTabItem:GetEnable()
  return self.isVisible_
end

function HelpSysSecondTabItem:SetSelect(isselect)
  self.isSelect_ = isselect
  self.uiObj_.Ref:SetVisible(self.uiObj_.img_on, isselect)
  self.uiObj_.Ref:SetVisible(self.uiObj_.img_off, not isselect)
  self.parentItem_:SetSelect(isselect)
  if isselect then
    self.tabView_:Callback(self.secondData_)
  end
end

function HelpSysSecondTabItem:CheckFilterShow(filter)
  if filter == nil or filter == "" then
    return true
  end
  if string.find(self.secondData_.Title, filter) then
    return true
  end
  return false
end

function HelpSysSecondTabItem:GetId()
  return self.secondData_.Id
end

function HelpSysSecondTabItem:GetParentItem()
  return self.parentItem_
end

function HelpSysSecondTabItem:UnInit()
end

return HelpSysSecondTabItem
