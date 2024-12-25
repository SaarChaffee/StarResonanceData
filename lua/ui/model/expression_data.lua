local super = require("ui.model.data_base")
local ExpressionData = class("ExpressionData", super)
local cjson = require("cjson")

function ExpressionData:ctor()
  super.ctor(self)
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.FacialLibraryTable = nil
  self.EmoteCache = nil
  self.EmoteTable = {}
  self.ActionTable = {}
  self.NormalActionTable = {}
  self.ContinuousActionTable = {}
  self.ExpressionTable = {}
  self.MultActionTable = {}
  self.ItemsSelectedData = {}
  self.TabSelected = 1
  self.IsRefTab = false
  self.historyDataOnlyId = {}
  self.tipsViewId = nil
  self.historyData_ = {}
  self.emoteTableData_ = {}
  self.displayExpressionType_ = E.DisplayExpressionType.None
  self.logicExpressionType_ = E.ExpressionType.None
  self.commonTipsData_ = {}
  self.historyKeyName = "ExpressionHistoryData"
  self:ClearCurPlayData()
end

function ExpressionData:Init()
end

function ExpressionData:Clear()
  self.commonTipsData_ = {}
  self.emoteTableData_ = {}
  self:ClearCurPlayData()
end

function ExpressionData:UnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function ExpressionData:onLanguageChange()
end

function ExpressionData:SetCommonTipsInfo(tipsViewType, showPieceType, showPieceId, isAdd)
  self.commonTipsData_ = {}
  self.commonTipsData_.commonTipsType = tipsViewType
  self.commonTipsData_.type = showPieceType
  self.commonTipsData_.id = showPieceId
  self.commonTipsData_.isAdd = isAdd
end

function ExpressionData:GetCommonTipsInfo()
  return self.commonTipsData_
end

function ExpressionData:GetExpressDirCache()
  if not self.EmoteCache or self.IsRefTab then
    self.EmoteCache = Z.ContainerMgr.CharSerialize.miscInfo.expressionIdsLearned
  end
  return self.EmoteCache
end

function ExpressionData:CheckActionIsUnlock(actionId)
  if not actionId then
    return false
  end
  local unlockTypeList = Z.ContainerMgr.CharSerialize.showPieceData.unlockTypeList
  if not (unlockTypeList[E.ExpressionType.Action] and next(unlockTypeList[E.ExpressionType.Action])) or not unlockTypeList[E.ExpressionType.Action].pieceIds then
    return
  end
  for _, v in pairs(unlockTypeList[E.ExpressionType.Action].pieceIds) do
    if actionId == v then
      return true
    end
  end
  return false
end

function ExpressionData:GetEmoteDataByActionName(id)
  if not id then
    return
  end
  local emoteTable = Z.TableMgr.GetTable("EmoteTableMgr")
  return emoteTable.GetRow(id)
end

function ExpressionData:GetTabTableData()
  local data = {}
  local index = 1
  for k, v in ipairs(Z.Global.UiEmoteTabsShow) do
    local tempTab_ = {}
    tempTab_.icon = v[1]
    tempTab_.type = tonumber(v[2])
    tempTab_.name = Lang(v[3])
    data[index] = tempTab_
    index = index + 1
  end
  return data
end

function ExpressionData:SetTabSelected(index)
  self.TabSelected = index
end

function ExpressionData:SetItemsSelectedData(data)
  self.ItemsSelectedData = data
end

function ExpressionData:GetItemsSelectedData()
  return self.ItemsSelectedData
end

function ExpressionData:GetExpressionCommonData(showPieceType)
  local OftenUseTypeList = Z.ContainerMgr.CharSerialize.showPieceData.OftenUseTypeList
  if not OftenUseTypeList or not next(OftenUseTypeList) then
    return
  end
  if not OftenUseTypeList[showPieceType] or not next(OftenUseTypeList[showPieceType]) then
    return
  end
  if not OftenUseTypeList[showPieceType].pieceIds or not next(OftenUseTypeList[showPieceType].pieceIds) then
    return
  end
  return OftenUseTypeList[showPieceType].pieceIds
end

function ExpressionData:AssemblyHistoryData(historyData)
  if string.zisEmpty(historyData) then
    return nil
  end
  local historyArr = cjson.decode(historyData)
  self.historyData_ = {}
  local id, data
  for k, v in pairs(historyArr) do
    data = {}
    data.Id = math.floor(v.Id)
    data.Type = math.floor(v.Type)
    table.insert(self.historyData_, data)
  end
  return self.historyData_
end

function ExpressionData:GetExpressionHistoryData()
  local historyData = ""
  local historyKeyName = self.historyKeyName
  if Z.LocalUserDataMgr.Contains(historyKeyName) then
    historyData = Z.LocalUserDataMgr.GetString(historyKeyName)
  end
  return self:AssemblyHistoryData(historyData)
end

function ExpressionData:UpdateExpressionHistoryData(showPieceType, showPieceId)
  self:CheckAndSetHasHistoryData(showPieceType, showPieceId)
  local historyData = {}
  historyData.Id = showPieceId
  historyData.Type = showPieceType
  table.insert(self.historyData_, 1, historyData)
  local historyDataMax = Z.Global.FacialMaxHistoricalNum
  if historyDataMax < table.zcount(self.historyData_) then
    self:RemoveExpressionHistoryData()
  end
  local deData = cjson.encode(self.historyData_)
  local historyKeyName = self.historyKeyName
  if not string.zisEmpty(deData) then
    Z.LocalUserDataMgr.SetString(historyKeyName, deData)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.ExpressionHistoryDataUpdate)
end

function ExpressionData:RemoveExpressionHistoryData()
  if self.historyData_ and next(self.historyData_) then
    local newTable = {}
    local maxLength = Z.Global.FacialMaxHistoricalNum
    local count = 0
    for _, value in pairs(self.historyData_) do
      count = count + 1
      if maxLength >= count then
        table.insert(newTable, value)
      end
    end
    self.historyData_ = newTable
  end
end

function ExpressionData:CheckAndSetHasHistoryData(showPieceType, showPieceId)
  local id
  for k, v in pairs(self.historyData_) do
    if v.Id == showPieceId and v.Type == showPieceType then
      id = k
      break
    end
  end
  if id then
    table.remove(self.historyData_, id)
  end
end

function ExpressionData:SetCurPlayingId(id)
  self.curPlayIs_[self.logicExpressionType_] = id
  if id == nil or id <= 0 then
    self.curPlayRowDatas_[self.logicExpressionType_] = nil
    return
  end
  local emoteTableMgr = Z.TableMgr.GetTable("EmoteTableMgr")
  self.curPlayRowDatas_[self.logicExpressionType_] = emoteTableMgr.GetRow(id)
end

function ExpressionData:ClearCurPlayData()
  self.curPlayIs_ = {
    [E.ExpressionType.Action] = -1,
    [E.ExpressionType.Emote] = -1,
    [E.ExpressionType.MultAction] = -1
  }
  self.curPlayRowDatas_ = {
    [E.ExpressionType.Action] = nil,
    [E.ExpressionType.Emote] = nil,
    [E.ExpressionType.MultAction] = nil
  }
end

function ExpressionData:GetCurPlayingEmotTableRow()
  return self.curPlayRowDatas_[self.logicExpressionType_]
end

function ExpressionData:GetCurPlayingId()
  return self.curPlayIs_[self.logicExpressionType_]
end

function ExpressionData:SetDisplayExpressionType(type)
  self.displayExpressionType_ = type
end

function ExpressionData:GetDisplayExpressionType()
  return self.displayExpressionType_
end

function ExpressionData:SetLogicExpressionType(type)
  self.logicExpressionType_ = type
end

function ExpressionData:GetLogicExpressionType()
  return self.logicExpressionType_
end

return ExpressionData
