local ctrlBtnsData = Z.DataMgr.Get("player_ctrl_btns_data")
local getData = function(key)
  local v = ctrlBtnsData[key]
  if v == nil then
    logGreen("[playerCtrlBtnsVm GetData] key {1} is nil", key)
  end
  return v
end
local setData = function(key, value)
  ctrlBtnsData:UpdateData(key, value)
end
local ret = {GetData = getData, SetData = setData}
return ret
