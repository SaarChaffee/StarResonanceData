local super = require("ui.model.data_base")
local FashionData = class("FashionData", super)

function FashionData:ctor()
  super.ctor(self)
  self:Clear()
end

function FashionData:Init()
  self.wearDict_ = {}
  self.advanceSelectData_ = {}
  self.selectProfessionId_ = 0
  self.OptionIndex = 0
  self.optionList_ = {}
  self.resetDict_ = {}
  self.AreaCount = 4
  self.SocksAreaIndex = 5
  self.IsShowAllFashion = false
end

function FashionData:Clear()
  self.colorDict_ = {}
  self.advanceSelectData_ = {}
  self.selectProfessionId_ = 0
  self.OptionIndex = 0
  self.optionList_ = {}
  self.resetDict_ = {}
  self.IsShowAllFashion = false
end

function FashionData:ClearWearDict()
  self.wearDict_ = {}
  self.selectProfessionId_ = 0
end

function FashionData:ClearAdvanceSelectData()
  self.advanceSelectData_ = {}
end

function FashionData:InitFashionData()
  self:Clear()
  if Z.StageMgr.GetIsInLogin() then
    return
  end
  local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
  local fashionAdvancedTbl = Z.TableMgr.GetTable("FashionAdvancedTableMgr")
  for region, wearFashionId in pairs(Z.ContainerMgr.CharSerialize.fashion.wearInfo) do
    if not self.wearDict_[region] then
      local styleData = {}
      styleData.wearFashionId = wearFashionId
      local fashionId = wearFashionId
      local row = fashionAdvancedTbl.GetRow(wearFashionId, true)
      if row then
        fashionId = row.FashionId
      end
      styleData.fashionId = fashionId
      for _, item in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Fashion].items) do
        local itemRow = itemTbl.GetRow(item.configId)
        if itemRow then
          local relatedFashion = itemRow.CorrelationId
          if relatedFashion == fashionId then
            styleData.isUnlock = true
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
    if dyeingInfo.attachmentColor then
      for _, vec3 in pairs(dyeingInfo.attachmentColor) do
        local hsv = self:convertProtoVectorToHSV(fashionId, vec3)
        self:SetColor(fashionId, self.SocksAreaIndex, hsv)
        break
      end
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

function FashionData:SetSelectProfessionId(professionId)
  self.selectProfessionId_ = professionId
end

function FashionData:GetSelectProfessionId()
  return self.selectProfessionId_
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

function FashionData:GetColorDict()
  return self.colorDict_
end

function FashionData:SetColor(fashionId, area, hsv)
  if not self.colorDict_[fashionId] then
    self.colorDict_[fashionId] = {}
  end
  self.colorDict_[fashionId][area] = hsv
  if table.zcount(self.colorDict_[fashionId]) == 0 then
    self.colorDict_[fashionId] = nil
  end
end

function FashionData:GetFashionAreaColor(fashionId, are)
  if not self.colorDict_[fashionId] then
    return
  end
  return self.colorDict_[fashionId][are]
end

function FashionData:RemoveColor(fashionId)
  if self.colorDict_[fashionId] then
    self.colorDict_[fashionId] = nil
  end
  if self.resetDict_[fashionId] then
    self.resetDict_[fashionId] = {}
  end
end

function FashionData:SetAdvanceSelectData(originalFashionId, advanceFashionId)
  self.advanceSelectData_[originalFashionId] = advanceFashionId
end

function FashionData:GetAdvanceSelectData(originalFashionId)
  return self.advanceSelectData_[originalFashionId]
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
    if region == E.FashionRegion.WeapoonSkin then
      return Z.VMMgr.GetVM("weapon_skill_skin"):GetWeaponSkinId(self:GetSelectProfessionId())
    else
      return Z.ContainerMgr.CharSerialize.fashion.wearInfo[region]
    end
  end
end

function FashionData:GetServerFashionColor(fashionId, area)
  if not Z.StageMgr.GetIsInLogin() then
    local areaColorDict = Z.ContainerMgr.CharSerialize.fashion.fashionDatas[fashionId]
    if areaColorDict then
      local areaColorVec
      if area == self.SocksAreaIndex then
        areaColorVec = areaColorDict.attachmentColor[1]
      else
        areaColorVec = areaColorDict.colors[area]
      end
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

function FashionData:GetOptionList()
  return self.optionList_
end

function FashionData:ClearOptionList()
  self.optionList_ = {}
  self.OptionIndex = 0
end

function FashionData:GetOptionData(index)
  return self.optionList_[index]
end

function FashionData:AddOptionData(sourceData)
  for i = #self.optionList_, self.OptionIndex + 1, -1 do
    table.remove(self.optionList_, i)
  end
  if #self.optionList_ >= 10 then
    table.remove(self.optionList_, 1)
  end
  self.optionList_[#self.optionList_ + 1] = {sourceData = sourceData}
  self.OptionIndex = #self.optionList_
end

function FashionData:SetCurOptionTargetData(targetData)
  if self.OptionIndex ~= #self.optionList_ then
    self.optionList_[#self.optionList_] = nil
    self.OptionIndex = #self.optionList_
    return
  end
  if not self.optionList_[#self.optionList_] then
    return
  end
  self.optionList_[#self.optionList_].targetData = targetData
end

function FashionData:GetAllFashionLevelRows()
  if self.fashionLevelDatas then
    return self.fashionLevelDatas
  end
  self.fashionLevelDatas = Z.TableMgr.GetTable("FashionLevelTableMgr").GetDatas()
  return self.fashionLevelDatas
end

function FashionData:GetAllFashionPrivilegeRows()
  if self.fashionPrivilegeDatas then
    return self.fashionPrivilegeDatas
  end
  self.fashionPrivilegeDatas = Z.TableMgr.GetTable("FashionPrivilegeTableMgr").GetDatas()
  return self.fashionPrivilegeDatas
end

function FashionData:OnLanguageChange()
  self.fashionLevelDatas = Z.TableMgr.GetTable("FashionLevelTableMgr").GetDatas()
  self.fashionPrivilegeDatas = Z.TableMgr.GetTable("FashionPrivilegeTableMgr").GetDatas()
end

return FashionData
