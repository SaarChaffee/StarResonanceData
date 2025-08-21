local super = require("ui.component.loop_list_view_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FishingRankingPlayerLoopItem = class("FishingRankingPlayerLoopItem", super)
local SDKDefine = require("ui.model.sdk_define")

function FishingRankingPlayerLoopItem:ctor()
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function FishingRankingPlayerLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.parentUIView:AddAsyncClick(self.uiBinder.node_normal.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick(self.data.rankData.playerData.basicData.charID)
  end)
  self.parentUIView:AddAsyncClick(self.uiBinder.node_normal.btn_qqprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self.parentUIView:AddAsyncClick(self.uiBinder.node_lv.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick(self.data.rankData.playerData.basicData.charID)
  end)
  self.parentUIView:AddAsyncClick(self.uiBinder.node_lv.btn_qqprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
end

function FishingRankingPlayerLoopItem:OnRefresh(data)
  self.data = data
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.com_head_46_item, self.data.rankData.playerData, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data.rankData.playerData.basicData.charID, self.parentUIView.cancelSource:CreateToken())
  end, self.parentUIView.cancelSource:CreateToken())
  self.uiBinder.node_lv.Ref.UIComp:SetVisible(self.data.rank <= 3)
  self.uiBinder.node_normal.Ref.UIComp:SetVisible(self.data.rank > 3)
  local personalzoneVm = Z.VMMgr.GetVM("personal_zone")
  personalzoneVm.SetPersonalInfoBgBySocialData(self.data.rankData.playerData, self.uiBinder.rimg_adorn)
  if self.data.rank <= 3 then
    self.uiBinder.node_lv.img_bg:SetImage(self.fishingData_.RankPathDict[self.data.rank])
    self.uiBinder.node_lv.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), self.data.rankData.size / 100)
    self.uiBinder.node_lv.lab_name.text = self.data.rankData.playerData.basicData.name
    self.uiBinder.node_lv.lab_digit.text = self.data.rank
    self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_wechatprivilege, false)
    self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_qqprivilege, false)
    if self:isSelf() then
      local accountData = Z.DataMgr.Get("account_data")
      local isPrivilege = self.sdkVM_.IsShowPrivilege()
      if accountData.LoginType == E.LoginType.QQ and isPrivilege then
        self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_qqprivilege, true)
      elseif accountData.LoginType == E.LoginType.WeChat and isPrivilege then
        self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_wechatprivilege, true)
      end
    else
      local privilegeData = self.data.rankData.playerData.privilegeData
      if privilegeData ~= nil then
        if privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformQq and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege) then
          self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_qqprivilege, privilegeData.isPrivilege)
        elseif privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformWeXin and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege) then
          self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_wechatprivilege, privilegeData.isPrivilege)
        end
      end
    end
    self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.data.rankData.playerData.basicData.isNewbie))
  else
    self.uiBinder.node_normal.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), self.data.rankData.size / 100)
    self.uiBinder.node_normal.lab_name.text = self.data.rankData.playerData.basicData.name
    self.uiBinder.node_normal.lab_digit.text = self.data.rank
    self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.data.rankData.playerData.basicData.isNewbie))
    self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.btn_wechatprivilege, false)
    self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.node_qqprivilege, false)
    if self:isSelf() then
      local accountData = Z.DataMgr.Get("account_data")
      local isPrivilege = self.sdkVM_.IsShowPrivilege()
      if accountData.LoginType == E.LoginType.QQ and isPrivilege then
        self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.node_qqprivilege, true)
      elseif accountData.LoginType == E.LoginType.WeChat and isPrivilege then
        self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.btn_wechatprivilege, true)
      end
    else
      local privilegeData = self.data.rankData.playerData.privilegeData
      if privilegeData ~= nil then
        if privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformQq and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege) then
          self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.node_qqprivilege, privilegeData.isPrivilege)
        elseif privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformWeXin and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege) then
          self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.btn_wechatprivilege, privilegeData.isPrivilege)
        end
      end
    end
  end
end

function FishingRankingPlayerLoopItem:OnUnInit()
end

function FishingRankingPlayerLoopItem:isSelf()
  return self.data.rankData.playerData.basicData.charID == Z.EntityMgr.PlayerEnt.EntId
end

return FishingRankingPlayerLoopItem
