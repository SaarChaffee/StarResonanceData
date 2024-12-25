local togglePath = "ui/prefabs/map/map_toggle_mark"
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_setting_subView = class("Map_setting_subView", super)

function Map_setting_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "map_setting_sub", "map/map_setting_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function Map_setting_subView:OnActive()
  self:startAnimatedShow()
  self.panel.Ref:SetSize(0, 0)
  self.count_ = 0
  self.maxCount_ = Z.Global.SceneTagMaxNum
  self.isChange_ = false
  self.closeByBtn_ = false
  self.markInfo_ = {}
  self:AddClick(self.panel.cont_content.cont_map_bg.cont_btn_return.btn.Btn, function()
    self.closeByBtn_ = true
    self.parent_:CloseRightSubview()
  end)
  self:AddClick(self.panel.cont_content.cont_btn_add.Btn, function()
    self:onAddBtnClick()
  end)
  self:AddClick(self.panel.cont_content.cont_btn_delete.Btn, function()
    self.isChange_ = false
    self:onDelBtnClick()
  end)
  self:AddClick(self.panel.cont_content.cont_btn_trace.Btn, function()
    self:onTraceBtnClick()
  end)
  self:AddClick(self.panel.cont_content.cont_btn_nottrace.Btn, function()
    self:onNotTraceBtnClick()
  end)
  self.remarkInput_ = self.panel.cont_content.layout_setting_group3.cont_setting_info_group.input_remark.TMPInput
  self.remarkInput_:AddListener(function(str)
    local contentMaxCount = Z.Global.SceneTagContentLenMax
    if contentMaxCount < string.zlen(str) then
      Z.TipsVM.ShowTipsLang(100001)
      local msg = string.zcut(str, contentMaxCount)
      self.remarkInput_.text = msg
    end
  end)
  self.remarkInput_:AddEndEditListener(function(string)
    if not self.viewData.isCreate then
      self.isChange_ = true
    end
  end)
  self.panel.cont_content.cont_map_bg.cont_map_title_top.input_title.TMPInput:AddEndEditListener(function(string)
    if not self.viewData.isCreate then
      self.isChange_ = true
    end
  end)
  self.panel.cont_content.cont_map_bg.cont_map_title_top.input_title.TMPInput:AddListener(function(str)
    local titleMaxCount = Z.Global.SceneTagTitleLenMax
    if titleMaxCount < string.zlen(str) then
      Z.TipsVM.ShowTipsLang(100001)
      local msg = string.zcut(str, titleMaxCount)
      self.panel.cont_content.cont_map_bg.cont_map_title_top.input_title.TMPInput.text = msg
    end
  end)
end

function Map_setting_subView:sendMapflagChange()
  Z.CoroUtil.create_coro_xpcall(function()
    local markInfo = {}
    if not self.viewData.isCreate then
      markInfo.tagId = self.viewData.flagData.MarkInfo.tagId
      markInfo.position = Vector2.New(self.viewData.flagData.MarkInfo.position.x, self.viewData.flagData.MarkInfo.position.y)
      markInfo.iconId = self.markInfo_.iconId
    else
      markInfo = self.markInfo_
    end
    markInfo.title = self.panel.cont_content.cont_map_bg.cont_map_title_top.input_title.TMPInput.text
    markInfo.content = self.remarkInput_.text
    self.mapVM_.AsyncSendSetMapMark(self.viewData.sceneId, markInfo, self.mapData_.CancelSource:CreateToken())
  end)()
end

function Map_setting_subView:onDelBtnClick()
  local tagId = self.viewData.flagData.MarkInfo.tagId
  local sceneId = self.viewData.sceneId
  Z.CoroUtil.create_coro_xpcall(function()
    self.parent_:DelCustomFlagById(tagId)
    self.mapVM_.AsyncSendDelMapMark(sceneId, tagId, self.mapData_.CancelSource:CreateToken())
  end)()
end

function Map_setting_subView:onTraceBtnClick()
  self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.CustomMapFlag, self.parent_:GetCurSceneId(), self.viewData.flagData)
  self.parent_:CloseRightSubview()
end

function Map_setting_subView:onNotTraceBtnClick()
  self.mapVM_.ClearFlagDataTrackSource(self.parent_:GetCurSceneId(), self.viewData.flagData)
  self.parent_:CloseRightSubview()
end

function Map_setting_subView:onAddBtnClick()
  Z.CoroUtil.create_coro_xpcall(function()
    self:sendMapflagChange()
    if self.count_ >= self.maxCount_ then
      Z.TipsVM.ShowTipsLang(121001)
    end
    self.parent_:CloseRightSubview()
  end)()
end

function Map_setting_subView:startAnimatedHide()
end

function Map_setting_subView:OnDeActive()
  if self.isChange_ then
    self:sendMapflagChange()
  end
  self:ClearAllUnits()
  self.parent_:DelCustomFlag()
end

function Map_setting_subView:OnRefresh()
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
    self.panel.cont_content.layout_setting_group3.lab_title2.TMPLab.text = sceneRow.Name
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
  tagRow = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(E.MapFlagTypeId.CustomTag3)
  if tagRow then
    table.insert(dataList, tagRow)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, tagRow in ipairs(dataList) do
      local unit = self:AsyncLoadUiUnit(togglePath, "tog_btn" .. k, self.panel.cont_content.layout_setting_group3.layout_map_setting_group2.Trans)
      unit.img_icon.Img:SetImage(tagRow.Icon1)
      unit.tog_btn.Tog.isOn = false
      unit.tog_btn.Tog.group = self.panel.cont_content.layout_setting_group3.layout_map_setting_group2.TogGroup
      unit.tog_btn.Tog:AddListener(function(isOn)
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
      end)
      if self.viewData.isCreate and tagRow.Id == dataList[1].Id then
        unit.tog_btn.Tog.isOn = true
      elseif not self.viewData.isCreate and tagRow.Id == self.viewData.flagData.MarkInfo.iconId then
        unit.tog_btn.Tog.isOn = true
      end
    end
  end)()
end

function Map_setting_subView:onCompRefresh()
  local cont_content = self.panel.cont_content
  local info_group = cont_content.layout_setting_group3.cont_setting_info_group
  if self.viewData.isCreate then
    cont_content.cont_map_bg.cont_map_title_top.input_title.TMPInput.text = ""
    info_group.input_remark.TMPInput.text = ""
    cont_content.cont_btn_add.Ref:SetVisible(true)
    cont_content.cont_btn_delete.Ref:SetVisible(false)
    cont_content.cont_btn_trace.Ref:SetVisible(false)
    cont_content.cont_btn_nottrace.Ref:SetVisible(false)
  else
    cont_content.cont_map_bg.cont_map_title_top.input_title.TMPInput.text = self.viewData.flagData.MarkInfo.title
    info_group.input_remark.TMPInput.text = self.viewData.flagData.MarkInfo.content
    cont_content.cont_btn_add.Ref:SetVisible(false)
    cont_content.cont_btn_delete.Ref:SetVisible(true)
    local isTracking = self.mapVM_.CheckIsTracingFlagBySrcAndFlagData(E.GoalGuideSource.CustomMapFlag, self.parent_:GetCurSceneId(), self.viewData.flagData)
    if isTracking then
      cont_content.cont_btn_trace.Ref:SetVisible(false)
      cont_content.cont_btn_nottrace.Ref:SetVisible(true)
    else
      cont_content.cont_btn_trace.Ref:SetVisible(true)
      cont_content.cont_btn_nottrace.Ref:SetVisible(false)
    end
  end
  cont_content.lab_quantity.TMPLab.text = self.count_ .. "/" .. self.maxCount_
end

function Map_setting_subView:startAnimatedShow()
  self.panel.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
end

function Map_setting_subView:startAnimatedHide()
  if self.closeByBtn_ then
    local coro = Z.CoroUtil.async_to_sync(self.panel.anim.TweenContainer.CoroPlay)
    coro(self.panel.anim.TweenContainer, Z.DOTweenAnimType.Close)
  end
end

return Map_setting_subView
