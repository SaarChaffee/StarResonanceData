local ContainerWatcher = class("ContainerWatcher")
local setDirtyMt = function(t, current, last)
  local mt = {
    __index = {
      Get = function()
        return current
      end,
      GetLast = function()
        return last
      end,
      IsNew = function()
        return last == nil and current ~= nil
      end,
      IsDel = function()
        return last ~= nil and current == nil
      end
    }
  }
  setmetatable(t, mt)
end

function ContainerWatcher:ctor(container)
  self.container = container
  self.changedFuncs = {}
  self.dirtys = {}
  self.isDirty = false
end

function ContainerWatcher:RegWatcher(onChanged)
  if table.zcontains(self.changedFuncs, onChanged) then
    return
  end
  table.insert(self.changedFuncs, onChanged)
end

function ContainerWatcher:UnregWatcher(onChanged)
  table.zremoveByValue(self.changedFuncs, onChanged)
end

function ContainerWatcher:UpdateWatcher()
  if self.isDirty then
    for _, c in pairs(self.changedFuncs) do
      c(self.container, self.dirtys)
    end
    self.dirtys = {}
    self.isDirty = false
  end
end

function ContainerWatcher:ClearWatcher()
  self.changedFuncs = {}
end

function ContainerWatcher:MarkDirty(key, last)
  if not self.dirtys[key] then
    self.dirtys[key] = {}
  end
  setDirtyMt(self.dirtys[key], self.container[key], last)
  self.isDirty = true
end

function ContainerWatcher:MarkMapDirty(key, index, last)
  if not self.dirtys[key] then
    self.dirtys[key] = {}
  end
  if index then
    self.dirtys[key][index] = {}
    setDirtyMt(self.dirtys[key][index], self.container[key][index], last)
  end
  self.isDirty = true
end

return ContainerWatcher
