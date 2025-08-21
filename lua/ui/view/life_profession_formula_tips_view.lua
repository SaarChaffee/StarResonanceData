local UI = Z.UI
local super = require("ui.ui_view_base")
local Life_profession_formula_tipsView = class("Life_profession_formula_tipsView", super)
local loopListView = require("ui.component.loop_list_view")
local menufactureProductionItem = require("ui.component.life_profession.menufacture_production_item")

function Life_profession_formula_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "life_profession_formula_tips")
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.lifeMenufactureData_ = Z.DataMgr.Get("life_menufacture_data")
end

function Life_profession_formula_tipsView:OnActive()
  self.data_ = self.viewData.data
  self.posTrans = self.viewData.trans
  self.showLock = self.viewData.showLock
  self:refreshFormulaList()
  self.uiBinder.tips_auto:UpdatePosition(self.posTrans)
end

function Life_profession_formula_tipsView:refreshFormulaList()
  local preStr = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "item_tpl")
  self.unitsTable = {}
  for k, v in pairs(self.data_.subProductList) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v)
    if not lifeProductionListTableRow then
      return
    end
    local hideItem = not self.showLock and not self.lifeProfessionVM_.IsProductUnlocked(lifeProductionListTableRow.LifeProId, lifeProductionListTableRow.Id)
    if not hideItem then
      Z.CoroUtil.create_coro_xpcall(function()
        local subProductId = v
        local unit = self:AsyncLoadUiUnit(preStr, subProductId, self.uiBinder.lay_out)
        if not unit then
          return
        end
        self:refreshSingleFormula(unit, subProductId, self.data_.curSelectProduct, k)
        self.unitsTable[tostring(subProductId)] = unit
      end)()
    end
  end
end

function Life_profession_formula_tipsView:refreshSingleFormula(unit, subProductId, curSelectId, formulaIndex)
  local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(subProductId)
  if not lifeProductionListTableRow then
    return
  end
  local isProductionUnlocked = self.lifeProfessionVM_.IsProductUnlocked(lifeProductionListTableRow.LifeProId, lifeProductionListTableRow.Id)
  unit.Ref:SetVisible(unit.node_lock, not isProductionUnlocked)
  unit.Ref:SetVisible(unit.node_unlock, isProductionUnlocked)
  unit.Ref:SetVisible(unit.img_cur_lock, curSelectId == subProductId)
  unit.Ref:SetVisible(unit.img_cur_unlock, curSelectId == subProductId)
  unit.lab_formula_lock.text = Lang("LifeManufactureFormuaIndex" .. formulaIndex)
  unit.lab_formula_unlock.text = Lang("LifeManufactureFormuaIndex" .. formulaIndex)
  if Z.IsPCUI then
    unit.formulaViewLock = loopListView.new(self, unit.loop_list_item_lock, menufactureProductionItem, "com_item_square_1_8_pc")
    unit.formulaViewUnLock = loopListView.new(self, unit.loop_list_item_unlock, menufactureProductionItem, "com_item_square_1_8_pc")
  else
    unit.formulaViewLock = loopListView.new(self, unit.loop_list_item_lock, menufactureProductionItem, "com_item_square_1_8")
    unit.formulaViewUnLock = loopListView.new(self, unit.loop_list_item_unlock, menufactureProductionItem, "com_item_square_1_8")
  end
  local datas = self.lifeProfessionVM_.GetProductionMaterials(lifeProductionListTableRow)
  unit.formulaViewUnLock:Init(datas)
  unit.formulaViewLock:Init(datas)
  self:AddClick(unit.btn, function()
    self.lifeMenufactureData_:SetSubProduct(self.data_.productId, subProductId, formulaIndex)
    self.lifeProfessionVM_.CloseSwicthFormulaPopUp()
  end)
  self:AddClick(self.uiBinder.point_press_check.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.uiBinder.point_press_check:StopCheck()
      self.lifeProfessionVM_.CloseSwicthFormulaPopUp()
    end
  end)
  self.uiBinder.point_press_check:StartCheck()
end

function Life_profession_formula_tipsView:OnDeActive()
  for k, v in pairs(self.unitsTable) do
    v.formulaViewLock:UnInit()
    v.formulaViewUnLock:UnInit()
    self:RemoveUiUnit(k)
  end
end

function Life_profession_formula_tipsView:OnRefresh()
end

return Life_profession_formula_tipsView
