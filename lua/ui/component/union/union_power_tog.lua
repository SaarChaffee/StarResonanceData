local UnionPowerTog = class("UnionPowerTog")

function UnionPowerTog:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function UnionPowerTog:Init(uiBinder, onToggleClick)
  self.uiBinder = uiBinder
  self.waiting_ = false
  self.uiBinder.tog_item:AddListener(function(isOn)
    self:switchToggle(isOn, true)
    if onToggleClick ~= nil then
      onToggleClick(isOn)
    end
  end)
end

function UnionPowerTog:UnInit()
  self.uiBinder = nil
end

function UnionPowerTog:switchToggle(isOn)
  if self.waiting_ then
    Z.TipsVM.ShowTips(100000)
    self.uiBinder.tog_item:SetIsOnWithoutNotify(not isOn)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on_bg, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off_bg, not isOn)
  Z.CoroUtil.create_coro_xpcall(function()
    local officialDataDict = self.unionData_.UnionInfo.officials
    local modifyOfficialData = table.zdeepCopy(officialDataDict[self.officialId_])
    modifyOfficialData.power[self.powerId_] = isOn
    local modifyOfficialDataList = {}
    modifyOfficialDataList[#modifyOfficialDataList + 1] = modifyOfficialData
    self.waiting_ = true
    local reply = self.unionVM_:AsyncReqChangeOfficials(self.unionVM_:GetPlayerUnionId(), E.UnionPowerDef.ModifyPositionPower, modifyOfficialDataList, self.unionData_.CancelSource:CreateToken())
    self.waiting_ = false
    if reply.errCode == 0 then
      Z.TipsVM.ShowTipsLang(1000535)
    end
    local curValue = officialDataDict[self.officialId_].power[self.powerId_]
    self.uiBinder.tog_item:SetIsOnWithoutNotify(curValue)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on_bg, curValue)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off_bg, not curValue)
  end)()
end

function UnionPowerTog:refreshUI(enableModify)
  local isOn = self.uiBinder.tog_item.isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on_bg, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off_bg, not isOn)
  if enableModify then
    self.uiBinder.canvas_group_item.alpha = 1
  else
    self.uiBinder.canvas_group_item.alpha = 0.3
  end
end

function UnionPowerTog:SetData(officialId, powerId, enableModify, defaultValue)
  self.officialId_ = officialId
  self.powerId_ = powerId
  self.uiBinder.lab_title.text = self.unionVM_:GetPowerName(powerId)
  self.uiBinder.canvas_group_item.interactable = enableModify
  self.uiBinder.tog_item:SetIsOnWithoutNotify(defaultValue)
  self:refreshUI(enableModify)
end

return UnionPowerTog
