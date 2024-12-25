local ret = {}

function ret.makeReadOnlyTable(originalTable, tempTable, recursive)
  if originalTable == nil then
    return nil
  end
  tempTable = tempTable or {}
  local readOnlyTable = tempTable[originalTable]
  if readOnlyTable then
    return readOnlyTable
  end
  readOnlyTable = {}
  tempTable[originalTable] = {}
  local mt = {
    __index = originalTable,
    __newindex = function(tbl, k, v)
      error("Table is read-only!")
    end,
    __pairs = function(tbl)
      return pairs(originalTable)
    end,
    __len = function(tbl)
      return #originalTable
    end
  }
  if recursive then
    for k, v in pairs(originalTable) do
      if type(v) == "table" then
        readOnlyTable[k] = ret.makeReadOnlyTable(v, tempTable)
      end
    end
  end
  setmetatable(readOnlyTable, mt)
  return readOnlyTable
end

function ret.Read_only(inputTable, recursive)
  return ret.makeReadOnlyTable(inputTable, nil, recursive)
end

return ret
