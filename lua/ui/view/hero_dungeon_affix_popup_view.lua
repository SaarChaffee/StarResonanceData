local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_affix_popup = class("Hero_dungeon_affix_popup", super)
local effectType = {
  Positive = 1,
  Negative = 2,
  Harmonic = 3
}

function Hero_dungeon_affix_popup:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_affix_popup")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
end

function Hero_dungeon_affix_popup:OnActive()
  self:initWidgets()
  self.affixTableMgr_ = Z.TableMgr.GetTable("AffixTableMgr")
  self.addAffixList_ = {}
  self.minusAffixList_ = {}
  self.selectAffixList_ = self.vm_.GetAffix(self.viewData.DungeonId)
  self:initDataList(true)
  self:initDataList(false)
  self:initItem()
end

function Hero_dungeon_affix_popup:initDataList(isAffix)
  local data = isAffix and self.viewData.Affix or self.viewData.SelectAffix
  for _, v in ipairs(data) do
    local tableData = self.affixTableMgr_.GetRow(v[1])
    if tableData then
      if tableData.EffectType == effectType.Positive or tableData.EffectType == effectType.Harmonic then
        table.insert(self.addAffixList_, {
          tableData,
          isAffix,
          v[2],
          tableData.EffectType
        })
      elseif tableData.EffectType == effectType.Negative then
        table.insert(self.minusAffixList_, {
          tableData,
          isAffix,
          v[2],
          tableData.EffectType
        })
      end
    end
  end
end

function Hero_dungeon_affix_popup:initWidgets()
  self.close_ = self.uiBinder.cont_tab_popup.cont_close.btn
  self.addContent_ = self.uiBinder.content1
  self.minusContent_ = self.uiBinder.content2
  self.affixRoot_ = self.uiBinder.layout_affix
  self.total_num_ = self.uiBinder.lab_total_number
  self.score_num_ = self.uiBinder.lab_scores_number
  self.reset_ = self.uiBinder.btn_reset
  self:AddClick(self.close_, function()
    self.vm_.CloseAffixPopupView()
  end)
  self:AddClick(self.reset_, function()
    self.selectAffixList_ = {}
    for _, v in ipairs(self.viewData.Affix) do
      table.insert(self.selectAffixList_, v[1])
    end
    self:initItem()
  end)
  self:AddClick(self.uiBinder.cont_tab_popup.cont_close.btn, function()
    self.vm_.CloseAffixPopupView()
  end)
  self:AddClick(self.uiBinder.cont_tab_popup.btn_ok, function()
    self.vm_.SetAffix(self.viewData.DungeonId, self.selectAffixList_)
    Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonAffixChange)
    self.vm_.CloseAffixPopupView()
  end)
end

function Hero_dungeon_affix_popup:initItem()
  local prefabPath = self:GetPrefabCacheData("item")
  if prefabPath == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.affixItemList_ = self.affixItemList_ or {}
    for i, v in ipairs(self.addAffixList_) do
      local item = self.affixItemList_[i]
      if not item then
        item = self:AsyncLoadUiUnit(prefabPath, "affixAddItem" .. i, self.addContent_)
        self.affixItemList_[i] = item
      end
      self:refreshItem(item, v)
      item.Ref:SetVisible(item.node_root, true)
    end
    for i, v in ipairs(self.minusAffixList_) do
      local item = self.affixItemList_[#self.addAffixList_ + i]
      if not item then
        item = self:AsyncLoadUiUnit(prefabPath, "affixMinusItem" .. i, self.minusContent_)
        self.affixItemList_[#self.addAffixList_ + i] = item
      end
      self:refreshItem(item, v)
      item.Ref:SetVisible(item.node_root, true)
    end
    for i = #self.addAffixList_ + #self.minusAffixList_ + 1, #self.affixItemList_ do
      local item = self.affixItemList_[i]
      if item then
        item.Ref:SetVisible(item.node_root, false)
      end
    end
  end)()
  self:refreshIcon()
end

function Hero_dungeon_affix_popup:refreshItem(unit, data)
  unit.Ref:SetVisible(unit.img_clock, data[2])
  unit.node_affix_icon_tpl.img_affix:SetImage(data[1].Icon)
  unit.node_affix_icon_tpl.Ref:SetVisible(unit.node_affix_icon_tpl.img_clock, data[2])
  local isAdd = false
  local colorHex
  if data[4] == effectType.Positive or data[4] == effectType.Harmonic then
    isAdd = true
    colorHex = "559962ff"
  elseif data[4] == effectType.Negative then
    isAdd = false
    colorHex = "e45a45ff"
  end
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(unit.lab_content, data[1].Description)
  unit.lab_name.text = string.format("<color=#%s>%s</color>", colorHex, data[1].Name)
  unit.Ref:SetVisible(unit.layout_title_add, isAdd)
  unit.Ref:SetVisible(unit.layout_title_minus, not isAdd)
  local score = data[3] > 0 and string.format("+%d%%", data[3]) or string.format("%d%%", data[3])
  unit.lab_add.text = score
  unit.lab_minus.text = score
  unit.Ref:SetVisible(unit.img_on, table.zcontains(self.selectAffixList_, data[1].Id))
  self:AddClick(unit.node_affix, function()
    if table.zcontains(self.selectAffixList_, data[1].Id) then
      if data[2] then
        Z.TipsVM.ShowTips(15001102)
        return
      end
      unit.Ref:SetVisible(unit.img_on, false)
      for i, v in pairs(self.selectAffixList_) do
        if v == data[1].Id then
          table.remove(self.selectAffixList_, i)
          break
        end
      end
      self:refreshIcon()
    else
      unit.Ref:SetVisible(unit.img_on, true)
      table.insert(self.selectAffixList_, data[1].Id)
      self:refreshIcon()
    end
  end)
end

function Hero_dungeon_affix_popup:refreshIcon()
  local diffValue = self.vm_.GetAffixValue(self.viewData.DungeonId, self.selectAffixList_)
  local allValue = self.viewData.BaseRatio + diffValue
  self.uiBinder.lab_scores_number.text = (0 < diffValue and "+" .. diffValue or diffValue) .. "%"
  self.uiBinder.lab_total_number.text = (0 < allValue and "+" .. allValue or allValue) .. "%"
  local prefabPath = self:GetPrefabCacheData("icon")
  if prefabPath == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.affixIconItemList_ = self.affixIconItemList_ or {}
    for i, v in ipairs(self.selectAffixList_) do
      local item = self.affixIconItemList_[i]
      if not item then
        item = self:AsyncLoadUiUnit(prefabPath, "affixIcon" .. i, self.affixRoot_)
        self.affixIconItemList_[i] = item
      end
      item.Ref:SetVisible(item.img_key, false)
      local cfg = self.affixTableMgr_.GetRow(v)
      if cfg then
        item.Ref:SetVisible(item.node_root, true)
        item.img_affix:SetImage(cfg.Icon)
        item.Ref:SetVisible(item.img_clock, self.vm_.IsRegularAffix(self.viewData.Affix, v))
      else
        item.Ref:SetVisible(item.node_root, false)
      end
    end
    for i = #self.selectAffixList_ + 1, #self.affixIconItemList_ do
      local item = self.affixIconItemList_[i]
      if item then
        item.Ref:SetVisible(item.node_root, false)
      end
    end
  end)()
end

function Hero_dungeon_affix_popup:OnDeActive()
  self.affixItemList_ = nil
  self.affixIconItemList_ = nil
  Z.CommonTipsVM.CloseRichText()
end

function Hero_dungeon_affix_popup:OnRefresh()
end

function Hero_dungeon_affix_popup:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root == nil then
    return nil
  end
  return self.uiBinder.prefabcache_root:GetString(key)
end

return Hero_dungeon_affix_popup
