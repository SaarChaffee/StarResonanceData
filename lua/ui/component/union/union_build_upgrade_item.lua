local super = require("ui.component.loop_list_view_item")
local UnionBuildUpgradeItem = class("UnionBuildUpgradeItem", super)
local unionBuffitem = require("ui.component.union.union_buff_item")
local MAX_BUFF_COUNT = Z.ConstValue.UnionConstValue.MAX_BUFF_COUNT

function UnionBuildUpgradeItem:OnInit()
  self.unionUpradingPurviewTableMgr_ = Z.TableMgr.GetTable("UnionUpradingPurviewTableMgr")
  self.unionTimelinessBuffTableMgr_ = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr")
  self.buffItemDict_ = {}
end

function UnionBuildUpgradeItem:OnRefresh(data)
  self.uiBinder.lab_desc_left.text = ""
  self.uiBinder.lab_desc_right.text = ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_upgrade, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_buff, false)
  if data.Type == "Level" then
    local buildLevel = data.Value
    self.uiBinder.lab_title.text = Lang("LevelUpgrade")
    if buildLevel == 1 then
      self.uiBinder.lab_desc_left.text = Lang("UnLock")
    else
      self.uiBinder.lab_desc_left.text = Lang("Level", {
        val = buildLevel - 1
      })
    end
    self.uiBinder.lab_desc_right.text = Lang("Level", {val = buildLevel})
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow, true)
  elseif data.Type == "Effect" then
    local diffInfo = data.Value
    local config = self.unionUpradingPurviewTableMgr_.GetRow(diffInfo.id)
    if diffInfo.id == E.UnionBuildEffectDef.AddMenSumNum then
      local baseNum = Z.Global.UnionMemberInitialNum
      self.uiBinder.lab_title.text = Z.Placeholder.Placeholder(config.ShowPurview, {
        val = baseNum + diffInfo.curValue
      })
    elseif diffInfo.id == E.UnionBuildEffectDef.UnlockUnionScreen then
      local screenId = diffInfo.curValue[2]
      local screenValue = diffInfo.curValue[3]
      self.uiBinder.lab_title.text = Z.Placeholder.Placeholder(config.ShowPurview, {val1 = screenId, val2 = screenValue})
    elseif diffInfo.id == E.UnionBuildEffectDef.UnlockUnionAlbum then
      local baseNum = Z.Global.UnionPhotoAlbumNumLimit
      self.uiBinder.lab_title.text = Z.Placeholder.Placeholder(config.ShowPurview, {
        val = baseNum + diffInfo.curValue
      })
    elseif diffInfo.id == E.UnionBuildEffectDef.UnlockEffectId then
      for i = 1, MAX_BUFF_COUNT do
        local buffId = diffInfo.curValue[i]
        local item = self.uiBinder["binder_buff_" .. i]
        if buffId then
          local buffItemData = {BuffId = buffId}
          if self.buffItemDict_[i] == nil then
            self.buffItemDict_[i] = unionBuffitem.new()
            self.buffItemDict_[i]:Init(item, buffItemData)
          else
            self.buffItemDict_[i]:Refresh(buffItemData)
          end
        end
        item.Ref.UIComp:SetVisible(buffId ~= nil)
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder.trans_buff, true)
      self.uiBinder.lab_title.text = Lang("UnlockEffect")
    else
      self.uiBinder.lab_title.text = Z.Placeholder.Placeholder(config.ShowPurview, {
        val = diffInfo.curValue
      })
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow, false)
  elseif data.Type == "Time" then
    local buildTime = data.Value
    self.uiBinder.lab_title.text = Lang("BuildTime")
    self.uiBinder.lab_desc_left.text = Z.TimeFormatTools.FormatToDHMS(buildTime, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow, false)
  end
end

function UnionBuildUpgradeItem:OnUnInit()
  self.unionUpradingPurviewTableMgr_ = nil
  self.unionTimelinessBuffTableMgr_ = nil
  self:unInitBuffItem()
end

function UnionBuildUpgradeItem:unInitBuffItem()
  for key, item in pairs(self.buffItemDict_) do
    item:UnInit()
  end
  self.buffItemDict_ = nil
end

return UnionBuildUpgradeItem
