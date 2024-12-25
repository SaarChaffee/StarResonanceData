local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_vocational_refining_popupView = class("Equip_vocational_refining_popupView", super)

function Equip_vocational_refining_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "equip_vocational_refining_popup")
  self.equipSystemVm_ = Z.VMMgr.GetVM("equip_system")
  self.equipRefineVm_ = Z.VMMgr.GetVM("equip_refine")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Equip_vocational_refining_popupView:initBinders()
  self.icon_ = self.uiBinder.part_icon
  self.refiningLevleLab_ = self.uiBinder.lab_refining_level
  self.partNameLab_ = self.uiBinder.part_name
  self.equipLab_ = self.uiBinder.putequip_lab
  self.leftParent_ = self.uiBinder.left_togparent
  self.togGroup_ = self.uiBinder.left_toggroup
  self.closeBnt_ = self.uiBinder.close_btn
  self.baseAttrParent_ = self.uiBinder.node_basics_item
  self.specialParent_ = self.uiBinder.node_special_item
  self.sceneMask_ = self.uiBinder.scenemask
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Equip_vocational_refining_popupView:initBtns()
  self:AddClick(self.closeBnt_, function()
    self.equipRefineVm_.CloseRefinePopup()
  end)
  self:AddClick(self.equipLab_, function()
    if self.partItem_ then
      if self.tipsId_ then
        Z.TipsVM.CloseItemTipsView(self.tipsId_)
        self.tipsId_ = nil
      end
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.equipLab_.transform, self.partItem_.configId, self.partItem_.uuid)
    end
  end)
end

function Equip_vocational_refining_popupView:initDatas()
  self.curProfessionId_ = nil
  self.partId_ = self.viewData.partId
  if self.partId_ == nil then
    self.partId_ = E.EquipPart.Weapon
  end
end

function Equip_vocational_refining_popupView:initUi()
  local profession_item_path = self.prefabCache_:GetString("profession_item")
  if profession_item_path and profession_item_path ~= "" then
    Z.CoroUtil.create_coro_xpcall(function()
      self.professionUnits_ = {}
      local professionTableMgr = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
      local currentProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
      for k, v in pairs(professionTableMgr) do
        if v.IsOpen then
          local unit = self:AsyncLoadUiUnit(profession_item_path, "profession_item" .. v.ProfessionId, self.leftParent_.transform)
          if unit then
            unit.tog_click.isOn = false
            unit.Ref:SetVisible(unit.img_on, false)
            self.professionUnits_[v.ProfessionId] = unit
            unit.tog_click.group = self.togGroup_
            unit.lab_vocational_name.text = v.Name
            unit.img_weapon_icon_off:SetImage(v.Icon)
            unit.img_weapon_icon_on:SetImage(v.Icon)
            self:AddClick(unit.tog_click, function(isOn)
              self:selectedProfession(v.ProfessionId)
            end)
          end
        end
      end
      if self.professionUnits_[currentProfessionId] then
        self:selectedProfession(currentProfessionId)
        self.professionUnits_[currentProfessionId].tog_click.isOn = true
      end
    end)()
  end
end

function Equip_vocational_refining_popupView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initDatas()
  self:initUi()
  self:initEquipInfo()
end

function Equip_vocational_refining_popupView:selectedProfession(professionId)
  if self.curProfessionId_ == professionId then
    return
  end
  self.curProfessionId_ = professionId
  self:loadBasicAttr()
  self:loadLevleEffect()
end

function Equip_vocational_refining_popupView:initEquipInfo()
  local equipPartRow = Z.TableMgr.GetRow("EquipPartTableMgr", self.partId_)
  if equipPartRow then
    self.icon_:SetImage(equipPartRow.PartIcon)
    self.partNameLab_.text = equipPartRow.PartName
  end
  self.partItem_ = self.equipSystemVm_.GetItemByPartId(self.partId_)
  if self.partItem_ == nil then
    self.equipLab_.text = Lang("NotWearing")
    return
  end
  self.equipLab_.text = string.zconcat(Lang("CurrentPut"), "<link>", self.itemsVM_.ApplyItemNameWithQualityTag(self.partItem_.configId), "</link>")
end

function Equip_vocational_refining_popupView:loadBasicAttr()
  if self.basicUnits_ then
    for k, v in pairs(self.basicUnits_) do
      self:RemoveUiUnit(k)
    end
    self.basicUnits_ = {}
  end
  local basicItemPath = self.prefabCache_:GetString("basic_item")
  if basicItemPath == nil or basicItemPath == "" then
    return
  end
  self.basicUnits_ = {}
  self.currentLevel_ = 0
  if Z.ContainerMgr.CharSerialize.equip.equipList[self.partId_] then
    self.currentLevel_ = Z.ContainerMgr.CharSerialize.equip.equipList[self.partId_].equipSlotRefineLevel or 0
  end
  self.refiningLevleLab_.text = Lang("LevelReminderTips", {
    val = self.currentLevel_
  })
  local tab = self.equipRefineVm_.GetBasicAttrInfo(self.partId_, self.currentLevel_, self.curProfessionId_)
  if tab == nil or #tab == 0 then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(tab) do
      local unitName = "basic" .. k
      local unit = self:AsyncLoadUiUnit(basicItemPath, unitName, self.baseAttrParent_.transform)
      if unit then
        self.basicUnits_[unitName] = unit
        unit.lab_name.text = v.attrName
        unit.lab_current_level.text = v.nowValue or ""
        if v.nextValue then
          unit.lab_last_level.text = v.nextValue
        end
        unit.Ref:SetVisible(unit.lab_last_level, v.nextValue ~= nil)
        unit.Ref:SetVisible(unit.img_arrow, v.nextValue ~= nil)
      end
    end
  end)()
end

function Equip_vocational_refining_popupView:loadLevleEffect()
  if self.effectUnits_ then
    for k, v in pairs(self.effectUnits_) do
      self:RemoveUiUnit(k)
    end
    self.effectUnits_ = {}
  end
  local refiningItemPath = self.prefabCache_:GetString("refining_item")
  if refiningItemPath == nil or refiningItemPath == "" then
    return
  end
  self.effectUnits_ = {}
  local tab = self.equipRefineVm_.GetRefineLevelEffect(self.partId_, self.curProfessionId_)
  if tab == nil or #tab == 0 then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(tab) do
      local unitName = "effect" .. k
      local unit = self:AsyncLoadUiUnit(refiningItemPath, unitName, self.specialParent_.transform)
      if unit then
        self.effectUnits_[unitName] = unit
        local str = Lang("EquipRefineLevle", {
          val = v.level
        }) .. ": " .. v.attrName
        if v.level > self.currentLevel_ then
          str = Z.RichTextHelper.ApplyColorTag(str, "#cdcdca")
        else
          str = Z.RichTextHelper.ApplyColorTag(str, "#EFC892")
        end
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(unit.lab_name, str)
      end
    end
  end)()
end

function Equip_vocational_refining_popupView:OnDeActive()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  Z.CommonTipsVM.CloseRichText()
end

function Equip_vocational_refining_popupView:OnRefresh()
end

return Equip_vocational_refining_popupView
