local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_master_popupView = class("Hero_dungeon_master_popupView", super)
local item = require("common.item_binder")
local hero_dungeon_master_scoreTpl = require("ui.component.hero_dungeon.hero_dungeon_master_score_tpl")

function Hero_dungeon_master_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_master_popup")
  self.heroDungeonMasterScoreTpl = hero_dungeon_master_scoreTpl.new(self)
end

function Hero_dungeon_master_popupView:OnActive()
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.heroDungeonMainVm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.itemClass_ = {}
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.heroDungeonMainVm_.CloseMaseterScoreView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_share, function()
    self:shareMasterScore()
    self.heroDungeonMainVm_.CloseMaseterScoreView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2551)
  end)
  self.uiBinder.tog_show_has:RemoveAllListeners()
  self.uiBinder.tog_show_has.isOn = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.isShow
  self.uiBinder.tog_show_has:AddListener(function(isOn)
    Z.CoroUtil.create_coro_xpcall(function()
      self.heroDungeonMainVm_.AsyncSetShowMasterModeScore(isOn, self.cancelSource:CreateToken())
    end)()
  end)
  if self.viewData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_bg, true)
    self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_bg, false)
  end
  local viewData = {isPlayer = true}
  self.heroDungeonMasterScoreTpl:Init(self.uiBinder.hero_dungeon_master_tpl, viewData)
end

function Hero_dungeon_master_popupView:OnDeActive()
  self.heroDungeonMasterScoreTpl:UnInit()
  for index, value in ipairs(self.itemClass_) do
    value:UnInit()
  end
  self.itemClass_ = {}
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

function Hero_dungeon_master_popupView:OnRefresh()
  self:refreshScoreReward()
end

function Hero_dungeon_master_popupView:shareMasterScore()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ShareToChat)
  if not isOn then
    return
  end
  local chatData_ = Z.DataMgr.Get("chat_main_data")
  chatData_:RefreshShareData("", nil, E.ChatHyperLinkType.MasterDungeonScore)
  local draftData = {}
  draftData.msg = chatData_:GetHyperLinkShareContent()
  chatData_:SetChatDraft(draftData, E.ChatChannelType.EChannelWorld, E.ChatWindow.Main)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.MainChat)
end

function Hero_dungeon_master_popupView:refreshScoreReward()
  local path = self.uiBinder.prefab_cache:GetString("score_item")
  local root = self.uiBinder.layout_item
  local lineWidth = root.rect.width
  local config = Z.GlobalDungeon.MasterScoreAward
  local maxScore = config[#config][1]
  local score = self.heroDungeonMainVm_.GetPlayerSeasonMasterDungeonScore()
  self.uiBinder.img_ing.fillAmount = score / maxScore
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(config) do
      local unit = self:AsyncLoadUiUnit(path, "score_item_" .. index, root)
      local posX = lineWidth * (value[1] / maxScore)
      unit.Trans:SetAnchorPosition(posX, 0)
      unit.lab_num.text = value[1]
      local awardList = self.awardPreviewVm_.GetAllAwardPreListByIds(value[2])
      if self.itemClass_[index] then
        self.itemClass_[index]:UnInit()
      else
        self.itemClass_[index] = item.new(self)
      end
      local isReceive = self.heroDungeonMainVm_.CheckGetSeasonScoreAwrard(index)
      local canReceive = value[1] <= score
      local itemData = {}
      itemData.configId = awardList[1].awardId
      itemData.lab = awardList[1].awardNum
      itemData.uiBinder = unit.item_uibinder
      itemData.isSquareItem = true
      itemData.isShowReceive = isReceive
      unit.Ref:SetVisible(unit.reddot, canReceive and not isReceive)
      
      function itemData.clickCallFunc()
        local isReceive = self.heroDungeonMainVm_.CheckGetSeasonScoreAwrard(index)
        if not isReceive and canReceive then
          local isSuccess = self.heroDungeonMainVm_.AsyncGetMasterModeAward(index - 1, self.cancelSource:CreateToken())
          if not isSuccess then
            return
          end
          local data = {}
          for i = 1, #awardList do
            data[#data + 1] = {
              configId = awardList[1].awardId,
              count = awardList[1].awardNum
            }
          end
          Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
          self.itemClass_[index]:SetReceive(isSuccess)
          unit.Ref:SetVisible(unit.reddot, false)
        else
          if self.tipsId_ then
            Z.TipsVM.CloseItemTipsView(self.tipsId_)
          end
          self.tipsId_ = Z.TipsVM.ShowItemTipsView(unit.item_uibinder.Trans, awardList[1].awardId)
        end
      end
      
      self.itemClass_[index]:Init(itemData)
    end
  end)()
end

function Hero_dungeon_master_popupView:OnSeasonSelectChange(seasonId)
  local showScoreAward = seasonId == Z.VMMgr.GetVM("season").GetCurrentSeasonId()
end

return Hero_dungeon_master_popupView
