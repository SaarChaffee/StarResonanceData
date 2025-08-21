local UI = Z.UI
local super = require("ui.ui_view_base")
local Chemistry_mainView = class("Chemistry_mainView", super)
local currency_item_list = require("ui.component.currency.currency_item_list")
local DefaultCameraId = 4100
local ChemistrySubType = {Chemistry = 1, Experiment = 2}

function Chemistry_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chemistry_main")
  self.subview_ = {
    [ChemistrySubType.Chemistry] = {
      title = "ChemistryRefine",
      view = require("ui/view/chemistry_refine_sub_view").new(self)
    },
    [ChemistrySubType.Experiment] = {
      title = "ChemistryExperiment",
      view = require("ui/view/chemistry_experiment_sub_view").new(self)
    }
  }
  self.curSubView_ = nil
  self.curSubType_ = nil
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Chemistry_mainView:OnActive()
  local cameraId = DefaultCameraId
  if self.viewData and self.viewData.camID then
    cameraId = self.viewData.camID
  end
  self.cameraInvokeId_ = {
    [ChemistrySubType.Experiment] = self.viewData.slowCam and cameraId + 2 or cameraId + 4,
    [ChemistrySubType.Chemistry] = self.viewData.slowCam and cameraId + 1 or cameraId + 3
  }
  Z.UIMgr:FadeIn({IsInstant = true, TimeOut = 0.3})
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    local lifeProfessionRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(E.ELifeProfession.Chemistry)
    if lifeProfessionRow then
      self.helpsysVM_.OpenFullScreenTipsView(lifeProfessionRow.HelpId)
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_level, function()
    self.lifeProfessionVM_.OpenLifeProfessionInfoView(E.ELifeProfession.Chemistry)
  end)
  self.uiBinder.tog_chemistry:AddListener(function()
    self:changeSub(ChemistrySubType.Chemistry)
  end)
  self.uiBinder.tog_chemistryexperiment:AddListener(function()
    self:changeSub(ChemistrySubType.Experiment)
  end)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    Z.SystemItem.VigourItemId
  })
  self:refreshUI()
  if self.uiBinder.tog_chemistry.isOn then
    self:changeSub(ChemistrySubType.Chemistry)
  else
    self.uiBinder.tog_chemistry.isOn = true
  end
  self:switchEntityShow(false)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
end

function Chemistry_mainView:lifeProfessionLevelChanged(proID)
  self:refreshUI()
end

function Chemistry_mainView:OnDeActive()
  self:switchEntityShow(true)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  self.uiBinder.tog_chemistry:RemoveAllListeners()
  self.uiBinder.tog_chemistryexperiment:RemoveAllListeners()
  self.curSubType_ = nil
  if self.curSubView_ ~= nil then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = nil
  self:closeCamera()
  self.viewData.slowCam = false
  Z.EventMgr:RemoveObjAll(self)
end

function Chemistry_mainView:OnRefresh()
end

function Chemistry_mainView:refreshUI()
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo[E.ELifeProfession.Chemistry]
  if professionInfo then
    self.uiBinder.lab_level_num.text = professionInfo.level
  else
    self.uiBinder.lab_level_num.text = "0"
  end
end

function Chemistry_mainView:changeSub(type)
  if self.curSubType_ == type then
    return
  end
  self.curSubType_ = type
  if self.curSubView_ ~= nil then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.subview_[type].view
  self.curSubView_:Active({
    isHouseCast = self.viewData.isHouseCast
  }, self.uiBinder.node_sub)
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.LifeProfessionChemistry)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name .. "/" .. Lang(self.subview_[type].title)
  end
  self:openCamera(self.cameraInvokeId_[type] or DefaultCameraId)
end

function Chemistry_mainView:openCamera(id)
  local idList = ZUtil.Pool.Collections.ZList_int.Rent()
  idList:Add(id)
  Z.CameraMgr:CameraInvokeByList(E.CameraState.Cooking, true, idList)
  ZUtil.Pool.Collections.ZList_int.Return(idList)
end

function Chemistry_mainView:closeCamera()
  local idList = ZUtil.Pool.Collections.ZList_int.Rent()
  Z.CameraMgr:CameraInvokeByList(E.CameraState.Cooking, false, idList)
  ZUtil.Pool.Collections.ZList_int.Return(idList)
end

function Chemistry_mainView:switchEntityShow(show)
  if show then
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_PLAYER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_NPC)
    Z.LuaBridge.SetHudSwitch(true)
  else
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_PLAYER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_NPC)
    Z.LuaBridge.SetHudSwitch(false)
  end
end

return Chemistry_mainView
