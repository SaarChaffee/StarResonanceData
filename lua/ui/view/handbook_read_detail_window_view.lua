local UI = Z.UI
local super = require("ui.ui_view_base")
local Handbook_read_detail_windowView = class("Handbook_read_detail_windowView", super)
local loop_list_view = require("ui.component.loop_list_view")
local handbookDetailReadLoopListItem = require("ui.component.handbook.handbook_detailread_loop_list_item")
local handbookDefine = require("ui.model.handbook_define")

function Handbook_read_detail_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "handbook_read_detail_window")
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
end

function Handbook_read_detail_windowView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.readingLoop_ = loop_list_view.new(self, self.uiBinder.loop_left, handbookDetailReadLoopListItem, "handbook_read_list_item_tpl")
  self.readingLoop_:Init({})
  self.selectId_ = nil
  local config
  if self.viewData then
    config = Z.TableMgr.GetTable("NoteReadingBookWorksTableMgr").GetRow(self.viewData)
  end
  if config then
    self.uiBinder.lab_title_name.text = config.WorksName
    local datas = {}
    local datasCount = 0
    local mgr = Z.TableMgr.GetTable("NoteReadingBookTableMgr")
    for _, v in ipairs(config.TargetType) do
      local config = mgr.GetRow(v)
      if config and not config.IsHide then
        datasCount = datasCount + 1
        datas[datasCount] = v
      end
    end
    if datasCount <= 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_reads, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_singleread, false)
    elseif datasCount == 1 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_reads, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_singleread, true)
      self:SelectId(datas[1])
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_reads, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_singleread, false)
      self.readingLoop_:RefreshListView(datas)
      self.readingLoop_:SetSelected(1)
    end
  end
end

function Handbook_read_detail_windowView:OnDeActive()
  self.readingLoop_:UnInit()
  self.readingLoop_ = nil
  self.selectId_ = nil
  Z.EventMgr:Dispatch(Z.ConstValue.Handbook.ReadDetailRefresh)
end

function Handbook_read_detail_windowView:OnRefresh()
end

function Handbook_read_detail_windowView:SelectId(id)
  if id == self.selectId_ then
    return
  end
  self.selectId_ = id
  local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.Read, self.selectId_)
  if isUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.com_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_singleinfo, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.com_singleempty, false)
    local config = Z.TableMgr.GetTable("NoteReadingBookTableMgr").GetRow(self.selectId_)
    if config then
      self.uiBinder.lab_content.text = config.ReadingBookDes
      self.uiBinder.lab_singlecontent.text = config.ReadingBookDes
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.com_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_singleinfo, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.com_singleempty, true)
  end
  local isNew = self.handbookVM_.IsNew(handbookDefine.HandbookType.Read, id)
  if isNew then
    self.handbookVM_.SetNotNew(handbookDefine.HandbookType.Read, id)
  end
  self.readingLoop_:RefreshAllShownItem()
end

return Handbook_read_detail_windowView
