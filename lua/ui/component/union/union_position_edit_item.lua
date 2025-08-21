local UnionPositionEditItem = class("UnionPositionEditItem")
local lineColor = {
  [E.UnionPositionDef.President] = Color.New(0.84, 0.73, 0.47),
  [E.UnionPositionDef.VicePresident] = Color.New(0.53, 0.87, 0.66),
  [E.UnionPositionDef.Administrator] = Color.New(0.82, 0.71, 0.93),
  [E.UnionPositionDef.Member] = Color.New(0.89, 0.89, 0.89),
  [E.UnionPositionDef.Custom1] = Color.New(0.89, 0.89, 0.89),
  [E.UnionPositionDef.Custom2] = Color.New(0.89, 0.89, 0.89),
  [E.UnionPositionDef.Custom3] = Color.New(0.89, 0.89, 0.89),
  [E.UnionPositionDef.Custom4] = Color.New(0.89, 0.89, 0.89)
}

function UnionPositionEditItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function UnionPositionEditItem:Init(uiBinder)
  self.uiBinder = uiBinder
  self.uiBinder.btn_modify:AddListener(function()
    self:onModifyBtnClick()
  end)
  self.uiBinder.input_position:AddEndEditListener(function(text)
    self:onInputEndEdit(text)
  end)
  self.uiBinder.input_position:AddListener(function()
    self:onNameInputChanged()
  end)
end

function UnionPositionEditItem:UnInit()
  self.uiBinder = nil
end

function UnionPositionEditItem:onModifyBtnClick()
  if self.unionVM_:CheckPlayerPower(E.UnionPowerDef.ModifyPositionName) then
    self:openInputField()
  else
    Z.TipsVM.ShowTipsLang(1000527)
  end
end

function UnionPositionEditItem:onInputEndEdit(text)
  local oldText = self.uiBinder.lab_position.text
  local textLength = string.zlenNormalize(text)
  local limitArray = Z.Global.MemberTitleLength
  if textLength < limitArray[1] or textLength > limitArray[2] then
    Z.TipsVM.ShowTipsLang(1000542)
    self:closeInputField(oldText)
    return
  end
  local hasSameName = false
  local sameNameCheck = {}
  local officialDataDict = self.unionData_.UnionInfo.officials
  local modifyOfficialData = table.zdeepCopy(officialDataDict[self.officialId_])
  modifyOfficialData.Name = text
  for id, officialData in pairs(officialDataDict) do
    local curName
    if id == self.officialId_ then
      curName = text
    else
      curName = officialData.Name
    end
    if sameNameCheck[curName] == nil then
      sameNameCheck[curName] = true
    else
      hasSameName = true
      break
    end
  end
  if hasSameName then
    Z.TipsVM.ShowTipsLang(1000529)
    self:closeInputField(oldText)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local modifyOfficialDataList = {}
      modifyOfficialDataList[#modifyOfficialDataList + 1] = modifyOfficialData
      local reply = self.unionVM_:AsyncReqChangeOfficials(self.unionVM_:GetPlayerUnionId(), E.UnionPowerDef.ModifyPositionName, modifyOfficialDataList, self.unionData_.CancelSource:CreateToken())
      if reply.errCode == 0 then
        Z.TipsVM.ShowTipsLang(1000528)
        self:closeInputField(text)
      else
        self:closeInputField(oldText)
      end
    end)()
  end
end

function UnionPositionEditItem:onNameInputChanged()
  local length = string.zlenNormalize(self.uiBinder.input_position.text)
  local maxLimit = Z.Global.MemberTitleLength[2]
  if length > maxLimit then
    self.uiBinder.input_position.text = string.zcutNormalize(self.uiBinder.input_position.text, maxLimit)
  end
end

function UnionPositionEditItem:openInputField()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_position, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_position, true)
  self.uiBinder.input_position:SetTextWithoutNotify(self.uiBinder.lab_position.text)
  self.uiBinder.input_position:ActivateInputField()
end

function UnionPositionEditItem:closeInputField(text)
  self.uiBinder.lab_position.text = text
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_position, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_position, false)
end

function UnionPositionEditItem:SetData(officialId, name)
  self.officialId_ = officialId
  local isCustomPosition = self.unionVM_:IsCustomPosition(officialId)
  local isDefaultPosition = self.unionVM_:IsDefaultPosition(officialId)
  local isDefaultManager = isCustomPosition == false and isDefaultPosition == false
  self.uiBinder.lab_position.text = name
  self.uiBinder.img_line_position:SetColor(lineColor[officialId])
  if isDefaultManager then
    local config = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(officialId)
    local curNum = #self.unionVM_:GetOfficialMemberList(officialId)
    self.uiBinder.lab_number.text = curNum .. "/" .. config.PositionNum
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_position, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_position, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_number, isDefaultManager)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_modify, isCustomPosition)
end

return UnionPositionEditItem
