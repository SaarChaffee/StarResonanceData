local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_targetView = class("Team_targetView", super)
local dropDownLoopItem = require("ui.component.team.dropdown_loop_item")
local keyPad = require("ui.view.cont_num_keyboard_view")
local keypadType = {level = 1, score = 2}

function Team_targetView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_target")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.vm_ = Z.VMMgr.GetVM("team_target")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.keypad_ = keyPad.new(self)
end

function Team_targetView:initBinder()
  self.anim_ = self.uiBinder.anim
  self.scenemask_ = self.uiBinder.scenemask
  self.btn_close_ = self.uiBinder.cont_close
  self.tog_hall_ = self.uiBinder.cont_tog_hall
  self.input_desc_ = self.uiBinder.input_desc
  self.btn_frame1_ = self.uiBinder.img_btn_frame1
  self.btn_frame2_ = self.uiBinder.img_btn_frame2
  self.btn_frame3_ = self.uiBinder.img_btn_frame3
  self.btn_import_info1_ = self.uiBinder.btn_import_info1
  self.btn_import_info2_ = self.uiBinder.btn_import_info2
  self.btn_import_info3_ = self.uiBinder.btn_import_info3
  self.lab_import1_ = self.uiBinder.lab_import1
  self.lab_import2_ = self.uiBinder.lab_import2
  self.lab_import3_ = self.uiBinder.lab_import3
  self.scrollview_ = self.uiBinder.scrollview
  self.btn_save_ = self.uiBinder.btn_save
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.lab_num_ = self.uiBinder.lab_num
  self.targetDes_ = ""
  self.group_grade_ = self.uiBinder.group_grade
  self.group_score_ = self.uiBinder.group_score
  self.levelBtn_ = self.group_grade_.btn_kevel
  self.levelLab_ = self.group_grade_.lab_level
  self.scoreBtn_ = self.group_score_.btn_score
  self.scoreLab_ = self.group_score_.lab_score
  self.levelKeybadNode_ = self.group_grade_.node_small_keyboard
  self.scoreKeybadNode_ = self.group_score_.node_small_keyboard
end

function Team_targetView:initBtns()
  self:AddClick(self.levelBtn_, function(...)
    local curLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
    self.keypadType = keypadType.level
    self.keypad_:Active({max = curLevel}, self.levelKeybadNode_)
  end)
  self:AddClick(self.scoreBtn_, function(...)
    local curScore = 10000
    self.keypadType = keypadType.score
    self.keypad_:Active({max = curScore}, self.scoreKeybadNode_)
  end)
  self:AddClick(self.btn_close_, function()
    self.vm_.CloseTeamTargetView()
  end, nil, nil)
  self:AddAsyncClick(self.tog_hall_, function(isOn)
    self.isInTeamHall_ = isOn
    self.settingVM_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "ShowInTeamHall")] = isOn and "0" or "1"
    })
    self.teamVM_.SetShowHall(isOn, self.cancelSource:CreateToken())
  end, nil, nil)
  self:AddAsyncClick(self.btn_save_.btn, function()
    if self.saveErrorId_ ~= 0 then
      Z.TipsVM.ShowTips(self.saveErrorId_)
      return
    end
    local refreshCd = self.teamData_:GetTeamSimpleTime("teamTypeCD")
    if not refreshCd or refreshCd == 0 then
      self:sendTarget()
    else
      Z.TipsVM.ShowTips(1000650)
    end
  end, nil, nil)
  self:AddClick(self.input_desc_, function(str)
    local len = string.zlenNormalize(str)
    if len <= self.inputDesMaxCount_ then
      self.targetDes_ = str
    else
      self.input_desc_.text = self.targetDes_
      len = string.zlenNormalize(self.targetDes_)
    end
    self:setTargetDesLen(len)
  end)
  self:AddAsyncClick(self.btn_import_info1_, function()
    self.input_desc_.text = self.lab_import1_.text
  end, nil, nil)
  self:AddAsyncClick(self.btn_import_info2_, function()
    self.input_desc_.text = self.lab_import2_.text
  end, nil, nil)
  self:AddAsyncClick(self.btn_import_info3_, function()
    self.input_desc_.text = self.lab_import3_.text
  end, nil, nil)
  self:AddAsyncClick(self.btn_frame1_, function()
    self:setDesc(self.lab_import1_, self.lab_import1_.text, "BKL_EasyLang1")
  end, nil, nil)
  self:AddAsyncClick(self.btn_frame2_, function()
    self:setDesc(self.lab_import2_, self.lab_import2_.text, "BKL_EasyLang2")
  end, nil, nil)
  self:AddAsyncClick(self.btn_frame3_, function()
    self:setDesc(self.lab_import3_, self.lab_import3_.text, "BKL_EasyLang3")
  end, nil, nil)
end

function Team_targetView:OnActive()
  self:initBinder()
  self:initBtns()
  self.inputDesMaxCount_ = Z.Global.TeamInputDescMax
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self.myUuid_ = Z.EntityMgr.PlayerUuid
  self:setSettingInfo()
  self:setTarget()
  self:setTargetDesLen(string.zlenNormalize(self.input_desc_.text))
  self.input_desc_.characterLimit = self.inputDesMaxCount_
  Z.EventMgr:Add(Z.ConstValue.ScreenWordAndGrpcPass, self.onScreenWordPass, self)
end

function Team_targetView:setTargetDesLen(len)
  local paramExp = {
    value1 = len,
    value2 = self.inputDesMaxCount_
  }
  self.lab_num_.text = Lang("degreeExpValue", paramExp)
end

function Team_targetView:setDesc(lab, desc, key)
  local data = {
    title = Lang("AddText"),
    inputContent = desc,
    onConfirm = function(text)
      local ret = self.teamVM_.AsyncSetTeamTargetQuickSay(text, E.TextCheckSceneType.TextCheckTeamTargetQuickSay, self.cancelSource:CreateToken())
      if ret and lab then
        Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, key, text)
        lab.text = text
      end
    end,
    stringLengthLimitNum = Z.Global.TeamInputDescMax,
    isMultiLine = true
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Team_targetView:sendTarget()
  self.targetId_ = self.setTargetId_
  self.teamVM_.AsyncSetTeamTargetInfo(self.targetId_, self.input_desc_.text, nil, self.isInTeamHall_, self.cancelSource:CreateToken())
  self.teamVM_.SetTeamTargetTime()
end

function Team_targetView:teamRepeatNotMatch()
  Z.CoroUtil.create_coro_xpcall(function()
    self.teamVM_.AsyncSetTeamTargetInfo(self.targetId_, self.input_desc_.text, nil, self.isInTeamHall_, self.cancelSource:CreateToken())
  end)()
end

function Team_targetView:onScreenWordPass()
  self.vm_.CloseTeamTargetView()
end

function Team_targetView:setSettingInfo()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local teamTargetCfg = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(teamInfo.targetId)
  if not teamTargetCfg then
    logError("TeamTargetTableMgr key {0} not found", teamInfo.targetId)
    return
  end
  self.targetId_ = teamTargetCfg.Id
  self.targetName_ = teamTargetCfg.Name
  self.setTargetId_ = self.targetId_
  self:setSaveBtnLab()
  local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
  local inTeamHall = settingInfo[Z.PbEnum("ESettingType", "ShowInTeamHall")] or "0"
  self.input_desc_.text = teamInfo.desc
  self.isInTeamHall_ = inTeamHall == "0"
  self.tog_hall_.isOn = self.isInTeamHall_
end

function Team_targetView:setSaveBtnLab()
  local teamTargetCfg = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.setTargetId_)
  local isFiveTeam = true
  if teamTargetCfg and teamTargetCfg.TeamType == 1 then
    isFiveTeam = false
  end
  local members = self.teamVM_.GetTeamMemData()
  self.saveErrorId_ = 0
  if isFiveTeam and 5 < #members then
    self.btn_save_.lab_normal.text = Lang("TeamMemberExceedFive")
    self.saveErrorId_ = 1000651
  else
    self.btn_save_.lab_normal.text = Lang("SaveChanges")
  end
end

function Team_targetView:setTarget()
  self.targetView = dropDownLoopItem.new(self, self.scrollview_.Content, self.prefab_cache_:GetString("dropdown1"), self.prefab_cache_:GetString("dropdown2"))
  self.targetView:createTargetItem(true)
  self.input_desc_.text = self.teamData_.TeamInfo.baseInfo.desc
  local text = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, "BKL_EasyLang1")
  local desc = text ~= "" and text or Lang("EasyLang1")
  self.lab_import1_.text = desc
  local text = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, "BKL_EasyLang2")
  local desc = text ~= "" and text or Lang("EasyLang2")
  self.lab_import2_.text = desc
  local text = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, "BKL_EasyLang3")
  local desc = text ~= "" and text or Lang("EasyLang3")
  self.lab_import3_.text = desc
end

function Team_targetView:SetTargetid(targetId)
  self.setTargetId_ = targetId
  self.targetId_ = targetId
  self:setSaveBtnLab()
end

function Team_targetView:OnDeActive()
  self.anim_:Play(Z.DOTweenAnimType.Close)
  self.keypad_:DeActive()
end

function Team_targetView:OnRefresh()
end

function Team_targetView:InputNum(num)
  if self.keypadType == keypadType.level then
    self.levelLab_.text = num
  else
    self.scoreLab_.text = num
  end
end

return Team_targetView
