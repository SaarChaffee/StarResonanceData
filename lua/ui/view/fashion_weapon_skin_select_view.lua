local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_weapon_skin_selectView = class("Fashion_weapon_skin_selectView", super)
local loopGridView = require("ui.component.loop_grid_view")
local style_icon_item = require("ui.component.fashion.style_icon_loop_item")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")

function Fashion_weapon_skin_selectView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fashion_weapon_skin_select_sub", "fashion/fashion_style_select_sub", nil, true)
  self.parentView_ = parent
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.weaponSkillSkinVm_ = Z.VMMgr.GetVM("weapon_skill_skin")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function Fashion_weapon_skin_selectView:SelectStyle(styleData)
  self.parentView_:SetLuaIntModelAttr(Z.ModelAttr.EModelDisplayWeaponSkinId, styleData.fashionId)
  self.style_ = styleData.fashionId
  self.fashionData_:SetWear(self.region_, styleData)
  self.selectWeaponSkinId_ = styleData.fashionId
  self:refreshFashionDetail()
  Z.EventMgr:Dispatch(Z.ConstValue.GM.GMItemView, styleData.fashionId)
end

function Fashion_weapon_skin_selectView:UnSelectStyle()
  local equipWeaponSkinId = self.weaponSkillSkinVm_:GetWeaponSkinId(self.curProfessionId_)
  self.parentView_:SetLuaIntModelAttr(Z.ModelAttr.EModelDisplayWeaponSkinId, equipWeaponSkinId)
  self.style_ = 0
  self.selectWeaponSkinId_ = 0
  self.fashionData_:SetWear(self.region_, nil)
  self:refreshFashionDetail()
end

function Fashion_weapon_skin_selectView:GetCurRegion()
  return self.region_
end

function Fashion_weapon_skin_selectView:OnActive()
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetWidth(Z.IsPCUI and 316 or 424)
  self.styleScrollRect_ = loopGridView.new(self, self.uiBinder.loop_item, style_icon_item, "fashion_item_square_3_8", true)
  self.styleScrollRect_:Init({})
  self.region_ = self.viewData.region
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_icon, false)
  self:AddClick(self.uiBinder.btn_go_source, function()
    self:goFashionSource(self.sourceData_)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_customized, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_collection, false)
  self.parentView_:ShowSaveBtn()
  self:BindEvents()
end

function Fashion_weapon_skin_selectView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionWearRevert, self.OnRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkinChange, self.OnRefresh, self)
end

function Fashion_weapon_skin_selectView:OnRefresh()
  self.region_ = self.viewData.region
  self.dataList_ = {}
  self.styleScrollRect_:ClearAllSelect()
  if self.viewData.professionId == nil or self.viewData.professionId == 0 then
    self.curProfessionId_ = self.weaponVm_.GetCurWeapon()
  else
    self.curProfessionId_ = self.viewData.professionId
  end
  if self.curProfessionId_ ~= self.weaponVm_.GetCurWeapon() then
    local professionSysRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.curProfessionId_)
    if professionSysRow then
      self.uiBinder.lab_tips.text = string.format(Lang("weapon_skin_tips"), professionSysRow.Name)
    end
  else
    self.uiBinder.lab_tips.text = ""
  end
  self.fashionData_:SetSelectProfessionId(self.curProfessionId_)
  local weaponSkinData = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetDatas()
  for _, value in pairs(weaponSkinData) do
    if value.ProfessionId == self.curProfessionId_ and value.IsOpen then
      local uuid_
      local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Weapon]
      for uuid__, item in pairs(package.items) do
        local itemRow = itemTbl.GetRow(item.configId)
        if itemRow and value.Id == itemRow.Id then
          uuid_ = uuid__
          break
        end
      end
      local data = {
        fashionId = value.Id,
        isUnlock = uuid_ ~= nil,
        wearFashionId = value.Id,
        uuid = uuid_,
        sortId = value.SortID,
        isEmpty = value.Original == 1
      }
      table.insert(self.dataList_, data)
    end
  end
  table.sort(self.dataList_, function(a, b)
    if a.isEmpty and not b.isEmpty then
      return true
    elseif b.isEmpty and not a.isEmpty then
      return false
    end
    if a.uuid and not b.uuid then
      return true
    elseif not a.uuid and b.uuid then
      return false
    end
    return a.sortId < b.sortId
  end)
  self.styleScrollRect_:RefreshListView(self.dataList_, false)
  self:refreshCurWearFashion()
end

function Fashion_weapon_skin_selectView:OnDeActive()
  self.region_ = nil
  self.dataList_ = nil
  self.selectWeaponSkinId_ = nil
  self.styleScrollRect_:UnInit()
  self.styleScrollRect_ = nil
  self.parentView_:SetLuaIntModelAttr(Z.ModelAttr.EModelDisplayWeaponSkinId, 0)
  self.uiBinder.lab_tips.text = ""
end

function Fashion_weapon_skin_selectView:refreshCurWearFashion()
  local tryonStyleData = self.fashionData_:GetWear(self.region_)
  local equipWeaponSkinId = tryonStyleData and tryonStyleData.fashionId or self.weaponSkillSkinVm_:GetWeaponSkinId(self.curProfessionId_)
  self.styleScrollRect_:ClearAllSelect()
  local selectIndex = 1
  for i, data in ipairs(self.dataList_) do
    if data.fashionId == equipWeaponSkinId then
      selectIndex = i
      break
    end
  end
  self.styleScrollRect_:SelectIndex(selectIndex - 1)
end

function Fashion_weapon_skin_selectView:refreshFashionDetail()
  if self.selectWeaponSkinId_ ~= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_detail, true)
    local itemRow = itemTbl.GetRow(self.selectWeaponSkinId_)
    if itemRow then
      self.uiBinder.lab_name.text = itemRow.Name
      local sourceData = self.itemSourceVm_.GetItemSource(self.selectWeaponSkinId_)
      if sourceData and 0 < #sourceData then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquire_entry, true)
        self.sourceData_ = sourceData[1]
        self.uiBinder.lab_source.text = string.format(Lang("FashionSource"), self.sourceData_.name)
        self.uiBinder.img_icon:SetImage(self.sourceData_.icon)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquire_entry, false)
      end
    end
    local row = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(self.selectWeaponSkinId_, true)
    if row and 0 < row.Score and Z.StageMgr.GetIsInGameScene() then
      self.uiBinder.lab_score.text = row.Score
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_score, true)
    else
      self.uiBinder.lab_score.text = ""
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_score, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_detail, false)
    self.uiBinder.lab_score.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_score, false)
  end
end

function Fashion_weapon_skin_selectView:goFashionSource(sourceData)
  if not sourceData then
    return
  end
  local tipsId = self.viewData.tipsId
  local jumpType = self.itemSourceVm_.JumpToSource(sourceData)
  if jumpType ~= E.QuickJumpType.Message and tipsId ~= nil then
    Z.TipsVM.CloseItemTipsView(tipsId)
  end
end

return Fashion_weapon_skin_selectView
