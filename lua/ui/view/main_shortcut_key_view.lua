local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_shortcut_keyView = class("Main_shortcut_keyView", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function Main_shortcut_keyView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_shortcut_key", "main/main_shortcut_key", UI.ECacheLv.None)
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.mainuiVM_ = Z.VMMgr.GetVM("mainui")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Main_shortcut_keyView:OnDestroy()
end

function Main_shortcut_keyView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.keyDescCompMap_ = {}
  self:bindEvent()
  self:initComp()
  self:refreshShortcutItem()
  self:changeShortcutMenuState(false)
end

function Main_shortcut_keyView:OnDeActive()
  self:unBindEvent()
  self:unInitComp()
  self:clearShortcutItem()
end

function Main_shortcut_keyView:OnShow()
  self:refreshShortcutItemState()
end

function Main_shortcut_keyView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.MainUI.ChangeShortcutMenuState, self.changeShortcutMenuState, self)
end

function Main_shortcut_keyView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.MainUI.ChangeShortcutMenuState, self.changeShortcutMenuState, self)
end

function Main_shortcut_keyView:initComp()
  self.inputKeyDescComp_:Init(124, self.uiBinder.node_icon_key)
  local functionRow = Z.TableMgr.GetRow("FunctionTableMgr", E.FunctionID.ShortcutMenu)
  if functionRow then
    self.uiBinder.lab_name.text = functionRow.Name
  end
end

function Main_shortcut_keyView:unInitComp()
  self.inputKeyDescComp_:UnInit()
end

function Main_shortcut_keyView:refreshShortcutItem()
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearShortcutItem()
    self:createShortcutItem()
  end)()
end

function Main_shortcut_keyView:createShortcutItem()
  local resultList = {}
  local dataList = Z.TableMgr.GetTable("SetKeyboardTableMgr").GetDatas()
  for id, row in pairs(dataList) do
    if row.Quickdescription > 0 then
      if resultList[row.Quickdescription] == nil then
        resultList[row.Quickdescription] = {}
      end
      table.insert(resultList[row.Quickdescription], row)
    end
  end
  for type, list in pairs(resultList) do
    table.sort(list, function(a, b)
      if a.Sort == b.Sort then
        return a.Id < b.Id
      else
        return a.Sort < b.Sort
      end
    end)
  end
  local unitPath = self.uiBinder.prefab_cache:GetString("com_icon_key")
  for type, list in ipairs(resultList) do
    local unitParent = self.uiBinder["trans_layout_type_" .. type]
    if unitParent then
      for index, row in ipairs(list) do
        local unitName = row.Id
        local unitToken = self.cancelSource:CreateToken()
        self.shortcutUnitTokenDict_[unitName] = unitToken
        local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
        self.shortcutUnitDict_[unitName] = unitItem
        local keyDescComp = inputKeyDescComp.new()
        keyDescComp:Init(row.Id, unitItem, row.SetDes, true)
        keyDescComp:SetVisible(true)
        keyDescComp:SetOnRefreshCb(function()
          self.uiBinder.rebuilder_layout:ForceRebuildLayoutImmediate()
        end)
        self.keyDescCompMap_[unitName] = keyDescComp
        local size = unitItem.lab_key:GetPreferredValues(unitItem.lab_key.text, 0, 20)
        unitItem.Trans:SetWidth(size.x)
      end
    end
  end
  self:refreshShortcutItemState()
end

function Main_shortcut_keyView:clearShortcutItem()
  if self.shortcutUnitTokenDict_ then
    for unitName, unitToken in pairs(self.shortcutUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.shortcutUnitTokenDict_ = {}
  if self.shortcutUnitDict_ then
    for unitName, unitItem in pairs(self.shortcutUnitDict_) do
      self.keyDescCompMap_[unitName]:UnInit()
      self:RemoveUiUnit(unitName)
    end
  end
  self.shortcutUnitDict_ = {}
  self.keyDescCompMap_ = {}
end

function Main_shortcut_keyView:refreshShortcutItemState()
  if self.shortcutUnitDict_ == nil then
    return
  end
  for unitName, unitItem in pairs(self.keyDescCompMap_) do
    local row = Z.TableMgr.GetRow("SetKeyboardTableMgr", unitName)
    local isCanShow = self:checkItemCanShow(row)
    unitItem:SetVisible(isCanShow)
  end
  self:keyHintUIFresh()
  self.uiBinder.rebuilder_layout:ForceRebuildLayoutImmediate()
end

function Main_shortcut_keyView:checkItemCanShow(row)
  if row.FunctionId == 0 then
    return true
  end
  if not self.funcVM_.FuncIsOn(row.FunctionId, true) then
    return false
  end
  if not self.mainuiVM_.CheckFunctionCanShowInScene(row.FunctionId) then
    return false
  end
  return true
end

function Main_shortcut_keyView:keyHintUIFresh()
  if self.shortcutUnitDict_[E.PCKeyHint.Jump] then
    local isShow = not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Jump)
    self.shortcutUnitDict_[E.PCKeyHint.Jump].Ref.UIComp:SetVisible(isShow)
  end
  if self.shortcutUnitDict_[E.PCKeyHint.Dash] then
    local isShow = not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Rush)
    self.shortcutUnitDict_[E.PCKeyHint.Dash].Ref.UIComp:SetVisible(isShow)
  end
  if self.shortcutUnitDict_[E.PCKeyHint.LockTarget] then
    local settingIsOn = Z.VMMgr.GetVM("setting").Get(E.SettingID.LockOpen)
    local lockInputMask = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.LockTarget)
    local isShow = settingIsOn and not lockInputMask
    self.shortcutUnitDict_[E.PCKeyHint.LockTarget].Ref.UIComp:SetVisible(isShow)
  end
end

function Main_shortcut_keyView:changeShortcutMenuState(isShow)
  if isShow and not self.IsVisible then
    self:Show()
    self:onStartAnimShow()
  else
    self:onStartAnimHide()
  end
end

function Main_shortcut_keyView:onStartAnimShow()
  Z.AudioMgr:Play("UI_Menu_QuickInstruction_Open")
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

function Main_shortcut_keyView:onStartAnimHide()
  Z.AudioMgr:Play("UI_Menu_QuickInstruction_Close")
  self.commonVM_.CommonDotweenPlay(self.uiBinder.anim_do, Z.DOTweenAnimType.Close, function()
    self:Hide()
  end)
end

return Main_shortcut_keyView
