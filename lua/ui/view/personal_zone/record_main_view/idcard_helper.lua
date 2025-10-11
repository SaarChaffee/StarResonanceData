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
end

function IDCardHelper:RefreshSelf()
  self:setSelfIDCardImg()
  self:setSelfPlayerInfo()
end

function IDCardHelper:setSelfIDCardImg()
  Z.CoroUtil.create_coro_xpcall(function()
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.rimg_idcard_figure, false)
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_idcard_figure, false)
    if Z.EntityMgr.PlayerEnt == nil then
      logError("PlayerEnt is nil")
      return
    end
    self.vm_.GetGetReviewAvatarInfo(Z.EntityMgr.PlayerEnt.CharId, self.view_.cancelSource, function(textureData)
      self:getSelfIDCardImgCallback(textureData)
    end)
  end)()
end

function IDCardHelper:getSelfIDCardImgCallback(textureData)
  if textureData and textureData.auditing == E.EPictureReviewType.EPictureReviewed and textureData.textureId ~= -1 then
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_idcard_figure, false)
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.rimg_idcard_figure, true)
    self.container_.idcard_popup.rimg_idcard_figure:SetNativeTexture(textureData.textureId)
  else
    self:setModelHalfImg()
  end
end

function IDCardHelper:setModelHalfImg()
  local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  local path = self.snapShotVM_.GetModelHalfPortrait(modelId)
  if path ~= nil then
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_idcard_figure, true)
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.rimg_idcard_figure, false)
    self.container_.idcard_popup.img_idcard_figure:SetImage(path)
    self.container_.idcard_popup.img_idcard_figure:SetNativeSize()
  end
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
  self.container_.idcard_popup.lab_team.text = Lang("IdCardInfo", {
    val1 = Lang("Team"),
    val2 = info
  })
  local playerName = ""
  local playerVM = Z.VMMgr.GetVM("player")
  if playerVM:IsNamed() then
    playerName = Z.ContainerMgr.CharSerialize.charBase.name
  else
    playerName = Lang("EmptyRoleName")
  end
  self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value))
  self.container_.idcard_popup.lab_name.text = playerName
  self.container_.idcard_popup.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  local titleId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  local titleConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
  if titleConfig and titleConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
    self.container_.idcard_popup.lab_gs.text = Lang("IdCardInfo", {
      val1 = Lang("PersonalzoneTitle"),
      val2 = titleConfig.Name
    })
  else
    self.container_.idcard_popup.lab_gs.text = Lang("IdCardInfo", {
      val1 = Lang("PersonalzoneTitle"),
      val2 = Lang("None")
    })
  end
  local lv = Z.ContainerMgr.CharSerialize.roleLevel.level or 1
  self.container_.idcard_popup.lab_lv.text = Lang("RoleLevel", {val = lv})
  local unionName = self.unionVm_:GetPlayerUnionName()
  self.container_.idcard_popup.lab_union.text = Lang("IdCardInfo", {
    val1 = Lang("Union"),
    val2 = unionName == "" and Lang("None") or unionName
  })
  local professionId = self.weaponVm_.GetCurWeapon()
  local professionSystemTableBase = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if professionSystemTableBase then
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_icon_profession_bg, true)
    self.container_.idcard_popup.img_icon_profession:SetImage(professionSystemTableBase.Icon)
  else
    self.container_.idcard_popup.Ref:SetVisible(self.container_.idcard_popup.img_icon_profession_bg, false)
  end
  local idCardId = self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idCardId)
  if config then
    self.container_.idcard_popup.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalCardBg .. config.Image)
    self.container_.idcard_popup.rimg_player_bg:SetImage(Z.ConstValue.PersonalZone.PersonalBg .. config.Image)
  end
  local seasonData = Z.DataMgr.Get("season_title_data")
  local seasonTitleId = seasonData:GetCurRankInfo().curRanKStar
  if seasonTitleId and seasonTitleId ~= 0 then
    local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
    if seasonRankConfig then
      self.container_.idcard_popup.img_armband_icon:SetImage(seasonRankConfig.IconBig)
    end
  end
  local heroDungeonMain = Z.VMMgr.GetVM("hero_dungeon_main")
  if heroDungeonMain.CheckAnyMasterDungeonOpen() then
    local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
    local score = heroDungeonMain.GetPlayerSeasonMasterDungeonScore(seasonId)
    local scoreText = heroDungeonMain.GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
    local master_dungeon_score_text = Lang("MaterDungeonScore") .. scoreText
    if Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.isShow then
      master_dungeon_score_text = Lang("MaterDungeonScore") .. Lang("Hidden")
    end
    self.container_.idcard_popup.lab_score.text = master_dungeon_score_text
  else
    self.container_.idcard_popup.lab_score.text = Lang("MaterDungeonScore") .. Lang("noYet")
  end
  local medals = {}
  local medalCount = 0
  if Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.medals then
    for i = 1, Z.Global.PersonalMedalLimit * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] do
      if Z.ContainerMgr.CharSerialize.personalZone.medals[i] ~= nil and Z.ContainerMgr.CharSerialize.personalZone.medals[i] ~= 0 then
        medalCount = medalCount + 1
        medals[medalCount] = Z.ContainerMgr.CharSerialize.personalZone.medals[i]
        if medalCount == Z.Global.IdCardShowMedalCount then
          break
        end
      end
    end
  end
  local mgr = Z.TableMgr.GetTable("MedalTableMgr")
  for i = 1, Z.Global.IdCardShowMedalCount do
    local img = self.container_.idcard_popup.node_badge["rimg_badge_" .. i]
    if medals[i] == nil then
      self.container_.idcard_popup.node_badge.Ref:SetVisible(img, false)
    else
      self.container_.idcard_popup.node_badge.Ref:SetVisible(img, true)
      local config = mgr.GetRow(medals[i])
      if config then
        img:SetImage(config.Image)
      end
    end
  end
end

return IDCardHelper
