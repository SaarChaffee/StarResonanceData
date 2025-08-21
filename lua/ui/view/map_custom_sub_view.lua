local togglePath = "ui/prefabs/map/map_toggle_mark"
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_custom_subView = class("Map_custom_subView", super)

function Map_custom_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_custom_sub", "map/map_custom_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function Map_custom_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self.count_ = 0
  self.maxCount_ = Z.Global.SceneTagMaxNum
  self.isChange_ = false
  self.closeByBtn_ = false
  self.markInfo_ = {}
  self:AddClick(self.uiBinder.btn_close, function()
    self.closeByBtn_ = true
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.uiBinder.btn_add, function()
    self:onAddBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_delete, function()
    self.isChange_ = false
    self:onDelBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_trace, function()
    self:onTraceBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_cancel_trace, function()
    self:onNotTraceBtnClick()
  end)
  self.uiBinder.input_remark:AddListener(function(str)
    local contentMaxCount = Z.Global.SceneTagContentLenMax
    if contentMaxCount < string.zlenNormalize(str) then
      Z.TipsVM.ShowTipsLang(100001)
      local msg = string.zcutNormalize(str, contentMaxCount)
      self.uiBinder.input_remark.text = msg
    end
  end)
  self.uiBinder.input_remark:AddEndEditListener(function(string)
    if not self.viewData.isCreate then
      self.isChange_ = true
    end
  end)
  self.uiBinder.input_title:AddEndEditListener(function(string)
    if not self.viewData.isCreate then
      self.isChange_ = true
    end
  end)
  self.uiBinder.input_title:AddListener(function(str)
    local titleMaxCount = Z.Global.SceneTagTitleLenMax
    if titleMaxCount < string.zlenNormalize(str) then
      Z.TipsVM.ShowTipsLang(100001)
      local msg = string.zcutNormalize(str, titleMaxCount)
      self.uiBinder.input_title.text = msg
    end
  end)
end

function Map_custom_subView:sendMapflagChange()
  Z.CoroUtil.create_coro_xpcall(function()
    local markInfo = {}
    if not self.viewData.isCreate then
      markInfo.tagId = self.viewData.flagData.MarkInfo.tagId
      markInfo.position = Vector2.New(self.viewData.flagData.MarkInfo.position.x, self.viewData.flagData.MarkInfo.position.y)
      markInfo.iconId = self.markInfo_.iconId
    else
      markInfo = self.markInfo_
    end
    markInfo.title = self.uiBinder.input_title.text
    markInfo.content = self.uiBinder.input_remark.text
    self.mapVM_.AsyncSendSetMapMark(self.viewData.sceneId, markInfo, self.mapData_.CancelSource:CreateToken())
  end)()
end

function Map_custom_subView:onDelBtnClick()
  local tagId = self.viewData.flagData.MarkInfo.tagId
  local sceneId = self.viewData.sceneId
  Z.CoroUtil.create_coro_xpcall(function()
    self.parent_:DelCustomFlagById(tagId)
    self.mapVM_.AsyncSendDelMapMark(sceneId, tagId, self.mapData_.CancelSource:CreateToken())
  end)()
end

function Map_custom_subView:onTraceBtnClick()
  self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.CustomMapFlag, self.parent_:GetCurSceneId(), self.viewData.flagData)
  self.parent_:CloseRightSubView()
end

function Map_custom_subView:onNotTraceBtnClick()
  self.mapVM_.ClearFlagDataTrackSource(self.parent_:GetCurSceneId(), self.viewData.flagData)
  self.parent_:CloseRightSubView()
end

function Map_custom_subView:onAddBtnClick()
  Z.CoroUtil.create_coro_xpcall(function()
    self:sendMapflagChange()
    if self.count_ >= self.maxCount_ then
      Z.TipsVM.ShowTipsLang(121001)
    end
    self.parent_:CloseRightSubView()
  end)()
end

function Map_custom_subView:startAnimatedHide()
end

function Map_custom_subView:OnDeActive()
  if self.isChange_ then
    self:sendMapflagChange()
  end
  self:ClearAllUnits()
  self.parent_:DelCustomFlag()
end

function Map_custom_subView:OnRefresh()
  self.isChange_ = false
  if Z.ContainerMgr.CharSerialize.mapData.markDataMap[self.viewData.sceneId] then
    local map = Z.ContainerMgr.CharSerialize.mapData.markDataMap[self.viewData.sceneId].markInfoMap
    self.count_ = table.zcount(map)
  else
    self.count_ = 0
  end
  self:onCompRefresh()
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(self.viewData.sceneId)
  if sceneRow then
    self.uiBinder.lab_scene_name.text = sceneRow.Name
  end
  local dataList = {}
  local tagRow
  tagRow = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(E.MapFlagTypeId.CustomTag1)
  if tagRow then
    table.insert(dataList, tagRow)
  end
  tagRow = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(E.MapFlagTypeId.CustomTag2)
  if tagRow then
    table.insert(dataList, tagRow)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local targetUnit, targetRow
    for k, tagRow in ipairs(dataList) do
      local unit = self:AsyncLoadUiUnit(togglePath, "tog_btn" .. k, self.uiBinder.trans_tog_parent)
      unit.img_icon:SetImage(tagRow.Icon1)
      unit.tog_btn.isOn = false
      unit.tog_btn.group = self.uiBinder.tog_group_item
      unit.tog_btn:AddListener(function(isOn)
        self:onTogValueChange(isOn, tagRow)
      end)
      if self.viewData.isCreate and tagRow.Id == dataList[1].Id then
        targetUnit = unit
        targetRow = tagRow
      elseif not self.viewData.isCreate and tagRow.Id == self.viewData.flagData.MarkInfo.iconId then
        targetUnit = unit
        targetRow = tagRow
      end
      self:MarkListenerComp(unit.tog_btn, true)
    end
    if targetUnit and targetRow then
      if targetUnit.tog_btn.isOn then
        self:onTogValueChange(true, targetRow)
      else
        targetUnit.tog_btn.isOn = true
      end
    end
  end)()
end

function Map_custom_subView:onTogValueChange(isOn, tagRow)
  self.markInfo_ = {}
  if isOn then
    if not self.viewData.isCreate then
      self.markInfo_.tagId = self.viewData.flagData.MarkInfo.tagId
      self.markInfo_.position = Vector2.New(self.viewData.flagData.MarkInfo.position.x, self.viewData.flagData.MarkInfo.position.y)
      self.isChange_ = true
    else
      self.markInfo_.tagId = 0
      self.markInfo_.position = self.viewData.position
    end
    self.markInfo_.iconId = tagRow.Id
    self.parent_:CustomFlagIconChange(tagRow.Icon1, self.markInfo_.tagId)
  end
end

function Map_custom_subView:onCompRefresh()
  if self.viewData.isCreate then
    self.uiBinder.input_title.text = ""
    self.uiBinder.input_remark.text = ""
    self:SetUIVisible(self.uiBinder.btn_add, true)
    self:SetUIVisible(self.uiBinder.btn_delete, false)
    self:SetUIVisible(self.uiBinder.btn_trace, false)
    self:SetUIVisible(self.uiBinder.btn_cancel_trace, false)
  else
    self.uiBinder.input_title.text = self.viewData.flagData.MarkInfo.title
    self.uiBinder.input_remark.text = self.viewData.flagData.MarkInfo.content
    self:SetUIVisible(self.uiBinder.btn_add, false)
    self:SetUIVisible(self.uiBinder.btn_delete, true)
    local isTracking = self.mapVM_.CheckIsTracingFlagBySrcAndFlagData(E.GoalGuideSource.CustomMapFlag, self.parent_:GetCurSceneId(), self.viewData.flagData)
    self:SetUIVisible(self.uiBinder.btn_trace, not isTracking)
    self:SetUIVisible(self.uiBinder.btn_cancel_trace, isTracking)
  end
  self.uiBinder.lab_quantity.text = self.count_ .. "/" .. self.maxCount_
end

function Map_custom_subView:startAnimatedShow()
  self.uiBinder.comp_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Map_custom_subView:startAnimatedHide()
  if self.closeByBtn_ then
    local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_dotween.CoroPlay)
    coro(self.uiBinder.comp_dotween, Z.DOTweenAnimType.Close)
  end
end

return Map_custom_subView
