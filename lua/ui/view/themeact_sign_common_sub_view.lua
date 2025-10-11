local UI = Z.UI
local super = require("ui.ui_subview_base")
local Themeact_sign_common_subView = class("Themeact_sign_common_subView", super)
local itemBinder = require("common.item_binder")

function Themeact_sign_common_subView:ctor(parent, viewConfigKey, assetPath)
  self.uiBinder = nil
  self.parent_ = parent
  super.ctor(self, viewConfigKey, assetPath, UI.ECacheLv.None)
end

function Themeact_sign_common_subView:GetSignType()
  return E.SignActivityType.ThemeActivity1
end

function Themeact_sign_common_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self:initAwardBinder()
  self:bindEvents()
  self:setRawImage()
end

function Themeact_sign_common_subView:OnDeActive()
  self:unInitAwardBinder()
  self:closeItemTips()
  self:unBindEvents()
  self.parent_.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_1)
  self.uiBinder.eff_1:SetEffectGoVisible(false)
  self.parent_.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_2)
  self.uiBinder.eff_2:SetEffectGoVisible(false)
end

function Themeact_sign_common_subView:OnRefresh()
  self:refreshAwardBinder()
end

function Themeact_sign_common_subView:initData()
  self.themePlayData_ = Z.DataMgr.Get("theme_play_data")
  self.themePlayVM_ = Z.VMMgr.GetVM("theme_play")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.config_ = self.viewData.config
  self.signType_ = self:GetSignType()
end

function Themeact_sign_common_subView:initComponent()
  self.uiBinder.comp_dotween:Restart(Z.DOTweenAnimType.Open)
  self.parent_.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_1)
  self.uiBinder.eff_1:SetEffectGoVisible(true)
  self.parent_.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_2)
  self.uiBinder.eff_2:SetEffectGoVisible(true)
end

function Themeact_sign_common_subView:initAwardBinder()
  self.awardBinderDict_ = {}
  local configDict = self.themePlayData_:GetSignDataByType(self.signType_)
  for k, v in pairs(configDict) do
    local uiBinder = self.uiBinder["item_" .. k]
    if uiBinder then
      self.awardBinderDict_[k] = itemBinder.new(self)
      self.awardBinderDict_[k]:Init({uiBinder = uiBinder})
    end
  end
end

function Themeact_sign_common_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.ThemePlay.SignActivityRefresh, self.refreshAwardBinder, self)
end

function Themeact_sign_common_subView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ThemePlay.SignActivityRefresh, self.refreshAwardBinder, self)
end

function Themeact_sign_common_subView:refreshAwardBinder()
  local configDict = self.themePlayData_:GetSignDataByType(self.signType_)
  for day, uiBinder in pairs(self.awardBinderDict_) do
    local config = configDict[day]
    if config ~= nil then
      local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(config.AwardId)
      if awardList and 0 < #awardList then
        local awardData = awardList[1]
        local itemData = {}
        itemData.configId = awardData.awardId
        itemData.uiBinder = uiBinder
        itemData.labType, itemData.lab = self.awardPreviewVM_.GetPreviewShowNum(awardData)
        itemData.isShowZero = false
        itemData.isShowOne = true
        itemData.isShowReceive = false
        itemData.isSquareItem = true
        itemData.PrevDropType = awardData.PrevDropType
        
        function itemData.clickCallFunc()
          self:onAwardItemClick(day, awardData)
        end
        
        uiBinder:RefreshByData(itemData)
      end
    end
    local isCanReceive = self:isAwardCanReceive(day)
    local img_can_receive = self.uiBinder["img_can_receive_" .. day]
    if img_can_receive then
      self:SetUIVisible(img_can_receive, isCanReceive)
    end
    local effCanReceive = self.uiBinder["uieffect_" .. day]
    if effCanReceive then
      effCanReceive:SetEffectGoVisible(isCanReceive)
    end
    uiBinder:SetRedDot(isCanReceive)
    local img_had_receive = self.uiBinder["img_had_receive_" .. day]
    if img_had_receive then
      self:SetUIVisible(img_had_receive, self:isAwardHadReceive(day))
    end
  end
end

function Themeact_sign_common_subView:unInitAwardBinder()
  for day, uiBinder in pairs(self.awardBinderDict_) do
    uiBinder:UnInit()
  end
  self.awardBinderDict_ = nil
end

function Themeact_sign_common_subView:isAwardCanReceive(day)
  return self.themePlayData_:GetSignAwardData(self.signType_, day) == E.DrawState.CanDraw
end

function Themeact_sign_common_subView:isAwardHadReceive(day)
  return self.themePlayData_:GetSignAwardData(self.signType_, day) == E.DrawState.AlreadyDraw
end

function Themeact_sign_common_subView:onAwardItemClick(day, awardData)
  if self:isAwardCanReceive(day) then
    local result = self.themePlayVM_:AsyncGetSignAward(self.signType_, day, self.cancelSource:CreateToken())
    if result then
      self:refreshAwardBinder()
    end
  else
    local uiBinder = self.uiBinder["item_" .. day]
    if uiBinder then
      self:openItemTips(uiBinder.Trans, awardData.awardId)
    end
  end
end

function Themeact_sign_common_subView:openItemTips(trans, configId)
  self:closeItemTips()
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(trans, configId)
end

function Themeact_sign_common_subView:closeItemTips()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function Themeact_sign_common_subView:setRawImage()
end

return Themeact_sign_common_subView
