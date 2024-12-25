local UI = Z.UI
local uibase = require("ui.ui_view_base")
local super = require("ui.view.face_system_view")
local Face_editView = class("Face_editView", super)

function Face_editView:ctor()
  self.uiBinder = nil
  uibase.ctor(self, "face_edit")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self:createSubView()
end

function Face_editView:OnActive()
  Z.AudioMgr:Play("sys_player_wardrobe_in")
  Z.UnrealSceneMgr:InitSceneCamera()
  super.OnActive(self)
  self:initSaveCost()
  self:AddClick(self.uiBinder.btn_money, function()
    local costData = self.faceVM_.GetFaceSaveCostData()
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.tips_trans, costData.ItemId)
  end)
  local commonVM = Z.VMMgr.GetVM("common")
  commonVM.SetLabText(self.uiBinder.lab_title, E.FunctionID.Cosmetology)
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
  end, function(model)
    super.PreloadModel(self, model)
  end)
end

function Face_editView:OnFinishModelLoad(model)
  super.OnFinishModelLoad(self, model)
  self.modelCount_ = self.modelCount_ + 1
  if self.modelCount_ >= 3 then
    Z.UIMgr:FadeOut()
  end
end

function Face_editView:initSaveCost()
  local costData = self.faceVM_.GetFaceSaveCostData()
  local itemsVM = Z.VMMgr.GetVM("items")
  if costData then
    local row = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costData.ItemId)
    if row then
      self.uiBinder.img_icon:SetImage(itemsVM.GetItemIcon(costData.ItemId))
    end
    local ownNum = itemsVM.GetItemTotalCount(costData.ItemId)
    self.uiBinder.lab_num.text = Z.RichTextHelper.RefreshItemExpendCountUi(ownNum, costData.Num)
  end
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
  local costData = self.faceVM_.GetFaceSaveCostData()
  if costData and costData.ItemId == item.configId then
    self:initSaveCost()
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
  self.faceVM_.RecordFaceEditorCommand()
  self.faceVM_.UpdateFaceDataByContainerData()
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
end

function Face_editView:onClickFinish()
  local costData = self.faceVM_.GetFaceSaveCostData()
  if not costData then
    return
  end
  local sendList = self.faceVM_.GetSendFaceOptionEnumList()
  if #sendList == 0 then
    Z.TipsVM.ShowTipsLang(120011)
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local ownNum = itemsVM.GetItemTotalCount(costData.ItemId)
  if ownNum < costData.Num then
    self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(costData.ItemId, self.uiBinder.cont_money)
    Z.TipsVM.ShowTipsLang(100002)
    return
  end
  local lockList = self.faceVM_.GetUsedLockFaceOptionList()
  if 0 < #lockList then
    Z.UIMgr:OpenView("face_unlock_popup", lockList)
  else
    local showItemList = {
      {
        ItemId = costData.ItemId,
        ItemNum = costData.Num
      }
    }
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("DescFaceEditConfirm"), function()
      self:onConfirmSetSeverFaceData()
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.SetSeverFaceData, showItemList)
  end
end

function Face_editView:onConfirmSetSeverFaceData()
  self.faceData_.Height = self.playerModel_:GetAttrGoHeight()
  self.faceVM_.AsyncSetSeverFaceData(self.cancelSource:CreateToken())
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

return Face_editView
