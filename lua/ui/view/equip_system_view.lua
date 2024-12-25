local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_systemView = class("Equip_systemView", super)
local item_operation_btnsView_ = require("ui.view.item_operation_btns_view")
local middleRoleSub = require("ui.view.equip_middle_role_sub_view")

function Equip_systemView:ctor()
  self.panel = nil
  super.ctor(self, "equip_system")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipAttrParseVm_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.item_operation_btnsView_ = item_operation_btnsView_.new()
  self.middleRoleSub_ = middleRoleSub.new()
  self.equipData_ = Z.DataMgr.Get("equip_system_data")
end

function Equip_systemView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:DoCameraAnim("enterEquip")
  self:AddClick(self.panel.cont_display.btn_replacement.Btn, function()
    self:ShowReplaceEquipView()
  end)
  self.panel.anim:SetVisible(false)
  self.frameTimer = self.timerMgr:StartFrameTimer(function()
    self.equip_trail_effuid_ = Z.UnrealSceneMgr:CreatEffect("ui/p_fx_ui_equip_trail_01", "equip_trail")
    self.equip_middle_effuid_ = Z.UnrealSceneMgr:CreatEffect("ui/p_fx_ui_equip_middle_01", "equip_middle")
    self.middleRoleSub_:Active(nil, self.panel.group_middle.Trans)
    self.panel.anim:SetVisible(true)
  end, 10)
  self:AddClick(self.panel.cont_title_return.cont_btn_return.btn.Btn, function()
    self.equipVm_.CloseEquipSystemView()
  end)
  self:AddClick(self.panel.cont_title_return.btn_ask.Btn, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30013)
  end)
  self.playerModel_ = Z.UnrealSceneMgr:GetCacheModel(self.equipData_.EquipModelName)
  if self.playerModel_ == nil then
    self.playerModel_ = Z.UnrealSceneMgr:CloneModelByLua(self.playerModel_, Z.EntityMgr.PlayerEnt.Model, function(model)
      self:SetMode(model)
    end, self.equipData_.EquipModelName, function()
      Z.UIMgr:FadeOut()
    end)
  else
    self:SetMode(self.playerModel_)
    Z.UIMgr:FadeOut()
  end
  self.btnData_ = {
    viewConfigKey = self.viewConfigKey
  }
  self:ShowEquipPartsView()
end

function Equip_systemView:SetMode(model)
  model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
  model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
  model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
  model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
  model:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
end

function Equip_systemView:OnRefresh()
end

function Equip_systemView:ShowEquipPartsView()
  self.selectedPartId_ = nil
  self.panel.cont_display:SetVisible(true)
  self:showEquipTotalDesTips()
  self.item_operation_btnsView_:DeActive()
end

function Equip_systemView:ShowReplaceEquipView(itemUuid)
  self.equipVm_.OpenChangeEquipView({
    itemUuid = itemUuid,
    prtId = self.selectedPartId_
  })
end

function Equip_systemView:OnDeActive()
  Z.UnrealSceneMgr:ClearEffect(self.equip_trail_effuid_)
  Z.UnrealSceneMgr:ClearEffect(self.equip_middle_effuid_)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.UnrealSceneMgr:ClearModel(self.playerZModel_)
  self.item_operation_btnsView_:DeActive()
  self.middleRoleSub_:DeActive()
  if self.frameTimer then
    self.timerMgr:StopFrameTimer(self.frameTimer)
  end
end

function Equip_systemView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("equip_system")
end

function Equip_systemView:showEquipTotalDesTips()
  self.panel.cont_display.cont_equip_information_right:SetVisible(true)
  local totalEquopAttr = Z.ContainerMgr.CharSerialize.equip.equipAttr
  self:ClearAllUnits()
  if not totalEquopAttr then
    self.panel.cont_display.cont_equip_information_right.scrollview_attrs:SetVisible(false)
    self.panel.cont_display.cont_empty.anim_empty:SetVisible(true)
    self.panel.cont_display.cont_equip_information_right.cont_gs_group.lab_numerical.TMPLab.text = 0
    return
  end
  self.panel.cont_display.cont_equip_information_right.cont_gs_group.lab_numerical.TMPLab.text = ""
  local baseAttrTips = self.equipAttrParseVm_.GetEquipBaseAttrTips(totalEquopAttr, true)
  local externAttrTips = {}
  local baseAttrParent = self.panel.cont_display.cont_equip_information_right.layout_base_content.Trans
  local externAttrParent = self.panel.cont_display.cont_equip_information_right.layout_special_content.Trans
  if 0 < table.zcount(baseAttrTips) or 0 < table.zcount(externAttrTips) then
    self.panel.cont_display.cont_empty.anim_empty:SetVisible(false)
    self.panel.cont_display.cont_equip_information_right.scrollview_attrs:SetVisible(true)
  else
    self.panel.cont_display.cont_empty.anim_empty:SetVisible(true)
    self.panel.cont_display.cont_equip_information_right.scrollview_attrs:SetVisible(false)
  end
  local cancelToken = self.cancelSource:CreateToken()
  Z.CoroUtil.create_coro_xpcall(function()
    local index = 1
    if baseAttrTips then
      for key, value in ipairs(baseAttrTips) do
        local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr), "baseAttrItem" .. index, baseAttrParent)
        if not self.cancelSource or self.cancelSource:CancelToken(cancelToken) then
          return
        end
        index = index + 1
        unit.lab_des.TMPLab.text = value
      end
      self.panel.cont_display.cont_equip_information_right.layout_base_content.ZLayout:ForceRebuildLayoutImmediate()
      self.panel.cont_display.cont_equip_information_right.layout_base.ZLayout:ForceRebuildLayoutImmediate()
    end
    if externAttrTips and table.zcount(externAttrTips) > 0 then
      self.panel.cont_display.cont_equip_information_right.layout_special:SetVisible(true)
      for key, value in ipairs(externAttrTips) do
        local unit
        unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr), "externAttrItem" .. index, externAttrParent)
        if not self.cancelSource or self.cancelSource:CancelToken(cancelToken) then
          return
        end
        index = index + 1
        unit.lab_des.TMPLab.text = value.tip
        self.equipAttrParseVm_.SetEquipExternAttrTipsImgColor(unit.node_icon.img_target_1, value.colorType)
      end
      self.panel.cont_display.cont_equip_information_right.layout_special_content.ZLayout:ForceRebuildLayoutImmediate()
      self.panel.cont_display.cont_equip_information_right.layout_special.ZLayout:ForceRebuildLayoutImmediate()
    else
      self.panel.cont_display.cont_equip_information_right.layout_special:SetVisible(false)
    end
    self.panel.cont_display.cont_equip_information_right.layout_atrr_content.ZLayout:ForceRebuildLayoutImmediate()
  end)()
end

function Equip_systemView:CustomClose()
end

return Equip_systemView
