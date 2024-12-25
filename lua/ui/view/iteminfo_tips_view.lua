local UI = Z.UI
local super = require("ui.ui_subview_base")
local Iteminfo_tipsView = class("Iteminfo_tipsView", super)
local quality_img_top_ = "ui/atlas/tips/common_img_tipsquality_top_"
local quality_img_tipsbg2_ = "ui/atlas/tips/common_img_tipsquality_second_"

function Iteminfo_tipsView:ctor()
  self.panel = nil
  super.ctor(self, "tips_iteminfo_tips", "tips/tips_iteminfo_tips", UI.ECacheLv.None)
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.equipAttrParseVm_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.viewData = nil
end

function Iteminfo_tipsView:OnActive()
  self:startAnimatedShow()
  self:AddClick(self.panel.con_information.btn_add.Btn, function()
    Z.TipsVM.ShowTipsLang(100102)
  end)
  local containGoEvent = self.panel.autoPos.PressCheck.ContainGoEvent
  self:EventAddAsyncListener(containGoEvent, function(isContainer)
    if not isContainer then
      Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
    end
  end, nil, nil)
end

function Iteminfo_tipsView:OnRefresh()
  if not self.viewData.isOpen then
    return
  end
  if not self.viewData.isResident then
    self.panel.autoPos.PressCheck:StartCheck()
  end
  self.panel.con_information.lab_count:SetVisible(true)
  if not self.viewData.showType or self.viewData.showType == E.EItemTipsShowType.Default then
    self.siblingIndex_ = -1
    self.siblingIndexs_ = {}
    self:refreshDefaultTips()
  else
    self:refreshClientUi(self.viewData.configId)
    self.panel.con_information.lab_count:SetVisible(false)
  end
  if self.viewData and self.viewData.isShowBg then
    self.panel.con_information.bg:SetVisible(true)
  else
    self.panel.con_information.bg:SetVisible(false)
  end
  self.panel.con_information.scroll_describe.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.Ref:ForceRebuildLayoutImmediate()
  self:updatePos()
end

function Iteminfo_tipsView:updatePos()
  if self.viewData.posType == E.EItemTipsPopType.Bounds then
    self.panel.autoPos.AdaptPos:UpdatePosition(self.viewData.parentTrans, true)
  elseif self.viewData.posType == E.EItemTipsPopType.WorldPosition then
    self.panel.autoPos.AdaptPos:UpdatePosition(self.viewData.parentTrans.position)
  end
end

function Iteminfo_tipsView:refreshDefaultTips()
  self.itemInfo_ = self.itemsVm_.GetItemInfobyItemId(self.viewData.itemUuid, self.viewData.configId)
  self.panel.con_information.lab_count.TMPLab.text = Lang("Count") .. ": " .. self.itemInfo_.count
  self:refreshClientUi(self.itemInfo_.configId, self.itemInfo_.quality)
  local itemTableData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemInfo_.configId)
  if itemTableData then
    self:setlimit(itemTableData)
  end
  if self.itemsVm_.CheckPackageTypeByConfigId(self.itemInfo_.configId, E.BackPackItemPackageType.Equip) then
    self:refreshEquipTips()
  else
    self:refreshItemTips()
  end
end

function Iteminfo_tipsView:refreshClientUi(configId, quality)
  local itemTableData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemTableData == nil then
    return
  end
  local itemTypeData = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemTableData.Type)
  self.panel.con_information.limit_content.expiry_date:SetVisible(false)
  self.panel.con_information.limit_content.surplus_time:SetVisible(false)
  self.panel.con_information.lab_name.TMPLab.text = itemTableData.Name
  local itemsVM = Z.VMMgr.GetVM("items")
  self.panel.con_information.img_icon.Img:SetImage(itemsVM.GetItemIcon(configId))
  quality = quality or itemTableData.Quality
  self.panel.con_information.img_top.Img:SetImage(quality_img_top_ .. quality)
  self.panel.con_information.img_tipsbg2.Img:SetImage(quality_img_tipsbg2_ .. quality)
  self.panel.con_information.img_tips_equip:SetVisible(false)
  if itemTypeData then
    self.panel.con_information.lab_type.TMPLab.text = itemTypeData.Name
  end
  self.panel.con_information.lab_des.TMPLab.text = string.zreplace(itemTableData.Description, "<br>", "\n")
  self.panel.con_information.layout_name.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.layout_baseinfocontent.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.equip_base_arr:SetVisible(false)
  self.panel.con_information.equip_special_arr:SetVisible(false)
  self.panel.con_information.equip_gs:SetVisible(false)
  self.panel.con_information.layout_des_content.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.Ref:ForceRebuildLayoutImmediate()
end

function Iteminfo_tipsView:refreshEquipTips()
  self.panel.con_information.equip_base_arr:SetVisible(true)
  self.panel.con_information.equip_special_arr:SetVisible(true)
  self.panel.con_information.equip_gs:SetVisible(true)
  local gs = self.equipVm_.GetEquipGsByConfigId(self.itemInfo_.configId)
  self.panel.con_information.equip_gs.TMPLab.text = Lang("GSEqual", {val = gs})
  if self.viewData.data and self.viewData.data.GsState and self.viewData.data.GsState ~= 0 then
    self.panel.con_information.img_gsup:SetVisible(self.viewData.data.GsState > 0)
    self.panel.con_information.img_gsdown:SetVisible(self.viewData.data.GsState < 0)
  else
    self.panel.con_information.img_gsup:SetVisible(false)
    self.panel.con_information.img_gsdown:SetVisible(false)
  end
  local equipInfo = self.equipVm_.GetSamePartEquipAttr(self.itemInfo_.configId)
  if equipInfo and equipInfo.itemUuid == self.itemInfo_.uuid then
    self.panel.con_information.img_tips_equip:SetVisible(true)
  else
    self.panel.con_information.img_tips_equip:SetVisible(false)
  end
  self.panel.con_information.lab_count.TMPLab.text = ""
  local cancelToken = self.cancelSource:CreateToken()
  self:SetVisible(false)
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncSetEquipBaseArr(cancelToken)
    self:asyncSetEquipSpecialArr(cancelToken)
  end)()
  self.panel.con_information.layout_des_content.ZLayout:ForceRebuildLayoutImmediate()
  self:SetVisible(true)
end

function Iteminfo_tipsView:refreshItemTips()
  self.panel.con_information.lab_count:SetVisible(true)
  self.panel.con_information.lab_count.TMPLab.text = Lang("Count") .. ": " .. self.itemInfo_.count
end

function Iteminfo_tipsView:setlimit(itemTableData)
  self.panel.con_information.limit_content.expiry_date:SetVisible(false)
  self.panel.con_information.limit_content.surplus_time:SetVisible(false)
  local timeLimt
  if itemTableData.TimeType == 0 then
  elseif itemTableData.TimeType ~= 4 then
    self.panel.con_information.limit_content.expiry_date:SetVisible(0 < self.itemInfo_.expireTime)
    local timeStrYMD = Z.TimeTools.FormatTimeToYMD(self.itemInfo_.expireTime)
    local timeStrHMS = Z.TimeTools.FormatTimeToHMS(self.itemInfo_.expireTime)
    local str = string.format("%s %s", timeStrYMD, timeStrHMS)
    local param = {str = str}
    if self.itemInfo_.invalid == 1 then
      timeLimt = Lang("Tips_TimeLimit_InValid", param)
      self.panel.con_information.limit_content.lab_period.TMPLab.text = timeLimt
    else
      timeLimt = Lang("Tips_TimeLimit_Valid", param)
      self.panel.con_information.limit_content.lab_period.TMPLab.text = timeLimt
    end
  else
    if self.itemInfo_.invalid then
    else
    end
  end
  self.panel.con_information.limit_content.layout_limit.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.layout_des_content.ZLayout:ForceRebuildLayoutImmediate()
end

function Iteminfo_tipsView:asyncSetEquipBaseArr(cancelToken)
  local equipAttr = self.itemInfo_.equipAttr
  local tipsStrTab = self.equipAttrParseVm_.GetEquipBaseAttrTips(equipAttr)
  if not tipsStrTab then
    return
  end
  if self.equipBaseArrUnits_ then
    for key, value in pairs(self.equipBaseArrUnits_) do
      self:RemoveUiUnit(value.Name)
    end
  end
  self.equipBaseArrUnits_ = {}
  local parentTran = self.panel.con_information.equip_base_arr.Trans
  local index = 0
  for _, value in ipairs(tipsStrTab) do
    local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr), "baseAttrInfo" .. index, parentTran)
    if self.cancelSource:CancelToken(cancelToken) then
      return
    end
    if unit then
      table.insert(self.equipBaseArrUnits_, unit)
      unit.lab_info.TMPLab.text = value
      self.equipAttrParseVm_.SetEquipExternAttrTipsImgColor(unit.btn_on, E.AttrTipsColorTag.AttrGray)
      unit.Ref:ForceRebuildLayoutImmediate()
    end
    index = index + 1
  end
  self.panel.con_information.equip_base_arr.layout_base.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.layout_des_content.ZLayout:ForceRebuildLayoutImmediate()
end

function Iteminfo_tipsView:asyncSetEquipSpecialArr(cancelToken)
  local equipAttr = self.itemInfo_.equipAttr
  local tipsStrTab
  if not tipsStrTab then
    return
  end
  local parentTran = self.panel.con_information.equip_special_arr.Trans
  local index = 0
  if not tipsStrTab or not next(tipsStrTab) then
    self.panel.con_information.equip_special_arr.Ref:SetVisible(false)
  else
    self.panel.con_information.equip_special_arr.Ref:SetVisible(true)
  end
  for _, value in ipairs(tipsStrTab) do
    local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr), "specialAttrInfo" .. index, parentTran)
    if self.cancelSource:CancelToken(cancelToken) then
      return
    end
    if unit then
      table.insert(self.equipBaseArrUnits_, unit)
      unit.lab_info.TMPLab.text = value.tip
      self.equipAttrParseVm_.SetEquipExternAttrTipsImgColor(unit.btn_on, value.colorType)
      unit.lab_info.ZLayout:ForceRebuildLayoutImmediate()
    end
    index = index + 1
  end
  self.panel.con_information.equip_special_arr.layout_special.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.con_information.layout_des_content.ZLayout:ForceRebuildLayoutImmediate()
end

function Iteminfo_tipsView:OnDeActive()
  self.panel.autoPos.PressCheck:StopCheck()
  self:SetVisible(true)
  self.showCeFlag_ = false
  self.equipBaseArrUnits_ = nil
end

function Iteminfo_tipsView:startAnimatedShow()
  self.panel.anim.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Iteminfo_tipsView:startAnimatedHide()
  self.panel.anim.anim:PlayOnce("anim_iteminfo_tips_002")
end

return Iteminfo_tipsView
