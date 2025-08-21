local UI = Z.UI
local super = require("ui.ui_view_base")
local Com_rewards_windowView = class("Com_rewards_windowView", super)
local loopGridView = require("ui.component.loop_grid_view")
local rewards_item = require("ui.component.tips.com_rewards_window_item")
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
local windowOpenEffect = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit"
local chemistryItemTpl = require("ui.component.chemistry.chemistry_item_tpl")
local itemShowInterval = 0
local itemListShowInterval = 0.8
local SDKDefine = require("ui.model.sdk_define")
local privilegeShowLang = {
  [SDKDefine.LaunchPlatform.LaunchPlatformQq] = "QQPrivilegeAddItem",
  [SDKDefine.LaunchPlatform.LaunchPlatformWeXin] = "WeChatPrivilegeAddItem"
}

function Com_rewards_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "com_rewards_window")
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Com_rewards_windowView:OnActive()
  self.uiBinder.btn_close.enabled = false
  self.uiBinder.loop_item.enabled = false
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:CreatEFFGO(windowOpenEffect, Vector3.zero)
  self.uiBinder.node_effect:SetEffectGoVisible(true)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self.uiBinder.animDoTween:Play(Z.DOTweenAnimType.Open)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_arraw, false)
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  local title = ""
  local exceptionEndCB = function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_loop, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  if self.viewData.audio then
    Z.AudioMgr:Play(self.viewData.audio)
  else
    Z.AudioMgr:Play("sys_general_award")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_monthly_card, false)
  if self.viewData.chemistryId and self.viewData.chemistryId ~= 0 then
    local lifeProductionListConfig = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(self.viewData.chemistryId)
    if lifeProductionListConfig then
      self.uiBinder.chemistry_item.Ref.UIComp:SetVisible(true)
      chemistryItemTpl.RefreshTpl(self.uiBinder.chemistry_item.item, self.viewData.chemistryId, lifeProductionListConfig)
      self.uiBinder.chemistry_item.lab_content.text = lifeProductionListConfig.Des
    else
      self.uiBinder.chemistry_item.Ref.UIComp:SetVisible(false)
    end
  else
    self.uiBinder.chemistry_item.Ref.UIComp:SetVisible(false)
  end
  if self.viewData.itemList then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_loop, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
    self.uiBinder.anim:PlayOnce("anim_com_rewards_window_open_01")
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
      coro(0.2, self.cancelSource:CreateToken())
      self:refreshItemList()
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arraw, #self.viewData.itemList > 12)
      self.uiBinder.anim:PlayLoop("anim_com_rewards_window_loop")
    end)()
    if self.viewData.title then
      title = self.viewData.title
    elseif self.viewData.itemList and self.viewData.itemList[1] and self.viewData.itemList[1].name then
      title = self.viewData.itemList[1].name
    else
      title = Lang("CongratulationsGetting")
    end
  elseif self.viewData.configId then
    self.uiBinder.btn_close.enabled = true
    self.uiBinder.loop_item.enabled = true
    self:refreshItem()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_loop, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
    self.uiBinder.anim:CoroPlayOnce("anim_com_rewards_window_open_02", self.cancelSource:CreateToken(), function()
      self.uiBinder.anim:PlayLoop("anim_com_rewards_window_loop")
    end, exceptionEndCB)
    title = self.viewData.title
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData.configId)
    if itemConfig then
      if itemConfig.Type == E.ItemType.Vehicle then
        self.uiBinder.uibinder_goto.lab_normal.text = Lang("GoToAssembly")
      else
        self.uiBinder.uibinder_goto.lab_normal.text = Lang("TravelWear")
      end
    end
    self:AddClick(self.uiBinder.uibinder_goto.btn, function()
      if itemConfig then
        if itemConfig.Type == E.ItemType.Vehicle then
          local vehicleVM = Z.VMMgr.GetVM("vehicle")
          vehicleVM.OpenVehicleMain(self.viewData.configId)
        else
          local fashionVm = Z.VMMgr.GetVM("fashion")
          fashionVm.GotoFashionView(self.viewData.configId)
        end
      end
    end)
  else
    self:closeView()
    return
  end
  title = title or Z.IsPCUI and Lang("com_rewards_title_pc") or Lang("com_rewards_title")
  self.uiBinder.lab_title.text = title
  local size = self.uiBinder.lab_title:GetPreferredValues(title, 233, 67)
  self.uiBinder.lab_title_ref:SetWidth(size.x)
  self:AddClick(self.uiBinder.btn_close, function()
    self:closeView()
  end)
  self:AddClick(self.uiBinder.btn_monthly_close, function()
    self:closeView()
  end)
  self:AddClick(self.uiBinder.btn_recharge, function()
    Z.VMMgr.GetVM("gotofunc").GoToFunc(E.ShopFuncID.MonthlyCard)
  end)
  self:refreshPrivilegeShow()
end

function Com_rewards_windowView:OnDeActive()
  if self.rewardList_ then
    self.rewardList_:UnInit()
    self.rewardList_ = nil
  end
  self.uiBinder.node_effect:ReleseEffGo()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
end

function Com_rewards_windowView:refreshItemList()
  if not self.viewData or not self.viewData.itemList then
    return
  end
  itemSortFactoryVm.DefaultSendAwardSortByConfigId(self.viewData.itemList)
  self.rewardList_ = loopGridView.new(self, self.uiBinder.node_loop, rewards_item, "com_reward_window_item_tpl")
  self.itemAnimTime_ = #self.viewData.itemList > 12 and 12 * itemShowInterval or #self.viewData.itemList * itemShowInterval
  self.rewardList_:SetIsCenter(#self.viewData.itemList <= 12)
  self.rewardList_:Init(self.viewData.itemList)
  self:beginItemAnimAndEffect()
end

function Com_rewards_windowView:beginItemAnimAndEffect()
  Z.CoroUtil.create_coro_xpcall(function()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
    coro(self.itemAnimTime_, self.cancelSource:CreateToken())
    self.uiBinder.btn_close.enabled = true
    self.uiBinder.loop_item.enabled = true
    self.itemAnimEnd = true
  end)()
end

function Com_rewards_windowView:refreshItem()
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData.configId, true)
  if not itemRow then
    self:closeView()
    return
  end
  self.uiBinder.lab_name.text = itemRow.Name
  self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemLargeIcon(self.viewData.configId))
  self.uiBinder.img_quality:SetImage(string.zconcat(Z.ConstValue.Item.ItemQualityBackGroundImage, itemRow.Quality))
end

function Com_rewards_windowView:closeView()
  Z.UIMgr:CloseView("com_rewards_window")
end

function Com_rewards_windowView:setMonthlyCardNodeInfo()
  local isExpired = self.monthlyCardVM_:GetIsBuyCurrentMonthCard()
  if not isExpired then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_monthly_card, true)
end

function Com_rewards_windowView:refreshPrivilegeShow()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_privilege, false)
  if not self.viewData or not self.viewData.itemList then
    return
  end
  if not self.viewData.isShowPrivilege or not self.sdkVM_.IsShowPrivilege() then
    return
  end
  local paunchPlatform = Z.ContainerMgr.CharSerialize.launchPrivilegeData.launchPlatform
  local launchPrivilegeConfig = Z.TableMgr.GetTable("LaunchPrivilegeTableMgr").GetRow(paunchPlatform)
  if launchPrivilegeConfig == nil then
    return
  end
  local showPrivilegeItems = {}
  for _, privilege in ipairs(launchPrivilegeConfig.Privilege) do
    local privilegeConfig = Z.TableMgr.GetTable("PrivilegeConfigTableMgr").GetRow(privilege)
    if privilegeConfig then
      for _, value in ipairs(privilegeConfig.PrivilegeConfig) do
        if value[1] == E.PrivilegeShowType.Item then
          showPrivilegeItems[value[2]] = value[2]
        end
      end
    end
  end
  local isHavePrivilegeAddItem = false
  for _, value in ipairs(self.viewData.itemList) do
    if showPrivilegeItems[value.configId] ~= nil then
      isHavePrivilegeAddItem = true
      break
    end
  end
  if not isHavePrivilegeAddItem then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_privilege, true)
  self.uiBinder.lab_privilege.text = Lang(privilegeShowLang[paunchPlatform])
end

return Com_rewards_windowView
