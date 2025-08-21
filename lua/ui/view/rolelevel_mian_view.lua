local UI = Z.UI
local super = require("ui.ui_view_base")
local Rolelevel_mianView = class("Rolelevel_mianView", super)
local loopListView = require("ui.component.loop_list_view")
local levelAwardLoopItme = require("ui.component.role_level.role_level_loop_item")
local proficiencySubView = require("ui.view.proficiency_main_view")
local listMinShowCount = 5

function Rolelevel_mianView:ctor()
  self.uiBinder = nil
  super.ctor(self, "rolelevel_mian")
  self.rolelevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
  self.rolelevelData_ = Z.DataMgr.Get("role_level_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.seasonData_ = Z.DataMgr.Get("season_data")
end

function Rolelevel_mianView:OnActive()
  self.commonVM_ = Z.VMMgr.GetVM("common")
  Z.AudioMgr:Play("UI_Event_ShengYuanTi_Level")
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self:AddClick(self.uiBinder.btn_acquire, function()
    self.rolelevelVm_.OpenRoleLevelWayWindow()
  end)
  self:AddClick(self.uiBinder.com_title_close_new.btn, function()
    self.rolelevelVm_.CloseRolelevelAwardPanel()
  end)
  self:AddClick(self.uiBinder.com_title_close_new.btn_ask, function()
    if self.selectIndex_ == E.RoleLevelPageIndex.RoleLevel then
      self.helpsysVM_.OpenFullScreenTipsView(30007)
    elseif self.selectIndex_ == E.RoleLevelPageIndex.Proficiency then
      self.helpsysVM_.CheckAndShowView(30016)
    end
  end)
  self:AddClick(self.uiBinder.btn_exp_ask, function()
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.rect_exp_ask, Lang("DelayExpDes"))
  end)
  self:initLoopListView()
  self.proficiencySubView_ = proficiencySubView.new(self)
  self.attrUnits_ = {}
  self.selectIndex_ = self.viewData.pageIndex or E.RoleLevelPageIndex.RoleLevel
  local togBinders = {
    [1] = self.uiBinder.tog_tab_role_level,
    [2] = self.uiBinder.tog_tab_proficiency
  }
  for index, value in ipairs(togBinders) do
    value.group = self.uiBinder.layout_tab
    value:RemoveAllListeners()
    value.isOn = false
    value:AddListener(function(isOn)
      if isOn then
        if index == 1 then
          self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
        end
        self.selectIndex_ = index
        self:refreshSubPage()
      end
    end)
  end
  if togBinders[self.selectIndex_].isOn then
    self:refreshSubPage()
  else
    togBinders[self.selectIndex_].isOn = true
  end
  self:loadRedDotItem()
end

function Rolelevel_mianView:refreshSubPage()
  if self.selectIndex_ == E.RoleLevelPageIndex.RoleLevel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_rolelevel_sub, true)
    if self.curSubView_ then
      self.curSubView_:DeActive()
    end
    self:refreshRoleLevelInfo()
    self.commonVM_.SetLabText(self.uiBinder.lab_title, E.FunctionID.RoleLevel)
  elseif self.selectIndex_ == E.RoleLevelPageIndex.Proficiency then
    self.proficiencySubView_:Active({}, self.uiBinder.node_proficiency_sub)
    self.curSubView_ = self.proficiencySubView_
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_rolelevel_sub, false)
    self.commonVM_.SetLabText(self.uiBinder.lab_title, E.FunctionID.Proficiency)
  end
end

function Rolelevel_mianView:OnDeActive()
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.CommonTipsVM.CloseTipsContent()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.node_eff:SetEffectGoVisible(false)
  self:unInitLoopListView()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self:clearAttr()
  self:unLoadRedDotItem()
end

function Rolelevel_mianView:OnRefresh()
end

function Rolelevel_mianView:refreshRoleLevelInfo()
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr")
  local roleLevelInfo = Z.ContainerMgr.CharSerialize.roleLevel
  self.level_ = roleLevelInfo.level
  self.curLevelExp_ = roleLevelInfo.curLevelExp
  self.uiBinder.lab_lv.text = self.level_
  if self.level_ == self.rolelevelData_.MaxPlayerLevel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_acquire, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_experience, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, true)
    self.uiBinder.img_blue.fillAmount = 1
    self.uiBinder.img_green.fillAmount = 1
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_acquire, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_experience, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, false)
    local levelCgf = playerLevelCfg.GetRow(self.level_)
    if levelCgf then
      self.uiBinder.lab_experience.text = self.curLevelExp_ .. "/" .. levelCgf.Exp
      self.uiBinder.img_blue.fillAmount = self.curLevelExp_ / levelCgf.Exp
    end
    self.uiBinder.btn_acquire.IsDisabled = levelCgf == nil
    local isBlessExpFuncOn = self.rolelevelVm_.IsBlessExpFuncOn()
    if isBlessExpFuncOn then
      if self.level_ < roleLevelInfo.prevSeasonMaxLv then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, true)
        self.uiBinder.img_green.fillAmount = 1
        self.uiBinder.lab_exptitle.text = Lang("BlessExp")
        local expMagn = 1
        if self.seasonData_.CurSeasonId and self.seasonData_.CurSeasonId ~= 0 then
          local config = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(self.seasonData_.CurSeasonId)
          if config then
            expMagn = config.ExGainEff + 1
          end
        end
        self.uiBinder.lab_expcontent.text = Lang("BlessExpContent", {
          val1 = roleLevelInfo.prevSeasonMaxLv,
          val2 = expMagn
        })
      else
        local doubleExp = roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp
        if 0 < doubleExp then
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, true)
          self.uiBinder.img_green.fillAmount = (self.curLevelExp_ + doubleExp) / levelCgf.Exp
          self.uiBinder.lab_exptitle.text = Lang("DelayExp")
          self.uiBinder.lab_expcontent.text = Lang("DoubleExpContent", {val = doubleExp})
        else
          self.uiBinder.img_green.fillAmount = 0
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, false)
        end
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, false)
      self.uiBinder.img_green.fillAmount = 0
    end
  end
  self:refreshLoopListViewByIndex()
  self:refreshAttr()
end

function Rolelevel_mianView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, levelAwardLoopItme, "rolelevel_item_tpl_new")
  self.loopListView_:Init({})
  self.loopListView_:SetSelected(1)
end

function Rolelevel_mianView:refreshLoopListViewByIndex()
  local awards = self.rolelevelVm_.GetLevelAwards()
  local index = 0
  local currentLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
  local awardsShow = {}
  local startIndex = 1
  for i, v in ipairs(awards) do
    if currentLevel >= v.Level then
      startIndex = i
    end
  end
  if #awards - startIndex < listMinShowCount then
    startIndex = #awards - listMinShowCount + 1
  end
  for i = startIndex, #awards do
    table.insert(awardsShow, awards[i])
  end
  self.loopListView_:ClearAllSelect()
  self.loopListView_:RefreshListView(awardsShow)
  self.loopListView_:SetSelected(1)
end

function Rolelevel_mianView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Rolelevel_mianView:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  self.uiBinder.node_eff:SetEffectGoVisible(true)
end

function Rolelevel_mianView:refreshAttr()
  if self.level_ == self.rolelevelData_.MaxPlayerLevel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_buff_lab, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_maxlevel, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_buff_lab, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_maxlevel, false)
    local path = "ui/prefabs/rolelevel/rolelevel_attr_tpl"
    local root = self.uiBinder.layout_info
    self.attrUnits_ = {}
    local config = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(self.level_)
    if config then
      Z.CoroUtil.create_coro_xpcall(function()
        for _, value in ipairs(config.LevelUpAttr) do
          local name = value[1]
          table.insert(self.attrUnits_, name)
          local unit = self:AsyncLoadUiUnit(path, name, root)
          local str
          unit.Ref:SetVisible(unit.img_bg, false)
          local nowvalue = self.fightAttrParseVm_.ParseFightAttrNumber(value[1], Z.EntityMgr.PlayerEnt:GetLuaAttr(value[1]).Value, true)
          local diffValue = self.fightAttrParseVm_.ParseFightAttrNumber(value[1], value[2], true)
          str = nowvalue .. Z.RichTextHelper.ApplyStyleTag("+" .. diffValue, E.TextStyleTag.RoleLevelLabUp)
          self:refreshAttrUnit(unit, value[1], str)
        end
      end)()
    end
  end
end

function Rolelevel_mianView:refreshAttrUnit(uibinder, id, str)
  if uibinder == nil then
    return
  end
  local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(id)
  if fightAttrData == nil then
    return
  end
  uibinder.lab_num.text = str
  uibinder.lab_name.text = fightAttrData.OfficialName
  uibinder.img_icon:SetImage(fightAttrData.Icon)
end

function Rolelevel_mianView:showAttrDetails(id)
  local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(id)
  if fightAttrData then
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, fightAttrData.OfficialName, fightAttrData.AttrDes)
  end
end

function Rolelevel_mianView:clearAttr()
  for _, value in ipairs(self.attrUnits_) do
    self:RemoveUiUnit(value)
  end
end

function Rolelevel_mianView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.RoleMainRolelevelPageBtn, self, self.uiBinder.tog_tab_proficiency.transform)
end

function Rolelevel_mianView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.RoleMainRolelevelPageBtn, self)
end

return Rolelevel_mianView
