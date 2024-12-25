local UI = Z.UI
local super = require("ui.ui_view_base")
local Role_info_attr_detailView = class("Role_info_attr_detailView", super)
local labelPrefabPath_ = "ui/prefabs/role_info/role_info_attr_layout_tpl"
local attrDetailsPrefabPath_ = "ui/prefabs/role_info/role_info_attr_detail_item"

function Role_info_attr_detailView:ctor()
  self.uiBinder = nil
  super.ctor(self, "role_info_attr_detail")
  self.vm_ = Z.VMMgr.GetVM("role_info_attr_detail")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.selectAttr_ = nil
end

function Role_info_attr_detailView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.fightAttrMgr_ = Z.TableMgr.GetTable("FightAttrTableMgr")
  self:AddClick(self.uiBinder.btn_close, function()
    self.vm_.CloseRoleAttrDetailView()
  end)
end

function Role_info_attr_detailView:OnDeActive()
  self.uiBinder.rect_attr_detail:SetParent(self.uiBinder.Trans)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_attr_detail, false)
  if self.selectUnit_ then
    self:clearSelect(self.selectUnit_, self.selectID_)
  end
  self.selectUnit_ = nil
  self.preUnit_ = nil
  self.selectID_ = nil
  self.preSelectId_ = nil
  self.index_ = 1
end

function Role_info_attr_detailView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshAttrDetail()
  end)()
end

function Role_info_attr_detailView:refreshAttrDetail()
  self.index_ = 1
  local attrs = self.vm_.GetAllShowAttr()
  local path = self.uiBinder.uiprefab_cashdata:GetString("labelprefab")
  for type, value in pairs(attrs) do
    local unitName = string.format("attr_label_%s", type)
    local unit = self:AsyncLoadUiUnit(path, unitName, self.uiBinder.layout_content)
    local name = value[1].TypeDisplayName
    unit.lab_title.text = name
    self:setAttrList(unit, value)
  end
end

function Role_info_attr_detailView:setAttrList(unit, value)
  local path = self.uiBinder.uiprefab_cashdata:GetString("attrdetail")
  for k, v in pairs(value) do
    local name = string.format("attr_%s_details", v.AttrId)
    local unit_ = self:AsyncLoadUiUnit(path, name, unit.rect_attr_list)
    self:setAttrDetailsUnit(unit_, v)
  end
end

function Role_info_attr_detailView:setAttrDetailsUnit(unit, value)
  local fightAttrData = self.fightAttrMgr_.GetRow(value.AttrId)
  if fightAttrData == nil then
    return
  end
  unit.Ref.UIComp:SetVisible(true)
  unit.lab_attr.text = fightAttrData.OfficialName
  unit.lab_num.text = self.fightAttrParseVm_.ParseFightAttrNumber(value.AttrId, Z.EntityMgr.PlayerEnt:GetLuaAttr(value.AttrId).Value, true)
  unit.Ref:SetVisible(unit.img_bg, self.index_ % 2 ~= 0)
  self.index_ = self.index_ + 1
  unit.btn_click:AddListener(function()
    if self.selectUnit_ == unit then
      self:clearSelect(self.selectUnit_, value.AttrId)
      return
    end
    self:setDetailsExpand(unit, value)
    self.preUnit_ = self.selectUnit_
    self.selectUnit_ = unit
    self.preSelectId_ = self.selectID_
    self.selectID_ = value.AttrId
    self.selectUnit_.Ref:SetVisible(self.selectUnit_.img_select, true)
    self.selectUnit_.img_triangle:SetColor(Color.New(1, 0.9137254901960784, 0.6549019607843137, 1))
    self.selectUnit_.rect_triangle:SetScale(1, -1)
    local colorTag = E.TextStyleTag.RoloLabAttr
    self.selectUnit_.lab_attr.text = Z.RichTextHelper.ApplyStyleTag(fightAttrData.OfficialName, colorTag)
    local num = self.fightAttrParseVm_.ParseFightAttrNumber(value.AttrId, Z.EntityMgr.PlayerEnt:GetLuaAttr(value.AttrId).Value, true)
    self.selectUnit_.lab_num.text = Z.RichTextHelper.ApplyStyleTag(num, colorTag)
    if self.preUnit_ then
      self.preUnit_.Ref:SetVisible(self.preUnit_.img_select, false)
      self.preUnit_.img_triangle:SetColor(Color.New(1, 1, 1, 1))
      self.preUnit_.rect_triangle:SetScale(1, 1)
      local prefightAttrData = self.fightAttrMgr_.GetRow(self.preSelectId_)
      local colorTag = E.TextStyleTag.White
      if prefightAttrData == nil then
        return
      end
      self.preUnit_.lab_attr.text = Z.RichTextHelper.ApplyStyleTag(prefightAttrData.OfficialName, colorTag)
      local value = self.fightAttrParseVm_.ParseFightAttrNumber(self.preSelectId_, Z.EntityMgr.PlayerEnt:GetLuaAttr(self.preSelectId_).Value, true)
      self.preUnit_.lab_num.text = Z.RichTextHelper.ApplyStyleTag(value, colorTag)
    end
  end)
end

function Role_info_attr_detailView:clearSelect(unit, value)
  self.uiBinder.rect_attr_detail:SetParent(self.uiBinder.rect_unit)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_attr_detail, false)
  unit.Ref:SetVisible(unit.img_select, false)
  unit.rect_triangle:SetScale(1, 1)
  unit.img_triangle:SetColor(Color.New(1, 1, 1, 1))
  local prefightAttrData = self.fightAttrMgr_.GetRow(value)
  local colorTag = E.TextStyleTag.White
  if prefightAttrData == nil then
    return
  end
  self.selectUnit_.lab_attr.text = Z.RichTextHelper.ApplyStyleTag(prefightAttrData.OfficialName, colorTag)
  local value = self.fightAttrParseVm_.ParseFightAttrNumber(value, Z.EntityMgr.PlayerEnt:GetLuaAttr(value).Value, true)
  self.selectUnit_.lab_num.text = Z.RichTextHelper.ApplyStyleTag(value, colorTag)
  self.preUnit_ = nil
  self.selectUnit_ = nil
  self.preSelectId_ = nil
  self.selectID_ = nil
end

function Role_info_attr_detailView:setDetailsExpand(unit, config)
  local fightAttrData = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(config.AttrId)
  local desc
  if fightAttrData then
    desc = fightAttrData.AttrDes
  end
  if desc == "" or desc == nil then
    self.uiBinder.rect_attr_detail:SetParent(self.uiBinder.rect_unit)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rect_attr_detail, false)
    return
  end
  self.uiBinder.lab_tips.text = desc
  self.uiBinder.rect_attr_detail:SetParent(unit.Trans.parent)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_attr_detail, true)
  local nowIndex = self.uiBinder.rect_attr_detail:GetSiblingIndex()
  local clickIndex = unit.Trans:GetSiblingIndex()
  if nowIndex > clickIndex or config.Type ~= self.selectAttr_.Type then
    self.uiBinder.rect_attr_detail:SetSiblingIndex(unit.Trans:GetSiblingIndex() + 1)
  else
    self.uiBinder.rect_attr_detail:SetSiblingIndex(unit.Trans:GetSiblingIndex())
  end
  self.uiBinder.layout_detailed:ForceRebuildLayoutImmediate()
  self.selectAttr_ = config
end

return Role_info_attr_detailView
