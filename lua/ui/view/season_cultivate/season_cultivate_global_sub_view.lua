local super = require("ui.ui_subview_base")
local SeasonCultivateGlobal = class("SeasonCultivateGlobal", super)
local NormalAttributeUnitPath = GetLoadAssetPath("SeasonCultivateNormalAttributeUnit")
local CoreAttributeUnitPath = GetLoadAssetPath("SeasonCultivateCoreAttributeUnit")

function SeasonCultivateGlobal:ctor()
  super.ctor(self, "season_cultivate_global", "season_cultivate/season_cultivate_global_sub", Z.UI.ECacheLv.None)
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
end

function SeasonCultivateGlobal:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  
  function self.coreHoleNodeInfoChangeFunc_(container, dirtys)
    self:coreHoleNodeInfoChangeFunc(container, dirtys)
  end
  
  Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:RegWatcher(self.coreHoleNodeInfoChangeFunc_)
end

function SeasonCultivateGlobal:OnRefresh()
  local config = self.seasonCultivateVM_.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, 1)
  Z.CoroUtil.create_coro_xpcall(function()
    self:ClearAllUnits()
    self.allItem_ = {}
    self:resetCoreAttribute()
    self:refreshAttrChooseCoun()
  end)()
end

function SeasonCultivateGlobal:OnDeActive()
  for index, item in pairs(self.allItem_) do
    item.btn:RemoveAllListeners()
  end
  Z.CommonTipsVM.CloseRichText()
  if self.coreHoleNodeInfoChangeFunc_ then
    Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:UnregWatcher(self.coreHoleNodeInfoChangeFunc_)
    self.coreHoleNodeInfoChangeFunc_ = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnSlotSubViewClose)
end

function SeasonCultivateGlobal:resetAttribute()
  local normalNodeInfo = self.seasonCultivateVM_.GetAllNormalNodeInfo()
  for _, info in pairs(normalNodeInfo) do
    local unit = self:AsyncLoadUiUnit(NormalAttributeUnitPath, _formatStr("attribute_{0}", info.attrConfig.NodeId), self.uiBinder.node_property.transform, self.cancelSource:CreateToken())
    if unit then
      unit.lab_name.text = info.attrConfig.NodeName
      unit.img_icon:SetImage(info.attrConfig.NodeIcon)
      unit.lab_num.text = "+" .. info.attrConfig.NodeEffect[1][3]
    end
  end
end

function SeasonCultivateGlobal:refreshAttrChooseCoun()
  local choose, limit = self.seasonCultivateVM_.GetCoreAttrChooseCount()
  self.uiBinder.lab_effect.text = Lang("CultivateCoreEffect", {val1 = choose, val2 = limit})
end

function SeasonCultivateGlobal:resetCoreAttribute()
  local coreNodeInfo = self.seasonCultivateVM_.GetCoreNodeInfo()
  if not next(coreNodeInfo) then
    return
  end
  self.allItem_ = {}
  for _, info in pairs(coreNodeInfo) do
    local unit = self:AsyncLoadUiUnit(CoreAttributeUnitPath, _formatStr("core_attribute_{0}", info.attrConfig.NodeId), self.uiBinder.node_item.transform, self.cancelSource:CreateToken())
    if unit then
      self.allItem_[info.attrConfig.NodeId] = unit
      unit.img_icon:SetImage(info.attrConfig.NodeIcon)
      local isSelected = self.seasonCultivateVM_.CheckCoreAttrIsChooseByNodeId(info.attrConfig.NodeId)
      unit.Ref:SetVisible(unit.img_select, isSelected)
      unit.Ref:SetVisible(unit.img_use, isSelected)
      unit.lab_level.text = info.nodeLevel
      local config = Z.TableMgr.GetTable("SeasonNodeDataTableMgr").GetRow(info.attrConfig.Id)
      local name = config and config.NodeName .. ": " or ""
      Z.RichTextHelper.SetBinderTmpLabTextWithCommonLink(unit.lab_info, name .. self.seasonCultivateVM_.GetAttributeDes(info.attrConfig.Id))
      self:AddAsyncClick(unit.btn, function()
        local nodeInfo = self.seasonCultivateVM_.GetCoreNodeInfoByNodeId(info.attrConfig.NodeId)
        if not nodeInfo or nodeInfo.slot == self.viewData then
          return
        end
        local chooseNodes = {}
        local coreAttributes = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleNodeInfos
        if coreAttributes then
          local notselectedId = 0
          local changeSlotNodeId = 0
          local slotId = 0
          if nodeInfo.choose then
            local nowSlotData = self.seasonCultivateVM_.GetCoreNodeSlotInfoBySlotId(self.viewData)
            if nowSlotData then
              changeSlotNodeId = nowSlotData.nodeId
              slotId = nodeInfo.slot
              notselectedId = nodeInfo.nodeId
            else
              notselectedId = nodeInfo.nodeId
            end
          end
          for nodeId, value in pairs(coreAttributes) do
            if value.choose and nodeId ~= notselectedId then
              local slot = value.slot
              if changeSlotNodeId == nodeId then
                slot = slotId
              end
              if slot ~= self.viewData then
                local tab = {}
                tab.slot = slot
                tab.nodeId = nodeId
                tab.nodeLevel = value.nodeLevel
                tab.choose = true
                chooseNodes[#chooseNodes + 1] = tab
              end
            end
          end
        end
        chooseNodes[#chooseNodes + 1] = {
          slot = self.viewData,
          nodeId = nodeInfo.nodeId,
          nodeLevel = nodeInfo.nodeLevel,
          choose = true
        }
        self.seasonCultivateVM_.AsyncChooseCoreSeasonHoleNode(chooseNodes, self.cancelSource:CreateToken())
      end)
    end
  end
end

function SeasonCultivateGlobal:setAttrSelectedState()
  for nodeId, item in pairs(self.allItem_) do
    local isSelected = self.seasonCultivateVM_.CheckCoreAttrIsChooseByNodeId(nodeId)
    item.Ref:SetVisible(item.img_select, isSelected)
    item.Ref:SetVisible(item.img_use, isSelected)
  end
end

function SeasonCultivateGlobal:coreHoleNodeInfoChangeFunc(container, dirtys)
  if dirtys.coreHoleNodeInfos then
    self:setAttrSelectedState()
    self:refreshAttrChooseCoun()
  end
end

function SeasonCultivateGlobal:refreshItemState()
end

return SeasonCultivateGlobal
