local super = require("ui.component.loop_list_view_item")
local TeamItem = class("TeamItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local MEMBERCOUNT = 4
local snpashotVm = Z.VMMgr.GetVM("snapshot")

function TeamItem:ctor()
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.teamData_ = Z.DataMgr.Get("team_data")
end

function TeamItem:OnInit()
  self.memberItemIcon20_ = {}
  self.talentNodes_ = {}
  for i = 1, 20 do
    self.memberItemIcon20_[i] = self.uiBinder.layout_20team["img_talent" .. i]
  end
  for i = 1, 3 do
    self.talentNodes_[i] = {
      img = self.uiBinder.node_profession["img_profession_" .. i],
      lab = self.uiBinder.node_profession["lab_num" .. i]
    }
  end
end

function TeamItem:refreshHead(data, unit)
  local charId = data.basicData.charID
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
    playerPortraitHgr.InsertNewPortraitBySocialData(unit, data, nil, self.parent.UIView.cancelSource:CreateToken())
  end
  self.parent.UIView:AddAsyncClick(unit.img_bg, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(charId, self.parent.UIView.cancelSource:CreateToken())
  end)
  unit.Ref.UIComp:SetVisible(true)
end

function TeamItem:OnRefresh(data)
  self.data = data
  self.teamMaxMemberType_ = self.data.teamMemberType
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_head, self.teamMaxMemberType_ == E.ETeamMemberType.Five)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_head_empty, self.teamMaxMemberType_ == E.ETeamMemberType.Five)
  self.uiBinder.layout_20team.Ref.UIComp:SetVisible(self.teamMaxMemberType_ == E.ETeamMemberType.Twenty)
  local targetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.data.targetId)
  local talentIdList = {}
  if targetInfo then
    self.uiBinder.lab_title.text = targetInfo.Name
    if targetInfo.Icon ~= "" then
      self.uiBinder.img_copy_picture:SetImage(Z.ConstValue.Team.TargetIconPath .. targetInfo.Icon)
    end
    for index, value in ipairs(targetInfo.Talent) do
      if value[1] ~= 0 then
        talentIdList[value[1]] = value[2]
      end
    end
  end
  self.uiBinder.leader_head.Ref.UIComp:SetVisible(false)
  for index, value in ipairs(self.talentNodes_) do
    self.uiBinder.node_profession.Ref:SetVisible(value.img, false)
  end
  if self.teamMaxMemberType_ == E.ETeamMemberType.Five then
    self:setFiveInfo(talentIdList)
  else
    self:setTwentyInfo(talentIdList)
  end
  self.uiBinder.lab_info.text = self.data.desc == "" and Lang("None") or self.data.desc
  self:refreshBtnInteractable()
  self.parent.UIView:AddAsyncClick(self.uiBinder.cont_btn_apply, function()
    self:applyJoinTeam()
  end)
end

function TeamItem:setFiveInfo(talentIdList)
  local memberCount = 0
  for i = MEMBERCOUNT, 1, -1 do
    self.uiBinder["node_head" .. i].Ref.UIComp:SetVisible(false)
    self.uiBinder.Ref:SetVisible(self.uiBinder["img_talent" .. i], false)
  end
  if 0 < table.zcount(talentIdList) then
    for key, data in ipairs(self.data.mems) do
      local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", data.socialData.professionData.professionId)
      if professionRow and talentIdList[professionRow.Talent] then
        talentIdList[professionRow.Talent] = talentIdList[professionRow.Talent] - 1
        if 0 >= talentIdList[professionRow.Talent] then
          talentIdList[professionRow.Talent] = nil
        end
      end
    end
    talentIdList = table.zkeys(talentIdList)
  end
  for _, data in ipairs(self.data.mems) do
    local charId = data.socialData.basicData.charID
    if charId == self.data.leaderId then
      self.uiBinder.lab_name.text = data.socialData.basicData.name
      self.uiBinder.lab_gs.text = Lang("LvFormatSymbol", {
        val = data.socialData.basicData.level
      })
      self:refreshHead(data.socialData, self.uiBinder.leader_head)
    else
      memberCount = memberCount + 1
      self:refreshHead(data.socialData, self.uiBinder["node_head" .. memberCount])
    end
  end
  if 0 < #talentIdList and memberCount < MEMBERCOUNT then
    for key, talentId in ipairs(talentIdList) do
      if memberCount >= MEMBERCOUNT then
        break
      end
      memberCount = memberCount + 1
      local talentTagTableRow = Z.TableMgr.GetRow("TalentTagTableMgr", talentId)
      if talentTagTableRow then
        self.uiBinder.Ref:SetVisible(self.uiBinder["img_talent" .. memberCount], true)
        self.uiBinder["img_talent" .. memberCount]:SetImage(talentTagTableRow.TagIconBg)
      end
    end
  end
end

function TeamItem:setTwentyInfo(talentIdList)
  local haveTalentCount = {}
  for index, img in ipairs(self.memberItemIcon20_) do
    local data = self.data.mems[index]
    if data and data.socialData then
      if data.socialData.basicData.charID == self.data.leaderId then
        self.uiBinder.lab_name.text = data.socialData.basicData.name
        self.uiBinder.lab_gs.text = Lang("LvFormatSymbol", {
          val = data.socialData.basicData.level
        })
      end
      self.uiBinder.layout_20team.Ref:SetVisible(img, true)
      local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", data.socialData.professionData.professionId)
      if professionRow then
        img:SetImage(professionRow.Icon)
        img:SetColorByHex(professionRow.TalentColor)
        if haveTalentCount[professionRow.Talent] then
          haveTalentCount[professionRow.Talent] = haveTalentCount[professionRow.Talent] + 1
        else
          haveTalentCount[professionRow.Talent] = 1
        end
      end
    else
      self.uiBinder.layout_20team.Ref:SetVisible(img, false)
    end
  end
  local talentIndex = 0
  for talentId, talentCount in pairs(talentIdList) do
    talentIndex = talentIndex + 1
    local talentNode = self.talentNodes_[talentIndex]
    if talentNode then
      talentNode.lab.text = string.zconcat(haveTalentCount[talentId] or 0, "/", talentCount)
      local talentTagTableRow = Z.TableMgr.GetRow("TalentTagTableMgr", talentId)
      if talentTagTableRow then
        talentNode.img:SetImage(talentTagTableRow.TagIconBg)
      end
      self.uiBinder.node_profession.Ref:SetVisible(talentNode.img, true)
    end
  end
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
