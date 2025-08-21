local UI = Z.UI
local super = require("ui.ui_view_base")
local Bug_windowView = class("Bug_windowView", super)
local priorityTypes = {
  "\232\175\183\233\128\137\230\139\169",
  "\230\153\174\233\128\154",
  "\233\171\152",
  "\231\180\167\230\128\165"
}

function Bug_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "bug_window")
  self.bugReportVM_ = Z.VMMgr.GetVM("bug_report")
  self.bugReportData_ = Z.DataMgr.Get("bug_report_data")
end

function Bug_windowView:OnActive()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_inner, not Z.IsOfficalVersion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player, Z.IsOfficalVersion)
  if self.viewData then
    self.uiBinder.cut_screen:InitUI(self.viewData.tex)
  end
  if not Z.IsOfficalVersion then
    self:refreshDevelopment()
  else
    self:refreshPlayer()
  end
  self.uiBinder.toggle_only_submit_log:SetIsOnWithoutCallBack(false)
  self:bindBtnClick()
  self:CheckSubBtnEnable()
end

function Bug_windowView:CheckSubBtnEnable()
  local enable = true
  if not Z.IsOfficalVersion then
    if self.uiBinder.node_dpd_pipeline.dpd.value == 0 or self.uiBinder.node_dpd_proority.dpd.value == 0 or self.uiBinder.input_content_inner.text == "" then
      enable = false
    end
  elseif self.uiBinder.input_content_player.text == "" or self.uiBinder.input_title_player == "" then
    enable = false
  end
  self.uiBinder.btn_submit.IsDisabled = not enable
end

function Bug_windowView:OnDeActive()
  self.uiBinder.input_content_inner.text = ""
  self.uiBinder.input_expect_result.text = ""
  self.uiBinder.input_expect_time.text = ""
  self.uiBinder.input_expect_fixer.text = ""
  self.uiBinder.input_expect_cc.text = ""
  self.uiBinder.input_title_player.text = ""
  self.uiBinder.input_content_player.text = ""
  self.uiBinder.cut_screen:ClearAll()
end

function Bug_windowView:OnRefresh()
end

function Bug_windowView:bindBtnClick()
  self:AddAsyncClick(self.uiBinder.btn_submit, function()
    self:BtnSubmitClick()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.bugReportVM_.CloseBugReprotView()
  end)
  self:AddClick(self.uiBinder.btn_clear, function()
    self.uiBinder.cut_screen:Clean()
  end)
  self.uiBinder.node_dpd_pipeline.dpd:AddListener(function(index)
    self:CheckSubBtnEnable()
  end)
  self.uiBinder.node_dpd_proority.dpd:AddListener(function(index)
    self:CheckSubBtnEnable()
  end)
  self.uiBinder.input_content_inner:AddListener(function(string)
    self:CheckSubBtnEnable()
  end)
  self.uiBinder.input_content_player:AddListener(function(string)
    self:CheckSubBtnEnable()
  end)
  self.uiBinder.input_title_player:AddListener(function(string)
    self:CheckSubBtnEnable()
  end)
end

function Bug_windowView:refreshDevelopment()
  local pipeLineOptions = self.bugReportData_:GetAllPipeLineOptions()
  self.uiBinder.node_dpd_pipeline.dpd:ClearAll()
  self.uiBinder.node_dpd_pipeline.dpd:AddListener(function(index)
  end, true)
  table.insert(pipeLineOptions, 1, "\232\175\183\233\128\137\230\139\169")
  self.uiBinder.node_dpd_pipeline.dpd:AddOptions(pipeLineOptions)
  self.uiBinder.node_dpd_proority.dpd:ClearAll()
  self.uiBinder.node_dpd_proority.dpd:AddListener(function(index)
  end, true)
  self.uiBinder.node_dpd_proority.dpd:AddOptions(priorityTypes)
end

function Bug_windowView:BtnSubmitClick()
  if self.isSubmiting_ then
    return
  end
  self.isSubmiting_ = true
  local tex = self.uiBinder.cut_screen.submitText
  local playerPos = Vector3.zero
  local playerServerPos = Vector3.zero
  local layerConfigId = 0
  local uuid = 0
  local charId = 0
  if Z.EntityMgr.PlayerEnt then
    playerPos = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
    playerServerPos = Z.EntityMgr.PlayerEnt:GetLuaAttrPos()
    layerConfigId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
    uuid = Z.EntityMgr.PlayerEnt.Uuid
    charId = Z.ContainerMgr.CharSerialize.charBase.charId
  end
  local form = Z.BugReportMgr:GetDefaultForm()
  form.screenShot = tex
  form.username = UnityEngine.SystemInfo.deviceName .. "  uuid:" .. uuid .. "  charid:" .. charId
  form.onlySubmitLog = self.uiBinder.toggle_only_submit_log.isOn
  if Z.IsOfficalVersion then
    form.description = self.uiBinder.input_content_player.text .. [[

pos:]] .. string.format("%.2f, %.2f, %.2f", playerPos.x, playerPos.y, playerPos.z) .. [[

serverPos:]] .. string.format("%.2f, %.2f, %.2f", playerServerPos.x, playerServerPos.y, playerServerPos.z) .. self:GetSceneInfo() .. " \n\232\167\134\233\135\142\229\177\130\231\186\167id:" .. layerConfigId
    form.pipelineType = self.uiBinder.input_title_player.text
    self.bugReportVM_.SubmitBug(form, function(error)
      self:SubmitCallBack(error)
    end)
    return
  end
  form.description = self.uiBinder.input_content_inner.text .. [[

pos:]] .. string.format("%.2f, %.2f, %.2f", playerPos.x, playerPos.y, playerPos.z) .. [[

serverPos:]] .. string.format("%.2f, %.2f, %.2f", playerServerPos.x, playerServerPos.y, playerServerPos.z) .. self:GetSceneInfo() .. " \n\232\167\134\233\135\142\229\177\130\231\186\167id:" .. layerConfigId
  form.expectResult = self.uiBinder.input_expect_result.text .. (self.uiBinder.input_expect_fixer.text == "" and "" or "\227\128\144\230\156\159\230\156\155\229\164\132\231\144\134\228\186\186\227\128\145 " .. self.uiBinder.input_expect_fixer.text)
  form.cc = self.uiBinder.input_expect_cc.text
  form.expectTime = self.uiBinder.input_expect_time.text
  if not self.uiBinder.toggle_only_submit_log.isOn then
    local bugReportConfigTableRow = self.bugReportData_:GetConfigByIndex(self.uiBinder.node_dpd_pipeline.dpd.value)
    if bugReportConfigTableRow then
      form.pipelineType = bugReportConfigTableRow.Desc
      form.pipelineQA = bugReportConfigTableRow.DataValue
      form.pipelineQAzh = bugReportConfigTableRow.DataValue2
      form.priorityType = priorityTypes[self.uiBinder.node_dpd_proority.dpd.value]
    end
  end
  self.bugReportVM_.SubmitBug(form, function(error)
    self:SubmitCallBack(error)
  end)
end

function Bug_windowView:GetSceneInfo()
  local curSceneID = Z.StageMgr.GetCurrentSceneId()
  local sceneInfo = "\n\229\156\186\230\153\175\228\191\161\230\129\175:" .. curSceneID .. " "
  local sceneTableRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(curSceneID)
  if sceneTableRow then
    sceneInfo = sceneInfo .. sceneTableRow.Name
    local sceneResourceTableRow = Z.TableMgr.GetTable("SceneResourceTableMgr").GetRow(sceneTableRow.SceneResourceId)
    if sceneResourceTableRow then
      sceneInfo = sceneInfo .. "(" .. sceneResourceTableRow.SceneFile .. ")"
    end
  end
  return sceneInfo
end

function Bug_windowView:refreshPlayer()
end

function Bug_windowView:SubmitCallBack(error)
  self.isSubmiting_ = false
  Z.BugReportMgr:UpdateSendCD()
  if error == nil then
    self.bugReportVM_.CloseBugReprotView()
    Z.TipsVM.ShowTipsLang(60080625)
  end
end

return Bug_windowView
