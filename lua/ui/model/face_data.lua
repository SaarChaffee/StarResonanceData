local OptionDef = require("ui.model.face_define_option")
local super = require("ui.model.data_base")
local FaceData = class("FaceData", super)

function FaceData:ctor()
  super.ctor(self)
  self.FaceDef = require("ui.model.face_define")
  self.FaceDefaultModelName = "FaceModel"
  self.FaceModelName = "FaceModel"
end

function FaceData:Init()
  super.Init(self)
  self.CancelSource = Z.CancelSource.Rent()
  self:initBeardDict()
  self:ResetFaceData()
  self.isInit_ = false
  self.FaceModelName = "FaceModel"
  self.FaceShare = nil
  self.FaceCosDataList = nil
  self.UploadFaceDataSuccess = nil
  self.faceOptionDict_ = {}
  self:clearFaceTableData()
end

function FaceData:UnInit()
  self.CancelSource:Recycle()
end

function FaceData:Clear()
  self:clearFaceTableData()
end

function FaceData:clearFaceTableData()
  self.faceOptionTableData_ = nil
  self.faceTableData_ = nil
  self.faceDataTableData_ = nil
end

function FaceData:ResetFaceData()
  self.FaceState = E.FaceDataState.Create
  self.ModelId = 0
  self.Gender = 0
  self.BodySize = 0
  self.Height = 0
  self:ResetFaceCacheValue()
end

function FaceData:ResetFaceCacheValue()
  self.cacheHeightSliderValue = 0
  self.cacheHeightShoeValue = 0
  self.CanUseCacheFaceData = false
  self.CacheFaceDataAccountName = ""
  self.faceEditorOperationIndex_ = 0
  self.faceEditorOperationList_ = {}
  self.copyColorHtml_ = nil
  self:ResetFaceOption()
end

function FaceData:GetIsInit()
  return self.isInit_
end

function FaceData:SetIsInit(isInit)
  self.isInit_ = isInit
end

function FaceData:InitFaceOption()
  self.faceOptionDict_ = {}
end

function FaceData:AddFaceOptionServerValue(optionEnum, value)
  self.faceOptionDict_[optionEnum] = OptionDef.CreateFaceOption(optionEnum)
  self.faceOptionDict_[optionEnum]:SetByProtoValue(value)
end

function FaceData:AddFaceOptionInitValue(optionEnum, value)
  self.faceOptionDict_[optionEnum] = OptionDef.CreateFaceOption(optionEnum)
  self.faceOptionDict_[optionEnum]:SetValue(value)
end

function FaceData:UpdateFaceOptionData(optionEnum, value)
  if not self.faceOptionDict_[optionEnum] then
    self.faceOptionDict_[optionEnum] = OptionDef.CreateFaceOption(optionEnum)
  end
  self.faceOptionDict_[optionEnum]:SetByProtoValue(value)
end

function FaceData:GetFaceOptionByEnum(optionEnum)
  return self.faceOptionDict_[optionEnum]
end

function FaceData:GetFaceOptionValueByEnum(optionEnum)
  return self.faceOptionDict_[optionEnum]:GetValue()
end

function FaceData:ResetFaceOption()
  self.FaceOptionDict = {}
  if not self.faceOptionTableData_ then
    self.faceOptionTableData_ = Z.TableMgr.GetTable("FaceOptionTableMgr").GetDatas()
  end
  for optionEnum, _ in pairs(self.faceOptionTableData_) do
    local option = OptionDef.CreateFaceOption(optionEnum)
    if option then
      self.FaceOptionDict[optionEnum] = option
    end
  end
end

function FaceData:GetFaceTableData()
  if not self.faceTableData_ then
    self.faceTableData_ = Z.TableMgr.GetTable("FaceTableMgr").GetDatas()
  end
  return self.faceTableData_
end

function FaceData:GetFaceDataTableData()
  if not self.faceDataTableData_ then
    self.faceDataTableData_ = Z.TableMgr.GetTable("FaceDataTableMgr").GetDatas()
  end
  return self.faceDataTableData_
end

function FaceData:GetFaceOptionValue(pbEnum)
  if self.FaceOptionDict[pbEnum] then
    return self.FaceOptionDict[pbEnum]:GetValue()
  else
    logError("[GetFaceOptionValue] optionEnum = {0}\228\184\141\229\173\152\229\156\168", pbEnum)
  end
end

function FaceData:SetFaceOptionValue(pbEnum, value, ignoreRecord)
  if not ignoreRecord then
    self:RecordEditorValue(pbEnum, value)
  end
  if self.FaceOptionDict[pbEnum] then
    self.FaceOptionDict[pbEnum]:SetValue(value)
  else
    logError("[SetFaceOptionValue] optionEnum = {0}\228\184\141\229\173\152\229\156\168", pbEnum)
  end
end

function FaceData:SetFaceOptionValueWithoutLimit(pbEnum, value)
  self:RecordEditorValue(pbEnum, value)
  if self.FaceOptionDict[pbEnum] then
    self.FaceOptionDict[pbEnum]:SetValue(value, false)
  else
    logError("[SetFaceOptionValue] optionEnum = {0}\228\184\141\229\173\152\229\156\168", pbEnum)
  end
end

function FaceData:GetFaceStyleItemIsUnlocked(faceId)
  if 0 < faceId then
    local row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(faceId)
    if row and 0 < #row.Unlock then
      if self.FaceState == E.FaceDataState.Create then
        return false
      else
        return Z.ContainerMgr.CharSerialize.roleFace.unlockItemMap[faceId]
      end
    end
  end
  return true
end

function FaceData:GetPlayerGender()
  if Z.StageMgr.GetIsInLogin() then
    return self.Gender
  else
    return Z.ContainerMgr.CharSerialize.charBase.gender
  end
end

function FaceData:GetPlayerModelId()
  if Z.StageMgr.GetIsInLogin() then
    return self.ModelId
  else
    return Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  end
end

function FaceData:GetPlayerBodySize()
  if Z.StageMgr.GetIsInLogin() then
    return self.BodySize
  else
    return Z.ContainerMgr.CharSerialize.charBase.bodySize
  end
end

function FaceData:GetBindBeard(faceShapeId, typeId)
  if self.beardDict_[faceShapeId] and self.beardDict_[faceShapeId][typeId] then
    return self.beardDict_[faceShapeId][typeId]
  end
  return 0
end

function FaceData:initBeardDict()
  self.beardDict_ = {}
  local allRow = Z.TableMgr.GetTable("FaceTableMgr").GetDatas()
  for faceId, row in pairs(allRow) do
    if row.Type == Z.PbEnum("EFaceDataType", "BeardID") and row.FaceShapeId > 0 then
      if not self.beardDict_[row.FaceShapeId] then
        self.beardDict_[row.FaceShapeId] = {}
      end
      self.beardDict_[row.FaceShapeId][row.Number] = faceId
    end
  end
end

function FaceData:SetCacheHeightSliderValue(value)
  self.cacheHeightSliderValue = value
end

function FaceData:GetCacheHeightSliderValue()
  return self.cacheHeightSliderValue
end

function FaceData:SetCacheHeightShoeValue(value)
  self.cacheHeightShoeValue = value
end

function FaceData:GetCacheHeightShoeValue()
  return self.cacheHeightShoeValue
end

function FaceData:RecordFaceEditorCommand(command)
  for i = #self.faceEditorOperationList_, self.faceEditorOperationIndex_ + 1, -1 do
    table.remove(self.faceEditorOperationList_, i)
  end
  table.insert(self.faceEditorOperationList_, command)
  if #self.faceEditorOperationList_ > 10 then
    table.remove(self.faceEditorOperationList_, 1)
  end
  self.faceEditorOperationIndex_ = #self.faceEditorOperationList_
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshOperationBtnState)
end

function FaceData:RecordEditorValue(optionEnum, targetValue)
  local curCommand = self.faceEditorOperationList_[self.faceEditorOperationIndex_]
  if curCommand then
    local option = self.FaceOptionDict[optionEnum]
    local sourceValue = option:GetValue()
    if sourceValue and type(sourceValue) == "table" then
      for k, v in pairs(sourceValue) do
        if not targetValue[k] then
          targetValue[k] = v
        end
      end
    end
    if not option or option:IsEqualTo(targetValue) then
      return
    end
    curCommand:AddChangeData(optionEnum, sourceValue, targetValue)
  end
end

function FaceData:MoveEditorOperation()
  if self.faceEditorOperationIndex_ + 1 > #self.faceEditorOperationList_ then
    return
  end
  self.faceEditorOperationIndex_ = self.faceEditorOperationIndex_ + 1
  local curCommand = self.faceEditorOperationList_[self.faceEditorOperationIndex_]
  if curCommand then
    curCommand:Do()
    Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView, curCommand:GetHotId())
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshOperationBtnState)
end

function FaceData:ReturnEditorOperation()
  if self.faceEditorOperationIndex_ == 0 then
    return
  end
  local curCommand = self.faceEditorOperationList_[self.faceEditorOperationIndex_]
  if curCommand then
    curCommand:Undo()
  end
  self.faceEditorOperationIndex_ = self.faceEditorOperationIndex_ - 1
  local hotId
  if self.faceEditorOperationIndex_ > 0 and self.faceEditorOperationList_[self.faceEditorOperationIndex_] then
    hotId = self.faceEditorOperationList_[self.faceEditorOperationIndex_]:GetHotId()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView, hotId)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshOperationBtnState)
end

function FaceData:GetCurCommand()
  if self.faceEditorOperationIndex_ == 0 or self.faceEditorOperationIndex_ > #self.faceEditorOperationList_ then
    return
  end
  return self.faceEditorOperationList_[self.faceEditorOperationIndex_]
end

function FaceData:IsShowMoveOperation()
  return self.faceEditorOperationIndex_ < #self.faceEditorOperationList_
end

function FaceData:IsShowReturnOperation()
  return self.faceEditorOperationIndex_ > 0
end

function FaceData:ResetFaceEditorList()
  self.faceEditorOperationIndex_ = 0
  self.faceEditorOperationList_ = {}
  self.copyColorHtml_ = nil
end

function FaceData:SetCopyColorHtml(html)
  self.copyColorHtml_ = html
end

function FaceData:GetCopyColorHtml()
  return self.copyColorHtml_
end

return FaceData
