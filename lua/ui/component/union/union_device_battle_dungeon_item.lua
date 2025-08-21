local super = require("ui.component.loop_list_view_item")
local loopListView = require("ui.component.loop_list_view")
local unionDeviceBattleDungeonItem = class("unionDeviceBattleDungeonItem", super)
local dungeonLoopItem = require("ui.component.union.union_device_main_item")

function unionDeviceBattleDungeonItem:ctor()
end

function unionDeviceBattleDungeonItem:OnInit()
  self.dungeonLoopList_ = loopListView.new(self.parent.UIView, self.uiBinder.loop_item, dungeonLoopItem, "union_device_main_item_tpl")
  self.dungeonLoopList_:Init({})
  Z.EventMgr:Add(Z.ConstValue.Union.UnionDeviceBattleBuffSelect, self.OnSelectDungeonBoss, self)
end

function unionDeviceBattleDungeonItem:OnRefresh(data)
  self.raidDungeonRow_ = data
  local dungeonRow = Z.TableMgr.GetRow("DungeonsTableMgr", self.raidDungeonRow_.DungeonId)
  if dungeonRow then
    self.uiBinder.lab_name.text = dungeonRow.Name
  end
  local data = {}
  for index, value in ipairs(self.raidDungeonRow_.BossId) do
    local temp = {
      dungeonId = self.raidDungeonRow_.DungeonId,
      bossId = value
    }
    table.insert(data, temp)
  end
  self.dungeonLoopList_:RefreshListView(data)
end

function unionDeviceBattleDungeonItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Union.UnionDeviceBattleBuffSelect, self.OnSelectDungeonBoss, self)
end

function unionDeviceBattleDungeonItem:OnSelectDungeonBoss(dungeonId, BossId)
  if self.dungeonId_ ~= dungeonId and self.dungeonLoopList_ then
    self.dungeonLoopList_:ClearAllSelect()
  end
end

function unionDeviceBattleDungeonItem:OnUnInit()
  if self.dungeonLoopList_ then
    self.dungeonLoopList_:UnInit()
    self.dungeonLoopList_ = nil
  end
end

return unionDeviceBattleDungeonItem
