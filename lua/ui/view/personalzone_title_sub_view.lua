local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_title_subView = class("Personalzone_title_subView", super)
local DEFINE = require("ui.model.personalzone_define")
local loopGridView = require("ui.component.loop_grid_view")
local PersonalZoneTitle = require("ui/view/personal_zone/record_main_view/title_loopitem")

function Personalzone_title_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_title_sub", "personalzone/personalzone_title_sub", UI.ECacheLv.None)
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
end

function Personalzone_title_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_lock.btn, function()
    if self.currentTitleId_ == self.selectId_ then
      return
    end
    if not self.personalZoneVM_.CheckProfileImageIsUnlock(self.selectId_) then
      local config = self.personalZoneData_:GetProfileImageTarget(self.selectId_)
      if config and config.profileImageTargetConfig then
        if config.currentNum >= config.profileImageTargetConfig.Num then
          local success = self.personalZoneVM_.AsyncGetPersonalZoneTargetAward(self.selectId_, self.cancelSource:CreateToken())
          if success then
            self.personalZoneData_:RemovePersonalzoneItem(self.selectId_)
            self.personalZoneVM_.CheckRed()
            self.titleLoopScroll_:RefreshListView(self.datas_, false)
            self:refreshInfo()
          end
        elseif config.profileImageTargetConfig.JumpType and config.profileImageTargetConfig.JumpType > 0 then
          local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
          quickJumpVm.DoJumpByConfigParam(config.profileImageTargetConfig.JumpType, config.profileImageTargetConfig.JumpParam)
          return
        end
      end
    else
      local success = self.personalZoneVM_.AsyncSetPersonalZoneTitle(self.selectId_, self.cancelSource:CreateToken())
      if success then
        self.currentTitleId_ = self.selectId_
        self.titleLoopScroll_:RefreshListView(self.datas_, false)
        self:refreshInfo()
      end
    end
  end)
  self.titleLoopScroll_ = loopGridView.new(self, self.uiBinder.loopscroll, PersonalZoneTitle, "personalzone_title_tpl")
  self.currentTitleId_ = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  self.selectId_ = self.currentTitleId_
  local profileImageConfigs = self.personalZoneVM_.GetProfileImageList(DEFINE.ProfileImageType.Title)
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
  self.titleLoopScroll_:Init(self.datas_)
  self:refreshInfo()
end

function Personalzone_title_subView:OnDeActive()
  self.titleLoopScroll_:UnInit()
  self.titleLoopScroll_ = nil
  self.personalZoneData_:ClearAddReddotByType(DEFINE.ProfileImageType.Title)
  self.personalZoneVM_.CheckRed()
end

function Personalzone_title_subView:OnRefresh()
end

function Personalzone_title_subView:SetSelect(id)
  self.personalZoneData_:RemovePersonalzoneItem(id)
  self.personalZoneVM_.CheckRed()
  self.selectId_ = id
  for _, data in ipairs(self.datas_) do
    data.select = data.config.Id == self.selectId_
  end
  self.titleLoopScroll_:RefreshListView(self.datas_, false)
  self:refreshInfo()
end

function Personalzone_title_subView:refreshInfo()
  local tagetConfig = self.personalZoneData_:GetProfileImageTarget(self.selectId_)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.selectId_)
  if config == nil then
    return
  end
  self.uiBinder.lab_head_name.text = config.Name
  self.uiBinder.lab_type.text = Z.ContainerMgr.CharSerialize.charBase.name
  local isUnlock = self.personalZoneVM_.CheckProfileImageIsUnlock(self.selectId_)
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
  if self.selectId_ == self.currentTitleId_ then
    self.uiBinder.btn_lock.btn.IsDisabled = true
    self.uiBinder.btn_lock.lab_normal.text = Lang("EnvSkillStateEquiped")
  elseif not isUnlock then
    if tagetConfig and tagetConfig.profileImageTargetConfig then
      if tagetConfig.currentNum < tagetConfig.profileImageTargetConfig.Num then
        if tagetConfig.profileImageTargetConfig.JumpType and tagetConfig.profileImageTargetConfig.JumpType > 0 then
          self.uiBinder.btn_lock.btn.IsDisabled = false
          self.uiBinder.btn_lock.lab_normal.text = Lang("GotoObtain")
        else
          self.uiBinder.btn_lock.btn.IsDisabled = true
          self.uiBinder.btn_lock.lab_normal.text = Lang("InvestigationSelectNotComplete")
        end
      else
        self.uiBinder.btn_lock.btn.IsDisabled = false
        self.uiBinder.btn_lock.lab_normal.text = Lang("UnLock")
      end
    else
      self.uiBinder.btn_lock.btn.IsDisabled = true
      self.uiBinder.btn_lock.lab_normal.text = Lang("InvestigationSelectNotComplete")
    end
  else
    self.uiBinder.btn_lock.btn.IsDisabled = false
    self.uiBinder.btn_lock.lab_normal.text = Lang("ExpressionItemUse")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.selectId_))
  self:refreshExpireTime()
end

function Personalzone_title_subView:refreshExpireTime()
  self.personalZoneVM_.RefreshViewExpireTime(self.selectId_, self.uiBinder, self.uiBinder.lab_expiretime)
end

return Personalzone_title_subView
