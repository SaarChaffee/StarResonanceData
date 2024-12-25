local UnionAppointEditItem = class("UnionAppointEditItem")

function UnionAppointEditItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function UnionAppointEditItem:Init(uiBinder, parentView)
  self.uiBinder = uiBinder
  self.parentView = parentView
  self.uiBinder.btn_click:AddListener(function()
    self:onItemClick()
  end)
end

function UnionAppointEditItem:UnInit()
  self.uiBinder = nil
  self.parentView = nil
end

function UnionAppointEditItem:SetData(officialData, memberData)
  if officialData == nil then
    self.uiBinder.Ref.UIComp:SetVisible(false)
    return
  end
  self.officialData_ = officialData
  self.memberData_ = memberData
  self.config_ = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(officialData.officialId)
  self.uiBinder.Ref.UIComp:SetVisible(true)
  local isPresidentPosition = officialData.officialId == E.UnionPositionDef.President
  local isCustomPosition = self.unionVM_:IsCustomPosition(officialData.officialId)
  local isDefaultPosition = self.unionVM_:IsDefaultPosition(officialData.officialId)
  local isManager = isCustomPosition == false and isDefaultPosition == false
  if isManager then
    if isPresidentPosition then
      self.uiBinder.lab_edit.text = Lang("TransferPresident")
    else
      local memberList = self.unionVM_:GetOfficialMemberList(officialData.officialId)
      self.uiBinder.lab_edit.text = officialData.Name .. " (" .. #memberList .. "/" .. self.config_.PositionNum .. ")"
    end
  else
    self.uiBinder.lab_edit.text = officialData.Name
  end
  local isSamePosition = officialData.officialId == memberData.baseData.officialId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSamePosition)
end

function UnionAppointEditItem:onItemClick()
  if self.unionVM_:IsPlayerUnionPresident() and self.officialData_.officialId == E.UnionPositionDef.President then
    local param = {
      player = {
        name = self.memberData_.socialData.basicData.name
      }
    }
    local desc = Lang("UnionTransferPresidentTips", param)
    Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
      local reply = self.unionVM_:AsyncReqTransferPresident(self.unionVM_:GetPlayerUnionId(), self.memberData_.socialData.basicData.charID, self.parentView.cancelSource:CreateToken())
      if reply.errorCode == 0 then
        self.unionVM_:CloseAppointEditTips()
      end
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  else
    local isDefaultPosition = self.unionVM_:IsDefaultPosition(self.officialData_.officialId)
    local isCustomPosition = self.unionVM_:IsCustomPosition(self.officialData_.officialId)
    local memList = self.unionVM_:GetOfficialMemberList(self.officialData_.officialId)
    if not isCustomPosition and not isDefaultPosition and #memList >= self.config_.PositionNum then
      Z.TipsVM.ShowTipsLang(1000543)
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local modifyDict = {}
      modifyDict[self.memberData_.socialData.basicData.charID] = self.officialData_.officialId
      local reply = self.unionVM_:AsyncReqChangeOfficialMembers(self.unionVM_:GetPlayerUnionId(), modifyDict, self.parentView.cancelSource:CreateToken())
      if reply.errorCode == 0 then
        Z.TipsVM.ShowTipsLang(1000592)
        self.unionVM_:CloseAppointEditTips()
      end
    end)()
  end
end

return UnionAppointEditItem
