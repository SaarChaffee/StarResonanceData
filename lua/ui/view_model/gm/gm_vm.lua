local openGmView = function()
  if Z.IsBlockGM then
    return
  end
  Z.UIMgr:OpenView("gm")
end
local closeGmView = function()
  Z.UIMgr:CloseView("gm")
  Z.InputMgr:EnableKeyBoard(true)
end
local openGmMainView = function()
  Z.UIMgr:OpenView("gm_main")
end
local closeGmMainView = function()
  Z.UIMgr:CloseView("gm_main")
end
local getCurCmdInfo = function(param)
  local gmTbl = Z.TableMgr.GetTable("GMTableMgr").GetDatas()
  for id, info in pairs(gmTbl) do
    local str = info.Command
    if str == param[1] then
      return info
    end
  end
  return nil
end
local pos_ = {
  "PosX",
  "PosY",
  "PosZ"
}
local getCurParameter = function(curCmdInfo, param)
  local pTbl = {}
  local optionalArguments = {}
  local paramInfo = {}
  local HasVal = false
  local checkId = 1
  for k, v in pairs(curCmdInfo.ParameterCheck) do
    table.insert(paramInfo, v)
  end
  if #param > #paramInfo then
    return string.format("\229\189\147\229\137\141\230\140\135\228\187\164\229\143\130\230\149\176\228\184\141\229\173\152\229\156\168\239\188\140\232\175\183\230\163\128\230\159\165\229\144\142\233\135\141\230\150\176\232\190\147\229\135\186")
  end
  for k, v in pairs(curCmdInfo.OptionalParameter) do
    optionalArguments = v
  end
  for k, v in pairs(curCmdInfo.ParameterOrContent) do
    if v then
      for strId, val in ipairs(v) do
        checkId = checkId + 1
      end
      if v[1] == "pos" then
        local p = {}
        for i = 1, #param do
          local pa = tonumber(param[i])
          if not pa then
            return string.format("%s\228\184\141\230\152\175\228\184\128\228\184\170\229\144\136\230\179\149\231\154\132%s\229\128\188", pos_[i], paramInfo[i])
          end
          table.insert(p, pa)
        end
        pTbl[v[1]] = p
      else
        for i = 1, #param do
          if param[i] then
            if paramInfo[i] == "number" then
              param[i] = tonumber(param[i])
            end
            if not param[i] then
              local pa = v[i] and v[i] or string.zsplit(optionalArguments[i], " ")[1]
              return string.format("%s\228\184\141\230\152\175\228\184\128\228\184\170\229\144\136\230\179\149\231\154\132%s\229\128\188", pa, paramInfo[i])
            end
            if v[i] then
              pTbl[v[i]] = param[i]
            end
          end
        end
      end
    end
  end
  for k, info in ipairs(optionalArguments) do
    local data = string.zsplit(info, " ")
    if paramInfo[checkId] == "number" then
      pTbl[data[1]] = param[checkId] and param[checkId] or tonumber(data[2])
      checkId = checkId + 1
    end
    HasVal = true
  end
  if (#param < #paramInfo or #param > #paramInfo) and HasVal == false then
    return nil
  end
  local Count = 0
  for k, v in pairs(pTbl) do
    Count = Count + 1
  end
  if HasVal and Count > #paramInfo then
    return nil
  end
  return pTbl
end
local setHistoryInfoToLocal = function()
  local data = Z.DataMgr.Get("gm_data")
  data:SetHistoryName(data.NowInputContent)
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "GM_HISTORY", data.HistoryNames)
end
local asyncSendCmd = function(curCmdInfo, pTbl, cancelToken, targetCharId)
  if Z.IsBlockGM then
    return
  end
  if curCmdInfo.Command == "moveSelf" then
    pTbl = string.gsub(pTbl, ",", "=")
  end
  local cmd = {
    command = curCmdInfo.Command,
    targetCharId = targetCharId == "" and 0 or targetCharId,
    parsingType = type(pTbl) == "table" and 0 or 1,
    parameter = pTbl
  }
  setHistoryInfoToLocal()
  local gmProxy = require("zproxy.world_proxy")
  local ret = gmProxy.GMCommand(cmd, cancelToken)
  if ret.success then
    local info = ""
    if ret.failReason then
      info = ret.failReason
    end
    Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd success" .. info)
  else
    Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd fail " .. ret.failReason)
  end
end
local executeGroupCmd = function(curCmdInfo, cancelSource, targetId)
  local pTbl = {}
  local cmdTbl = {}
  for k, v in ipairs(curCmdInfo.ParameterOrContent) do
    table.insert(cmdTbl, v)
  end
  for i = 1, #cmdTbl do
    local gmTbl = string.zsplit(cmdTbl[i], " ")
    local param = {}
    local p = string.zsplit(gmTbl[2], ",")
    for k, v in ipairs(p) do
      table.insert(param, v)
    end
    local curCmdData = getCurCmdInfo(gmTbl)
    local pTbl = ""
    if table.zcount(param) > 0 then
      local str = table.concat(param, ",")
      pTbl = str
    end
    Z.LocalGmMgr:CallLocalGM(cmdTbl[i], table.unpack(param))
    asyncSendCmd(curCmdData, pTbl, cancelSource:CreateToken(), targetId)
  end
end
local refreshDesLoop = function(loopscrollrect, isAddDindex)
  local data = Z.DataMgr.Get("gm_data")
  if isAddDindex then
    data.DIndex = data.DIndex - 1
  else
    data.DIndex = data.DIndex + 1
  end
  if data.DIndex == 0 then
    data.DIndex = 1
  end
  if data.DIndex > data.MaxDindex then
    data.DIndex = data.MaxDindex
  end
  loopscrollrect.RefreshAllItem(loopscrollrect)
end
local refreshDesLoopNew = function(loopscrollrect, isAddDindex)
  local data = Z.DataMgr.Get("gm_data")
  if isAddDindex then
    data.DIndex = data.DIndex - 1
  else
    data.DIndex = data.DIndex + 1
  end
  if data.DIndex == 0 then
    data.DIndex = 1
  end
  if data.DIndex > data.MaxDindex then
    data.DIndex = data.MaxDindex
  end
  loopscrollrect:MovePanelToItemIndex(data.DIndex)
end
local submitGmCmd = function(cmdStr, cancelSource, targetId)
  if Z.IsBlockGM then
    return
  end
  logGreen(cmdStr)
  local gmData = Z.DataMgr.Get("gm_data")
  if cancelSource == nil then
    cancelSource = gmData.CancelSource
  end
  local cmdTbl = string.zsplit(cmdStr, " ")
  local param = {}
  targetId = targetId or ""
  for i = 2, #cmdTbl do
    local p = string.zsplit(cmdTbl[i], ",")
    for k, v in ipairs(p) do
      if v ~= "" then
        table.insert(param, v)
      end
    end
  end
  gmData:SetNowInputContent(cmdStr)
  local curCmdInfo = getCurCmdInfo(cmdTbl)
  if not curCmdInfo then
    local curCmdInfo = {}
    curCmdInfo.Command = cmdTbl[1]
    local mailInfo = table.concat(cmdTbl, " ", 2, table.zcount(cmdTbl))
    asyncSendCmd(curCmdInfo, mailInfo, cancelSource:CreateToken(), targetId)
    return
  end
  local pTbl
  if curCmdInfo.Type == gmData.CmdType.single then
    pTbl = getCurParameter(curCmdInfo, param)
    if not pTbl then
      Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd fail " .. "\229\189\147\229\137\141\230\140\135\228\187\164\229\143\130\230\149\176\228\184\141\229\173\152\229\156\168,\232\175\183\230\163\128\230\159\165\229\144\142\233\135\141\230\150\176\232\190\147\229\133\165")
      return
    end
    if type(pTbl) ~= "table" then
      Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd fail " .. pTbl)
      return
    end
    Z.LocalGmMgr:CallLocalGM(curCmdInfo.Command, table.unpack(param))
    setHistoryInfoToLocal()
    if curCmdInfo.AuToClose then
      closeGmView()
    end
  elseif curCmdInfo.Type == gmData.CmdType.group then
    executeGroupCmd(curCmdInfo, cancelSource, targetId)
    if curCmdInfo.AuToClose then
      closeGmView()
    end
  elseif curCmdInfo.Type == gmData.CmdType.server then
    if table.zcount(param) > 0 then
      local str = table.concat(param, ",")
      pTbl = str
    end
    asyncSendCmd(curCmdInfo, pTbl, cancelSource:CreateToken(), targetId)
    if curCmdInfo.AuToClose then
      closeGmView()
    end
  end
end
local getCmdInfo = function(str)
  local data = Z.DataMgr.Get("gm_data")
  data:SetDindex(1)
  if str == "" then
    return
  end
  local strTbl = string.zsplit(str, " ")
  local tbl = {}
  local gmCfgData = Z.TableMgr.GetTable("GMTableMgr").GetDatas()
  for _, gmData in pairs(gmCfgData) do
    if gmData.Command .. " " == str and not gmData.OnOff then
      tbl[1] = gmData
      break
    end
  end
  if #tbl == 0 then
    for _, gmData in pairs(gmCfgData) do
      if gmData.Command == strTbl[1] and not gmData.OnOff then
        tbl[1] = gmData
        break
      end
    end
  end
  if 0 < #tbl then
    local data = Z.DataMgr.Get("gm_data")
    data:SetMaxDindex(table.zcount(tbl))
    Z.DataMgr.Get("gm_data"):SetGMexplore(false)
    return tbl
  end
  if 2 <= #strTbl then
    return tbl
  end
  local commands = {}
  for i = 1, string.len(strTbl[1]) do
    table.insert(commands, string.sub(strTbl[1], i, i))
  end
  local isFinishi = false
  for _, gmData in pairs(gmCfgData) do
    isFinishi = false
    local str = gmData.Command
    for i = 1, #commands do
      if string.sub(str, i, i) ~= string.upper(commands[i]) and string.sub(str, i, i) ~= string.lower(commands[i]) and not gmData.OnOff then
        isFinishi = true
        break
      end
    end
    if not isFinishi then
      table.insert(tbl, gmData)
    end
  end
  local data = Z.DataMgr.Get("gm_data")
  data:SetMaxDindex(table.zcount(tbl))
  data:SetGMexplore(true)
  table.sort(tbl, function(a, b)
    return a.Command < b.Command
  end)
  return tbl
end
local sendCmd = function(curCmdInfo, ptbl, tagetId)
  Z.CoroUtil.create_coro_xpcall(function()
    local cancelSource = Z.CancelSource.Rent()
    local info = curCmdInfo .. " " .. ptbl
    submitGmCmd(info, cancelSource, tagetId)
    cancelSource:Recycle()
  end)()
end
local getCurCmdTbl = function(group)
  local gmTbl = Z.TableMgr.GetTable("GMTableMgr").GetDatas()
  local cmdTbl = {}
  for k, v in pairs(gmTbl) do
    if v.GMGroup == group and not v.OnOff then
      table.insert(cmdTbl, v)
    end
  end
  table.sort(cmdTbl, function(a, b)
    return a.Id < b.Id
  end)
  return cmdTbl
end
local initHistoryInfo = function()
  local data = Z.DataMgr.Get("gm_data")
  local hisInfo = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "GM_HISTORY", "")
  if hisInfo then
    Z.DataMgr.Get("gm_data"):SetHistoryName(hisInfo)
  end
  local tbl = string.zsplit(hisInfo, "&")
  Z.DataMgr.Get("gm_data"):SetHistoryInfo(tbl)
end
local refreshGmBtn = function(group)
  Z.EventMgr:Dispatch("GmBtnRefresh", group)
end
local refreshInputField = function(cmdInfo)
  Z.EventMgr:Dispatch("RefreshInputField", cmdInfo)
end
local onInputActions = function(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.GmVisible then
    openGmView()
  end
  if inputActionEventData.ActionId == Z.InputActionIds.Disconnect then
    Z.ConnectMgr:Disconnect()
  end
  if inputActionEventData.ActionId == Z.InputActionIds.LowMemory then
    Z.LuaBridge.OnLowMemory()
  end
  if inputActionEventData.ActionId == Z.InputActionIds.HideUI then
    local rootGo = Z.UIRoot.Instance.RootCanvas.gameObject
    rootGo:SetActive(not rootGo.activeInHierarchy)
  end
end
local ret = {
  SetHistoryInfoToLocal = setHistoryInfoToLocal,
  InitHistoryInfo = initHistoryInfo,
  RefreshDesLoop = refreshDesLoop,
  RefreshDesLoopNew = refreshDesLoopNew,
  OpenGmView = openGmView,
  CloseGmView = closeGmView,
  OpenGmMainView = openGmMainView,
  CloseGmMainView = closeGmMainView,
  SubmitGmCmd = submitGmCmd,
  GetCmdInfo = getCmdInfo,
  GetCurCmdTbl = getCurCmdTbl,
  RefreshGmBtn = refreshGmBtn,
  RefreshInputField = refreshInputField,
  SendCmd = sendCmd,
  OnInputActions = onInputActions
}
return ret
