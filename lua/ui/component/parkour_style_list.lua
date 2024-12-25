local ParkourStyleList = class("ParkourStyleList")
local ParkourStyleItem = require("ui.component.parkour_style_list.parkour_style_item")

function ParkourStyleList:ctor(panel)
  self.panel_ = panel
  self.uiUnit_ = nil
  self.gradeItemList = {}
  self.ParkourStyleItemCount = 0
  self.aliveParkourStyleItem_ = nil
  self.timerMgr = Z.TimerMgr.new()
end

function ParkourStyleList:RegisterEvent()
  Z.EventMgr:Add("OnQteSucess", self.OnQteFire, self)
  Z.EventMgr:Add("OnParkourStylePushItem", self.PushItem, self)
  Z.EventMgr:Add("ShowNextParkourItem", self.UpdateUI, self)
end

function ParkourStyleList:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function ParkourStyleList:OnQteFire(qteId, tipsId)
  if qteId ~= 4 and qteId ~= 5 and qteId ~= 6 and qteId ~= 7 then
    return
  end
  self:PushItem(tipsId)
end

function ParkourStyleList:PushItem(tipsId)
  if tipsId <= 0 then
    return
  end
  table.insert(self.gradeItemList, 1, tipsId)
  self:UpdateUI()
end

function ParkourStyleList:CheckHasAliveItem()
  if self.aliveParkourStyleItem_ == nil then
    return false
  end
  if self.aliveParkourStyleItem_:GetState() == E.ParkourStyleItemLifeCycle.Death then
    self.aliveParkourStyleItem_:Destroy()
    self.aliveParkourStyleItem_ = nil
    self.gradeItemList[#self.gradeItemList] = nil
    return false
  end
  return true
end

function ParkourStyleList:UpdateUI()
  if self:CheckHasAliveItem() then
    if self.aliveParkourStyleItem_:GetState() < E.ParkourStyleItemLifeCycle.Exit then
      self.aliveParkourStyleItem_:SetState(E.ParkourStyleItemLifeCycle.Exit)
    end
    return
  end
  if #self.gradeItemList == 0 then
    return
  end
  local tipsId = self.gradeItemList[#self.gradeItemList]
  self.ParkourStyleItemCount = self.ParkourStyleItemCount + 1
  self.aliveParkourStyleItem_ = ParkourStyleItem.new(self.panel_, "ParkourStyleItem" .. self.ParkourStyleItemCount, tipsId)
end

function ParkourStyleList:Destroy()
  if self.timerMgr ~= nil then
    self.timerMgr:Clear()
  end
  self.timerMgr = nil
  self.gradeItemList = nil
  self.aliveParkourStyleItem_:Destroy()
end

return ParkourStyleList
