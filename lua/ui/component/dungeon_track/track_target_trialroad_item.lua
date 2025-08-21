local TrackTargetTrialRoadItem = class("TrackTargetTrialRoadItem")

function TrackTargetTrialRoadItem:ctor()
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  self.trialroadData_ = Z.DataMgr.Get("trialroad_data")
end

function TrackTargetTrialRoadItem:Init(uiBinder, parentView)
  self.uiBinder = uiBinder
  self.parentView_ = parentView
end

function TrackTargetTrialRoadItem:UnInit()
  self.uiBinder = nil
  self.parentView_ = nil
  self.targetData_ = nil
end

function TrackTargetTrialRoadItem:SetData(targetData)
  self.targetData_ = targetData
  local targetCfg = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetData.targetId)
  if not targetCfg then
    return
  end
  local isCompelete = targetData.complete == 1
  self:SetIcon(isCompelete)
  self:RefreshContent(isCompelete, targetCfg, targetData)
end

function TrackTargetTrialRoadItem:SetIcon(isComplete)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isComplete)
end

function TrackTargetTrialRoadItem:RefreshContent(isComplete, targetCfg, targetData)
  local targetDesColor = isComplete and self.trialroadData_.finishTargetColor or self.trialroadData_.unfinishTargetColor
  self.uiBinder.lab_info.text = Z.RichTextHelper.ApplyColorTag(targetCfg.TargetDes, targetDesColor)
  local progressTXT = string.format("(%d / %d)", targetData.nums, targetCfg.Num)
  self.uiBinder.lab_num.text = Z.RichTextHelper.ApplyColorTag(progressTXT, targetDesColor)
end

function TrackTargetTrialRoadItem:OnLanguageChange()
  self:SetData(self.targetData_)
end

return TrackTargetTrialRoadItem
