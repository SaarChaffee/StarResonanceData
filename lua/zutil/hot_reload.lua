DeclareGlobal("HU", {})
if _VERSION == "Lua 5.3" then
  function HU.getfenv(f)
    if type(f) == "function" then
      local name, value = debug.getupvalue(f, 1)
      
      if name == "_ENV" then
        return value
      else
        return _ENV
      end
    end
  end
  
  function HU.setfenv(f, Env)
    if type(f) == "function" then
      local name, value = debug.getupvalue(f, 1)
      if name == "_ENV" then
        debug.setupvalue(f, 1, Env)
      end
    end
  end
  
  debug = debug or {}
  debug.setfenv = HU.setfenv
  
  function HU.loadstring(...)
    return load(...)
  end
else
  HU.getfenv = getfenv
  HU.setfenv = setfenv
  HU.loadstring = loadstring
end
local tango, tangoCo

function HU.FailNotify(...)
  if HU.NotifyFunc then
    HU.NotifyFunc(...)
  end
end

function HU.DebugNofity(...)
  if HU.DebugNofityFunc then
    HU.DebugNofityFunc(...)
  end
end

local GetWorkingDir = function()
  if HU.WorkingDir == nil then
    local p = io.popen("echo %cd%")
    if p then
      HU.WorkingDir = p:read("*l") .. "\\"
      p:close()
    end
  end
  return HU.WorkingDir
end
local Normalize = function(path)
  path = path:gsub("/", "\\")
  if path:find(":") == nil then
    path = GetWorkingDir() .. path
  end
  local pathLen = #path
  if path:sub(pathLen, pathLen) == "\\" then
    path = path:sub(1, pathLen - 1)
  end
  local parts = {}
  for w in path:gmatch("[^\\]+") do
    if w == ".." and #parts ~= 0 then
      table.remove(parts)
    elseif w ~= "." then
      table.insert(parts, w)
    end
  end
  return table.concat(parts, "\\")
end

function HU.InitFileMap(rootPath)
  for _, rootPath in pairs(rootPath) do
    rootPath = Normalize(rootPath)
    local file = io.popen("dir /S/B /A:A \"" .. rootPath .. "\"")
    io.input(file)
    for line in io.lines() do
      local FilevalueName = string.match(line, "Lua\\(.*)%.lua$")
      if FilevalueName ~= nil then
        if HU.FileMap[FilevalueName] == nil then
          HU.FileMap[FilevalueName] = {}
        end
        local l_line = line
        local sysPath = string.sub(l_line, #rootPath + 2, #l_line - 4)
        local luapath = string.gsub(sysPath, "\\", ".")
        HU.luaPathTosysPath[luapath] = sysPath
        table.insert(HU.FileMap[FilevalueName], {sysPath = l_line, luaPath = luapath})
      end
    end
    file:close()
  end
end

function HU.InitFakeTable()
  local meta = {}
  HU.Meta = meta
  local FakeT = function()
    return setmetatable({}, meta)
  end
  local EmptyFunc = function()
  end
  local pairs = function()
    return EmptyFunc
  end
  local setmetatable = function(t, metaT)
    HU.MetaMap[t] = metaT
    return t
  end
  local getmetatable = function(t, metaT)
    return setmetatable({}, t)
  end
  local require = function(luaPath)
    if not HU.RequireMap[luaPath] then
      local FakeTable = FakeT()
      HU.RequireMap[luaPath] = FakeTable
    end
    return HU.RequireMap[luaPath]
  end
  local module = function(k, v)
    local result = {}
    _G.string.gsub(k, "[^.]+", function(w)
      _G.table.insert(result, w)
    end)
    local pt = HU.FakeENV
    for i, v in ipairs(result) do
      pt = pt[v]
    end
    HU.setfenv(2, pt)
  end
  
  function meta.__index(t, k)
    if k == "setmetatable" then
      return setmetatable
    elseif k == "pairs" or k == "ipairs" then
      return pairs
    elseif k == "next" then
      return EmptyFunc
    elseif k == "require" then
      return require
    elseif k == "module" then
      return module
    else
      local FakeTable = FakeT()
      rawset(t, k, FakeTable)
      return FakeTable
    end
  end
  
  function meta.__newindex(t, k, v)
    rawset(t, k, v)
  end
  
  function meta.__call()
    return FakeT(), FakeT(), FakeT()
  end
  
  function meta.__add()
    return meta.__call()
  end
  
  function meta.__sub()
    return meta.__call()
  end
  
  function meta.__mul()
    return meta.__call()
  end
  
  function meta.__div()
    return meta.__call()
  end
  
  function meta.__mod()
    return meta.__call()
  end
  
  function meta.__pow()
    return meta.__call()
  end
  
  function meta.__unm()
    return meta.__call()
  end
  
  function meta.__concat()
    return meta.__call()
  end
  
  function meta.__eq()
    return meta.__call()
  end
  
  function meta.__lt()
    return meta.__call()
  end
  
  function meta.__le()
    return meta.__call()
  end
  
  function meta.__len()
    return meta.__call()
  end
  
  return FakeT
end

function HU.InitProtection()
  HU.Protection = {}
  HU.Protection[setmetatable] = true
  HU.Protection[pairs] = true
  HU.Protection[ipairs] = true
  HU.Protection[next] = true
  HU.Protection[require] = true
  HU.Protection[math] = true
  HU.Protection[string] = true
  HU.Protection[_ENV] = true
  HU.Protection[table] = true
  HU.Protection[HU] = true
  HU.Protection[HU.Meta] = true
  HU.Protection[HU.ResetENV] = true
  HU.Protection[ZUtil] = true
  HU.Protection[UnityEngine] = true
end

function HU.ErrorHandle(e)
  HU.FailNotify("HotUpdate Error\n" .. tostring(e))
  HU.ErrorHappen = true
end

function HU.BuildnewCode(sysPath, luaPath, newCode)
  if not newCode then
    io.input(sysPath)
    newCode = io.read("*all")
  end
  if HU.ALL and HU.OldCode[luaPath] == nil then
    HU.OldCode[luaPath] = newCode
    return
  end
  if HU.OldCode[luaPath] == newCode then
    io.input():close()
    return false
  end
  local chunkvalueName = luaPath
  local chunk = "--[[" .. luaPath .. "]] "
  chunk = chunk .. newCode
  local newFunc = HU.loadstring(chunk, chunkvalueName)
  if not newFunc then
    HU.FailNotify(luaPath .. " has syntax error.")
    collectgarbage("collect")
    return false
  else
    HU.FakeENV = HU.FakeT()
    HU.MetaMap = {}
    HU.RequireMap = {}
    HU.setfenv(newFunc, HU.FakeENV)
    local newObject
    HU.ErrorHappen = false
    xpcall(function()
      newObject = newFunc()
      if not newObject then
        HU.FailNotify("bulid newcode fail, because load chunk return nil luaPath = {0}", luaPath)
      end
    end, HU.ErrorHandle)
    if not HU.ErrorHappen then
      HU.OldCode[luaPath] = newCode
      return true, newObject
    else
      collectgarbage("collect")
      return false
    end
  end
end

function HU.Travel_G()
  local visited = {}
  visited[HU] = true
  
  local function f(t)
    if type(t) ~= "function" and type(t) ~= "table" or visited[t] then
      return
    end
    if not rawequal(t, _G) and HU.Protection[t] then
      return
    end
    visited[t] = true
    if type(t) == "function" then
      for i = 1, math.huge do
        local name, value = debug.getupvalue(t, i)
        if not name then
          break
        end
        if type(value) == "function" then
          for _, funcs in ipairs(HU.ChangedFuncList) do
            if value == funcs[1] then
              debug.setupvalue(t, i, funcs[2])
            end
          end
        end
        f(value)
      end
    elseif type(t) == "table" then
      f(debug.getmetatable(t))
      local changeIndexs = {}
      for k, v in pairs(t) do
        f(k)
        f(v)
        if type(v) == "function" then
          for _, funcs in ipairs(HU.ChangedFuncList) do
            if v == funcs[1] then
              t[k] = funcs[2]
            end
          end
        end
        if type(k) == "function" then
          for index, funcs in ipairs(HU.ChangedFuncList) do
            if k == funcs[1] then
              changeIndexs[#changeIndexs + 1] = index
            end
          end
        end
      end
      for _, index in ipairs(changeIndexs) do
        local funcs = HU.ChangedFuncList[index]
        t[funcs[2]] = t[funcs[1]]
        t[funcs[1]] = nil
      end
    end
  end
  
  f(_G)
  local registryTable = debug.getregistry()
  f(registryTable)
end

function HU.ReplaceOld(oldObject, newObject, luaPath, callFrom, deepth)
  if type(oldObject) == type(newObject) then
    if type(newObject) == "table" then
      HU.UpdateAllFunction(oldObject, newObject, luaPath, callFrom, "")
    elseif type(newObject) == "function" then
      HU.UpdateOneFunction(oldObject, newObject, luaPath, nil, callFrom, "")
    end
  end
end

function HU.HotUpdateCode(luaPath, sysPath, newCode)
  local oldObject = package.loaded[luaPath]
  if type(oldObject) == "boolean" then
    return
  end
  if oldObject then
    HU.VisitedSig = {}
    HU.ChangedFuncList = {}
    local success, newObject = HU.BuildnewCode(sysPath, luaPath, newCode)
    if success then
      HU.ReplaceOld(oldObject, newObject, luaPath, "Main", "")
      for luaPath, newObject in pairs(HU.RequireMap) do
        local oldObject = package.loaded[luaPath]
        HU.ReplaceOld(oldObject, newObject, luaPath, "Main_require", "")
      end
      setmetatable(HU.FakeENV, nil)
      HU.UpdateAllFunction(HU.ENV, HU.FakeENV, " ENV ", "Main", "")
      if #HU.ChangedFuncList > 0 then
        HU.Travel_G()
      end
      collectgarbage("collect")
    end
  elseif sysPath and HU.OldCode[sysPath] == nil then
    io.input(sysPath)
    HU.OldCode[sysPath] = io.read("*all")
    io.input():close()
  end
end

function HU.ResetENV(object, name, callFrom, deepth)
  local visited = {}
  
  local function f(object, name)
    if not object or visited[object] then
      return
    end
    visited[object] = true
    if type(object) == "function" then
      HU.DebugNofity(deepth .. "HU.ResetENV:function:{0} from:{1}", name, callFrom)
      xpcall(function()
        HU.setfenv(object, HU.ENV)
      end, HU.FailNotify)
    elseif type(object) == "table" then
      HU.DebugNofity(deepth .. "HU.ResetENV:table:{0} from:{1}", name, callFrom)
      for k, v in pairs(object) do
        f(k, tostring(k) .. "__key", " HU.ResetENV ", deepth .. "    ")
        f(v, tostring(k), " HU.ResetENV ", deepth .. "    ")
      end
    end
  end
  
  f(object, name)
end

function HU.UpdateUpvalue(oldFunc, newFunc, valueName, callFrom, deepth)
  HU.DebugNofity(deepth .. "HU.UpdateUpvalue:{0} from:{1}", valueName, callFrom)
  local oldUpvalueMap = {}
  local oldExistvalueName = {}
  for i = 1, math.huge do
    local name, value = debug.getupvalue(oldFunc, i)
    if not name then
      break
    end
    oldUpvalueMap[name] = value
    oldExistvalueName[name] = true
  end
  for i = 1, math.huge do
    local name, value = debug.getupvalue(newFunc, i)
    if not name then
      break
    end
    if oldExistvalueName[name] then
      local oldValue = oldUpvalueMap[name]
      if type(oldValue) ~= type(value) then
        debug.setupvalue(newFunc, i, oldValue)
      elseif type(oldValue) == "function" then
        HU.UpdateOneFunction(oldValue, value, name, nil, "HU.UpdateUpvalue", deepth .. "    ")
      elseif type(oldValue) == "table" then
        HU.UpdateAllFunction(oldValue, value, name, "HU.UpdateUpvalue", deepth .. "    ")
        debug.setupvalue(newFunc, i, oldValue)
      else
        debug.setupvalue(newFunc, i, oldValue)
      end
    else
      HU.ResetENV(newFunc, name, "HU.UpdateUpvalue", deepth .. "    ")
    end
  end
end

function HU.UpdateOneFunction(oldObject, newObject, funcName, oldTable, callFrom, deepth)
  if HU.Protection[oldObject] or HU.Protection[newObject] then
    return
  end
  local signature = tostring(oldObject) .. tostring(newObject)
  if HU.VisitedSig[signature] then
    HU.DebugNofity("HU.VisitedSig[signature]")
    return
  end
  HU.VisitedSig[signature] = true
  HU.DebugNofity(deepth .. "HU.UpdateOneFunction {0} from:{1}", funcName, callFrom)
  if pcall(debug.setfenv, newObject, HU.getfenv(oldObject)) then
    HU.UpdateUpvalue(oldObject, newObject, funcName, "HU.UpdateOneFunction", deepth .. "    ")
    HU.ChangedFuncList[#HU.ChangedFuncList + 1] = {
      oldObject,
      newObject,
      funcName,
      oldTable
    }
  end
end

function HU.GetTableSignature(t)
  local metaTable
  if t == _G then
    return tostring(t)
  end
  if t and t[".name"] then
    return tostring(t[".name"])
  elseif t and t.GetClassType then
    metaTable = t.GetClassType()
    return tostring(metaTable)
  elseif t and t.__tostring and t.__cname then
    return tostring(t.__cname or getmetatable(t))
  else
    return tostring(t)
  end
end

function HU.UpdateAllFunction(oldTable, newTable, tableName, callFrom, deepth)
  if HU.Protection[oldTable] or HU.Protection[newTable] then
    return
  end
  local signature = HU.GetTableSignature(oldTable) .. HU.GetTableSignature(newTable)
  if HU.VisitedSig[signature] then
    return
  end
  HU.VisitedSig[signature] = true
  HU.DebugNofity(deepth .. "[HU.UpdateAllFunction]tableName:{0}, from:{1}", tableName, callFrom)
  for k, element in pairs(newTable) do
    local oldelement = oldTable[k]
    if type(element) == type(oldelement) then
      if type(element) == "function" then
        HU.UpdateOneFunction(oldelement, element, k, oldTable, "HU.UpdateAllFunction", deepth .. "    ")
      elseif type(element) == "table" and HU.UpdatedTables[element] == nil then
        HU.UpdatedTables[element] = true
        HU.UpdateAllFunction(oldelement, element, k, "HU.UpdateAllFunction", deepth .. "    ")
      end
    elseif oldelement == nil and type(element) == "function" and pcall(HU.setfenv, element, HU.ENV) then
      oldTable[k] = element
    end
  end
  local oldMeta = debug.getmetatable(oldTable)
  local newMeta = HU.MetaMap[newTable]
  if type(oldMeta) == "table" and type(newMeta) == "table" then
    HU.UpdateAllFunction(oldMeta, newMeta, tableName .. "'s Meta", "HU.UpdateAllFunction", deepth .. "    ")
  end
end

function HU.Init(_, rootPath)
  HU.FileMap = {}
  HU.UpdatedTables = {}
  HU.NotifyFunc = logError
  HU.DebugNofityFunc = logGreen
  HU.OldCode = {}
  HU.ChangedFuncList = {}
  HU.VisitedSig = {}
  HU.FakeENV = nil
  HU.ENV = ENV or _G
  HU.luaPathTosysPath = {}
  HU.FakeT = HU.InitFakeTable()
  HU.InitProtection()
  HU.ALL = false
  local pathTbl = assert(load("return {\"" .. rootPath .. "\"}")())
  HU.InitFileMap(pathTbl)
end

function HU.DoHotReload(luaPath)
  local filePath = string.gsub(luaPath, "%.", "\\")
  if not HU.FileMap[filePath] then
    logError("\228\184\141\229\173\152\229\156\168luaPath = {0}, \232\175\183\231\161\174\229\174\154require\229\144\141\231\167\176", luaPath)
    return
  end
  HU.UpdatedTables = {}
  HU.HotUpdateCode(luaPath, HU.FileMap[filePath][1].sysPath)
end
