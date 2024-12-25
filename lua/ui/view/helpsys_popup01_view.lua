local UI = Z.UI
local super = require("ui.ui_view_base")
local Helpsys_popup01View = class("Helpsys_popup01View", super)
local contentPrefabPath = "ui/prefabs/helpsys/lab_content1"
local titlePrefabPath = "ui/prefabs/helpsys/lab_title_name"
local imagePrefabPath = "ui/prefabs/helpsys/node_rimg"
local FieldIdentificationEnum = {
  Title = 1,
  Content = 2,
  Image = 3
}

function Helpsys_popup01View:ctor()
  self.uiBinder = nil
  super.ctor(self, "helpsys_popup01")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.helpsysData_ = Z.DataMgr.Get("helpsys_data")
end

function Helpsys_popup01View:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self:startAnimatedShow()
  self:initListener()
  local data = self.helpsysData_:GetOtherDataById(self.viewData.id)
  local dataTable = self.helpsysData_:GetTableSegmentationDataById(data)
  if data == nil or next(dataTable) == nil then
    return
  end
  self.uiBinder.lab_title_name.text = data.Title
  Z.CoroUtil.create_coro_xpcall(function()
    local uiUnit
    local parentTrans = self.uiBinder.node_content.transform
    for i, v in ipairs(dataTable) do
      uiUnit = self:handleUiUnit(uiUnit, v.type, i, parentTrans)
      if uiUnit == nil then
        return
      end
      if tonumber(v.type) == FieldIdentificationEnum.Title then
        uiUnit.lab_content.text = v.value
      elseif tonumber(v.type) == FieldIdentificationEnum.Content then
        uiUnit.lab_content.text = Z.TableMgr.DecodeLineBreak(v.value)
      else
        uiUnit.rimg:SetImage(string.format("ui/textures/helpsys/%s", v.value))
      end
    end
  end)()
end

function Helpsys_popup01View:handleUiUnit(uiUnit, type, index, parentTransform)
  if type == nil then
    return
  end
  local convertedType = tonumber(type)
  if convertedType == FieldIdentificationEnum.Title then
    uiUnit = self:AsyncLoadUiUnit(titlePrefabPath, string.format("title_%s", index), parentTransform)
  elseif convertedType == FieldIdentificationEnum.Content then
    uiUnit = self:AsyncLoadUiUnit(contentPrefabPath, string.format("content_%s", index), parentTransform)
  else
    uiUnit = self:AsyncLoadUiUnit(imagePrefabPath, string.format("image_%s", index), parentTransform)
  end
  return uiUnit
end

function Helpsys_popup01View:OnDeActive()
end

function Helpsys_popup01View:OnRefresh()
  self:setBtnMaskHeight()
end

function Helpsys_popup01View:setBtnMaskHeight()
  self.uiBinder.layout:ForceRebuildLayoutImmediate()
  local height = self.uiBinder.node_content.rect.height
  local scrollviewHeight = self.uiBinder.cont_scroll_tips_tpl01.rect.height
  local DifferenceValue = scrollviewHeight - height
  if DifferenceValue < 0 then
    DifferenceValue = 0
  end
  self.uiBinder.btn_mask_rect:SetHeight(DifferenceValue)
end

function Helpsys_popup01View:initListener()
  self:AddClick(self.uiBinder.btn_mask, function()
    self.helpsysVM_:CloseFullScreenTipsView()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.helpsysVM_:CloseFullScreenTipsView()
  end)
end

function Helpsys_popup01View:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Helpsys_popup01View:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Z.DOTweenAnimType.Close)
end

return Helpsys_popup01View
