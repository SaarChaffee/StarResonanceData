local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_develop_make_subView = class("Weapon_develop_make_subView", super)
local loopListView = require("ui.component.loop_list_view")
local common_reward_loop_list_item = require("ui.component.common_reward_loop_list_item")
local itemBinder = require("common.item_binder")
local bagRed = require("rednode.bag_red")

function Weapon_develop_make_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_make_sub", "weapon_develop/weapon_develop_make_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.resonancePowerVM_ = Z.VMMgr.GetVM("resonance_power")
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.itemTraceVM_ = Z.VMMgr.GetVM("item_trace")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Weapon_develop_make_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self.parent_:RefreshListView(true, function(dataList)
    return self:getListSelectIndex(dataList)
  end)
end

function Weapon_develop_make_subView:OnDeActive()
  self:unInitLoopListView()
  self:unLoadMakeRedDotItem()
  self:closeSourceTips()
end

function Weapon_develop_make_subView:OnRefresh()
end

function Weapon_develop_make_subView:initData()
  self.consumeList_ = {}
  self.targetCreateData_ = {configId = -1, count = 1}
  if self.parent_.viewData and self.parent_.viewData.MakeParam then
    self.targetCreateData_.configId = self.parent_.viewData.MakeParam.configId
    self.targetCreateData_.count = self.parent_.viewData.MakeParam.count
    self.parent_.viewData.MakeParam = nil
  end
  self.maxCreateCount_ = 0
  self.canCreate_ = false
  self.createNotEnoughItem_ = nil
end

function Weapon_develop_make_subView:initComponent()
  self:initLoopListView()
  self:AddAsyncClick(self.uiBinder.btn_make, function()
    self:startCreate()
  end)
  self:AddClick(self.uiBinder.binder_num_module.btn_add, function()
    if self.targetCreateData_.count + 1 > self.maxCreateCount_ then
      Z.TipsVM.ShowTips(150103)
      local notEnoughItem_ = self.resonancePowerVM_.GetNotEnoughItemByCount(self.targetCreateData_.configId, self.targetCreateData_.count + 1)
      if notEnoughItem_ then
        self:closeSourceTips()
        self.sourceTipId_ = Z.TipsVM.OpenSourceTips(notEnoughItem_, self.uiBinder.tips_root)
      end
    end
    local count_ = math.min(self.targetCreateData_.count + 1, self.maxCreateCount_)
    self:setCreateCount(count_)
    self:refreshCreateRightInfo()
  end)
  self:AddClick(self.uiBinder.binder_num_module.btn_reduce, function()
    local count_ = self.targetCreateData_.count - 1
    if count_ < 0 then
      count_ = 0
    end
    self:setCreateCount(count_)
    self:refreshCreateRightInfo()
  end)
  self:AddClick(self.uiBinder.binder_num_module.btn_max, function()
    local count_ = self.maxCreateCount_
    self:setCreateCount(count_)
    self:refreshCreateRightInfo()
  end)
  self.uiBinder.binder_num_module.slider_temp:AddListener(function()
    self.targetCreateData_.count = math.floor(self.uiBinder.binder_num_module.slider_temp.value)
    self:refreshCreateRightInfo()
  end)
  self:AddClick(self.uiBinder.btn_material_tracking, function()
    self.itemTraceVM_.ShowTraceView(self.targetCreateData_.configId, self.consumeList_)
  end)
end

function Weapon_develop_make_subView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, common_reward_loop_list_item, "com_item_square_1_8", true)
  self.loopListView_:Init({})
end

function Weapon_develop_make_subView:refreshLoopListView(dataList)
  self.loopListView_:RefreshListView(dataList, true)
end

function Weapon_develop_make_subView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Weapon_develop_make_subView:closeSourceTips()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
end

function Weapon_develop_make_subView:getListSelectIndex(dataList)
  if self.targetCreateData_ and self.targetCreateData_.configId ~= -1 then
    for k, v in ipairs(dataList) do
      if v == self.targetCreateData_.configId then
        return k
      end
    end
  end
  return nil
end

function Weapon_develop_make_subView:startCreate()
  if not self.canCreate_ then
    Z.TipsVM.ShowTips(150104)
    if self.createNotEnoughItem_ then
      self:closeSourceTips()
      self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.createNotEnoughItem_, self.uiBinder.tips_root)
    end
    return
  end
  if self.targetCreateData_.configId == -1 then
    return
  end
  local aoyiItemConfig = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(self.targetCreateData_.configId)
  if aoyiItemConfig == nil then
    return
  end
  local isActivate = self.weaponSkillVM_:CheckSkillUnlock(aoyiItemConfig.SkillId)
  if isActivate then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ResonanceHaveCreateTips_2"), function()
      self:realCreateItem()
    end, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ResonanceItemDecompose2)
  elseif self.itemsVM_.GetItemTotalCount(self.targetCreateData_.configId) > 0 then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ResonanceHaveCreateTips_1"), function()
      self:realCreateItem()
    end, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ResonanceItemDecompose1)
  else
    self:realCreateItem()
  end
end

function Weapon_develop_make_subView:realCreateItem()
  local token = self.cancelSource:CreateToken()
  local reply = self.resonancePowerVM_.ReqCreateResonancePower(self.targetCreateData_.configId, self.targetCreateData_.count, token)
  if reply then
    self.parent_:RefreshListView(true)
  end
end

function Weapon_develop_make_subView:refreshCreateRightItemList()
  local costList = self.resonancePowerVM_.GetCreateConsumeAward(self.targetCreateData_.configId, self.targetCreateData_.count)
  self.consumeList_ = {}
  for i, v in ipairs(costList) do
    self.consumeList_[i] = {
      ItemId = v.ItemId,
      ItemNum = v.Num,
      LabType = E.ItemLabType.Expend
    }
  end
  self:refreshLoopListView(costList)
end

function Weapon_develop_make_subView:refreshCreateRightInfo()
  if self.targetCreateData_.configId == -1 then
    return
  end
  local itemConfig = self.itemTableMgr_.GetRow(self.targetCreateData_.configId)
  local aoyiItemConfig = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(self.targetCreateData_.configId)
  local aoyiConfig = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(aoyiItemConfig.SkillId)
  if itemConfig and aoyiConfig then
    self.uiBinder.rimg_icon:SetImage(aoyiConfig.ArtPreview)
    self.uiBinder.lab_name.text = itemConfig.Name
    self:refreshSkillInfo(aoyiConfig, aoyiItemConfig.SkillId)
  end
  self.uiBinder.binder_num_module.lab_num.text = self.targetCreateData_.count
  self.uiBinder.binder_num_module.slider_temp.value = self.targetCreateData_.count
  self.uiBinder.btn_make.IsDisabled = not self.canCreate_
  self:SetUIVisible(self.uiBinder.btn_material_tracking, not self.canCreate_)
  self:refreshCreateRightItemList()
end

function Weapon_develop_make_subView:refreshSkillInfo(config, skillId)
  local skillConfig = Z.TableMgr.GetRow("SkillTableMgr", skillId)
  if skillConfig == nil then
    return
  end
  self.uiBinder.lab_skill_name.text = Lang("ResonanceSkillName", {
    name = skillConfig.Name
  })
  local typeLabelList = {}
  for i, type in ipairs(config.ShowSkillType) do
    typeLabelList[i] = Lang("ShowSkillType_" .. type)
  end
  local skillTypeLabel = table.concat(typeLabelList, Lang("Comma"))
  self.uiBinder.lab_skill_type.text = Lang("ResonanceSkillTypeExtra", {type = skillTypeLabel})
  local content = self.weaponSkillVM_:ParseResonanceSkillBaseDesc(skillId)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_normal_effect_desc, content)
  local attrDescList, buffDescList = self.weaponSkillVM_:ParseResonanceSkillDesc(skillId, 0, true)
  local resultDescList = {}
  for i, info in ipairs(attrDescList) do
    table.insert(resultDescList, info.desc)
    table.insert(resultDescList, "\n")
  end
  for i, info in ipairs(buffDescList) do
    table.insert(resultDescList, info.desc)
    table.insert(resultDescList, "\n")
  end
  local isSpecialEffectEmpty = #resultDescList == 0
  if not isSpecialEffectEmpty then
    local content = table.concat(resultDescList)
    Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_special_effect_desc, content)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_special_effect_title, not isSpecialEffectEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_special_effect_desc, not isSpecialEffectEmpty)
end

function Weapon_develop_make_subView:setCreateCount(count)
  self.uiBinder.binder_num_module.slider_temp.value = count
end

function Weapon_develop_make_subView:loadMakeRedDotItem(itemId)
  self:unLoadMakeRedDotItem()
  self.redDotId_ = bagRed.GetResonanceMakeRedId(itemId)
  Z.RedPointMgr.LoadRedDotItem(self.redDotId_, self, self.uiBinder.btn_make.transform)
end

function Weapon_develop_make_subView:unLoadMakeRedDotItem()
  if self.redDotId_ then
    Z.RedPointMgr.RemoveNodeItem(self.redDotId_)
    self.redDotId_ = nil
  end
end

function Weapon_develop_make_subView:OnSelectResonancePowerItemCreate(configId)
  self.targetCreateData_.configId = configId
  self:setCreateCount(1)
  self.maxCreateCount_, self.canCreate_, self.createNotEnoughItem_ = self.resonancePowerVM_.GetMaxCreateCount(configId)
  self.uiBinder.binder_num_module.slider_temp.maxValue = self.maxCreateCount_
  self.uiBinder.binder_num_module.slider_temp.minValue = 1
  self:refreshCreateRightInfo()
  self:loadMakeRedDotItem(configId)
end

function Weapon_develop_make_subView:OnItemChanged()
  self.parent_:RefreshListView(true, function(dataList)
    return self:getListSelectIndex(dataList)
  end)
end

return Weapon_develop_make_subView
