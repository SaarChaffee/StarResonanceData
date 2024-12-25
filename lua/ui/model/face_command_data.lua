local FaceCommandData = class("FaceCommandData")

function FaceCommandData:ctor(modelAttrList, hotId)
  self.changeDataValue_ = {}
  self.changeModelAttrList_ = modelAttrList
  self.hotId_ = hotId
end

function FaceCommandData:Do()
  local faceData = Z.DataMgr.Get("face_data")
  for optionEnum, data in pairs(self.changeDataValue_) do
    faceData:SetFaceOptionValue(optionEnum, data.targetValue, true)
  end
  self:refreshModelView()
end

function FaceCommandData:Undo()
  local faceData = Z.DataMgr.Get("face_data")
  for optionEnum, data in pairs(self.changeDataValue_) do
    faceData:SetFaceOptionValue(optionEnum, data.sourceValue, true)
  end
  self:refreshModelView()
end

function FaceCommandData:refreshModelView()
  if self.changeModelAttrList_ == nil then
    Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  else
    local attrVM = Z.VMMgr.GetVM("face_attr")
    for i = 1, #self.changeModelAttrList_ do
      attrVM.UpdateFaceAttr(self.changeModelAttrList_[i])
    end
  end
end

function FaceCommandData:AddChangeData(optionEnum, sourceValue, targetValue)
  if not self.changeDataValue_[optionEnum] then
    self.changeDataValue_[optionEnum] = {}
    self.changeDataValue_[optionEnum].sourceValue = sourceValue
  end
  self.changeDataValue_[optionEnum].targetValue = targetValue
end

function FaceCommandData:IsAttrChange()
  return table.zcount(self.changeDataValue_) > 0
end

function FaceCommandData:SetModelAttr(modelAttrList)
  self.changeModelAttrList_ = modelAttrList
end

function FaceCommandData:GetHotId()
  return self.hotId_
end

return FaceCommandData
