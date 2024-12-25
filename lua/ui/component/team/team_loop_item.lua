local super = require("ui.component.loop_list_view_item")
local TeamItem = class("TeamItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local snpashotVm = Z.VMMgr.GetVM("snapshot")

function TeamItem:ctor()
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.teamData_ = Z.DataMgr.Get("team_data")
end

function TeamItem:OnInit()
end

function TeamItem:refreshHead(data, unit)
  local charId = data.basicData.charID
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(data.basicData.gender, data.basicData.bodySize)
  if data.basicData.botAiId ~= 0 then
    local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", data.basicData.botAiId)
    if botAITableRow then
      local path = snpashotVm.GetModelHeadPortrait(botAITableRow.ModelID)
      if path then
        unit.Ref:SetVisible(unit.img_portrait, true)
        unit.Ref:SetVisible(unit.rimg_portrait, false)
        unit.img_portrait:SetImage(path)
      end
    end
  else
    playerPortraitHgr.InsertNewPortraitBySocialData(unit, data)
  end
  self.parent.UIView:AddAsyncClick(unit.img_bg, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(charId, self.parent.UIView.cancelSource:CreateToken())
  end)
  unit.Ref.UIComp:SetVisible(true)
end

function TeamItem:OnRefresh(data)
  self.data = data
  local targetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.data.targetId)
  if targetInfo then
    self.uiBinder.lab_title.text = targetInfo.Name
    self.uiBinder.img_copy_picture:SetImage(Z.ConstValue.Team.TargetIconPath .. targetInfo.Icon)
  end
  self.uiBinder.lab_info.text = self.data.desc == "" and Lang("None") or self.data.desc
  self.uiBinder.leader_head.Ref.UIComp:SetVisible(false)
  for i = 1, 3 do
    self.uiBinder["node_head" .. i].Ref.UIComp:SetVisible(false)
  end
  local index = 0
  for _, data in ipairs(self.data.memSocialData) do
    local charId = data.basicData.charID
    if charId == self.data.leaderId then
      self.uiBinder.lab_name.text = data.basicData.name
      self.uiBinder.lab_gs.text = Lang("LvFormatSymbol", {
        val = data.basicData.level
      })
      self:refreshHead(data, self.uiBinder.leader_head)
    else
      index = index + 1
      self:refreshHead(data, self.uiBinder["node_head" .. index])
    end
  end
  self:refreshBtnInteractable()
  self.parent.UIView:AddAsyncClick(self.uiBinder.cont_btn_apply, function()
    self:applyJoinTeam()
  end)
end

function TeamItem:refreshBtnInteractable()
  local applyBtn = self.uiBinder.cont_btn_apply
  local isApply = self.teamData_:GetTeamApplyStatus(self.data.teamId)
  applyBtn.interactable = not isApply
  applyBtn.IsDisabled = isApply
end

function TeamItem:applyJoinTeam()
  if self.teamVM_.CheckIsInTeam() then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuitJoinTeam"), function()
      self.teamVM_.AsyncQuitJoinTeam({
        self.data.teamId
      }, self.parent.UIView.cancelSource)
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  else
    local ret = self.teamVM_.AsyncApplyJoinTeam({
      self.data.teamId
    }, self.parent.UIView.cancelSource:CreateToken())
    if ret == 0 then
      Z.TipsVM.ShowTipsLang(1000630)
    end
  end
end

function TeamItem:OnBeforePlayAnim()
  self.uiBinder.mask_bg.OnPlay:AddListener(function()
    self.uiBinder.Ref.UIComp:SetVisible(true)
  end)
  local groupAnimComp = self.parent:GetContainerGroupAnimComp()
  if groupAnimComp then
    groupAnimComp:AddTweenContainer(self.uiBinder.mask_bg)
    self.uiBinder.Ref.UIComp:SetVisible(false)
  end
end

function TeamItem:OnUnInit()
end

return TeamItem
