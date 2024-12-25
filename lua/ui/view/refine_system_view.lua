local UI = Z.UI
local super = require("ui.ui_view_base")
local Refine_systemView = class("Refine_systemView", super)
local loopScrollRect_ = require("ui/component/loopscrollrect")
local smash_loop_item = require("ui.component.refine.smash_loop_item")
local itemClass = require("common.item")

function Refine_systemView:ctor()
  self.panel = nil
  super.ctor(self, "refine_system")
  self.refineData = Z.DataMgr.Get("refine_data")
  self.refineTips1Name = "refineTips1"
  self.refineTips2Name = "refineTips2"
  self.refineSystemVm = Z.VMMgr.GetVM("refine_system")
  self.timerList = {}
  self.timerMgr = Z.TimerMgr.new()
end

function Refine_systemView:OnActive()
  self.refineSystemVm.ResetSmashItemData()
  self.refineSystemVm.WatcherRefineChange()
  self:init()
  self:BindLuaAttrWatchers()
  self:BindEvents()
end

function Refine_systemView:OnDeActive()
  self.refineSystemVm.RefineUnRegWatcher()
  for i = 1, #self.timerList do
    self.timerMgr:StopTimer(self.timerList[i])
  end
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self:ClearAllUnits()
end

function Refine_systemView:init()
  self.panel.lab_name.TMPLab.text = Lang("Grinder")
  self.panel.btn_refine.lab_name.TMPLab.text = Lang("Smash")
  self.panel.btn_onekey_add.lab_name.TMPLab.text = Lang("OneKeyPush")
  self.panel.btn_onekey_receive.lab_name.TMPLab.text = Lang("OneKeyReceive")
  self.itemClassTab_ = {}
  self:AddAsyncClick(self.panel.btn_smash.Btn, function()
    self.refineSystemVm.CloseRefineSystemView()
  end, nil, nil)
  self.itemsScrollRect_ = loopScrollRect_.new(self.panel.loopscroll_prop.VLoopScrollRect, self, smash_loop_item)
  local ids = self.refineSystemVm.GetShowItemIds()
  self.itemsScrollRect_:SetData(ids, true, true, 0)
  self.itemsScrollRect_:SetCanMultiSelected(true)
  Z.CoroUtil.create_coro_xpcall(function()
    self:initRefineView()
    self:initBtnClick()
    self:refreshEnergy()
  end)()
end

function Refine_systemView:initBtnClick()
  self:AddAsyncClick(self.panel.middle.group_save.btn_up.Btn, function()
    local viewData = {}
    viewData.viewType = "tips2"
    Z.UIMgr:OpenView("refine_dialog", viewData)
  end, nil, nil)
  self:AddAsyncClick(self.panel.btn_onekey_add.btn.Btn, function()
    self.refineSystemVm.AsyncInstantRefine(self.cancelSource:CreateToken())
  end, nil, nil)
  self:AddAsyncClick(self.panel.btn_onekey_receive.btn.Btn, function()
    local items = {}
    local energyInfo = Z.ContainerMgr.CharSerialize.energyItem.energyInfo
    for k1, v1 in pairs(energyInfo) do
      for k2, v2 in pairs(v1.energyItemInfo) do
        if v2.refineState == Z.PbEnum("ERefineState", "Receive") then
          local refineItem = self.refineFrameList[k1].refineItemList[k2]
          local itemId = refineItem.itemId
          local itemCount = refineItem.itemCount
          if not items[itemId] then
            items[itemId] = itemCount
          else
            items[itemId] = items[itemId] + itemCount
          end
        end
      end
    end
    if not next(items) then
      Z.TipsVM.ShowTipsLang(500005)
      return
    end
    local ret = self.refineSystemVm.AsyncInstantReceive(self.cancelSource:CreateToken())
    if ret then
      local itemShowVm = Z.VMMgr.GetVM("item_show")
      local acquireList = {}
      for key, value in pairs(items) do
        table.insert(acquireList, {configId = key, count = value})
      end
      itemShowVm.OpenItemShowView(acquireList)
    end
  end, nil, nil)
  local smashFunc = function()
    local decomposeData = self.refineData:GetSmashItemConfigData()
    local ret = self.refineSystemVm.AsyncDecomposeItem(decomposeData, 100242, self.cancelSource:CreateToken())
    if ret then
      self.refineSystemVm.ResetSmashItemData()
      local newIds = self.refineSystemVm.GetShowItemIds()
      self.itemsScrollRect_:SetData(newIds, true, true, 0)
      Z.EventMgr:Dispatch(Z.ConstValue.Refine.CancelSelected, false)
      self:refreshEnergy()
      self:updateSmashBtnGray()
    end
  end
  self:AddAsyncClick(self.panel.btn_refine.btn.Btn, function()
    local smashItemData = self.refineData:GetSmashItemData()
    if not next(smashItemData) then
      Z.TipsVM.ShowTipsLang(500002)
      return
    end
    local nowAddEnergy = self.refineData:GetAddEnergy(true)
    if nowAddEnergy > Z.ContainerMgr.CharSerialize.energyItem.energyLimit then
      local viewData = {
        viewType = "normal",
        labDesc = Lang("RefineTips3"),
        onConfirm = function()
          smashFunc()
          Z.UIMgr:CloseView("refine_dialog")
        end
      }
      Z.UIMgr:OpenView("refine_dialog", viewData)
      return
    end
    smashFunc()
  end, nil, nil)
  self:updateSmashBtnGray()
end

function Refine_systemView:initRefineView()
  self.refineFrameList = {
    self.panel.refine_frame_1,
    self.panel.refine_frame_2,
    self.panel.refine_frame_3
  }
  self.refineGroupPropList = {
    self.panel.middle.refine_group_prop_1,
    self.panel.middle.refine_group_prop_2,
    self.panel.middle.refine_group_prop_3
  }
  self.refineFramePosList = {}
  self.refineGroupPropPosList = {}
  for i = 1, 3 do
    local cfg = Z.TableMgr.GetTable("ChangeQueueTableMgr").GetRow(i)
    if cfg then
      do
        local refineFrame = self.refineFrameList[i]
        refineFrame.lab.TMPLab.text = Lang("RefineTitle" .. i)
        refineFrame.refineItemList = {
          refineFrame.refine_item_prop_1,
          refineFrame.refine_item_prop_2,
          refineFrame.refine_item_prop_3
        }
        local framePosCfg = refineFrame.Ref.RectTransform.anchoredPosition
        framePosCfg.sort = cfg.Sort
        self.refineFramePosList[#self.refineFramePosList + 1] = framePosCfg
        local refineGroupProp = self.refineGroupPropList[i]
        refineGroupProp.lab.TMPLab.text = cfg.Consumable[1][2]
        local propPosCfg = refineGroupProp.Ref.RectTransform.anchoredPosition
        propPosCfg.sort = cfg.Sort
        self.refineGroupPropPosList[#self.refineGroupPropPosList + 1] = propPosCfg
        for j = 1, 3 do
          local refineItem = refineFrame.refineItemList[j]
          refineItem.receive_lab.TMPLab.text = Lang("Receive")
          refineItem.wait_lab.TMPLab.text = Lang("InWait")
          refineItem.itemId = cfg.ExchangeGoods[j][1]
          refineItem.itemCount = cfg.ExchangeGoods[j][2]
          local unitName = "item" .. i .. j
          self:AsyncLoadUiUnit("ui/prefabs/new_common/c_com_item_backpack_tpl", unitName, refineItem.item_group.Trans)
          local nowUnit = self.units[unitName]
          self.itemClassTab_[unitName] = itemClass.new(self)
          self.itemClassTab_[unitName]:Init({
            unit = nowUnit,
            configId = cfg.ExchangeGoods[j][1]
          })
          self:AddAsyncClick(refineItem.btn_add.Btn, function()
            local backpackVm = Z.VMMgr.GetVM("backpack")
            local nowCount = backpackVm.GetItemCount(cfg.Consumable[j][1])
            if nowCount < cfg.Consumable[j][2] then
              Z.TipsVM.ShowTipsLang(500003)
              return
            end
            local ret = self.refineSystemVm.AsyncRefineItem(i, j, self.cancelSource:CreateToken())
            if ret then
            end
          end, nil, nil)
          self:AddAsyncClick(refineItem.btn_cloes.Btn, function()
            local viewData = {
              viewType = "tips1",
              putItemId = cfg.Condition[j][2],
              putItemCount = cfg.Condition[j][3],
              queueIndex = i,
              columnIndex = j
            }
            Z.UIMgr:OpenView("refine_dialog", viewData)
          end, nil, nil)
          self:AddAsyncClick(refineItem.img_title_receive.Btn, function()
            local ret = self.refineSystemVm.AsyncGainItem(i, j, self.cancelSource:CreateToken())
            if ret then
              local items = {
                {
                  configId = refineItem.itemId,
                  count = refineItem.itemCount
                }
              }
              local itemShowVm = Z.VMMgr.GetVM("item_show")
              itemShowVm.OpenItemShowView(items)
            end
          end, nil, nil)
        end
      end
    end
  end
  self:initSort()
  self:initRefineStatus()
end

function Refine_systemView:initSort()
  table.sort(self.refineFramePosList, function(a, b)
    return a.sort < b.sort
  end)
  table.sort(self.refineGroupPropPosList, function(a, b)
    return a.sort < b.sort
  end)
  for i = 1, 3 do
    self.refineFrameList[i].Ref:SetPosition(self.refineFramePosList[i])
    self.refineGroupPropList[i].Ref:SetPosition(self.refineGroupPropPosList[i])
  end
end

function Refine_systemView:initRefineStatus()
  local energyInfo = Z.ContainerMgr.CharSerialize.energyItem.energyInfo
  for i = 1, 3 do
    local cfg = Z.TableMgr.GetTable("ChangeQueueTableMgr").GetRow(i)
    if cfg then
      for j = 1, 3 do
        local changeData
        if energyInfo[i] and energyInfo[i].energyItemInfo[j] then
          changeData = energyInfo[i].energyItemInfo[j]
        else
          local refineState
          if cfg.Condition[j][1] == 0 then
            refineState = Z.PbEnum("ERefineState", "Add")
          else
            refineState = Z.PbEnum("ERefineState", "Unlock")
          end
          changeData = {
            queueId = i,
            columnId = j,
            refineState = refineState
          }
        end
        self:updateRefineStatus(changeData)
      end
    end
  end
end

function Refine_systemView:updateSmashBtnGray()
  local smashItemData = self.refineData:GetSmashItemData()
  if not next(smashItemData) then
    self.panel.btn_refine.btn.Img:SetImage("ui/atlas/common/common_btn_bg_off")
  else
    self.panel.btn_refine.btn.Img:SetImage("ui/atlas/common/common_btn_bg_new_2")
  end
end

function Refine_systemView:updateRefineStatus(changeData)
  local queueId = changeData.queueId
  local columnId = changeData.columnId
  local refineState = changeData.refineState
  local oldStastus = self.refineData:GetRefineItemListData(queueId, columnId)
  local oldChangeData = {
    queueId = queueId,
    columnId = columnId,
    refineState = oldStastus
  }
  self:updateRefineView(oldChangeData, false)
  self:updateRefineView(changeData, true)
  self.refineSystemVm.SetRefineItemListData(queueId, columnId, refineState)
end

function Refine_systemView:updateCountDown(energyItemInfo)
  local refineItem = self.refineFrameList[energyItemInfo.queueId].refineItemList[energyItemInfo.columnId]
  local serverTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local diffTime = math.floor(Z.TimeTools.DiffTime(energyItemInfo.gainTime, serverTime))
  if 0 < diffTime then
    local countDownTimr = diffTime
    local countDownFunc = function()
      refineItem.time_lab.TMPLab.text = self.refineSystemVm.TimeFormat(countDownTimr)
      countDownTimr = countDownTimr - 1
    end
    countDownFunc()
    self.timerList[#self.timerList + 1] = self.timerMgr:StartTimer(function()
      countDownFunc()
    end, 1, countDownTimr)
  end
end

function Refine_systemView:updateRefineView(energyItemInfo, visibleStatus)
  local queueId = energyItemInfo.queueId
  local columnId = energyItemInfo.columnId
  local refineState = energyItemInfo.refineState
  local refineItem = self.refineFrameList[queueId].refineItemList[columnId]
  if refineState == Z.PbEnum("ERefineState", "Add") then
    refineItem.btn_add:SetVisible(visibleStatus)
    refineItem.img_ash:SetVisible(visibleStatus)
  elseif refineState == Z.PbEnum("ERefineState", "CountDown") then
    refineItem.img_title_time:SetVisible(visibleStatus)
    if visibleStatus then
      self:updateCountDown(energyItemInfo)
    end
  elseif refineState == Z.PbEnum("ERefineState", "Receive") then
    refineItem.img_title_receive:SetVisible(visibleStatus)
  elseif refineState == Z.PbEnum("ERefineState", "Unlock") then
    refineItem.btn_cloes:SetVisible(visibleStatus)
    refineItem.img_ash:SetVisible(visibleStatus)
  elseif refineState == Z.PbEnum("ERefineState", "Wait") then
    refineItem.img_title_wait:SetVisible(visibleStatus)
  end
end

function Refine_systemView:refreshEnergy()
  local materials = Z.Global.EnergyAddMax
  local limitCfgData = materials[table.zcount(materials)][1]
  local energyItem = Z.ContainerMgr.CharSerialize.energyItem
  local smashItemData = self.refineData:GetSmashItemData()
  local limitData = energyItem.energyLimit
  local backpackVm = Z.VMMgr.GetVM("backpack")
  local nowData = backpackVm.GetItemCount(E.SpecialItem.RefineEnergy)
  local addData = self.refineData:GetAddEnergy(true)
  if limitData < addData then
    addData = limitData
  end
  local groupSave = self.panel.middle.group_save
  if nowData < addData then
    groupSave.digit_1:SetVisible(true)
    groupSave.digit_2:SetVisible(false)
    groupSave.digit_1.lab_1.TMPLab.text = nowData
    groupSave.digit_1.lab_2.TMPLab.text = "+" .. addData - nowData
  else
    groupSave.digit_1:SetVisible(false)
    groupSave.digit_2:SetVisible(true)
    groupSave.digit_2.lab_1.TMPLab.text = nowData
  end
  self.panel.middle.content_1.Img.fillAmount = nowData / limitData
  self.panel.middle.content_2.Img.fillAmount = addData / limitData
  groupSave.lab_3.TMPLab.text = limitData
  if limitCfgData == limitData then
    self.panel.middle.group_save.btn_max:SetVisible(true)
  end
end

function Refine_systemView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Refine.RefreshEnergy, self.refreshEnergy, self)
  Z.EventMgr:Add(Z.ConstValue.Refine.RefreshItemStatus, self.updateRefineStatus, self)
  Z.EventMgr:Add(Z.ConstValue.Refine.UpdateSmashBtnGray, self.updateSmashBtnGray, self)
end

function Refine_systemView:BindLuaAttrWatchers()
  Z.EventMgr:RemoveObjAll()
end

function Refine_systemView:OnRefresh()
end

return Refine_systemView
