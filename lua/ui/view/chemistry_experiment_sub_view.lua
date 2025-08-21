local UI = Z.UI
local super = require("ui.ui_subview_base")
local Chemistry_experiment_subView = class("Chemistry_experiment_subView", super)
local loopGridView = require("ui/component/loop_grid_view")
local chemistryExperimentLoopItem = require("ui.component.chemistry.chemistry_experiment_loop_item")
local itemBinder = require("common.item_binder")
local chemistryDefine = require("ui.model.chemistry_define")

function Chemistry_experiment_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "chemistry_experiment_sub", "chemistry/chemistry_experiment_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "chemistry_experiment_sub", "chemistry/chemistry_experiment_sub", UI.ECacheLv.None)
  end
  self.selectItemBinder_ = itemBinder.new(self)
  self.selectData_ = nil
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.chemistryData_ = Z.DataMgr.Get("chemistry_data")
end

function Chemistry_experiment_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_root)
  self.uiBinder.effect_root:SetEffectGoVisible(false)
  self:AddAsyncClick(self.uiBinder.btn_icon, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
    end
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.rect_icon, Z.SystemItem.VigourItemId)
  end)
  self:AddAsyncClick(self.uiBinder.btn_chemistry, function()
    if self.selectData_ == nil then
      Z.TipsVM.ShowTipsLang(1002051)
    elseif Z.Global.ChemistryExperimentTriesLimit[1] - Z.ContainerMgr.CharSerialize.lifeProfession.lifeProfessionAlchemyInfo.rdCount <= 0 then
      Z.TipsVM.ShowTipsLang(1002054)
    elseif self.itemVm_.GetItemTotalCount(Z.SystemItem.VigourItemId) < Z.Global.ChemistryExperimentCraftEnergyConsume[1] then
      Z.TipsVM.ShowTipsLang(1002057)
    else
      self.lifeProfessionVM_.AsyncRequestLifeProfessionRDAlchemy(self.selectData_.configId, self.cancelSource:CreateToken())
      self.uiBinder.effect_root:SetEffectGoVisible(true)
      self.uiBinder.effect_root:Play()
      self:chemstryExperimentRefresh()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_open, function()
    if self.selectData_ == nil then
    else
      Z.UIMgr:OpenView("chemistry_recipe_popup", self.selectData_.configId)
    end
  end)
  self:AddAsyncClick(self.uiBinder.select_item.btn_temp, function()
    if self.selectData_ then
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.select_item.Trans, self.selectData_.configId)
    end
  end)
  if Z.IsPCUI then
    self.itemsExperimentGridView_ = loopGridView.new(self, self.uiBinder.loop_experiment_item, chemistryExperimentLoopItem, "chemistry_item_long_tpl_pc")
  else
    self.itemsExperimentGridView_ = loopGridView.new(self, self.uiBinder.loop_experiment_item, chemistryExperimentLoopItem, "chemistry_item_long_tpl")
  end
  self.itemsExperimentGridView_:Init({})
  self.uiBinder.lab_num.text = Z.Global.ChemistryExperimentCraftEnergyConsume[1]
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(Z.SystemItem.VigourItemId)
  if itemConfig then
    self.uiBinder.rimg_icon:SetImage(itemConfig.Icon)
  end
  self.selectData_ = nil
  self:chemstryExperimentRefresh()
end

function Chemistry_experiment_subView:OnDeActive()
  self.itemsExperimentGridView_:UnInit()
  self.itemsExperimentGridView_ = nil
  self.selectItemBinder_:UnInit()
  self.selectData_ = nil
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.tipsId_ = nil
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_root)
  self.uiBinder.effect_root:SetEffectGoVisible(false)
end

function Chemistry_experiment_subView:OnRefresh()
end

function Chemistry_experiment_subView:chemstryExperimentRefresh()
  local count = Z.Global.ChemistryExperimentTriesLimit[1] - Z.ContainerMgr.CharSerialize.lifeProfession.lifeProfessionAlchemyInfo.rdCount
  self.uiBinder.lab_tips.text = Lang("TodaysurpluseTestCount", {val = count})
  self:refreshLoop()
  self:refreshExperiment()
end

function Chemistry_experiment_subView:refreshLoop()
  local allMainMaterials = self.chemistryData_:GetMaterialByType(chemistryDefine.MaterialType.Main)
  local unlockItems = {}
  local unlockItemsCount = 0
  local items = {}
  local itemsCount = 0
  for _, config in ipairs(allMainMaterials) do
    local package = self.itemVm_.GetPackageInfobyItemId(config.Id)
    local itemUuids = self.itemsData_:GetItemUuidsByConfigId(config.Id)
    if itemUuids ~= nil and 1 <= #itemUuids then
      local condition = true
      if config.UseCondition and next(config.UseCondition) then
        condition, _, _ = Z.ConditionHelper.GetSingleConditionDesc(config.UseCondition[1], config.UseCondition[2], config.UseCondition[3])
      end
      for _, itemUuid in ipairs(itemUuids) do
        local item = package.items[itemUuid]
        if item and 0 < item.count then
          if condition then
            itemsCount = itemsCount + 1
            items[itemsCount] = {
              itemUuid = itemUuid,
              configId = config.Id,
              itemInfo = item,
              condition = condition,
              config = config
            }
          else
            unlockItemsCount = unlockItemsCount + 1
            unlockItems[unlockItemsCount] = {
              itemUuid = itemUuid,
              configId = config.Id,
              itemInfo = item,
              condition = condition,
              config = config
            }
          end
        end
      end
    end
  end
  for _, item in ipairs(unlockItems) do
    itemsCount = itemsCount + 1
    items[itemsCount] = item
  end
  if 0 < itemsCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_experiment_item, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, false)
    self.itemsExperimentGridView_:RefreshListView(items)
    self.itemsExperimentGridView_:ClearAllSelect()
    if self.selectData_ ~= nil then
      local selectIndex = -1
      for index, data in ipairs(items) do
        if data.configId == self.selectData_.configId then
          selectIndex = index
          break
        end
      end
      if selectIndex == -1 then
        self.selectData_ = nil
      else
        self.itemsExperimentGridView_:SetSelected(selectIndex)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_experiment_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, true)
    self.selectData_ = nil
  end
end

function Chemistry_experiment_subView:refreshExperiment()
  if self.selectData_ == nil then
    self.uiBinder.select_item.Ref.UIComp:SetVisible(false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_ask, true)
    self.uiBinder.img_exp_ask:SetImage("ui/atlas/chemistry/chemistry_icon_ask_off")
    self.uiBinder.ring_adorn:SetImage("ui/textures/chemistry/chemistry_empty")
  else
    self.uiBinder.select_item.Ref.UIComp:SetVisible(true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_ask, false)
    self.uiBinder.img_exp_ask:SetImage("ui/atlas/chemistry/chemistry_icon_ask_on")
    self.uiBinder.ring_adorn:SetImage("ui/textures/chemistry/chemistry_ing")
    self.selectItemBinder_:InitCircleItem(self.uiBinder.select_item, self.selectData_.configId, self.selectData_.itemUuid)
  end
end

function Chemistry_experiment_subView:SetSelectItem(data)
  if data.condition then
    if self.selectData_ ~= nil and self.selectData_.itemUuid == data.itemUuid and self.selectData_.configId == data.configId then
      return
    end
    self.selectData_ = data
    self:refreshExperiment()
  else
    self.itemsExperimentGridView_:ClearAllSelect()
    Z.ConditionHelper.CheckCondition({
      data.config.UseCondition
    }, true)
    local datas = self.itemsExperimentGridView_:GetData()
    for key, value in ipairs(datas) do
      if self.selectData_ ~= nil and self.selectData_.itemUuid == value.itemUuid and self.selectData_.configId == value.configId then
        self.itemsExperimentGridView_:SetSelected(key)
        return
      end
    end
  end
end

return Chemistry_experiment_subView
