local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_targetView = class("Team_targetView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local dropDownLoopItem = require("ui.component.team.dropdown_loop_item")

function Team_targetView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_target")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.vm_ = Z.VMMgr.GetVM("team_target")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
end

function Team_targetView:initBinder()
  self.anim_ = self.uiBinder.anim
  self.scenemask_ = self.uiBinder.scenemask
  self.btn_close_ = self.uiBinder.cont_close
  self.tog_hall_ = self.uiBinder.cont_tog_hall
  self.tog_match_ = self.uiBinder.cont_tog_match
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
end

function Team_targetView:OnActive()
  self:initBinder()
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self.myUuid_ = Z.EntityMgr.PlayerUuid
  self:AddAsyncClick(self.btn_close_, function()
    self.vm_.CloseTeamTargetView()
  end, nil, nil)
  self:setSettingInfo()
  self:setTarget()
  self.inputDesMaxCount_ = Z.Global.TeamInputDescMax
  self:setTargetDesLen(string.zlen(self.input_desc_.text))
  self:AddAsyncClick(self.tog_hall_, function(isOn)
    self.isInTeamHall_ = isOn
    self.settingVM_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "ShowInTeamHall")] = isOn and "0" or "1"
    })
    self.teamVM_.SetShowHall(isOn, self.cancelSource:CreateToken())
  end, nil, nil)
  self:AddAsyncClick(self.tog_match_, function(isOn)
    self.isAutoMatch_ = isOn
    self.settingVM_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "TeamAutoMatch")] = isOn and "0" or "1"
    })
  end, nil, nil)
  self:AddAsyncClick(self.btn_save_, function()
    self:sendTarget()
  end, nil, nil)
  self.input_desc_.characterLimit = self.inputDesMaxCount_
  self:AddClick(self.input_desc_, function(str)
    local len = string.zlen(str)
    if len <= self.inputDesMaxCount_ then
      self.targetDes_ = str
    else
      self.input_desc_.text = self.targetDes_
      len = string.zlen(self.targetDes_)
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
  local vm = Z.VMMgr.GetVM("screenword")
  vm.CheckScreenWord(desc, E.TextCheckSceneType.TextCheckTeamTargetInfo, self.cancelSource:CreateToken(), function()
    local data = {
      title = Lang("AddText"),
      inputContent = desc,
      onConfirm = function(text)
        local vm = Z.VMMgr.GetVM("screenword")
        vm.CheckScreenWord(text, E.TextCheckSceneType.TextCheckTeamTargetInfo, self.cancelSource:CreateToken(), function()
          Z.LocalUserDataMgr.SetString(key, text)
          lab.text = text
        end)
      end,
      stringLengthLimitNum = Z.Global.TeamInputDescMax,
      isMultiLine = true
    }
    Z.TipsVM.OpenCommonPopupInput(data)
  end)
end

function Team_targetView:sendTarget()
  self.targetId_ = self.setTargetId_
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  if self.targetId_ == E.TeamTargetId.Costume and self.isAutoMatch_ then
    Z.TipsVM.ShowTipsLang(1000622)
  end
  local members = self.teamVM_.GetTeamMemData()
  if 4 <= #members and teamInfo.autoMatch then
    Z.TipsVM.ShowTipsLang(1000619)
  end
  local matchData = Z.DataMgr.Get("match_data")
  local teamMatching = matchData:GetSelfMatchData("teamMatching")
  if teamMatching then
    Z.EventMgr:Add(Z.ConstValue.Team.RepeatTeamCancelMatch, self.teamRepeatNotMatch, self)
    self.matchVm_.AsyncCancelMatchNew(E.MatchType.Team, true, self.cancelSource:CreateToken())
  else
    self.teamVM_.AsyncSetTeamTargetInfo(self.targetId_, self.input_desc_.text, self.isAutoMatch_, self.isInTeamHall_, self.cancelSource:CreateToken())
  end
end

function Team_targetView:teamRepeatNotMatch()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.EventMgr:Remove(Z.ConstValue.Team.RepeatTeamCancelMatch, self.teamRepeatNotMatch, self)
    self.teamVM_.AsyncSetTeamTargetInfo(self.targetId_, self.input_desc_.text, self.isAutoMatch_, self.isInTeamHall_, self.cancelSource:CreateToken())
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
  local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
  local inTeamHall = settingInfo[Z.PbEnum("ESettingType", "ShowInTeamHall")] or "0"
  local autoMatch = settingInfo[Z.PbEnum("ESettingType", "TeamAutoMatch")] or "0"
  self.isAutoMatch_ = autoMatch == "0"
  self.input_desc_.text = teamInfo.desc
  self.isInTeamHall_ = inTeamHall == "0"
  self.tog_hall_.isOn = self.isInTeamHall_
  self.tog_match_.isOn = self.isAutoMatch_
end

function Team_targetView:setTarget()
  self.targetView = dropDownLoopItem.new(self, self.scrollview_.Content, self.prefab_cache_:GetString("dropdown1"), self.prefab_cache_:GetString("dropdown2"))
  self.targetView:createTargetItem(true)
  self.input_desc_.text = self.teamData_.TeamInfo.baseInfo.desc
  local text = Z.LocalUserDataMgr.GetString("BKL_EasyLang1")
  local desc = text ~= "" and text or Lang("EasyLang1")
  self.lab_import1_.text = desc
  local text = Z.LocalUserDataMgr.GetString("BKL_EasyLang2")
  local desc = text ~= "" and text or Lang("EasyLang2")
  self.lab_import2_.text = desc
  local text = Z.LocalUserDataMgr.GetString("BKL_EasyLang3")
  local desc = text ~= "" and text or Lang("EasyLang3")
  self.lab_import3_.text = desc
end

function Team_targetView:SetTargetid(targetId)
  self.setTargetId_ = targetId
end

function Team_targetView:OnDeActive()
  self.anim_:Play(Z.DOTweenAnimType.Close)
end

function Team_targetView:OnRefresh()
end

return Team_targetView
