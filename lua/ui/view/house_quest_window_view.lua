local UI = Z.UI
local super = require("ui.ui_view_base")
local House_quest_windowView = class("House_quest_windowView", super)
local houseQuestLoopItem = require("ui.component.house.house_quest_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function House_quest_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_quest_window")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function House_quest_windowView:OnActive()
  self:bindBtnClick()
  self:bindEvent()
  self:onStartAnimShow()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.HomeShopCurrencyDisplay)
  local row = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.HouseQuest, true)
  if not row then
    return
  end
  self.uiBinder.lab_title.text = row.Name
  self.uiBinder.img_icon_title:SetImage(row.Icon)
end

function House_quest_windowView:OnDeActive()
  for k, v in pairs(self.questList) do
    v:OnUnInit()
  end
  Z.EventMgr:RemoveObjAll(self)
  self:ClearAllUnits()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
  end
  self.timer_ = nil
  self.currencyItemList_:UnInit()
end

function House_quest_windowView:OnRefresh()
  self:refreshQuestList()
  self:refreshTime()
  self:refreshRemainSubmitCount()
end

function House_quest_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.House.HouseQuestChanged, self.OnHouseQuestChanged, self)
end

function House_quest_windowView:OnHouseQuestChanged()
  local questList = self.houseData_:GetAllTaskDatas()
  for k, v in ipairs(questList) do
    self.questList[v.id]:OnRefresh(v)
  end
  self:refreshTime()
  self:refreshRemainSubmitCount()
end

function House_quest_windowView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(40001)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.houseVm_.CloseHouseTaskView()
  end)
end

function House_quest_windowView:refreshQuestList()
  local questList = self.houseData_:GetAllTaskDatas()
  local path = self.uiBinder.pcd:GetString("house_quest_item_tpl")
  self.questList = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(questList) do
      local name = "quest_item_" .. v.id
      local unit = self:AsyncLoadUiUnit(path, name, self.uiBinder.task_root, self.cancelSource:CreateToken())
      if unit == nil then
        return
      end
      local houseQuestLoopItemClass = houseQuestLoopItem.new(self, unit)
      houseQuestLoopItemClass:OnInit()
      houseQuestLoopItemClass:OnRefresh(v)
      self.questList[v.id] = houseQuestLoopItemClass
    end
  end)()
end

function House_quest_windowView:refreshTime()
  local questTaskInfo = self.houseData_:GetTaskInfo()
  if questTaskInfo == nil then
    return
  end
  self.questRefreshTime = questTaskInfo.nextTaskReflushTime
  self:setRemianTime()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timer_ = self.timerMgr:StartTimer(function()
    self:setRemianTime()
  end, 1, -1)
end

function House_quest_windowView:refreshRemainSubmitCount()
  local remainCount = 0
  local questTaskInfo = self.houseData_:GetTaskInfo()
  if questTaskInfo == nil then
    return
  end
  remainCount = questTaskInfo.curLeftTimes
  self.uiBinder.lab_count.text = Lang("HouseQuestRemainTimes", {val = remainCount})
end

function House_quest_windowView:setRemianTime()
  local curRefreshSecond = Panda.Util.ZTimeUtils.ConvertToUnixTimestamp(self.questRefreshTime)
  local remainSeconds = curRefreshSecond - Z.TimeTools.Now() / 1000
  if remainSeconds <= 0 then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.uiBinder.lab_time.text = Lang("HouseQuestRefreshTime", {
    val = Z.TimeFormatTools.FormatToDHMS(math.max(remainSeconds, 0))
  })
end

function House_quest_windowView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return House_quest_windowView
