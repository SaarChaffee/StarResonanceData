local isRelease = false

function _formatStr(...)
  local l_arg = {
    ...
  }
  if not next(l_arg) then
    return "nil"
  elseif #l_arg == 1 then
    return string.ztrim(tostring(l_arg[1]))
  end
  local str = ""
  local n = select("#", ...)
  local first = tostring(select(1, ...))
  local isFormat = first and string.find(first, "%{%d+%}")
  if isFormat then
    local args = {}
    for i = 2, n do
      table.insert(args, string.ztrim(tostring(select(i, ...))))
    end
    str = string.format(string.gsub(first, "{%d+}", "%%s"), table.unpack(args))
  else
    local ret = {}
    for i = 1, n do
      table.insert(string.ztrim(tostring(select(i, ...))))
    end
    str = table.concat(ret, "\t")
  end
  return str
end

local zlog = ZUtil.ZDebug

function log(...)
  if isRelease then
    return
  end
  zlog.LogInfo("[lua] " .. _formatStr(...) .. [[

[traceback] ]] .. debug.traceback())
end

function logGreen(...)
  if isRelease then
    return
  end
  zlog.LogInfo("<color=green>[lua] " .. _formatStr(...) .. [[
</color>
[traceback] ]] .. debug.traceback())
end

function logYellow(...)
  if isRelease then
    return
  end
  zlog.LogInfo("<color=yellow>[lua] " .. _formatStr(...) .. [[
</color>
[traceback] ]] .. debug.traceback())
end

function logRed(...)
  if isRelease then
    return
  end
  zlog.LogInfo("<color=red>[lua] " .. _formatStr(...) .. [[
</color>
[traceback] ]] .. debug.traceback())
end

function logWarning(...)
  if isRelease then
    return
  end
  zlog.LogWarning("[lua] " .. _formatStr(...) .. [[

[traceback] ]] .. debug.traceback())
end

function logError(...)
  zlog.LogError("[lua] " .. _formatStr(...) .. [[

[traceback] ]] .. debug.traceback())
end

function pcallAndDebug(method, value, ...)
  local resultErrorCode, resultErrorInfo = pcall(method, value, ...)
  if resultErrorCode == false then
    logError(resultErrorInfo)
  end
end
