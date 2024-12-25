local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_head_subView = class("Personalzone_head_subView", super)
local DEFINE = require("ui.model.personalzone_define")
local loopGridView = require("ui.component.loop_grid_view")
local PersonalZoneHead = require("ui.view.personal_zone.record_main_view.head_loopitem")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local snapshotVm = Z.VMMgr.GetVM("snapshot")

function Personalzone_head_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_head_sub", "personalzone/personalzone_head_sub", UI.ECacheLv.None)
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
end

function Personalzone_head_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.charId_ = Z.ContainerMgr.CharSerialize.charId
  self.modelId_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  self:AddAsyncClick(self.uiBinder.btn_use.btn, function()
    if self.curId_ == self.useId_ then
      return
    end
    if not self.personalZoneVM_.CheckProfileImageIsUnlock(self.curId_) then
      local config = self.personalZoneData_:GetProfileImageTarget(self.curId_)
      if config and config.profileImageTargetConfig then
        if config.currentNum >= config.profileImageTargetConfig.Num then
          local success = self.personalZoneVM_.AsyncGetPersonalZoneTargetAward(self.curId_, self.cancelSource:CreateToken())
          if success then
            self.personalZoneData_:RemovePersonalzoneItem(self.curId_)
            self.personalZoneVM_.CheckRed()
          end
        elseif config.profileImageTargetConfig.JumpType and config.profileImageTargetConfig.JumpType > 0 then
          local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
          quickJumpVm.DoJumpByConfigParam(config.profileImageTargetConfig.JumpType, config.profileImageTargetConfig.JumpParam)
          return
        end
      end
    elseif self.viewData == E.FunctionID.PersonalzoneHead then
      local success = self.personalZoneVM_.AsyncSetPersonalZoneAvatar(self.curId_, self.cancelSource:CreateToken())
      if success then
        self.useId_ = self.curId_
        local headId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Head)
        local headFrameId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.HeadFrame)
        Z.EventMgr:Dispatch(Z.ConstValue.ChangeRoleAvatar, headId, headFrameId)
      end
    elseif self.viewData == E.FunctionID.PersonalzoneHeadFrame then
      local success = self.personalZoneVM_.AsyncSetPersonalZoneAvatarFrame(self.curId_, self.cancelSource:CreateToken())
      if success then
        self.useId_ = self.curId_
        local headId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Head)
        local headFrameId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.HeadFrame)
        Z.EventMgr:Dispatch(Z.ConstValue.ChangeRoleAvatar, headId, headFrameId)
      end
    end
    self:refreshInfo()
    self.headLoopScroll_:RefreshListView(self.datas_, false)
  end)
  self.headLoopScroll_ = loopGridView.new(self, self.uiBinder.loopscroll, PersonalZoneHead, "personalzone_head_item")
  self.useId_ = 0
  self.curId_ = 0
  local profileImageConfigs = {}
  if self.viewData == E.FunctionID.PersonalzoneHead then
    profileImageConfigs = self.personalZoneVM_.GetProfileImageList(DEFINE.ProfileImageType.Head)
    self.useId_ = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Head)
    self.curId_ = self.useId_
  elseif self.viewData == E.FunctionID.PersonalzoneHeadFrame then
    profileImageConfigs = self.personalZoneVM_.GetProfileImageList(DEFINE.ProfileImageType.HeadFrame)
    self.useId_ = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.HeadFrame)
    self.curId_ = self.useId_
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.datas_ = {}
    local index = 0
    if profileImageConfigs then
      for _, config in ipairs(profileImageConfigs) do
        local data = {
          config = config,
          select = self.curId_ == config.Id,
          isAuditing = false
        }
        if config.Id == 0 or config.Id == 1 then
          local auditData = snapshotVm.AsyncGetAvatarAuditData(self.charId_, self.cancelSource:CreateToken())
          if auditData then
            data.isAuditing = auditData.auditing >= E.EPictureReviewType.EPictureReviewing
            data.textureId = auditData.textureId
          end
        end
        index = index + 1
        self.datas_[index] = data
      end
    end
    self.headLoopScroll_:Init(self.datas_)
    self:refreshInfo()
  end)()
end

function Personalzone_head_subView:OnDeActive()
  self.headLoopScroll_:UnInit()
  self.headLoopScroll_ = nil
end

function Personalzone_head_subView:OnRefresh()
end

function Personalzone_head_subView:SetSelect(id)
  self.personalZoneData_:RemovePersonalzoneItem(id)
  self.personalZoneVM_.CheckRed()
  self.curId_ = id
  for _, data in ipairs(self.datas_) do
    data.select = data.config.Id == self.curId_
  end
  self.headLoopScroll_:RefreshListView(self.datas_, false)
  self:refreshInfo()
end

function Personalzone_head_subView:refreshInfo()
  local selectedData
  for _, data in ipairs(self.datas_) do
    if data.config.Id == self.curId_ then
      selectedData = data
      break
    end
  end
  if selectedData and selectedData.isAuditing then
    self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.img_portrait, false)
    self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.rimg_portrait, true)
    self.uiBinder.node_player_head_item.rimg_portrait:SetNativeTexture(selectedData.textureId)
  else
    local viewData = {}
    viewData.charId = self.charId_
    viewData.modelId = self.modelId_
    if self.viewData == E.FunctionID.PersonalzoneHead then
      viewData.id = self.curId_
      viewData.isShowCombinationIcon = false
      viewData.isShowTalentIcon = false
      viewData.headFrameId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.HeadFrame)
    elseif self.viewData == E.FunctionID.PersonalzoneHeadFrame then
      viewData.id = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Head)
      viewData.isShowCombinationIcon = false
      viewData.isShowTalentIcon = false
      viewData.headFrameId = self.curId_
    end
    PlayerPortraitHgr.InsertNewPortrait(self.uiBinder.node_player_head_item, viewData)
  end
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.img_audit_mask, selectedData.isAuditing)
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.group_unlocked, false)
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.img_select, false)
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.img_use_bg, false)
  local tagetConfig = self.personalZoneData_:GetProfileImageTarget(self.curId_)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.curId_)
  if config then
    local text = ""
    self.uiBinder.lab_head_name.text = config.Name
    text = config.UnlockDes
    if tagetConfig and tagetConfig.profileImageTargetConfig then
      text = Z.Placeholder.Placeholder(tagetConfig.profileImageTargetConfig.Describe, {
        val = tagetConfig.profileImageTargetConfig.Num
      })
      text = text .. string.format("(%s/%s)", tagetConfig.currentNum, tagetConfig.profileImageTargetConfig.Num)
    end
    self.uiBinder.lab_get_info.text = text
  end
  self.uiBinder.lab_info.text = ""
  local isUnlock = self.personalZoneVM_.CheckProfileImageIsUnlock(self.curId_)
  if config.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.curId_)
    if itemConfig then
      self.uiBinder.lab_info.text = itemConfig.Description
    end
  else
    self.uiBinder.lab_info.text = ""
  end
  if self.curId_ == self.useId_ then
    self.uiBinder.btn_use.btn.IsDisabled = true
    self.uiBinder.btn_use.lab_normal.text = Lang("EnvSkillStateEquiped")
  elseif not isUnlock then
    if tagetConfig and tagetConfig.profileImageTargetConfig then
      if tagetConfig.currentNum < tagetConfig.profileImageTargetConfig.Num then
        if tagetConfig.profileImageTargetConfig.JumpType and tagetConfig.profileImageTargetConfig.JumpType > 0 then
          self.uiBinder.btn_use.btn.IsDisabled = false
          self.uiBinder.btn_use.lab_normal.text = Lang("GotoObtain")
        else
          self.uiBinder.btn_use.btn.IsDisabled = true
          self.uiBinder.btn_use.lab_normal.text = Lang("InvestigationSelectNotComplete")
        end
      else
        self.uiBinder.btn_use.btn.IsDisabled = false
        self.uiBinder.btn_use.lab_normal.text = Lang("UnLock")
      end
    else
      self.uiBinder.btn_use.btn.IsDisabled = true
      self.uiBinder.btn_use.lab_normal.text = Lang("InvestigationSelectNotComplete")
    end
  else
    self.uiBinder.btn_use.btn.IsDisabled = false
    self.uiBinder.btn_use.lab_normal.text = Lang("ExpressionItemUse")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.curId_))
  self:refreshExpireTime()
end

function Personalzone_head_subView:refreshExpireTime()
  self.personalZoneVM_.RefreshViewExpireTime(self.curId_, self.uiBinder, self.uiBinder.lab_expiretime)
end

return Personalzone_head_subView
