local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_develop_function_subView = class("Weapon_develop_function_subView", super)
local itemClass = require("common.item")

function Weapon_develop_function_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_function_sub", "weapon_develop/weapon_develop_function_sub", UI.ECacheLv.None)
end

function Weapon_develop_function_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.buffAttrParseVM_ = Z.VMMgr.GetVM("buff_attr_parse")
  self:AddAsyncClick(self.uiBinder.btn_activation, function()
    local nodeConfig = Z.TableMgr.GetTable("WeaponStarTableMgr").GetRow(self.nodeId_)
    if nodeConfig == nil then
      return
    end
    if Z.ConditionHelper.CheckCondition(nodeConfig.UlockSkillLevel, true) then
      if self.matEnough_ == false then
        local coinConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
        if coinConfig then
          local param = {
            val = coinConfig.Name
          }
          Z.TipsVM.ShowTipsLang(130019, param)
        end
        return
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SkillNodeActive, self.nodeId_)
      self.weaponVm_.AsyncWeaponSkillNodeActive(self.nodeId_, self.cancelSource:CreateToken())
    end
  end)
  self.itemClassTab_ = {}
  self:BindEvents()
end

function Weapon_develop_function_subView:BindEvents()
  function self.onContainerChanged()
    self:refreshInfo()
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
end

function Weapon_develop_function_subView:refreshInfo()
  self:ClearAllUnits()
  self.matEnough_ = true
  self.notEnoughItem_ = nil
  local nodeConfig = Z.TableMgr.GetTable("WeaponStarTableMgr").GetRow(self.nodeId_)
  if nodeConfig == nil then
    return
  end
  self.uiBinder.lab_title.text = nodeConfig.Name
  if nodeConfig.ChangeSkill and nodeConfig.ChangeSkill ~= 0 then
    local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(nodeConfig.ChangeSkill)
    if config ~= nil then
      Z.RichTextHelper.SetBinderTmpLabTextWithCommonLink(self.uiBinder.lab_content, Z.TableMgr.DecodeLineBreak(config.Desc))
    end
  else
    local buffDesc = ""
    if nodeConfig.BuffID and nodeConfig.BuffID ~= 0 then
      local param = {}
      for index, value in ipairs(nodeConfig.BuffPar) do
        param[index] = {value}
      end
      buffDesc = Z.TableMgr.DecodeLineBreak(self.buffAttrParseVM_.ParseBufferTips(nodeConfig.BuffID, param))
    end
    local content = Z.TableMgr.DecodeLineBreak(nodeConfig.Des)
    content = content .. "\n" .. buffDesc
    self.uiBinder.lab_content.text = content
  end
  if self.weaponVm_.CheckWeaponSkillNodeActive(self.weaponId_, self.nodeId_) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_activation, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_activation, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_activation, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_activation, true)
    local items = {}
    for _, value in ipairs(nodeConfig.UpgradeCost) do
      local item = {}
      item.itemId = value[1]
      item.itemCount = value[2]
      table.insert(items, item)
    end
    local weaponConfig = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(nodeConfig.WeaponId)
    if weaponConfig == nil then
      return
    end
    for _, value in ipairs(nodeConfig.UpgradeExtraCost) do
      local item = {}
      item.itemId = weaponConfig.ProfessionStarExtraItem[value[1]][1]
      item.itemCount = value[2]
      table.insert(items, item)
    end
    local parent = self.uiBinder.group_item
    Z.CoroUtil.create_coro_xpcall(function()
      for _, value in ipairs(items) do
        local totalCount = self.itemVm_.GetItemTotalCount(value.itemId)
        local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Backpack.Item_Unit_Addr), value.itemId, parent)
        self.itemClassTab_[value.itemId] = itemClass.new(self)
        local itemClassData = {
          unit = unit,
          configId = value.itemId,
          isShowZero = true,
          lab = totalCount,
          expendCount = value.itemCount,
          labType = E.ItemLabType.Expend
        }
        if totalCount < value.itemCount then
          self.matEnough_ = false
          if not self.notEnoughItem_ then
            self.notEnoughItem_ = value.itemId
          end
        end
        self.itemClassTab_[value.itemId]:Init(itemClassData)
      end
      local btnDisable = self.matEnough_
      local conditionEnough = Z.ConditionHelper.CheckCondition(nodeConfig.UlockSkillLevel, false)
      if not conditionEnough then
        local lv = nodeConfig.UlockSkillLevel[1][3]
        local name = ""
        local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(nodeConfig.UlockSkillLevel[1][2])
        if skillConfig then
          name = skillConfig.Name
        end
        self.uiBinder.btn_activation_binder.lab_content.text = name .. string.format(Lang("active_lv_tips"), lv)
      else
        self.uiBinder.btn_activation_binder.lab_content.text = Lang("ensure_active")
      end
      self.uiBinder.btn_activation.IsDisabled = not self.matEnough_ or not btnDisable
    end)()
  end
end

function Weapon_develop_function_subView:OnDeActive()
  Z.CommonTipsVM.CloseRichText()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
  self.onContainerChanged = nil
  self.matEnough_ = true
  self.notEnoughItem_ = nil
end

function Weapon_develop_function_subView:OnRefresh()
  self.nodeId_ = self.viewData.nodeId
  self.weaponId_ = self.viewData.weaponId
  self:refreshInfo()
end

return Weapon_develop_function_subView
