local super = require("ui.model.data_base")
local CapabilityAssessmentData = class("CapabilityAssessmentData", super)

function CapabilityAssessmentData:ctor()
  super.ctor(self)
end

function CapabilityAssessmentData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.assessResultTableRows_ = nil
  self.assessTableRows_ = nil
  self.fightAttrTableRows_ = nil
end

function CapabilityAssessmentData:GetAssessResultCfgs()
  if not self.assessResultTableRows_ then
    self.assessResultTableRows_ = Z.TableMgr.GetTable("AssessResultTableMgr").GetDatas()
  end
  return self.assessResultTableRows_
end

function CapabilityAssessmentData:GetAssessCfgs()
  if not self.assessTableRows_ then
    self.assessTableRows_ = Z.TableMgr.GetTable("AssessTableMgr").GetDatas()
  end
  return self.assessTableRows_
end

function CapabilityAssessmentData:GetFightAttrCfgs()
  if not self.fightAttrTableRows_ then
    self.fightAttrTableRows_ = Z.TableMgr.GetTable("FightAttrTableMgr").GetDatas()
  end
  return self.fightAttrTableRows_
end

function CapabilityAssessmentData:UnInit()
  self.CancelSource:Recycle()
  self.assessResultTableRows_ = nil
  self.assessTableRows_ = nil
  self.fightAttrTableRows_ = nil
end

function CapabilityAssessmentData:Clear()
end

return CapabilityAssessmentData
