local WeaponHeroProfessionTitle = class("WeaponHeroProfessionTitle")
local HeroHelper = require("ui.component.hero_helper")
local WeaponHeroProfessionBg = {
  [0] = "WeaponHeroProfessionBg_0",
  [1] = "WeaponHeroProfessionBg_1",
  [2] = "WeaponHeroProfessionBg_2",
  [3] = "WeaponHeroProfessionBg_3",
  [4] = "WeaponHeroProfessionBg_4",
  [5] = "WeaponHeroProfessionBg_5",
  [6] = "WeaponHeroProfessionBg_6"
}
local WeaponHeroProfessionJobGray = {
  [1] = "WeaponHeroProfessionJobGray_1",
  [2] = "WeaponHeroProfessionJobGray_2",
  [3] = "WeaponHeroProfessionJobGray_3"
}

function WeaponHeroProfessionTitle:ctor()
end

function WeaponHeroProfessionTitle:Init(container, onclick)
  self.container_ = container
end

function WeaponHeroProfessionTitle:Refresh(profeeesionId, heroId1, heroId2, emptyHead)
  self.professionId_ = profeeesionId
  self.Active = false
  local professionConfig = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(self.professionId_)
  if professionConfig == nil then
    return
  end
  if heroId1 == nil then
    heroId1 = 0
  end
  if heroId2 == nil then
    heroId2 = 0
  end
  local jobs = {0, 0}
  local heros = {heroId1, heroId2}
  for index, value in ipairs(heros) do
    if value ~= 0 then
      local config = Z.TableMgr.GetTable("HeroTableMgr").GetRow(value)
      if config == nil then
        return
      end
      jobs[index] = config.Job
    end
  end
  local job1 = professionConfig.Job[1][1]
  local job2 = professionConfig.Job[1][2]
  local port1 = 0
  for index, value in ipairs(jobs) do
    if value ~= 0 and job1 == value then
      port1 = heros[index]
      jobs[index] = 0
      break
    end
  end
  local port2 = 0
  for index, value in ipairs(jobs) do
    if value ~= 0 and job2 == value then
      port2 = heros[index]
      jobs[index] = 0
      break
    end
  end
  if port1 ~= 0 then
    local config = Z.TableMgr.GetTable("HeroTableMgr").GetRow(port1)
    if config == nil then
      return
    end
    self.container_.node_list.img_empty_bg_1:SetVisible(false)
    self.container_.node_list.img_head_1:SetVisible(true)
    self.container_.node_list.img_head_1.img_head:SetVisible(true)
    self.container_.node_list.img_head_1.img_head.Img:SetImage(config.Image)
    self.container_.node_list.img_job_icon_1.Img:SetColorByHex(E.ColorHexValues.JobActive)
    self.container_.node_list.img_job_icon_1.Img:SetImage(HeroHelper.GetProfessionJob(job1))
  else
    if not emptyHead then
      self.container_.node_list.img_head_1:SetVisible(true)
      self.container_.node_list.img_head_1.img_empty:SetVisible(true)
      self.container_.node_list.img_head_1.img_head:SetVisible(false)
    else
      self.container_.node_list.img_head_1:SetVisible(false)
    end
    self.container_.node_list.img_empty_bg_1:SetVisible(true)
    self.container_.node_list.img_job_icon_1.Img:SetColorByHex(E.ColorHexValues.JobNotActive)
    self.container_.node_list.img_job_icon_1.Img:SetImage(HeroHelper.GetProfessionJob(job1))
  end
  if port2 ~= 0 then
    local config = Z.TableMgr.GetTable("HeroTableMgr").GetRow(port2)
    if config == nil then
      return
    end
    self.container_.node_list.img_empty_bg_2:SetVisible(false)
    self.container_.node_list.img_head_2:SetVisible(true)
    self.container_.node_list.img_head_2.img_head:SetVisible(true)
    self.container_.node_list.img_head_2.img_head.Img:SetImage(config.Image)
    self.container_.node_list.img_job_icon_2.Img:SetColorByHex(E.ColorHexValues.JobActive)
    self.container_.node_list.img_job_icon_2.Img:SetImage(HeroHelper.GetProfessionJob(job2))
  else
    if not emptyHead then
      self.container_.node_list.img_head_2:SetVisible(true)
      self.container_.node_list.img_head_2.img_empty:SetVisible(true)
      self.container_.node_list.img_head_2.img_head:SetVisible(false)
    else
      self.container_.node_list.img_head_2:SetVisible(false)
    end
    self.container_.node_list.img_empty_bg_2:SetVisible(true)
    self.container_.node_list.img_job_icon_2.Img:SetColorByHex(E.ColorHexValues.JobNotActive)
    self.container_.node_list.img_job_icon_2.Img:SetImage(HeroHelper.GetProfessionJob(job2))
  end
  self.container_.node_list.img_state.Img:SetImage(GetLoadAssetPath(WeaponHeroProfessionBg[self.professionId_]))
  self.container_.node_list.img_profession_icon.Img:SetImage(professionConfig.Icon)
  local professionName = Z.RichTextHelper.ApplyStyleTag(professionConfig.Name, E.TextStyleTag.AccentGreen)
  self.container_.lab_info.TMPLab.text = professionName .. "\239\188\154" .. professionConfig.TipsDescription
  if port1 ~= 0 and port2 ~= 0 then
    self.Active = true
  end
  self.container_.node_list.img_arrow_on:SetVisible(self.Active)
  self.container_.node_list.img_arrow_off:SetVisible(not self.Active)
end

function WeaponHeroProfessionTitle:SetStateBgVisible()
  if not self.Active then
    self.container_.node_list.img_state.Img:SetImage(GetLoadAssetPath(WeaponHeroProfessionBg[0]))
    self.container_.node_list.img_profession_icon.Img:SetImage(HeroHelper.GetProfessionIconGray(self.professionId_))
  end
end

function WeaponHeroProfessionTitle:AddClick()
end

function WeaponHeroProfessionTitle:SetArrorVisible(visible)
  self.container_.node_list.img_arrow_on:SetVisible(visible)
  self.container_.node_list.img_arrow_off:SetVisible(not visible)
end

return WeaponHeroProfessionTitle
