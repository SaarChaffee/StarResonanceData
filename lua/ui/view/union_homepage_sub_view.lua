local UI = Z.UI
local super = require("ui.ui_subview_base")
local unionLogoItem = require("ui.component.union.union_logo_item")
local loopScrollRect = require("ui.component.loopscrollrect")
local UnionEventListItemTemplate = require("ui.component.union.union_event_list_item")
local unionTagItem = require("ui.component.union.union_tag_item")
local unionBuffitem = require("ui.component.union.union_buff_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local Union_homepage_subView = class("Union_homepage_subView", super)
local reportDefine = require("ui.model.report_define")
local unionSDKGroup = require("ui.component.union.union_sdk_group")
local MAX_BUFF_COUNT = Z.ConstValue.UnionConstValue.MAX_BUFF_COUNT

function Union_homepage_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_homepage_sub", "union/union_homepage_sub", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.reportVm_ = Z.VMMgr.GetVM("report")
end

function Union_homepage_subView:initData()
  self.buffItemDict_ = {}
  self.accountData_ = Z.DataMgr.Get("account_data")
  self.serverData_ = Z.DataMgr.Get("server_data")
end

function Union_homepage_subView:initComponent()
  self:startAnimatedShow()
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Normal, self, self.uiBinder.trans_tag_time, self.uiBinder.trans_tag_activity)
  self.Logo_ = unionLogoItem.new()
  self.Logo_:Init(self.uiBinder.binder_logo.Go)
  self.scrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_event, self, UnionEventListItemTemplate)
  self:AddClick(self.uiBinder.btn_set, function()
    self:onSettingBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_recruit_set, function()
    self:onRecruitSettingBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_list, function()
    self:onUnionListBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_buff_switch, function()
    self:onBuffSwitchBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_buff_ask, function()
    self:onBuffAskBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_edit, function()
    self:onSettingBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_return, function()
    self:onUnionReturnBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_photo_album, function()
    self:onAlbumBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_crowdfunding, function()
    self:onUnionUnlockBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_scene_lock_ask_1, function()
    self:onSceneLockHelpBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_scene_lock_ask_2, function()
    self:onSceneLockHelpBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_money_icon, function()
    self:onMoneyIconBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_exp_icon, function()
    self:onExpIconBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_report, function()
    self:onReportBtnClick()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, self.reportVm_.IsReportOpen(true))
end

function Union_homepage_subView:startAnimatedShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_homepage_subView:onSettingBtnClick()
  self.unionVM_:OpenUnionSettingView()
end

function Union_homepage_subView:onRecruitSettingBtnClick()
  self.unionVM_:OpenUnionRecruitSettingView()
end

function Union_homepage_subView:onUnionListBtnClick()
  self.unionVM_:OpenJoinWindow()
end

function Union_homepage_subView:onUnionUnlockBtnClick()
  self.unionVM_:OpenUnionUnlockSceneView()
end

function Union_homepage_subView:onBuffSwitchBtnClick()
  local buildConfig = self.unionVM_:GetUnionBuildConfig(E.UnionBuildId.Buff)
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  quickJumpVm.DoJumpByConfigParam(buildConfig.QuickJumpType, buildConfig.QuickJumpParam)
end

function Union_homepage_subView:onUnionReturnBtnClick()
  self.unionVM_:AsyncEnterUnionScene(self.cancelSource:CreateToken())
end

function Union_homepage_subView:onAlbumBtnClick()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.UnionPhotoSet)
  if not isOn then
    return
  end
  Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Union)
end

function Union_homepage_subView:onBuffAskBtnClick()
  self.helpsysVM_.CheckAndShowView(50010621)
end

function Union_homepage_subView:onSceneLockHelpBtnClick()
  self.helpsysVM_.CheckAndShowView(500110)
end

function Union_homepage_subView:onMoneyIconBtnClick()
  self:openItemTips(self.uiBinder.btn_money_icon.transform, E.UnionResourceId.Gold)
end

function Union_homepage_subView:onExpIconBtnClick()
  self:openItemTips(self.uiBinder.btn_exp_icon.transform, E.UnionResourceId.Exp)
end

function Union_homepage_subView:onReportBtnClick()
  self.reportVm_.OpenReportPop(reportDefine.ReportScene.UnionInfo, self.unionData_.UnionInfo.baseInfo.Name, self.unionData_.UnionInfo.baseInfo.Id)
end

function Union_homepage_subView:RefreshInfo(unionInfo)
  if unionInfo == nil then
    return
  end
  local logoData = self.unionVM_:GetLogoData(unionInfo.baseInfo.Icon)
  self.Logo_:SetLogo(logoData)
  self.uiBinder.lab_name.text = unionInfo.baseInfo.Name
  self.uiBinder.lab_grade_digit.text = unionInfo.baseInfo.level
  self.uiBinder.lab_member_digit.text = string.zconcat(unionInfo.baseInfo.onlineNum, "/", unionInfo.baseInfo.num, "/", unionInfo.baseInfo.maxNum)
  self.uiBinder.lab_id.text = Lang("ID") .. unionInfo.baseInfo.Id
  self.uiBinder.lab_date.text = Lang("CreateDate") .. os.date("%Y/%m/%d", unionInfo.createTime)
  local moneyItemConfig = Z.TableMgr.GetRow("ItemTableMgr", E.UnionResourceId.Gold)
  if moneyItemConfig then
    self.uiBinder.rimg_money_icon:SetImage(moneyItemConfig.Icon)
    self.uiBinder.lab_money_digit.text = self.unionVM_:GetUnionResourceCount(E.UnionResourceId.Gold)
  end
  local expItemConfig = Z.TableMgr.GetRow("ItemTableMgr", E.UnionResourceId.Exp)
  if expItemConfig then
    self.uiBinder.rimg_exp_icon:SetImage(expItemConfig.Icon)
    self.uiBinder.lab_exp_digit.text = self.unionVM_:GetUnionResourceCount(E.UnionResourceId.Exp)
  end
  self.uiBinder.lab_manifesto.text = unionInfo.baseInfo.declaration
  table.sort(unionInfo.unionEvents, function(left, right)
    return left.eventTime > right.eventTime
  end)
  self.scrollRect_:ClearCells()
  self.scrollRect_:SetData(unionInfo.unionEvents, false, false, 0)
  self:refreashTagUI(unionInfo)
  local presidentInfo = self.unionVM_:GetUnionMemberData(unionInfo.baseInfo.presidentId)
  if presidentInfo and presidentInfo.socialData then
    self.uiBinder.lab_president_name.text = presidentInfo.socialData.basicData.name
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(presidentInfo.socialData.basicData.isNewbie))
    self:refreshHeadUI(presidentInfo)
  end
  self:refreshBuffItem()
  local isShowPhotoAlbumBtn = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetCover)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_photo_album, isShowPhotoAlbumBtn)
  self:getUnionPhoto(unionInfo)
  self:refreshUnlockState()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionSceneUnlockBtnRed, self, self.uiBinder.btn_crowdfunding.transform)
end

function Union_homepage_subView:refreshUnlockState()
  local sceneIsUnlock, state, leftTime = self.unionVM_:GetUnionSceneIsUnlock()
  self:SetUIVisible(self.uiBinder.btn_return, sceneIsUnlock)
  local canShowGrow = state == E.UnionUnlockState.IsCrowding
  self:SetUIVisible(self.uiBinder.node_crowdfunding_01, sceneIsUnlock == false and canShowGrow == false)
  self:SetUIVisible(self.uiBinder.node_crowdfunding_02, sceneIsUnlock == false and canShowGrow)
  if sceneIsUnlock == false then
    if state == E.UnionUnlockState.IsCrowding then
      local num = self.unionVM_:GetUnionSceneUnlockProgress()
      self.uiBinder.lab_grow_member.text = Lang("UnionSceneUnlockProgress") .. num .. "/" .. Z.Global.UnionunlocksceneNum
    end
    local nowTime = math.floor(Z.TimeTools.Now() / 1000)
    if 0 < leftTime and leftTime > nowTime then
      if self.timer_ then
        self.timerMgr:StopTimer(self.timer_)
        self.timer_ = nil
      end
      self:onTimerUpdate(state, leftTime)
      self.timer_ = self.timerMgr:StartTimer(function()
        self:onTimerUpdate(state, leftTime)
      end, 1, -1)
    end
  end
end

function Union_homepage_subView:onTimerUpdate(state, leftTime)
  local str
  if state == E.UnionUnlockState.WaitBegin then
    str = Lang("UnionGrowOpenCounter")
  elseif state == E.UnionUnlockState.WaitBuildEnd then
    str = Lang("UnionBuildCounter")
  end
  local nowTime = math.floor(Z.TimeTools.Now() / 1000)
  local t = leftTime - nowTime
  local time = leftTime - nowTime
  if 0 <= time then
    self.uiBinder.lab_left_time.text = str .. Z.TimeFormatTools.FormatToDHMS(t)
  else
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
    self:refreshUnlockState()
  end
end

function Union_homepage_subView:refreashTagUI(unionInfo)
  local tagIdList = unionInfo.baseInfo.tags
  self.unionTagItem_:SetCommonTagUI(tagIdList, self.uiBinder)
end

function Union_homepage_subView:refreshHeadUI(presidentInfo)
  if presidentInfo == nil then
    return
  end
  if self.headItem_ then
    self.headItem_:UnInit()
  end
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, presidentInfo.socialData, function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(presidentInfo.socialData.basicData.charID, self.cancelSource:CreateToken())
    end)()
  end, self.cancelSource:CreateToken())
end

function Union_homepage_subView:openItemTips(trans, itemId)
  self:closeItemTips()
  self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(trans, itemId)
end

function Union_homepage_subView:closeItemTips()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
end

function Union_homepage_subView:refreshBuffItem()
  local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  for i = 1, MAX_BUFF_COUNT do
    local item = self.uiBinder["binder_cur_buff_" .. i]
    local buffId
    local curBuffInfo = self.unionData_.BuildBuffInfo[i]
    if curBuffInfo and curServerTime < curBuffInfo.endTime then
      buffId = self.unionData_.BuildBuffInfo[i].effectBuffId
    end
    local buffItemData = {
      BuffId = buffId,
      SlotIndex = i,
      IgnoreClick = false
    }
    if self.buffItemDict_[i] == nil then
      self.buffItemDict_[i] = unionBuffitem.new()
      self.buffItemDict_[i]:Init(item, buffItemData)
    else
      self.buffItemDict_[i]:Refresh(buffItemData)
    end
  end
  local isHavePower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetBuildingEffect)
  self.uiBinder.lab_content_buff.text = isHavePower and Lang("GoSet") or Lang("GoView")
end

function Union_homepage_subView:unInitBuffItem()
  for key, item in pairs(self.buffItemDict_) do
    item:UnInit()
  end
  self.buffItemDict_ = nil
end

function Union_homepage_subView:onRefreshUnionBaseData()
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  self:RefreshInfo(unionInfo)
end

function Union_homepage_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self:initSDKGroup()
  self:BindEvents()
end

function Union_homepage_subView:OnDeActive()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
  self.Logo_:UnInit()
  self.Logo_ = nil
  self:unInitSDKGroup()
  self:UnBindEvents()
  self:unInitBuffItem()
  self:clearUnionRedDot()
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self:closeItemTips()
end

function Union_homepage_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.RefreshUnionBaseData, self.onRefreshUnionBaseData, self)
end

function Union_homepage_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.RefreshUnionBaseData, self.onRefreshUnionBaseData, self)
end

function Union_homepage_subView:OnRefresh()
  self:RefreshInfo(self.unionData_.UnionInfo)
  Z.CoroUtil.create_coro_xpcall(function()
    local unionId = self.unionVM_:GetPlayerUnionId()
    self.unionVM_:AsyncReqUnionInfo(unionId, self.cancelSource:CreateToken())
    self.unionVM_:AsyncGetUnlockUnionSceneData(self.cancelSource:CreateToken())
    self:RefreshInfo(self.unionData_.UnionInfo)
  end)()
end

function Union_homepage_subView:getUnionPhoto(unionInfo)
  local coverPhotoInfo = unionInfo.baseInfo.coverPhotoInfo
  if not coverPhotoInfo then
    self.uiBinder.rimg_photo:SetImage(Z.ConstValue.UnionRes.DefaultPhotoCover)
    return
  end
  local album_main_vm = Z.VMMgr.GetVM("album_main")
  local photoData = coverPhotoInfo.images[E.PictureType.ECameraRender]
  if not photoData or string.zisEmpty(photoData.cosUrl) then
    self.uiBinder.rimg_photo:SetImage(Z.ConstValue.UnionRes.DefaultPhotoCover)
    return
  end
  album_main_vm.AsyncGetHttpAlbumPhoto(photoData.cosUrl, E.PictureType.ECameraRender, E.NativeTextureCallToken.album_loop_item, self.cancelSource, self.onPhotoCallBack, self)
end

function Union_homepage_subView:onPhotoCallBack(photoId)
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
  self.photoId = photoId
  self.uiBinder.rimg_photo:SetNativeTexture(photoId)
end

function Union_homepage_subView:clearUnionRedDot()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionSceneUnlockBtnRed)
end

function Union_homepage_subView:initSDKGroup()
  self.unionSDKGroup_ = unionSDKGroup.new()
  self.unionSDKGroup_:Init(self)
end

function Union_homepage_subView:unInitSDKGroup()
  if self.unionSDKGroup_ then
    self.unionSDKGroup_:UnInit()
    self.unionSDKGroup_ = nil
  end
end

return Union_homepage_subView
