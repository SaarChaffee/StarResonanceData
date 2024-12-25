local super = require("ui.model.data_base")
local PubMixologyData = class("Proficiency", super)
local type = {MultiSelect = 1, SingleSelection = 2}
local MAX_INGREDIENT_COUNT = 4

function PubMixologyData:ctor()
  super.ctor(self)
end

function PubMixologyData:Init()
  self.ShakerMaximum = 6
  self.FlowId = 0
  self:InitSelectCount()
  self.FlowIndex = 0
  self.MaxFlowIndex = 3
  self.selectMadeId = 0
  self.FailCount = 0
  self.CancelSource = Z.CancelSource.Rent()
  self:InitCfgData()
end

function PubMixologyData:InitCfgData()
  self.CocktailRecipeTableDatas = Z.TableMgr.GetTable("CocktailRecipeTableMgr").GetDatas()
  self.RecipeTableDatas = Z.TableMgr.GetTable("RecipeTableMgr").GetDatas()
end

function PubMixologyData:OnLanguageChange()
  self:InitCfgData()
end

function PubMixologyData:UnInit()
  self.CancelSource:Recycle()
end

function PubMixologyData:InitSelectCount()
  self.SelectCount = 0
  self.SelectPubData = {}
  self.SelectPubuDataQueue = {}
  self.SelectIngeredientCount = 0
  self.selectMadeId = 0
end

function PubMixologyData:GetSelectData()
  return self.SelectPubData
end

function PubMixologyData:GetSelectIngeredientCount()
  return self.SelectIngeredientCount
end

function PubMixologyData:GetSelectMadeID()
  return self.selectMadeId
end

function PubMixologyData:SelectBurdening(burdeningData)
  if burdeningData.RecipeType == type.MultiSelect then
    if self.SelectIngeredientCount >= MAX_INGREDIENT_COUNT then
      return false
    end
    self.SelectIngeredientCount = self.SelectIngeredientCount + 1
    if self.SelectPubData[burdeningData.Id] then
      self.SelectPubData[burdeningData.Id] = self.SelectPubData[burdeningData.Id] + 1
      table.insert(self.SelectPubuDataQueue, burdeningData)
      return true
    else
      self.SelectPubData[burdeningData.Id] = 1
      table.insert(self.SelectPubuDataQueue, burdeningData)
    end
  else
    if self.selectMadeId > 0 then
      return false
    end
    self.selectMadeId = burdeningData.Id
    self.SelectPubData[burdeningData.Id] = 1
    table.insert(self.SelectPubuDataQueue, burdeningData)
  end
  return true
end

function PubMixologyData:RemoveBring(burdeningData)
  for index, value in ipairs(self.SelectPubuDataQueue) do
    if value.Id == burdeningData.Id then
      table.remove(self.SelectPubuDataQueue, index)
      break
    end
  end
  if self.SelectPubData[burdeningData.Id] then
    self.SelectPubData[burdeningData.Id] = self.SelectPubData[burdeningData.Id] - 1
    if burdeningData.RecipeType == type.MultiSelect then
      self.SelectIngeredientCount = self.SelectIngeredientCount - 1
    end
    if self.SelectPubData[burdeningData.Id] == 0 then
      self.SelectPubData[burdeningData.Id] = nil
    end
  end
  if self.selectMadeId == burdeningData.Id then
    self.selectMadeId = 0
  end
end

function PubMixologyData:PlayMixologyFlow()
  self.FlowIndex = self.FlowIndex + 1
  if self.FlowIndex > self.MaxFlowIndex then
    self.FlowIndex = 1
  end
end

function PubMixologyData:QuitMixology()
  self.FlowIndex = self.FlowIndex - 1
end

function PubMixologyData:SetFlowId(flowId)
  self.FlowId = flowId
end

return PubMixologyData
