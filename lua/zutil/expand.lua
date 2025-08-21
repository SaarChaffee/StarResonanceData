function string.zsplit(str, delimiter)
  if str == nil or str == "" or delimiter == nil then
    return {}
  end
  local l_result = {}
  local l_lastIndex = 1
  repeat
    local l_start, l_end = string.find(str, delimiter, l_lastIndex)
    if not (l_start and l_end) then
      break
    end
    table.insert(l_result, string.sub(str, l_lastIndex, l_start - 1))
    l_lastIndex = l_end + 1
  until false
  if l_lastIndex <= #str then
    table.insert(l_result, string.sub(str, l_lastIndex, #str))
  end
  return l_result
end

function string.ztrim(str)
  if not str then
    return ""
  end
  return (string.gsub(str, "^[%s|%z]*(.-)[%s|%z]*$", "%1"))
end

function string.ztoCamelize(str)
  if string.zisEmpty(str) then
    return ""
  end
  local l_camelize = string.gsub(string.lower(str), "_[a-zA-z%d]", function(findstr)
    return string.upper(string.sub(findstr, 2, 2))
  end)
  return string.upper(string.sub(l_camelize, 1, 1)) .. string.sub(l_camelize, 2)
end

function string.zisLegal(str)
  local l_str = tostring(str)
  local l_isLegal
  local l_nLenInByte = #l_str
  local l_curByte = 0
  for i = 1, l_nLenInByte do
    l_curByte = string.byte(l_str, i)
    if 97 <= l_curByte and l_curByte <= 123 then
      l_isLegal = false
    elseif 65 <= l_curByte and l_curByte <= 90 then
      l_isLegal = false
    elseif 48 <= l_curByte and l_curByte <= 57 then
      l_isLegal = false
    elseif 127 < l_curByte then
      l_isLegal = false
    else
      l_isLegal = true
    end
    if l_isLegal then
      return true
    end
  end
  return l_isLegal
end

function math.zisBitSet(number, bitPosition)
  return number & 1 << bitPosition ~= 0
end

function math.zbitSet(number, bitPosition, value)
  if value then
    return number | 1 << bitPosition
  else
    return number & ~(1 << bitPosition)
  end
end

local zchsize = function(char)
  if not char then
    return 0
  elseif 240 < char then
    return 4
  elseif 225 < char then
    return 3
  elseif 192 < char then
    return 2
  else
    return 1
  end
end

function string.zhasEmoji(str)
  local l_len = string.len(str)
  for i = 1, l_len do
    local l_char = string.byte(str, i)
    local l_size = zchsize(l_char)
    i = i + l_size - 1
    if l_char ~= 0 and l_char ~= 9 and l_char ~= 10 and l_char ~= 13 and (not (32 <= l_char) or not (l_char <= 55295)) and (not (57344 <= l_char) or not (l_char <= 65533)) and (not (65536 <= l_char) or not (l_char <= 1114111)) then
      return true
    end
  end
  return false
end

function string.zlen(str)
  local l_str = tostring(str)
  local nLenInByte = #l_str
  local nWidth = 0
  for i = 1, nLenInByte do
    local curByte = string.byte(l_str, i)
    local byteCount = 0
    if 0 < curByte and curByte < 128 then
      byteCount = 1
    elseif 192 <= curByte and curByte < 224 then
      byteCount = 2
    elseif 224 <= curByte and curByte < 240 then
      byteCount = 3
    elseif 240 <= curByte and curByte < 248 then
      byteCount = 4
    end
    if 0 < byteCount then
      i = i + byteCount - 1
    end
    if byteCount == 1 then
      nWidth = nWidth + 1
    elseif 1 < byteCount then
      nWidth = nWidth + 2
    end
  end
  return nWidth
end

function string.zlenNormalize(str)
  local l_str = tostring(str)
  local nLenInByte = #l_str
  local nWidth = 0
  for i = 1, nLenInByte do
    local curByte = string.byte(l_str, i)
    local byteCount = 0
    if 0 < curByte and curByte < 128 then
      byteCount = 1
    elseif 192 <= curByte and curByte < 224 then
      byteCount = 2
    elseif 224 <= curByte and curByte < 240 then
      byteCount = 3
    elseif 240 <= curByte and curByte < 248 then
      byteCount = 4
    end
    if 1 <= byteCount then
      nWidth = nWidth + 1
    end
  end
  return nWidth
end

function string.zcut(str, count, suffix)
  local l_str = tostring(str)
  local l_count = tonumber(count)
  if l_count == nil then
    return l_str
  end
  local tCode = {}
  local tName = {}
  local nLenInByte = #l_str
  local nWidth = 0
  for i = 1, nLenInByte do
    local curByte = string.byte(l_str, i)
    local byteCount = 0
    if 0 < curByte and curByte < 128 then
      byteCount = 1
    elseif 192 <= curByte and curByte < 224 then
      byteCount = 2
    elseif 224 <= curByte and curByte < 240 then
      byteCount = 3
    elseif 240 <= curByte and curByte < 248 then
      byteCount = 4
    end
    local char
    if 0 < byteCount then
      char = string.sub(l_str, i, i + byteCount - 1)
      i = i + byteCount - 1
    end
    if byteCount == 1 then
      nWidth = nWidth + 1
      table.insert(tName, char)
      table.insert(tCode, 1)
    elseif 1 < byteCount then
      nWidth = nWidth + 2
      table.insert(tName, char)
      table.insert(tCode, 2)
    end
  end
  if l_count < nWidth then
    local _sN = ""
    local _len = 0
    for i = 1, #tName do
      _len = _len + tCode[i]
      if l_count < _len then
        break
      end
      _sN = _sN .. tName[i]
    end
    str = _sN
  end
  suffix = suffix or ""
  return str .. suffix
end

function string.zcutNormalize(str, count, suffix)
  local l_str = tostring(str)
  local l_count = tonumber(count)
  if l_count == nil then
    return l_str
  end
  local tCode = {}
  local tName = {}
  local nLenInByte = #l_str
  local nWidth = 0
  for i = 1, nLenInByte do
    local curByte = string.byte(l_str, i)
    local byteCount = 0
    if 0 < curByte and curByte < 128 then
      byteCount = 1
    elseif 192 <= curByte and curByte < 224 then
      byteCount = 2
    elseif 224 <= curByte and curByte < 240 then
      byteCount = 3
    elseif 240 <= curByte and curByte < 248 then
      byteCount = 4
    end
    local char
    if 0 < byteCount then
      char = string.sub(l_str, i, i + byteCount - 1)
      i = i + byteCount - 1
    end
    if 1 <= byteCount then
      nWidth = nWidth + 1
      table.insert(tName, char)
      table.insert(tCode, 1)
    end
  end
  if l_count < nWidth then
    local _sN = ""
    local _len = 0
    for i = 1, #tName do
      _len = _len + tCode[i]
      if l_count < _len then
        break
      end
      _sN = _sN .. tName[i]
    end
    str = _sN
  end
  suffix = suffix or ""
  return str .. suffix
end

function string.zisEmpty(str)
  local l_strType = type(str)
  if l_strType ~= "string" and l_strType ~= "number" then
    return true
  end
  if string.zlen(str) == 0 then
    return true
  end
  return false
end

function string.zconcat(...)
  local arg = {
    ...
  }
  return table.concat(arg, "")
end

function string.ztoChars(str)
  local l_result = {}
  local l_strType = type(str)
  if l_strType == "string" then
    local l_len = string.len(str)
    local l_index = 1
    while l_len >= l_index do
      local l_char = string.byte(str, l_index)
      local l_charSize = zchsize(l_char)
      local l_str = string.sub(str, l_index, l_index + l_charSize - 1)
      l_index = l_index + l_charSize
      table.insert(l_result, {charSize = l_charSize, char = l_str})
    end
  end
  return l_result
end

function string.zreplace(s, pattern, repl)
  local i, j = string.find(s, pattern, 1, true)
  if i and j then
    local ret = {}
    local start = 1
    while i and j do
      table.insert(ret, string.sub(s, start, i - 1))
      table.insert(ret, repl)
      start = j + 1
      i, j = string.find(s, pattern, start, true)
    end
    table.insert(ret, string.sub(s, start))
    return table.concat(ret)
  end
  return s
end

function table.zunique(tb)
  local l_ret = {}
  local l_valueSet = {}
  for k, v in pairs(tb) do
    if l_valueSet[v] == nil then
      l_valueSet[v] = true
      table.insert(l_ret, v)
    end
  end
  return l_ret
end

function table.zsize(tb)
  local l_size = 0
  for _, _ in pairs(tb) do
    l_size = l_size + 1
  end
  return l_size
end

table.zcount = table.zsize

function table.zsort(hashTb, sortFunc)
  local sortTab = {}
  for k, v in pairs(hashTb) do
    table.insert(sortTab, {key = k, value = v})
  end
  table.sort(sortTab, function(a, b)
    return sortFunc(a.value, b.value)
  end)
  return sortTab
end

function table.zclone(tb)
  local retTab = {}
  for k, v in pairs(tb) do
    retTab[k] = v
  end
  return retTab
end

function table.zdeepCopy(object)
  local searchTable = {}
  
  local function func(object)
    if type(object) ~= "table" then
      return object
    elseif searchTable[object] then
      return searchTable[object]
    end
    local newTable = {}
    searchTable[object] = newTable
    for k, v in pairs(object) do
      newTable[func(k)] = func(v)
    end
    return setmetatable(newTable, getmetatable(object))
  end
  
  return func(object)
end

function table.zcontains(tb, value)
  for k, v in pairs(tb) do
    if v == value then
      return true
    end
  end
  return false
end

function table.zcontainsKey(tb, key)
  for k, v in pairs(tb) do
    if k == key then
      return true
    end
  end
  return false
end

function table.zdeepCompare(tb1, tb2)
  if type(tb1) ~= type(tb2) then
    return false
  elseif type(tb1) == "table" then
    if #tb1 ~= #tb2 then
      return false
    else
      for key, _ in pairs(tb1) do
        if table.zcontainsKey(tb2, key) then
          if not table.zdeepCompare(tb1[key], tb2[key]) then
            return false
          end
        else
          return false
        end
      end
      return true
    end
  else
    return tb1 == tb2
  end
end

function table.zkvConcat(tb)
  local l_retMsg = ""
  for k, v in pairs(tb) do
    if type(v) == "table" then
      l_retMsg = l_retMsg .. "|" .. table.zconcat(v)
    elseif type(v) == "userdata" then
      local l_meta = getmetatable(v)
      l_meta = l_meta[".get"] or {}
      l_retMsg = l_retMsg .. "|" .. table.zconcat(l_meta)
    else
      l_retMsg = l_retMsg .. "|" .. tostring(k) .. ":" .. tostring(v)
    end
  end
  return l_retMsg
end

function table.zconcat(hashTb, delimitation)
  local l_tmpTable = table.zvalues(hashTb)
  return table.concat(l_tmpTable, delimitation)
end

function table.zkeys(hashTb)
  local keys = {}
  for k, v in pairs(hashTb) do
    keys[#keys + 1] = k
  end
  return keys
end

function table.zvalues(hashTb)
  local values = {}
  for k, v in pairs(hashTb) do
    values[#values + 1] = v
  end
  return values
end

function table.zremoveByValue(array, value, removeOne)
  local c, i, max = 0, 1, #array
  while i <= max do
    if array[i] == value then
      table.remove(array, i)
      c = c + 1
      i = i - 1
      max = max - 1
      if removeOne then
        break
      end
    end
    i = i + 1
  end
  return c
end

function table.zremoveOneByValue(array, value)
  table.zremoveByValue(array, value, true)
end

function table.zinsertRange(tb, values)
  if tb == nil then
    return
  end
  if values == nil then
    return
  end
  for i = 1, #values do
    table.insert(tb, values[i])
  end
end

function table.zinsertIndexRange(tb, values, index)
  if tb == nil then
    return
  end
  if values == nil then
    return
  end
  for i = 1, #values do
    table.insert(tb, index + i - 1, values[i])
  end
end

function table.zmerge(t1, t2)
  local ret = t1
  if not t1 or not t2 then
    return ret
  end
  for i, v in ipairs(t2) do
    table.insert(ret, v)
  end
  return t1
end

function table.zreverse(tb)
  local ret = {}
  local table_insert = table.insert
  for i = #tb, 1, -1 do
    table_insert(ret, tb[i])
  end
  return ret
end

local function _table2str(lua_table, raw_table, table_map, n, fold, indent)
  indent = indent or 1
  for k, v in pairs(lua_table) do
    if type(k) == "string" then
      k = string.format("%q", k)
    else
      k = tostring(k)
    end
    n = n + 1
    raw_table[n] = string.rep("    ", indent)
    n = n + 1
    raw_table[n] = "["
    n = n + 1
    raw_table[n] = k
    n = n + 1
    raw_table[n] = "]"
    n = n + 1
    raw_table[n] = " = "
    if type(v) == "table" then
      if fold and table_map[tostring(v)] then
        n = n + 1
        raw_table[n] = tostring(v)
        n = n + 1
        raw_table[n] = ",\n"
      else
        table_map[tostring(v)] = true
        n = n + 1
        raw_table[n] = "{\n"
        n = _table2str(v, raw_table, table_map, n, fold, indent + 1)
        n = n + 1
        raw_table[n] = string.rep("    ", indent)
        n = n + 1
        raw_table[n] = "},\n"
      end
    else
      if type(v) == "string" then
        v = string.format("%q", v)
      else
        v = tostring(v)
      end
      n = n + 1
      raw_table[n] = v
      n = n + 1
      raw_table[n] = ",\n"
    end
  end
  return n
end

function table.ztostring(tb, fold)
  if type(tb) == "table" then
    local raw_table = {}
    local table_map = {}
    table_map[tostring(tb)] = true
    local n = 0
    n = n + 1
    raw_table[n] = "{\n"
    n = _table2str(tb, raw_table, table_map, n, fold)
    n = n + 1
    raw_table[n] = "}"
    return table.concat(raw_table, "")
  else
    return tb
  end
end
