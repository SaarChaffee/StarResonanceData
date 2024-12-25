local IDCardHelper = class("IDCardHelper")
local MEDAL_PATH = {
  "ui/prefabs/personalzone/personalzone_medal_show_01_tpl",
  "ui/prefabs/personalzone/personalzone_medal_show_02_tpl",
  "ui/prefabs/personalzone/personalzone_medal_show_03_tpl"
}
local DEFINE = require("ui.model.personalzone_define")

function IDCardHelper:ctor(view, container)
  self.view_ = view
  self.container_ = container
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.snapShotVM_ = Z.VMMgr.GetVM("snapshot")
  self.unionVm_ = Z.VMMgr.GetVM("union")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.vm_ = Z.VMMgr.GetVM("idcard")
end

function IDCardHelper:SetIDCardBg(path, playerPath, color)
  self.container_.idcard_popup.rimg_bg:SetImage(path)
  self.container_.idcard_popup.rimg_player_bg:SetImage(playerPath)
  self.container_.idcard_popup.img_left:SetColorByHex(color)
  self.container_.idcard_popup.img_right:SetColorByHex(color)
  self.container_.idcard_popup.img_armband_bg_1:SetColorByHex(color)
  self.container_.idcard_popup.img_armband_bg_2:SetColorByHex(color)
  self.container_.idcard_popup.img_lv_num_bg:SetColorByHex(color)
  self.container_.idcard_popup.img_diamond_gs:SetColorByHex(color)
  self.container_.idcard_popup.img_diamond_uniom:SetColorByHex(color)
  self.container_.idcard_popup.img_diamond_team:SetColorByHex(color)
end

function IDCardHelper:RefreshSelf()
  self:setSelfIDCardImg()
  self:setSelfPlayerInfo()
end

function IDCardHelper:setSelfIDCardImg()
  Z.CoroUtil.create_coro_xpcall(function()
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.rimg_idcard_figure, false)
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_idcard_figure, false)
    local textureData = self.vm_.GetGetReviewAvatarInfo(Z.EntityMgr.PlayerEnt.EntId, self.view_.cancelSource:CreateToken())
    if textureData and textureData.auditing == E.EPictureReviewType.EPictureReviewed then
      self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_idcard_figure, false)
      self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.rimg_idcard_figure, true)
      self.container_.idcard_popup.rimg_idcard_figure:SetNativeTexture(textureData.textureId)
    else
      local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
      local path = self.snapShotVM_.GetModelHalfPortrait(modelId)
      if path ~= nil then
        self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_idcard_figure, true)
        self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.rimg_idcard_figure, false)
        self.container_.idcard_popup.img_idcard_figure:SetImage(path)
        self.container_.idcard_popup.img_idcard_figure:SetNativeSize()
      end
    end
  end)()
end

function IDCardHelper:setSelfPlayerInfo()
  local info = Lang("None")
  if Z.ContainerMgr.CharSerialize.charBase.teamInfo then
    local teamId = Z.ContainerMgr.CharSerialize.charBase.teamInfo.teamId
    if teamId ~= 0 then
      local teamTargetData = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(Z.ContainerMgr.CharSerialize.charBase.teamInfo.teamTargetId)
      if teamTargetData then
        local targetName = teamTargetData.Name
        info = targetName .. " " .. Z.ContainerMgr.CharSerialize.charBase.teamInfo.teamNum .. "/" .. "4"
      end
    end
  end
  self.container_.idcard_popup.lab_team.text = Lang("Team") .. Lang(":") .. info
  local playerName = ""
  local playerVM = Z.VMMgr.GetVM("player")
  if playerVM:IsNamed() then
    playerName = Z.ContainerMgr.CharSerialize.charBase.name
  end
  self.container_.idcard_popup.lab_name.text = playerName
  self.container_.idcard_popup.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  local titleId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  local titleConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
  if titleConfig and titleConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
    self.container_.idcard_popup.lab_gs.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), titleConfig.Name)
  else
    self.container_.idcard_popup.lab_gs.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), Lang("None"))
  end
  local lv = Z.ContainerMgr.CharSerialize.roleLevel.level or 1
  self.container_.idcard_popup.lab_lv_num.text = lv
  local unionName = self.unionVm_:GetPlayerUnionName()
  self.container_.idcard_popup.lab_union.text = string.format("%s\239\188\154%s", Lang("Union"), unionName == "" and Lang("None") or unionName)
  local professionId = self.weaponVm_.GetCurWeapon()
  local professionSystemTableBase = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if professionSystemTableBase then
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_icon_talent_bg, true)
    self.container_.idcard_popup.img_icon_talent:SetImage(professionSystemTableBase.Icon)
  else
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_icon_talent_bg, false)
  end
  local idCardId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idCardId)
  if config then
    self.container_.idcard_popup.rimg_bg:SetImage(config.Image2)
    self.container_.idcard_popup.rimg_player_bg:SetImage(config.ImagePlayer)
    self.container_.idcard_popup.img_left:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_right:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_armband_bg_1:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_armband_bg_2:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_lv_num_bg:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_diamond_gs:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_diamond_uniom:SetColorByHex(config.Color)
    self.container_.idcard_popup.img_diamond_team:SetColorByHex(config.Color)
  end
  local seasonData = Z.DataMgr.Get("season_title_data")
  local seasonTitleId = seasonData:GetCurRankInfo().curRanKStar
  if seasonTitleId and seasonTitleId ~= 0 then
    local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
    if seasonRankConfig then
      self.container_.idcard_popup.img_armband_icon:SetImage(seasonRankConfig.IconBig)
    end
  end
end

return IDCardHelper
