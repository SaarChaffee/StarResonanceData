local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_choice_subView = class("Equip_choice_subView", super)
local loopGridView = require("ui/component/loop_grid_view")
local loopItem = require("ui/component/equip/equip_recast_popup_loop_item")

function Equip_choice_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath
  if Z.IsPCUI then
    assetPath = "equip/equip_choice_sub_pc"
  else
    assetPath = "equip/equip_choice_sub"
  end
  super.ctor(self, "equip_choice_sub", assetPath, UI.ECacheLv.None)
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
end

function Equip_choice_subView:initBinders()
  self.closeBnt_ = self.uiBinder.btn_return
  self.itemList_ = self.uiBinder.loop_item
  self.press_ = self.uiBinder.node_press
  self.emptyLab_ = self.uiBinder.lab_empty
  self.infoLab_ = self.uiBinder.lab_info
  self.titleLab_ = self.uiBinder.lab_title
end

function Equip_choice_subView:initBtns()
  self:AddClick(self.closeBnt_, function()
    self:DeActive()
  end)
  self:EventAddAsyncListener(self.press_.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:DeActive()
    end
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.btn_get, function()
    if self.viewData and self.viewData.selectedEquipId then
      local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.viewData.selectedEquipId)
      if not equipRow then
        return
      end
      for _, typeId in ipairs(equipRow.RecastType) do
        local recastItemRow = Z.TableMgr.GetRow("EquipRecastTypeTableMgr", typeId)
        if recastItemRow and recastItemRow.RecastItemId then
          if self.tipsId_ then
            Z.TipsVM.CloseItemTipsView(self.tipsId_)
          end
          self.tipsId_ = Z.TipsVM.OpenSourceTips(recastItemRow.RecastItemId, self.viewData.tipsRoot, nil, {
            tipsBindPressCheckComp = self.press_
          })
          return
        end
      end
    end
  end)
end

function Equip_choice_subView:initUi()
  self.infoLab_.text = self.viewData.labInfo or ""
  self.titleLab_.text = self.viewData.title or ""
  self.loopGridView_ = loopGridView.new(self, self.itemList_, loopItem, "com_item_long_2", true)
  self.items_ = {}
  if self.viewData and self.viewData.items then
    self.items_ = self.viewData.items
  end
  self.uiBinder.Ref:SetVisible(self.emptyLab_, #self.items_ == 0 and self.viewData.isRecast)
  self.loopGridView_:Init(self.items_)
  self:StartCheck()
end

function Equip_choice_subView:GetIsRecast()
  return self.viewData.isRecast
end

function Equip_choice_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initBinders()
  self:initBtns()
  self:initUi()
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, true)
end

function Equip_choice_subView:StartCheck()
  self.press_:StartCheck()
end

function Equip_choice_subView:StopCheck()
  self.press_:StopCheck()
end

function Equip_choice_subView:ClearSelected()
  self.loopGridView_:ClearAllSelect()
end

function Equip_choice_subView:OnDeActive()
  self:StopCheck()
  if self.loopGridView_ then
    self.loopGridView_:UnInit()
    self.loopGridView_ = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, false)
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

function Equip_choice_subView:OnRefresh()
end

return Equip_choice_subView
