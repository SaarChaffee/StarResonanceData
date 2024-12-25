local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_skin_subView = class("Weapon_skin_subView", super)
local loopScrollRect_ = require("ui/component/loopscrollrect")
local weaponSkinItem_ = require("ui/component/weapon/weapon_skin_loop_item")

function Weapon_skin_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_skin_sub", "weapon_develop/weapon_skin_sub", UI.ECacheLv.None)
end

function Weapon_skin_subView:OnActive()
  self:startAnimatedShow()
  self.professionId_ = self.viewData.weaponId
  self.selectSkinId_ = nil
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.weaponLoop_ = loopScrollRect_.new(self.uiBinder.skin_loop, self, weaponSkinItem_)
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_replace, function()
    if self.weaponVm_.CheckWeaponSkinEquip(self.professionId_, self.selectSkinId_) then
      return
    end
    if not self.weaponVm_.CheckWeaponSkinUnlock(self.selectSkinId_) then
      Z.TipsVM.ShowTipsLang(3071)
      return
    end
    self.weaponVm_.AsyncUseWeaponSkin(self.professionId_, self.selectSkinId_, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_job, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(10014)
  end)
  self:BindEventWatchers()
  self:refreshSkinLoop()
  self:refreshWeaponInfo()
end

function Weapon_skin_subView:BindEventWatchers()
  function self.onSkinContainerChanged(container, dirty)
    if dirty.skinList then
      self:refreshSkinLoop()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onSkinContainerChanged)
end

function Weapon_skin_subView:refreshWeaponInfo()
  local weaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.professionId_)
  self.uiBinder.lab_name.text = weaponConfig.Name
  self.uiBinder.job_icon:SetImage(GetLoadAssetPath("WepaonElementIconPath_" .. weaponConfig.Element))
  local talentTags = {
    [1] = self.uiBinder.btn_choose01,
    [2] = self.uiBinder.btn_choose02,
    [3] = self.uiBinder.btn_choose03
  }
  for _, value in ipairs(talentTags) do
    value.Ref:SetVisible(value.img_on, false)
    value.Ref:SetVisible(value.img_off, false)
    self.uiBinder.Ref:SetVisible(value.Ref, false)
  end
  for index, value in ipairs(weaponConfig.Talent) do
    local talentConfig = Z.TableMgr.GetTable("TalentTagTableMgr").GetRow(value)
    if talentConfig then
      do
        local container = talentTags[index]
        self.uiBinder.Ref:SetVisible(container.Ref, true)
        container.Ref:SetVisible(container.img_off, true)
        container.img_icon_on:SetImage(talentConfig.TagIconMark)
        container.img_icon_off:SetImage(talentConfig.TagIconMark)
        self:AddClick(container.btn, function()
          Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, talentConfig.TagName, talentConfig.DetailsDes)
        end)
      end
    end
  end
  talentTags[1].Ref:SetVisible(talentTags[1].img_on, true)
end

function Weapon_skin_subView:refreshSkinLoop()
  local allSkinInfo = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetDatas()
  local skinDatas = {}
  for _, value in pairs(allSkinInfo) do
    if value.ProfessionId == self.professionId_ then
      local data = {
        weaponId = self.professionId_,
        skinCfg = value
      }
      table.insert(skinDatas, data)
    end
  end
  self.skinsCount_ = #skinDatas
  table.sort(skinDatas, function(a, b)
    return a.skinCfg.Id < b.skinCfg.Id
  end)
  local select = 0
  local equipSkinId = self.weaponVm_.GetWeaponSkinId(self.professionId_)
  for index, value in ipairs(skinDatas) do
    if value.skinCfg.Id == equipSkinId then
      select = index - 1
    end
  end
  self.weaponLoop_:ClearCells()
  self.weaponLoop_:SetData(skinDatas, false, false, 0)
  self.weaponLoop_:SetSelected(select)
end

function Weapon_skin_subView:onWeaponSkillItemSelect(skinId, index)
  self.selectSkinId_ = skinId
  self:refreshWeaponSkinInfo(skinId, index)
  Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkinChange, skinId)
end

function Weapon_skin_subView:refreshWeaponSkinInfo(skinId, index)
  local skinInfo = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(skinId)
  self.uiBinder.lab_desc.text = skinInfo.Intro
  self.uiBinder.lab_title.text = skinInfo.Name
  self.uiBinder.lab_num.text = string.zconcat(index, "/", self.skinsCount_)
  local equip = self.weaponVm_.CheckWeaponSkinEquip(self.professionId_, skinId)
  if equip then
    self.uiBinder.btn_replace_binder.lab_content.text = Lang("inEquip")
    self.uiBinder.btn_replace.IsDisabled = true
  else
    self.uiBinder.btn_replace.IsDisabled = false
    self.uiBinder.btn_replace_binder.lab_content.text = Lang("Replace")
  end
end

function Weapon_skin_subView:OnDeActive()
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onSkinContainerChanged)
  self.onSkinContainerChanged = nil
  self:startAnimatedHide()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

function Weapon_skin_subView:OnRefresh()
end

function Weapon_skin_subView:startAnimatedShow()
  self.uiBinder.main_anim:Restart(Z.DOTweenAnimType.Open)
end

function Weapon_skin_subView:startAnimatedHide()
  self.uiBinder.main_anim:Restart(Z.DOTweenAnimType.Close)
end

return Weapon_skin_subView
