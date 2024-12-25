local UI = Z.UI
local super = require("ui.ui_subview_base")
local Proficiency_tips_subView = class("Proficiency_tips_subView", super)
local itemClass = require("common.item_binder")

function Proficiency_tips_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "proficiency_tips_sub", "proficiency/proficiency_tips_sub", UI.ECacheLv.None)
  self.proficiencyVm_ = Z.VMMgr.GetVM("proficiency")
  self.profilciencyData_ = Z.DataMgr.Get("proficiency_data")
  self.parentView_ = parent
end

function Proficiency_tips_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  if self.viewData == nil then
    return
  end
  local buffData = self.proficiencyVm_.GetBuffData(self.viewData.BuffId)
  if buffData == nil then
    return
  end
  local isLock = self.proficiencyVm_.GetIsLockByLevelAndBuffId(self.viewData.LockItem, self.viewData.ActiveLevel, self.viewData.BuffId)
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.itemClassTab_ = {}
  self.uiBinder.lab_title.text = buffData.Name
  local buffCfgData = Z.TableMgr.GetTable("BuffTableMgr").GetRow(self.viewData.BuffId)
  self.uiBinder.img_icon:SetImage(buffCfgData.Icon)
  if level < self.viewData.ActiveLevel then
    self.uiBinder.lab_info_1.text = buffData.Desc
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_2, true)
  else
    self.uiBinder.lab_info_1.text = buffData.Desc
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_2, false)
  end
  if isLock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.tips_icon_title_tpl, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tips_lock_tpl, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.tips_icon_title_tpl, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tips_lock_tpl, true)
    local itemPath = self:GetPrefabCacheData("item")
    local itemsVm = Z.VMMgr.GetVM("items")
    local isOn = true
    for i, itmeData in pairs(self.viewData.ItemDataArray) do
      local itemName = i
      local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.rect_item, self.cancelSource:CreateToken())
      if itemUnit then
        local expendCount = itmeData.Count
        local haveCount = itemsVm.GetItemTotalCount(itmeData.ConfigId)
        if expendCount > haveCount then
          isOn = false
        end
        self.itemClassTab_[itemName] = itemClass.new(self)
        local itemClassData = {
          unit = itemUnit,
          configId = itmeData.ConfigId,
          labType = E.ItemLabType.Expend,
          lab = haveCount,
          expendCount = expendCount,
          colorKey = self.viewData.ColorKey,
          isSquareItem = true
        }
        self.itemClassTab_[itemName]:Init(itemClassData)
      end
    end
  end
  self:AddAsyncClick(self.uiBinder.btn_check, function()
    if isLock then
      return
    end
    self.parentView_:unLock()
  end)
end

function Proficiency_tips_subView:OnDeActive()
  for _, v in pairs(self.itemClassTab_) do
    v:UnInit()
  end
end

function Proficiency_tips_subView:OnRefresh()
end

return Proficiency_tips_subView
