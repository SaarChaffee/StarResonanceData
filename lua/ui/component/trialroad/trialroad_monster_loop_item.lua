local super = require("ui.component.loop_list_view_item")
local TrialRoadMonsterLoopItem = class("TrialRoadMonsterLoopItem", super)

function TrialRoadMonsterLoopItem:ctor()
end

function TrialRoadMonsterLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self:AddAsyncListener(self.uiBinder.btn_monster, function()
    self.parentUIView:OnMonsterInfoBtnClick()
  end)
end

function TrialRoadMonsterLoopItem:OnRefresh(data)
  self.data = data
  local monsterCfgData = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(data)
  local modelTableRow = Z.TableMgr.GetTable("ModelTableMgr").GetRow(monsterCfgData.ModelID)
  if modelTableRow == nil then
    return
  end
  local iconPath = modelTableRow.Image
  self.uiBinder.img_monster:SetImage(iconPath)
  local exploreMonsterVM_ = Z.VMMgr.GetVM("explore_monster")
  local level = exploreMonsterVM_.GetMonsterLevel(monsterCfgData)
  self.uiBinder.lab_num.text = level
end

function TrialRoadMonsterLoopItem:OnUnInit()
end

return TrialRoadMonsterLoopItem
