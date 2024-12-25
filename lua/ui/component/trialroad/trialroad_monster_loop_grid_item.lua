local super = require("ui.component.loop_grid_view_item")
local TrialRoadMonsterLoopItem = class("TrialRoadMonsterLoopItem", super)

function TrialRoadMonsterLoopItem:ctor()
end

function TrialRoadMonsterLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function TrialRoadMonsterLoopItem:OnRefresh(data)
  self.data = data
  local monsterCfgData = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(data.monsterId)
  local modelTableRow = Z.TableMgr.GetTable("ModelTableMgr").GetRow(monsterCfgData.ModelID)
  if modelTableRow == nil then
    return
  end
  local iconPath = modelTableRow.Image
  self.uiBinder.img_monster:SetImage(iconPath)
  self.uiBinder.lab_monster_name.text = monsterCfgData.Name
  self.uiBinder.lab_monster_gs.text = data.monsterGs
end

function TrialRoadMonsterLoopItem:OnUnInit()
end

return TrialRoadMonsterLoopItem
