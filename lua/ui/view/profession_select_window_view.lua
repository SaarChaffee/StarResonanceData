local UI = Z.UI
local super = require("ui.ui_view_base")
local Profession_select_windowView = class("Profession_select_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local profession_loop_item = require("ui.component.profession.profession_loop_item")

function Profession_select_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "profession_select_window")
end

function Profession_select_windowView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  self:initZWidget()
  self:initData()
  self:initFunc()
  self:hideModel()
  self.uiBinder.Ref:SetVisible(self.loadingMask_, false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  if not self.viewData.isFaceView then
    self:refreshWeaponList()
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", false)
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", false)
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", false)
  else
    self:initWeaponList()
  end
  self:BindEvent()
end

function Profession_select_windowView:BindEvent()
  if not self.viewData.isFaceView then
    function self.onContainerChanged(container, dirty)
      if dirty.curProfessionId then
        self:refreshWeaponList()
      end
    end
    
    Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
    Z.EventMgr:Add(Z.ConstValue.Quest.QuestFlowLoaded, self.onQuestFlowLoad, self)
  else
  end
end

function Profession_select_windowView:onQuestFlowLoad(questId)
  if questId == self.questId_ then
    self:onQuestAccept(questId)
  end
end

function Profession_select_windowView:OnDeActive()
  self.professionVideo_:RemoveAllListeners()
  self.professionVideo_ = nil
  self:stopWeaponSkillSound()
  self.professionLoopRect_:UnInit()
  self.professionLoopRect_ = nil
  self.selectSkillUnit_ = nil
  self:showModel()
  self:clearTimer()
  Z.CommonTipsVM.CloseRichText()
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.CommonTipsVM.CloseSkillTips()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
  self.uiBinder.Ref:SetVisible(self.loadingMask_, false)
end

function Profession_select_windowView:OnRefresh()
end

function Profession_select_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("profession_select_window")
end

function Profession_select_windowView:initZWidget()
  self.professionLoop_ = self.uiBinder.loop_item
  self.professionName_ = self.uiBinder.lab_name
  self.img_talent_icon_ = self.uiBinder.img_talent_icon
  self.startTog1_ = self.uiBinder.tog_star_level_1
  self.startTog2_ = self.uiBinder.tog_star_level_2
  self.startTog3_ = self.uiBinder.tog_star_level_3
  self.startTog4_ = self.uiBinder.tog_star_level_4
  self.startTog5_ = self.uiBinder.tog_star_level_5
  self.skill1_ = self.uiBinder.cont_skill_1
  self.skill2_ = self.uiBinder.cont_skill_2
  self.skill3_ = self.uiBinder.cont_skill_3
  self.skill4_ = self.uiBinder.cont_skill_4
  self.skill5_ = self.uiBinder.cont_skill_5
  self.skill6_ = self.uiBinder.cont_skill_6
  self.selectWeaponBtn_ = self.uiBinder.btn_weapon_choice
  self.returnBtn_ = self.uiBinder.btn_return_pinch
  self.professionVideo_ = self.uiBinder.group_video
  self.videoBtn_ = self.uiBinder.btn_play
  self.allVideoBtn_ = self.uiBinder.node_demo
  self.weaponDesc_ = self.uiBinder.lab_content
  self.closeBtn_ = self.uiBinder.btn_close
  self.loadingMask_ = self.uiBinder.img_loading_mask
  self.btnChange = self.uiBinder.btn_change
  self.btnChangeBinder = self.uiBinder.btn_change_binder
  self.btnTrace = self.uiBinder.btn_trace
  self.uiBinder.Ref:SetVisible(self.btnTrace, not self.viewData.isFaceView)
  self.uiBinder.Ref:SetVisible(self.btnChange, not self.viewData.isFaceView)
  self.uiBinder.Ref:SetVisible(self.selectWeaponBtn_, self.viewData.isFaceView)
  self.uiBinder.Ref:SetVisible(self.returnBtn_, self.viewData.isFaceView)
end

function Profession_select_windowView:initData()
  self.professionLoopRect_ = loopListView.new(self, self.professionLoop_, profession_loop_item, "profession_choose_tpl", true)
  self.professionSkill_ = {
    [1] = self.skill1_,
    [2] = self.skill2_,
    [3] = self.skill3_,
    [4] = self.skill4_,
    [5] = self.skill5_,
    [6] = self.skill6_
  }
  self.talentTogs_ = {
    [1] = self.uiBinder.tog_1,
    [2] = self.uiBinder.tog_2
  }
  self.togLabels_ = {
    [1] = self.uiBinder.tog_1_lab,
    [2] = self.uiBinder.tog_2_lab
  }
  self.togOnLabels_ = {
    [1] = self.uiBinder.tog_1_lab_on,
    [2] = self.uiBinder.tog_2_lab_on
  }
  self.startTog_ = {
    self.startTog1_,
    self.startTog2_,
    self.startTog3_,
    self.startTog4_,
    self.startTog5_
  }
  self.curProfessionSysTable_ = nil
  self.curProfessionSkillIndex_ = 1
  self.selectTogIndex_ = 1
  self.skillTogCount_ = 3
  self.initLoop_ = false
  self.questId_ = nil
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.playerModel_ = Z.UnrealSceneMgr:GetCacheModel(self.faceData_.FaceModelName)
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.changeWepaonInCd_ = false
  self.changeSkillInCd_ = false
end

function Profession_select_windowView:initFunc()
  self:AddClick(self.closeBtn_, function()
    local professionVm = Z.VMMgr.GetVM("profession")
    professionVm:CloseProfessionSelectView()
  end)
  self:AddClick(self.returnBtn_, function()
    local professionVm = Z.VMMgr.GetVM("profession")
    professionVm:CloseProfessionSelectView()
  end)
  self:AddClick(self.selectWeaponBtn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DescFaceConfirm"), function()
      self:onConfirmCreateRoleClick()
    end)
  end)
  self:AddAsyncClick(self.btnChange, function()
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.selectProfessionId_)
    if not professionRow then
      return
    end
    local equip = self.weaponVm_.CheckWeaponEquip(self.selectProfessionId_)
    if equip then
      return
    end
    Z.DialogViewDataMgr:OpenNormalDialog(string.format(Lang("profession_change_dialog"), professionRow.Name, professionRow.Name), function()
      self.professionVm_:AsyncChangeProfession(self.selectProfessionId_, self.cancelSource:CreateToken())
    end)
  end)
  self:AddAsyncClick(self.btnTrace, function()
    local professSysRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.selectProfessionId_)
    if professSysRow == nil then
      return
    end
    local unLockList = professSysRow.UnlockCondition[1]
    if unLockList == nil then
      return
    end
    local unLockList = {}
    for _, value in ipairs(professSysRow.UnlockCondition) do
      if value[1] == E.ConditionType.TaskOver then
        unLockList = value
        break
      end
    end
    if #unLockList == 0 then
      return
    end
    local questId = unLockList[2]
    self.questId_ = questId
    if Z.ContainerMgr.CharSerialize.questList.questMap[questId] then
      self:onQuestAccept(questId)
    else
      self.professionVm_:AsyncAcceptProfessionQuest(self.selectProfessionId_, self.cancelSource:CreateToken())
    end
  end)
  self.professionVideo_:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.videoBtn_, false)
  end, function()
    self:setWeaponSkillVideo()
    self.uiBinder.Ref:SetVisible(self.videoBtn_, true)
  end, function()
    self:stopWeaponSkillSound()
  end)
  self:AddAsyncClick(self.videoBtn_, function()
    self.uiBinder.Ref:SetVisible(self.videoBtn_, false)
    self.professionVideo_:PlayCurrent(true)
    self:setWeaponSkillSound(true)
  end)
  self.uiBinder.Ref:SetVisible(self.videoBtn_, false)
  for index, value in ipairs(self.talentTogs_) do
    value.group = self.uiBinder.togs_group
    value:RemoveAllListeners()
    value.isOn = false
    value:AddListener(function(isOn)
      if isOn then
        self.selectTogIndex_ = index
        self:refreshTalentStageInfo()
      end
    end)
  end
end

function Profession_select_windowView:onQuestAccept(questId)
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  questTrackVM.ReplaceAndTrackingQuest(questId)
  local questDetailVm_ = Z.VMMgr.GetVM("questdetail")
  questDetailVm_.OpenDetailView()
end

function Profession_select_windowView:onConfirmCreateRoleClick()
  if not self.curProfessionSysTable_ then
    logError("[Account] not professionTable")
    return
  end
  local loginVM = Z.VMMgr.GetVM("login")
  local data = Z.DataMgr.Get("player_data")
  self.uiBinder.Ref:SetVisible(self.loadingMask_, true)
  self.IsResponseInput = false
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.CheckLocalFaceData()
  local reply = loginVM:AsyncCreateChar(data.AccountName, self.faceData_.Gender, self.faceData_.BodySize, faceVM.ConvertOptionDictToProtoData(), self.curProfessionSysTable_.Id)
  if reply.errCode ~= 0 then
    Z.TipsVM.ShowTips(reply.errCode)
    loginVM:KickOffByServer(reply.errCode)
    self.uiBinder.Ref:SetVisible(self.loadingMask_, false)
    self.IsResponseInput = true
    return
  end
  Z.SDKReport.Report(Z.SDKReportEvent.CharacterCreated)
  logGreen("[Account]CreateChar success with return:{0}", table.ztostring(reply))
  if data.CharDataList == nil then
    data.CharDataList = {}
  end
  data.CharDataList[#data.CharDataList + 1] = reply.socialData
  data:SortCharDataList(reply.socialData.charId)
  local charId = reply.socialData.charId
  loginVM:BeginSelectChar(charId, function()
    self.uiBinder.Ref:SetVisible(self.loadingMask_, false)
    self.IsResponseInput = true
  end)
end

function Profession_select_windowView:initWeaponList()
  local professionData = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  self.professionList_ = {}
  for _, professionRow in pairs(professionData) do
    local showInLoop = true
    if self.viewData.isFaceView and professionRow.Create == 0 then
      showInLoop = false
    end
    if showInLoop then
      self.professionList_[#self.professionList_ + 1] = professionRow
    end
  end
  table.sort(self.professionList_, function(left, right)
    return left.Index < right.Index
  end)
  self.professionLoopRect_:Init(self.professionList_)
  self.professionLoopRect_:ClearAllSelect()
  self.professionLoopRect_:SetSelected(1)
end

function Profession_select_windowView:refreshWeaponList()
  local weaponDatas = {}
  local professionData = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  for _, value in pairs(professionData) do
    if value.IsOpen then
      local weaponData = {
        Id = value.Id,
        unlock = self.weaponVm_.CheckWeaponUnlock(value.Id),
        equip = self.weaponVm_.CheckWeaponEquip(value.Id)
      }
      table.insert(weaponDatas, weaponData)
    end
  end
  table.sort(weaponDatas, function(a, b)
    if a.equip == b.equip then
      if a.unlock == b.unlock then
        if a.weaponLevel == b.weaponLevel then
          return a.Id < b.Id
        else
          return a.weaponLevel > b.weaponLevel
        end
      else
        return a.unlock
      end
    else
      return a.equip
    end
  end)
  self.selectProfessionId_ = self.weaponVm_.GetCurWeapon()
  local selectIndex = 1
  for index, value in ipairs(weaponDatas) do
    if value.Id == self.selectProfessionId_ then
      selectIndex = index
      break
    end
  end
  self.professionLoopRect_:ClearAllSelect()
  if self.initLoop_ then
    self.professionLoopRect_:RefreshListView(weaponDatas)
  else
    self.professionLoopRect_:Init(weaponDatas)
    self.initLoop_ = true
  end
  self.professionLoopRect_:SetSelected(selectIndex)
end

function Profession_select_windowView:OnSelectWeapon(professionId)
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if not professionRow then
    return
  end
  if not self.viewData.isFaceView then
    local unlock = self.professionVm_:CheckProfessionUnlock(professionId)
    local equip = self.weaponVm_.CheckWeaponEquip(professionId)
    self.uiBinder.Ref:SetVisible(self.btnTrace, not unlock)
    self.uiBinder.Ref:SetVisible(self.btnChange, unlock)
    if not equip then
      self.btnChangeBinder.lab_normal.text = Lang("Switch")
      self.btnChange.IsDisabled = false
    else
      self.btnChangeBinder.lab_normal.text = Lang("InUse")
      self.btnChange.IsDisabled = true
    end
  end
  self.selectProfessionId_ = professionId
  self.curProfessionSysTable_ = professionRow
  self.professionName_.text = professionRow.Name
  self.uiBinder.img_profession:SetImage(self.curProfessionSysTable_.Icon)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.weaponDesc_, professionRow.Intro)
  local talentConfig = Z.TableMgr.GetTable("TalentTagTableMgr").GetRow(self.curProfessionSysTable_.Talent)
  self.uiBinder.lab_job.text = talentConfig.TagName
  self.img_talent_icon_:SetImage(talentConfig.TagIconMark)
  self:AddAsyncClick(self.uiBinder.btn_talent_icon, function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, talentConfig.TagName, talentConfig.DetailsDes)
  end)
  if self.talentTogs_[1].isOn then
    self:refreshTalentStageInfo()
  else
    self.talentTogs_[1].isOn = true
  end
  for index, value in ipairs(self.togLabels_) do
    local talentRow = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(self.curProfessionSysTable_.ShowTalentStage[index])
    value.text = talentRow.Name[2]
    self.togOnLabels_[index].text = talentRow.Name[2]
  end
  self:ResetChangeWeaponCd()
end

function Profession_select_windowView:refreshTalentStageInfo()
  self.talentStageRow_ = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(self.curProfessionSysTable_.ShowTalentStage[self.selectTogIndex_])
  if not self.talentStageRow_ then
    return
  end
  for i = 1, #self.startTog_ do
    self.startTog_[i].isOn = i <= self.talentStageRow_.Factor
  end
  self.uiBinder.lab_type_info.text = self.talentStageRow_.MainDesShow
  self.uiBinder.lab_skill.text = string.format(Lang("profession_talent_desc"), self.talentStageRow_.Name[2])
  local content = ""
  for index, value in ipairs(self.talentStageRow_.MainAttrShow) do
    local fightAttrRow = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(value)
    if fightAttrRow then
      if index == #self.talentStageRow_.MainAttrShow then
        content = content .. fightAttrRow.OfficialName
      else
        content = content .. fightAttrRow.OfficialName .. Lang("SplitSign")
      end
    end
  end
  self.uiBinder.lab_attr.text = content
  for index, value in ipairs(self.professionSkill_) do
    local skillId = self.talentStageRow_.MainSkillShow[index]
    if skillId == nil then
      value.Ref.UIComp:SetVisible(false)
    else
      do
        local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
        if config then
          value.img_icon:SetImage(config.Icon)
        end
        value.Ref:SetVisible(value.img_on, false)
        self:AddClick(value.img_bg, function()
          Z.CommonTipsVM.OpenSkillTips(skillId, self.uiBinder.tips_root.anchoredPosition, Vector2.New(0.5, 0))
          if self.selectSkillUnit_ then
            self.selectSkillUnit_.Ref:SetVisible(self.selectSkillUnit_.img_on, false)
          end
          self.selectSkillUnit_ = value
          self.selectSkillUnit_.Ref:SetVisible(self.selectSkillUnit_.img_on, true)
        end)
      end
    end
  end
  self:setWeaponSkillVideo()
end

function Profession_select_windowView:setWeaponSkillVideo()
  if self.talentStageRow_.MainVideoShow == nil then
    return
  end
  self.professionVideo_:Prepare(self.talentStageRow_.MainVideoShow .. ".mp4", false, true)
  self.uiBinder.Ref:SetVisible(self.videoBtn_, true)
  self:setWeaponSkillSound()
end

function Profession_select_windowView:stopWeaponSkillSound()
  if self.curProfessionSoundName_ then
    Z.AudioMgr:StopSound(self.curProfessionSoundName_)
    self.curProfessionSoundName_ = nil
  end
end

function Profession_select_windowView:setWeaponSkillSound(isAgain)
  if isAgain then
    if self.curProfessionSoundName_ then
      Z.AudioMgr:StopSound(self.curProfessionSoundName_)
      Z.AudioMgr:Play(self.curProfessionSoundName_)
    end
    return
  end
  self:stopWeaponSkillSound()
  local path = self.talentStageRow_.MainVideoShow
  local lastBackslash = string.find(path, "/[^/]*$")
  if lastBackslash == nil then
    return
  end
  self.curProfessionSoundName_ = string.sub(path, lastBackslash + 1)
  Z.AudioMgr:Play(self.curProfessionSoundName_)
end

local changeWeaponCd_ = 0
local changeSkillCd_ = 1

function Profession_select_windowView:ResetChangeWeaponCd()
  if self.changeWeaponTimer_ then
    self.timerMgr:StopTimer(self.changeWeaponTimer_)
    self.changeWeaponTimer_ = nil
  end
  self.changeWepaonInCd_ = true
  self.changeWeaponTimer_ = self.timerMgr:StartTimer(function()
    self.changeWepaonInCd_ = false
  end, changeWeaponCd_, 1)
end

function Profession_select_windowView:ResetChangeSkillCd()
  if self.changeSkillTimer_ then
    self.timerMgr:StopTimer(self.changeSkillTimer_)
    self.changeSkillTimer_ = nil
  end
  self.changeSkillInCd_ = true
  self.changeSkillTimer_ = self.timerMgr:StartTimer(function()
    self.changeSkillInCd_ = false
  end, changeSkillCd_, 1)
end

function Profession_select_windowView:clearTimer()
  if self.changeSkillTimer_ then
    self.timerMgr:StopTimer(self.changeSkillTimer_)
    self.changeSkillTimer_ = nil
  end
  if self.changeWeaponTimer_ then
    self.timerMgr:StopTimer(self.changeWeaponTimer_)
    self.changeWeaponTimer_ = nil
  end
end

function Profession_select_windowView:CheckCanChangeSelectWeapon()
  return self.changeWepaonInCd_ == false
end

function Profession_select_windowView:CheckCanChangeSelectSkill()
  return self.changeSkillInCd_ == false
end

function Profession_select_windowView:showModel()
  if self.playerModel_ and self.playerModel_:IsAttrValid() then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_UNREALSCENE)
  end
end

function Profession_select_windowView:hideModel()
  if self.playerModel_ and self.playerModel_:IsAttrValid() then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_INVISIBLE)
  end
end

function Profession_select_windowView:onStartAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
end

return Profession_select_windowView
