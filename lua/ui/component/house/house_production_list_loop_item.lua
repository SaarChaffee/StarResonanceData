local super = require("ui.component.loop_grid_view_item")
local itemClass = require("common.item_binder")
local HouseProductionListLoopItem = class("HouseProductionListLoopItem", super)

function HouseProductionListLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = itemClass.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.binder_item
  })
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.timerMgr_ = Z.TimerMgr.new()
end

function HouseProductionListLoopItem:OnRefresh(data)
  self.data_ = data
  self.buildInfo_ = self.houseData_:GetBuildInfosByIndexAndType(self.uiView_:GetCurrentType(), self.Index)
  self.isProduction_ = self.buildInfo_ ~= nil
  self.isLeisure_ = self.buildInfo_ == nil
  self.isFinish_ = false
  if self.buildInfo_ then
    self.isFinish_ = self.buildInfo_.endTime <= Z.ServerTime:GetServerTime() / 1000
    if not self.isFinish_ then
      local time = math.ceil(self.buildInfo_.endTime - Z.ServerTime:GetServerTime() / 1000)
      local furnitureItemRow = Z.TableMgr.GetRow("HousingItemsMgr", self.buildInfo_.furnitureId)
      if not furnitureItemRow then
        return
      end
      local time1 = furnitureItemRow.BuildTime * (self.buildInfo_.furnitureCount - self.buildInfo_.accelerateCount)
      self.updateTimer_ = self.timerMgr_:StartTimer(function()
        local time = math.ceil(self.buildInfo_.endTime - Z.ServerTime:GetServerTime() / 1000)
        self.uiBinder.lab_time.text = Lang("RemainingTime:") .. Z.TimeFormatTools.FormatToDHMS(time)
        self.uiBinder.img_progress.fillAmount = 1 - time / time1
        if time <= 0 then
          self.isFinish_ = true
          self:refreshUI()
          self.uiBinder.lab_time.text = ""
          self.timerMgr_:StopTimer(self.updateTimer_)
        end
      end, 1, time, nil, nil, true)
    else
      self.uiBinder.lab_time.text = ""
    end
    local name = self.itemsVm_.ApplyItemNameWithQualityTag(self.buildInfo_.furnitureId)
    self.uiBinder.lab_name.text = name
    self.uiBinder.lab_name_ing.text = name
    local itemData = {}
    itemData.uiBinder = self.uiBinder.binder_item
    itemData.configId = self.buildInfo_.furnitureId
    itemData.lab = self.buildInfo_.furnitureCount - self.buildInfo_.accelerateCount
    itemData.labType = E.ItemLabType.Str
    self.itemClass_:RefreshByData(itemData)
  end
  self:refreshUI()
end

function HouseProductionListLoopItem:refreshUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_progress_bg, self.isProduction_ and not self.isFinish_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_add, self.isLeisure_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_completed, self.buildInfo_ ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ing, self.isProduction_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_complete, self.isFinish_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name, not self.isProduction_)
end

function HouseProductionListLoopItem:OnSelected(OnSelected)
  if not self.buildInfo_ then
    self.parent:UnSelectIndex(self.Index)
    return
  end
  if OnSelected then
    self.uiView_:OnSelectedProductionItem(self.buildInfo_)
  end
end

function HouseProductionListLoopItem:OnRecycle()
  self.timerMgr_:Clear()
end

function HouseProductionListLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  self.timerMgr_:Clear()
  self.timerMgr_ = nil
end

return HouseProductionListLoopItem
