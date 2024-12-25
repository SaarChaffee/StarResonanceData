local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_create_windowView = class("Union_create_windowView", super)
local unionLogoListItem = require("ui.component.union.union_logo_list_item")
local unionLogoItem = require("ui.component.union.union_logo_item")
local loopScrollRect = require("ui.component.loopscrollrect")
local itemClass = require("common.item_binder")
local unionTagItem = require("ui.component.union.union_tag_item")

function Union_create_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_create_window")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.commonVM = Z.VMMgr.GetVM("common")
end

function Union_create_windowView:onReturnBtnClick()
  Z.UIMgr:CloseView("union_create_window")
end

function Union_create_windowView:onHelpTipsBtnClick()
  self.helpsysVM_.OpenFullScreenTipsView(30003)
end

function Union_create_windowView:onOkBtnClick()
  if self.unionVM_:GetPlayerUnionId() ~= 0 then
    Z.TipsVM.ShowTipsLang(1000501)
    return
  end
  if self:checkItemEnough() == false then
    Z.TipsVM.ShowTipsLang(1000502)
    return
  end
  local name = self.uiBinder.input_name.text
  local manifesto = self.uiBinder.input_announce.text
  local nameLength = string.zlen(name)
  if nameLength < Z.Global.UnionNameLengthMinLimit or nameLength > Z.Global.UnionNameLengthMaxLimit then
    Z.TipsVM.ShowTipsLang(1000503)
    return
  end
  local manifestoLength = string.zlen(manifesto)
  if manifestoLength < Z.Global.UnionNoticeLengthMinLimit or manifestoLength > Z.Global.UnionNoticeLengthMaxLimit then
    Z.TipsVM.ShowTipsLang(1000515)
    return
  end
  local isAutoJoin = self.uiBinder.tog_item.isOn
  local logoPreviewConfigArray = Z.Global.UnionIconPreview
  local config = logoPreviewConfigArray[self.selectedIndex_]
  local logo = {
    config[2],
    config[3],
    config[4],
    config[5],
    config[6]
  }
  local tagList = {}
  for id, isOn in pairs(self.tagDict_) do
    if isOn == true then
      table.insert(tagList, id)
    end
  end
  self.unionVM_:AsyncCreateUnion(name, manifesto, isAutoJoin, logo, tagList, self.cancelSource:CreateToken())
end

function Union_create_windowView:onNameInputChanged()
  local length = string.zlen(self.uiBinder.input_name.text)
  if length > self.nameLimitMax_ then
    self.uiBinder.input_name.text = string.zcut(self.uiBinder.input_name.text, self.nameLimitMax_)
  else
    self.uiBinder.lab_digit_name.text = string.zconcat(length, "/", self.nameLimitMax_)
  end
end

function Union_create_windowView:onAnnounceInputChanged()
  local length = string.zlen(self.uiBinder.input_announce.text)
  if length > self.announceLimitMax_ then
    self.uiBinder.input_announce.text = string.zcut(self.uiBinder.input_announce.text, self.announceLimitMax_)
  else
    self.uiBinder.lab_digit_announce.text = string.zconcat(length, "/", self.announceLimitMax_)
  end
end

function Union_create_windowView:initComponent()
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Selection, self, self.uiBinder.trans_time, self.uiBinder.trans_activity)
  self.Logo_ = unionLogoItem.new()
  self.Logo_:Init(self.uiBinder.binder_logo.Go)
  self.uiBinder.tog_item.isOn = Z.Global.UnionDefaultJoinSwitch == 1
  self.uiBinder.lab_title.text = self.commonVM.GetTitleByConfig({
    E.UnionFuncId.Union,
    E.UnionFuncId.Create
  })
  self.nameLimitMin_ = Z.Global.UnionNameLengthMinLimit
  self.nameLimitMax_ = Z.Global.UnionNameLengthMaxLimit
  local nameInputParam = {
    minLimit = self.nameLimitMin_,
    maxLimit = self.nameLimitMax_
  }
  self.uiBinder.input_name:SetPlaceholderText(Lang("InputPlaceholderTips", nameInputParam))
  self.uiBinder.input_name:AddListener(function()
    self:onNameInputChanged()
  end)
  self.uiBinder.input_name.text = ""
  self:onNameInputChanged()
  self.announceLimitMin_ = Z.Global.UnionNoticeLengthMinLimit
  self.announceLimitMax_ = Z.Global.UnionNoticeLengthMaxLimit
  local manifestoInputParam = {
    minLimit = self.announceLimitMin_,
    maxLimit = self.announceLimitMax_
  }
  self.uiBinder.input_announce:SetPlaceholderText(Lang("InputPlaceholderTips", manifestoInputParam))
  self.uiBinder.input_announce:AddListener(function()
    self:onAnnounceInputChanged()
  end)
  self.uiBinder.input_announce.text = ""
  self:onAnnounceInputChanged()
  self.scrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_icon, self, unionLogoListItem)
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncCreateItem()
  end)()
  self:AddClick(self.uiBinder.btn_close, function()
    self:onReturnBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onHelpTipsBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_create, function()
    self:onOkBtnClick()
  end)
end

function Union_create_windowView:initData()
  self.selectedIndex_ = 0
  self.unionIconTableMgr_ = Z.TableMgr.GetTable("UnionIconTableMgr")
  local logoPreviewConfigArray = Z.Global.UnionIconPreview
  self.LogoListData = {}
  for i = 1, #logoPreviewConfigArray do
    local info = logoPreviewConfigArray[i]
    local itemData = {}
    
    function itemData.selectedFunc(itemData)
      self:onLogoSelected(itemData)
    end
    
    itemData.showMode = E.UnionLogoItemShowType.Logo
    itemData.data = {}
    itemData.data.frontIconId = info[2]
    local unionIconRow = self.unionIconTableMgr_.GetRow(info[2])
    itemData.data.frontIconColor = self.unionVM_:GetRGBColorById(unionIconRow.Colour, info[3])
    itemData.data.backIconId = info[4]
    unionIconRow = self.unionIconTableMgr_.GetRow(info[4])
    itemData.data.backIconColor = self.unionVM_:GetRGBColorById(unionIconRow.Colour, info[5])
    itemData.data.backIconTexId = info[6]
    self.LogoListData[i] = itemData
  end
  self.tagDict_ = {}
  self.scrollRect_:SetData(self.LogoListData, false, true, 0)
  self.scrollRect_:SetSelected(0)
end

function Union_create_windowView:checkItemEnough()
  local costList = Z.Global.UnionCreateCost
  if costList == nil then
    return true
  end
  for i = 1, #costList do
    local itemId = costList[i][1]
    local costCount = costList[i][2]
    local curNum = Z.VMMgr.GetVM("items").GetItemTotalCount(itemId)
    if costCount > curNum then
      return false
    end
  end
  return true
end

function Union_create_windowView:onLogoSelected(selectedData)
  self.selectedIndex_ = self.scrollRect_:GetIndexByData(selectedData)
  self.Logo_:SetLogo(selectedData.data)
  self:onSelectAnim()
end

function Union_create_windowView:onItemCountChange(itemData)
  for id, costItemData in pairs(self.costItemMap_) do
    if itemData.configId == id then
      self:refreshItemUI(id, costItemData.costCount, costItemData.item)
    end
  end
end

function Union_create_windowView:refreshItemUI(configId, costCount, item)
  local curCount = Z.VMMgr.GetVM("items").GetItemTotalCount(configId)
  self.itemClassTab_["item_" .. configId]:SetExpendCount(curCount, costCount)
end

function Union_create_windowView:asyncCreateItem()
  local costList = Z.Global.UnionCreateCost
  if costList == nil then
    return
  end
  self.costItemMap_ = {}
  for i = 1, #costList do
    local itemId = costList[i][1]
    local costCount = costList[i][2]
    local itemPath = GetLoadAssetPath(Z.ConstValue.Backpack.BackPack_Item_Unit_Addr1_8_New)
    local itemName = "item_" .. itemId
    local item = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.trans_material)
    self.costItemMap_[itemId] = {}
    self.costItemMap_[itemId].id = itemId
    self.costItemMap_[itemId].costCount = costCount
    self.costItemMap_[itemId].item = item
    self.itemClassTab_[itemName] = itemClass.new(self)
    self.itemClassTab_[itemName]:Init({
      uiBinder = item,
      configId = itemId,
      isSquareItem = true
    })
    self:refreshItemUI(itemId, costCount, item)
  end
end

function Union_create_windowView:onCreateUnionNotify()
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  if unionInfo ~= nil then
    Z.UIMgr:GotoMainView()
    Z.UIMgr:OpenView("union_main")
  end
end

function Union_create_windowView:OnActive()
  self.itemClassTab_ = {}
  self:startAnimatedShow()
  self:initComponent()
  self:initData()
  self:initTagItem()
  self:BindEvents()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
end

function Union_create_windowView:OnDeActive()
  self:UnBindEvents()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.itemClassTab_ = nil
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
  self.Logo_:UnInit()
  self.Logo_ = nil
  self.scrollRect_:ClearCells()
  self.scrollRect_ = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Union_create_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.CreateUnion, self.onCreateUnionNotify, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
end

function Union_create_windowView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.CreateUnion, self.onCreateUnionNotify, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
end

function Union_create_windowView:OnRefresh()
end

function Union_create_windowView:onSelectAnim()
  self.uiBinder.tween_main:Restart(Z.DOTweenAnimType.Tween_0)
end

function Union_create_windowView:startAnimatedShow()
end

function Union_create_windowView:startAnimatedHide()
end

function Union_create_windowView:initTagItem()
  local allTagList = Z.TableMgr.GetTable("UnionTagTableMgr").GetDatas()
  self.unionTagItem_:SetTag(allTagList, nil, nil, function(config, item, isOn)
    self.tagDict_[config.Id] = isOn
  end)
end

return Union_create_windowView
