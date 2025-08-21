local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_title_subView = class("Season_title_subView", super)
local MODEL_SIZE = 2.5
local ARMBAND_MOUNT_RES_NAME = "ch_c_armband_bizhang"
local MALE_FADE_MAT_PATH = "materials/unrealscene/ui_fade_male"
local FEMALE_FADE_MAT_PATH = "materials/unrealscene/ui_fade_female"
local FADE_MAT_PATH = "materials/unrealscene/ui_fade_normal"
local ARMHAND_EFFECT_PATH = "effect/character/badge/p_fx_badge_dan_levelup_1"

function Season_title_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_title_sub", "season_title/season_title_new_sub", UI.ECacheLv.None, true)
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  self.seasonData_ = Z.DataMgr.Get("season_data")
  self.seasonTitleVM_ = Z.VMMgr.GetVM("season_title")
  self.seasonTitleData_ = Z.DataMgr.Get("season_title_data")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.BpTipView_ = require("ui.view.season_lv_tips_view").new()
  self.isCanUpRankStar_ = false
  self.curArmbandRewardIndex_ = -1
  self.showModel_ = nil
  local charBase = Z.ContainerMgr.CharSerialize.charBase
  self.modelId_ = Z.ModelManager:GetModelIdByGenderAndSize(charBase.gender, charBase.bodySize)
  self.bpTipOffset_ = Vector2.New(-200, -100)
  self.tipsId_ = nil
  self.showRankStarAttr_ = Z.PbAttrEnum("AttrShowRankStar")
end

function Season_title_subView:initBinder()
  self.cont_left_ = self.uiBinder.cont_left
  self.cont_right_ = self.uiBinder.cont_right
  local dataList = Z.Global.RankConditionItemIconId
  self.conditions_ = {}
  self.conditions_[1] = {
    conditionId = 0,
    unit = self.cont_left_.node_season_condition_1
  }
  self.conditions_[2] = {
    conditionId = 0,
    unit = self.cont_left_.node_season_condition_2
  }
  if dataList[1] and dataList[1][2] then
    self.conditions_[1].conditionId = dataList[1][2]
  end
  if dataList[2] and dataList[2][2] then
    self.conditions_[2].conditionId = dataList[2][2]
  end
  self.node_stars_ = {}
  self.node_stars_[1] = self.cont_left_.node_star_1
  self.node_stars_[2] = self.cont_left_.node_star_2
  self.node_stars_[3] = self.cont_left_.node_star_3
  self.node_stars_[4] = self.cont_left_.node_star_4
  self.node_stars_[5] = self.cont_left_.node_star_5
end

function Season_title_subView:OnActive()
  self:initBinder()
  self:onStartAnimShow()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:AddClick(self.cont_right_.btn_award, function()
    self.seasonTitleVM_.OpenSeasonTitleCourseSubView()
  end)
  self:AddAsyncClick(self.cont_left_.btn_get, function()
    if self.isCanUpRankStar_ then
      self.seasonTitleVM_.AsyncAdvanceSeasonMaxRankStart()
    elseif self.nextConifg_ then
      for _, v in ipairs(self.nextConifg_.Conditions) do
        local params = {}
        local condType = v[1]
        if v[2] then
          table.insert(params, v[2])
        end
        if v[3] then
          table.insert(params, v[3])
        end
        if not Z.ConditionHelper.CheckSingleCondition(condType, true, table.unpack(params)) then
          self:openNotEnoughItemTips(v)
          break
        end
      end
    end
  end)
  self:AddAsyncClick(self.cont_right_.btn_arrow_left, function()
    if self.curArmbandRewardIndex_ <= 1 then
      return
    end
    self.curArmbandRewardIndex_ = self.curArmbandRewardIndex_ - 1
    self:refreshArmbandReward()
    self:onRewardIndexChange()
  end)
  self:AddAsyncClick(self.cont_right_.btn_arrow_right, function()
    if self.curArmbandRewardIndex_ >= #self.allArmbandRewardConfigList_ then
      return
    end
    self.curArmbandRewardIndex_ = self.curArmbandRewardIndex_ + 1
    self:refreshArmbandReward()
    self:onRewardIndexChange()
  end)
  self:AddAsyncListener(self.uiBinder.cont_right.tog_use, self.uiBinder.cont_right.tog_use.AddListener, function(isOn)
    self:onTogUseChanged(isOn)
  end)
  self.isCanUpRankStar_ = false
  self.allArmbandRewardConfigList_ = self.seasonTitleData_:GetArmbandRewardList()
  self.zListString_ = ZUtil.Pool.Collections.ZList_string.Rent()
  self.modelArmbandEffectData_ = Panda.ZGame.ModelArmbandEffectData.New("", "", "")
  self.curShowRankStar_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(self.showRankStarAttr_).Value
  self:refreshTotalInfo()
  self:BindEvents()
  self:BindLuaAttrWatchers()
end

function Season_title_subView:onRewardIndexChange()
  local config = self.allArmbandRewardConfigList_[self.curArmbandRewardIndex_]
  if config then
    self:refreshConditions(config)
  end
end

function Season_title_subView:OnDeActive()
  self:clearModel()
  self:clearPosCheckTimer()
  for _, value in pairs(self.conditions_) do
    value.unit.btn:RemoveAllListeners()
  end
  self:UnBindEvents()
  self:UnBindLuaAttrWatchers()
  if self.zListString_ then
    ZUtil.Pool.Collections.ZList_string.Return(self.zListString_)
    self.zListString_ = nil
  end
  self.nextConifg_ = nil
  self:closeSourceTip()
  self.BpTipView_:DeActive()
  if self.effectModelId_ then
    Z.UnrealSceneMgr:ClearEffect(self.effectModelId_)
    self.effectModelId_ = nil
  end
end

function Season_title_subView:OnRefresh()
end

function Season_title_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.SeasonTitle.TitleRankStarUpgrade, self.refreshTotalInfo, self)
end

function Season_title_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.SeasonTitle.TitleRankStarUpgrade, self.refreshTotalInfo, self)
end

function Season_title_subView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt == nil then
    return
  end
  self.showRankStarWatcher_ = self:BindEntityLuaAttrWatcher({
    self.showRankStarAttr_
  }, Z.EntityMgr.PlayerEnt, self.onShowRankStarChanged)
end

function Season_title_subView:UnBindLuaAttrWatchers()
  if self.showRankStarWatcher_ then
    self:UnBindEntityLuaAttrWatcher(self.showRankStarWatcher_)
    self.showRankStarWatcher_ = nil
  end
end

function Season_title_subView:refreshTotalInfo()
  self.curArmbandRewardIndex_ = self.seasonTitleVM_.GetCurArmbandIndex()
  self:refreshRankInfo()
  self:refreshArmbandReward()
  self:refreshFashionReward()
end

function Season_title_subView:refreshRankInfo()
  local rankInfo = self.seasonTitleData_:GetCurRankInfo()
  if rankInfo then
    self:refreshRankStar(rankInfo.curRanKStar)
  end
  local isHaveUnReceivedRankReward = self.seasonTitleVM_.IsHaveUnReceivedRankReward()
  self.cont_right_.Ref:SetVisible(self.cont_right_.img_reward_red, isHaveUnReceivedRankReward)
end

function Season_title_subView:refreshRankStar(rankStar)
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local config = seasonRankTableMgr.GetRow(rankStar)
  if config == nil then
    return
  end
  local allConfigs = self.seasonTitleData_:GetAllConfigs()
  if allConfigs[config.RankId] then
    self.showStars = #allConfigs[config.RankId] <= #self.node_stars_
    if self.showStars then
      self.cont_left_.Ref:SetVisible(self.cont_left_.layout_star, true)
      self.cont_left_.Ref:SetVisible(self.cont_left_.node_star_high, false)
      for key, value in ipairs(self.node_stars_) do
        if key <= config.StarLevel then
          value.Ref:SetVisible(value.img_star_on, true)
        else
          value.Ref:SetVisible(value.img_star_on, false)
        end
      end
      for key, value in ipairs(self.node_stars_) do
        if key <= #allConfigs[config.RankId] then
          self.cont_left_.Ref:SetVisible(value.Ref, true)
        else
          self.cont_left_.Ref:SetVisible(value.Ref, false)
        end
      end
    else
      self.cont_left_.Ref:SetVisible(self.cont_left_.layout_star, false)
      self.cont_left_.Ref:SetVisible(self.cont_left_.node_star_high, true)
      self.cont_left_.lab_star_num.text = "x" .. config.StarLevel
    end
  end
  self.nextConifg_ = nil
  if config.BackRankId and config.BackRankId ~= 0 then
    self.nextConifg_ = seasonRankTableMgr.GetRow(config.BackRankId)
  end
  self:refreshConditions(self.nextConifg_)
end

function Season_title_subView:refreshConditions(config)
  local isCurRank = self.curArmbandRewardIndex_ == self.seasonTitleVM_.GetCurArmbandIndex()
  if isCurRank then
    config = self.nextConifg_
  end
  self.cont_left_.Ref:SetVisible(self.cont_left_.layout_star, isCurRank and self.showStars)
  self.cont_left_.Ref:SetVisible(self.cont_left_.node_star_high, isCurRank and not self.showStars)
  if config then
    self.isCanUpRankStar_ = Z.ConditionHelper.CheckCondition(config.Conditions, false)
    self.cont_left_.btn_get.IsDisabled = not self.isCanUpRankStar_
    self.cont_left_.Ref:SetVisible(self.cont_left_.btn_get, false)
    self.cont_right_.Ref:SetVisible(self.cont_right_.img_red, self.isCanUpRankStar_)
    for _, value in pairs(self.conditions_) do
      self.cont_left_.Ref:SetVisible(value.unit.Ref, false)
      value.unit.btn:RemoveAllListeners()
      if config.Conditions and config.Conditions and #config.Conditions > 0 then
        self.cont_left_.Ref:SetVisible(self.cont_left_.btn_get, isCurRank)
        for _, condition in ipairs(config.Conditions) do
          if value.conditionId == condition[2] then
            self.cont_left_.Ref:SetVisible(value.unit.Ref, true)
            self:AddClick(value.unit.btn, function()
              self:clickSeasonCondition(condition)
            end)
            local params = {}
            table.insert(params, condition[2])
            table.insert(params, condition[3])
            local bResult, tips, progress = Z.ConditionHelper.GetSingleConditionDesc(condition[1], table.unpack(params))
            local color = bResult and E.TextStyleTag.White or E.TextStyleTag.Red
            progress = Z.RichTextHelper.ApplyStyleTag(progress, color)
            value.unit.lab_level_schedule.text = progress
            break
          end
        end
      end
    end
  else
    self.cont_left_.Ref:SetVisible(self.cont_left_.btn_get, false)
    for _, value in pairs(self.conditions_) do
      self.cont_left_.Ref:SetVisible(value.unit.Ref, false)
    end
  end
end

function Season_title_subView:refreshFashionReward()
  local coreId = self.seasonTitleVM_.GetCurUnReceivedCoreRewardRankId()
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local unReceivedCoreConfig
  if coreId ~= -1 then
    unReceivedCoreConfig = seasonRankTableMgr.GetRow(coreId)
  end
  if unReceivedCoreConfig then
    self.cont_right_.lab_get_info.text = string.format(Lang("GetRewardWhenSeasonTitle"), unReceivedCoreConfig.Name)
    Z.CoroUtil.create_coro_xpcall(function()
      self:showModel()
      self:refreshCoreReward(unReceivedCoreConfig)
    end)()
  else
    self.cont_right_.lab_get_info.text = ""
    self.cont_right_.lab_name.text = ""
  end
end

function Season_title_subView:showModel()
  self:clearModel()
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  local isMale = gender == Z.PbEnum("EGender", "GenderMale")
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local rate = rootCanvas.localScale.x / 0.00925 * MODEL_SIZE
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  pos.x = pos.x + 1.5
  local modelScale = Z.EntityMgr.PlayerEnt.Model:GetLuaAttrGoScaleFinal()
  local modelHeight = Z.EntityMgr.PlayerEnt.Model:GetAttrGoHeight() / modelScale
  local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.cont_right_.node_model_position.position)
  local cameraPosition = Z.CameraMgr.MainCamera.transform.position
  screenPosition.z = Z.NumTools.Distance(cameraPosition, pos)
  local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(screenPosition)
  local posOffset = modelHeight * rate
  worldPosition.y = worldPosition.y - posOffset
  self.showModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    model:SetLuaAttr(Z.ModelAttr.ECameraAlpha, 0)
    model:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, false)
    model:SetAttrGoPosition(worldPosition)
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, -130, 0)))
    model:SetLuaAttrGoScale(rate)
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    local ModelClipDataClass = Panda.ZGame.ModelClipData
    local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_ModelClipData.Rent()
    zList:Add(ModelClipDataClass.New(Vector4.New(0.25, 0, 1, 1), Z.ModelRenderMask.Mount))
    zList:Add(ModelClipDataClass.New(Vector4.New(0.25, 0, 1, 1), Z.ModelRenderMask.BODY))
    model:SetLuaAttr(Z.ModelAttr.EModelClipData, zList)
    zList:Recycle()
    self.zListString_:Clear()
    self.zListString_:Add(isMale and Z.Global.SeasonArmbandShowAction[1] or Z.Global.SeasonArmbandShowAction[2])
    model:SetLuaAnimBase(Z.AnimBaseData.Rent(self.zListString_))
    local emoteId = isMale and Z.Global.SeasonArmbandShowExpression[1] or Z.Global.SeasonArmbandShowExpression[2]
    model:SetLuaAttrEmoteInfo(emoteId, -1)
  end, function(model)
    if not self.IsActive then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local asyncSwitchMount = Z.CoroUtil.async_to_sync(model.RenderComp.SwitchUIFadeMat)
      asyncSwitchMount(model.RenderComp, FADE_MAT_PATH, self.cancelSource:CreateToken(), Z.ModelRenderMask.Mount)
      local asyncSwitchBody = Z.CoroUtil.async_to_sync(model.RenderComp.SwitchUIFadeMat)
      local matPath = isMale and MALE_FADE_MAT_PATH or FEMALE_FADE_MAT_PATH
      asyncSwitchBody(model.RenderComp, matPath, self.cancelSource:CreateToken(), Z.ModelRenderMask.BODY)
      self:setCurArmbandMount(model)
      model:SetLuaAttr(Z.ModelAttr.ECameraAlpha, 1)
    end)()
  end)
  self:createPosCheckTimer(cameraPosition, screenPosition, pos, posOffset)
end

function Season_title_subView:clearModel()
  if self.showModel_ then
    self.showModel_.RenderComp:ResetUIFadeMat(Z.ModelRenderMask.Mount)
    self.showModel_.RenderComp:ResetUIFadeMat(Z.ModelRenderMask.BODY)
    Z.UnrealSceneMgr:ClearModel(self.showModel_)
    self.showModel_ = nil
  end
end

function Season_title_subView:createPosCheckTimer(lastCameraPos, lastScreenPos, transPos, posOffset)
  self:clearPosCheckTimer()
  self.posCheckTimer_ = self.timerMgr:StartTimer(function()
    local curCameraPos = Z.CameraMgr.MainCamera.transform.position
    if self.showModel_ and curCameraPos ~= lastCameraPos then
      lastScreenPos.z = Z.NumTools.Distance(curCameraPos, transPos)
      local curWorldPos = Z.CameraMgr.MainCamera:ScreenToWorldPoint(lastScreenPos)
      curWorldPos.y = curWorldPos.y - posOffset
      self.showModel_:SetAttrGoPosition(curWorldPos)
    end
  end, 0.2, 1)
end

function Season_title_subView:clearPosCheckTimer()
  if self.posCheckTimer_ then
    self.posCheckTimer_:Stop()
    self.posCheckTimer_ = nil
  end
end

function Season_title_subView:refreshArmbandReward()
  self.cont_right_.Ref:SetVisible(self.cont_right_.btn_arrow_left, false)
  self.cont_right_.Ref:SetVisible(self.cont_right_.btn_arrow_right, false)
  self.cont_right_.Ref:SetVisible(self.cont_right_.tog_use, false)
  local config = self.allArmbandRewardConfigList_[self.curArmbandRewardIndex_]
  if config then
    self.cont_right_.Ref:SetVisible(self.cont_right_.btn_arrow_left, self.curArmbandRewardIndex_ ~= 1)
    self.cont_right_.Ref:SetVisible(self.cont_right_.btn_arrow_right, self.curArmbandRewardIndex_ ~= #self.allArmbandRewardConfigList_)
    self.cont_left_.lab_title_name.text = config.Name
    self:setCurArmbandMount(self.showModel_)
    self:refreshUseToggle()
  end
end

function Season_title_subView:refreshCoreReward(config)
  local coreRewardId = config.CoreRewardId[1][1]
  local avatarShowTableMgr = Z.TableMgr.GetTable("AvatarShowTableMgr")
  local avatarShowConfig = avatarShowTableMgr.GetRow(coreRewardId)
  if avatarShowConfig == nil then
    return
  end
  self.cont_right_.lab_name.text = avatarShowConfig.Name
  if avatarShowConfig.DesignPage and #avatarShowConfig.DesignPage >= 2 then
    local gender = Z.ContainerMgr.CharSerialize.charBase.gender
    local fashionIconPath = gender == Z.PbEnum("EGender", "GenderMale") and avatarShowConfig.DesignPage[1][1] or avatarShowConfig.DesignPage[2][1]
    self.cont_left_.rimg_reward_icon:SetImage(fashionIconPath)
  end
  self.cont_right_.lab_get_info.text = string.format(Lang("GetRewardWhenSeasonTitle"), config.Name)
  self.cont_left_.Ref:SetVisible(self.cont_left_.img_received, self.seasonTitleVM_.IsReceivedRankReward(config.Id))
end

function Season_title_subView:clickSeasonCondition(condition)
  self:closeSourceTip()
  if condition and 0 < #condition then
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.cont_left.node_season_condition_1.Trans, condition[2])
  end
end

function Season_title_subView:openNotEnoughItemTips(condition)
  self:closeSourceTip()
  if condition and 0 < #condition then
    self.tipsId_ = Z.TipsVM.OpenSourceTips(condition[2], self.uiBinder.cont_right.rect_get)
  end
end

function Season_title_subView:closeSourceTip()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function Season_title_subView:onTogUseChanged(isUsed)
  local resultId
  if not isUsed then
    resultId = 0
  else
    local curRankInfo = self.seasonTitleData_:GetCurRankInfo()
    if curRankInfo.curRanKStar == nil or curRankInfo.curRanKStar == 0 then
      return
    end
    local selectConfig = self.allArmbandRewardConfigList_[self.curArmbandRewardIndex_]
    local serverConfig = Z.TableMgr.GetRow("SeasonRankTableMgr", curRankInfo.curRanKStar)
    if selectConfig.BigRankId > serverConfig.BigRankId or selectConfig.RankId > serverConfig.RankId then
      return
    end
    resultId = selectConfig.Id
  end
  self.seasonTitleVM_.AsyncSetSeasonRankShowArmband(resultId, self.cancelSource:CreateToken())
end

function Season_title_subView:onShowRankStarChanged()
  self.curShowRankStar_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(self.showRankStarAttr_).Value
  self:refreshUseToggle()
end

function Season_title_subView:refreshUseToggle()
  self:checkTogShow()
  local selectConfig = self.allArmbandRewardConfigList_[self.curArmbandRewardIndex_]
  local serverConfig = Z.TableMgr.GetRow("SeasonRankTableMgr", self.curShowRankStar_, true)
  local isShow = serverConfig and serverConfig.RankId == selectConfig.RankId
  self.uiBinder.cont_right.tog_use:SetIsOnWithoutCallBack(isShow)
  self.uiBinder.cont_right.lab_tog.text = Lang(isShow and "SeasonRankTitleDisplayTips" or "SeasonRankTitleHideTips")
end

function Season_title_subView:checkTogShow()
  local curRankInfo = self.seasonTitleData_:GetCurRankInfo()
  if curRankInfo.curRanKStar == nil or curRankInfo.curRanKStar == 0 then
    self.uiBinder.cont_right.Ref:SetVisible(self.uiBinder.cont_right.tog_use, false)
  else
    local selectConfig = self.allArmbandRewardConfigList_[self.curArmbandRewardIndex_]
    local serverConfig = Z.TableMgr.GetRow("SeasonRankTableMgr", curRankInfo.curRanKStar)
    if selectConfig.BigRankId <= serverConfig.BigRankId and selectConfig.RankId <= serverConfig.RankId then
      self.uiBinder.cont_right.Ref:SetVisible(self.uiBinder.cont_right.tog_use, true)
    else
      self.uiBinder.cont_right.Ref:SetVisible(self.uiBinder.cont_right.tog_use, false)
    end
  end
end

function Season_title_subView:setCurArmbandMount(model)
  if model == nil then
    return
  end
  local config = self.allArmbandRewardConfigList_[self.curArmbandRewardIndex_]
  if config == nil then
    return
  end
  local armbankId = config.ArmbandReward
  self.modelArmbandEffectData_.ArmbandAddress = ""
  self.modelArmbandEffectData_.TexMatAddress = ""
  self.modelArmbandEffectData_.TextureAddress = ""
  if 0 < armbankId then
    local seasonRankArmbandTableMgr = Z.TableMgr.GetTable("SeasonRankArmbandTableMgr")
    local armbandConfig = seasonRankArmbandTableMgr.GetRow(armbankId)
    if armbandConfig then
      self.modelArmbandEffectData_.ArmbandAddress = ARMBAND_MOUNT_RES_NAME
      self.modelArmbandEffectData_.TexMatAddress = armbandConfig.MaterialPath
      self.modelArmbandEffectData_.TextureAddress = armbandConfig.TexturePath
    end
  end
  model:SetLuaAttr(Z.ModelAttr.EModelCMountArmBand, self.modelArmbandEffectData_)
  Z.CoroUtil.create_coro_xpcall(function()
    Z.UnrealSceneMgr:AsyncSetArmHandEffect(model, ARMHAND_EFFECT_PATH, self.cancelSource:CreateToken())
  end)()
end

function Season_title_subView:onStartAnimShow()
  if Z.IsPCUI then
    return
  end
  self.uiBinder.anim_season:CoroPlayOnce("anim_season_title_new_sub", self.cancelSource:CreateToken(), function()
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

return Season_title_subView
