local UI = Z.UI
local super = require("ui.ui_view_base")
local Gm_item_popupView = class("Gm_item_popupView", super)

function Gm_item_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gm_item_popup")
  self.gmVm_ = Z.VMMgr.GetVM("gm")
  self.vm_ = Z.VMMgr.GetVM("gm_item_popup")
end

function Gm_item_popupView:OnActive()
  self.gsNumber_ = 100
  self.numNumber_ = 1
  self.durabilityNumber_ = 100
  self.bindNumber_ = 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  self:AddAsyncClick(self.uiBinder.btn_get_item, function()
    local gmStr = ""
    if self.isEquip_ then
      gmStr = string.format("%s%s,%s,%s,%s", "addEquip ", self.configId_, self.gsNumber_, self.bindNumber_, self.numNumber_)
    else
      gmStr = string.format("%s%s,%s,%s", "addItem ", self.configId_, self.numNumber_, self.bindNumber_)
    end
    self.gmVm_.SubmitGmCmd(gmStr, self.cancelSource)
  end, nil, nil)
  self:AddClick(self.uiBinder.btn_close, function()
    self.vm_.CloseGmItemPopup()
  end)
  self:AddClick(self.uiBinder.input_gs, function(num)
    self.gsNumber_ = num
  end)
  self:AddClick(self.uiBinder.input_durability, function(num)
    self.durabilityNumber_ = num
  end)
  self:AddClick(self.uiBinder.input_bind, function(num)
    self.bindNumber_ = num
  end)
  self:AddClick(self.uiBinder.input_num, function(num)
    self.numNumber_ = num
  end)
  self.uiBinder.img_bg.onDrag:AddListener(function(go, pointerData)
    local pos = self.uiBinder.img_bg_ref.localPosition
    local posX = pos.x + pointerData.delta.x
    local posy = pos.y + pointerData.delta.y
    self.uiBinder.img_bg_ref:SetLocalPos(posX, posy)
  end)
  self:BindEvents()
end

function Gm_item_popupView:changeSelectItem(configData)
  if configData == nil then
    return
  end
  self.configId_ = configData
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  local cfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.configId_)
  if cfgData == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
  local equipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(self.configId_, true)
  self.isEquip_ = equipData ~= nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_gs, self.isEquip_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_durablity, self.isEquip_)
  self.uiBinder.input_gs.text = self.gsNumber_
  self.uiBinder.input_durability.text = self.durabilityNumber_
  self.uiBinder.input_num.text = self.numNumber_
  self.uiBinder.input_bind.text = self.bindNumber_
  self.uiBinder.lab_item_name.text = cfgData.Name
  self.uiBinder.lab_item_id.text = self.configId_
end

function Gm_item_popupView:OnDeActive()
end

function Gm_item_popupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.GM.GMItemView, self.changeSelectItem, self)
end

function Gm_item_popupView:OnRefresh()
  self.uiBinder.img_bg_ref:SetLocalPos(650, 300)
end

return Gm_item_popupView
