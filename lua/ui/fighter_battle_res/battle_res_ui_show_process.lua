local BattleResUIShowProcess = class("BattleResUIShowProcess")
E.PlayerBattleResType = {
  BarEffect = 0,
  Bar = 1,
  DotEffect = 2
}

function BattleResUIShowProcess:Init()
  BattleResUIShowProcess.isPlaying = {}
end

function BattleResUIShowProcess:Clear()
  BattleResUIShowProcess.isPlaying = {}
end

function BattleResUIShowProcess:OnDisPlayProcess_0(zuiEffect, displayEffectParam)
  if BattleResUIShowProcess.isPlaying[displayEffectParam.type] == displayEffectParam.isOpen then
    return
  end
  if displayEffectParam.isOpen then
    zuiEffect:ReleseEffGo()
    zuiEffect:CreatEFFGOWithCallBack(displayEffectParam.effPath, true, Vector3.zero, function()
      if tonumber(displayEffectParam.param[3]) == 1 then
        zuiEffect:UpdateDepth(1, true)
      else
        zuiEffect:UpdateDepth(-300, true)
      end
    end)
  else
    zuiEffect:ReleseEffGo()
  end
  BattleResUIShowProcess.isPlaying[displayEffectParam.type] = displayEffectParam.isOpen
end

function BattleResUIShowProcess:OnDisPlayProcess_1(zimgBar, displayEffectParam, zuiEffect)
  if BattleResUIShowProcess.isPlaying[displayEffectParam.type] ~= displayEffectParam.isOpen and zuiEffect ~= nil then
    if displayEffectParam.isOpen then
      zuiEffect:ReleseEffGo()
      zuiEffect:CreatEFFGOWithCallBack(displayEffectParam.effPath, true, Vector3.zero, function()
        if tonumber(displayEffectParam.param[3]) == 1 then
          zuiEffect:UpdateDepth(1, true)
        else
          zuiEffect:UpdateDepth(-300, true)
        end
      end)
    else
      zuiEffect:ReleseEffGo()
    end
  end
  if displayEffectParam.isOpen then
    local now = Z.TimeTools.Now()
    local beginTime = displayEffectParam.buffItem.CreateTime
    local begin = 1 - (now - beginTime) / displayEffectParam.buffItem.Duration
    local target = 0
    if displayEffectParam.param[4] == 1 then
      begin = (now - beginTime) / displayEffectParam.buffItem.Duration
      target = 1
    end
    local totalTime = beginTime + displayEffectParam.buffItem.Duration - now
    zimgBar:Play(begin, target, totalTime / 1000, nil)
  else
    zimgBar:Play(0, 0, 0, nil)
  end
  BattleResUIShowProcess.isPlaying[displayEffectParam.type] = displayEffectParam.isOpen
end

function BattleResUIShowProcess:OnDisPlayProcess_2(dot, displayEffectParam)
  if BattleResUIShowProcess.isPlaying[displayEffectParam.type] == displayEffectParam.isOpen then
    return
  end
  dot:DisplayEffect(displayEffectParam.isOpen, displayEffectParam.param)
  BattleResUIShowProcess.isPlaying[displayEffectParam.type] = displayEffectParam.isOpen
end

return BattleResUIShowProcess
