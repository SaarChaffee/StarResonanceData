local UI = Z.UI
local super = require("ui.ui_view_base")
local Handbook_dictionaries_windowView = class("Handbook_dictionaries_windowView", super)
local loop_list_view = require("ui.component.loop_list_view")
local handbookDictionariesLoopListItem = require("ui.component.handbook.handbook_dictionaries_loop_list_item")
local handbookDefine = require("ui.model.handbook_define")
local handbookDictionaryTypeTableMap = require("table.HandbookDictionaryTypeTableMap")
local handbookDictionaryTableMap = require("table.HandbookDictionaryTableMap")

function Handbook_dictionaries_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "handbook_dictionaries_window")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
  self.handbookData_ = Z.DataMgr.Get("handbook_data")
end

function Handbook_dictionaries_windowView:OnActive()
  self.selectType_ = nil
  self.selectId_ = nil
  self.tabs_ = {}
  self.dictionaryLoop_ = loop_list_view.new(self, self.uiBinder.subview.loop_left, handbookDictionariesLoopListItem, "handbook_dictionaries_list_item_tpl")
  self.dictionaryLoop_:Init({})
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2089)
  end)
  local mgr = Z.TableMgr.GetTable("NoteDictionaryTypeTableMgr")
  Z.CoroUtil.create_coro_xpcall(function()
    local unitPath = self.uiBinder.prefab_cache:GetString("item_tog")
    for _, tab in ipairs(handbookDictionaryTypeTableMap.DictionaryType) do
      local config = mgr.GetRow(tab)
      local unitName = "togs_" .. config.Id
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_tog)
      if unit then
        unit.img_on:SetImage(config.ReadingBookDes)
        unit.img_off:SetImage(config.ReadingBookDes)
        unit.tog_tab_select.group = self.uiBinder.togs_group
        unit.tog_tab_select:AddListener(function(isOn)
          if isOn then
            self.commonVM_.CommonPlayTogAnim(unit.anim_tog, self.cancelSource:CreateToken())
            self:selectType(config.Id)
          end
        end)
        table.insert(self.tabs_, unit)
      end
    end
    self.uiBinder.togs_group:SetAllTogglesOff()
    self.tabs_[1].tog_tab_select.isOn = true
  end)()
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.HandbookDictionary)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
end

function Handbook_dictionaries_windowView:OnDeActive()
  self.uiBinder.togs_group:ClearAll()
  self.tabs_ = {}
  self.dictionaryLoop_:UnInit()
  self.dictionaryLoop_ = nil
end

function Handbook_dictionaries_windowView:OnRefresh()
end

function Handbook_dictionaries_windowView:selectType(type)
  if type == self.selectType_ then
    return
  end
  self.selectType_ = type
  local dictionaryIds = handbookDictionaryTableMap.Dictionary[self.selectType_]
  if dictionaryIds then
    local mgr = Z.TableMgr.GetTable("NoteDictionaryTableMgr")
    table.sort(dictionaryIds, function(a, b)
      local aState = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Dictionary, a)
      local bState = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Dictionary, b)
      if aState == bState then
        local aConfig = mgr.GetRow(a)
        local bConfig = mgr.GetRow(b)
        if aConfig and bConfig then
          return aConfig.Episode < bConfig.Episode
        else
          return false
        end
      else
        return aState < bState
      end
    end)
    self.dictionaryLoop_:ClearAllSelect()
    self.dictionaryLoop_:RefreshListView(dictionaryIds, true)
    self.dictionaryLoop_:SetSelected(1)
  else
    self.dictionaryLoop_:ClearAllSelect()
    self.dictionaryLoop_:RefreshListView({})
  end
end

function Handbook_dictionaries_windowView:SelectId(id)
  if id == self.selectId_ then
    return
  end
  self.selectId_ = id
  self:refreshSubView()
end

function Handbook_dictionaries_windowView:refreshSubView()
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Dictionary, self.selectId_)
  if isUnlock then
    self.uiBinder.subview.Ref:SetVisible(self.uiBinder.subview.node_info, true)
    self.uiBinder.subview.Ref:SetVisible(self.uiBinder.subview.node_lock, false)
    local config = Z.TableMgr.GetTable("NoteDictionaryTableMgr").GetRow(self.selectId_)
    if config then
      self.uiBinder.subview.lab_title_name.text = config.Name
      self.uiBinder.subview.lab_content.text = config.DictionaryDes
      if config.DictionaryFigure and config.DictionaryFigure ~= "" then
        self.uiBinder.subview.Ref:SetVisible(self.uiBinder.subview.node_rimg, true)
        self.uiBinder.subview.rimg_photo:SetImage(config.DictionaryFigure)
      else
        self.uiBinder.subview.Ref:SetVisible(self.uiBinder.subview.node_rimg, false)
      end
    end
  else
    self.uiBinder.subview.Ref:SetVisible(self.uiBinder.subview.node_info, false)
    self.uiBinder.subview.Ref:SetVisible(self.uiBinder.subview.node_lock, true)
  end
end

return Handbook_dictionaries_windowView
