local ret = {}
local template = require("zutil.template")

function ret.ParamTempAttr(id, value)
  if id == nil then
    logError("\228\184\180\230\151\182\229\177\158\230\128\167Id\228\184\141\232\131\189\228\184\186\231\169\186")
    return ""
  end
  if value == nil then
    logError("\228\184\180\230\151\182\229\177\158\230\128\167\229\128\188\228\184\141\232\131\189\228\184\186\231\169\186")
    return ""
  end
  local tempAttrTableMgr = Z.TableMgr.GetTable("TempAttrTableMgr")
  local tempAttrTableRow = tempAttrTableMgr.GetRow(id)
  if not tempAttrTableRow then
    return ""
  end
  local des = tempAttrTableRow.AttrDesc
  if des == nil then
    return ""
  end
  local param = {
    tempAttr = {
      mn = function()
        return Z.NumTools.MakeNormalFormat(value)
      end,
      un = function()
        return Z.NumTools.DefaultFormat(value)
      end,
      mp = function()
        return Z.NumTools.MarkAndPercentFormat(value)
      end,
      up = function()
        return Z.NumTools.UnMarkAndPercentFormat(value)
      end,
      mt = function()
        return Z.NumTools.MarkAndSecFormat(value)
      end,
      ut = function()
        return Z.NumTools.UnMarkAndSecFormat(value)
      end
    }
  }
  local str = Z.Placeholder.Placeholder(des, param)
  return str
end

return ret
