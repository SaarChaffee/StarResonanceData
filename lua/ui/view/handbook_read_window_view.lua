local UI = Z.UI
local super = require("ui.ui_view_base")
local Handbook_read_windowView = class("Handbook_read_windowView", super)
local loop_grid_view = require("ui.component.loop_grid_view")
local handbookReadingWorksLoopGridItem = require("ui.component.handbook.handbook_readingworks_loop_grid_item")
local handbookDefine = require("ui.model.handbook_define")
local handbookReadingBookTypeTableMap = require("table.HandbookReadingBookTypeTableMap")
local handbookReadingBookWorksTableMap = require("table.HandbookReadingBookWorksTableMap")

function Handbook_read_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "handbook_read_window")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
  self.handbookData_ = Z.DataMgr.Get("handbook_data")
end

function Handbook_read_windowView:OnActive()
  self.selectType_ = nil
  self.selectId_ = nil
  self.tabs_ = {}
  self.readingLoop_ = loop_grid_view.new(self, self.uiBinder.subview.node_list, handbookReadingWorksLoopGridItem, "handbook_read_item_tpl")
  self.readingLoop_:Init({})
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.subview.btn_read, function()
    if self.selectId_ == nil then
      return
    end
    Z.UIMgr:OpenView("handbook_read_detail_window", self.selectId_)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2087)
  end)
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.HandbookRead)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
  local mgr = Z.TableMgr.GetTable("NoteReadingBookTypeTableMgr")
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = self.uiBinder.uiprefab_cache:GetString("item_tog")
    for _, tab in ipairs(handbookReadingBookTypeTableMap.ReadingBookType) do
      local readingWorks = handbookReadingBookWorksTableMap.ReadingBookWorks[tab]
      if readingWorks and next(readingWorks) then
        local config = mgr.GetRow(tab)
        local unitName = "togs_" .. config.Id
        local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_tog)
        if unit then
          unit.img_on:SetImage(config.ReadingBookDes)
          unit.img_off:SetImage(config.ReadingBookDes)
          unit.tog_tab_select.group = self.uiBinder.togs_group
          unit.tog_tab_select:AddListener(function(isOn)
            if isOn then
              self.commonVM_.CommonPlayTogAnim(unit.anim_tog, self.cancelSource:CreateToken())
              self:selectType(config.Id)
            end
          end)
          table.insert(self.tabs_, unit)
        end
      end
    end
    self.uiBinder.togs_group:SetAllTogglesOff()
    self.tabs_[1].tog_tab_select.isOn = true
  end)()
  Z.EventMgr:Add(Z.ConstValue.Handbook.ReadDetailRefresh, self.refreshGridLoop, self)
end

function Handbook_read_windowView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Handbook.ReadDetailRefresh, self.refreshGridLoop, self)
  self.uiBinder.togs_group:ClearAll()
  self.tabs_ = {}
  self.readingLoop_:UnInit()
  self.readingLoop_ = nil
end

function Handbook_read_windowView:OnRefresh()
end

function Handbook_read_windowView:selectType(type)
  if type == self.selectType_ then
    return
  end
  self.selectType_ = type
  local readingWorks = handbookReadingBookWorksTableMap.ReadingBookWorks[self.selectType_]
  if readingWorks then
    local mgr = Z.TableMgr.GetTable("NoteReadingBookWorksTableMgr")
    table.sort(readingWorks, function(a, b)
      local aConfig = mgr.GetRow(a)
      local bConfig = mgr.GetRow(b)
      if aConfig and bConfig then
        local aState = handbookDefine.UnitState.IsLock
        for _, target in ipairs(aConfig.TargetType) do
          local temp = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Read, target)
          aState = math.min(temp, aState)
        end
        local bState = handbookDefine.UnitState.IsLock
        for _, target in ipairs(bConfig.TargetType) do
          local temp = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Read, target)
          bState = math.min(temp, bState)
        end
        if aState == bState then
          return aConfig.Episode < bConfig.Episode
        else
          return aState < bState
        end
      else
        return false
      end
    end)
    self.readingLoop_:ClearAllSelect()
    self.readingLoop_:RefreshListView(readingWorks, true)
    self.readingLoop_:SetSelected(1)
  else
    self.readingLoop_:ClearAllSelect()
    self.readingLoop_:RefreshListView({})
  end
end

function Handbook_read_windowView:SelectId(id)
  if id == self.selectId_ then
    return
  end
  self.selectId_ = id
  self:refreshSubView()
end

function Handbook_read_windowView:refreshSubView()
  local unlockCount = 0
  local allCount = 0
  local readingWorkConfig = Z.TableMgr.GetTable("NoteReadingBookWorksTableMgr").GetRow(self.selectId_)
  if readingWorkConfig then
    for _, target in ipairs(readingWorkConfig.TargetType) do
      if self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Read, target) then
        unlockCount = unlockCount + 1
      end
      allCount = allCount + 1
    end
    self.uiBinder.subview.lab_title.text = readingWorkConfig.WorksName
    self.uiBinder.subview.lab_content.text = readingWorkConfig.ReadingBookDes
    self.uiBinder.subview.lab_gather.text = Lang("HandbookIsCollection", {val1 = unlockCount, val2 = allCount})
  end
end

function Handbook_read_windowView:refreshGridLoop()
  self.readingLoop_:RefreshAllShownItem()
end

return Handbook_read_windowView
