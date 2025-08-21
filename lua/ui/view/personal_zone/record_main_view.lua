local UI = Z.UI
local super = require("ui.ui_view_base")
local PersonalZoneRecordMain = class("PersonalZoneRecordMain", super)
local DEFINE = require("ui.model.personalzone_define")
local FunctionTab = {
  [E.FunctionID.PersonalzoneHead] = {
    lua = "ui/view/personalzone_head_sub_view",
    sort = 1,
    functionId = E.FunctionID.PersonalzoneHead
  },
  [E.FunctionID.PersonalzoneHeadFrame] = {
    lua = "ui/view/personalzone_head_sub_view",
    sort = 2,
    functionId = E.FunctionID.PersonalzoneHeadFrame
  },
  [E.FunctionID.PersonalzoneCard] = {
    lua = "ui/view/personalzone_detailed_sub_view",
    sort = 3,
    functionId = E.FunctionID.PersonalzoneCard
  },
  [E.FunctionID.PersonalzoneTitle] = {
    lua = "ui/view/personalzone_title_sub_view",
    sort = 4,
    functionId = E.FunctionID.PersonalzoneTitle
  },
  [E.FunctionID.PersonalzoneMedal] = {
    lua = "ui/view/personalzone_badge_sub_view",
    sort = 5,
    functionId = E.FunctionID.PersonalzoneMedal
  }
}

function PersonalZoneRecordMain:ctor()
  self.uiBinder = nil
  super.ctor(self, "personal_zone_record_main")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.togSubViews_ = {}
  self.curSelectTogSubView_ = nil
end

function PersonalZoneRecordMain:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.OpenFullScreenTipsView(400007)
  end)
  self.tabs_ = {}
  self.tabsfunctionId_ = {}
  self.redDots_ = {}
  local index = 0
  for _, functionConfig in pairs(FunctionTab) do
    local isUnlock = self.gotoFuncVM_.CheckFuncCanUse(functionConfig.functionId, true)
    if isUnlock then
      index = index + 1
      self.tabs_[index] = functionConfig
    end
  end
  table.sort(self.tabs_, function(a, b)
    return a.sort < b.sort
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = GetLoadAssetPath("ComTabTogItem")
    for _, tab in ipairs(self.tabs_) do
      local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(tab.functionId)
      local unitName = "togs_" .. tab.functionId
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.rect_tab)
      if unit and functionConfig then
        unit.img_on:SetImage(functionConfig.Icon)
        unit.img_off:SetImage(functionConfig.Icon)
        unit.tog_tab_select.group = self.uiBinder.layout_tab
        unit.tog_tab_select:AddListener(function(isOn)
          if isOn then
            self.commonVM_.CommonPlayTogAnim(unit.anim_tog, self.cancelSource:CreateToken())
            self:SelectFunctionId(tab.functionId)
          end
        end)
        self.tabsfunctionId_[tab.functionId] = unit
        do
          local profileImageType
          for key, functionId in pairs(DEFINE.ProfileImageFunctionId) do
            if functionId == tab.functionId then
              profileImageType = key
            end
          end
          if profileImageType then
            Z.RedPointMgr.LoadRedDotItem(DEFINE.ProfileImageRedDot[profileImageType], self, unit.Trans)
            self.redDots_[profileImageType] = profileImageType
          end
        end
      end
    end
    self.uiBinder.layout_tab:SetAllTogglesOff()
    if self.viewData and type(self.viewData) == "number" and self.tabsfunctionId_[self.viewData] then
      self.tabsfunctionId_[self.viewData].tog_tab_select.isOn = true
    elseif self.tabs_[1] ~= nil and self.tabs_[1].functionId ~= nil then
      self.tabsfunctionId_[self.tabs_[1].functionId].tog_tab_select.isOn = true
    end
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  end)()
end

function PersonalZoneRecordMain:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  self.uiBinder.layout_tab:ClearAll()
  for _, unit in pairs(self.tabsfunctionId_) do
    unit.tog_tab_select:RemoveAllListeners()
    unit.tog_tab_select.isOn = false
  end
  self.tabsfunctionId_ = {}
  if self.curSelectTogSubView_ then
    self.curSelectTogSubView_:DeActive()
  end
  self.curSelectTogSubView_ = nil
  for _, reddot in pairs(self.redDots_) do
    Z.RedPointMgr.RemoveNodeItem(reddot)
  end
end

function PersonalZoneRecordMain:OnRefresh()
end

function PersonalZoneRecordMain:SelectFunctionId(functionId)
  if self.curSelectTogSubView_ then
    self.curSelectTogSubView_:DeActive()
  end
  if self.togSubViews_[functionId] == nil then
    local view = require(FunctionTab[functionId].lua).new(self)
    self.togSubViews_[functionId] = view
  end
  self.togSubViews_[functionId]:Active(functionId, self.uiBinder.node_info)
  self.curSelectTogSubView_ = self.togSubViews_[functionId]
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

return PersonalZoneRecordMain
