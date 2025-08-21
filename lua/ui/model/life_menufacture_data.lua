local super = require("ui.model.data_base")
local LifeMenufactureData = class("LifeMenufactureData", super)

function LifeMenufactureData:ctor()
end

function LifeMenufactureData:Init()
  self.menufactureProductDatas = {}
  self.menufactureInited = false
end

function LifeMenufactureData:Clear()
  self.menufactureProductDatas = {}
  self.menufactureInited = false
end

function LifeMenufactureData:UnInit()
  self.menufactureProductDatas = {}
  self.menufactureInited = false
end

function LifeMenufactureData:OnLanguageChange()
  self.productionDatas = nil
end

function LifeMenufactureData:GetALLProductionDatas()
  if not self.productionDatas then
    self.productionDatas = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetDatas()
  end
  return self.productionDatas
end

function LifeMenufactureData:GetProductionDatas()
  if not self.productionDatas then
    self.productionDatas = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetDatas()
  end
  if not self.menufactureInited then
    self:InitProductData()
    self.menufactureInited = true
  end
  return self.menufactureProductDatas
end

function LifeMenufactureData:InitProductData()
  self.menufactureProductDatas = {}
  for k, v in pairs(self.productionDatas) do
    local lifeProductionListTableRow = v
    if lifeProductionListTableRow.ParentId ~= 0 then
      local parentTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(lifeProductionListTableRow.ParentId)
      if parentTableRow == nil then
        logError("[LifeProfession] Invalid ParentId " .. lifeProductionListTableRow.Id)
        return
      end
      self:SetParentProduct(lifeProductionListTableRow.ParentId, lifeProductionListTableRow.Id)
    else
      local productData, index = self:GetMenufactureProductDataById(lifeProductionListTableRow.Id)
      if productData == nil then
        local menufactureProductData = {}
        menufactureProductData.productId = lifeProductionListTableRow.Id
        menufactureProductData.subProductList = {}
        menufactureProductData.curSelectProduct = nil
        menufactureProductData.lifeType = E.ELifeProfessionMainType.Manufacture
        table.insert(self.menufactureProductDatas, menufactureProductData)
      end
    end
  end
end

function LifeMenufactureData:GetMenufactureProductDataById(productID)
  if not self.menufactureProductDatas then
    return nil, nil
  end
  for k, v in pairs(self.menufactureProductDatas) do
    if v.productId == productID then
      return v, k
    end
  end
  return nil, nil
end

function LifeMenufactureData:SetParentProduct(parentId, Id)
  local productData, index = self:GetMenufactureProductDataById(parentId)
  if productData == nil then
    local menufactureProductData = {}
    menufactureProductData.productId = parentId
    menufactureProductData.subProductList = {Id}
    menufactureProductData.curSelectProduct = Id
    menufactureProductData.curSelectProductIndex = 1
    menufactureProductData.lifeType = E.ELifeProfessionMainType.Manufacture
    table.insert(self.menufactureProductDatas, menufactureProductData)
  else
    table.insert(productData.subProductList, Id)
    table.sort(productData.subProductList, function(a, b)
      return a < b
    end)
    productData.curSelectProductIndex = 1
    productData.curSelectProduct = productData.subProductList[1]
    self.menufactureProductDatas[index] = productData
  end
end

function LifeMenufactureData:SetSubProduct(productID, subId, formulaIndex)
  local productData, index = self:GetMenufactureProductDataById(productID)
  if productData == nil then
    return
  end
  productData.curSelectProductIndex = formulaIndex
  productData.curSelectProduct = subId
  self.menufactureProductDatas[index] = productData
  Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionSubFormulaChanged)
end

function LifeMenufactureData:GetCurSelectProductID(productID)
  local productData, index = self:GetMenufactureProductDataById(productID)
  if not productData then
    return productID
  end
  if productData.curSelectProduct then
    return productData.curSelectProduct
  end
  return productID
end

function LifeMenufactureData:ResetSelectProductions(showLock)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self:GetProductionDatas()
  for k, v in pairs(self.menufactureProductDatas) do
    if #v.subProductList > 0 then
      if showLock then
        v.curSelectProductIndex = 1
        v.curSelectProduct = v.subProductList[1]
      else
        for index, subProductId in pairs(v.subProductList) do
          local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(subProductId)
          if not lifeProductionListTableRow then
            return
          end
          local unlocked = lifeProfessionVM.IsProductUnlocked(lifeProductionListTableRow.LifeProId, lifeProductionListTableRow.Id)
          if unlocked then
            v.curSelectProductIndex = index
            v.curSelectProduct = subProductId
            break
          end
        end
      end
    end
  end
end

return LifeMenufactureData
