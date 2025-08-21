local RedDotTest = {}
local RedLogPath = "D:\\RedDotLog"

function RedDotTest.make_prefix(buffer, depth, is_last)
  local line = {}
  for i = 1, depth do
    if i == depth then
      table.insert(line, is_last and "\226\148\148\226\148\128\226\148\128 " or "\226\148\156\226\148\128\226\148\128 ")
    else
      table.insert(line, "\226\148\130   ")
    end
  end
  table.insert(buffer, table.concat(line))
end

function RedDotTest.build_tree(buffer, node_id, visited, depth, is_last)
  if visited[node_id] then
    RedDotTest.make_prefix(buffer, depth, is_last)
    table.insert(buffer, "\226\154\160\239\184\143 [Circular Reference] Node:" .. node_id .. "\n")
    return
  end
  visited[node_id] = true
  local node = Z.RedPointMgr.CheckNodeIsNil(node_id)
  if not node then
    RedDotTest.make_prefix(buffer, depth, is_last)
    table.insert(buffer, "\226\157\140 [Missing Node] ID:" .. node_id .. "\n")
    return
  end
  local state_icon = node.State and "\226\151\143" or "\226\151\139"
  local info = string.format("%s %s (ID:%s    State:%s    Num:%s)\n", state_icon, node.RedDotStyleUIItems and "\240\159\159\165" or "\226\172\156", tostring(node_id), tostring(node.State or false), tostring(node.Num or 0):gsub("%.0+$", ""))
  RedDotTest.make_prefix(buffer, depth, is_last)
  table.insert(buffer, info)
  if node.ChildrenIds and 0 < #node.ChildrenIds then
    local child_count = #node.ChildrenIds
    for i, child_id in ipairs(node.ChildrenIds) do
      local new_visited = {}
      for k, v in pairs(visited) do
        new_visited[k] = v
      end
      local is_last_child = i == child_count
      RedDotTest.build_tree(buffer, child_id, new_visited, depth + 1, is_last_child)
    end
  end
end

function RedDotTest.PrintRedDotTree()
  if not Z.RedPointMgr.redPointData or not next(Z.RedPointMgr.redPointData) then
    return
  end
  local buffer = {
    "\n\240\159\148\180 Red Dot System Hierarchy:\n"
  }
  local roots = {}
  for id, node in pairs(Z.RedPointMgr.redPointData) do
    if node.ParentIds == nil or table.zcount(node.ParentIds) == 0 then
      table.insert(roots, id)
    end
  end
  logError("Roots:" .. table.zcount(roots) .. "   Nodes:" .. table.zcount(Z.RedPointMgr.redPointData))
  for i, root_id in ipairs(roots) do
    RedDotTest.build_tree(buffer, root_id, {}, 0, i == #roots)
  end
  local content = table.concat(buffer)
  logGreen(content)
  local path = RedLogPath .. "_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
  local file, err = io.open(path, "w")
  if file then
    file:write(content)
    file:close()
    logGreen("\230\150\135\228\187\182\228\191\157\229\173\152\230\136\144\229\138\159: " .. path)
  else
    logError("\230\150\135\228\187\182\228\191\157\229\173\152\229\164\177\232\180\165: " .. tostring(err))
  end
end

return RedDotTest
