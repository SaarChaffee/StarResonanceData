local ToggleItem = class("ToggleItem")

function ToggleItem:ctor()
end

function ToggleItem:Init(component, index, view, bindName)
  self.component = component
  self.parent = self.component.transform.parent
  self.index = index
  self.view = view
  self.uiBinder = UIBinderToLua(self.parent.gameObject)
  self:OnInit()
end

function ToggleItem:OnInit()
end

function ToggleItem:UnInit()
end

function ToggleItem:OnSelected(isOn)
end

return ToggleItem
