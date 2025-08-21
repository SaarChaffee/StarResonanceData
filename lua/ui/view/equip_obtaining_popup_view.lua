local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_obtaining_popupView = class("Equip_obtaining_popupView", super)
local itemBinder = require("common.item_binder")

function Equip_obtaining_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "equip_obtaining_popup")
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  self.equipForgetVm_ = Z.VMMgr.GetVM("equip_forge")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function Equip_obtaining_popupView:initBinders()
  self.titleLab_ = self.uiBinder.lab_title
  self.item_ = self.uiBinder.com_item_long
  self.oldLab_ = self.uiBinder.lab_name
  self.newLab_ = self.uiBinder.lab_change_num
  self.scenemMask_ = self.uiBinder.scenemask
  self.labNode_ = self.uiBinder.node_through_attribute
  self.pressCheck_ = self.uiBinder.press_check
  self.anim_ = self.uiBinder.anim
  self.lab_click_close_ = self.uiBinder.lab_click_close
  self.scenemMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Equip_obtaining_popupView:initBtns()
  self:EventAddAsyncListener(self.pressCheck_.ContainGoEvent, function(isContainer)
    if not isContainer then
      self.equipForgetVm_.CloseEquipObtainingPopup()
    end
  end, nil, nil)
end

function Equip_obtaining_popupView:initData()
  self.itemClass_ = itemBinder.new(self)
  self.itemClass_:Init({
    uiBinder = self.item_
  })
  self.itemInfo_ = self.viewData
end

function Equip_obtaining_popupView:initUi()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff_fankui)
  self.uiBinder.node_eff_fankui:SetEffectGoVisible(false)
  self.commonVM_.CommonPlayAnim(self.anim_, "anim_equip_obtaining_popup_open", self.cancelSource:CreateToken(), function()
    self.uiBinder.node_eff_fankui:SetEffectGoVisible(true)
    self.anim_:PlayLoop("anim_equip_obtaining_popup_loop")
  end)
  self.pressCheck_:StartCheck()
  if self.itemInfo_ then
    local isBreak = self.itemInfo_.equipAttr.breakThroughTime and self.itemInfo_.equipAttr.breakThroughTime > 0
    self.uiBinder.Ref:SetVisible(self.labNode_, isBreak)
    local itemData = {
      uiBinder = self.item_,
      configId = self.itemInfo_.configId,
      itemInfo = self.itemInfo_,
      uuid = self.itemInfo_.uuid,
      tipsBindPressCheckComp = self.pressCheck_
    }
    self.titleLab_.text = isBreak and Lang("EquipBreakThroughSuccessTips") or Lang("EquipCreateSuccessTips")
    if isBreak then
      local levels = self.equipCfgData_.EquipBreakIdLevelMap[self.itemInfo_.configId]
      if self.itemInfo_.equipAttr.breakThroughTime == 1 then
        local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.itemInfo_.configId)
        if equipRow then
          self.oldLab_.text = Lang("GSEqual", {
            val = equipRow.EquipGs
          })
        end
      elseif levels then
        local oldRowId = levels[self.itemInfo_.equipAttr.breakThroughTime - 1]
        if oldRowId then
          local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", oldRowId)
          if breakThroughRow then
            self.oldLab_.text = Lang("GSEqual", {
              val = breakThroughRow.EquipGs
            })
          end
        end
      end
      if levels then
        local curRowId = levels[self.itemInfo_.equipAttr.breakThroughTime]
        if curRowId then
          local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", curRowId)
          if breakThroughRow then
            self.newLab_.text = breakThroughRow.EquipGs
          end
        end
      end
    end
    self.itemClass_:RefreshByData(itemData)
  end
end

function Equip_obtaining_popupView:OnActive()
  self:initBinders()
  self:SetCloseText()
  self:initBtns()
  self:initData()
  self:initUi()
end

function Equip_obtaining_popupView:SetCloseText()
  if Z.IsPCUI then
    self.lab_click_close_.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.lab_click_close_.text = Lang("ClickOnBlankSpaceClosePhone")
  end
end

function Equip_obtaining_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff_fankui)
  self.pressCheck_:StopCheck()
end

function Equip_obtaining_popupView:OnRefresh()
end

return Equip_obtaining_popupView
