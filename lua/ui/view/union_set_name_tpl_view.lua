local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_set_name_tplView = class("Union_set_name_tplView", super)
local itemClass = require("common.item_binder")
local CLICK_CD = 5

function Union_set_name_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_set_name_tpl", "union/union_set_name_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.parentView_ = parent
end

function Union_set_name_tplView:OnActive()
  self.uiBinder.input_name:AddListener(function()
    self:onInputNameChanged()
  end)
  self.charMinLimit_ = Z.Global.UnionNameLengthMinLimit
  self.charMaxLimit_ = Z.Global.UnionNameLengthMaxLimit
  self.itemClassDict_ = {}
  self.unionInfo_ = self.unionVM_:GetPlayerUnionInfo()
  self.lastClickTime_ = 0
  self:bindEvents()
end

function Union_set_name_tplView:OnDeActive()
  self:removeCostItem()
  self:unbindEvents()
end

function Union_set_name_tplView:OnRefresh()
  self:setLabInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setCostInfo()
  end)()
end

function Union_set_name_tplView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.RefreshUnionBaseData, self.onRefreshUnionBaseData, self)
end

function Union_set_name_tplView:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.RefreshUnionBaseData, self.onRefreshUnionBaseData, self)
end

function Union_set_name_tplView:onInputNameChanged()
  local nameContent = self.uiBinder.input_name.text
  local length = string.zlenNormalize(nameContent)
  if length > self.charMaxLimit_ then
    self.uiBinder.input_name.text = string.zcutNormalize(nameContent, self.charMaxLimit_)
  else
    self.uiBinder.lab_digit.text = string.zconcat(length, "/", self.charMaxLimit_)
  end
  local isModify = nameContent ~= "" and nameContent ~= self.unionInfo_.baseInfo.Name
  self.parentView_:EnableOrDisableByModify(isModify)
end

function Union_set_name_tplView:setLabInfo()
  local modifyNameCD = Z.Global.UnionNameReviseCD
  local param = {
    minLimit = self.charMinLimit_,
    maxLimit = self.charMaxLimit_
  }
  local isShowTime = false
  if self.unionInfo_.changeNameTime > 0 then
    local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local changeNameTime = self.unionInfo_.changeNameTime
    local leftTime = changeNameTime + modifyNameCD - curServerTime
    if 0 < leftTime then
      self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(leftTime)
      isShowTime = true
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_time, isShowTime)
  self.uiBinder.input_name:SetPlaceholderText(Lang("InputPlaceholderTips", param))
  self.uiBinder.input_name.text = self.unionInfo_.baseInfo.Name
  self:onInputNameChanged()
end

function Union_set_name_tplView:setCostInfo()
  local costList = Z.Global.UnionNameCost
  if costList == nil then
    return
  end
  self:removeCostItem()
  for i = 1, #costList do
    local itemId = costList[i][1]
    local costCount = costList[i][2]
    local curCount = self.itemsVM_.GetItemTotalCount(itemId)
    local itemPath = GetLoadAssetPath(Z.ConstValue.Backpack.BackPack_Item_Unit_Addr1_8_New)
    local name = "item_" .. itemId
    local item = self:AsyncLoadUiUnit(itemPath, name, self.uiBinder.trans_item_root)
    self.itemClassDict_[name] = itemClass.new(self)
    self.itemClassDict_[name]:Init({
      uiBinder = item,
      configId = itemId,
      isSquareItem = true
    })
    self.itemClassDict_[name]:SetExpendCount(curCount, costCount)
  end
end

function Union_set_name_tplView:removeCostItem()
  for name, itemClass in pairs(self.itemClassDict_) do
    itemClass:UnInit()
    self:RemoveUiUnit(name)
  end
  self.itemClassDict_ = {}
end

function Union_set_name_tplView:checkItemEnough()
  local costList = Z.Global.UnionNameCost
  if costList == nil then
    return true
  end
  for i = 1, #costList do
    local itemId = costList[i][1]
    local costCount = costList[i][2]
    local curNum = self.itemsVM_.GetItemTotalCount(itemId)
    if costCount > curNum then
      return false
    end
  end
  return true
end

function Union_set_name_tplView:checkVaild()
  local strLen = string.zlenNormalize(self.uiBinder.input_name.text)
  if strLen < self.charMinLimit_ or strLen > self.charMaxLimit_ then
    Z.TipsVM.ShowTipsLang(1000503)
    return false
  end
  if not self:checkItemEnough() then
    Z.TipsVM.ShowTipsLang(1000538)
    return false
  end
  return true
end

function Union_set_name_tplView:onRefreshUnionBaseData()
  local nameContent = self.uiBinder.input_name.text
  local isModify = nameContent ~= "" and nameContent ~= self.unionInfo_.baseInfo.Name
  self.parentView_:EnableOrDisableByModify(isModify)
end

function Union_set_name_tplView:onClickConfirm()
  if self:checkVaild() then
    local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    if curServerTime - self.lastClickTime_ < CLICK_CD then
      return
    end
    self.lastClickTime_ = curServerTime
    local strName = self.uiBinder.input_name.text
    self.unionVM_:AsyncSetUnionName(self.unionVM_:GetPlayerUnionId(), strName, self.cancelSource:CreateToken())
  end
end

return Union_set_name_tplView
