local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_rolechoose_windowView = class("Face_rolechoose_windowView", super)
local MAX_COLUMN_NUM = 3
local NORMAL_FRAME_PATH = "ui/textures/large_ui/rolechoose/rolechoose_frame_off"
local SELECT_FRAME_PATH = "ui/textures/large_ui/rolechoose/rolechoose_frame_on"
local NORMAL_PROFESSION_FRAME = "ui/atlas/rolechoose/rolechoose_profession_white"
local SELECT_PROFESSION_FRAME = "ui/atlas/rolechoose/rolechoose_profession_black"
local TALENT_UP_FRAME_EMPTY_PATH = "ui/atlas/rolechoose/rolechoose_up_gray"
local TALENT_DOWN_FRAME_EMPTY_PATH = "ui/atlas/rolechoose/rolechoose_down_gray"
local TALENT_UP_FRAME_PATH = {
  [1] = "ui/atlas/rolechoose/rolechoose_up_red",
  [2] = "ui/atlas/rolechoose/rolechoose_up_green",
  [3] = "ui/atlas/rolechoose/rolechoose_up_blue"
}
local TALENT_DOWN_FRAME_PATH = {
  [1] = "ui/atlas/rolechoose/rolechoose_down_red",
  [2] = "ui/atlas/rolechoose/rolechoose_down_green",
  [3] = "ui/atlas/rolechoose/rolechoose_down_blue"
}
local TALENT_DOWN_ANIM_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_face_001/ui_sfx_group_face_hit_red",
  [2] = "ui/uieffect/prefab/ui_sfx_face_001/ui_sfx_group_face_hit_green",
  [3] = "ui/uieffect/prefab/ui_sfx_face_001/ui_sfx_group_face_hit_blue"
}
local TIMELINE_FEMALE_DEFINE = {
  50000013,
  50000014,
  50000015
}
local TIMELINE_MALE_DEFINE = {
  50000016,
  50000017,
  50000018
}

function Face_rolechoose_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_rolechoose_window")
  self.loginVM_ = Z.VMMgr.GetVM("login")
  self.loginData_ = Z.DataMgr.Get("login_data")
  self.snapShotVM_ = Z.VMMgr.GetVM("snapshot")
  self.playerVM_ = Z.VMMgr.GetVM("player")
  self.playerData_ = Z.DataMgr.Get("player_data")
end

function Face_rolechoose_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:preLoadTimeline()
  self:initData()
  self:initComp()
end

function Face_rolechoose_windowView:playEnterAnim()
  self:SetUIVisible(self.uiBinder.anim, false)
  Z.CoroUtil.create_coro_xpcall(function()
    Z.Delay(0.2, self.cancelSource:CreateToken())
    self:SetUIVisible(self.uiBinder.anim, true)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  end)()
end

function Face_rolechoose_windowView:OnRefresh()
  self:refreshTotalColumnInfo()
  self:clearModel()
  self:switchRole(self.playerData_.CharDataIndex, true)
end

function Face_rolechoose_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unInitEffectGoLayer()
  self:clearModel()
  self:hideRoleEffect()
  Z.UITimelineDisplay:ClearTimeLine()
  if self.deleteTimer_ then
    self.deleteTimer_:Stop()
    self.deleteTimer_ = nil
  end
end

function Face_rolechoose_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Face_rolechoose_windowView:initData()
  self.curRotation_ = 180
  self.isLogining_ = false
end

function Face_rolechoose_windowView:initComp()
  self:initEffectGoLayer()
  self:AddClick(self.uiBinder.btn_close, function()
    self:OnInputBack()
  end)
  self:AddClick(self.uiBinder.btn_create_role, function()
    self.loginVM_:BeginCreateChar()
  end)
  self:AddClick(self.uiBinder.btn_delete, function()
    self:onRoleDeleteBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_cancel_delete, function()
    self:onRoleCancelDeleteBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_entergame, function()
    local socialData = self.playerData_.CharDataList[self.playerData_.CharDataIndex]
    if socialData == nil then
      return
    end
    self.isLogining_ = true
    self:refreshButtonState()
    self.loginVM_:BeginSelectChar(socialData.basicData.charID, function()
      self.isLogining_ = false
      self:refreshButtonState()
    end)
  end)
  self.uiBinder.img_lab:SetImage("ui/textures/rolechoose/rolechoose_lab_c_1")
  Z.UnrealSceneMgr:InitSceneCamera(true)
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", false)
end

function Face_rolechoose_windowView:initEffectGoLayer()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_profession)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_entergame)
  self.uiBinder.eff_entergame:Play()
end

function Face_rolechoose_windowView:unInitEffectGoLayer()
  for i = 1, math.max(Z.Global.MaxRoleNumber, MAX_COLUMN_NUM) do
    local eff = self.uiBinder["binder_role_" .. i].eff_click
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(eff)
    eff:ReleseEffGo()
  end
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_profession)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_entergame)
end

function Face_rolechoose_windowView:switchRole(index, isInit, isRefresh)
  if index == nil or index < 1 or index > Z.Global.MaxRoleNumber then
    index = 1
  end
  self:hideRoleEffect()
  local socialData = self.playerData_.CharDataList[index]
  if socialData then
    self.playerData_.CharDataIndex = index
    self:createRoleModel(socialData, isInit)
    self:refreshRoleInfo(socialData)
    self:playSwitchRoleEff(index, isInit)
  elseif isInit then
    self:playEnterAnim()
    Z.UIMgr:FadeOut()
  elseif isRefresh then
    self:refreshRoleInfo()
  else
    self.loginVM_:BeginCreateChar()
  end
  self:refreshButtonState()
  self:refreshColumnState()
end

function Face_rolechoose_windowView:createRoleModel(socialData, isInit)
  self:clearModel()
  self.showModel_ = Z.UnrealSceneMgr:GenModelByLuaSocialData(socialData, nil, function(model)
    model:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, false)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, -180, 0)))
  end, function(model)
    if isInit then
      self:playEnterAnim()
      Z.UIMgr:FadeOut()
    end
    self:showRoleEffect()
    self:playTimeline(model, socialData)
  end)
  Z.UnrealSceneMgr:SetModelCustomShadow(self.showModel_, true)
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(socialData.basicData.gender, socialData.basicData.bodySize)
  local pinchHeight = self.showModel_:GetLuaAttr(Z.ModelAttr.EModelPinchHeight).Value
  Z.UnrealSceneMgr:SetCameraLookAtEnable(true)
  Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusHead_" .. modelId, Vector3.New(0, pinchHeight / 13, 0))
end

function Face_rolechoose_windowView:clearModel()
  Z.UITimelineDisplay:Stop()
  if self.showModel_ then
    Z.UnrealSceneMgr:ClearModel(self.showModel_)
    self.showModel_ = nil
  end
end

function Face_rolechoose_windowView:showRoleEffect()
  local effectTrans = Z.UnrealSceneMgr:GetTransByName("select_role_effect")
  if effectTrans then
    effectTrans.gameObject:SetActive(true)
  end
end

function Face_rolechoose_windowView:hideRoleEffect()
  local effectTrans = Z.UnrealSceneMgr:GetTransByName("select_role_effect")
  if effectTrans then
    effectTrans.gameObject:SetActive(false)
  end
end

function Face_rolechoose_windowView:playTimeline(model, socialData)
  if model == nil or socialData == nil then
    return
  end
  Z.UITimelineDisplay:Stop()
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:BindModel(0, model)
  local timelineId = self:getRandomTimelineId(socialData)
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(timelineId, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
  Z.UITimelineDisplay:Play(timelineId)
end

function Face_rolechoose_windowView:getRandomTimelineId(socialData)
  local timelineConfig
  if socialData.basicData.gender == Z.PbEnum("EGender", "GenderMale") then
    timelineConfig = TIMELINE_MALE_DEFINE
  else
    timelineConfig = TIMELINE_FEMALE_DEFINE
  end
  local randomIndex = math.random(1, #timelineConfig)
  return timelineConfig[randomIndex]
end

function Face_rolechoose_windowView:preLoadTimeline()
  Z.UITimelineDisplay:ClearTimeLine()
  for i, timelineId in ipairs(TIMELINE_MALE_DEFINE) do
    Z.UITimelineDisplay:AsyncPreLoadTimeline(timelineId, self.cancelSource:CreateToken())
  end
  for i, timelineId in ipairs(TIMELINE_FEMALE_DEFINE) do
    Z.UITimelineDisplay:AsyncPreLoadTimeline(timelineId, self.cancelSource:CreateToken())
  end
end

function Face_rolechoose_windowView:onModelDrag(eventData)
  if not self.showModel_ then
    return
  end
  self.curRotation_ = self.curRotation_ - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self.showModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
end

function Face_rolechoose_windowView:refreshRoleInfo(socialData)
  local professionRow
  if socialData then
    professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", socialData.professionData.professionId)
    self.uiBinder.img_profession:SetImage(professionRow.Icon)
  end
  self:SetUIVisible(self.uiBinder.img_profession, socialData ~= nil)
  local emptyLab = Lang("EmptySelectLab")
  local isNamed = socialData and self.playerVM_:IsNamedByCharState(socialData.basicData.charState) or false
  if isNamed then
    self.uiBinder.lab_name.text = socialData.basicData.name or Lang("EmptyRoleName")
  else
    self.uiBinder.lab_name.text = socialData and Lang("EmptyRoleName") or Lang("CreateRole")
  end
  self.uiBinder.lab_id_num.text = socialData and socialData.basicData.showId or emptyLab
  self.uiBinder.lab_attr_lv.text = socialData and socialData.basicData.level or emptyLab
  if socialData and socialData.userAttrData then
    self.uiBinder.lab_attr_gs.text = socialData.userAttrData.fightPoint
  else
    self.uiBinder.lab_attr_gs.text = emptyLab
  end
  self.uiBinder.lab_attr_profession.text = socialData and professionRow.Name or emptyLab
  if socialData and socialData.personalZone then
    local titleId = socialData.personalZone.titleId
    if titleId ~= 0 then
      local titleConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
      if titleConfig then
        self.uiBinder.lab_attr_title.text = titleConfig.Name
      else
        self.uiBinder.lab_attr_title.text = emptyLab
      end
    else
      self.uiBinder.lab_attr_title.text = Lang("None")
    end
  else
    self.uiBinder.lab_attr_title.text = emptyLab
  end
end

function Face_rolechoose_windowView:refreshTotalColumnInfo()
  for i = 1, math.max(Z.Global.MaxRoleNumber, MAX_COLUMN_NUM) do
    local uiBinder = self.uiBinder["binder_role_" .. i]
    if uiBinder then
      local socialData = self.playerData_.CharDataList[i]
      if i <= Z.Global.MaxRoleNumber then
        self:SetUIVisible(uiBinder.Ref, true)
        self:refreshColumnInfo(uiBinder, socialData)
        self:AddClick(uiBinder.btn_item, function()
          local socialData = self.playerData_.CharDataList[i]
          if socialData == nil or self.playerData_.CharDataIndex ~= i then
            self:switchRole(i, false)
          end
        end)
      else
        self:SetUIVisible(uiBinder.Ref, false)
      end
    end
  end
end

function Face_rolechoose_windowView:refreshColumnState()
  for i = 1, math.max(Z.Global.MaxRoleNumber, MAX_COLUMN_NUM) do
    local uiBinder = self.uiBinder["binder_role_" .. i]
    if uiBinder then
      local socialData = self.playerData_.CharDataList[i]
      local isDeleted = false
      if socialData then
        isDeleted = self.playerData_.DeleteCharIdsLeftTime[socialData.charId] ~= nil and self.playerData_.DeleteCharIdsLeftTime[socialData.charId] ~= 0
      end
      local isSelected = i == self.playerData_.CharDataIndex and socialData ~= nil
      local x, y = uiBinder.Trans:GetAnchorPosition(nil, nil)
      y = isSelected and 55 or -5
      uiBinder.Trans:SetAnchorPosition(x, y)
      uiBinder.rimg_frame_on:SetImage(isSelected and SELECT_FRAME_PATH or NORMAL_FRAME_PATH)
      uiBinder.img_profession_frame:SetImage(isSelected and SELECT_PROFESSION_FRAME or NORMAL_PROFESSION_FRAME)
      uiBinder.Ref:SetVisible(uiBinder.node_delete, isDeleted)
      if isSelected then
        uiBinder.group_on_state_change:ChangeStateByKey("Selected")
      else
        uiBinder.group_on_state_change:ChangeStateByKey("Unselected")
      end
    end
  end
end

function Face_rolechoose_windowView:refreshColumnInfo(uiBinder, socialData)
  uiBinder.Ref:SetVisible(uiBinder.group_on, socialData ~= nil)
  uiBinder.Ref:SetVisible(uiBinder.group_off, socialData == nil)
  if socialData then
    if socialData.professionData then
      local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", socialData.professionData.professionId)
      if professionRow then
        uiBinder.img_profession:SetImage(professionRow.Icon)
        uiBinder.img_up:SetImage(TALENT_UP_FRAME_PATH[professionRow.Talent])
        uiBinder.img_down:SetImage(TALENT_DOWN_FRAME_PATH[professionRow.Talent])
        local eff = uiBinder.eff_click
        eff:CreatEFFGO(TALENT_DOWN_ANIM_PATH[professionRow.Talent], Vector3.zero, false)
        self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(eff)
      end
    end
    uiBinder.lab_lv_num.text = socialData.basicData.level
    self:refreshRoleFigure(uiBinder, socialData)
  else
    uiBinder.img_up:SetImage(TALENT_UP_FRAME_EMPTY_PATH)
    uiBinder.img_down:SetImage(TALENT_DOWN_FRAME_EMPTY_PATH)
  end
end

function Face_rolechoose_windowView:refreshRoleFigure(uiBinder, socialData)
  Z.CoroUtil.create_coro_xpcall(function()
    uiBinder.Ref:SetVisible(uiBinder.img_role, false)
    uiBinder.Ref:SetVisible(uiBinder.rimg_role, false)
    local textureData = {}
    if socialData.avatarInfo and socialData.avatarInfo.halfBody and socialData.avatarInfo.halfBody.url ~= "" then
      textureData.textureId = self.snapShotVM_.AsyncDownLoadPictureByUrl(socialData.avatarInfo.halfBody.url)
      textureData.auditing = socialData.avatarInfo.halfBody.verify.ReviewStartTime
    end
    if textureData.auditing and textureData.auditing == E.EPictureReviewType.EPictureReviewed then
      uiBinder.Ref:SetVisible(uiBinder.rimg_role, true)
      uiBinder.rimg_role:SetNativeTexture(textureData.textureId)
    else
      local modelId = Z.ModelManager:GetModelIdByGenderAndSize(socialData.basicData.gender, socialData.basicData.bodySize)
      local path = self.snapShotVM_.GetModelHalfPortrait(modelId)
      if path ~= nil then
        uiBinder.Ref:SetVisible(uiBinder.img_role, true)
        uiBinder.img_role:SetImage(path)
      else
        logError("[refreshRoleFigure] The path of GetModelHalfPortrait is nil.")
      end
    end
  end)()
end

function Face_rolechoose_windowView:refreshButtonState()
  local charDataList = self.playerData_.CharDataList
  local curSocialData
  if charDataList then
    curSocialData = charDataList[self.playerData_.CharDataIndex]
  end
  local isSelectedRole = curSocialData ~= nil
  local isDeleted = false
  if curSocialData then
    isDeleted = self.playerData_.DeleteCharIdsLeftTime[curSocialData.charId] ~= nil and self.playerData_.DeleteCharIdsLeftTime[curSocialData.charId] ~= 0
  end
  self:SetUIVisible(self.uiBinder.btn_create_role, not isSelectedRole)
  self:SetUIVisible(self.uiBinder.btn_delete, isSelectedRole and not isDeleted)
  self:SetUIVisible(self.uiBinder.btn_cancel_delete, isSelectedRole and isDeleted and not self.isLogining_)
  self:SetUIVisible(self.uiBinder.btn_entergame, isSelectedRole and not isDeleted and not self.isLogining_)
  self:SetUIVisible(self.uiBinder.node_mask, self.isLogining_)
  self:SetUIVisible(self.uiBinder.node_progress, self.isLogining_)
  self:SetUIVisible(self.uiBinder.lab_time, isDeleted)
  if isDeleted then
    if self.deleteTimer_ then
      self.deleteTimer_:Stop()
      self.deleteTimer_ = nil
    end
    local lastSyncLeftTime = self.playerData_.DeleteCharIdsLeftTime[curSocialData.charId]
    local lastSyncTimestamp = self.playerData_.GetDeleteCharTimestamp[curSocialData.charId]
    self.deleteTimer_ = self.timerMgr:StartTimer(function()
      local interval = os.time() - lastSyncTimestamp
      local leftTime = lastSyncLeftTime - interval
      if leftTime < 0 then
        leftTime = 0
        if self.deleteTimer_ then
          self.deleteTimer_:Stop()
          self.deleteTimer_ = nil
        end
      end
      local param = {
        time = Z.TimeFormatTools.FormatToDHMS(leftTime)
      }
      self.uiBinder.lab_time.text = Lang("LeftDeleteTime", param)
    end, 1, -1, false, nil, true)
  elseif self.deleteTimer_ then
    self.deleteTimer_:Stop()
    self.deleteTimer_ = nil
  end
end

function Face_rolechoose_windowView:deleteRoleHandler(charId)
  self.playerData_:SortCharDataList(charId)
  self:refreshTotalColumnInfo()
  self:refreshButtonState()
  self:refreshColumnState()
end

function Face_rolechoose_windowView:onRoleDeleteBtnClick()
  local socialData = self.playerData_.CharDataList[self.playerData_.CharDataIndex]
  if socialData == nil then
    logError("[DeleteChar] socialData is nil.")
    return
  end
  Z.UIMgr:OpenView("face_rolechoose_popup", {
    charId = socialData.charId,
    successCallback = function(charId, deleteLeftTime)
      self:deleteRoleHandler(charId)
    end
  })
end

function Face_rolechoose_windowView:onRoleCancelDeleteBtnClick()
  local desc = Lang("RoleCancelDeleteDesc")
  Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
    local socialData = self.playerData_.CharDataList[self.playerData_.CharDataIndex]
    if socialData == nil then
      logError("[CancelDeleteChar] socialData is nil.")
      return
    end
    local reply = self.loginVM_:AsyncCancelDeleteChar(socialData.charId)
    if reply.errCode == 0 then
      self:deleteRoleHandler(socialData.charId)
    elseif reply.errCode == Z.PbEnum("EErrorCode", "ErrCancelDeleteCharIsDelete") then
      self.playerData_:DeleteChar(socialData.charId)
      self.playerData_:SortCharDataList()
      self:refreshTotalColumnInfo()
      self:refreshButtonState()
      self:refreshColumnState()
      self:clearModel()
      self:switchRole(self.playerData_.CharDataIndex, false, true)
    else
      Z.TipsVM.ShowTips(reply.errCode)
    end
  end)
end

function Face_rolechoose_windowView:playSwitchRoleEff(index, isInit)
  if isInit then
    return
  end
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  local eff = self.uiBinder["binder_role_" .. index].eff_click
  eff:SetEffectGoVisible(true)
  eff:Play()
end

function Face_rolechoose_windowView:OnInputBack()
  if self.isLogining_ then
    return
  end
  self.loginVM_:KickOffByClient(E.KickOffClientErrCode.NormalReturn, true)
end

return Face_rolechoose_windowView
