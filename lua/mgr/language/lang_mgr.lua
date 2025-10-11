local langFunc = Panda.Module.StringPoolManager.Lang
local LangMgr = class("LangMgr")

function LangMgr:ctor()
end

function LangMgr:Init()
  self.cache_ = {}
  self.cache_order_ = {}
  self.max_cache_size_ = 1000
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.ClearCache, self)
end

function LangMgr:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self:ClearCache()
end

function LangMgr:ClearCache()
  self.cache_ = {}
  self.cache_order_ = {}
end

function LangMgr:AddContent(key, content)
  if not self.cache_[key] then
    if #self.cache_order_ >= self.max_cache_size_ then
      local oldest_key = table.remove(self.cache_order_, 1)
      self.cache_[oldest_key] = nil
    end
    table.insert(self.cache_order_, key)
    self.cache_[key] = content
  end
end

function LangMgr:Lang(key, param)
  key = tostring(key)
  local content = self.cache_[key]
  if not content then
    content = langFunc(key)
    if not string.zisEmpty(content) then
      self:AddContent(key, content)
    else
      return "unknown key on Lang, key: " .. key
    end
  end
  return Z.Placeholder.Placeholder(content, param)
end

function LangMgr:IsContainKey(key)
  key = tostring(key)
  local content = self.cache_[key]
  content = content or langFunc(key)
  return not string.zisEmpty(content)
end

return LangMgr
