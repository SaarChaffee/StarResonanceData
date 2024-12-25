local getTitleByConfig = function(functionIds)
  local functable = Z.TableMgr.GetTable("FunctionTableMgr")
  if type(functionIds) == "number" then
    local config = functable.GetRow(functionIds)
    local returnstr = config and config.Name or ""
    return returnstr
  elseif type(functionIds) == "table" then
    local strTbl = {
      nil,
      nil,
      nil,
      nil
    }
    for idx, id in ipairs(functionIds) do
      local cfg = functable.GetRow(id)
      if idx == 1 and cfg then
        table.insert(strTbl, cfg.Name)
      elseif cfg then
        table.insert(strTbl, "/")
        table.insert(strTbl, cfg.Name)
      end
    end
    return table.concat(strTbl)
  else
    logError("function 'getTitleByConfig' type of param is error")
  end
end
local setLabText = function(lab, functionIds)
  if lab == nil then
    logError("type of param 'lab' is not ZText")
  end
  local str = getTitleByConfig(functionIds)
  if str == nil then
    return
  end
  lab.text = str
end
local commonPlayAnim = function(animComp, animName, token, callback)
  animComp:CoroPlayOnce(animName, token, callback, function(err)
    if err == Z.CancelException then
      return
    end
    logError(err)
  end)
end
local commonDotweenPlay = function(dotweenAnim, animName, callback)
  dotweenAnim:CoroPlay(animName, callback, function(err)
    if err ~= nil then
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      logError("CoroPlay err={0}", err)
    end
  end)
end
local commonPlayTogAnim = function(uiTog, token)
  local animNameLoop = "anim_com_tab_item_1_new_tpl_loop"
  local animName = "anim_com_tab_item_1_new_tpl_open"
  commonPlayAnim(uiTog, animName, token, function()
    uiTog:PlayLoop(animNameLoop)
  end)
end
local ret = {
  GetTitleByConfig = getTitleByConfig,
  SetLabText = setLabText,
  CommonPlayTogAnim = commonPlayTogAnim,
  CommonPlayAnim = commonPlayAnim,
  CommonDotweenPlay = commonDotweenPlay
}
return ret
