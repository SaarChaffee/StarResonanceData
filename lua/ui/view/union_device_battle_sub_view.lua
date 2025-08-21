local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_device_battle_subView = class("Union_device_battle_subView", super)
local loopListView = require("ui.component.loop_list_view")
local dungeonLoopItem = require("ui.component.union.union_device_battle_dungeon_item")
local memberRecordItem = require("ui.component.union.union_device_battle_dungeon_member_record_item")

function Union_device_battle_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_device_battle_sub", "union_2/union_device_battle_sub", UI.ECacheLv.None)
end

function Union_device_battle_subView:OnActive()
  self.unionVm_ = Z.VMMgr.GetVM("union")
  self.dungeonLoopList = loopListView.new(self, self.uiBinder.loop_dungeon_list, dungeonLoopItem, "union_device_battle_list_tpl")
  self.dungeonLoopList:Init({})
  self.memberLoopList = loopListView.new(self, self.uiBinder.loop_member_list, memberRecordItem, "union_device_battle_record_tpl")
  self.memberLoopList:Init({})
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
  self:refreshDungeon()
end

function Union_device_battle_subView:refreshDungeon()
  Z.CoroUtil.create_coro_xpcall(function()
    self.unionVm_:AsyncUnionGetAllBossData(self.cancelSource:CreateToken())
    local raidDungeonData = Z.TableMgr.GetTable("RaidDungeonTableMgr").GetDatas()
    local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
    local raidDungeons = {}
    for _, value in pairs(raidDungeonData) do
      if value.SeasonId == seasonId then
        raidDungeons[value.Difficult] = value
      end
    end
    self.curDungeonId_ = raidDungeons[1].DungeonId
    self.curBossId_ = raidDungeons[1].BossId[1]
    self.dungeonLoopList:RefreshListView(raidDungeons)
  end)()
end

function Union_device_battle_subView:OnSelectDungeonBoss(dungeonId, bossId)
  Z.CoroUtil.create_coro_xpcall(function()
    self.unionGetKillBossData_ = self.unionVm_:AsyncGetRaidDungeonPassInfo(bossId, self.cancelSource:CreateToken())
    self.curDungeonId_ = dungeonId
    self.curBossId_ = bossId
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, true)
    self.passMemberList_ = self.unionGetKillBossData_.killBossRecords
    self.uiBinder.lab_pass_num.text = string.format(Lang("union_active_buff_member"), self.unionGetKillBossData_.killCnt)
    local unionBossBuffRow = Z.TableMgr.GetTable("UnionBossBuffTableMgr").GetRow(self.curBossId_)
    local buffId = unionBossBuffRow.Buff
    local buffRow = Z.TableMgr.GetTable("BuffTableMgr").GetRow(buffId)
    if buffRow then
      self.uiBinder.lab_buff_name.text = buffRow.Name
      self.uiBinder.lab_buff_content.text = buffRow.Desc
    end
    local dungeonBossRow = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(self.curBossId_)
    local isUnlock = true
    self.uiBinder.lab_acitve_content.text = unionBossBuffRow.Desc
    self.uiBinder.lab_pass_num.text = self.unionGetKillBossData_.killCnt .. "/" .. unionBossBuffRow.ConditionValue
    self.uiBinder.union_buff_item.Ref:SetVisible(self.uiBinder.union_buff_item.node_on, isUnlock)
    self.uiBinder.union_buff_item.Ref:SetVisible(self.uiBinder.union_buff_item.node_off, not isUnlock)
    self.uiBinder.union_buff_item.rimg_icon_on:SetImage(dungeonBossRow.BossIcon)
    self.uiBinder.union_buff_item.rimg_icon_off:SetImage(dungeonBossRow.BossIcon)
    self:refershMemeberRecord()
  end)()
end

function Union_device_battle_subView:CheckIsInitSelect(dungeonId, bossId)
  return self.curDungeonId_ == dungeonId and self.curBossId_ == bossId
end

function Union_device_battle_subView:refershMemeberRecord()
  if #self.passMemberList_ == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.com_empty, true)
    return
  end
  table.sort(self.passMemberList_, function(a, b)
    return a.killTime > b.killTime
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.com_empty, false)
  self.memberLoopList:RefreshListView(self.passMemberList_)
end

function Union_device_battle_subView:OnDeActive()
  if self.dungeonLoopList then
    self.dungeonLoopList:UnInit()
    self.dungeonLoopList = nil
  end
  if self.memberLoopList then
    self.memberLoopList:UnInit()
    self.memberLoopList = nil
  end
end

function Union_device_battle_subView:OnRefresh()
end

return Union_device_battle_subView
