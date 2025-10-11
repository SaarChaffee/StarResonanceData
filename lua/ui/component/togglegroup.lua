local ToggleGroup = class("ToggleGroup")

function ToggleGroup:ctor(toggleGroup, toggleItem, data, view, bindName)
  self.toggleGroup_ = toggleGroup
  self.toggleItem_ = toggleItem
  self.data_ = data
  self.view_ = view
  self.bindName_ = bindName
  self.toggleComponents_ = {}
  self.toggleGroupComps_ = {}
  self.toggleGroup_:Init()
end

function ToggleGroup:Init(index, changeFunc, clickFunc)
  if self.data_ == nil or table.zcount(self.data_) == 0 then
    logError("ToggleGroup item is empty!")
    return
  end
  self.index_ = index or 1
  local count = table.zcount(self.data_)
  self.toggleGroup_:SetCount(count, function()
    for i = 1, count do
      local component = self.toggleGroup_:GetInstanceToggles(i - 1)
      if component then
        self.toggleComponents_[i] = self.toggleItem_.new()
        self.toggleComponents_[i]:Init(component, i, self.view_, self.bindName_)
        self.toggleComponents_[i]:Refresh(self.data_[i])
        component.group = self.toggleGroup_
        component:AddListener(function(isOn)
          self.toggleComponents_[i]:OnSelected(isOn)
          if isOn then
            self.index_ = i
            changeFunc(i)
          end
        end)
        if clickFunc then
          component:AddClickListener(clickFunc)
        end
        table.insert(self.toggleGroupComps_, component)
      end
    end
    if self.toggleGroupComps_[index].isOn then
      self.toggleComponents_[index]:OnSelected(true)
      self.index_ = index
      changeFunc(index)
    else
      self.toggleGroupComps_[index].isOn = true
    end
    self:OnInit()
  end, function(err)
  end)
end

function ToggleGroup:GetSelectedIndex()
  return self.index_ or 1
end

function ToggleGroup:SelectedByIndex(index)
  if self.toggleGroupComps_[index] then
    self.toggleGroupComps_[index].isOn = true
  end
end

function ToggleGroup:OnInit()
end

function ToggleGroup:UnInit()
  if self.data_ == nil or table.zcount(self.data_) == 0 then
    return
  end
  for index, value in ipairs(self.toggleComponents_) do
    value:UnInit()
  end
  self.toggleGroup_:UnInit()
end

return ToggleGroup
