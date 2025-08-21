local UI = Z.UI
local super = require("ui.ui_view_base")
local Handbook_postcard_windowView = class("Handbook_postcard_windowView", super)
local loop_list_view = require("ui.component.loop_list_view")
local handbookPostcardLoopListItem = require("ui.component.handbook.handbook_postcard_loop_list_item")
local handbookDefine = require("ui.model.handbook_define")
local handbookPostcardTableMap = require("table.HandbookPostcardTableMap")

function Handbook_postcard_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "handbook_postcard_window")
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
  self.handbookData_ = Z.DataMgr.Get("handbook_data")
end

function Handbook_postcard_windowView:OnActive()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2088)
  end)
  self.selectId_ = nil
  local datas = handbookPostcardTableMap.Postcard
  local mgr = Z.TableMgr.GetTable("NotePostcardTableMgr")
  table.sort(datas, function(a, b)
    local aState = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Postcard, a)
    local bState = self.handbookVM_.GetUnitUISortState(handbookDefine.HandbookType.Postcard, b)
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
  self.postcardLoop_ = loop_list_view.new(self, self.uiBinder.loop_left, handbookPostcardLoopListItem, "handbook_postcard_list_item_tpl")
  self.postcardLoop_:Init(datas)
  self.postcardLoop_:SetSelected(1)
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.HandbookPostCard)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
end

function Handbook_postcard_windowView:OnDeActive()
  self.postcardLoop_:UnInit()
  self.postcardLoop_ = nil
end

function Handbook_postcard_windowView:OnRefresh()
end

function Handbook_postcard_windowView:SelectId(id)
  if id == self.selectId_ then
    return
  end
  self.selectId_ = id
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Postcard, self.selectId_)
  if isUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lock_photo, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_lock, false)
    local config = Z.TableMgr.GetTable("NotePostcardTableMgr").GetRow(self.selectId_)
    if config then
      self.uiBinder.lab_title_name.text = config.Name
      self.uiBinder.lab_content.text = config.DictionaryDes
      self.uiBinder.rimg_photo:SetImage(config.Resources)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lock_photo, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_lock, true)
    self.uiBinder.lab_title_name.text = Lang("HandbookLockContent")
  end
end

return Handbook_postcard_windowView
