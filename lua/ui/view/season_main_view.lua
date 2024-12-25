local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_mainView = class("Season_mainView", super)

function Season_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_main")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.vm = Z.VMMgr.GetVM("season")
  self.seasonData_ = Z.DataMgr.Get("season_data")
  self.bpCardData_ = Z.DataMgr.Get("battlepass_data")
  self.goToFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Season_mainView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.AudioMgr:Play("sys_main_season_in")
  self:startAnimatedShow()
  self.curPageViewTab_ = {}
  self.redNodeIdTab_ = {}
  self.leftTogs_ = {}
  self.curChoosePage = -1
  self.bpCardPageIndex = 0
  self.gender_ = Z.ContainerMgr.CharSerialize.charBase.gender
  self.size_ = Z.ContainerMgr.CharSerialize.charBase.bodySize
  self.modelId_ = Z.ModelManager:GetModelIdByGenderAndSize(self.gender_, self.size_)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:SwicthVirtualStyle(E.UnrealSceneSlantingLightStyle.Turquoise)
  self:initBinder()
  self:RegisterInputActions()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initPages()
  end)()
end

function Season_mainView:OnRefresh()
  Z.UIMgr:FadeOut()
  self:refreshPage()
  self:refreshTitleUI()
end

function Season_mainView:refreshTitleUI()
  local seasonName, timeStr = self.vm.GetCurSeasonTimeShow()
  if seasonName and timeStr then
    self.uiBinder.node_season_title.lab_time.text = timeStr
    self.uiBinder.node_season_title.lab_season_name.text = seasonName
  else
    logError("\232\181\155\229\173\163\230\151\182\233\151\180\232\175\187\229\143\150\233\148\153\232\175\175")
  end
end

function Season_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:UnRegisterInputActions()
  for _, view in pairs(self.curPageViewTab_) do
    view:DeActive()
  end
  for index, nodeId in ipairs(self.redNodeIdTab_) do
    Z.RedPointMgr.RemoveNodeItem(nodeId)
  end
  self.curPageViewTab_ = nil
end

function Season_mainView:initBinder()
  self:AddClick(self.uiBinder.binder_title_close.btn_close, function()
    for _, view in pairs(self.curPageViewTab_) do
      if view.CloseSelf then
        view:CloseSelf()
      end
    end
    self.vm.CloseSeasonMainView()
  end)
  self:AddClick(self.uiBinder.binder_title_close.btn_ask, function()
    local helpsysVM_ = Z.VMMgr.GetVM("helpsys")
    local config = self.seasonData_:GetPageByIndex(self.pageIndexes_[self.curChoosePage])
    if config then
      helpsysVM_.OpenFullScreenTipsView(config.HelpId)
    end
  end)
  self:AddClick(self.uiBinder.node_season_title.btn_view, function()
    Z.UIMgr:OpenView("season_window")
  end)
  self.pageToggleGroup_ = self.uiBinder.cont_left.layout_tab
  self.pageItemParent_ = self.uiBinder.cont_left.layout_tab_trans
  self.pageParent_ = self.uiBinder.cont_info
  self.title_ = self.uiBinder.binder_title_close.lab_title
end

function Season_mainView:initPages()
  self.pageIndexes_ = self.vm.GetSeasonPagesIndex()
  local curPage = self.vm.GetCurChoosePage()
  local path = self:GetPrefabCacheDataNew(self.uiBinder.season_main_pcd, "pageItem")
  for i = 1, #self.pageIndexes_ do
    local itemUnit = self:AsyncLoadUiUnit(path, "season_page_" .. self.pageIndexes_[i], self.pageItemParent_)
    self.leftTogs_[i] = itemUnit
    itemUnit.tog_tab_select.group = self.pageToggleGroup_
    local cfg = self.seasonData_:GetPageByIndex(self.pageIndexes_[i])
    local functionCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(cfg.FunctionId)
    if functionCfg and functionCfg.Icon ~= "" then
      itemUnit.img_on:SetImage(functionCfg.Icon)
      itemUnit.img_off:SetImage(functionCfg.Icon)
    end
    Z.GuideMgr:SetSteerIdByComp(itemUnit.uisteer, E.DynamicSteerType.SeasonFunctionId, cfg.FunctionId)
    self.uiBinder.season_main:AddChildDepth(itemUnit.eff_root)
    Z.RedPointMgr.LoadRedDotItem(cfg.FunctionId, self, itemUnit.Trans)
    table.insert(self.redNodeIdTab_, cfg.FunctionId)
    self:AddClick(itemUnit.tog_tab_select, function(ison)
      self.commonVM_.CommonPlayTogAnim(itemUnit.anim_tog, self.cancelSource:CreateToken())
      if ison then
        self:onPageToggleIsOn(i)
      end
    end)
    itemUnit.tog_tab_select.OnPointClickEvent:AddListener(function()
      local isFuncOpen = self.goToFuncVM_.CheckFuncCanUse(cfg.FunctionId)
      itemUnit.tog_tab_select.IsToggleCanSwitch = isFuncOpen
    end)
    local isFuncOpen = self.goToFuncVM_.CheckFuncCanUse(cfg.FunctionId, true)
    itemUnit.Ref:SetVisible(itemUnit.img_lock, not isFuncOpen)
  end
  if self.leftTogs_[curPage] then
    self.leftTogs_[curPage].tog_tab_select.isOn = true
  end
end

function Season_mainView:refreshPage()
  local curPage = self.vm.GetCurChoosePage()
  if self.curChoosePage and curPage == self.curChoosePage then
    return
  end
  if self.leftTogs_[curPage] then
    self.leftTogs_[curPage].tog_tab_select.isOn = true
    self:onPageToggleIsOn(curPage)
  end
end

function Season_mainView:onPageToggleIsOn(index)
  if self.curChoosePage == index then
    return
  end
  local curPageView = self.curPageViewTab_[self.pageIndexes_[self.curChoosePage]]
  if curPageView then
    curPageView:DeActive()
  end
  self.curChoosePage = index
  curPageView = self.curPageViewTab_[self.pageIndexes_[self.curChoosePage]]
  local cfg = self.seasonData_:GetPageByIndex(self.pageIndexes_[self.curChoosePage])
  if cfg == nil then
    return
  end
  if not curPageView then
    local luaCode = self.seasonData_:GetPageCodeByFunctionId(cfg.FunctionId)
    if luaCode == nil then
      return
    end
    curPageView = require(luaCode).new(self)
    self.curPageViewTab_[self.pageIndexes_[self.curChoosePage]] = curPageView
  end
  curPageView:Active(nil, self.pageParent_)
  self.seasonData_:SetSeasonActFuncId()
  local functioncfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(cfg.FunctionId)
  if functioncfg then
    self.title_.text = functioncfg.Name
  end
  self.seasonData_:SetCurShowPage(index)
end

function Season_mainView:startAnimatedShow()
end

function Season_mainView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Season)
end

function Season_mainView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Season)
end

function Season_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("season_main")
end

function Season_mainView:CustomClose()
  local bpCardData = Z.DataMgr.Get("battlepass_data")
  bpCardData.BPCardPageIndex = 0
end

return Season_mainView
