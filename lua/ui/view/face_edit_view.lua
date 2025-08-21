local UI = Z.UI
local uibase = require("ui.ui_view_base")
local super = require("ui.view.face_system_view")
local Face_editView = class("Face_editView", super)

function Face_editView:ctor()
  self.uiBinder = nil
  uibase.ctor(self, "face_edit")
  self.editorFaceInfo_ = {}
  self:createSubView()
end

function Face_editView:OnActive()
  Z.AudioMgr:Play("sys_player_wardrobe_in")
  Z.UnrealSceneMgr:InitSceneCamera(true)
  super.OnActive(self)
  self.editorFaceInfo_ = {}
  self.costMoney_ = {
    [1] = {
      node = self.uiBinder.layout_money1,
      img = self.uiBinder.img_icon_1,
      lab = self.uiBinder.lab_num_1,
      btn = self.uiBinder.btn_money_1
    },
    [2] = {
      node = self.uiBinder.layout_money2,
      img = self.uiBinder.img_icon_2,
      lab = self.uiBinder.lab_num_2,
      btn = self.uiBinder.btn_money_2
    }
  }
  self:initSaveCost()
  for index, node in ipairs(self.costMoney_) do
    self:AddClick(node.btn, function()
      local costData = self.faceVM_.GetFaceSaveCostData(self.editorFaceInfo_)
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.tips_trans, costData[index].ItemId)
    end)
  end
  local commonVM = Z.VMMgr.GetVM("common")
  commonVM.SetLabText(self.uiBinder.lab_title, E.FunctionID.Cosmetology)
  self:initEditorFace()
  self:BindEvents()
  self:onInitRed()
end

function Face_editView:OnDeActive()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
  self.editorFaceInfo_ = {}
  self:clearRed()
  super.OnDeActive(self)
end

function Face_editView:OnRefresh()
  super.OnRefresh(self)
  self.actionIndex_ = 1
end

function Face_editView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FaceEditorHair, self, self.uiBinder.binder_tog_hair.Trans)
end

function Face_editView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FaceEditorHair)
end

function Face_editView:OnClearTimeLine()
  Z.UnrealSceneMgr:ClearModel(self.playerModel_)
end

function Face_editView:BindEvents()
  super.BindEvents(self)
  Z.EventMgr:Add(Z.ConstValue.FaceSaveConfirmItemClick, self.onFaceSaveConfirmItemClick, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Face.FaceOptionChange, self.changeEditorFaceInfo, self)
end

function Face_editView:RemoveEvents()
  super.RemoveEvents(self)
  Z.EventMgr:Remove(Z.ConstValue.FaceSaveConfirmItemClick, self.onFaceSaveConfirmItemClick, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Face.FaceOptionChange, self.changeEditorFaceInfo, self)
end

function Face_editView:initFaceData()
  if self.viewData == nil or not self.viewData.cacheFaceData then
    self.faceData_:ResetFaceData()
    self.faceVM_.UpdateFaceDataByContainerData()
  end
end

function Face_editView:initTabSelect()
  if self.viewData then
    self.curFirstTab_ = self.viewData.firstTab
    self.curSecondTab_ = self.viewData.secondTab
    self.curShowView_ = self.viewData.showView
  else
    self.curFirstTab_ = E.FaceFirstTab.HotPhoto
    self.curSecondTab_ = nil
    self.curShowView_ = self.hotPhotoView_
  end
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  self.curShowView_:Active(nil, self.uiBinder.node_viewport)
end

function Face_editView:initModel()
  self.modelCount_ = 0
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    model:SetLuaAttrLookAtEnable(true)
  end, function(model)
    super.PreloadModel(self, model)
    local fashionVm = Z.VMMgr.GetVM("fashion")
    fashionVm.SetModelAutoLookatCamera(model)
  end)
end

function Face_editView:initSaveCost()
  local itemsVM = Z.VMMgr.GetVM("items")
  local mgr = Z.TableMgr.GetTable("ItemTableMgr")
  local costDataCount = 0
  local costData = self.faceVM_.GetFaceSaveCostData(self.editorFaceInfo_)
  for index, node in ipairs(self.costMoney_) do
    if costData[index] then
      costDataCount = costDataCount + 1
      local data = costData[index]
      self.uiBinder.Ref:SetVisible(node.node, true)
      local row = mgr.GetRow(data.ItemId)
      if row then
        node.img:SetImage(itemsVM.GetItemIcon(data.ItemId))
      end
      local ownNum = itemsVM.GetItemTotalCount(data.ItemId)
      node.lab.text = Z.RichTextHelper.RefreshItemExpendCountUi(ownNum, data.Num)
    else
      self.uiBinder.Ref:SetVisible(node.node, false)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_money, 0 < costDataCount)
end

function Face_editView:GetCacheData()
  local viewData = {
    firstTab = self.curFirstTab_,
    secondTab = self.curSecondTab_,
    showView = self.curShowView_,
    cacheFaceData = true
  }
  return viewData
end

function Face_editView:onItemCountChange(item)
  local itemsVM = Z.VMMgr.GetVM("items")
  local costData = self.faceVM_.GetFaceSaveCostData(self.editorFaceInfo_)
  for index, cost in ipairs(costData) do
    if cost.ItemId == item.configId then
      local node = self.costMoney_[index]
      local ownNum = itemsVM.GetItemTotalCount(cost.ItemId)
      node.lab.text = Z.RichTextHelper.RefreshItemExpendCountUi(ownNum, cost.Num)
    end
  end
end

function Face_editView:onFaceSaveConfirmItemClick(faceOption)
  local optionEnum = faceOption:GetOptionEnum()
  local optionRow = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
  if not optionRow then
    return
  end
  local firstTabData = self.firstTabDict_[optionRow.Tab // 100]
  if firstTabData then
    local togNode = self.uiBinder[firstTabData.NodeName]
    togNode.tog_tab_select.isOn = true
  end
  local secondTabData = self.secondTabDict_[optionRow.Tab]
  if secondTabData then
    local togNode = self.uiBinder[secondTabData.NodeName]
    togNode.tog_tab.isOn = true
  end
end

function Face_editView:onClickReturn()
  self.faceVM_.CloseEditView()
end

function Face_editView:onClickRevert()
  if not self.faceVM_.IsAttrChange() then
    return
  end
  if Z.SDKDevices.IsCloudGame then
    self:revertFace()
    return
  end
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("RevertFaceData"), function()
    self:revertFace()
  end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.ConfirmRevertFaceData)
end

function Face_editView:revertFace()
  self.faceVM_.RecordFaceEditorCommand()
  self.faceVM_.UpdateFaceDataByContainerData()
  self.faceVM_.CacheFaceData()
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
  self.editorFaceInfo_ = {}
  self:initSaveCost()
end

function Face_editView:onClickFinish()
  local costData = self.faceVM_.GetFaceSaveCostData(self.editorFaceInfo_)
  if #costData == 0 then
    Z.TipsVM.ShowTipsLang(120011)
    return
  end
  local sendList = self.faceVM_.GetSendFaceOptionEnumList()
  if #sendList == 0 then
    Z.TipsVM.ShowTipsLang(120011)
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  for _, cost in ipairs(costData) do
    local ownNum = itemsVM.GetItemTotalCount(cost.ItemId)
    if ownNum < cost.Num then
      self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(cost.ItemId, self.uiBinder.cont_money)
      Z.TipsVM.ShowTipsLang(100002)
      return
    end
  end
  local lockList = self.faceVM_.GetUsedLockFaceOptionList()
  if 0 < #lockList then
    Z.UIMgr:OpenView("face_unlock_popup", lockList)
  else
    local showItemList = {}
    for _, cost in ipairs(costData) do
      table.insert(showItemList, {
        ItemId = cost.ItemId,
        ItemNum = cost.Num
      })
    end
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("DescFaceEditConfirm"), function()
      self:onConfirmSetSeverFaceData()
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.SetSeverFaceData, showItemList)
  end
end

function Face_editView:onConfirmSetSeverFaceData()
  self.faceData_.Height = self.playerModel_:GetAttrGoHeight()
  self.faceVM_.AsyncSetSeverFaceData(self.cancelSource:CreateToken())
  self.editorFaceInfo_ = {}
  self:initSaveCost()
end

function Face_editView:getCurFashionSettingStr()
  local regionDict = {}
  for _, region in pairs(E.FashionRegion) do
    regionDict[region] = 1
  end
  local settingVM = Z.VMMgr.GetVM("fashion_setting")
  for k, v in pairs(settingVM.GetCurFashionSettingRegionDict()) do
    regionDict[k] = v
  end
  return settingVM.RegionDictToSettingStr(regionDict)
end

function Face_editView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("face_edit")
end

function Face_editView:OnInputBack()
  Z.UIMgr:CloseView("face_edit")
end

function Face_editView:changeEditorFaceInfo(pbEnum)
  local option = self.faceData_.FaceOptionDict[pbEnum]
  local serverValue = self.faceData_:GetFaceOptionValueByEnum(pbEnum)
  local isChange = option and not option:IsEqualTo(serverValue)
  if self.editorFaceInfo_[pbEnum] == nil then
    self.editorFaceInfo_[pbEnum] = {isChange = isChange}
  else
    self.editorFaceInfo_[pbEnum].isChange = isChange
  end
  self:initSaveCost()
end

function Face_editView:initEditorFace()
  for pbEnum, option in pairs(self.faceData_.FaceOptionDict) do
    local serverValue = self.faceData_:GetFaceOptionValueByEnum(pbEnum)
    self.editorFaceInfo_[pbEnum] = {
      isChange = not option:IsEqualTo(serverValue)
    }
  end
  self:initSaveCost()
end

return Face_editView
