local UI = Z.UI
local super = require("ui.ui_view_base")
local Main_upgrade_windowView = class("Main_upgrade_windowView", super)

function Main_upgrade_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_upgrade_window", "main/main_upgrade_window", true)
  self.anim_name_ = "anim_main_upgrade_window_open"
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.roleLevelData_ = Z.DataMgr.Get("role_level_data")
  self.roleLevelVM_ = Z.VMMgr.GetVM("rolelevel_main")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function Main_upgrade_windowView:OnActive()
  Z.AudioMgr:Play("UI_Event_Magic_B")
end

function Main_upgrade_windowView:OnDeActive()
  self:clearUpgradeTimer()
end

function Main_upgrade_windowView:OnRefresh()
  self:SetUIVisible(self.uiBinder.trans_info, false)
  self:SetUIVisible(self.uiBinder.trans_icon, false)
  self:SetUIVisible(self.uiBinder.lab_normal_desc, false)
  if self.viewData.ProfessionUpgrade then
    local professionConfig = Z.TableMgr.GetRow("LifeProfessionTableMgr", self.viewData.ProfessionId)
    if professionConfig then
      self:SetUIVisible(self.uiBinder.trans_icon, true)
      self.uiBinder.img_icon:SetImage(professionConfig.LevelUpIcon)
      if self.viewData.ProfessionLevel == 1 then
        self.uiBinder.lab_desc.text = Lang("LifeProfessionUnlock", {
          name = professionConfig.Name
        })
      else
        self.uiBinder.lab_desc.text = Lang("ProfessionUpgradeDesc", {
          profession = professionConfig.Name,
          level = self.viewData.ProfessionLevel
        })
      end
    end
  elseif self.viewData.normalShow then
    self:SetUIVisible(self.uiBinder.lab_normal_desc, true)
    self:SetUIVisible(self.uiBinder.img_line_1, false)
    self:SetUIVisible(self.uiBinder.img_line_2, false)
    self:SetUIVisible(self.uiBinder.lab_name_1, false)
    self:SetUIVisible(self.uiBinder.lab_name_2, true)
    self:SetUIVisible(self.uiBinder.lab_name_3, false)
    self.uiBinder.lab_desc.text = self.viewData.title
    self.uiBinder.lab_normal_desc.text = self.viewData.labDesc
  else
    local curLevel = self.roleLevelData_:GetRoleLevel()
    local levelConfig = Z.TableMgr.GetRow("PlayerLevelTableMgr", curLevel)
    self.uiBinder.lab_desc.text = Lang("LevelUpgradeDesc", {level = curLevel})
    local isShowAttr = levelConfig.LevelUpAttr and next(levelConfig.LevelUpAttr) ~= nil
    local isShowTalent = levelConfig.TalentAward ~= 0
    local isShowGift = levelConfig.LevelAwardID ~= 0
    local totalCount = 0
    if isShowAttr then
      totalCount = totalCount + 1
    end
    if isShowTalent then
      totalCount = totalCount + 1
    end
    if isShowGift then
      totalCount = totalCount + 1
    end
    self:SetUIVisible(self.uiBinder.trans_info, 0 < totalCount)
    self:SetUIVisible(self.uiBinder.img_line_1, 1 < totalCount)
    self:SetUIVisible(self.uiBinder.img_line_2, 2 < totalCount)
    self:SetUIVisible(self.uiBinder.lab_name_1, isShowAttr)
    self:SetUIVisible(self.uiBinder.lab_name_2, isShowTalent)
    self:SetUIVisible(self.uiBinder.lab_name_3, isShowGift)
  end
  local token = self.cancelSource:CreateToken()
  self.commonVM_.CommonPlayAnim(self.uiBinder.anim, self.anim_name_, token, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function Main_upgrade_windowView:clearUpgradeTimer()
  if self.upgradeTimer_ then
    self.upgradeTimer_:Stop()
    self.upgradeTimer_ = nil
  end
end

return Main_upgrade_windowView
