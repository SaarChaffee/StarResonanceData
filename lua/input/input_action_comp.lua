local InputActionComp = class("InputActionComp")
local InputActionItem = require("input/input_action_item")

function InputActionComp:ctor()
end

function InputActionComp:Init()
  self.actionItems_ = {}
  self:InitActionItems()
end

function InputActionComp:UnInit()
  for k, v in pairs(self.actionItems_) do
    v:UnInit()
  end
  self.actionItems_ = nil
end

function InputActionComp:InitActionItems()
  local keyboardTableMgr = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  local keyboardRows = keyboardTableMgr.GetDatas()
  for _, v in pairs(keyboardRows) do
    local actionItem = InputActionItem.new()
    actionItem:Init(v)
    self.actionItems_[v.Id] = actionItem
  end
end

function InputActionComp:EnableAll(enable)
  for k, v in pairs(self.actionItems_) do
    v:Enable(enable)
  end
end

function InputActionComp:EnableByKeyId(keyId, enable)
  if keyId == nil then
    return
  end
  local actionItem = self.actionItems_[keyId]
  if actionItem then
    actionItem:Enable(enable)
  end
end

function InputActionComp:SetActionCallback(id, func)
  if id == nil then
    return
  end
  local actionItem = self.actionItems_[id]
  if actionItem then
    actionItem:SetActionCallback(func)
  end
end

return InputActionComp
