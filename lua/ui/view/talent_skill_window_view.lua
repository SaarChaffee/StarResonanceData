local UI = Z.UI
local super = require("ui.ui_view_base")
local Talent_skill_windowView = class("Talent_skill_windowView", super)
local TalentSkillDefine = require("ui.model.talent_skill_define")
local GroupMainSkillHeight = 470
local TalentZoneAdd = 0.01
local nextStationPrefabPath = "ui/prefabs/talent_new/talent_next_station"

function Talent_skill_windowView:ctor()
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "talent_skill_window")
  self.talentSkillVM_ = Z.VMMgr.GetVM("talent_skill")
  self.talentSkillData_ = Z.DataMgr.Get("talent_skill_data")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.rightGroupSubView_ = require("ui/view/talent_attr_info_sub_view").new(self)
  self.minTalentTreeScale_ = Z.Global.TalentPageScale[1]
  self.maxTalentTreeScale_ = Z.Global.TalentPageScale[2]
  self.scrollUnit_ = (self.maxTalentTreeScale_ * TalentZoneAdd - self.minTalentTreeScale_ * TalentZoneAdd) / 10
  self.talentTreeIsUnlockAndPos_ = {}
  self.talentTreeIsInPreview_ = {}
  self.talentTreeUnlockNodeCounts_ = {}
  self.canUITouchByAnimEnd_ = true
end

function Talent_skill_windowView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  for i = 1, TalentSkillDefine.TalentTreeMaxStage do
    self:AddClick(self.uiBinder["btn_location" .. i], function()
      self.uiBinder.content:SetAnchorPosition(0, self.talentTreeIsUnlockAndPos_[i].pos * self.zoomSize_)
    end)
  end
  self:AddClick(self.uiBinder.btn_zoom_out, function()
    self.lastZoomSize_ = self.zoomSize_
    self.zoomSize_ = self.zoomSize_ - TalentZoneAdd
    self.zoomSize_ = math.max(self.zoomSize_, self.minTalentTreeScale_ * TalentZoneAdd)
    self:refreshTalentTreeScaleAndSlider()
  end)
  self:AddClick(self.uiBinder.btn_zoom_in, function()
    self.lastZoomSize_ = self.zoomSize_
    self.zoomSize_ = self.zoomSize_ + TalentZoneAdd
    self.zoomSize_ = math.min(self.zoomSize_, self.maxTalentTreeScale_ * TalentZoneAdd)
    self:refreshTalentTreeScaleAndSlider()
  end)
  self.uiBinder.slider_zoom:AddListener(function(value)
    self.lastZoomSize_ = self.zoomSize_
    local addValue = TalentZoneAdd * value * (self.maxTalentTreeScale_ - self.minTalentTreeScale_) / 100
    self.zoomSize_ = self.minTalentTreeScale_ / 100 + addValue
    self:refreshTalentTreeScaleAndSlider()
  end)
  self.uiBinder.scrollview.OnScrollEvent:AddListener(function(scale)
    self.lastZoomSize_ = self.zoomSize_
    self.zoomSize_ = self.zoomSize_ + scale * self.scrollUnit_
    self.zoomSize_ = Mathf.Clamp(self.zoomSize_, self.minTalentTreeScale_ * TalentZoneAdd, self.maxTalentTreeScale_ * TalentZoneAdd)
    self:refreshTalentTreeScaleAndSlider()
  end)
  self:AddAsyncClick(self.uiBinder.btn_reset, function()
    self:onClickReset()
  end)
  self:AddAsyncClick(self.uiBinder.btn_source, function()
    self:openSourceTip()
  end)
  self:AddAsyncClick(self.uiBinder.btn_icon, function()
    self:openNotEnoughItemTips(self.talentSkillData_:GetTalentPointConfigId(), self.uiBinder.rect_icon)
  end)
  self:AddAsyncClick(self.uiBinder.btn_icon_weapon, function()
    if not self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.ProfessionLv, true) then
      return
    end
    if not self.canUITouchByAnimEnd_ then
      return
    end
    self:hideSelectUnit()
    self.selectTalentUnit_ = {
      type = TalentSkillDefine.TalentAttrInfoSubViewType.Weapon
    }
    self.uiBinder.rimg_icon_weapon:SetImage(self.professionSystemTable_.MainTalentSelectedIcon)
    self.uiBinder.rimg_adorn:SetImage(TalentSkillDefine.TalentSkillWindowAdornIconPath[2])
    self:hideRightSubView()
    local curWeaponIsUnlock = self.weaponVM_.CheckWeaponUnlock(self.professionSystemTable_.ProfessionId)
    if curWeaponIsUnlock then
      local viewData = {
        type = TalentSkillDefine.TalentAttrInfoSubViewType.Weapon,
        id = self.professionSystemTable_.ProfessionId,
        professionId = self.professionSystemTable_.ProfessionId,
        closeFunc = function()
          self:hideRightSubView()
        end
      }
      self:showRightSubView(viewData)
    else
      Z.TipsVM.ShowTipsLang(150021, {
        val = self.professionSystemTable_.Name
      })
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_recommend, function()
    self:recommedTalent()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(400002)
  end)
  self:AddAsyncClick(self.uiBinder.btn_head_forging, function()
    local professSysRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.professionSystemTable_.ProfessionId)
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
      local professionVm = Z.VMMgr.GetVM("profession")
      professionVm:AsyncAcceptProfessionQuest(self.professionSystemTable_.ProfessionId, self.cancelSource:CreateToken())
    end
  end)
  self:AddClick(self.uiBinder.btn_viewguide, function()
    local talentStageId = self.talentSkillVM_.GetCurProfessionTalentStage()
    local talenStageRow = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(talentStageId)
    if talenStageRow then
      self.helpsysVM_.OpenMulHelpSysView(talenStageRow.StrategyPage)
    end
  end)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect_5)
  Z.EventMgr:Add(Z.ConstValue.Quest.QuestFlowLoaded, self.onQuestAccept, self)
  Z.EventMgr:Add(Z.ConstValue.TalentSkill.UnLockTalent, self.talentChangeRefresh, self)
  self:initData()
  self:BindLuaAttrWatchers()
  Z.AudioMgr:Play("sys_hero_memory")
  self:RefreshProfession()
end

function Talent_skill_windowView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Quest.QuestFlowLoaded, self.onQuestAccept, self)
  Z.EventMgr:Remove(Z.ConstValue.TalentSkill.UnLockTalent, self.talentChangeRefresh, self)
  self:UnBindLuaAttrWatchers()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:closeSourceTip()
  self:hideSelectUnit()
  self:hideRightSubView()
  self.uiBinder.node_effect_3:ReleseEffGo()
  self.uiBinder.node_effect_5:ReleseEffGo()
  self.isCreateWeaponEffect_ = nil
  self:unloadTalentSkillTree()
  Z.UIMgr:ReleasePreloadAsset(TalentSkillDefine.TalentWindowCharacerLeftRimg .. self.professionSystemTable_.ProfessionId)
  Z.UIMgr:ReleasePreloadAsset(TalentSkillDefine.TalentWindowCharacerRightRimg .. self.professionSystemTable_.ProfessionId)
end

function Talent_skill_windowView:OnRefresh()
end

function Talent_skill_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Talent_skill_windowView:GetCacheData()
  local viewData = {}
  if self.professionSystemTable_ and self.professionSystemTable_.ProfessionId then
    viewData.professionId = self.professionSystemTable_.ProfessionId
  else
    viewData.professionId = self.weaponVM_.GetCurWeapon()
  end
  return viewData
end

function Talent_skill_windowView:initData()
  self.loadTalentTreeNames_ = {}
  self.nextStageSkills_ = {}
  self.talentTreeUnit_ = nil
  if Z.IsPCUI then
    self.zoomSize_ = self.minTalentTreeScale_ * TalentZoneAdd
  else
    self.zoomSize_ = (self.minTalentTreeScale_ + self.maxTalentTreeScale_) * TalentZoneAdd / 2
  end
  self.lastZoomSize_ = nil
  self.selectTalentUnit_ = nil
  self.canUITouchByAnimEnd_ = false
  self.curPointActiveTalentTreeNodes_ = {}
  self.curPointUnlockTalentTreeNodes_ = {}
  self.lineEffects_ = {}
  self.treeY_ = 0
  self.isCreateWeaponEffect_ = nil
  self.isInPreview_ = false
end

function Talent_skill_windowView:BindLuaAttrWatchers()
  function self.onContainerChanged(container, dirty)
    if dirty.professionList then
      if self.isCreateWeaponEffect_ == nil then
        local weaponTalent = self.professionSystemTable_.Talent
        
        self.uiBinder.node_effect_5:CreatEFFGO(TalentSkillDefine.TalentSkillWeaponLevelUpEffect[weaponTalent], Vector3.zero)
        self.uiBinder.node_effect_5:SetEffectGoVisible(true)
        self.isCreateWeaponEffect_ = true
      else
        self.uiBinder.node_effect_5:SetEffectGoVisible(true)
      end
      Z.AudioMgr:Play("sys_hero_skillup")
      self:refreshWeaponInfo()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function Talent_skill_windowView:UnBindLuaAttrWatchers()
  if self.onContainerChanged ~= nil then
    Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
    self.onContainerChanged = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function Talent_skill_windowView:RefreshProfession()
  if self.viewData and self.viewData.professionId then
    self.professionSystemTable_ = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.viewData.professionId)
  end
  if self.professionSystemTable_ then
    local weaponTalent = self.professionSystemTable_.Talent
    local style = TalentSkillDefine.SelectTalentUnrealSceneStyle[weaponTalent]
    Z.UnrealSceneMgr:SwicthVirtualStyle(style)
    self.uiBinder.node_effect_3:CreatEFFGO(TalentSkillDefine.TalentSkillWeaponOpenEffect[weaponTalent], Vector3.zero)
    self.uiBinder.node_effect_3:SetEffectGoVisible(true)
    local talentTagConfig = Z.TableMgr.GetTable("TalentTagTableMgr").GetRow(self.professionSystemTable_.Talent)
    local talentTagName = ""
    if talentTagConfig then
      talentTagName = talentTagConfig.TagName
    end
    self.uiBinder.lab_title.text = Lang("DefensefirearmsExpertise", {
      val1 = talentTagName,
      val2 = self.professionSystemTable_.Name
    })
    if self.viewData == nil or self.viewData.skillId == nil then
      local curWeaponIsUnlock = self.weaponVM_.CheckWeaponUnlock(self.professionSystemTable_.ProfessionId)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_head_forging, not curWeaponIsUnlock)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_recommend, curWeaponIsUnlock)
    end
    self.uiBinder.btn_recommend.IsDisabled = self.weaponVM_.GetCurWeapon() ~= self.viewData.professionId
    self.uiBinder.btn_reset.IsDisabled = self.weaponVM_.GetCurWeapon() ~= self.viewData.professionId
    self.uiBinder.rimg_icon_weapon:SetImage(self.professionSystemTable_.MainTalentIcon)
    self.uiBinder.rimg_adorn:SetImage(TalentSkillDefine.TalentSkillWindowAdornIconPath[1])
    self.uiBinder.rimg_line_middel:SetColor(TalentSkillDefine.TalentWindowMiddelRimg[weaponTalent])
    self.uiBinder.rimg_character_left:SetImage(TalentSkillDefine.TalentWindowCharacerLeftRimg .. self.professionSystemTable_.Id)
    self.uiBinder.rimg_character_right:SetImage(TalentSkillDefine.TalentWindowCharacerRightRimg .. self.professionSystemTable_.Id)
    self:refreshTalentPoints()
    self:refreshWeaponInfo()
    self:refreshTalentTreeScaleAndSlider()
    self:loadTalentTree(true)
    self:playAnim()
  end
end

function Talent_skill_windowView:playAnim()
  self.commonVM_.CommonPlayAnim(self.uiBinder.node_content, TalentSkillDefine.TalentWindowAnim .. self.professionSystemTable_.Id, self.cancelSource:CreateToken(), function()
    self.canUITouchByAnimEnd_ = true
  end)
end

function Talent_skill_windowView:refreshTalentPoints()
  self.uiBinder.lab_num.text = self.talentSkillVM_.GetSurpluseTalentPointCount(self.professionSystemTable_.ProfessionId) .. "/" .. self.talentSkillVM_.GetAllTalentPointCount()
end

function Talent_skill_windowView:talentChangeRefresh(talents)
  local posX, posY = self.uiBinder.content:GetAnchorPosition(nil, nil)
  self.treeY_ = posY
  local talentStage
  if talents then
    local mgr = Z.TableMgr.GetTable("TalentTreeTableMgr")
    for _, talentId in ipairs(talents) do
      local config = mgr.GetRow(talentId)
      if config.PreTalent and config.PreTalent[1] == nil then
        if talentStage == nil then
          talentStage = config.TalentStage
        else
          talentStage = math.max(talentStage, config.TalentStage)
        end
      end
    end
  end
  if talentStage then
    self:JumpTalentStage(talentStage)
  end
  self:refreshTalentPoints()
  self:loadTalentTree()
  Z.AudioMgr:Play("sys_player_enviroreso_in")
end

function Talent_skill_windowView:refreshWeaponInfo()
  if self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.ProfessionLv, true) then
    local weapon = self.weaponVM_.GetWeaponInfo(self.professionSystemTable_.ProfessionId)
    if weapon then
      self.uiBinder.lab_lv.text = Lang("WeaponProficiency") .. weapon.level
    else
      self.uiBinder.lab_lv.text = Lang("common_lock")
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.talentSkillVM_.CheckWeaponRed() and self.weaponVM_.GetCurWeapon() == self.viewData.professionId)
  else
    self.uiBinder.lab_lv.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  end
end

function Talent_skill_windowView:refreshTalentTreeScaleAndSlider()
  self.uiBinder.slider_zoom:SetValueWithoutNotify((self.zoomSize_ * 100 - self.minTalentTreeScale_) * 100 / (self.maxTalentTreeScale_ - self.minTalentTreeScale_))
  if self.lastZoomSize_ then
    local x, y = self.uiBinder.content:GetAnchorPosition(nil, nil)
    local width, height = self.uiBinder.scrollview.rect:GetSize(nil, nil)
    y = self.zoomSize_ * (height / 2 + y) / self.lastZoomSize_ - height / 2
    self.uiBinder.content:SetScale(self.zoomSize_, self.zoomSize_)
    self.uiBinder.content:SetAnchorPosition(0, y)
  else
    self.uiBinder.content:SetScale(self.zoomSize_, self.zoomSize_)
  end
end

function Talent_skill_windowView:loadTalentTree(isFirst)
  self:unloadTalentSkillTree()
  local stageReds = {}
  local talentTreeTableMgr = Z.TableMgr.GetTable("TalentTreeTableMgr")
  local nodes = self.talentSkillData_:GetCurUnActiveUnlockTalentTreeNodes()
  self.talentTreeRedDots_ = {}
  for _, node in ipairs(nodes) do
    self.talentTreeRedDots_[node] = true
    local tempConfig = talentTreeTableMgr.GetRow(node)
    if tempConfig then
      stageReds[tempConfig.TalentStage] = true
    end
  end
  local isCurWeapon = self.weaponVM_.GetCurWeapon() == self.professionSystemTable_.ProfessionId
  for i = 0, TalentSkillDefine.TalentTreeMaxStage - 1 do
    self.uiBinder.Ref:SetVisible(self.uiBinder["img_reddot_" .. i + 1], stageReds[i] and isCurWeapon)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local activeTalentTreeNodes = self.talentSkillVM_.GetWeaponActiveTalentTreeNode(self.professionSystemTable_.ProfessionId)
    local tempActiveTalentTreeNodes = {}
    if activeTalentTreeNodes and activeTalentTreeNodes.talentNodeIds then
      for _, nodes in ipairs(activeTalentTreeNodes.talentNodeIds) do
        tempActiveTalentTreeNodes[nodes] = nodes
      end
    end
    local talentTableMgr = Z.TableMgr.GetTable("TalentTableMgr")
    local height = 0
    local width = 0
    local activeTreeCount = 0
    self.talentTreeActiveStageConfig_ = {}
    self.talentTreeUnlockTipsLang_ = {}
    self.curPointActiveTalentTreeNodes_ = {}
    self.curPointUnlockTalentTreeNodes_ = {}
    self.lineEffects_ = {}
    if isFirst then
      self.lastActiveTalentTreeNodes_ = tempActiveTalentTreeNodes
      self.lastUnLockTalentTreeNodes_ = {}
      for _, nodes in pairs(tempActiveTalentTreeNodes) do
        local talentTreeConfig = talentTreeTableMgr.GetRow(nodes)
        self.lastUnLockTalentTreeNodes_[nodes] = nodes
        if talentTreeConfig and talentTreeConfig.NextTalent then
          for _, node in ipairs(talentTreeConfig.NextTalent) do
            self.lastUnLockTalentTreeNodes_[node] = node
          end
        end
      end
    else
      local tempCurAllUnlockTreeNodes = {}
      for _, nodes in pairs(tempActiveTalentTreeNodes) do
        tempCurAllUnlockTreeNodes[nodes] = nodes
        if self.lastActiveTalentTreeNodes_[nodes] == nil then
          self.curPointActiveTalentTreeNodes_[nodes] = {node = nodes, effect = nil}
        end
        local talentTreeConfig = talentTreeTableMgr.GetRow(nodes)
        if talentTreeConfig and talentTreeConfig.NextTalent then
          for _, node in ipairs(talentTreeConfig.NextTalent) do
            tempCurAllUnlockTreeNodes[node] = node
          end
        end
      end
      for _, nodes in pairs(self.curPointActiveTalentTreeNodes_) do
        local talentTreeConfig = talentTreeTableMgr.GetRow(nodes.node)
        if talentTreeConfig and talentTreeConfig.NextTalent then
          for _, node in ipairs(talentTreeConfig.NextTalent) do
            if self.lastUnLockTalentTreeNodes_[node] == nil then
              self.curPointUnlockTalentTreeNodes_[node] = node
            end
            tempCurAllUnlockTreeNodes[node] = node
          end
        end
      end
      self.lastActiveTalentTreeNodes_ = tempActiveTalentTreeNodes
      self.lastUnLockTalentTreeNodes_ = tempCurAllUnlockTreeNodes
    end
    for i = 1, TalentSkillDefine.TalentTreeMaxStage do
      self.uiBinder["btn_location" .. i].IsDisabled = true
      self.talentTreeIsUnlockAndPos_[i] = {
        unlock = false,
        pos = 0,
        tipsId = 1042021
      }
      if isFirst then
        self.talentTreeIsInPreview_[i] = -1
      end
      self.talentTreeUnlockNodeCounts_[i] = 0
    end
    local allStageConfigs = self.talentSkillData_:GetTalentTreeByWeapon(self.professionSystemTable_.ProfessionId)
    if allStageConfigs then
      for i = 0, TalentSkillDefine.TalentTreeMaxStage - 1 do
        local needPoint = 0
        if 0 < i then
          needPoint = allStageConfigs[i - 1][0].NeedPoint
        end
        local timeCondition = true
        local tipsParam = ""
        if next(allStageConfigs[i][0].OpenCondition) then
          local condition = allStageConfigs[i][0].OpenCondition[1]
          local tempTimeCondition, _, _, _, tempTipsParam = Z.ConditionHelper.GetSingleConditionDesc(condition[1], condition[2])
          timeCondition = tempTimeCondition
          tipsParam = tempTipsParam
        end
        local unlockBDType = -1
        local count = 0
        for _, config in pairs(allStageConfigs[i]) do
          count = count + 1
          if tempActiveTalentTreeNodes[config.RootId] ~= nil then
            unlockBDType = config.BdType
          end
        end
        if unlockBDType ~= -1 then
          self.talentTreeActiveStageConfig_[i] = allStageConfigs[i][unlockBDType]
        end
        if count == 1 then
          unlockBDType = 0
          self.talentTreeActiveStageConfig_[i] = allStageConfigs[i][unlockBDType]
        end
        local isUnlockTree = (i == 0 or needPoint <= self.talentTreeUnlockNodeCounts_[i]) and timeCondition
        if isUnlockTree then
          activeTreeCount = activeTreeCount + 1
        end
        local unitTalentNextStageName = "talent_nextstation" .. i
        local unitTalentNextStageUnit = self:AsyncLoadUiUnit(nextStationPrefabPath, unitTalentNextStageName, self.uiBinder.group_skill)
        if unitTalentNextStageUnit then
          self.talentTreeIsUnlockAndPos_[i + 1].pos = GroupMainSkillHeight + height
          unitTalentNextStageUnit.img_grade:SetImage(TalentSkillDefine.TalentTreeStageIconPath[i + 1])
          if isUnlockTree then
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.group_class, true)
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.group_lock, false)
          else
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.group_class, false)
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.group_lock, true)
            if timeCondition then
              unitTalentNextStageUnit.lab_nextstation_condition.text = Lang("TalentNextStationCondition", {
                val1 = allStageConfigs[i - 1][0].Name[1],
                val2 = needPoint,
                val3 = allStageConfigs[i][0].Name[1]
              })
              self.talentTreeUnlockTipsLang_[i] = {
                lang = Lang("TalentNextStationConditionSubTip", {
                  val1 = allStageConfigs[i - 1][0].Name[1],
                  val2 = needPoint,
                  val3 = allStageConfigs[i][0].Name[1]
                }),
                isTimeConditionUnlock = true
              }
            else
              unitTalentNextStageUnit.lab_nextstation_condition.text = Lang("TalentNextStationOpenServiceCondition", {
                val1 = allStageConfigs[i][0].Name[1],
                val2 = tipsParam.val
              })
              self.talentTreeUnlockTipsLang_[i] = {
                lang = Lang("TalentNextStationOpenServiceConditionSubTip", {
                  val1 = allStageConfigs[i][0].Name[1],
                  val2 = tipsParam.val
                }),
                isTimeConditionUnlock = false
              }
            end
          end
          if count == 1 or not self.isInPreview_ and unlockBDType ~= -1 or self.isInPreview_ and self.talentTreeIsInPreview_[i + 1] ~= -1 then
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.node_basics_item, false)
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.btn_reset, count ~= 1)
          else
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.node_basics_item, true)
            unitTalentNextStageUnit.Ref:SetVisible(unitTalentNextStageUnit.btn_reset, false)
            local tempStageSortConfigs = {}
            for _, config in pairs(allStageConfigs[i]) do
              table.insert(tempStageSortConfigs, config)
            end
            table.sort(tempStageSortConfigs, function(a, b)
              return a.BdType < b.BdType
            end)
            for _, config in ipairs(tempStageSortConfigs) do
              local unitTalentItemPath = unitTalentNextStageUnit.talent_next_station:GetString("talent_item")
              local unitTalentItemName = config.RootId
              local unitTalentItem = self:AsyncLoadUiUnit(unitTalentItemPath, unitTalentItemName, unitTalentNextStageUnit.node_basics_item)
              if unitTalentItem then
                local talentTreeConfig = talentTreeTableMgr.GetRow(config.RootId)
                if talentTreeConfig then
                  self:refreshSpecialTalentTreeNode(unitTalentItem, config.RootId, self.talentTreeUnlockTipsLang_[i] ~= nil, tempActiveTalentTreeNodes[config.RootId] ~= nil, talentTableMgr.GetRow(talentTreeConfig.TalentId))
                end
                table.insert(self.nextStageSkills_, unitTalentItemName)
              end
            end
          end
          local tempWidth = unitTalentNextStageUnit.Trans.sizeDelta.x
          local tempHeight = 0
          if isUnlockTree then
            unitTalentNextStageUnit.Trans:SetAnchorPosition(0, -height)
            if count == 1 then
              unitTalentNextStageUnit.Trans:SetHeight(250)
            elseif count == 1 or not self.isInPreview_ and unlockBDType ~= -1 or self.isInPreview_ and self.talentTreeIsInPreview_[i + 1] ~= -1 then
              unitTalentNextStageUnit.Trans:SetHeight(360)
            else
              unitTalentNextStageUnit.Trans:SetHeight(400)
            end
            tempHeight = unitTalentNextStageUnit.Trans.sizeDelta.y
          else
            unitTalentNextStageUnit.Trans:SetAnchorPosition(0, -height + 40)
            if count == 1 then
              unitTalentNextStageUnit.Trans:SetHeight(320)
            elseif count == 1 or not self.isInPreview_ and unlockBDType ~= -1 or self.isInPreview_ and self.talentTreeIsInPreview_[i + 1] ~= -1 then
              unitTalentNextStageUnit.Trans:SetHeight(430)
            else
              unitTalentNextStageUnit.Trans:SetHeight(470)
            end
            tempHeight = unitTalentNextStageUnit.Trans.sizeDelta.y - 40
          end
          height = height + tempHeight
          width = math.max(width, tempWidth)
          unitTalentNextStageUnit.btn_reset:RemoveAllListeners()
          unitTalentNextStageUnit.btn_reset:AddListener(function()
            self:resetPreviewTalentTree(i)
            self:hideRightSubView()
          end)
          table.insert(self.loadTalentTreeNames_, unitTalentNextStageName)
        end
        if count == 1 or not self.isInPreview_ and unlockBDType ~= -1 or self.isInPreview_ and self.talentTreeIsInPreview_[i + 1] ~= -1 then
          local tempBDType = unlockBDType
          if self.talentTreeIsInPreview_[i + 1] ~= -1 then
            tempBDType = self.talentTreeIsInPreview_[i + 1]
          end
          local treePath = string.format(TalentSkillDefine.TalentTreePrefabPath, self.professionSystemTable_.ProfessionId, i, tempBDType)
          local treeName = self.professionSystemTable_.ProfessionId .. i .. tempBDType
          local treeUnit = self:AsyncLoadUiUnit(treePath, treeName, self.uiBinder.group_skill)
          if treeUnit then
            treeUnit.Trans:SetAnchorPosition(0, -height)
            local tempStageConfig = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(allStageConfigs[i][tempBDType].Id)
            local rootTalentId = tempStageConfig.RootId
            self.lastTalentActiveCount_ = 0
            self.refreshUnitTalentTreeId_ = {}
            self:recursionRefreshTreeNote(treeUnit, rootTalentId, tempActiveTalentTreeNodes, talentTreeTableMgr, talentTableMgr)
            local name = tempStageConfig.Name[1]
            if tempStageConfig.Name[2] then
              name = tempStageConfig.Name[2]
            end
            unitTalentNextStageUnit.lab_cur_condition.text = string.format("%s : %s/%s", name, self.lastTalentActiveCount_, allStageConfigs[i][0].NeedPoint)
            self.talentTreeUnlockNodeCounts_[i + 1] = self.lastTalentActiveCount_
            local tempWidth = treeUnit.Trans.sizeDelta.x
            local tempHeight = treeUnit.Trans.sizeDelta.y
            height = height + tempHeight
            width = math.max(width, tempWidth)
            table.insert(self.loadTalentTreeNames_, treeName)
          end
        else
          local tempStageConfig = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(allStageConfigs[i][0].Id)
          unitTalentNextStageUnit.lab_cur_condition.text = string.format("%s : %s/%s", tempStageConfig.Name[1], 0, allStageConfigs[i][0].NeedPoint)
        end
      end
    end
    self.uiBinder.group_skill:SetWidth(width)
    self.uiBinder.group_skill:SetHeight(height)
    self.uiBinder.content:SetWidth(width)
    self.uiBinder.content:SetHeight(GroupMainSkillHeight + height)
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    self.uiBinder.content:SetAnchorPosition(0, self.treeY_)
    if isFirst then
      self.activeTreeCount = activeTreeCount
    else
      if activeTreeCount > self.activeTreeCount then
        Z.TipsVM.ShowTipsLang(1042017, {
          val = allStageConfigs[activeTreeCount - 1][0].Name[1]
        })
      end
      self.activeTreeCount = activeTreeCount
    end
  end)()
end

function Talent_skill_windowView:unloadTalentSkillTree()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.TalentTree)
  if self.selectTalentUnit_ and self.selectTalentUnit_.unit ~= nil then
    self.selectTalentUnit_.unit.node_effect_select:SetEffectGoVisible(false)
    self.selectTalentUnit_.unit.node_effect_select:ReleseEffGo()
    self.selectTalentUnit_.unit = nil
  end
  for _, effect in pairs(self.curPointActiveTalentTreeNodes_) do
    if effect.effect then
      effect.effect:ReleseEffGo()
    end
  end
  for _, effect in pairs(self.lineEffects_) do
    if effect then
      effect:ReleseEffGo()
    end
  end
  for _, name in ipairs(self.nextStageSkills_) do
    self:RemoveUiUnit(name)
  end
  for _, name in ipairs(self.loadTalentTreeNames_) do
    self:RemoveUiUnit(name)
  end
  self.loadTalentTreeNames_ = {}
  self.nextStageSkills_ = {}
end

function Talent_skill_windowView:recursionRefreshTreeNote(treeUIBinder, talentId, activeTalentTreeNodes, talentTreeMgr, talentMgr)
  if self.refreshUnitTalentTreeId_[talentId] then
    return
  end
  self.refreshUnitTalentTreeId_[talentId] = talentId
  local unit = treeUIBinder[tostring(talentId)]
  local talentTreeCofig = talentTreeMgr.GetRow(talentId)
  if unit and talentTreeCofig then
    local talentConfig = talentMgr.GetRow(talentTreeCofig.TalentId)
    if talentConfig == nil then
      return
    end
    local curUnitIsActive = activeTalentTreeNodes[talentId] ~= nil
    if curUnitIsActive then
      self.lastTalentActiveCount_ = self.lastTalentActiveCount_ + 1
    end
    local isLock = true
    if #talentTreeCofig.PreTalent > 0 then
      for _, pretalent in ipairs(talentTreeCofig.PreTalent) do
        if activeTalentTreeNodes[pretalent] then
          isLock = false
        end
      end
    else
      isLock = self.talentTreeUnlockTipsLang_[talentTreeCofig.TalentStage] ~= nil
    end
    self:refreshTalentTreeUnit(unit, talentId, isLock, curUnitIsActive, TalentSkillDefine.TalentAttrInfoSubViewType.Talent, talentConfig)
    if 0 < #talentTreeCofig.NextTalent then
      for _, nextNodeId in ipairs(talentTreeCofig.NextTalent) do
        local lineName1 = talentId .. "_" .. nextNodeId
        local lineName2 = nextNodeId .. "_" .. talentId
        local lineUnit = treeUIBinder[lineName1]
        if lineUnit == nil then
          lineUnit = treeUIBinder[lineName2]
        end
        if activeTalentTreeNodes[nextNodeId] then
          if lineUnit then
            lineUnit.talent_item_line_tpl.isOn = curUnitIsActive
          end
        elseif lineUnit then
          lineUnit.talent_item_line_tpl.isOn = false
        end
        self:recursionRefreshTreeNote(treeUIBinder, nextNodeId, activeTalentTreeNodes, talentTreeMgr, talentMgr)
      end
    end
  end
end

function Talent_skill_windowView:refreshTalentTreeUnit(unit, skillId, isLock, isActive, type, talentConfig)
  local isSelect = false
  if self.selectTalentUnit_ and self.selectTalentUnit_.nodeId == skillId then
    isSelect = true
    self.selectTalentUnit_.unit = unit
  end
  if isLock or not isActive then
    unit.node.alpha = 0.4
  else
    unit.node.alpha = 1
  end
  if talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Attr or talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Buff then
    if isLock then
      unit.Ref:SetVisible(unit.img_lock, true)
      unit.Ref:SetVisible(unit.img_mask, true)
    else
      unit.Ref:SetVisible(unit.img_lock, false)
      unit.Ref:SetVisible(unit.img_mask, not isActive)
    end
  elseif talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.BigAttr or talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.BigBuff then
    if isLock then
      unit.Ref:SetVisible(unit.img_mask, true)
      unit.Ref:SetVisible(unit.img_lock, true)
    else
      unit.Ref:SetVisible(unit.img_lock, false)
      unit.Ref:SetVisible(unit.img_mask, not isActive)
    end
  elseif talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Special then
    if isLock then
      unit.Ref:SetVisible(unit.img_lock, true)
      unit.Ref:SetVisible(unit.img_mask, true)
    else
      unit.Ref:SetVisible(unit.img_lock, false)
      unit.Ref:SetVisible(unit.img_mask, not isActive)
    end
  end
  if isSelect then
    if talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Special then
      unit.node_effect_select:CreatEFFGO(TalentSkillDefine.TalentSkillTreeNodeSelectEffect[2][self.professionSystemTable_.Talent], Vector3.zero)
    else
      unit.node_effect_select:CreatEFFGO(TalentSkillDefine.TalentSkillTreeNodeSelectEffect[1][self.professionSystemTable_.Talent], Vector3.zero)
    end
    unit.node_effect_select:SetEffectGoVisible(true)
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(unit.node_effect_select)
  end
  self:AddAsyncClick(unit.btn, function()
    if not self.canUITouchByAnimEnd_ then
      return
    end
    self:hideRightSubView()
    local viewData = {
      type = type,
      id = skillId,
      professionId = self.professionSystemTable_.ProfessionId,
      closeFunc = function()
        self:hideRightSubView()
      end
    }
    self:showRightSubView(viewData)
    self:hideSelectUnit()
    self.selectTalentUnit_ = {
      nodeId = skillId,
      unit = unit,
      type = type
    }
    if talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Special then
      self.selectTalentUnit_.unit.node_effect_select:CreatEFFGO(TalentSkillDefine.TalentSkillTreeNodeSelectEffect[2][self.professionSystemTable_.Talent], Vector3.zero)
      self.selectTalentUnit_.unit.node_effect_select:SetEffectGoVisible(true)
    else
      self.selectTalentUnit_.unit.node_effect_select:CreatEFFGO(TalentSkillDefine.TalentSkillTreeNodeSelectEffect[1][self.professionSystemTable_.Talent], Vector3.zero)
      self.selectTalentUnit_.unit.node_effect_select:SetEffectGoVisible(true)
    end
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.selectTalentUnit_.unit.node_effect_select)
  end)
  if self.curPointActiveTalentTreeNodes_[skillId] then
    local weaponTalent = self.professionSystemTable_.Talent
    unit.anim:Init()
    unit.anim:Play(Z.DOTweenAnimType.Tween_0)
    unit.anim:Restart(Z.DOTweenAnimType.Tween_0)
    if talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Attr or talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Buff then
      unit.node_effect:CreatEFFGO(TalentSkillDefine.TalentSkillUnitActiveEffect[2][weaponTalent], Vector3.zero)
    else
      unit.node_effect:CreatEFFGO(TalentSkillDefine.TalentSkillUnitActiveEffect[1][weaponTalent], Vector3.zero)
    end
    unit.node_effect:SetEffectGoVisible(true)
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(unit.node_effect)
    self.curPointActiveTalentTreeNodes_[skillId].effect = unit.node_effect
  end
  if self.curPointUnlockTalentTreeNodes_[skillId] then
    unit.anim:Init()
    unit.anim:Play(Z.DOTweenAnimType.Open)
    unit.anim:Restart(Z.DOTweenAnimType.Open)
  end
  if self.talentTreeRedDots_[skillId] then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.TalentTree, self, unit.Trans)
  end
end

function Talent_skill_windowView:refreshSpecialTalentTreeNode(unit, skillId, isLock, isActive, talentConfig)
  local isSelect = false
  if self.selectTalentUnit_ and self.selectTalentUnit_.nodeId == skillId then
    isSelect = true
    self.selectTalentUnit_.unit = unit
  end
  unit.img_icon:SetImage(talentConfig.TalentIcon)
  if isLock or not isActive then
    unit.node.alpha = 0.4
  else
    unit.node.alpha = 1
  end
  unit.Trans:SetWidthAndHeight(171.0, 171.0)
  unit.img_mask:SetImage(TalentSkillDefine.TalentSkillMaskIconPath[2])
  if isLock then
    unit.Ref:SetVisible(unit.img_lock, true)
    unit.Ref:SetVisible(unit.img_mask, true)
    unit.img_bg:SetImage(TalentSkillDefine.TalentWindowTreeBg.Special[self.professionSystemTable_.Talent].Unactive)
  else
    unit.Ref:SetVisible(unit.img_lock, false)
    unit.Ref:SetVisible(unit.img_mask, not isActive)
    unit.img_bg:SetImage(TalentSkillDefine.TalentWindowTreeBg.Special[self.professionSystemTable_.Talent].Active)
  end
  if isSelect then
    unit.node_effect_select:CreatEFFGO(TalentSkillDefine.TalentSkillTreeNodeSelectEffect[2][self.professionSystemTable_.Talent], Vector3.zero)
    unit.node_effect_select:SetEffectGoVisible(true)
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(unit.node_effect_select)
  end
  self:AddAsyncClick(unit.btn, function()
    if not self.canUITouchByAnimEnd_ then
      return
    end
    self:hideRightSubView()
    local viewData = {
      type = TalentSkillDefine.TalentTreeUnitType.Special,
      id = skillId,
      professionId = self.professionSystemTable_.ProfessionId,
      closeFunc = function()
        self:hideRightSubView()
      end
    }
    self:showRightSubView(viewData)
    self:hideSelectUnit()
    if isActive then
      self.selectTalentUnit_ = {
        nodeId = skillId,
        type = TalentSkillDefine.TalentTreeUnitType.Special
      }
      self:previewTalentTree(skillId)
    else
      self.selectTalentUnit_ = {
        nodeId = skillId,
        unit = unit,
        type = TalentSkillDefine.TalentTreeUnitType.Special
      }
      self.selectTalentUnit_.unit.node_effect_select:CreatEFFGO(TalentSkillDefine.TalentSkillTreeNodeSelectEffect[2][self.professionSystemTable_.Talent], Vector3.zero)
      self.selectTalentUnit_.unit.node_effect_select:SetEffectGoVisible(true)
      self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.selectTalentUnit_.unit.node_effect_select)
    end
  end)
  if self.talentTreeRedDots_[skillId] then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.TalentTree, self, unit.Trans)
  end
end

function Talent_skill_windowView:resetPreviewTalentTree(stage)
  self.isInPreview_ = true
  self.talentTreeIsInPreview_[stage + 1] = -1
  local posX, posY = self.uiBinder.content:GetAnchorPosition(nil, nil)
  self.treeY_ = posY
  self:loadTalentTree()
end

function Talent_skill_windowView:previewTalentTree(nodeId)
  local talentTreeTableConfig = Z.TableMgr.GetTable("TalentTreeTableMgr").GetRow(nodeId)
  if self.talentSkillVM_.CheckTalentIsActive(self.professionSystemTable_.Id, nodeId) then
    self.isInPreview_ = false
    self.talentTreeIsInPreview_[talentTreeTableConfig.TalentStage + 1] = -1
  else
    self.isInPreview_ = true
    self.talentTreeIsInPreview_[talentTreeTableConfig.TalentStage + 1] = talentTreeTableConfig.BdType
  end
  self:JumpTalentStage(talentTreeTableConfig.TalentStage)
  self:loadTalentTree()
end

function Talent_skill_windowView:clearPreviewStage()
  self.isInPreview_ = false
  for k, _ in pairs(self.talentTreeIsInPreview_) do
    self.talentTreeIsInPreview_[k] = -1
  end
end

function Talent_skill_windowView:showRightSubView(viewData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_head_forging, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_recommend, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_slider, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_reset, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reset, false)
  self.rightGroupSubView_:Active(viewData, self.uiBinder.group_right)
end

function Talent_skill_windowView:hideRightSubView()
  local curWeaponIsUnlock = self.weaponVM_.CheckWeaponUnlock(self.professionSystemTable_.ProfessionId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_head_forging, not curWeaponIsUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_recommend, curWeaponIsUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reset, curWeaponIsUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_slider, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_reset, true)
  self.rightGroupSubView_:DeActive()
end

function Talent_skill_windowView:onClickReset()
  if self.weaponVM_.GetCurWeapon() ~= self.viewData.professionId then
    Z.TipsVM.ShowTipsLang(1042020)
    return
  end
  if self.talentSkillVM_.GetSurpluseTalentPointCount(self.professionSystemTable_.ProfessionId) == self.talentSkillVM_.GetAllTalentPointCount() then
    Z.TipsVM.ShowTipsLang(1042008)
    return
  end
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = Lang("TalentResetTipFree"),
    onConfirm = function()
      self:hideSelectUnit()
      if self.talentSkillVM_.ResetTalentTree(self.professionSystemTable_.ProfessionId, self.cancelSource:CreateToken()) then
        Z.TipsVM.ShowTipsLang(1042006)
        self:talentChangeRefresh()
      end
    end
  }
  Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
end

function Talent_skill_windowView:openSourceTip()
  self:closeSourceTip()
  local configId = self.talentSkillData_:GetTalentPointConfigId()
  self.sourceTipId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.rect_source, configId)
end

function Talent_skill_windowView:openNotEnoughItemTips(itemId, rect)
  self:closeSourceTip()
  self.sourceTipId_ = Z.TipsVM.OpenSourceTips(itemId, rect)
end

function Talent_skill_windowView:closeSourceTip()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
end

function Talent_skill_windowView:hideSelectUnit()
  if self.selectTalentUnit_ == nil then
    return
  end
  if self.selectTalentUnit_.type == TalentSkillDefine.TalentAttrInfoSubViewType.Weapon then
    self.uiBinder.rimg_icon_weapon:SetImage(self.professionSystemTable_.MainTalentIcon)
    self.uiBinder.rimg_adorn:SetImage(TalentSkillDefine.TalentSkillWindowAdornIconPath[1])
  elseif (self.selectTalentUnit_.type == TalentSkillDefine.TalentAttrInfoSubViewType.Talent or self.selectTalentUnit_.type == TalentSkillDefine.TalentAttrInfoSubViewType.TalentBD) and self.selectTalentUnit_.unit ~= nil and self.selectTalentUnit_.unit.node_effect_select ~= nil then
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.selectTalentUnit_.unit.node_effect_select)
    self.selectTalentUnit_.unit.node_effect_select:SetEffectGoVisible(false)
    self.selectTalentUnit_.unit.node_effect_select:ReleseEffGo()
  end
  self.selectTalentUnit_ = nil
end

function Talent_skill_windowView:recommedTalent()
  if self.weaponVM_.GetCurWeapon() ~= self.viewData.professionId then
    Z.TipsVM.ShowTipsLang(1042020)
    return
  end
  local activeTalentTreeNodes = self.talentSkillVM_.GetWeaponActiveTalentTreeNode(self.professionSystemTable_.ProfessionId)
  local tempActiveTalentTreeNodes = {}
  if activeTalentTreeNodes and activeTalentTreeNodes.talentNodeIds then
    for _, nodes in ipairs(activeTalentTreeNodes.talentNodeIds) do
      tempActiveTalentTreeNodes[nodes] = nodes
    end
  end
  local recommandTalents = {}
  local tempIndex = 0
  local recommandStage = 0
  for i = 0, TalentSkillDefine.TalentTreeMaxStage - 1 do
    if self.talentTreeActiveStageConfig_[i] then
      local recommandTalent = self.talentTreeActiveStageConfig_[i].RecommendTalent
      for _, talent in ipairs(recommandTalent) do
        if tempActiveTalentTreeNodes[talent] == nil then
          tempIndex = tempIndex + 1
          recommandTalents[tempIndex] = talent
        end
      end
      if tempIndex ~= 0 then
        recommandStage = i
        break
      end
    else
      Z.TipsVM.ShowTipsLang(1042019)
      return
    end
  end
  if tempIndex == 0 then
    Z.TipsVM.ShowTipsLang(1042025)
  end
  local allStageConfigs = self.talentSkillData_:GetTalentTreeByWeapon(self.professionSystemTable_.ProfessionId)
  if allStageConfigs == nil then
    return
  end
  local timeCondition = true
  local tipsStr = ""
  local progress = ""
  if next(allStageConfigs[recommandStage][0].OpenCondition) then
    local condition = allStageConfigs[recommandStage][0].OpenCondition[1]
    timeCondition, tipsStr, progress = Z.ConditionHelper.GetSingleConditionDesc(condition[1], condition[2])
  end
  if not timeCondition then
    Z.TipsVM.ShowTipsLang(1042026, {val = progress})
    return
  end
  if self.talentTreeIsInPreview_[recommandStage + 1] ~= -1 then
    Z.TipsVM.ShowTipsLang(1042027)
    return
  end
  local talentTreeTableMgr = Z.TableMgr.GetTable("TalentTreeTableMgr")
  local talentTableMgr = Z.TableMgr.GetTable("TalentTableMgr")
  local surpluseTalentPoints = self.talentSkillVM_.GetSurpluseTalentPointCount(self.professionSystemTable_.ProfessionId)
  local resTalent = {}
  local needItems = {}
  local talentPoints = 0
  local recommandTalentCount = 0
  local noEnoughItemId = 0
  for _, talent in ipairs(recommandTalents) do
    local talentTreeTableConfig = talentTreeTableMgr.GetRow(talent)
    if talentTreeTableConfig then
      local talentTableConfig = talentTableMgr.GetRow(talentTreeTableConfig.TalentId)
      if talentTableConfig then
        local pointsEnough = surpluseTalentPoints >= talentPoints + talentTableConfig.TalentPointsConsume
        local itemEnough = true
        local i = 1
        if talentTableConfig.UnlockConsume and 0 < #talentTableConfig.UnlockConsume then
          for _, unlockConsume in ipairs(talentTableConfig.UnlockConsume) do
            local itemCount = 0
            if needItems[unlockConsume[1]] then
              itemCount = needItems[unlockConsume[1]]
            end
            itemEnough = self.itemVM_.GetItemTotalCount(unlockConsume[1]) >= unlockConsume[2] + itemCount and itemEnough
            if itemEnough then
              if needItems[unlockConsume[1]] == nil then
                needItems[unlockConsume[1]] = 0
              end
              needItems[unlockConsume[1]] = needItems[unlockConsume[1]] + unlockConsume[2]
            else
              noEnoughItemId = unlockConsume[1]
            end
          end
        end
        if pointsEnough and itemEnough then
          talentPoints = talentPoints + talentTableConfig.TalentPointsConsume
          recommandTalentCount = recommandTalentCount + 1
          resTalent[recommandTalentCount] = talent
        else
          noEnoughItemId = pointsEnough and noEnoughItemId or self.talentSkillData_:GetTalentPointConfigId()
          break
        end
      end
    end
  end
  if 0 < recommandTalentCount then
    local itemList = {}
    local tempIndex = 0
    for id, count in pairs(needItems) do
      tempIndex = tempIndex + 1
      itemList[tempIndex] = {
        ItemId = id,
        ItemNum = count,
        LabType = E.ItemLabType.Expend
      }
    end
    tempIndex = tempIndex + 1
    itemList[tempIndex] = {
      ItemId = self.talentSkillData_:GetTalentPointConfigId(),
      ItemNum = talentPoints,
      LabType = E.ItemLabType.Expend,
      OverrideItemNum = self.talentSkillVM_.GetSurpluseTalentPointCount(self.professionSystemTable_.ProfessionId)
    }
    local dialogViewData = {
      dlgType = E.DlgType.YesNo,
      labDesc = Lang("TalentRecommedCertain"),
      onConfirm = function()
        self.talentSkillVM_.UnlockTalentTreeNode(self.professionSystemTable_.ProfessionId, resTalent, self.cancelSource:CreateToken(), true)
      end,
      itemList = itemList
    }
    Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
  else
    if 0 < noEnoughItemId then
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(noEnoughItemId)
      if itemConfig then
        Z.TipsVM.ShowTipsLang(1042015, {
          val = itemConfig.Name
        })
        self:openNotEnoughItemTips(noEnoughItemId, self.uiBinder.rect_recommend)
      end
    else
    end
  end
end

function Talent_skill_windowView:onQuestAccept(questId)
  if self.questId_ ~= questId then
    return
  end
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  questTrackVM.ReplaceAndTrackingQuest(questId)
  local questDetailVm_ = Z.VMMgr.GetVM("questdetail")
  questDetailVm_.OpenDetailView()
end

function Talent_skill_windowView:JumpTalentStage(stage)
  self.treeY_ = self.talentTreeIsUnlockAndPos_[stage + 1].pos * self.zoomSize_
end

function Talent_skill_windowView:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Currency) or itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Item) or itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.SpecialItem) then
    self:refreshWeaponInfo()
  end
end

return Talent_skill_windowView
