function class(classname, ...)
  local cls = {__cname = classname}
  
  local supers = {
    ...
  }
  for _, super in ipairs(supers) do
    local superType = type(super)
    assert(superType == "nil" or superType == "table" or superType == "function", string.format("class() - create class \"%s\" with invalid super class type \"%s\"", classname, superType))
    if superType == "function" then
      assert(cls.__create == nil, string.format("class() - create class \"%s\" with more than one creating function", classname))
      cls.__create = super
    elseif superType == "table" then
      if super[".isclass"] then
        assert(cls.__create == nil, string.format("class() - create class \"%s\" with more than one creating function or native class", classname))
        
        function cls.__create()
          return super:create()
        end
      else
        cls.__supers = cls.__supers or {}
        cls.__supers[#cls.__supers + 1] = super
        if not cls.super then
          cls.super = super
        end
      end
    else
      error(string.format("class() - create class \"%s\" with invalid super type", classname), 0)
    end
  end
  cls.__index = cls
  if not cls.__supers or #cls.__supers == 1 then
    setmetatable(cls, {
      __index = cls.super
    })
  else
    setmetatable(cls, {
      __index = function(_, key)
        local supers = cls.__supers
        for i = 1, #supers do
          local super = supers[i]
          if super[key] then
            return super[key]
          end
        end
      end
    })
  end
  if not cls.ctor then
    function cls.ctor()
    end
  end
  
  function cls.new(...)
    local instance
    if cls.__create then
      instance = cls.__create(...)
    else
      instance = {}
    end
    setmetatableindex(instance, cls)
    instance.class = cls
    instance:ctor(...)
    return instance
  end
  
  function cls.create(_, ...)
    return cls.new(...)
  end
  
  return cls
end

local setmetatableindex_

function setmetatableindex_(t, index)
  if type(t) == "userdata" then
    local peer = tolua.getpeer(t)
    if not peer then
      peer = {}
      tolua.setpeer(t, peer)
    end
    setmetatableindex_(peer, index)
  else
    local mt = getmetatable(t)
    mt = mt or {}
    if not mt.__index then
      mt.__index = index
      setmetatable(t, mt)
    elseif mt.__index ~= index then
      setmetatableindex_(mt, index)
    end
  end
end

setmetatableindex = setmetatableindex_
