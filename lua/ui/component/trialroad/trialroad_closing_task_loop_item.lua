local super = require("ui.component.loop_list_view_item")
local TrialRoadClosingTaskLoopItem = class("TrialRoadClosingTaskLoopItem", super)

function TrialRoadClosingTaskLoopItem:ctor()
  self.trialroadData_ = Z.DataMgr.Get("trialroad_data")
end

function TrialRoadClosingTaskLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
end

function TrialRoadClosingTaskLoopItem:OnRefresh(data)
  self.data = data
  local trialRoadTargetRow_ = Z.TableMgr.GetTable("TargetTableMgr").GetRow(data.TargetId)
  if trialRoadTargetRow_ == nil then
    return
  end
  local isComplete = false
  local curProgress = 0
  local targetProgress = 0
  local color_ = self.trialroadData_.unfinishTargetColor
  if Z.ContainerMgr.DungeonSyncData.target.targetData[data.TargetId] then
    isComplete = Z.ContainerMgr.DungeonSyncData.target.targetData[data.TargetId].complete == 1
    curProgress = Z.ContainerMgr.DungeonSyncData.target.targetData[data.TargetId].nums
  end
  if isComplete then
    color_ = self.trialroadData_.finishTargetColor
  end
  self.uiBinder.lab_info.text = Z.RichTextHelper.ApplyColorTag(trialRoadTargetRow_.TargetDes, color_)
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if planetRoomInfo then
    targetProgress = trialRoadTargetRow_.Num
    local progressTXT_ = "( " .. curProgress .. "/" .. targetProgress .. " )"
    self.uiBinder.lab_num.text = Z.RichTextHelper.ApplyColorTag(progressTXT_, color_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_star_on, isComplete)
end

function TrialRoadClosingTaskLoopItem:OnUnInit()
end

return TrialRoadClosingTaskLoopItem
