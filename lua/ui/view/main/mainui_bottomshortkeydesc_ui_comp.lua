local MainUIBottomShortKeyDescUIComp = class("MainUIBottomShortKeyDescUIComp")
local inputKeyDescComp = require("input.input_key_desc_comp")
local FUNC_ITEM_PREFIX = "com_icon_key_"

function MainUIBottomShortKeyDescUIComp:ctor(view)
  self.view_ = view
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.homeVM_ = Z.VMMgr.GetVM("home_editor")
  self.mainVm_ = Z.VMMgr.GetVM("mainui")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
end

function MainUIBottomShortKeyDescUIComp:Init()
  self:bindEvent()
  self.inputKeyDescMap_ = {}
end

function MainUIBottomShortKeyDescUIComp:UnInit()
  self:unBindEvents()
  self:clearBottomShortcutItem()
end

function MainUIBottomShortKeyDescUIComp:OnRefresh()
  self:refreshBottomShortcutUI()
end

function MainUIBottomShortKeyDescUIComp:bindEvent(...)
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.refreshBottomShortcutUI, self)
end

function MainUIBottomShortKeyDescUIComp:unBindEvents(...)
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.refreshBottomShortcutUI, self)
end

function MainUIBottomShortKeyDescUIComp:refreshBottomShortcutUI()
  if not Z.IsPCUI then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearBottomShortcutItem()
    self:createBottomShortcutItem()
  end)()
end

function MainUIBottomShortKeyDescUIComp:createBottomShortcutItem()
  local funcItemInfo = self.mainVm_.GetMainItem()
  self.bottomPCFuncItemList_ = funcItemInfo[E.MainUIPlaceType.RightTop]
  local unitParent = self.view_.uiBinder.bottom_layout_rebuilder.transform
  local unitPath = self.view_.uiBinder.prefab_cache:GetString("com_icon_key")
  for _, row in ipairs(self.bottomPCFuncItemList_) do
    local keyId, keyDesc = self.mainUIData_:GetKeyIdAndDescByFuncId(row.Id)
    if keyId and keyDesc then
      local unitName = FUNC_ITEM_PREFIX .. row.Id
      local unitToken = self.view_.cancelSource:CreateToken()
      self.bottomShortcutUnitTokenDict_[unitName] = unitToken
      local unitItem = self.view_:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
      self.bottomShortcutUnitDict_[unitName] = unitItem
      local descComp = inputKeyDescComp.new()
      self.inputKeyDescMap_[unitName] = descComp
      descComp:Init(keyId, unitItem, keyDesc, true)
      local size = unitItem.lab_key:GetPreferredValues(unitItem.lab_key.text, 0, 20)
      unitItem.Trans:SetWidth(size.x)
      self:refreshBottomShortcutItem(row.Id, descComp)
    end
  end
end

function MainUIBottomShortKeyDescUIComp:refreshBottomShortcutItem(funcId, descComp)
  local isFuncOpen = self.funcVM_.CheckFuncCanUse(funcId, true)
  if isFuncOpen then
    if funcId == E.FunctionID.Home then
      isFuncOpen = self.homeVM_.IsSelfResident()
    elseif funcId == E.FunctionID.PathFinding then
      local pathFindingVM = Z.VMMgr.GetVM("path_finding")
      isFuncOpen = pathFindingVM:CheckState()
    end
  end
  descComp:SetVisible(isFuncOpen)
end

function MainUIBottomShortKeyDescUIComp:clearBottomShortcutItem()
  if self.bottomShortcutUnitTokenDict_ then
    for unitName, unitToken in pairs(self.bottomShortcutUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.bottomShortcutUnitTokenDict_ = {}
  if self.bottomShortcutUnitDict_ then
    for unitName, unitItem in pairs(self.bottomShortcutUnitDict_) do
      self.inputKeyDescMap_[unitName]:UnInit()
      self.view_:RemoveUiUnit(unitName)
    end
  end
  self.bottomShortcutUnitDict_ = {}
  self.inputKeyDescMap_ = {}
end

function MainUIBottomShortKeyDescUIComp:RefreshPathFindingBtn()
  if self.inputKeyDescMap_ then
    local keyId, keyDesc = self.mainUIData_:GetKeyIdAndDescByFuncId(E.FunctionID.PathFinding)
    if keyId == nil or keyDesc == nil then
      return
    end
    local unitName = FUNC_ITEM_PREFIX .. E.FunctionID.PathFinding
    local descComp = self.inputKeyDescMap_[unitName]
    if descComp then
      descComp:Init(keyId, self.bottomShortcutUnitDict_[unitName], keyDesc, true)
      self:refreshBottomShortcutItem(E.FunctionID.PathFinding, descComp)
    end
  end
end

function MainUIBottomShortKeyDescUIComp:RefreshHomeBtn()
  if self.inputKeyDescMap_ then
    local unitName = FUNC_ITEM_PREFIX .. E.FunctionID.Home
    local descComp = self.inputKeyDescMap_[unitName]
    if descComp then
      self:refreshBottomShortcutItem(E.FunctionID.Home, descComp)
    end
  end
end

function MainUIBottomShortKeyDescUIComp:RefreshAllBottomFuncItemShowState()
  if self.inputKeyDescMap_ == nil or self.bottomPCFuncItemList_ == nil then
    return
  end
  for _, row in pairs(self.bottomPCFuncItemList_) do
    local unitName = FUNC_ITEM_PREFIX .. row.Id
    local descComp = self.inputKeyDescMap_[unitName]
    if descComp then
      self:refreshBottomShortcutItem(row.Id, descComp)
    end
  end
end

return MainUIBottomShortKeyDescUIComp
