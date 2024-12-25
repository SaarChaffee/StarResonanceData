local UI = Z.UI
local super = require("ui.ui_view_base")
local GmView = class("GmView", super)
local LoopListView = require("ui.component.loop_list_view")
local group_loop_item = require("ui.component.gm.group_loop_item")
local gm_loop_item = require("ui.component.gm.gm_loop_item")
local desc_loop_item = require("ui.component.gm.desc_loop_item")
local history_loop_item = require("ui.component.gm.history_loop_item")
local result_loop_item = require("ui.component.gm.result_loop_item")

function GmView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gm")
  self.vm = Z.VMMgr.GetVM("gm")
  
  function self.onInputAction_(inputActionEventData)
    self:onInputAction(inputActionEventData)
  end
end

function GmView:OnActive()
  self.gmData_ = Z.DataMgr.Get("gm_data")
  self:AddClick(self.uiBinder.Close, function()
    Z.VMMgr.GetVM("gm").CloseGmView()
  end)
  self:AddClick(self.uiBinder.close, function()
    Z.VMMgr.GetVM("gm").CloseGmView()
  end)
  self:AddClick(self.uiBinder.urpSettingBtn, function()
    Z.VMMgr.GetVM("zrp_setting").OpenZrpSetting()
    Z.VMMgr.GetVM("gm").CloseGmView()
  end)
  self.groupLoopScrollRect = LoopListView.new(self, self.uiBinder.GroupScrollRect, group_loop_item, "group_content_item")
  self.groupLoopScrollRect:Init(Z.Global.GMTableGroup)
  self.groupLoopScrollRect:SetSelected(1)
  self.gmLoopScrollRect = LoopListView.new(self, self.uiBinder.BtnScrollRect, gm_loop_item, "gmbtn_content_item")
  self.gmLoopScrollRect:Init(self.vm.GetCurCmdTbl(1))
  self.descLoopScrollRect = LoopListView.new(self, self.uiBinder.descScrollRect, desc_loop_item, "desc_content_item")
  self.descLoopScrollRect:Init({})
  self.uiBinder.Ref:SetVisible(self.uiBinder.descScrollRect, false)
  self.historyLoopScrollRect = LoopListView.new(self, self.uiBinder.historyScrollRect, history_loop_item, "history_content_item")
  self.historyLoopScrollRect:Init({})
  self.uiBinder.Ref:SetVisible(self.uiBinder.historyScrollRect, false)
  self.resultLoopScrollRect = LoopListView.new(self, self.uiBinder.resultContainer, result_loop_item, "result_content_item")
  self.resultLoopScrollRect:Init(self.gmData_.SendServerCallLog)
  self:BindEvents()
end

function GmView:OnDeActive()
  self:UnBindEvents()
  self.groupLoopScrollRect:UnInit()
  self.gmLoopScrollRect:UnInit()
  self.descLoopScrollRect:UnInit()
  self.historyLoopScrollRect:UnInit()
  self.resultLoopScrollRect:UnInit()
  Z.InputMgr:EnableKeyBoard(true)
end

function GmView:BindEvents()
  Z.EventMgr:Add("InputKeyDown", self.inputKeyDown, self)
  Z.EventMgr:Add("InputKeyTab", self.inputKeyTab, self)
  Z.EventMgr:Add("InputKeyUp", self.inputKeyUp, self)
  Z.EventMgr:Add("GmBtnRefresh", self.gmBtnRefresh, self)
  Z.EventMgr:Add("RefreshInputField", self.refreshInputField, self)
  Z.EventMgr:Add("CmdResult", self.cmdResult, self)
  self:AddAsyncListener(self.uiBinder.cmdInput, self.uiBinder.cmdInput.AddSubmitListener, function()
    self:submitGMCmd()
  end)
  self:AddAsyncClick(self.uiBinder.sendBtn, function()
    self:submitGMCmd()
  end)
  self:AddClick(self.uiBinder.historyBtn, function()
    local b = not self.uiBinder.historyScrollRect_canvas.interactable
    self.uiBinder.Ref:SetVisible(self.uiBinder.historyScrollRect, b)
    if b then
      self.historyLoopScrollRect:RefreshListView(self.gmData_.HistoryInfo, false)
    end
  end)
  self:AddClick(self.uiBinder.cmdInput, function(str)
    local cmdInfo = self.vm.GetCmdInfo(str)
    if not cmdInfo then
      self.uiBinder.Ref:SetVisible(self.uiBinder.descScrollRect, false)
      return
    end
    local HasVal = 0 < #cmdInfo
    self.uiBinder.Ref:SetVisible(self.uiBinder.descScrollRect, HasVal)
    if HasVal then
      self.descLoopScrollRect:RefreshListView(cmdInfo, false)
    else
      self.descLoopScrollRect:RefreshListView({}, false)
    end
  end)
  self.uiBinder.common_slider:AddListener(function(value)
    self.uiBinder.root_canvas.alpha = value
  end)
end

function GmView:inputKeyTab(isUp)
  if self.uiBinder.descScrollRect_canvas.alpha == 1 then
    local data = self.descLoopScrollRect:GetDataByIndex(self.gmData_.DIndex)
    self:refreshInputField(data.Command .. " ")
  end
end

function GmView:inputKeyUp(isUp)
  if self.uiBinder.descScrollRect_canvas.alpha == 1 then
    self.vm.RefreshDesLoopNew(self.descLoopScrollRect, true)
  end
end

function GmView:inputKeyDown()
  if self.uiBinder.descScrollRect_canvas.alpha == 1 then
    self.vm.RefreshDesLoopNew(self.descLoopScrollRect, false)
  end
end

function GmView:UnBindEvents()
  self.uiBinder.cmdInput:RemoveAllListeners()
  Z.EventMgr:RemoveObjAll(self)
end

function GmView:gmBtnRefresh(param)
  local btnTbl = self.vm.GetCurCmdTbl(param)
  if 0 < #btnTbl then
    self.gmLoopScrollRect:RefreshListView(btnTbl, false)
  else
    self.gmLoopScrollRect:RefreshListView({}, false)
  end
end

function GmView:refreshInputField(param)
  self.uiBinder.cmdInput.text = param
  self.uiBinder.cmdInput:ActivateInputField()
  self.timerMgr:StartFrameTimer(function()
    self.uiBinder.cmdInput:MoveTextEnd(false)
  end, 1, 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.historyScrollRect, false)
end

function GmView:cmdResult(param)
  self.gmData_:SetLog(param)
  self.resultLoopScrollRect:RefreshListView(self.gmData_.SendServerCallLog, false)
  logGreen(param)
end

function GmView:submitGMCmd()
  self.uiBinder.Ref:SetVisible(self.uiBinder.historyScrollRect, false)
  local cmdStr = self.uiBinder.cmdInput.text
  local targetId = self.uiBinder.targetInput.text
  self.vm.SubmitGmCmd(cmdStr, nil, targetId)
end

return GmView
