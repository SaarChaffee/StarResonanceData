local UI = Z.UI
local super = require("ui.ui_view_base")
local Rolelevel_mianView = class("Rolelevel_mianView", super)
local loopListView = require("ui.component.loop_list_view")
local levelAwardLoopItme = require("ui.component.role_level.role_level_loop_item")
local listMinShowCount = 5

function Rolelevel_mianView:ctor()
  self.uiBinder = nil
  super.ctor(self, "rolelevel_mian")
  self.rolelevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
  self.rolelevelData_ = Z.DataMgr.Get("role_level_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
end

function Rolelevel_mianView:OnActive()
  Z.AudioMgr:Play("UI_Event_ShengYuanTi_Level")
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self:AddClick(self.uiBinder.btn_acquire, function()
    self.rolelevelVm_.OpenRoleLevelWayWindow()
  end)
  self:AddClick(self.uiBinder.com_title_close_new.btn, function()
    self.rolelevelVm_.CloseRolelevelAwardPanel()
  end)
  self:AddClick(self.uiBinder.com_title_close_new.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(30007)
  end)
  self:initLoopListView()
end

function Rolelevel_mianView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Rolelevel_mianView:OnDeActive()
  Z.CommonTipsVM.CloseTipsTitleContent()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.node_eff:SetEffectGoVisible(false)
  self:unInitLoopListView()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:clearAttr()
end

function Rolelevel_mianView:OnRefresh()
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr")
  self.level_ = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.curLevelExp_ = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp
  self.uiBinder.lab_lv.text = self.level_
  local levelCgf = playerLevelCfg.GetRow(self.level_)
  if levelCgf then
    self.uiBinder.lab_experience.text = string.format("%s%s%s", self.curLevelExp_, "/", levelCgf.Exp)
    self.uiBinder.slider_temp.value = self.curLevelExp_ / levelCgf.Exp
  end
  self.uiBinder.btn_acquire.IsDisabled = levelCgf == nil
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
  if self.level_ == self.maxLv_ then
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
          str = nowvalue .. Z.Placeholder.SetTextSize(Z.RichTextHelper.ApplyStyleTag("+" .. diffValue, E.TextStyleTag.AttrUp))
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

return Rolelevel_mianView
