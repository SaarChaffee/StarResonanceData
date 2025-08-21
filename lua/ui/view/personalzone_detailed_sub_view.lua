local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_detailed_subView = class("Personalzone_detailed_subView", super)
local DEFINE = require("ui.model.personalzone_define")
local loopGridView = require("ui.component.loop_grid_view")
local PersonalZoneCard = require("ui.view.personal_zone.record_main_view.card_loopitem")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local IdcardHelper = require("ui.view.personal_zone.record_main_view.idcard_helper")

function Personalzone_detailed_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_detailed_sub", "personalzone/personalzone_detailed_sub", UI.ECacheLv.None)
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.collectionVM_ = Z.VMMgr.GetVM("collection")
end

function Personalzone_detailed_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.charId_ = Z.ContainerMgr.CharSerialize.charId
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  self.modelId_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  self:AddAsyncClick(self.uiBinder.btn_use.btn, function()
    if self.currentCardId_ == self.selectId_ then
      return
    end
    if not self.personalZoneVM_.CheckProfileImageIsUnlock(self.selectId_) then
      local config = self.personalZoneData_:GetProfileImageTarget(self.selectId_)
      if config and config.profileImageTargetConfig then
        if config.currentNum >= config.profileImageTargetConfig.Num then
          local success = self.personalZoneVM_.AsyncGetPersonalZoneTargetAward(self.selectId_, self.cancelSource:CreateToken())
          if success then
            self:SetSelect(self.selectId_)
          end
        elseif config.profileImageTargetConfig.JumpType and config.profileImageTargetConfig.JumpType > 0 then
          local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
          quickJumpVm.DoJumpByConfigParam(config.profileImageTargetConfig.JumpType, config.profileImageTargetConfig.JumpParam)
          return
        end
      end
    else
      local success = self.personalZoneVM_.AsyncSetPersonalZoneBusinessCardStyle(self.selectId_, self.cancelSource:CreateToken())
      if success then
        self.currentCardId_ = self.selectId_
        self.cardLoopScroll_:RefreshListView(self.datas_, false)
        self:refreshInfo()
      end
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_copy, function()
    Z.LuaBridge.SystemCopy(tostring(Z.ContainerMgr.CharSerialize.charBase.showId))
    Z.TipsVM.ShowTipsLang(100110)
  end)
  self.idCardHelper = IdcardHelper.new(self, self.uiBinder.node_idcard)
  self.idCardHelper:RefreshSelf()
  self.cardLoopScroll_ = loopGridView.new(self, self.uiBinder.loopscroll, PersonalZoneCard, "personalzone_idcard_bg_tpl")
  self.currentCardId_ = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  self.selectId_ = self.currentCardId_
  local profileImageConfigs = self.personalZoneVM_.GetProfileImageList(DEFINE.ProfileImageType.Card)
  self.datas_ = {}
  local index = 0
  if profileImageConfigs then
    for _, config in ipairs(profileImageConfigs) do
      local data = {
        config = config,
        select = self.selectId_ == config.Id
      }
      index = index + 1
      self.datas_[index] = data
    end
  end
  self.cardLoopScroll_:Init(self.datas_)
  self:refreshInfo()
  self.uiBinder.lab_num.text = self.collectionVM_.GetFashionCollectionPoints()
end

function Personalzone_detailed_subView:OnDeActive()
  self.cardLoopScroll_:UnInit()
  self.cardLoopScroll_ = nil
  self.personalZoneData_:ClearAddReddotByType(DEFINE.ProfileImageType.Card)
  self.personalZoneVM_.CheckRed()
end

function Personalzone_detailed_subView:OnRefresh()
end

function Personalzone_detailed_subView:SetSelect(id)
  self.personalZoneData_:RemovePersonalzoneItem(id)
  self.personalZoneVM_.CheckRed()
  self.selectId_ = id
  for _, data in ipairs(self.datas_) do
    data.select = data.config.Id == self.selectId_
  end
  self.cardLoopScroll_:RefreshListView(self.datas_, false)
  self:refreshInfo()
end

function Personalzone_detailed_subView:refreshInfo()
  local tagetConfig = self.personalZoneData_:GetProfileImageTarget(self.selectId_)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.selectId_)
  if config == nil then
    return
  end
  self.uiBinder.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalCardBgLong .. config.Image)
  self.uiBinder.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  self.uiBinder.lab_strength.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
  local viewData = {}
  viewData.id = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Head)
  viewData.charId = self.charId_
  viewData.modelId = self.modelId_
  viewData.isShowCombinationIcon = false
  viewData.isShowTalentIcon = false
  viewData.headFrameId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.HeadFrame)
  viewData.token = self.cancelSource:CreateToken()
  PlayerPortraitHgr.InsertNewPortrait(self.uiBinder.node_player_head_item, viewData)
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.group_unlocked, false)
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.img_select, false)
  self.uiBinder.node_player_head_item.Ref:SetVisible(self.uiBinder.node_player_head_item.img_use_bg, false)
  local playerVM = Z.VMMgr.GetVM("player")
  if playerVM:IsNamed() then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  else
    self.uiBinder.lab_name.text = Lang("EmptyRoleName")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value))
  self.idCardHelper:SetIDCardBg(Z.ConstValue.PersonalZone.PersonalCardBg .. config.Image, Z.ConstValue.PersonalZone.PersonalCardBg .. config.Image, config.Color)
  self.uiBinder.img_line_left:SetColorByHex(config.Color)
  self.uiBinder.img_bg:SetColorByHex(config.Color2)
  local isUnlock = self.personalZoneVM_.CheckProfileImageIsUnlock(self.selectId_)
  self.uiBinder.lab_head_name.text = config.Name
  if config.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.selectId_)
    if itemConfig then
      self.uiBinder.lab_info.text = itemConfig.Description .. "\n"
    end
  else
    self.uiBinder.lab_info.text = ""
  end
  local text = config.UnlockDes
  if tagetConfig and tagetConfig.profileImageTargetConfig and not isUnlock then
    text = Z.Placeholder.Placeholder(tagetConfig.profileImageTargetConfig.Describe, {
      val = tagetConfig.profileImageTargetConfig.Num
    })
    text = text .. string.format("(%s/%s)", tagetConfig.currentNum, tagetConfig.profileImageTargetConfig.Num)
  end
  self.uiBinder.lab_get_info.text = text
  if self.selectId_ == self.currentCardId_ then
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.selectId_))
  self:refreshExpireTime()
end

function Personalzone_detailed_subView:refreshExpireTime()
  self.personalZoneVM_.RefreshViewExpireTime(self.selectId_, self.uiBinder, self.uiBinder.lab_expiretime)
end

return Personalzone_detailed_subView
