local ret = {}
local emojiIds = {
  BeRevive = 3006,
  Dead = 3007,
  FirstEnterDungeon = 3008,
  EndDungeon = 3009,
  EnterTeam = 3015
}

function ret.BinderEvent()
  Z.EventMgr:Add(Z.ConstValue.Team.EnterTeam, ret.OnEnterTeam)
  Z.EventMgr:Add(Z.ConstValue.Dungeon.EndDungeon, ret.OnEndDungeon)
  Z.EventMgr:Add(Z.ConstValue.Dead, ret.OnDead)
  Z.EventMgr:Add(Z.ConstValue.Revive, ret.OnRevive)
end

function ret.UnBinderEvent()
  Z.EventMgr:Remove(Z.ConstValue.Team.EnterTeam, ret.OnEnterTeam)
  Z.EventMgr:Remove(Z.ConstValue.Dungeon.EndDungeon, ret.OnEndDungeon)
  Z.EventMgr:Remove(Z.ConstValue.Dead, ret.OnDead)
  Z.EventMgr:Remove(Z.ConstValue.Revive, ret.OnRevive)
end

function ret:asyncLoadSpriteItem(id)
end

function ret.OnRevive()
  local teamVm = Z.VMMgr.GetVM("team")
  if not teamVm.CheckIsInTeam() then
    return
  end
  ret:asyncLoadSpriteItem(emojiIds.BeRevive)
end

function ret.OnDead()
  local teamVm = Z.VMMgr.GetVM("team")
  if not teamVm.CheckIsInTeam() then
    return
  end
  ret:asyncLoadSpriteItem(emojiIds.Dead)
end

function ret.OnEnterTeam()
  ret:asyncLoadSpriteItem(emojiIds.EnterTeam)
end

function ret.OnEndDungeon()
  local teamVm = Z.VMMgr.GetVM("team")
  if not teamVm.CheckIsInTeam() then
    return
  end
  ret:asyncLoadSpriteItem(emojiIds.EndDungeon)
end

function ret.EnterDungeon()
end

function ret.OnFirstEnterDungeon()
  local teamVm = Z.VMMgr.GetVM("team")
  if not teamVm.CheckIsInTeam() then
    return
  end
  ret:asyncLoadSpriteItem(emojiIds.FirstEnterDungeon)
end

return ret
