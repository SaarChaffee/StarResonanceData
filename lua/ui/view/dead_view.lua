local UI = Z.UI
local super = require("ui.ui_view_base")
local DeadView = class("DeadView", super)

function DeadView:ctor()
  self.uiBinder = nil
  super.ctor(self, "dead")
  self.vm = Z.VMMgr.GetVM("dead")
  self.bossBattleVm_ = Z.VMMgr.GetVM("bossbattle")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.mainuiVM_ = Z.VMMgr.GetVM("mainui")
end

function DeadView:OnActive()
  if not self.vm.CheckPlayerIsDead() then
    self.vm:CloseDeadView()
    return
  end
  self:bindLuaAttrWatchers()
  self:setExitDungeonBtn()
  self:setBaseInfo()
  self:openMainChatView()
  Z.CoroUtil.create_coro_xpcall(function()
    self:unLoadAllReviveItem()
    self:loadAllReviveItem()
    self:setReviveCountTip()
  end)()
end

function DeadView:OnDeActive()
  self:unBindLuaAttrWatchers()
  self:clearCheckTimer()
  self:unLoadAllReviveItem()
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
end

function DeadView:bindLuaAttrWatchers()
  function self.onReviveInfoChange_()
    self:onReviveInfoChange()
  end
  
  Z.ContainerMgr.DungeonSyncData.reviveInfo.Watcher:RegWatcher(self.onReviveInfoChange_)
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    self:updateState()
  end)
end

function DeadView:unBindLuaAttrWatchers()
  if self.onReviveInfoChange_ then
    Z.ContainerMgr.DungeonSyncData.reviveInfo.Watcher:UnregWatcher(self.onReviveInfoChange_)
    self.onReviveInfoChange_ = nil
  end
end

function DeadView:onReviveInfoChange()
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.IsActive then
      return
    end
    self.timerMgr:Clear()
    self:unLoadAllReviveItem()
    self:loadAllReviveItem()
    self:setReviveCountTip()
  end)()
end

function DeadView:setExitDungeonBtn()
  local show = self.mainuiVM_.CheckFunctionCanShowInScene(E.FunctionID.ExitDungeon) and not Z.StageMgr.IsInVisualLayer()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_exit, show)
  self:AddAsyncClick(self.uiBinder.btn_exit, function()
    self.funcVM_.GoToFunc(E.FunctionID.ExitDungeon)
  end)
end

function DeadView:setBaseInfo()
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(Z.Global.ReviveText)
  self.uiBinder.lab_content.text = msgCfg.Content
end

function DeadView:openMainChatView()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if gotoFuncVM.CheckFuncCanUse(E.FunctionID.MainChat, true) then
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    chatMainVM.OpenMainChatView()
  end
end

function DeadView:loadAllReviveItem()
  self.allReviveItemDict_ = {}
  self.curReviveIdList_ = self.vm.GetCurReviveIdList()
  local path
  if Z.IsPCUI then
    path = "ui/prefabs/dead/dead_btn_tpl_pc"
  else
    path = "ui/prefabs/dead/dead_btn_tpl"
  end
  for key, value in pairs(self.curReviveIdList_) do
    local revive = Z.TableMgr.GetTable("ReviveTableMgr").GetRow(value)
    if revive and revive.Type ~= E.ReviveType.BeRevived then
      self.hasBoos_ = self.bossBattleVm_.CheckHasBoss()
      do
        local gotoCheckBattle = self.hasBoos_ and revive.IsBossCanRevive <= 0
        local unitName = "reviveBtn" .. key
        local unitToken = self.cancelSource:CreateToken()
        self.allReviveItemTokenDict_[unitName] = unitToken
        local item = self:AsyncLoadUiUnit(path, unitName, self.uiBinder.layout_btn, unitToken)
        self.allReviveItemDict_[unitName] = item
        item.img_icon:SetImage(revive.Icon)
        self:setCostUI(revive, item)
        self:setBtnState(item, true, revive.Id)
        local reviveTimeConsumPCT = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrReviveTimeConsumePCT")).Value
        local countDown = revive.CountDown * (1 - reviveTimeConsumPCT / 10000.0)
        if countDown then
          local entDeadTime = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrDeadTime")).Value
          local time = 0
          self:AddAsyncClick(item.btn_icon, function()
            if 0 < time then
              Z.TipsVM.ShowTipsLang(130005)
              return
            end
            if self.hasBoos_ and gotoCheckBattle and not self.bossBattleVm_.CheckBossBattleComplete() then
              Z.TipsVM.ShowTipsLang(1001603)
              return
            end
            self:confirmRevive(revive)
          end)
          if entDeadTime ~= 0 then
            entDeadTime = math.floor(entDeadTime / 1000)
            local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
            local diffTime = nowTime - entDeadTime
            time = countDown - diffTime
          else
            time = countDown
          end
          if time <= 0 then
            local str = revive.Name
            if self.hasBoos_ and gotoCheckBattle and not self.bossBattleVm_.CheckBossBattleComplete() then
              self:setBtnState(item, false, revive.Id)
            end
            self:setItemCountText(item, str)
          else
            do
              local str = string.format("%s%s%s%s", "(", math.floor(time), ")", revive.Name)
              self:setItemCountText(item, str)
              self:setBtnState(item, false, revive.Id)
              self.timerMgr:StartTimer(function()
                time = time - 1
                local str
                if 0 < time then
                  str = string.format("%s%s%s%s", "(", math.floor(time), ")", revive.Name)
                else
                  str = revive.Name
                  if gotoCheckBattle then
                    self:createCheckTimer(item, revive.Id)
                  else
                    self:setBtnState(item, true, revive.Id)
                  end
                end
                self:setItemCountText(item, str)
              end, 1, time)
            end
          end
        else
          if self.hasBoos_ and gotoCheckBattle and not self.bossBattleVm_.CheckBossBattleComplete() then
            self:setBtnState(item, false, revive.Id)
          end
          self:setItemCountText(item, revive.Name)
          self:AddAsyncClick(item.btn_icon, function()
            self:confirmRevive(revive)
          end)
        end
      end
    end
  end
end

function DeadView:unLoadAllReviveItem()
  if self.allReviveItemTokenDict_ then
    for unitName, unitToken in pairs(self.allReviveItemTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.allReviveItemTokenDict_ = {}
  if self.allReviveItemDict_ then
    for unitName, unitItem in pairs(self.allReviveItemDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.allReviveItemDict_ = {}
end

function DeadView:setCostUI(row, itemBinder)
  if #row.Consume > 0 then
    local costItemId = row.Consume[2]
    local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", costItemId)
    if itemTableRow == nil then
      return
    end
    local haveNum, costNum, isCostEnough = self:getCostConsumeInfo(row)
    itemBinder.lab_cost_num.text = Z.RichTextHelper.RefreshItemExpendCountUi(haveNum, costNum)
    local itemsVm = Z.VMMgr.GetVM("items")
    itemBinder.rimg_cost_icon:SetImage(itemsVm.GetItemIcon(costItemId))
    itemBinder.Ref:SetVisible(itemBinder.node_cost, true)
  else
    itemBinder.Ref:SetVisible(itemBinder.node_cost, false)
  end
end

function DeadView:createCheckTimer(item, reviveId)
  self:clearCheckTimer()
  self.checkTimer_ = self.timerMgr:StartTimer(function()
    if self.bossBattleVm_.CheckBossBattleComplete() then
      self:clearCheckTimer()
      self:setBtnState(item, true, reviveId)
    end
  end, 1, -1)
end

function DeadView:clearCheckTimer()
  if self.checkTimer_ then
    self.timerMgr:StopTimer(self.checkTimer_)
    self.checkTimer_ = nil
  end
end

function DeadView:setBtnState(item, state, reviveId)
  if item then
    local isCountEnough = self.vm.CheckReviveCount(reviveId)
    if state and isCountEnough then
      item.img_icon:ClearGray()
    else
      item.img_icon:SetGray()
    end
  end
end

function DeadView:setItemCountText(item, text)
  item.lab_name.text = text
end

function DeadView:updateState()
  if not self.vm.CheckPlayerIsDead() then
    self.vm:CloseDeadView()
  end
end

function DeadView:getCostConsumeInfo(reviveRow)
  local costType = reviveRow.Consume[1]
  local costItemId = reviveRow.Consume[2]
  local costNum = reviveRow.Consume[3]
  local haveNum = self.itemsVM_.GetItemTotalCount(costItemId)
  if costType == 2 then
    local addNum = reviveRow.Consume[4]
    local maxNum = reviveRow.Consume[5]
    local reviveInfo = self.vm.GetPlayerReviveInfo(reviveRow.Id)
    local totalNum = costNum + addNum * reviveInfo.PersonReviveCount
    if maxNum < totalNum then
      totalNum = maxNum
    end
    costNum = totalNum
  end
  return haveNum, costNum, haveNum >= costNum
end

function DeadView:confirmRevive(reviveRow)
  if not self.vm.CheckReviveCount(reviveRow.Id, true) then
    return
  end
  if #reviveRow.Consume > 0 then
    Z.UIMgr:OpenView("dead_property_popup", {
      ReviveId = reviveRow.Id
    })
  else
    Z.AudioMgr:Play("UI_Button_Revive")
    self.vm.AsyncRevive(reviveRow.Id, self.cancelSource:CreateToken())
  end
end

function DeadView:setReviveCountTip()
  local showCountTip = false
  local totalPersonalReviveCount = 0
  for index, reviveId in ipairs(self.curReviveIdList_) do
    local countInfo = self.vm.GetPlayerReviveInfo(reviveId)
    if countInfo then
      if 0 <= countInfo.PersonReviveLimit then
        showCountTip = true
      end
      local count = countInfo.PersonReviveLimit - countInfo.PersonReviveCount
      if 0 < count then
        totalPersonalReviveCount = totalPersonalReviveCount + count
      end
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_num_tip, showCountTip)
  self.uiBinder.lab_num_tip.text = Lang("ReviveCountTip", {count = totalPersonalReviveCount})
end

return DeadView
