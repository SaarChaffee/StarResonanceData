local QuickUseItemBarComp = class("QuickUseItemBarComp")
local TIME_INTERVAL = 0.05

function QuickUseItemBarComp:ctor(parentView)
  self.parentView_ = parentView
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function QuickUseItemBarComp:Init(itemContainer, type)
  self.configId_ = 0
  self.curCdTime_ = 0
  self.cdTimer_ = nil
  self.type_ = type
  self.itemContainer_ = itemContainer
  self.isShowShortcuts_ = true
  self.itemContainer_.btn_arrow_up:SetVisible(type == E.ShortcutsItemType.Shortcuts)
  self.itemContainer_.btn_arrow_down:SetVisible(false)
  if type == E.ShortcutsItemType.Shortcuts then
    self:InitShortcuts()
  end
  self.parentView_:AddAsyncClick(self.itemContainer_.btn_item.Btn, function()
    self:btnItemCallFunc()
  end)
  Z.EventMgr:Add(Z.ConstValue.SyncAllContainerData, self.onSyncAllContainerData, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onAddItem, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onDelItem, self)
  if type ~= E.ShortcutsItemType.Quest then
    Z.EventMgr:Add(Z.ConstValue.Backpack.ChangeQuickBar, self.SetItemConfigId, self)
  end
  
  function self.onPackageChangedFunc_(container, dirty)
    self:onPackageChanged(container, dirty)
  end
  
  function self.onGropCdChangedFunc_(container, dirty)
    self:onGropCdChanged(container, dirty)
  end
  
  self.parentView_:EventAddAsyncListener(self.itemContainer_.btn_item.Btn.OnLongPressEvent, function()
    if self.configId_ == 0 then
      return
    end
    self.tipsId = Z.TipsVM.ShowItemTipsView(self.itemContainer_.Trans, self.configId_)
  end, nil, nil)
  for _, package in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages) do
    package.Watcher:RegWatcher(self.onPackageChangedFunc_)
  end
  Z.ContainerMgr.CharSerialize.itemPackage.Watcher:RegWatcher(self.onGropCdChangedFunc_)
  if type ~= E.ShortcutsItemType.Quest then
    local configId = Z.ContainerMgr.CharSerialize.itemPackage.quickBar or 0
    self:SetItemConfigId(configId)
  end
end

function QuickUseItemBarComp:btnItemCallFunc()
  if self.configId_ == 0 then
    return
  end
  self:onClickItem()
end

function QuickUseItemBarComp:InitShortcuts()
  self:onCloseShortcutsPopup()
  self.parentView_:AddClick(self.itemContainer_.btn_add.Btn, function()
    Z.TipsVM.ShowTipsLang(130001)
  end)
  self.parentView_:AddClick(self.itemContainer_.btn_arrow_down.Btn, function()
    Z.UIMgr:CloseView("item_shortcuts_popup")
  end)
  self.parentView_:AddClick(self.itemContainer_.btn_arrow_up.Btn, function()
    self:setItemPopShow(true)
  end)
  Z.EventMgr:Add(Z.ConstValue.Backpack.CloseShortcutsPopup, self.onCloseShortcutsPopup, self)
end

function QuickUseItemBarComp:UnInit()
  self.parentView_.timerMgr:StopTimer(self.cdTimer_)
  Z.EventMgr:RemoveObjAll(self)
  Z.TipsVM.CloseItemTipsView(self.tipsId)
  for _, package in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages) do
    package.Watcher:UnregWatcher(self.onPackageChangedFunc_)
  end
  Z.ContainerMgr.CharSerialize.itemPackage.Watcher:UnregWatcher(self.onGropCdChangedFunc_)
  self.configId_ = 0
  self.curCdTime_ = 0
  self.cdTimer_ = nil
  self.itemContainer_ = nil
  self.onPackageChangedFunc_ = nil
  self.onGropCdChangedFunc_ = nil
end

function QuickUseItemBarComp:onCloseShortcutsPopup()
  self.itemContainer_.btn_arrow_down:SetVisible(false)
  self.itemContainer_.btn_arrow_up:SetVisible(true)
end

function QuickUseItemBarComp:SetItemConfigId(itemConfigId)
  self.itemContainer_.group_item:SetVisible(itemConfigId ~= 0)
  self.itemContainer_.btn_add:SetVisible(itemConfigId == 0)
  self.configId_ = itemConfigId
  self.curCdTime_ = 0
  self:refreshAll()
end

function QuickUseItemBarComp:QuickUseItem()
  if self.itemContainer_ then
    Z.CoroUtil.create_coro_xpcall(function()
      self:onClickItem()
    end)()
  end
end

function QuickUseItemBarComp:refreshAll()
  self:refreshItemIcon()
  self:refreshItemCount()
  self:refreshItemCd()
end

function QuickUseItemBarComp:refreshItemIcon()
  if self.configId_ <= 0 then
    return
  end
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.configId_)
  if itemRow then
    self.itemContainer_.rimg_icon.RImg:SetImage(self.itemsVM_.GetItemIcon(self.configId_))
  end
end

function QuickUseItemBarComp:refreshItemCount()
  if self.configId_ <= 0 then
    return
  end
  local ownNum = self.itemsVM_.GetItemTotalCount(self.configId_)
  if 0 < ownNum then
    self.itemContainer_.rimg_icon.RImg:ClearGray()
    self.itemContainer_.rimg_icon.Ref:SetVisible(true)
    self.itemContainer_.lab_count.Ref:SetVisible(true)
  else
    self.itemContainer_.rimg_icon.Ref:SetVisible(false)
    self.itemContainer_.lab_count.Ref:SetVisible(false)
  end
  if 100 < ownNum then
    ownNum = 99 .. "+"
  end
  self.itemContainer_.lab_count.TMPLab.text = ownNum
end

function QuickUseItemBarComp:refreshItemCd()
  self.parentView_.timerMgr:StopTimer(self.cdTimer_)
  self.cdTimer_ = nil
  self:hideCd()
  if self.configId_ <= 0 then
    return
  end
  local package = self.itemsVM_.GetPackageInfobyItemId(self.configId_)
  if not package or not next(package) then
    return
  end
  local cdTime, useCd = self.itemsVM_.GetItemCd(package, self.configId_)
  if cdTime and useCd then
    local serverTime = Z.ServerTime:GetServerTime()
    local diffTime = (cdTime - serverTime) / 1000
    if 0 < diffTime then
      self:startCdTimer(useCd, diffTime)
    end
  end
end

function QuickUseItemBarComp:refreshCd(itemUseCD)
  self.curCdTime_ = self.curCdTime_ - TIME_INTERVAL
  if self.curCdTime_ < 0 then
    self.curCdTime_ = 0
  end
  self.itemContainer_.lab_cd.TMPLab.text = string.format("%.1f", self.curCdTime_)
  self.itemContainer_.img_mask.Img.fillAmount = self.curCdTime_ / itemUseCD
end

function QuickUseItemBarComp:startCdTimer(itemUseCD, remainingSec)
  self.curCdTime_ = remainingSec
  self:refreshCd(itemUseCD)
  self.itemContainer_.lab_cd:SetVisible(true)
  local loops = math.ceil(remainingSec / TIME_INTERVAL)
  if self.cdTimer_ then
    self.parentView_.timerMgr:StopTimer(self.cdTimer_)
  end
  self.cdTimer_ = self.parentView_.timerMgr:StartTimer(function()
    self:refreshCd(itemUseCD)
  end, TIME_INTERVAL, loops, nil, function()
    self.curCdTime_ = 0
    self:hideCd()
  end)
end

function QuickUseItemBarComp:hideCd()
  self.itemContainer_.lab_cd:SetVisible(false)
  self.itemContainer_.img_mask.Img.fillAmount = 0
end

function QuickUseItemBarComp:onClickItem()
  local ownNum = self.itemsVM_.GetItemTotalCount(self.configId_)
  if ownNum <= 0 then
    local itemShortcutsPop = Z.UIMgr:GetView("item_shortcuts_popup")
    if itemShortcutsPop and itemShortcutsPop.IsActive then
      self:setItemPopShow(false)
      return
    end
    self:setItemPopShow(true)
    return
  end
  if 0 >= self.curCdTime_ then
    self:asyncQuickUseItem()
  else
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.configId_)
    if itemRow then
      local param = {
        item = {
          name = itemRow.Name
        }
      }
      Z.TipsVM.ShowTipsLang(100103, param)
    end
  end
end

function QuickUseItemBarComp:setItemPopShow(isShow)
  self.itemContainer_.btn_arrow_down:SetVisible(isShow)
  self.itemContainer_.btn_arrow_up:SetVisible(not isShow)
  if isShow then
    local pos = Vector3.New(self.itemContainer_.btn_arrow_up.Trans.position.x, self.itemContainer_.btn_arrow_up.Trans.position.y - 0.1, self.itemContainer_.btn_arrow_up.Trans.position.z)
    if Z.IsPCUI then
      pos.y = pos.y + 0.3
    else
      pos.x = pos.x - 1
    end
    Z.UIMgr:OpenView("item_shortcuts_popup", pos)
  else
    Z.UIMgr:CloseView("item_shortcuts_popup")
  end
end

function QuickUseItemBarComp:asyncQuickUseItem()
  local ret = self.itemsVM_.AsyncUseItemByConfigId(self.configId_, self.parentView_.cancelSource:CreateToken())
  if ret == 0 then
    return true
  else
    return false
  end
end

function QuickUseItemBarComp:onPackageChanged(container, dirtyKeys)
  if dirtyKeys.itemCd and dirtyKeys.itemCd[self.configId_] then
    local timeStamp = dirtyKeys.itemCd[self.configId_]:Get()
    if timeStamp then
      self:refreshItemCd()
    end
  end
end

function QuickUseItemBarComp:onGropCdChanged(container, dirtyKeys)
  if dirtyKeys.useGroupCd then
    self:refreshItemCd()
  end
end

function QuickUseItemBarComp:onSyncAllContainerData()
  for _, package in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages) do
    package.Watcher:RegWatcher(self.onPackageChangedFunc_)
  end
end

function QuickUseItemBarComp:onItemCountChange(item)
  if item.configId == self.configId_ then
    self:refreshItemCount()
  end
end

function QuickUseItemBarComp:onAddItem(item)
  if item.configId == self.configId_ then
    self:refreshItemCount()
    self:refreshItemCd()
  end
end

function QuickUseItemBarComp:onDelItem(item)
  if item.configId == self.configId_ then
    self:refreshItemCount()
    self:refreshItemCd()
  end
end

return QuickUseItemBarComp
