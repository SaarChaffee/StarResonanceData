local super = require("ui.ui_view_base")
local PersonalZoneMedalMain = class("PersonalZoneMedalMain", super)
local CELL_SIZE = 188
local MEDAL_PATH = {
  [1] = GetLoadAssetPath("PersonalZoneMedalDiy01"),
  [2] = GetLoadAssetPath("PersonalZoneMedalDiy02"),
  [3] = GetLoadAssetPath("PersonalZoneMedalDiy03")
}

function PersonalZoneMedalMain:ctor()
  self.uiBinder = nil
  super.ctor(self, "personal_zone_medal_main")
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.socialVM_ = Z.VMMgr.GetVM("social")
end

function PersonalZoneMedalMain:OnActive()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  local w = self.uiBinder.node_panel.rect.width
  local h = self.uiBinder.node_panel.rect.height
  self.cellPosition_ = self.personalZoneVM_.PrepareCellPos(w, h, CELL_SIZE)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_round, function()
    Z.UIMgr:OpenView("personal_zone_medal_edit_main")
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.OpenFullScreenTipsView(400008)
  end)
  self:AddClick(self.uiBinder.btn_check, function()
    self.personalZoneVM_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneMedal)
  end)
  if self.viewData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn, true)
  end
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnSaveMedalEdit, self.onSaveMedalEdit, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnMedalRedDotRefresh, self.refreshRedDot, self)
end

function PersonalZoneMedalMain:OnRefresh()
  self:refreshRedDot()
  self:refreshMedalEdit(self.viewData)
end

function PersonalZoneMedalMain:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnSaveMedalEdit, self.onSaveMedalEdit, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnMedalRedDotRefresh, self.refreshRedDot, self)
end

function PersonalZoneMedalMain:refreshMedalEdit(medal)
  Z.CoroUtil.create_coro_xpcall(function()
    self:ClearAllUnits()
    local medals
    if medal then
      medals = medal
    elseif Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.medals then
      medals = Z.ContainerMgr.CharSerialize.personalZone.medals
    end
    if not medals or not next(medals) then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nonemedal, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_line_frame, false)
      return
    end
    local count = 0
    for pos, id in pairs(medals) do
      if id ~= 0 then
        local config = Z.TableMgr.GetTable("MedalTableMgr").GetRow(id)
        if config then
          local path = MEDAL_PATH[config.Type]
          local unit = self:AsyncLoadUiUnit(path, id, self.uiBinder.node_panel, self.cancelSource:CreateToken())
          if unit then
            self:refreshMedalUnit(unit, config, pos)
            count = count + 1
          end
        end
      end
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nonemedal, count == 0)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_line_frame, count ~= 0)
  end)()
end

function PersonalZoneMedalMain:refreshMedalUnit(unit, config, pos)
  unit.img_medal_02:SetImage(config.Image)
  local cellOffset = self.cellPosition_[pos]
  unit.Trans.anchoredPosition = cellOffset
  unit.Ref:SetVisible(unit.btn_close, false)
  unit.Ref:SetVisible(unit.img_on, false)
  unit.Ref:SetVisible(unit.img_not, false)
end

function PersonalZoneMedalMain:onSaveMedalEdit()
  if Z.ContainerMgr.CharSerialize.personalZone then
    self:refreshMedalEdit(Z.ContainerMgr.CharSerialize.personalZone.medals)
  end
end

function PersonalZoneMedalMain:refreshRedDot()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot_1, self.personalZoneVM_.CheckMedalRed_1())
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot_2, self.personalZoneVM_.CheckMedalRed_2())
end

return PersonalZoneMedalMain
