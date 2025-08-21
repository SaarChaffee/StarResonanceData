local UI = Z.UI
local super = require("ui.ui_view_base")
local Lifework_record_popupView = class("Lifework_record_popupView", super)
local lifeWorkAwardLoopItem = require("ui.component.life_work.life_work_settlement_reward_item")
local loopListView = require("ui.component.loop_list_view")
local maxRowPerPage = 4

function Lifework_record_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "lifework_record_popup")
  self.lifeWorkVM_ = Z.VMMgr.GetVM("life_work")
  self.lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
end

function Lifework_record_popupView:OnActive()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_list, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_page, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_left, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_right, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_page, false)
  self.curPage = 1
  self:initBtnClick()
  Z.EventMgr:Add(Z.ConstValue.LifeWork.LifeWorkRecordReady, self.LifeWorkRecordReady, self)
  local success = self.lifeProfessionWorkData_:TryGetRecord()
  if not success then
    Z.CoroUtil.create_coro_xpcall(function()
      self.lifeWorkVM_.AsyncRequsetGetWorkHistory()
    end)()
  end
end

function Lifework_record_popupView:LifeWorkRecordReady()
  self.recordList = self.lifeProfessionWorkData_:GetRecord()
  if self.recordList == nil then
    return
  end
  self:refreshContent()
end

function Lifework_record_popupView:initBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    self.lifeWorkVM_.CloseWorkRecordView()
  end)
  self:AddClick(self.uiBinder.btn_arrow_left, function()
    self.curPage = self.curPage - 1
    self:refreshContent()
  end)
  self:AddClick(self.uiBinder.btn_arrow_right, function()
    self.curPage = self.curPage + 1
    self:refreshContent()
  end)
end

function Lifework_record_popupView:OnDeActive()
  self.curPage = 1
  if self.unitTable then
    for k, v in pairs(self.unitTable) do
      v.rewardLoopListView_:UnInit()
      v.rewardLoopListView_ = nil
      self:RemoveUiUnit(k)
    end
  end
  Z.EventMgr:RemoveObjAll(self)
end

function Lifework_record_popupView:OnRefresh()
end

function Lifework_record_popupView:refreshContent()
  local recordCnt = table.zcount(self.recordList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, recordCnt == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_list, 0 < recordCnt)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_page, 0 < recordCnt)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_left, 0 < recordCnt)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_right, 0 < recordCnt)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_page, 0 < recordCnt)
  if recordCnt == 0 then
    return
  end
  local pageCnt = math.ceil(recordCnt / maxRowPerPage)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_left, self.curPage > 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_right, pageCnt > self.curPage)
  self.uiBinder.lab_page.text = string.zconcat(self.curPage, " / ", pageCnt)
  if self.unitTable then
    for k, v in pairs(self.unitTable) do
      v.rewardLoopListView_:UnInit()
      v.rewardLoopListView_ = nil
      self:RemoveUiUnit(k)
    end
  end
  self.unitTable = {}
  local beginIndex = (self.curPage - 1) * maxRowPerPage + 1
  for i = 1, maxRowPerPage do
    if recordCnt < beginIndex then
      break
    end
    local recordData = self.recordList[beginIndex]
    local unitName = "record_tpl" .. i
    local unitPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "record_tpl")
    Z.CoroUtil.create_coro_xpcall(function()
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.layout_list)
      if unit then
        self.unitTable[unitName] = unit
        self:refreshRecordItem(unit, recordData)
      end
    end)()
    beginIndex = beginIndex + 1
  end
end

function Lifework_record_popupView:refreshRecordItem(unit, recordData)
  unit.lab_time.text = Z.TimeFormatTools.TicksFormatTime(recordData.beginTime, E.TimeFormatType.YMDHMS)
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(recordData.lifeProfessionId)
  if lifeWorkTableRow == nil then
    return
  end
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(recordData.lifeProfessionId)
  if lifeProfessionTableRow == nil then
    return
  end
  unit.lab_place.text = lifeWorkTableRow.Address
  unit.lab_skill.text = lifeProfessionTableRow.Name
  unit.lab_num.text = recordData.cost
  local data = {}
  unit.rewardLoopListView_ = loopListView.new(self, unit.loop_item, lifeWorkAwardLoopItem, "com_item_square_1_8")
  unit.rewardLoopListView_:Init(data)
  unit.rewardLoopListView_:RefreshListView(recordData.reward)
end

return Lifework_record_popupView
