local UI = Z.UI
local super = require("ui.ui_view_base")
local Refine_dialogView = class("Refine_dialogView", super)
local itemClass = require("common.item")

function Refine_dialogView:ctor()
  self.panel = nil
  super.ctor(self, "refine_dialog")
  self.defaultDesc = ""
  self.defaultLabYes = Lang("BtnYes")
  self.defaultLabNo = Lang("BtnNo")
  
  function self.defaultOnCancel()
    Z.UIMgr:CloseView("refine_dialog")
  end
end

function Refine_dialogView:OnRefresh()
end

function Refine_dialogView:OnActive()
  if self.viewData then
    self.itemClassTab_ = {}
    self.panel.lab_desc.TMPLab.text = ""
    self.panel.refine_tips_1:SetVisible(false)
    self.panel.refine_tips_2:SetVisible(false)
    if self.viewData.viewType == "normal" then
      self.panel.lab_desc.TMPLab.text = self.viewData.labDesc or self.defaultDesc
    elseif self.viewData.viewType == "tips1" then
      self:createRefineTips1()
    elseif self.viewData.viewType == "tips2" then
      self:createRefineTips2()
    end
    self.panel.con_yesno.lab_yes.TMPLab.text = self.viewData.labYes or self.defaultLabYes
    self.panel.con_yesno.lab_no.TMPLab.text = self.viewData.labNo or self.defaultLabNo
    self:AddAsyncClick(self.panel.con_yesno.btn_yes.Btn, self.viewData.onConfirm or self.defaultOnCancel)
    self:AddAsyncClick(self.panel.con_yesno.btn_no.Btn, self.viewData.onCancel or self.defaultOnCancel)
    self:AddAsyncClick(self.panel.btn_close.Btn, self.viewData.onCancel or self.defaultOnCancel)
    if self.viewData.createUnitFunc then
      self.viewData.createUnitFunc(self, self.panel)
    end
  end
end

function Refine_dialogView:createRefineTips1()
  self.panel.refine_tips_1:SetVisible(true)
  local tips1 = self.panel.refine_tips_1
  tips1.lab_desc.TMPLab.text = Lang("RefineTips1")
  local putItemId = self.viewData.putItemId
  local putItemCount = self.viewData.putItemCount
  Z.CoroUtil.create_coro_xpcall(function()
    self:AsyncLoadUiUnit("ui/prefabsnew_common/c_com_item_backpack_tpl", "item", tips1.content.Trans)
    local consumeItemUnit = self.units.item
    local backpackVm = Z.VMMgr.GetVM("backpack")
    local nowCount = backpackVm.GetItemCount(putItemId)
    self.itemClassTab_.item = itemClass.new(self)
    self.itemClassTab_.item:Init({
      unit = consumeItemUnit,
      configId = putItemId,
      labType = E.ItemLabType.Expend,
      lab = nowCount,
      expendCount = putItemCount
    })
  end)()
  
  function self.viewData.onConfirm()
    if nowCount < putItemCount then
      Z.TipsVM.ShowTipsLang(500006)
      return
    end
    local refineSystemVm = Z.VMMgr.GetVM("refine_system")
    local ret = refineSystemVm.AsyncUnlockItem(self.viewData.queueIndex, self.viewData.columnIndex, self.cancelSource:CreateToken())
    if ret then
      Z.UIMgr:CloseView("refine_dialog")
    end
  end
end

function Refine_dialogView:createRefineTips2()
  self.panel.refine_tips_2:SetVisible(true)
  local tips2 = self.panel.refine_tips_2
  local nowLimit = Z.ContainerMgr.CharSerialize.energyItem.energyLimit
  local addLimit = 0
  local consumeItemId, consumeItemCount
  local materials = Z.Global.EnergyAddMax
  for _, data in ipairs(materials) do
    addLimit = data[1]
    if nowLimit < addLimit then
      consumeItemId = tonumber(data[2])
      consumeItemCount = tonumber(data[3])
      break
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:AsyncLoadUiUnit("ui/prefabs/new_common/c_com_item_backpack_tpl", "item", tips2.content.Trans)
    local consumeItemUnit = self.units.item
    local backpackVm = Z.VMMgr.GetVM("backpack")
    local nowCount = backpackVm.GetItemCount(consumeItemId)
    self.itemClassTab_.item = itemClass.new(self)
    self.itemClassTab_.item:Init({
      unit = consumeItemUnit,
      configId = consumeItemId,
      labType = E.ItemLabType.Expend,
      lab = nowCount,
      expendCount = consumeItemCount
    })
  end)()
  tips2.left_lab_1.TMPLab.text = nowLimit
  tips2.right_lab_1.TMPLab.text = addLimit
  local param = {
    val = addLimit - nowLimit
  }
  tips2.lab_desc.TMPLab.text = Lang("RefineTips2", param)
  
  function self.viewData.onConfirm()
    if nowCount < consumeItemCount then
      Z.TipsVM.ShowTipsLang(500006)
      return
    end
    local refineSystemVm = Z.VMMgr.GetVM("refine_system")
    local ret = refineSystemVm.AsyncAddEnergyLimit(self.cancelSource:CreateToken())
    if ret then
      Z.UIMgr:CloseView("refine_dialog")
    end
  end
end

function Refine_dialogView:OnDeActive()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self:ClearAllUnits()
end

return Refine_dialogView
