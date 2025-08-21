local super = require("ui.component.loop_list_view_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local UnionApplicationItem = class("UnionApplicationItem", super)

function UnionApplicationItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function UnionApplicationItem:OnInit()
  self:AddAsyncListener(self.uiBinder.btn_agree, function()
    local curData = self:GetCurData()
    if curData and curData.clickFunc then
      curData.clickFunc(curData.socialData.basicData.charID, true)
    end
  end)
  self:AddAsyncListener(self.uiBinder.btn_refuse, function()
    local curData = self:GetCurData()
    if curData and curData.clickFunc then
      curData.clickFunc(curData.socialData.basicData.charID, false)
    end
  end)
end

function UnionApplicationItem:OnRefresh(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(data.socialData.basicData.isNewbie))
  self.uiBinder.lab_name.text = data.socialData.basicData.name
  self.uiBinder.lab_gs.text = data.socialData.fightPoint or 0
  self.uiBinder.lab_role_level.text = data.socialData.basicData.level
  self.uiBinder.lab_state.text = self.unionVM_:GetLastTimeDesignText(data.socialData.basicData.offlineTime)
  if data.socialData.basicData.offlineTime == 0 then
    self.uiBinder.img_icon_state:SetImage(Z.ConstValue.UnionRes.StateOnIcon)
  else
    self.uiBinder.img_icon_state:SetImage(Z.ConstValue.UnionRes.StateOffIcon)
  end
  local personalzoneVm = Z.VMMgr.GetVM("personal_zone")
  personalzoneVm.SetPersonalInfoBgBySocialData(data.socialData, self.uiBinder.rimg_card)
  local hasPower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.ProcessApplication)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_btn_root, hasPower)
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, data.socialData, function()
    self:onPortraitClick()
  end, self.parent.UIView.cancelSource:CreateToken())
end

function UnionApplicationItem:OnUnInit()
end

function UnionApplicationItem:onPortraitClick()
  Z.CoroUtil.create_coro_xpcall(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(curData.socialData.basicData.charID, self.parent.UIView.cancelSource:CreateToken())
  end)()
end

return UnionApplicationItem
