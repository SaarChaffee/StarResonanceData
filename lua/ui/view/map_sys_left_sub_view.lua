local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_sys_left_subView = class("Map_sys_left_subView", super)
local lifeSubView = require("ui/view/map_life_profession_left_sub_view")
local markSubView = require("ui/view/map_mark_sub_view")
local settingSubView = require("ui/view/map_setting_sub_view")
local TAB_DEFINE = {
  LIFE = 1,
  MARK = 2,
  SETTING = 3
}

function Map_sys_left_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_sys_left_sub", "map/map_sys_left_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Map_sys_left_subView:OnActive()
  self:initData()
  self:initComp()
end

function Map_sys_left_subView:OnDeActive()
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curSubType_ = nil
  for type, tog in pairs(self.mapToggleDict_) do
    tog:RemoveAllListeners()
  end
  self.mapToggleDict_ = nil
  self.mapSubViewDict_ = nil
  self.mapSubCheckFuncDict_ = nil
end

function Map_sys_left_subView:OnRefresh()
  self:switchOnOpen()
end

function Map_sys_left_subView:initData()
  self.mapTabFunctionIdDict_ = {
    [TAB_DEFINE.LIFE] = E.FunctionID.LifeProfession,
    [TAB_DEFINE.MARK] = E.FunctionID.MapMark,
    [TAB_DEFINE.SETTING] = E.FunctionID.MapSetting
  }
  self.mapSubViewDict_ = {
    [TAB_DEFINE.LIFE] = lifeSubView.new(self),
    [TAB_DEFINE.MARK] = markSubView.new(self),
    [TAB_DEFINE.SETTING] = settingSubView.new(self)
  }
  self.mapSubTitleDict_ = {
    [TAB_DEFINE.LIFE] = self.commonVM_.GetTitleByConfig(self.mapTabFunctionIdDict_[TAB_DEFINE.LIFE]),
    [TAB_DEFINE.MARK] = self.commonVM_.GetTitleByConfig(self.mapTabFunctionIdDict_[TAB_DEFINE.MARK]),
    [TAB_DEFINE.SETTING] = self.commonVM_.GetTitleByConfig(self.mapTabFunctionIdDict_[TAB_DEFINE.SETTING])
  }
  self.mapSubCheckFuncDict_ = {
    [TAB_DEFINE.LIFE] = self.checkLifeShow,
    [TAB_DEFINE.MARK] = nil,
    [TAB_DEFINE.SETTING] = nil
  }
end

function Map_sys_left_subView:initComp()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.mapToggleDict_ = {
    [TAB_DEFINE.LIFE] = self.uiBinder.tog_tab_profession,
    [TAB_DEFINE.MARK] = self.uiBinder.tog_tab_mark,
    [TAB_DEFINE.SETTING] = self.uiBinder.tog_tab_setting
  }
  self.mapToggleRootDict_ = {
    [TAB_DEFINE.LIFE] = self.uiBinder.node_life_profession,
    [TAB_DEFINE.MARK] = self.uiBinder.node_mark,
    [TAB_DEFINE.SETTING] = self.uiBinder.node_setting
  }
  self:AddClick(self.uiBinder.btn_close, function()
    self.parent_:CloseLeftSubView()
  end)
  for type, tog in pairs(self.mapToggleDict_) do
    tog.group = self.uiBinder.tog_group_tab
    tog:AddListener(function(isOn)
      if isOn then
        self:switchSubView(type)
      end
    end)
    tog.OnPointClickEvent:AddListener(function()
      local subFuncId = self.mapTabFunctionIdDict_[type]
      local isFuncOpen = self.funcVM_.CheckFuncCanUse(subFuncId)
      tog.IsToggleCanSwitch = isFuncOpen
    end)
  end
end

function Map_sys_left_subView:switchOnOpen()
  local tabType
  local isAllClose = true
  for type, funcId in pairs(self.mapTabFunctionIdDict_) do
    local isTabShow = true
    local isFuncOpen = self.funcVM_.CheckFuncCanUse(funcId, true)
    if isFuncOpen then
      local checkFunc = self.mapSubCheckFuncDict_[type]
      if checkFunc and not checkFunc(self) then
        isTabShow = false
      else
        if tabType == nil then
          tabType = type
        end
        isAllClose = false
      end
    else
      isTabShow = false
    end
    local nodeRoot = self.mapToggleRootDict_[type]
    self:SetUIVisible(nodeRoot, isTabShow)
  end
  if isAllClose then
    Z.TipsVM.ShowTips(100102)
    self.parent_:CloseLeftSubView()
    return
  end
  if tabType == nil then
    return
  end
  local tabTog = self.mapToggleDict_[tabType]
  if tabTog.isOn then
    self:switchSubView(tabType)
  else
    tabTog.isOn = true
  end
end

function Map_sys_left_subView:switchSubView(subType)
  if self.curSubType_ and self.curSubType_ == subType then
    return
  end
  self.curSubType_ = subType
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.mapSubViewDict_[subType]
  self.uiBinder.lab_title.text = self.mapSubTitleDict_[subType]
  if self.curSubView_ then
    self.curSubView_:Active(nil, self.uiBinder.node_sub)
  end
end

function Map_sys_left_subView:GetCurSceneId()
  return self.parent_:GetCurSceneId()
end

function Map_sys_left_subView:checkLifeShow()
  local curSceneId = self:GetCurSceneId()
  local mapData = Z.DataMgr.Get("map_data")
  local dataList = Z.TableMgr.GetTable("LifeCollectListTableMgr").GetDatas()
  for i, v in pairs(dataList) do
    local collectionPosInfo = mapData:GetCollectionPosInfo(v.Id, curSceneId)
    if collectionPosInfo and 0 < #collectionPosInfo then
      return true
    end
  end
  return false
end

return Map_sys_left_subView
