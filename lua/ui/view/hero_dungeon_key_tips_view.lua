local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_key_tipsView = class("Hero_dungeon_key_tipsView", super)
local keyItemID_ = Z.Global.HeroDungeonKeyId
local loopGridView_ = require("ui.component.loop_grid_view")
local keyItem_ = require("ui.component.dungeon.dungeon_key_loop_item")

function Hero_dungeon_key_tipsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_key_tips", "hero_dungeon/hero_dungeon_key_tips", UI.ECacheLv.None)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.itemsTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.data_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.teamData_ = Z.DataMgr.Get("team_data")
end

function Hero_dungeon_key_tipsView:OnActive()
  self:initBinders()
  self:initBaseData()
end

function Hero_dungeon_key_tipsView:OnDeActive()
  self.keyScrollView_:UnInit()
  self.keyScrollView_ = nil
  self.uiBinder.presscheck.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.presscheck:StopCheck()
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

function Hero_dungeon_key_tipsView:OnRefresh()
end

function Hero_dungeon_key_tipsView:initBinders()
  self.keyScrollView_ = loopGridView_.new(self, self.uiBinder.loop_item, keyItem_, "com_item_square_1_8")
  local dataList = {}
  self.keyScrollView_:Init(dataList)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      self.vm_:CloseKeyPopupView()
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self:AddClick(self.uiBinder.btn_ok, function()
    local limitNum = self.viewData
    if self.teamVm_.CheckIsInTeam() then
      if self.teamVm_.GetYouIsLeader() then
        local count = table.zcount(self.teamData_.TeamInfo.members)
        local canUseKey = count >= limitNum[1] and count <= limitNum[2]
        if canUseKey == false then
          Z.TipsVM.ShowTips(1004105)
          return
        end
      else
        Z.TipsVM.ShowTips(1004103)
        return
      end
    else
      Z.TipsVM.ShowTips(1004104)
      return
    end
    self.data_:SetUseKeyData(self.selectItemUuid)
    self.vm_:CloseKeyPopupView()
    Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonKeyChange)
  end)
end

function Hero_dungeon_key_tipsView:initBaseData()
  local itemUuids = self.itemsData_:GetItemUuidsByConfigId(keyItemID_)
  local count = 0
  if itemUuids then
    count = table.zcount(itemUuids)
  end
  self:SetUIVisible(self.uiBinder.node_item_info, 0 < count)
  self:SetUIVisible(self.uiBinder.node_empty, count == 0)
  if 0 < count then
    self.keyScrollView_:RefreshListView(itemUuids, true)
    self:OnClickItem(itemUuids[1])
  end
end

function Hero_dungeon_key_tipsView:OnClickItem(itemData)
  local itemInfo = self.itemsVM_.GetItemInfo(itemData, E.BackPackItemPackageType.Item)
  if itemInfo then
    local itemRow = self.itemsTableMgr_.GetRow(itemInfo.configId, true)
    if itemRow then
      self.uiBinder.lab_name.text = itemRow.Name
      self.uiBinder.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(itemInfo.configId))
      local str = itemRow.Description .. "\n"
      local affix = itemInfo.affixData.affixIds
      local affixStr = self.itemsVM_.GetKeyAffixStr(itemData, E.BackPackItemPackageType.Item)
      if string.len(affixStr) > 0 then
        affixStr = Lang("KeyItemAffixInfo") .. affixStr
      end
      self.uiBinder.lab_content.text = str .. affixStr
      self:addLinkClick(self.uiBinder.lab_content, affix)
      self.uiBinder.lab_quantity.text = Lang("Count") .. ":" .. tostring(itemInfo.count)
    end
  end
  self.selectItemUuid = itemData
  self.keyScrollView_:RefreshAllShownItem()
end

function Hero_dungeon_key_tipsView:addLinkClick(tmp, linkDatas)
  if tmp then
    tmp:AddListener(function(key)
      local index = tonumber(key)
      local linkData = linkDatas[index]
      if linkData then
        Z.CommonTipsVM.OpenAffixTips({linkData}, self.uiBinder.transform)
      end
    end, true)
  end
end

return Hero_dungeon_key_tipsView
