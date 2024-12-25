local super = require("ui.model.data_base")
local FashionData = class("FashionData", super)

function FashionData:ctor()
  super.ctor(self)
  self:Clear()
end

function FashionData:Init()
  self.wearDict_ = {}
end

function FashionData:Clear()
  self.colorDict_ = {}
end

function FashionData:ClearWearDict()
  self.wearDict_ = {}
end

function FashionData:InitFashionData()
  self:Clear()
  if Z.StageMgr.GetIsInLogin() then
    return
  end
  local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
  for region, fashionId in pairs(Z.ContainerMgr.CharSerialize.fashion.wearInfo) do
    if not self.wearDict_[region] then
      local styleData = {}
      styleData.fashionId = fashionId
      for uuid, item in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages[7].items) do
        local itemRow = itemTbl.GetRow(item.configId)
        if itemRow then
          local relatedFashion = itemRow.CorrelationId
          if relatedFashion == fashionId then
            styleData.uuid = uuid
          end
        end
      end
      self.wearDict_[region] = styleData
    end
  end
  for fashionId, dyeingInfo in pairs(Z.ContainerMgr.CharSerialize.fashion.fashionDatas) do
    for area, vec3 in pairs(dyeingInfo.colors) do
      local hsv = self:convertProtoVectorToHSV(fashionId, vec3)
      self:SetColor(fashionId, area, hsv)
    end
  end
end

function FashionData:GetColors()
  return self.colorDict_
end

function FashionData:GetWears()
  return self.wearDict_
end

function FashionData:GetWear(region)
  return self.wearDict_[region]
end

function FashionData:SetWear(region, styleData)
  self.wearDict_[region] = styleData
end

function FashionData:SetAllWear(dict)
  self.wearDict_ = dict
end

function FashionData:GetColor(fashionId)
  if not self.colorDict_[fashionId] then
    self.colorDict_[fashionId] = {}
  end
  return self.colorDict_[fashionId]
end

function FashionData:SetAllColor(dict)
  self.colorDict_ = dict
end

function FashionData:SetColor(fashionId, area, hsv)
  if not self.colorDict_[fashionId] then
    self.colorDict_[fashionId] = {}
  end
  self.colorDict_[fashionId][area] = hsv
end

function FashionData:GetColorIsUnlocked(fashionId, colorIndex)
  if Z.StageMgr.GetIsInLogin() then
    return true
  end
  if 0 < fashionId and 0 < colorIndex then
    local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
    if fashionRow then
      local isNeedUnlock = self:getColorIsNeedUnlock(fashionRow.ColorGroupId, colorIndex)
      if isNeedUnlock then
        local unlockColorInfo = Z.ContainerMgr.CharSerialize.fashion.UnlockColor[fashionId]
        if unlockColorInfo then
          return unlockColorInfo.colorInfoMap[colorIndex] == true
        else
          return false
        end
      else
        return true
      end
    end
  end
  return true
end

function FashionData:getColorIsNeedUnlock(groupId, colorIndex)
  local row = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(groupId)
  if row then
    for _, itemArray in ipairs(row.Unlock) do
      if colorIndex == itemArray[1] then
        return true
      end
    end
  end
  return false
end

function FashionData:GetUnlockItemDataListByColorGroupIdAndIndex(groupId, colorIndex)
  local ret = {}
  local row = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(groupId)
  if row then
    for _, itemArray in ipairs(row.Unlock) do
      if colorIndex == itemArray[1] then
        for i = 2, #itemArray, 2 do
          local itemId = itemArray[i]
          local unlockNum = itemArray[i + 1]
          if itemId and unlockNum then
            local data = {}
            data.ItemId = itemId
            data.UnlockNum = unlockNum
            table.insert(ret, data)
          else
            logError("\232\167\163\233\148\129\230\157\161\228\187\182\233\133\141\231\189\174\230\160\188\229\188\143\233\148\153\232\175\175, groupId = {0}, colorIndex = {1}", groupId, colorIndex)
          end
        end
        break
      end
    end
  end
  return ret
end

function FashionData:GetServerFashionWear(region)
  if not Z.StageMgr.GetIsInLogin() then
    return Z.ContainerMgr.CharSerialize.fashion.wearInfo[region]
  end
end

function FashionData:GetServerFashionColor(fashionId, area)
  if not Z.StageMgr.GetIsInLogin() then
    local areaColorDict = Z.ContainerMgr.CharSerialize.fashion.fashionDatas[fashionId]
    if areaColorDict then
      local areaColorVec = areaColorDict.colors[area]
      if areaColorVec then
        local hsv = self:convertProtoVectorToHSV(fashionId, areaColorVec)
        return hsv
      end
    end
  end
end

function FashionData:convertProtoVectorToHSV(fashionId, colorVec)
  local h = 0
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if fashionRow then
    local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
    if colorRow then
      if colorRow.Type == E.EHueModifiedMode.Board then
        h = colorVec.x
      elseif colorVec.x ~= 0 then
        for _, hueArray in ipairs(colorRow.Hue) do
          if colorVec.x == hueArray[1] then
            local intH = hueArray[2] or 0
            h = intH
            break
          end
        end
      end
    end
  end
  return {
    h = h,
    s = colorVec.y,
    v = colorVec.z
  }
end

return FashionData
