local super = require("ui.model.data_base")
local FunctionPreviewData = class("FunctionPreviewData", super)
E.FuncPreviewAwardState = {
  CanGet = 1,
  CantGet = 2,
  Complete = 3
}

function FunctionPreviewData:ctor()
  super.ctor(self)
  self.switchData_ = Z.DataMgr.Get("switch_data")
end

function FunctionPreviewData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self:refreshStateDict()
end

function FunctionPreviewData:refreshStateDict()
  self.FuncRewardDict = {}
  local funcDatas = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetDatas()
  local switchVM = Z.VMMgr.GetVM("switch")
  for k, v in pairs(funcDatas) do
    local open = switchVM.CheckFuncSwitch(v.Id)
    if open then
      self.FuncRewardDict[v.Id] = E.FuncPreviewAwardState.CanGet
    else
      self.FuncRewardDict[v.Id] = E.FuncPreviewAwardState.CantGet
    end
  end
  local ids = Z.ContainerMgr.CharSerialize.FunctionData.drawnFunctionIds
  if ids then
    for k, v in pairs(ids) do
      self.FuncRewardDict[v] = E.FuncPreviewAwardState.Complete
    end
  end
  local sevendaysRed_ = require("rednode.sevendays_target_red")
  sevendaysRed_.InitOrRefreshFuncPreviewRed()
end

function FunctionPreviewData:GetStateDict()
  if self.FuncRewardDict == nil then
    self:refreshStateDict()
  end
  return self.FuncRewardDict
end

function FunctionPreviewData:CheckNeedPreview(funcId)
  if self.FuncRewardDict == nil then
    self:refreshStateDict()
  end
  return self.FuncRewardDict[funcId] ~= nil
end

function FunctionPreviewData:GetFuncAwardState(funcId)
  if self.FuncRewardDict == nil then
    self:refreshStateDict()
  end
  if self.FuncRewardDict[funcId] ~= nil then
    return self.FuncRewardDict[funcId]
  end
  return E.FuncPreviewAwardState.CantGet
end

function FunctionPreviewData:ClearDict()
  self.FuncRewardDict = nil
end

function FunctionPreviewData:Clear()
  self:ClearDict()
end

function FunctionPreviewData:UnInit()
  self.CancelSource:Recycle()
  self:ClearDict()
end

return FunctionPreviewData
