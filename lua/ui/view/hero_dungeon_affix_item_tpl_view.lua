local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_affix_item_tplView = class("Hero_dungeon_affix_item_tplView", super)
local loopListView_ = require("ui.component.loop_list_view")
local affixLoopItem = require("ui.component.dungeon.dungeon_affix_loop_item")

function Hero_dungeon_affix_item_tplView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_affix_item_tpl")
  self.data_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.vm_ = Z.VMMgr.GetVM("team_enter")
end

function Hero_dungeon_affix_item_tplView:OnActive()
  self:initBinders()
  self:initBaseData()
end

function Hero_dungeon_affix_item_tplView:OnDeActive()
  self.keyScrollView_:UnInit()
  self.keyScrollView_ = nil
end

function Hero_dungeon_affix_item_tplView:OnRefresh()
end

function Hero_dungeon_affix_item_tplView:initBinders()
  self.keyScrollView_ = loopListView_.new(self, self.uiBinder.loop_item, affixLoopItem, "hero_dungeon_affix_icon_tpl")
  local dataList = {}
  self.keyScrollView_:Init(dataList)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      self.vm_.CloseAffixInfoView()
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
end

function Hero_dungeon_affix_item_tplView:initBaseData()
  local affixList
  local dataList = {}
  if self.viewData and self.viewData.dungeonAffix then
    affixList = self.viewData.dungeonAffix
    for _, value in ipairs(affixList) do
      local d = {}
      d.isKey = false
      d.affixId = value
      dataList[#dataList + 1] = d
    end
  end
  if self.viewData and self.viewData.keyAffix then
    affixList = self.viewData.keyAffix
    for _, value in ipairs(affixList) do
      local d = {}
      d.isKey = false
      d.affixId = value
      dataList[#dataList + 1] = d
    end
  end
  self.keyScrollView_:RefreshListView(dataList, true)
end

return Hero_dungeon_affix_item_tplView
