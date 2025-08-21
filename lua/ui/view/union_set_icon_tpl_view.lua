local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_set_icon_tplView = class("Union_set_icon_tplView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local iconItem = require("ui/component/union/union_logo_list_item")
local colorItem = require("ui/component/union/common_color_loop_item")
local logoItem = require("ui/component/union/union_logo_item")
local LOGO_ITEM_NAME = "logo"
local SIZE_NORMAL = 473
local SIZE_EXTEND = 568

function Union_set_icon_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_set_icon_tpl", "union/union_set_icon_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.parentView_ = parent
end

function Union_set_icon_tplView:OnActive()
  self.unionIconTableMgr_ = Z.TableMgr.GetTable("UnionIconTableMgr")
  self.iconCfgDict_ = {
    [E.UnionIconType.EMascot] = {},
    [E.UnionIconType.EIcon] = {},
    [E.UnionIconType.EPattern] = {}
  }
  self.tabBinderDict_ = {
    [E.UnionIconType.EMascot] = self.uiBinder.binder_tab_1,
    [E.UnionIconType.EIcon] = self.uiBinder.binder_tab_2,
    [E.UnionIconType.EPattern] = self.uiBinder.binder_tab_3
  }
  for index, value in pairs(self.unionIconTableMgr_.GetDatas()) do
    if value.IsHide == 0 and self.unionVM_:CheckIconUnlock(value.Id) then
      table.insert(self.iconCfgDict_[value.Type], value)
    end
  end
  self.curTabType_ = nil
  self.iconTab_ = {}
  self.colorTab_ = {}
  self.iconItemLoop_ = loopScrollRect.new(self.uiBinder.loopscroll_icon, self, iconItem)
  self.colorItemLoop_ = loopScrollRect.new(self.uiBinder.loopscroll_color, self, colorItem)
  self:initComponent()
  self:resetIcon()
  self:switchOnOpen()
end

function Union_set_icon_tplView:OnDeActive()
  if self.logoUnit_ then
    self:RemoveUiUnit(LOGO_ITEM_NAME)
    self.logoUnit_ = nil
  end
  self.curTabType_ = nil
  self.iconCfgDict_ = nil
  self.tabBinderDict_ = nil
end

function Union_set_icon_tplView:OnRefresh()
end

function Union_set_icon_tplView:initComponent()
  self:AddAsyncClick(self.uiBinder.btn_reset, function()
    self:resetIcon()
    if self.curTabType_ ~= E.UnionIconType.EPattern then
      self:refreshColorLoop()
    end
    self:refreshIconLoop()
    self:refreshUnionLogo()
  end)
  self:AddAsyncClick(self.uiBinder.btn_random, function()
    self:randomIcon()
    self:switchTab(self.curTabType_, true)
    self:refreshUnionLogo()
  end)
  for index, binder in pairs(self.tabBinderDict_) do
    binder.tog_item.group = self.uiBinder.tog_group_tab
    binder.tog_item:AddListener(function(isOn)
      if isOn then
        self:switchTab(index)
      end
    end)
  end
end

function Union_set_icon_tplView:switchOnOpen()
  local curType = E.UnionIconType.EMascot
  local binder = self.tabBinderDict_[curType]
  if binder.tog_item.isOn then
    self:switchTab(curType)
  else
    binder.tog_item.isOn = true
  end
end

function Union_set_icon_tplView:switchTab(tabType, forceSwitch)
  if not forceSwitch and self.curTabType_ and self.curTabType_ == tabType then
    return
  end
  self.curTabType_ = tabType
  if tabType == E.UnionIconType.EPattern then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loopscroll_color, false)
    self.uiBinder.trans_loop_icon:SetHeight(SIZE_EXTEND)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.loopscroll_color, true)
    self.uiBinder.trans_loop_icon:SetHeight(SIZE_NORMAL)
    self:refreshColorLoop()
  end
  self:refreshIconLoop()
end

function Union_set_icon_tplView:refreshIconLoop()
  self.iconItemLoop_:ClearCells()
  local logoData = {}
  local selectId = self.iconTab_[self.curTabType_]
  local selectIndex = 0
  for index, value in ipairs(self.iconCfgDict_[self.curTabType_]) do
    local data = {}
    
    function data.selectedFunc(itemData)
      self:onChangeIcon(itemData)
    end
    
    data.showMode = E.UnionLogoItemShowType.Element
    data.data = value.Id
    data.sortIndex = value.ShowSort
    table.insert(logoData, data)
    if value.Id == selectId then
      selectIndex = index - 1
    end
  end
  table.sort(logoData, function(l, r)
    if l.sortIndex ~= r.sortIndex then
      return l.sortIndex < r.sortIndex
    end
    return l.data < r.data
  end)
  for index, value in pairs(logoData) do
    if value.data == selectId then
      selectIndex = index - 1
    end
  end
  self.iconItemLoop_:SetData(logoData, true, true, 0)
  self.iconItemLoop_:SetSelected(selectIndex)
end

function Union_set_icon_tplView:onChangeIcon(itemData)
  self.iconTab_[self.curTabType_] = itemData.data
  self:refreshUnionLogo()
  self:checkModify()
end

function Union_set_icon_tplView:refreshColorLoop()
  local unionIconRow = self.unionIconTableMgr_.GetRow(self.iconTab_[self.curTabType_])
  if unionIconRow == nil then
    return
  end
  local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(unionIconRow.Colour)
  if colorRow == nil then
    return
  end
  self.colorItemLoop_:ClearCells()
  local colorArray = colorRow.UiColor
  local colorData = {}
  for index, value in ipairs(colorArray) do
    local data = {}
    
    function data.selectedFunc(index)
      self:onChangeColor(index)
    end
    
    data.color = {}
    data.color[1] = value[1]
    data.color[2] = value[2] / 360
    data.color[3] = value[3] / 100
    data.color[4] = value[4] / 100
    table.insert(colorData, data)
  end
  self.colorItemLoop_:SetData(colorData, true, false, 0)
  self.colorItemLoop_:SetSelected(self.colorTab_[self.curTabType_] - 1)
end

function Union_set_icon_tplView:onChangeColor(index)
  self.colorTab_[self.curTabType_] = index
  self:refreshUnionLogo()
  self:checkModify()
end

function Union_set_icon_tplView:refreshUnionLogo()
  local unionIconRowFront = self.unionIconTableMgr_.GetRow(self.iconTab_[1])
  local unionIconRowBack = self.unionIconTableMgr_.GetRow(self.iconTab_[2])
  if unionIconRowFront == nil or unionIconRowBack == nil then
    return
  end
  local logoData = {}
  logoData.showMode = E.UnionLogoItemShowType.Logo
  logoData.frontIconId = self.iconTab_[1]
  logoData.frontIconColor = self.unionVM_:GetRGBColorById(unionIconRowFront.Colour, self.colorTab_[1])
  logoData.backIconId = self.iconTab_[2]
  logoData.backIconColor = self.unionVM_:GetRGBColorById(unionIconRowBack.Colour, self.colorTab_[2])
  logoData.backIconTexId = self.iconTab_[3]
  Z.CoroUtil.create_coro_xpcall(function()
    if self.logoUnit_ == nil then
      self.logoUnit_ = logoItem.new()
      local itemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.LogoItem)
      local binderItem = self:AsyncLoadUiUnit(itemPath, LOGO_ITEM_NAME, self.uiBinder.trans_preview)
      self.logoUnit_:Init(binderItem.Go)
      binderItem.Trans:SetSizeDelta(225, 225)
      self.logoUnit_:SetLogo(logoData)
    elseif self.logoUnit_.uiBinder ~= nil then
      self.logoUnit_:SetLogo(logoData)
    end
  end)()
end

function Union_set_icon_tplView:randomIcon()
  local mascotCfg = self.iconCfgDict_[E.UnionIconType.EMascot]
  local ranMascot = math.random(1, #mascotCfg)
  self.iconTab_[1] = mascotCfg[ranMascot].Id
  local colorId = mascotCfg[ranMascot].Colour
  local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(colorId)
  if colorRow == nil then
    return
  end
  local ranMascotColor = math.random(1, #colorRow.UiColor)
  self.colorTab_[1] = ranMascotColor
  local iconCfg = self.iconCfgDict_[E.UnionIconType.EIcon]
  local ranIcon = math.random(1, #iconCfg)
  self.iconTab_[2] = iconCfg[ranIcon].Id
  local iconColorId = iconCfg[ranIcon].Colour
  local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(iconColorId)
  if colorRow == nil then
    return
  end
  local ranMascotColor = math.random(1, #colorRow.UiColor)
  self.colorTab_[2] = ranMascotColor
  local patternCfg = self.iconCfgDict_[E.UnionIconType.EPattern]
  local ranPattern = math.random(1, #patternCfg)
  self.iconTab_[3] = patternCfg[ranPattern].Id
  self:checkModify()
end

function Union_set_icon_tplView:resetIcon()
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  local baseData = unionInfo.baseInfo
  self.iconTab_ = {
    [E.UnionIconType.EMascot] = baseData.Icon[1],
    [E.UnionIconType.EIcon] = baseData.Icon[3],
    [E.UnionIconType.EPattern] = baseData.Icon[5]
  }
  self.colorTab_ = {
    [E.UnionIconType.EMascot] = baseData.Icon[2],
    [E.UnionIconType.EIcon] = baseData.Icon[4]
  }
  self:checkModify()
end

function Union_set_icon_tplView:checkModify()
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  local iconInfo = unionInfo.baseInfo.Icon
  if self.iconTab_[1] ~= iconInfo[1] or self.colorTab_[1] ~= iconInfo[2] or self.iconTab_[2] ~= iconInfo[3] or self.colorTab_[2] ~= iconInfo[4] or self.iconTab_[3] ~= iconInfo[5] then
    self.parentView_:EnableOrDisableByModify(true)
  else
    self.parentView_:EnableOrDisableByModify(false)
  end
end

function Union_set_icon_tplView:onClickConfirm()
  local icon = {}
  icon[1] = self.iconTab_[1]
  icon[2] = self.colorTab_[1]
  icon[3] = self.iconTab_[2]
  icon[4] = self.colorTab_[2]
  icon[5] = self.iconTab_[3]
  local reply = self.unionVM_:AsyncSetUnionIcon(self.unionVM_:GetPlayerUnionId(), icon, self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    Z.TipsVM.ShowTips(1000549)
    if self.parentView_ then
      self.parentView_:EnableOrDisableByModify(false)
    end
  end
end

return Union_set_icon_tplView
