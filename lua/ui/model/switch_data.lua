local super = require("ui.model.data_base")
local SwitchData = class("SwitchData", super)

function SwitchData:ctor()
  super.ctor(self)
end

function SwitchData:Init()
  super.Init(self)
  self.SwitchFunctionIdDic = {}
  self.ServerCloseFunctionIdDic = {}
  self.UserCloseFunctionIdDic = {}
  self.allFunctionArr_ = nil
  self.mainFunctionDic_ = nil
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function SwitchData:OnReconnect()
  super.OnReconnect(self)
end

function SwitchData:Clear()
  self.SwitchFunctionIdDic = {}
  self.ServerCloseFunctionIdDic = {}
  self.UserCloseFunctionIdDic = {}
  super.Clear(self)
end

function SwitchData:UnInit()
  super.UnInit(self)
  self.allFunctionArr_ = nil
  self.mainFunctionDic_ = nil
  self.SwitchFunctionIdDic = {}
  self.ServerCloseFunctionIdDic = {}
  self.UserCloseFunctionIdDic = {}
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function SwitchData:GetLockedFeature(onlyNeedPreview)
  if not self.allFunctionArr_ then
    self:initData()
  end
  if not self.allFunctionArr_ or not next(self.allFunctionArr_) then
    return nil
  end
  local data = {}
  for _, v in pairs(self.allFunctionArr_) do
    if v.OnOff == 0 and not self.SwitchFunctionIdDic[v.Id] then
      local previewData = Z.DataMgr.Get("function_preview_data")
      local isPreview = previewData:CheckNeedPreview(v.Id)
      if not onlyNeedPreview or onlyNeedPreview and isPreview then
        table.insert(data, v)
      end
    end
  end
  return data
end

function SwitchData:GetAllFeature(onlyNeedPreview)
  if not self.allFunctionArr_ then
    self:initData()
  end
  if not self.allFunctionArr_ or not next(self.allFunctionArr_) then
    return nil
  end
  local data = {}
  for _, v in pairs(self.allFunctionArr_) do
    if v.OnOff == 0 then
      local previewData = Z.DataMgr.Get("function_preview_data")
      local isPreview = previewData:CheckNeedPreview(v.Id)
      if not onlyNeedPreview or onlyNeedPreview and isPreview then
        table.insert(data, v)
      end
    end
  end
  return data
end

function SwitchData:IsMainFunction(id)
  if not self.allFunctionArr_ or not self.mainFunctionDic_ then
    self:initData()
  end
  local row = self.mainFunctionDic_[id]
  if row and (table.zcontains(row.SystemPlace, E.MainUIPlaceType.Esc) or table.zcontains(row.SystemPlace, E.MainUIPlaceType.EscRight)) then
    return true
  else
    return false
  end
end

function SwitchData:initData()
  self.allFunctionArr_ = {}
  local datas = Z.TableMgr.GetTable("FunctionTableMgr").GetDatas()
  for _, v in pairs(datas) do
    table.insert(self.allFunctionArr_, v)
  end
  local previewData = Z.DataMgr.Get("function_preview_data")
  table.sort(self.allFunctionArr_, function(a, b)
    local isPreviewA = previewData:CheckNeedPreview(a.Id)
    local isPreviewB = previewData:CheckNeedPreview(b.Id)
    if isPreviewA and isPreviewB then
      return a.Preview < b.Preview
    end
    if isPreviewA then
      return true
    end
    if isPreviewB then
      return false
    end
    return false
  end)
  self.mainFunctionDic_ = {}
  datas = Z.TableMgr.GetTable("MainIconTableMgr").GetDatas()
  for _, v in pairs(datas) do
    self.mainFunctionDic_[v.Id] = v
  end
end

function SwitchData:onLanguageChange()
  self.allFunctionArr_ = nil
  self.mainFunctionDic_ = nil
end

return SwitchData
