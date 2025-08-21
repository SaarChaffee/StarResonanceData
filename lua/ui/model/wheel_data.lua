local super = require("ui.model.data_base")
local WheelData = class("WheelData", super)

function WheelData:ctor()
  super.ctor(self)
end

function WheelData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.WheelCount = 8
end

function WheelData:Clear()
  self.wheelPageDataTable = nil
end

function WheelData:UnInit()
  self.CancelSource:Recycle()
end

function WheelData:OnLanguageChange()
end

function WheelData:GetWheelList(pageIndex)
  if self.wheelPageDataTable and self.wheelPageDataTable[pageIndex] then
    return self.wheelPageDataTable[pageIndex]
  end
  if not self.wheelPageDataTable then
    self.wheelPageDataTable = {}
  end
  self.wheelPageDataTable[pageIndex] = {}
  local localKey = "BKL_EXPRESSION_WHEEL_" .. pageIndex
  if not Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, localKey) then
    return {}
  end
  local curDataString = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, localKey, "")
  local idArrays = string.split(curDataString, "|")
  for i = 1, self.WheelCount do
    local idArrayString = idArrays[i]
    if idArrayString == nil then
      local expressionData = {}
      expressionData.type = 0
      expressionData.id = 0
      table.insert(self.wheelPageDataTable[pageIndex], expressionData)
    else
      local idArray = string.split(idArrayString, "=")
      if #idArray == 2 then
        local type = tonumber(idArray[1])
        local id = tonumber(idArray[2])
        local expressionData = {}
        expressionData.type = type
        expressionData.id = id
        table.insert(self.wheelPageDataTable[pageIndex], expressionData)
      end
    end
  end
  return self.wheelPageDataTable[pageIndex]
end

function WheelData:GetDataByTypeAndId(type, id)
  if type == E.ExpressionSettingType.QuickMessage or type == E.ExpressionSettingType.Emoji then
    local config = Z.TableMgr.GetTable("ChatStickersTableMgr").GetRow(id, true)
    return config
  elseif type == E.ExpressionSettingType.UseItem then
    local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    return itemTableRow
  elseif type == E.ExpressionSettingType.Transporter then
    local transferTableRow = Z.TableMgr.GetTable("TransferTableMgr").GetRow(id)
    return transferTableRow
  else
    local expressionVm = Z.VMMgr.GetVM("expression")
    local itemList = expressionVm.GetExpressionShowDataByType(type, false, true)
    for k, v in pairs(itemList) do
      if v.tableData.Id == id then
        return v
      end
    end
  end
end

function WheelData:SetWheelList(pageIndex, wheelSettingList)
  if self.wheelPageDataTable and self.wheelPageDataTable[pageIndex] then
    self.wheelPageDataTable[pageIndex] = wheelSettingList
    self:SaveWheelList(pageIndex, wheelSettingList)
  end
end

function WheelData:SaveWheelList(pageIndex, wheelSettingList)
  local localKey = "BKL_EXPRESSION_WHEEL_" .. pageIndex
  local stringTable = {}
  for k, v in pairs(wheelSettingList) do
    table.insert(stringTable, string.zconcat(v.type, "=", v.id))
  end
  local saveString = table.concat(stringTable, "|")
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, localKey, saveString)
  Z.LocalUserDataMgr.Save()
end

function WheelData:GetWheelPage()
  if not Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, "BKL_EXPRESSION_WHEEL_PAGE") then
    return 1
  end
  return Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_EXPRESSION_WHEEL_PAGE", 1)
end

function WheelData:SetWheelPage(pageIndex)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_EXPRESSION_WHEEL_PAGE", pageIndex)
  Z.LocalUserDataMgr.Save()
end

function WheelData:SetWheelSlotClicked(slotClicked)
  self.slotClicked = slotClicked
end

function WheelData:GetWheelSlotClicked()
  return self.slotClicked
end

return WheelData
